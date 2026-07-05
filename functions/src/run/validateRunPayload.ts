import { HttpsError } from "firebase-functions/v2/https";
import type { CadenceAnalysisSeriesPayload, RawRunCompletionPayload } from "./runCompletionTypes.js";
import { readOptionalCadenceAnalysisSeries } from "./validateCadenceAnalysisSeries.js";
import {
  readDistanceMeters,
  readDurationSeconds,
  readOptionalDurationSeconds,
  readOptionalPositiveNumber,
  readPaceSecondsPerKm,
} from "./validateRunScalarFields.js";

const allowedKeys = new Set([
  "clientRunSessionId",
  "startedAt",
  "completedAt",
  "durationSeconds",
  "activeDurationSeconds",
  "elapsedWallSeconds",
  "pausedDurationSeconds",
  "distanceMeters",
  "avgPaceSecondsPerKm",
  "source",
  "routePrivacy",
  "userConfirmedLowDataSave",
  "routeLabel",
  "avgHeartRate",
  "caloriesEstimate",
  "planEnrollmentId",
  "scheduledWorkoutId",
  "deviceRecordedAt",
  "clientAppVersion",
  "cadenceAnalysisSeries",
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

  const userConfirmedLowDataSave = readUserConfirmedLowDataSave(data);
  const durationSeconds = readDurationSeconds(data, userConfirmedLowDataSave);
  const activeDurationSeconds =
    readOptionalDurationSeconds(data, "activeDurationSeconds", userConfirmedLowDataSave) ?? durationSeconds;
  const distanceMeters = readDistanceMeters(data, userConfirmedLowDataSave);
  const startedAt = readIsoDateString(data, "startedAt");
  const completedAt = readIsoDateString(data, "completedAt");

  if (Date.parse(completedAt) <= Date.parse(startedAt)) {
    throw invalid("completedAt must be after startedAt.");
  }

  const computedElapsedWallSeconds = (Date.parse(completedAt) - Date.parse(startedAt)) / 1000;
  const elapsedWallSeconds =
    readOptionalDurationSeconds(data, "elapsedWallSeconds", userConfirmedLowDataSave) ??
    Math.round(computedElapsedWallSeconds);
  const pausedDurationSeconds =
    readOptionalDurationSeconds(data, "pausedDurationSeconds", true) ??
    Math.max(0, elapsedWallSeconds - activeDurationSeconds);

  if (durationSeconds !== activeDurationSeconds) {
    throw invalid("durationSeconds must match activeDurationSeconds.");
  }

  if (Math.abs(computedElapsedWallSeconds - elapsedWallSeconds) > 60) {
    throw invalid("elapsedWallSeconds must match startedAt/completedAt within tolerance.");
  }

  if (activeDurationSeconds - elapsedWallSeconds > 60) {
    throw invalid("activeDurationSeconds must not exceed elapsedWallSeconds within tolerance.");
  }

  if (Math.abs(elapsedWallSeconds - activeDurationSeconds - pausedDurationSeconds) > 60) {
    throw invalid("pausedDurationSeconds must match elapsedWallSeconds minus activeDurationSeconds within tolerance.");
  }

  const payload = {
    clientRunSessionId: readString(data, "clientRunSessionId"),
    startedAt,
    completedAt,
    durationSeconds,
    activeDurationSeconds,
    elapsedWallSeconds,
    pausedDurationSeconds,
    distanceMeters,
    avgPaceSecondsPerKm: readPaceSecondsPerKm(data, {
      userConfirmedLowDataSave,
      distanceMeters,
    }),
    source: readMobileSource(data),
    routePrivacy: readRoutePrivacy(data),
    userConfirmedLowDataSave,
    routeLabel: readOptionalString(data, "routeLabel"),
    avgHeartRate: readOptionalPositiveNumber(data, "avgHeartRate"),
    caloriesEstimate: readOptionalPositiveNumber(data, "caloriesEstimate"),
    planEnrollmentId: readOptionalString(data, "planEnrollmentId"),
    scheduledWorkoutId: readOptionalString(data, "scheduledWorkoutId"),
    deviceRecordedAt: readOptionalIsoDateString(data, "deviceRecordedAt"),
    clientAppVersion: readOptionalString(data, "clientAppVersion"),
    cadenceAnalysisSeries: readOptionalCadenceAnalysisSeries(data),
  };

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

function readUserConfirmedLowDataSave(data: Readonly<Record<string, unknown>>): boolean {
  const value = data["userConfirmedLowDataSave"];
  if (value === undefined) {
    return false;
  }
  if (typeof value !== "boolean") {
    throw invalid("userConfirmedLowDataSave must be true or false when provided.");
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
  readonly activeDurationSeconds: number;
  readonly elapsedWallSeconds: number;
  readonly pausedDurationSeconds: number;
  readonly distanceMeters: number;
  readonly avgPaceSecondsPerKm: number;
  readonly source: "mobile";
  readonly routePrivacy: "private" | "public";
  readonly userConfirmedLowDataSave: boolean;
  readonly routeLabel: string | undefined;
  readonly avgHeartRate: number | undefined;
  readonly caloriesEstimate: number | undefined;
  readonly planEnrollmentId: string | undefined;
  readonly scheduledWorkoutId: string | undefined;
  readonly deviceRecordedAt: string | undefined;
  readonly clientAppVersion: string | undefined;
  readonly cadenceAnalysisSeries: CadenceAnalysisSeriesPayload | undefined;
}): RawRunCompletionPayload {
  return {
    clientRunSessionId: payload.clientRunSessionId,
    startedAt: payload.startedAt,
    completedAt: payload.completedAt,
    durationSeconds: payload.durationSeconds,
    activeDurationSeconds: payload.activeDurationSeconds,
    elapsedWallSeconds: payload.elapsedWallSeconds,
    pausedDurationSeconds: payload.pausedDurationSeconds,
    distanceMeters: payload.distanceMeters,
    avgPaceSecondsPerKm: payload.avgPaceSecondsPerKm,
    source: payload.source,
    routePrivacy: payload.routePrivacy,
    ...(payload.userConfirmedLowDataSave ? { userConfirmedLowDataSave: true } : {}),
    ...(payload.routeLabel === undefined ? {} : { routeLabel: payload.routeLabel }),
    ...(payload.avgHeartRate === undefined ? {} : { avgHeartRate: payload.avgHeartRate }),
    ...(payload.caloriesEstimate === undefined ? {} : { caloriesEstimate: payload.caloriesEstimate }),
    ...(payload.planEnrollmentId === undefined ? {} : { planEnrollmentId: payload.planEnrollmentId }),
    ...(payload.scheduledWorkoutId === undefined ? {} : { scheduledWorkoutId: payload.scheduledWorkoutId }),
    ...(payload.deviceRecordedAt === undefined ? {} : { deviceRecordedAt: payload.deviceRecordedAt }),
    ...(payload.clientAppVersion === undefined ? {} : { clientAppVersion: payload.clientAppVersion }),
    ...(payload.cadenceAnalysisSeries === undefined
      ? {}
      : { cadenceAnalysisSeries: payload.cadenceAnalysisSeries }),
  };
}

function invalid(message: string): HttpsError {
  return new HttpsError("invalid-argument", message);
}
