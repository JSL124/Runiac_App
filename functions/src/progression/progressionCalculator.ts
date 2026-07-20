import type { ProgressionConfig } from "../config/configLoader.js";
import { leaderboardLeagueForLevel } from "./leaderboardLeagues.js";

export type StreakBonusResult = {
  readonly bonusXp: number;
  readonly milestoneDays: number | null;
};

const singaporeUtcOffsetHours = 8;

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

export function calculateActivityXp(
  input: ActivityXpInput,
  config: ProgressionConfig,
): ActivityXpResult {
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

  const distanceXp = Math.floor(input.distanceMeters / 1000) * config.xpPerKilometer;
  const durationXp = Math.floor(input.activeDurationSeconds / 600) * config.xpPerTenActiveMinutes;
  const bonusXp = input.planCompletionBonusEligible ? config.planCompletionBonusXp : 0;
  const rawXpBeforeActivityCap = config.baseCompletionXp + distanceXp + durationXp + bonusXp;
  const xpDeltaBeforeDailyCap = Math.min(rawXpBeforeActivityCap, config.activityXpCap);

  return {
    baseCompletionXp: config.baseCompletionXp,
    distanceXp,
    durationXp,
    planCompletionBonusXp: bonusXp,
    rawXpBeforeActivityCap,
    xpDeltaBeforeDailyCap,
    activityCapApplied: xpDeltaBeforeDailyCap < rawXpBeforeActivityCap,
    reason: "run_completion_xp_awarded",
  };
}

export function calculateCoolDownBonus(baseEarnedXp: number, config: ProgressionConfig): number {
  if (!Number.isFinite(baseEarnedXp) || baseEarnedXp <= 0) {
    return 0; // zero-XP bases (low-data, premium, fully daily-capped runs) earn no bonus
  }
  const raw = Math.round((baseEarnedXp * config.coolDown.percent) / 5) * 5;
  const clamped = Math.min(config.coolDown.max, Math.max(config.coolDown.min, raw));
  return Math.max(0, Math.min(clamped, config.activityXpCap - baseEarnedXp));
}

export function applyDailyXpCap(input: DailyXpCapInput, config: ProgressionConfig): DailyXpCapResult {
  const remainingDailyXp = Math.max(0, config.dailyXpCap - input.dailyXpBefore);
  const xpDelta = Math.min(input.xpDeltaBeforeDailyCap, remainingDailyXp);

  return {
    xpDelta,
    dailyXpAfter: input.dailyXpBefore + xpDelta,
    dailyCapApplied: xpDelta < input.xpDeltaBeforeDailyCap,
  };
}

// Bonus XP for crossing a streak milestone on this run. Deliberately EXEMPT
// from `activityXpCap` (callers apply that cap to the base activity XP only,
// before this bonus is added) but still bounded by whatever daily XP room
// remains — callers are responsible for clamping the returned `bonusXp`
// against `config.dailyXpCap`, this function only decides WHICH milestone
// (if any) was crossed and its raw, uncapped reward.
//
// If several milestones are crossed in one jump (a backfill or data repair
// can move `nextStreak` by many days at once), only the HIGHEST is paid —
// never the sum, or a single repaired streak could explode the XP economy.
// `config.streakRewards` is not assumed to be sorted even though validation
// enforces ascending `milestoneDays`; the max crossed milestone is selected
// explicitly by comparing every entry.
export function calculateStreakMilestoneBonus(
  input: { readonly previousStreak: number; readonly nextStreak: number },
  config: ProgressionConfig,
): StreakBonusResult {
  const none: StreakBonusResult = { bonusXp: 0, milestoneDays: null };

  if (
    !Number.isFinite(input.previousStreak) ||
    !Number.isFinite(input.nextStreak) ||
    input.previousStreak < 0 ||
    input.nextStreak < 0 ||
    input.nextStreak <= input.previousStreak ||
    config.streakRewards.length === 0
  ) {
    return none;
  }

  let best: { readonly milestoneDays: number; readonly bonusXp: number } | null = null;
  for (const reward of config.streakRewards) {
    if (!Number.isFinite(reward.bonusXp) || reward.bonusXp < 0) {
      continue; // malformed reward entry: ignore it, do not let it block others
    }
    const crossed = input.previousStreak < reward.milestoneDays && reward.milestoneDays <= input.nextStreak;
    if (!crossed) {
      continue;
    }
    if (best === null || reward.milestoneDays > best.milestoneDays) {
      best = reward;
    }
  }

  return best === null ? none : { bonusXp: best.bonusXp, milestoneDays: best.milestoneDays };
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

export function resolveLevelProgression(totalXp: number, config: ProgressionConfig): LevelProgression {
  const boundedTotalXp = Math.max(0, Math.floor(totalXp));
  const thresholds = levelThresholds(config);
  let level = 1;
  for (let index = 0; index < thresholds.length; index += 1) {
    const threshold = thresholds[index];
    if (threshold !== undefined && boundedTotalXp >= threshold) {
      level = index + 1;
    }
  }

  const division = leaderboardLeagueForLevel(level);
  const currentLevelXp = thresholds[level - 1] ?? 0;
  const nextLevelXp = level >= config.maxLevel ? null : thresholds[level] ?? null;
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

function levelThresholds(config: ProgressionConfig): readonly number[] {
  const thresholds: number[] = [0];
  for (let nextLevel = 2; nextLevel <= config.maxLevel; nextLevel += 1) {
    const previousThreshold = thresholds[nextLevel - 2] ?? 0;
    thresholds.push(previousThreshold + incrementForLevel(nextLevel, config));
  }
  return thresholds;
}

function incrementForLevel(level: number, config: ProgressionConfig): number {
  const increments = config.levelIncrements;
  const bandIndex = Math.min(Math.floor((level - 1) / 10), increments.length - 1);
  return increments[bandIndex] ?? increments[increments.length - 1] ?? 0;
}
