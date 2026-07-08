import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import {
  hashNotificationToken,
  registerNotificationDeviceForCallable,
  unregisterNotificationDeviceForCallable,
} from "../src/notifications/deviceRegistry.js";

const PROJECT_ID = "runiac-functions-test";
const USER_UID = "notification-runner-001";
const FCM_TOKEN = "fcm-token-registration-secret";

type CallableRequest = {
  readonly auth?: {
    readonly uid: string;
  };
  readonly data: unknown;
};

let firestore: Firestore;

before(() => {
  if (getApps().length === 0) {
    initializeApp({ projectId: PROJECT_ID });
  }

  firestore = getFirestore();
});

beforeEach(async () => {
  await clearNotificationDevices();
});

describe("notification device callable boundary", () => {
  it("rejects unauthenticated token registration", async () => {
    await expectRejectsCode(
      () => registerNotificationDeviceForCallable({ data: registrationPayload() }, firestore),
      "unauthenticated",
    );
  });

  it("stores registered tokens under a hashed fingerprint without returning the raw token", async () => {
    const result = await registerNotificationDeviceForCallable(
      authenticatedRequest(registrationPayload()),
      firestore,
    );
    const expectedFingerprint = hashNotificationToken(FCM_TOKEN);
    const tokenDocument = await firestore
      .doc(`notificationDevices/${USER_UID}/tokens/${expectedFingerprint}`)
      .get();

    assert.equal(result.status, "registered");
    assert.equal(result.fingerprint, expectedFingerprint);
    assert.equal(JSON.stringify(result).includes(FCM_TOKEN), false);
    assert.notEqual(result.fingerprint, FCM_TOKEN);
    assert.equal(tokenDocument.exists, true);
    assert.equal(tokenDocument.id, expectedFingerprint);
    assert.notEqual(tokenDocument.id, FCM_TOKEN);
    assert.equal(tokenDocument.get("ownerUid"), USER_UID);
    assert.equal(tokenDocument.get("tokenFingerprint"), expectedFingerprint);
    assert.equal(tokenDocument.get("fcmToken"), FCM_TOKEN);
    assert.equal(tokenDocument.get("enabled"), true);
    assert.equal(tokenDocument.get("disabledAt"), null);
  });

  it("disables a registered token on unregister", async () => {
    const registered = await registerNotificationDeviceForCallable(
      authenticatedRequest(registrationPayload()),
      firestore,
    );

    const result = await unregisterNotificationDeviceForCallable(
      authenticatedRequest({
        token: FCM_TOKEN,
        now: "2026-07-08T10:15:00.000Z",
      }),
      firestore,
    );
    const tokenDocument = await firestore
      .doc(`notificationDevices/${USER_UID}/tokens/${registered.fingerprint}`)
      .get();

    assert.equal(result.status, "disabled");
    assert.equal(result.fingerprint, registered.fingerprint);
    assert.equal(JSON.stringify(result).includes(FCM_TOKEN), false);
    assert.equal(tokenDocument.get("enabled"), false);
    assert.equal(tokenDocument.get("disabledAt"), "2026-07-08T10:15:00.000Z");
  });
});

function authenticatedRequest(data: unknown): CallableRequest {
  return {
    auth: { uid: USER_UID },
    data,
  };
}

function registrationPayload(): Record<string, unknown> {
  return {
    token: FCM_TOKEN,
    platform: "ios",
    appInstallationId: "install-001",
    now: "2026-07-08T10:00:00.000Z",
  };
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

async function expectRejectsCode(action: () => Promise<unknown>, code: string): Promise<void> {
  await assert.rejects(
    action,
    (error: unknown) => {
      assert.ok(error instanceof Error);
      assert.equal("code" in error ? error.code : undefined, code);
      return true;
    },
  );
}
