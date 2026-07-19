import type { Firestore } from "firebase-admin/firestore";

export type ProgressionCoolDownConfig = {
  readonly percent: number;
  readonly min: number;
  readonly max: number;
};

export type StreakRewardConfig = {
  readonly milestoneDays: number;
  readonly bonusXp: number;
};

export type ProgressionConfig = {
  readonly baseCompletionXp: number;
  readonly xpPerKilometer: number;
  readonly xpPerTenActiveMinutes: number;
  readonly planCompletionBonusXp: number;
  readonly activityXpCap: number;
  readonly dailyXpCap: number;
  readonly premiumEarnsXp: boolean;
  readonly maxLevel: number;
  readonly coolDown: ProgressionCoolDownConfig;
  readonly levelIncrements: readonly number[];
  readonly streakRewards: readonly StreakRewardConfig[];
  readonly version: number;
};

export type LeaderboardConfig = {
  readonly minRunsToQualify: number;
  readonly excludePremium: boolean;
  readonly seasonLengthDays: number;
  readonly version: number;
};

export type FeatureAccessEntry = {
  readonly minimumTier: "basic" | "premium";
  readonly enabled: boolean;
};

export type FeatureAccessConfig = {
  readonly features: Readonly<Record<string, FeatureAccessEntry>>;
  readonly version: number;
};

export type ConfigValidationResult = {
  readonly valid: boolean;
  readonly errors: readonly string[];
};

export const DEFAULT_PROGRESSION_CONFIG: ProgressionConfig = {
  baseCompletionXp: 20,
  xpPerKilometer: 10,
  xpPerTenActiveMinutes: 5,
  planCompletionBonusXp: 20,
  activityXpCap: 100,
  dailyXpCap: 200,
  premiumEarnsXp: false,
  maxLevel: 100,
  coolDown: {
    percent: 0.2,
    min: 5,
    max: 20,
  },
  levelIncrements: [100, 150, 220, 300, 400, 520, 660, 820, 1000, 1200],
  streakRewards: [
    { milestoneDays: 3, bonusXp: 30 },
    { milestoneDays: 7, bonusXp: 90 },
    { milestoneDays: 14, bonusXp: 220 },
    { milestoneDays: 30, bonusXp: 600 },
  ],
  version: 1,
};

export const DEFAULT_LEADERBOARD_CONFIG: LeaderboardConfig = {
  minRunsToQualify: 1,
  excludePremium: true,
  seasonLengthDays: 30,
  version: 1,
};

export const DEFAULT_FEATURE_ACCESS_CONFIG: FeatureAccessConfig = {
  features: {
    advancedAnalysis: { minimumTier: "premium", enabled: true },
    goalPlan: { minimumTier: "premium", enabled: true },
    leaderboard: { minimumTier: "basic", enabled: true },
  },
  version: 1,
};

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Merges `partial` over `defaults`, field by field. Nested plain objects are
 * merged recursively so that omitted nested fields fall back to the default
 * value (e.g. a stored `{ coolDown: { percent: 0.3 } }` keeps the default
 * `coolDown.min`/`coolDown.max`). Arrays are replaced wholesale, never merged
 * element-by-element.
 */
export function deepMerge<T>(defaults: T, partial: unknown): T {
  if (!isPlainObject(partial) || !isPlainObject(defaults)) {
    return defaults;
  }

  const merged: Record<string, unknown> = { ...(defaults as Record<string, unknown>) };

  for (const key of Object.keys(partial)) {
    const partialValue = partial[key];
    const defaultValue = (defaults as Record<string, unknown>)[key];

    if (partialValue === undefined) {
      continue;
    }

    if (isPlainObject(defaultValue) && isPlainObject(partialValue)) {
      merged[key] = deepMerge(defaultValue, partialValue);
    } else {
      merged[key] = partialValue;
    }
  }

  return merged as T;
}

function isFiniteNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

