import type { PersistPlanProgressResult } from "../plan/planProgress.js";
import type { StreakTransition } from "./streakCalculator.js";
import type { CompleteRunIds, ProgressionDisplay, RawRunCompletionPayload } from "../run/runCompletionTypes.js";
import {
  applyDailyXpCap,
  calculateActivityXp,
  resolveLevelProgression,
  type LevelProgression,
} from "./progressionCalculator.js";
import {
  formatXpLabel,
  isPremiumSubscription,
  progressionReason,
  readTotalXp,
  sumDailyXp,
  sumMonthlyXp,
} from "./progressionAuditHelpers.js";

export { progressionDisplayFromEvent } from "./progressionDisplayReader.js";

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
  readonly monthlyPeriod: string;
  readonly dailyXpBefore: number;
  readonly dailyXpAfter: number;
  readonly monthlyXpBefore: number;
  readonly monthlyXpAfter: number;
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
  readonly monthlyPeriod: string;
  readonly sameDayProgressionEventDocuments: readonly FirebaseFirestore.DocumentData[];
  readonly sameMonthProgressionEventDocuments: readonly FirebaseFirestore.DocumentData[];
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
  const monthlyXpBefore = sumMonthlyXp(
    input.sameMonthProgressionEventDocuments,
    input.monthlyPeriod,
  );
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
  const monthlyXpAfter = monthlyXpBefore + capped.xpDelta;
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
      previousTotalXp,
      previousLevel: previousProgression.level,
      previousLevelProgressPercent: previousProgression.levelProgressPercent,
      levelProgressPercent: nextProgression.levelProgressPercent,
      nextLevelXp: nextProgression.nextLevelXp,
      xpToNextLevel: nextProgression.xpToNextLevel,
    },
    baseCompletionXp: activityXp.baseCompletionXp,
    distanceXp: activityXp.distanceXp,
    durationXp: activityXp.durationXp,
    planCompletionBonusXp: activityXp.planCompletionBonusXp,
    rawXpBeforeActivityCap: activityXp.rawXpBeforeActivityCap,
    rawXpBeforeDailyCap: activityXp.xpDeltaBeforeDailyCap,
    activityCapApplied: activityXp.activityCapApplied,
    dailyCapDate: input.dailyCapDate,
    monthlyPeriod: input.monthlyPeriod,
    dailyXpBefore,
    dailyXpAfter: capped.dailyXpAfter,
    monthlyXpBefore,
    monthlyXpAfter,
    dailyCapApplied: capped.dailyCapApplied,
    xpDelta: capped.xpDelta,
    previousTotalXp,
    nextTotalXp,
    previousProgression,
    nextProgression,
    reason,
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
    monthlyPeriod: input.audit.monthlyPeriod,
    dailyXpBefore: input.audit.dailyXpBefore,
    dailyXpAfter: input.audit.dailyXpAfter,
    monthlyXpBefore: input.audit.monthlyXpBefore,
    monthlyXpAfter: input.audit.monthlyXpAfter,
    dailyCapApplied: input.audit.dailyCapApplied,
    previousTotalXp: input.audit.previousTotalXp,
    nextTotalXp: input.audit.nextTotalXp,
    previousLevel: input.audit.previousProgression.level,
    nextLevel: input.audit.nextProgression.level,
    previousDivisionKey: input.audit.previousProgression.divisionKey,
    nextDivisionKey: input.audit.nextProgression.divisionKey,
    previousLevelProgressPercent: input.audit.previousProgression.levelProgressPercent,
    nextLevelProgressPercent: input.audit.nextProgression.levelProgressPercent,
    nextLevelXpTarget: input.audit.nextProgression.nextLevelXp,
    nextXpToNextLevel: input.audit.nextProgression.xpToNextLevel,
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
    monthlyXp: audit.monthlyXpAfter,
    monthlyXpLabel: formatXpLabel(audit.monthlyXpAfter),
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
