import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onSchedule } from "firebase-functions/v2/scheduler";
import {
  dispatchScheduledPushNotificationsForUsers,
  type DispatchResult,
  type ScheduledPushDependencies,
} from "./scheduledPushFirestore.js";

if (getApps().length === 0) {
  initializeApp();
}

export const dispatchScheduledPushNotifications = onSchedule(
  {
    schedule: "every 10 minutes",
    timeZone: "Asia/Singapore",
    region: "asia-southeast1",
  },
  async () => {
    await dispatchScheduledPushNotificationsNow({
      firestore: getFirestore(),
      messaging: getMessaging(),
    });
  },
);

export async function dispatchScheduledPushNotificationsNow(
  dependencies: ScheduledPushDependencies,
  now: string = new Date().toISOString(),
): Promise<DispatchResult> {
  return dispatchScheduledPushNotificationsForUsers(dependencies, now);
}
