// Scheduled premium subscription expiry sweep (same registration style as
// `settleChallengeDeadlines` / `dispatchScheduledPushNotifications`: a thin
// `onSchedule` wrapper delegating to a testable, dependency-injected core).
// Runs once a day; repeated invocations are idempotent — a user already
// downgraded to `basic` no longer matches the sweep's query.

import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import {
  runSubscriptionExpirySweep,
  type SubscriptionExpirySweepResult,
} from "./subscriptionExpiryCore.js";

if (getApps().length === 0) {
  initializeApp();
}

export const expireSubscriptions = onSchedule(
  {
    schedule: "every day 03:00",
    timeZone: "Asia/Singapore",
    region: "asia-southeast1",
  },
  async () => {
    await expireSubscriptionsNow();
  },
);

export async function expireSubscriptionsNow(
  nowMs: number = Date.now(),
): Promise<SubscriptionExpirySweepResult> {
  return runSubscriptionExpirySweep(getFirestore(), nowMs);
}
