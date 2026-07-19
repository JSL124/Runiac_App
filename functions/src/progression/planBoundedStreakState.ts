import { calculateStreakStateFromRuns, type StreakRun, type StreakState } from "./streakCalculator.js";
import {
  isRecord,
  isRestWorkout,
  readOptionalInteger,
  readOptionalString,
  scheduledDateFor,
} from "../plan/planProgressParsing.js";

export type TrustedStreakStateInput = {
  readonly profileState: StreakState;
  readonly generatedPlanData: FirebaseFirestore.DocumentData | undefined;
  readonly activityDocuments: readonly FirebaseFirestore.DocumentData[];
};

export function readTrustedStreakState(input: TrustedStreakStateInput): StreakState {
  const generatedPlanStartedAt = readGeneratedPlanStartedAt(input.generatedPlanData);
  if (generatedPlanStartedAt === null) {
    return input.profileState;
  }

  return calculateStreakStateFromRuns(
    readPlanBoundedValidatedRuns(input.activityDocuments, generatedPlanStartedAt),
    readPlanBoundedRestDates(input.generatedPlanData, generatedPlanStartedAt),
  );
}

export function readTrustedProtectedRestDates(
  generatedPlanData: FirebaseFirestore.DocumentData | undefined,
): readonly string[] {
  const generatedPlanStartedAt = readGeneratedPlanStartedAt(generatedPlanData);
  if (generatedPlanStartedAt === null) {
    return [];
  }

  return readPlanBoundedRestDates(generatedPlanData, generatedPlanStartedAt);
}

function readPlanBoundedValidatedRuns(
  activityDocuments: readonly FirebaseFirestore.DocumentData[],
  generatedPlanStartedAt: string,
): readonly StreakRun[] {
  return activityDocuments.flatMap((activityData) => {
    if (
      activityData["activityType"] !== "run" ||
      activityData["validationStatus"] !== "validated" ||
      activityData["countsTowardStreak"] === false
    ) {
      return [];
    }

    const completedAt = readActivityCompletedAt(activityData);
    if (completedAt === null || Date.parse(completedAt) < Date.parse(generatedPlanStartedAt)) {
      return [];
    }

    return [{ completedAt }];
  });
}

function readActivityCompletedAt(activityData: FirebaseFirestore.DocumentData): string | null {
  const endedAt = activityData["endedAt"];
  if (typeof endedAt === "string") {
    return endedAt;
  }

  const completedAt = activityData["completedAt"];
  return typeof completedAt === "string" ? completedAt : null;
}

function readPlanBoundedRestDates(
  generatedPlanData: FirebaseFirestore.DocumentData | undefined,
  generatedPlanStartedAt: string,
): readonly string[] {
  if (generatedPlanData === undefined) {
    return [];
  }

  const startsOnDate = readOptionalString(generatedPlanData["startsOnDate"]);
  const weeks = generatedPlanData["weeks"];
  if (startsOnDate === undefined || !Array.isArray(weeks)) {
    return [];
  }

  return weeks.flatMap((week) => {
    if (!isRecord(week)) {
      return [];
    }

    const weekNumber = readOptionalInteger(week["weekNumber"]);
    const workouts = week["workouts"];
    if (weekNumber === undefined || !Array.isArray(workouts)) {
      return [];
    }

    return workouts.flatMap((workout) => {
      if (!isRecord(workout) || !isRestWorkout(workout)) {
        return [];
      }

      const dayLabel = readOptionalString(workout["dayLabel"]);
      const scheduledDate = dayLabel === undefined
        ? null
        : scheduledDateFor(startsOnDate, weekNumber, dayLabel);
      if (
        scheduledDate === null ||
        Date.parse(`${scheduledDate}T00:00:00.000Z`) < Date.parse(generatedPlanStartedAt)
      ) {
        return [];
      }

      return [scheduledDate];
    });
  });
}

function readGeneratedPlanStartedAt(generatedPlanData: FirebaseFirestore.DocumentData | undefined): string | null {
  if (generatedPlanData === undefined) {
    return null;
  }

  return readTimestampLikeString(generatedPlanData["createdAt"]) ??
    readTimestampLikeString(generatedPlanData["updatedAt"]) ??
    readDateString(generatedPlanData["startsOnDate"]);
}

function readTimestampLikeString(value: unknown): string | null {
  if (typeof value === "string" && Number.isFinite(Date.parse(value))) {
    return value;
  }

  if (isFirestoreTimestamp(value)) {
    return value.toDate().toISOString();
  }

  return null;
}

function readDateString(value: unknown): string | null {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return null;
  }

  return `${value}T00:00:00.000Z`;
}

function isFirestoreTimestamp(value: unknown): value is { readonly toDate: () => Date } {
  return typeof value === "object" && value !== null && "toDate" in value && typeof value.toDate === "function";
}