export function validateProgressionConfig(config: ProgressionConfig): ConfigValidationResult {
  const errors: string[] = [];

  const nonNegativeFields: Array<[string, number]> = [
    ["baseCompletionXp", config.baseCompletionXp],
    ["xpPerKilometer", config.xpPerKilometer],
    ["xpPerTenActiveMinutes", config.xpPerTenActiveMinutes],
    ["planCompletionBonusXp", config.planCompletionBonusXp],
    ["activityXpCap", config.activityXpCap],
    ["dailyXpCap", config.dailyXpCap],
  ];

  for (const [name, value] of nonNegativeFields) {
    if (!isFiniteNumber(value) || value < 0) {
      errors.push(`${name} must be a non-negative finite number`);
    }
  }

  if (isFiniteNumber(config.dailyXpCap) && isFiniteNumber(config.activityXpCap) && config.dailyXpCap < config.activityXpCap) {
    errors.push("dailyXpCap must be greater than or equal to activityXpCap");
  }

  if (!isFiniteNumber(config.maxLevel) || config.maxLevel <= 0) {
    errors.push("maxLevel must be a positive finite number");
  }

  if (!isPlainObject(config.coolDown)) {
    errors.push("coolDown must be an object");
  } else {
    const { percent, min, max } = config.coolDown;

    if (!isFiniteNumber(percent) || percent < 0 || percent > 1) {
      errors.push("coolDown.percent must be between 0 and 1");
    }

    if (!isFiniteNumber(min) || !isFiniteNumber(max) || min > max) {
      errors.push("coolDown.min must be less than or equal to coolDown.max");
    }
  }

  if (!Array.isArray(config.levelIncrements) || config.levelIncrements.length === 0) {
    errors.push("levelIncrements must be a non-empty array");
  } else if (!config.levelIncrements.every((increment) => isFiniteNumber(increment) && increment > 0)) {
    errors.push("levelIncrements must contain only finite positive numbers");
  }

  if (!Array.isArray(config.streakRewards)) {
    errors.push("streakRewards must be an array");
  } else {
    let previousMilestoneDays: number | undefined;

    for (const [index, reward] of config.streakRewards.entries()) {
      if (!isPlainObject(reward)) {
        errors.push(`streakRewards[${index}] must be an object`);
        continue;
      }

      const milestoneDays = reward["milestoneDays"];
      const bonusXp = reward["bonusXp"];

      if (!isFiniteNumber(milestoneDays) || !Number.isInteger(milestoneDays) || milestoneDays < 1) {
        errors.push(`streakRewards[${index}].milestoneDays must be an integer greater than or equal to 1`);
      } else {
        if (previousMilestoneDays !== undefined && milestoneDays <= previousMilestoneDays) {
          errors.push(`streakRewards[${index}].milestoneDays must be greater than the previous milestoneDays`);
        }

        previousMilestoneDays = milestoneDays;
      }

      if (!isFiniteNumber(bonusXp) || bonusXp < 0) {
        errors.push(`streakRewards[${index}].bonusXp must be a non-negative finite number`);
      }
    }
  }

  return { valid: errors.length === 0, errors };
}

export function validateLeaderboardConfig(config: LeaderboardConfig): ConfigValidationResult {
  const errors: string[] = [];

  if (!isFiniteNumber(config.minRunsToQualify) || config.minRunsToQualify < 0) {
    errors.push("minRunsToQualify must be a non-negative finite number");
  }

  if (!isFiniteNumber(config.seasonLengthDays) || config.seasonLengthDays <= 0) {
    errors.push("seasonLengthDays must be a positive finite number");
  }

  return { valid: errors.length === 0, errors };
}

