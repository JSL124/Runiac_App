import { HttpsError } from "firebase-functions/v2/https";
import type { RawRunCompletionPayload } from "./runCompletionTypes.js";

const allowedKeys = new Set([
  "clientRunSessionId",
  "startedAt",
  "completedAt",
  "durationSeconds",
  "distanceMeters",
  "avgPaceSecondsPerKm",
  "source",
  "routePrivacy",
  "routeLabel",
  "avgHeartRate",
  "caloriesEstimate",
  "planEnrollmentId",
  "scheduledWorkoutId",
  "deviceRecordedAt",
  "clientAppVersion",
]);

const protectedKeys = new Set([
  "xp",
  "totalXp",
  "totalXP",
  "weeklyXp",
  "weeklyXP",
  "monthlyXp",
  "monthlyXP",
  "streak",
  "streakCount",
  "level",
  "rank",
  "leaderboardScore",
  "scoreXp",
  "scoreXP",
  "subscriptionStatus",
  "subscriptionPrivilegeState",
  "userRole",
  "adminPrivilegeState",
  "expertPrivilegeState",
  "expertPlanPublicationState",
  "validationStatus",
  "validatedActivityContributionState",
  "countsTowardProgression",
]);

const isoDatePattern = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/;
const maxDurationSeconds = 86_400;
const maxDistanceMeters = 100_000;
const minPaceSecondsPerKm = 120;
const maxPaceSecondsPerKm = 3_600;

export function parseRunCompletionPayload(data: unknown): RawRunCompletionPayload {
  if (!isRecord(data)) {
    throw invalid("Payload must be an object.");
  }

  for (const key of Object.keys(data)) {
    if (protectedKeys.has(key)) {
      throw invalid(`Protected field is not accepted: ${key}.`);
    }
    if (!allowedKeys.has(key)) {
      throw invalid(`Unsupported field is not accepted: ${key}.`);
    }
  }

  const payload = {
    clientRunSessionId: readString(data, "clientRunSessionId"),
    startedAt: readIsoDateString(data, "startedAt"),
    completedAt: readIsoDateString(data, "completedAt"),
    durationSeconds: readBoundedPositiveNumber(data, "durationSeconds", maxDurationSeconds),
    distanceMeters: readBoundedPositiveNumber(data, "distanceMeters", maxDistanceMeters),
    avgPaceSecondsPerKm: readPaceSecondsPerKm(data),
    source: readMobileSource(data),
    routePrivacy: readRoutePrivacy(data),
    routeLabel: readOptionalString(data, "routeLabel"),
    avgHeartRate: readOptionalPositiveNumber(data, "avgHeartRate"),
    caloriesEstimate: readOptionalPositiveNumber(data, "caloriesEstimate"),
    planEnrollmentId: readOptionalString(data, "planEnrollmentId"),
    scheduledWorkoutId: readOptionalString(data, "scheduledWorkoutId"),
    deviceRecordedAt: readOptionalIsoDateString(data, "deviceRecordedAt"),
    clientAppVersion: readOptionalString(data, "clientAppVersion"),
  };

  if (Date.parse(payload.completedAt) <= Date.parse(payload.startedAt)) {
    throw invalid("completedAt must be after startedAt.");
  }

  const elapsedSeconds = (Date.parse(payload.completedAt) - Date.parse(payload.startedAt)) / 1000;
  if (Math.abs(elapsedSeconds - payload.durationSeconds) > 60) {
    throw invalid("durationSeconds must match startedAt/completedAt within tolerance.");
  }

  return withoutUndefined(payload);
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readString(data: Readonly<Record<string, unknown>>, key: string): string {
  const value = data[key];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw invalid(`${key} must be a non-empty string.`);
  }
  return value;
}

function readOptionalString(data: Readonly<Record<string, unknown>>, key: string): string | undefined {
  const value = data[key];
  if (value === undefined) {
    return undefined;
  }
  if (typeof value !== "string" || value.trim().length === 0) {
    throw invalid(`${key} must be a non-empty string when provided.`);
  }
  return value;
}

function readPositiveNumber(data: Readonly<Record<string, unknown>>, key: string): number {
  const value = data[key];
  if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
    throw invalid(`${key} must be a positive number.`);
  }
  return value;
}

