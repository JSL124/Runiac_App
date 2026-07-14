import { leaderboardLeagueForLevel } from "./leaderboardLeagues.js";

const baseCompletionXp = 20;
const xpPerKilometer = 10;
const xpPerTenActiveMinutes = 5;
const planCompletionBonusXp = 20;
const activityXpCap = 100;
const dailyXpCap = 200;
const singaporeUtcOffsetHours = 8;
const maxLevel = 100;

export type ActivityXpInput = {
  readonly distanceMeters: number;
  readonly activeDurationSeconds: number;
  readonly lowDataConfirmed: boolean;
  readonly planCompletionBonusEligible: boolean;
};

export type ActivityXpResult = {
  readonly baseCompletionXp: number;
  readonly distanceXp: number;
  readonly durationXp: number;
  readonly planCompletionBonusXp: number;
  readonly rawXpBeforeActivityCap: number;
  readonly xpDeltaBeforeDailyCap: number;
  readonly activityCapApplied: boolean;
  readonly reason: "run_completion_xp_awarded" | "low_data_no_xp";
};

export type DailyXpCapInput = {
  readonly xpDeltaBeforeDailyCap: number;
  readonly dailyXpBefore: number;
};

export type DailyXpCapResult = {
  readonly xpDelta: number;
  readonly dailyXpAfter: number;
  readonly dailyCapApplied: boolean;
};

export type LevelProgression = {
  readonly totalXp: number;
  readonly level: number;
  readonly divisionTier: number;
  readonly divisionKey: string;
  readonly divisionLabel: string;
  readonly levelLabel: string;
  readonly totalXpLabel: string;
  readonly nextLevelXp: number | null;
  readonly xpToNextLevel: number | null;
  readonly levelProgressPercent: number;
};

export function calculateActivityXp(input: ActivityXpInput): ActivityXpResult {
  if (input.lowDataConfirmed) {
    return {
      baseCompletionXp: 0,
      distanceXp: 0,
      durationXp: 0,
      planCompletionBonusXp: 0,
      rawXpBeforeActivityCap: 0,
      xpDeltaBeforeDailyCap: 0,
      activityCapApplied: false,
      reason: "low_data_no_xp",
    };
  }

  const distanceXp = Math.floor(input.distanceMeters / 1000) * xpPerKilometer;
  const durationXp = Math.floor(input.activeDurationSeconds / 600) * xpPerTenActiveMinutes;
  const bonusXp = input.planCompletionBonusEligible ? planCompletionBonusXp : 0;
  const rawXpBeforeActivityCap = baseCompletionXp + distanceXp + durationXp + bonusXp;
  const xpDeltaBeforeDailyCap = Math.min(rawXpBeforeActivityCap, activityXpCap);

  return {
    baseCompletionXp,
    distanceXp,
    durationXp,
    planCompletionBonusXp: bonusXp,
    rawXpBeforeActivityCap,
    xpDeltaBeforeDailyCap,
    activityCapApplied: xpDeltaBeforeDailyCap < rawXpBeforeActivityCap,
    reason: "run_completion_xp_awarded",
  };
}

export const coolDownBonusPercent = 0.2;
export const coolDownBonusMin = 5;
export const coolDownBonusMax = 20;

export function calculateCoolDownBonus(baseEarnedXp: number): number {
  if (!Number.isFinite(baseEarnedXp) || baseEarnedXp <= 0) {
    return 0; // zero-XP bases (low-data, premium, fully daily-capped runs) earn no bonus
  }
  const raw = Math.round((baseEarnedXp * coolDownBonusPercent) / 5) * 5;
  const clamped = Math.min(coolDownBonusMax, Math.max(coolDownBonusMin, raw));
  return Math.max(0, Math.min(clamped, activityXpCap - baseEarnedXp));
}

export function applyDailyXpCap(input: DailyXpCapInput): DailyXpCapResult {
  const remainingDailyXp = Math.max(0, dailyXpCap - input.dailyXpBefore);
  const xpDelta = Math.min(input.xpDeltaBeforeDailyCap, remainingDailyXp);

  return {
    xpDelta,
    dailyXpAfter: input.dailyXpBefore + xpDelta,
    dailyCapApplied: xpDelta < input.xpDeltaBeforeDailyCap,
  };
}

export function dailyCapDateForCompletedAt(completedAt: string): string {
  return singaporeDateForCompletedAt(completedAt).slice(0, 10);
}

export function monthlyPeriodForCompletedAt(completedAt: string): string {
  return singaporeDateForCompletedAt(completedAt).slice(0, 7);
}

function singaporeDateForCompletedAt(completedAt: string): string {
  const completedAtDate = new Date(completedAt);
  const singaporeTime = new Date(
    completedAtDate.getTime() + singaporeUtcOffsetHours * 60 * 60 * 1000,
  );
  return singaporeTime.toISOString();
}

export function resolveLevelProgression(totalXp: number): LevelProgression {
  const boundedTotalXp = Math.max(0, Math.floor(totalXp));
  const thresholds = levelThresholds();
  let level = 1;
  for (let index = 0; index < thresholds.length; index += 1) {
    const threshold = thresholds[index];
    if (threshold !== undefined && boundedTotalXp >= threshold) {
      level = index + 1;
    }
  }

  const division = leaderboardLeagueForLevel(level);
  const currentLevelXp = thresholds[level - 1] ?? 0;
  const nextLevelXp = level >= maxLevel ? null : thresholds[level] ?? null;
  const xpToNextLevel = nextLevelXp === null ? null : nextLevelXp - boundedTotalXp;
  const levelProgressPercent =
    nextLevelXp === null
      ? 100
      : Math.max(
          0,
          Math.min(
            100,
            Math.floor(((boundedTotalXp - currentLevelXp) / (nextLevelXp - currentLevelXp)) * 100),
          ),
        );

  return {
    totalXp: boundedTotalXp,
    level,
    divisionTier: division.tier,
    divisionKey: division.key,
    divisionLabel: division.label,
    levelLabel: `Level ${level}`,
    totalXpLabel: `${boundedTotalXp} XP`,
    nextLevelXp,
    xpToNextLevel,
    levelProgressPercent,
  };
}

function levelThresholds(): readonly number[] {
  const thresholds: number[] = [0];
  for (let nextLevel = 2; nextLevel <= maxLevel; nextLevel += 1) {
    const previousThreshold = thresholds[nextLevel - 2] ?? 0;
    thresholds.push(previousThreshold + incrementForLevel(nextLevel));
  }
  return thresholds;
}

function incrementForLevel(level: number): number {
  if (level <= 10) {
    return 100;
  }
  if (level <= 20) {
    return 150;
  }
  if (level <= 30) {
    return 220;
  }
  if (level <= 40) {
    return 300;
  }
  if (level <= 50) {
    return 400;
  }
  if (level <= 60) {
    return 520;
  }
  if (level <= 70) {
    return 660;
  }
  if (level <= 80) {
    return 820;
  }
  if (level <= 90) {
    return 1000;
  }
  return 1200;
}
