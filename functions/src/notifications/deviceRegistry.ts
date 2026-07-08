import { createHash } from "node:crypto";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

type CallableNotificationRequest = {
  readonly auth?: {
    readonly uid: string;
  };
  readonly data: unknown;
};

type NotificationPlatform = "android" | "ios" | "web";

type RegisterNotificationDevicePayload = {
  readonly token: string;
  readonly platform: NotificationPlatform;
  readonly appInstallationId: string;
  readonly now: string;
};

type UnregisterNotificationDevicePayload = {
  readonly token: string;
  readonly now: string;
};

export type NotificationDeviceMutationResult = {
  readonly status: "registered" | "disabled";
  readonly fingerprint: string;
};

if (getApps().length === 0) {
  initializeApp();
}

export const registerNotificationDevice = onCall({ region: "asia-southeast1" }, async (request) =>
  registerNotificationDeviceForCallable(request, getFirestore()),
);

export const unregisterNotificationDevice = onCall({ region: "asia-southeast1" }, async (request) =>
  unregisterNotificationDeviceForCallable(request, getFirestore()),
);

export async function registerNotificationDeviceForCallable(
  request: CallableNotificationRequest,
  firestore: Firestore,
): Promise<NotificationDeviceMutationResult> {
  const uid = authenticatedUid(request);
  const payload = parseRegisterPayload(request.data);
  const fingerprint = hashNotificationToken(payload.token);
  const tokenRef = firestore.doc(`notificationDevices/${uid}/tokens/${fingerprint}`);

  await firestore.doc(`notificationDevices/${uid}`).set(
    {
      ownerUid: uid,
      updatedAt: payload.now,
    },
    { merge: true },
  );
  await tokenRef.set(
    {
      ownerUid: uid,
      tokenFingerprint: fingerprint,
      fcmToken: payload.token,
      platform: payload.platform,
      appInstallationId: payload.appInstallationId,
      enabled: true,
      registeredAt: payload.now,
      updatedAt: payload.now,
      disabledAt: null,
    },
    { merge: true },
  );

  return {
    status: "registered",
    fingerprint,
  };
}

export async function unregisterNotificationDeviceForCallable(
  request: CallableNotificationRequest,
  firestore: Firestore,
): Promise<NotificationDeviceMutationResult> {
  const uid = authenticatedUid(request);
  const payload = parseUnregisterPayload(request.data);
  const fingerprint = hashNotificationToken(payload.token);

  await firestore.doc(`notificationDevices/${uid}/tokens/${fingerprint}`).set(
    {
      ownerUid: uid,
      tokenFingerprint: fingerprint,
      enabled: false,
      updatedAt: payload.now,
      disabledAt: payload.now,
    },
    { merge: true },
  );

  return {
    status: "disabled",
    fingerprint,
  };
}

export function hashNotificationToken(token: string): string {
  if (token.length === 0) {
    throw new HttpsError("invalid-argument", "A notification token is required.");
  }

  return createHash("sha256").update(token, "utf8").digest("hex");
}

function authenticatedUid(request: CallableNotificationRequest): string {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) {
    throw new HttpsError("unauthenticated", "Authentication is required to manage notification devices.");
  }

  return uid;
}

function parseRegisterPayload(data: unknown): RegisterNotificationDevicePayload {
  const value = parseObject(data);
  const token = readRequiredString(value, "token");
  const appInstallationId = readRequiredString(value, "appInstallationId");
  const now = readRequiredIsoInstant(value, "now");
  const platform = readPlatform(value["platform"]);

  return {
    token,
    platform,
    appInstallationId,
    now,
  };
}

function parseUnregisterPayload(data: unknown): UnregisterNotificationDevicePayload {
  const value = parseObject(data);

  return {
    token: readRequiredString(value, "token"),
    now: readRequiredIsoInstant(value, "now"),
  };
}

function parseObject(data: unknown): Record<string, unknown> {
  if (!isRecord(data)) {
    throw new HttpsError("invalid-argument", "Notification device payload must be an object.");
  }

  return data;
}

function isRecord(data: unknown): data is Record<string, unknown> {
  return typeof data === "object" && data !== null && !Array.isArray(data);
}

function readRequiredString(data: Record<string, unknown>, field: string): string {
  const value = data[field];
  if (typeof value !== "string" || value.length === 0) {
    throw new HttpsError("invalid-argument", `${field} must be a non-empty string.`);
  }

  return value;
}

function readRequiredIsoInstant(data: Record<string, unknown>, field: string): string {
  const value = readRequiredString(data, field);
  const date = new Date(value);
  if (Number.isNaN(date.getTime()) || date.toISOString() !== value) {
    throw new HttpsError("invalid-argument", `${field} must be an ISO-8601 UTC instant.`);
  }

  return value;
}

function readPlatform(value: unknown): NotificationPlatform {
  if (value === "android" || value === "ios" || value === "web") {
    return value;
  }

  throw new HttpsError("invalid-argument", "platform must be android, ios, or web.");
}
