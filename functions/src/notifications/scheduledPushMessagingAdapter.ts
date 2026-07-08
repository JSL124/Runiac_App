import { Timestamp } from "firebase-admin/firestore";
import {
  createInboxPayload,
  deviceDeliveryKey,
  type NotificationDeviceRecord,
  type NotificationDispatch,
  type NotificationSendAdapter,
} from "./dispatchPlanner.js";
import type { ScheduledPushDependencies } from "./scheduledPushFirestore.js";

export function firestoreMessagingAdapter(
  dependencies: ScheduledPushDependencies,
  now: string,
): NotificationSendAdapter {
  return {
    send: async (
      dispatch: NotificationDispatch,
      device: NotificationDeviceRecord,
      inboxPayload,
    ) => {
      const deliveryRef = dependencies.firestore
        .collection("notificationDeliveries")
        .doc(deviceDeliveryKey(dispatch.deliveryKey, device.tokenFingerprint));
      const timestampNow = Timestamp.fromDate(new Date(now));
      const deliveryCreated = await dependencies.firestore.runTransaction(async (transaction) => {
        const existingDelivery = await transaction.get(deliveryRef);
        if (existingDelivery.exists && existingDelivery.get("status") === "sent") {
          return false;
        }
        transaction.set(deliveryRef, {
          ...inboxPayload,
          createdAt: timestampNow,
          sentAt: timestampNow,
          status: "pending",
          updatedAt: timestampNow,
        });
        transaction.set(
          dependencies.firestore
            .collection("notificationInbox")
            .doc(dispatch.uid)
            .collection("items")
            .doc(dispatch.deliveryKey),
          {
            ...createInboxPayload(dispatch, device.tokenFingerprint, now),
            createdAt: timestampNow,
            updatedAt: timestampNow,
          },
          { merge: true },
        );
        return true;
      });
      if (!deliveryCreated) {
        return { status: "skipped-duplicate" };
      }

      try {
        await dependencies.messaging.send({
          token: device.fcmToken,
          notification: {
            title: dispatch.title,
            body: dispatch.body,
          },
          data: {
            deliveryKey: dispatch.deliveryKey,
            kind: dispatch.kind,
            scheduledDate: dispatch.scheduledDate,
            ...(dispatch.scheduledWorkoutId === null
              ? {}
              : { scheduledWorkoutId: dispatch.scheduledWorkoutId }),
          },
        });
        await deliveryRef.set({ status: "sent", sentAt: timestampNow, updatedAt: timestampNow }, { merge: true });
        return { status: "sent" };
      } catch (error) {
        if (isInvalidTokenError(error)) {
          await deliveryRef.set({ status: "invalid-token", updatedAt: timestampNow }, { merge: true });
          return { status: "invalid-token", disabledAt: now };
        }
        await deliveryRef.set(
          {
            status: "failed",
            errorCode: errorCode(error),
            updatedAt: timestampNow,
          },
          { merge: true },
        );
        throw error;
      }
    },
    disableToken: async (device: NotificationDeviceRecord, disabledAt: string) => {
      await dependencies.firestore
        .collection("notificationDevices")
        .doc(device.uid)
        .collection("tokens")
        .doc(device.tokenFingerprint)
        .set(
          {
            enabled: false,
            disabledAt,
            updatedAt: Timestamp.fromDate(new Date(disabledAt)),
          },
          { merge: true },
        );
    },
  };
}

function isInvalidTokenError(error: unknown): boolean {
  const code = errorCode(error);
  return code === "messaging/invalid-registration-token" || code === "messaging/registration-token-not-registered";
}

function errorCode(error: unknown): string {
  if (isRecord(error) && typeof error["code"] === "string") {
    return error["code"];
  }
  return "unknown";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
