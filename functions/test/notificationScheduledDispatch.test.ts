import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { dispatchScheduledPushNotificationsNow } from "../src/notifications/scheduledPushDispatch.js";

const PROJECT_ID = "runiac-functions-test";
const USER_UID = "notification-runner-002";
const WORKOUT_ID = "week-1-thu-easy-run";
const FCM_TOKEN = "fcm-token-dispatch-secret";

let firestore: Firestore;

before(() => {
  if (getApps().length === 0) {
    initializeApp({ projectId: PROJECT_ID });
  }

  firestore = getFirestore();
});

beforeEach(async () => {
  await clearDispatchCollections();
});

describe("scheduled notification dispatch", () => {
  it("sends due push once and writes delivery plus inbox records", async () => {
    await seedDispatchUser();
    const sentTokens: string[] = [];
    const messaging = {
      send: async (message: { readonly token: string }) => {
        sentTokens.push(message.token);
        return "message-id-001";
      },
    };

    const first = await dispatchScheduledPushNotificationsNow(
      { firestore, messaging },
      "2026-07-09T21:00:00.000Z",
    );
    const second = await dispatchScheduledPushNotificationsNow(
      { firestore, messaging },
      "2026-07-09T21:00:00.000Z",
    );

    const deliveryKey = `${USER_UID}:plan_start_minus_120:2026-07-10:${WORKOUT_ID}`;
    const delivery = await firestore.doc(`notificationDeliveries/${deliveryKey}:fingerprint-dispatch`).get();
    const inbox = await firestore.doc(`notificationInbox/${USER_UID}/items/${deliveryKey}`).get();

    assert.deepEqual(sentTokens, [FCM_TOKEN]);
    assert.equal(first.usersScanned, 1);
    assert.equal(first.dispatchesPlanned, 1);
    assert.equal(first.sendsAttempted, 1);
    assert.equal(second.dispatchesPlanned, 1);
    assert.equal(second.sendsAttempted, 0);
    assert.equal(delivery.get("status"), "sent");
    assert.equal(delivery.get("ownerUid"), USER_UID);
    assert.equal(delivery.get("tokenFingerprint"), "fingerprint-dispatch");
    assert.equal(delivery.get("fcmToken"), undefined);
    assert.equal(typeof delivery.get("createdAt"), "object");
    assert.equal(typeof inbox.get("createdAt"), "object");
    assert.equal(inbox.get("title"), "Easy Run");
    assert.equal(inbox.get("readAt"), null);
    assert.equal(inbox.get("deletedAt"), undefined);
  });

  it("sends to each enabled device and retries failed deliveries", async () => {
    await seedDispatchUser();
    await firestore.doc(`notificationDevices/${USER_UID}/tokens/fingerprint-second`).set({
      ownerUid: USER_UID,
      tokenFingerprint: "fingerprint-second",
      fcmToken: "fcm-token-second",
      enabled: true,
      updatedAt: "2026-07-09T20:55:00.000Z",
    });
    const sentTokens: string[] = [];
    const messaging = {
      send: async (message: { readonly token: string }) => {
        sentTokens.push(message.token);
        if (sentTokens.length === 1) {
          throw new TestMessagingError("transient send failure", "messaging/internal-error");
        }
        return `message-id-${sentTokens.length}`;
      },
    };

    await assert.rejects(
      () =>
        dispatchScheduledPushNotificationsNow(
          { firestore, messaging },
          "2026-07-09T21:00:00.000Z",
        ),
      /transient send failure/,
    );
    const retry = await dispatchScheduledPushNotificationsNow(
      { firestore, messaging },
      "2026-07-09T21:00:00.000Z",
    );

    assert.deepEqual(sentTokens.sort(), [
      FCM_TOKEN,
      FCM_TOKEN,
      "fcm-token-second",
    ].sort());
    assert.equal(retry.sendsAttempted, 2);
  });
});

class TestMessagingError extends Error {
  constructor(
    message: string,
    readonly code: string,
  ) {
    super(message);
  }
}

async function seedDispatchUser(): Promise<void> {
  await firestore.doc(`notificationDevices/${USER_UID}`).set({
    ownerUid: USER_UID,
    updatedAt: "2026-07-09T20:55:00.000Z",
  });
  await firestore.doc(`notificationDevices/${USER_UID}/tokens/fingerprint-dispatch`).set({
    ownerUid: USER_UID,
    tokenFingerprint: "fingerprint-dispatch",
    fcmToken: FCM_TOKEN,
    enabled: true,
    updatedAt: "2026-07-09T20:55:00.000Z",
  });
  await firestore.doc(`userProfiles/${USER_UID}`).set({
    ownerUid: USER_UID,
    streakCount: 2,
    lastStreakRunDate: "2026-07-09",
  });
  await firestore.doc(`notificationPreferences/${USER_UID}`).set({
    ownerUid: USER_UID,
    planRemindersEnabled: true,
    streakRiskEnabled: true,
    updatedAt: "2026-07-09T20:55:00.000Z",
  });
  await firestore.doc(`generatedPlans/${USER_UID}`).set({
    ownerUid: USER_UID,
    planId: "plan-dispatch",
    startsOnDate: "2026-07-06",
    weeks: [
      {
        weekNumber: 1,
        workouts: [
          {
            scheduledWorkoutId: WORKOUT_ID,
            dayLabel: "Friday",
            title: "Easy Run",
            durationMinutes: 20,
            scheduleTimeLabel: "07:00",
          },
        ],
      },
    ],
  });
  await firestore.doc(`planProgress/${USER_UID}`).set({
    ownerUid: USER_UID,
    workouts: {},
  });
}

async function clearDispatchCollections(): Promise<void> {
  await Promise.all([
    clearCollection("generatedPlans"),
    clearCollection("planProgress"),
    clearCollection("userProfiles"),
    clearCollection("notificationPreferences"),
    clearCollection("notificationDeliveries"),
    clearCollection("notificationInbox"),
    clearNotificationDevices(),
  ]);
}

async function clearCollection(name: string): Promise<void> {
  const snapshot = await firestore.collection(name).get();
  await Promise.all(
    snapshot.docs.map(async (document) => {
      const items = await document.ref.collection("items").get();
      await Promise.all(items.docs.map((item) => item.ref.delete()));
      await document.ref.delete();
    }),
  );
}

async function clearNotificationDevices(): Promise<void> {
  const userDevices = await firestore.collection("notificationDevices").get();
  await Promise.all(
    userDevices.docs.map(async (userDocument) => {
      const tokens = await userDocument.ref.collection("tokens").get();
      await Promise.all(tokens.docs.map((tokenDocument) => tokenDocument.ref.delete()));
      await userDocument.ref.delete();
    }),
  );
}
