import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  createInboxPayload,
  deliveryKeyFor,
  planNotificationDispatches,
  sendNotificationDispatches,
  type NotificationDeviceRecord,
  type NotificationSendAdapter,
} from "../src/notifications/dispatchPlanner.js";

const USER_UID = "notification-runner-002";
const WORKOUT_ID = "week-1-thu-easy-run";

describe("notification dispatch planner", () => {
  it("emits plan reminder cases at midnight, before starts, and after missed runs", () => {
    const expectedCases = [
      ["2026-07-09T16:00:00.000Z", "today_plan_midnight"],
      ["2026-07-09T21:00:00.000Z", "plan_start_minus_120"],
      ["2026-07-09T22:00:00.000Z", "plan_start_minus_60"],
      ["2026-07-09T22:50:00.000Z", "plan_start_minus_10"],
      ["2026-07-10T00:00:00.000Z", "missed_run_plus_60"],
      ["2026-07-10T01:00:00.000Z", "missed_run_plus_120"],
    ] as const;

    for (const [now, expectedKind] of expectedCases) {
      const dispatches = planNotificationDispatches(planContext(now));

      assert.equal(dispatches.length, 1);
      assert.equal(dispatches[0]?.kind, expectedKind);
      assert.equal(dispatches[0]?.scheduledWorkoutId, WORKOUT_ID);
      assert.equal(dispatches[0]?.deliveryKey, deliveryKeyFor(dispatches[0]));
    }
  });

  it("emits streak-risk reminders only at 22:00 or 23:00 Singapore time when enabled and incomplete", () => {
    const enabledAt22 = planNotificationDispatches(streakContext("2026-07-10T14:00:00.000Z"));
    const enabledAt23 = planNotificationDispatches(streakContext("2026-07-10T15:00:00.000Z"));
    const enabledAt21 = planNotificationDispatches(streakContext("2026-07-10T13:00:00.000Z"));
    const disabled = planNotificationDispatches(
      streakContext("2026-07-10T14:00:00.000Z", {
        streakRiskEnabled: false,
        completedToday: false,
      }),
    );
    const completed = planNotificationDispatches(
      streakContext("2026-07-10T14:00:00.000Z", {
        streakRiskEnabled: true,
        completedToday: true,
      }),
    );

    assert.equal(enabledAt22.length, 1);
    assert.equal(enabledAt22[0]?.kind, "streak_risk_22");
    assert.equal(enabledAt23.length, 1);
    assert.equal(enabledAt23[0]?.kind, "streak_risk_23");
    assert.equal(enabledAt21.length, 0);
    assert.equal(disabled.length, 0);
    assert.equal(completed.length, 0);
  });

  it("generates stable delivery keys and inbox payloads without raw tokens", () => {
    const dispatch = planNotificationDispatches(planContext("2026-07-09T21:00:00.000Z"))[0];
    assert.ok(dispatch !== undefined);

    const firstKey = deliveryKeyFor(dispatch);
    const secondKey = deliveryKeyFor({ ...dispatch });
    const payload = createInboxPayload(dispatch, "fingerprint-001", "2026-07-09T21:00:00.000Z");

    assert.equal(firstKey, secondKey);
    assert.equal(payload.deliveryKey, firstKey);
    assert.equal(payload.ownerUid, USER_UID);
    assert.equal(payload.tokenFingerprint, "fingerprint-001");
    assert.equal(JSON.stringify(payload).includes("fcm-token"), false);
  });

  it("disables invalid or unregistered notification devices through the send adapter cleanup seam", async () => {
    const dispatch = planNotificationDispatches(planContext("2026-07-09T21:00:00.000Z"))[0];
    assert.ok(dispatch !== undefined);
    const disabledFingerprints: string[] = [];
    const adapter: NotificationSendAdapter = {
      send: async () => ({
        status: "invalid-token",
        disabledAt: "2026-07-09T21:00:01.000Z",
      }),
      disableToken: async (device: NotificationDeviceRecord, disabledAt: string) => {
        disabledFingerprints.push(`${device.tokenFingerprint}:${disabledAt}`);
      },
    };
    const devices: readonly NotificationDeviceRecord[] = [
      {
        uid: USER_UID,
        tokenFingerprint: "fingerprint-invalid",
        fcmToken: "fcm-token-invalid",
      },
    ];

    const results = await sendNotificationDispatches({
      dispatches: [dispatch],
      devices,
      adapter,
      sentDeliveryKeys: new Set<string>(),
      now: "2026-07-09T21:00:01.000Z",
    });

    assert.deepEqual(results, [
      {
        deliveryKey: dispatch.deliveryKey,
        tokenFingerprint: "fingerprint-invalid",
        status: "invalid-token",
      },
    ]);
    assert.deepEqual(disabledFingerprints, ["fingerprint-invalid:2026-07-09T21:00:01.000Z"]);
  });

});

function planContext(now: string) {
  return {
    now,
    uid: USER_UID,
    notificationPreferences: {
      planRemindersEnabled: true,
      streakRiskEnabled: true,
    },
    plannedWorkouts: [
      {
        scheduledWorkoutId: WORKOUT_ID,
        title: "Easy Run",
        scheduledDate: "2026-07-10",
        startTime: "07:00",
      },
    ],
    completedWorkoutIds: [],
    streakState: {
      streakCount: 2,
      lastStreakRunDate: "2026-07-09",
    },
  };
}

function streakContext(
  now: string,
  options: {
    readonly streakRiskEnabled: boolean;
    readonly completedToday: boolean;
  } = {
    streakRiskEnabled: true,
    completedToday: false,
  },
) {
  return {
    now,
    uid: USER_UID,
    notificationPreferences: {
      planRemindersEnabled: false,
      streakRiskEnabled: options.streakRiskEnabled,
    },
    plannedWorkouts: [],
    completedWorkoutIds: [],
    streakState: {
      streakCount: 4,
      lastStreakRunDate: options.completedToday ? "2026-07-10" : "2026-07-09",
    },
  };
}