export function validateFeatureAccessConfig(config: FeatureAccessConfig): ConfigValidationResult {
  const errors: string[] = [];

  if (!isPlainObject(config.features)) {
    errors.push("features must be an object");
    return { valid: false, errors };
  }

  for (const [featureName, entry] of Object.entries(config.features)) {
    if (!isPlainObject(entry)) {
      errors.push(`features.${featureName} must be an object`);
      continue;
    }

    if (entry["minimumTier"] !== "basic" && entry["minimumTier"] !== "premium") {
      errors.push(`features.${featureName}.minimumTier must be "basic" or "premium"`);
    }

    if (typeof entry["enabled"] !== "boolean") {
      errors.push(`features.${featureName}.enabled must be a boolean`);
    }
  }

  return { valid: errors.length === 0, errors };
}

async function readConfigDoc(db: Firestore, docPath: string): Promise<unknown> {
  const snapshot = await db.doc(docPath).get();

  if (!snapshot.exists) {
    return undefined;
  }

  return snapshot.data();
}

export async function loadProgressionConfig(db: Firestore): Promise<ProgressionConfig> {
  try {
    const stored = await readConfigDoc(db, "config/progression");

    if (stored === undefined) {
      console.warn("configLoader: config/progression is missing; using DEFAULT_PROGRESSION_CONFIG");
      return DEFAULT_PROGRESSION_CONFIG;
    }

    const merged = deepMerge(DEFAULT_PROGRESSION_CONFIG, stored);
    const result = validateProgressionConfig(merged);

    if (!result.valid) {
      console.warn(
        `configLoader: config/progression failed validation (${result.errors.join(", ")}); using DEFAULT_PROGRESSION_CONFIG`,
      );
      return DEFAULT_PROGRESSION_CONFIG;
    }

    return merged;
  } catch (error) {
    console.warn("configLoader: failed to read config/progression; using DEFAULT_PROGRESSION_CONFIG", error);
    return DEFAULT_PROGRESSION_CONFIG;
  }
}

export async function loadLeaderboardConfig(db: Firestore): Promise<LeaderboardConfig> {
  try {
    const stored = await readConfigDoc(db, "config/leaderboard");

    if (stored === undefined) {
      console.warn("configLoader: config/leaderboard is missing; using DEFAULT_LEADERBOARD_CONFIG");
      return DEFAULT_LEADERBOARD_CONFIG;
    }

    const merged = deepMerge(DEFAULT_LEADERBOARD_CONFIG, stored);
    const result = validateLeaderboardConfig(merged);

    if (!result.valid) {
      console.warn(
        `configLoader: config/leaderboard failed validation (${result.errors.join(", ")}); using DEFAULT_LEADERBOARD_CONFIG`,
      );
      return DEFAULT_LEADERBOARD_CONFIG;
    }

    return merged;
  } catch (error) {
    console.warn("configLoader: failed to read config/leaderboard; using DEFAULT_LEADERBOARD_CONFIG", error);
    return DEFAULT_LEADERBOARD_CONFIG;
  }
}

export async function loadFeatureAccessConfig(db: Firestore): Promise<FeatureAccessConfig> {
  try {
    const stored = await readConfigDoc(db, "config/featureAccess");

    if (stored === undefined) {
      console.warn("configLoader: config/featureAccess is missing; using DEFAULT_FEATURE_ACCESS_CONFIG");
      return DEFAULT_FEATURE_ACCESS_CONFIG;
    }

    const merged = deepMerge(DEFAULT_FEATURE_ACCESS_CONFIG, stored);
    const result = validateFeatureAccessConfig(merged);

    if (!result.valid) {
      console.warn(
        `configLoader: config/featureAccess failed validation (${result.errors.join(", ")}); using DEFAULT_FEATURE_ACCESS_CONFIG`,
      );
      return DEFAULT_FEATURE_ACCESS_CONFIG;
    }

    return merged;
  } catch (error) {
    console.warn("configLoader: failed to read config/featureAccess; using DEFAULT_FEATURE_ACCESS_CONFIG", error);
    return DEFAULT_FEATURE_ACCESS_CONFIG;
  }
}