function readBoundedPositiveNumber(
  data: Readonly<Record<string, unknown>>,
  key: string,
  maxValue: number,
): number {
  const value = readPositiveNumber(data, key);
  if (value > maxValue) {
    throw invalid(`${key} exceeds the emulator skeleton safety limit.`);
  }
  return value;
}

function readPaceSecondsPerKm(data: Readonly<Record<string, unknown>>): number {
  const value = readPositiveNumber(data, "avgPaceSecondsPerKm");
  if (value < minPaceSecondsPerKm || value > maxPaceSecondsPerKm) {
    throw invalid("avgPaceSecondsPerKm is outside the emulator skeleton safety limits.");
  }
  return value;
}

function readOptionalPositiveNumber(data: Readonly<Record<string, unknown>>, key: string): number | undefined {
  const value = data[key];
  if (value === undefined) {
    return undefined;
  }
  if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
    throw invalid(`${key} must be a positive number when provided.`);
  }
  return value;
}

function readIsoDateString(data: Readonly<Record<string, unknown>>, key: string): string {
  const value = readString(data, key);
  if (!isoDatePattern.test(value) || Number.isNaN(Date.parse(value))) {
    throw invalid(`${key} must be a UTC ISO date string with milliseconds.`);
  }
  return value;
}

function readOptionalIsoDateString(data: Readonly<Record<string, unknown>>, key: string): string | undefined {
  const value = readOptionalString(data, key);
  if (value === undefined) {
    return undefined;
  }
  if (!isoDatePattern.test(value) || Number.isNaN(Date.parse(value))) {
    throw invalid(`${key} must be a UTC ISO date string with milliseconds.`);
  }
  return value;
}

function readMobileSource(data: Readonly<Record<string, unknown>>): "mobile" {
  const source = readString(data, "source");
  if (source !== "mobile") {
    throw invalid("source must be mobile.");
  }
  return source;
}

function readRoutePrivacy(data: Readonly<Record<string, unknown>>): "private" | "public" {
  const routePrivacy = readString(data, "routePrivacy");
  if (routePrivacy !== "private" && routePrivacy !== "public") {
    throw invalid("routePrivacy must be private or public.");
  }
  return routePrivacy;
}

function withoutUndefined(payload: {
  readonly clientRunSessionId: string;
  readonly startedAt: string;
  readonly completedAt: string;
  readonly durationSeconds: number;
  readonly distanceMeters: number;
  readonly avgPaceSecondsPerKm: number;
  readonly source: "mobile";
  readonly routePrivacy: "private" | "public";
  readonly routeLabel: string | undefined;
  readonly avgHeartRate: number | undefined;
  readonly caloriesEstimate: number | undefined;
  readonly planEnrollmentId: string | undefined;
  readonly scheduledWorkoutId: string | undefined;
  readonly deviceRecordedAt: string | undefined;
  readonly clientAppVersion: string | undefined;
}): RawRunCompletionPayload {
  return {
    clientRunSessionId: payload.clientRunSessionId,
    startedAt: payload.startedAt,
    completedAt: payload.completedAt,
    durationSeconds: payload.durationSeconds,
    distanceMeters: payload.distanceMeters,
    avgPaceSecondsPerKm: payload.avgPaceSecondsPerKm,
    source: payload.source,
    routePrivacy: payload.routePrivacy,
    ...(payload.routeLabel === undefined ? {} : { routeLabel: payload.routeLabel }),
    ...(payload.avgHeartRate === undefined ? {} : { avgHeartRate: payload.avgHeartRate }),
    ...(payload.caloriesEstimate === undefined ? {} : { caloriesEstimate: payload.caloriesEstimate }),
    ...(payload.planEnrollmentId === undefined ? {} : { planEnrollmentId: payload.planEnrollmentId }),
    ...(payload.scheduledWorkoutId === undefined ? {} : { scheduledWorkoutId: payload.scheduledWorkoutId }),
    ...(payload.deviceRecordedAt === undefined ? {} : { deviceRecordedAt: payload.deviceRecordedAt }),
    ...(payload.clientAppVersion === undefined ? {} : { clientAppVersion: payload.clientAppVersion }),
  };
}

function invalid(message: string): HttpsError {
  return new HttpsError("invalid-argument", message);
}
