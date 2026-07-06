import { calculateStreakStateFromRuns, type StreakRun, type StreakState } from "./streakCalculator.js";

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

  return calculateStreakStateFromRuns(readPlanBoundedValidatedRuns(input.activityDocuments, generatedPlanStartedAt));
}

function readPlanBoundedValidatedRuns(
  activityDocuments: readonly FirebaseFirestore.DocumentData[],
  generatedPlanStartedAt: string,
): readonly StreakRun[] {
  return activityDocuments.flatMap((activityData) => {
    if (activityData["activityType"] !== "run" || activityData["validationStatus"] !== "validated") {
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
