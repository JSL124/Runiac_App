import { HttpsError } from "firebase-functions/v2/https";
import type { PersistPlanProgressResult } from "../plan/planProgress.js";
import type { StreakTransition } from "./streakCalculator.js";
import type { CompleteRunIds, ProgressionDisplay, RawRunCompletionPayload } from "../run/runCompletionTypes.js";
import {
  applyDailyXpCap,
  calculateActivityXp,
  resolveLevelProgression,
  type LevelProgression,
} from "./progressionCalculator.js";

export type ProgressionAudit = {
  readonly progressionDisplay: ProgressionDisplay;
  readonly baseCompletionXp: number;
  readonly distanceXp: number;
  readonly durationXp: number;
  readonly planCompletionBonusXp: number;
  readonly rawXpBeforeActivityCap: number;
  readonly rawXpBeforeDailyCap: number;
  readonly activityCapApplied: boolean;
  readonly dailyCapDate: string;
  readonly dailyXpBefore: number;
  readonly dailyXpAfter: number;
  readonly dailyCapApplied: boolean;
  readonly xpDelta: number;
  readonly previousTotalXp: number;
  readonly nextTotalXp: number;
  readonly previousProgression: LevelProgression;
  readonly nextProgression: LevelProgression;
  readonly reason: ProgressionDisplay["reason"];
};

export function calculateProgressionAudit(input: {
  readonly payload: RawRunCompletionPayload;
  readonly profileData: FirebaseFirestore.DocumentData | undefined;
  readonly subscriptionData: FirebaseFirestore.DocumentData | undefined;
  readonly dailyCapDate: string;
  readonly sameDayProgressionEventDocuments: readonly FirebaseFirestore.DocumentData[];
  readonly planProgressResult: PersistPlanProgressResult;
}): ProgressionAudit {
  const previousTotalXp = readTotalXp(input.profileData);
  const previousProgression = resolveLevelProgression(previousTotalXp);
  const isPremium = isPremiumSubscription(input.subscriptionData) || isPremiumSubscription(input.profileData);
  const activityXp = calculateActivityXp({
    distanceMeters: input.payload.distanceMeters,
    activeDurationSeconds: input.payload.activeDurationSeconds,
    lowDataConfirmed: input.payload.userConfirmedLowDataSave === true,
    planCompletionBonusEligible: input.planProgressResult.completedWorkoutRecorded,
  });
  const dailyXpBefore = sumDailyXp(input.sameDayProgressionEventDocuments, input.dailyCapDate);
  const capped = isPremium
    ? { xpDelta: 0, dailyXpAfter: dailyXpBefore, dailyCapApplied: false }
    : applyDailyXpCap({
        xpDeltaBeforeDailyCap: activityXp.xpDeltaBeforeDailyCap,
        dailyXpBefore,
      });
  const reason = progressionReason({
    isPremium,
    activityReason: activityXp.reason,
    xpDeltaBeforeDailyCap: activityXp.xpDeltaBeforeDailyCap,
    xpDelta: capped.xpDelta,
  });
  const nextTotalXp = previousTotalXp + capped.xpDelta;
  const nextProgression = resolveLevelProgression(nextTotalXp);

  return {
    progressionDisplay: {
      xpDelta: capped.xpDelta,
      countsTowardLeaderboard: false,
      status: capped.xpDelta > 0 ? "awarded" : "not_awarded",
      reason,
      totalXp: nextTotalXp,
      level: nextProgression.level,
      divisionKey: nextProgression.divisionKey,
    },
    baseCompletionXp: activityXp.baseCompletionXp,
    distanceXp: activityXp.distanceXp,
    durationXp: activityXp.durationXp,
    planCompletionBonusXp: activityXp.planCompletionBonusXp,
    rawXpBeforeActivityCap: activityXp.rawXpBeforeActivityCap,
    rawXpBeforeDailyCap: activityXp.xpDeltaBeforeDailyCap,
    activityCapApplied: activityXp.activityCapApplied,
    dailyCapDate: input.dailyCapDate,
    dailyXpBefore,
    dailyXpAfter: capped.dailyXpAfter,
    dailyCapApplied: capped.dailyCapApplied,
    xpDelta: capped.xpDelta,
    previousTotalXp,
    nextTotalXp,
    previousProgression,
    nextProgression,
    reason,
  };
}

export function progressionDisplayFromEvent(
  eventData: FirebaseFirestore.DocumentData | undefined,
): ProgressionDisplay {
  if (eventData === undefined) {
    throw new HttpsError("already-exists", "Existing run completion progression event is unreadable.");
  }
  const xpDelta = eventData["xpDelta"];
  const status = eventData["status"];
  const reason = eventData["reason"];
  const totalXp = eventData["nextTotalXp"];
  const level = eventData["nextLevel"];
  const divisionKey = eventData["nextDivisionKey"];
  if (typeof xpDelta !== "number" || !isProgressionStatus(status) || !isProgressionReason(reason)) {
    throw new HttpsError("already-exists", "Existing run completion progression display is unreadable.");
  }

  return {
    xpDelta,
    countsTowardLeaderboard: false,
    status,
    reason,
    ...(typeof totalXp === "number" ? { totalXp } : {}),
    ...(typeof level === "number" ? { level } : {}),
    ...(typeof divisionKey === "string" ? { divisionKey } : {}),
  };
}

export function progressionEventData(input: {
  readonly uid: string;
  readonly ids: CompleteRunIds;
  readonly payload: RawRunCompletionPayload;
  readonly audit: ProgressionAudit;
  readonly streakTransition: StreakTransition;
  readonly planProgressResult: PersistPlanProgressResult;
}): FirebaseFirestore.DocumentData {
  const display = input.audit.progressionDisplay;
  return {
    ownerUid: input.uid,
    activityId: input.ids.activityId,
    eventType: "run_completion_xp",
    status: display.status,
    createdAt: input.payload.completedAt,
    xpDelta: input.audit.xpDelta,
    rawXpBeforeDailyCap: input.audit.rawXpBeforeDailyCap,
    rawXpBeforeActivityCap: input.audit.rawXpBeforeActivityCap,
    baseCompletionXp: input.audit.baseCompletionXp,
    distanceXp: input.audit.distanceXp,
    durationXp: input.audit.durationXp,
    planCompletionBonusXp: input.audit.planCompletionBonusXp,
    activityCapApplied: input.audit.activityCapApplied,
    dailyCapDate: input.audit.dailyCapDate,
    dailyXpBefore: input.audit.dailyXpBefore,
    dailyXpAfter: input.audit.dailyXpAfter,
    dailyCapApplied: input.audit.dailyCapApplied,
    previousTotalXp: input.audit.previousTotalXp,
    nextTotalXp: input.audit.nextTotalXp,
    previousLevel: input.audit.previousProgression.level,
    nextLevel: input.audit.nextProgression.level,
    previousDivisionKey: input.audit.previousProgression.divisionKey,
    nextDivisionKey: input.audit.nextProgression.divisionKey,
    previousStreak: input.streakTransition.previousStreak,
    nextStreak: input.streakTransition.nextStreak,
    previousStreakRunDate: input.streakTransition.previousStreakRunDate,
    nextStreakRunDate: input.streakTransition.nextStreakRunDate,
    countsTowardLeaderboard: display.countsTowardLeaderboard,
    reason: display.reason,
    plannedWorkoutBonusApplied: input.audit.planCompletionBonusXp > 0,
    plannedWorkoutRecorded: input.planProgressResult.completedWorkoutRecorded,
    plannedWorkoutId: input.planProgressResult.scheduledWorkoutId,
    plannedWorkoutMatchedBy: input.planProgressResult.matchedBy,
  };
}

export function profileProgressionData(audit: ProgressionAudit, updatedAt: string): FirebaseFirestore.DocumentData {
  return {
    totalXp: audit.nextTotalXp,
    level: audit.nextProgression.level,
    divisionTier: audit.nextProgression.divisionTier,
    divisionKey: audit.nextProgression.divisionKey,
    divisionLabel: audit.nextProgression.divisionLabel,
    levelLabel: audit.nextProgression.levelLabel,
    totalXpLabel: audit.nextProgression.totalXpLabel,
    nextLevelXp: audit.nextProgression.nextLevelXp,
    xpToNextLevel: audit.nextProgression.xpToNextLevel,
    levelProgressPercent: audit.nextProgression.levelProgressPercent,
    progressionUpdatedAt: updatedAt,
  };
}

export function noCompletedWorkoutRecorded(): PersistPlanProgressResult {
  return {
    completedWorkoutRecorded: false,
    scheduledWorkoutId: null,
    matchedBy: null,
  };
}

function progressionReason(input: {
  readonly isPremium: boolean;
  readonly activityReason: "run_completion_xp_awarded" | "low_data_no_xp";
  readonly xpDeltaBeforeDailyCap: number;
  readonly xpDelta: number;
}): ProgressionDisplay["reason"] {
  if (input.isPremium) {
    return "premium_no_progression";
  }
  if (input.activityReason === "low_data_no_xp") {
    return "low_data_no_xp";
  }
  if (input.xpDeltaBeforeDailyCap > 0 && input.xpDelta === 0) {
    return "daily_cap_reached";
  }
  return "run_completion_xp_awarded";
}

function readTotalXp(profileData: FirebaseFirestore.DocumentData | undefined): number {
  const totalXp = profileData?.["totalXp"];
  return typeof totalXp === "number" && Number.isInteger(totalXp) && totalXp > 0 ? totalXp : 0;
}

function sumDailyXp(
  progressionEventDocuments: readonly FirebaseFirestore.DocumentData[],
  dailyCapDate: string,
): number {
  return progressionEventDocuments.reduce((total, eventData) => {
    const eventDailyCapDate = eventData["dailyCapDate"];
    const xpDelta = eventData["xpDelta"];
    if (eventDailyCapDate === dailyCapDate && typeof xpDelta === "number" && xpDelta > 0) {
      return total + xpDelta;
    }
    return total;
  }, 0);
}

function isPremiumSubscription(data: FirebaseFirestore.DocumentData | undefined): boolean {
  const subscriptionStatus = data?.["subscriptionStatus"];
  return subscriptionStatus === "premium" || subscriptionStatus === "Premium";
}

function isProgressionStatus(value: unknown): value is ProgressionDisplay["status"] {
  return value === "awarded" || value === "not_awarded" || value === "deferred";
}

function isProgressionReason(value: unknown): value is ProgressionDisplay["reason"] {
  return (
    value === "run_completion_xp_awarded" ||
    value === "low_data_no_xp" ||
    value === "daily_cap_reached" ||
    value === "premium_no_progression" ||
    value === "progression_formula_deferred"
  );
}
