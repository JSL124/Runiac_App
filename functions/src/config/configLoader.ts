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

// The DEFAULT_* constants are handed out directly (the validation fallback
// returns them, `deepMerge` copies only the top level so an untouched nested
// key like `coolDown` is still the constant's own object, and the per-field
// repair resets to them). Anything that mutated one would corrupt the defaults
// for the lifetime of the Functions instance — a process-wide change caused by
// a single request. They are `readonly` in the type system, which is erased at
// runtime, so freeze them for real.
function deepFreeze<T>(value: T): T {
  if (value !== null && typeof value === "object" && !Object.isFrozen(value)) {
    Object.freeze(value);
    for (const nested of Object.values(value as Record<string, unknown>)) {
      deepFreeze(nested);
    }
  }
  return value;
}

export const DEFAULT_PROGRESSION_CONFIG: ProgressionConfig = deepFreeze({
  baseCompletionXp: 20,
  xpPerKilometer: 10,
  xpPerTenActiveMinutes: 5,
  planCompletionBonusXp: 20,
  activityXpCap: 100,
  dailyXpCap: 200,
  // Premium buys coaching, analysis, and presentation value — never a
  // competitive edge. Premium runners therefore earn XP under exactly the same
  // rules as Basic runners; suppressing it instead froze their level, division,
  // and leaderboard standing, which reads as a penalty for paying.
  premiumEarnsXp: true,
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
});

export const DEFAULT_LEADERBOARD_CONFIG: LeaderboardConfig = deepFreeze({
  minRunsToQualify: 1,
  // Paired with `premiumEarnsXp: true`: premium runners accrue XP normally, so
  // they rank on the same board under the same formula. Flipping this to `true`
  // without also clearing `premiumEarnsXp` would rank them at a permanent zero.
  excludePremium: false,
  seasonLengthDays: 30,
  version: 1,
});

export const DEFAULT_FEATURE_ACCESS_CONFIG: FeatureAccessConfig = deepFreeze({
  features: {
    advancedAnalysis: { minimumTier: "premium", enabled: true },
    goalPlan: { minimumTier: "premium", enabled: true },
    leaderboard: { minimumTier: "basic", enabled: true },
  },
  version: 1,
});

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

  // Same reasoning as excludePremium: a stored "false" string would be truthy
  // and silently keep premium XP suppressed, or a stored 0 would silently
  // suppress it, with no error surfaced to the admin who saved it.
  if (typeof config.premiumEarnsXp !== "boolean") {
    errors.push("premiumEarnsXp must be a boolean");
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

  // Type-checked explicitly because deepMerge passes stored values through
  // verbatim and this flag is read as a plain truthiness test. A Firestore
  // write of the STRING "false" is truthy, which would silently switch premium
  // exclusion back on with no error anywhere.
  if (typeof config.excludePremium !== "boolean") {
    errors.push("excludePremium must be a boolean");
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


/**
 * Repairs a merged config by resetting ONLY the fields the validator rejected
 * back to their defaults, instead of discarding the whole document.
 *
 * The all-or-nothing fallback meant a single bad value — say a
 * `premiumEarnsXp: "false"` string written by hand — silently reverted every
 * other tuned field in the same document (XP rates, caps, the level curve,
 * streak rewards) with only a console.warn as the signal. An admin fixing a
 * typo would have found their whole configuration gone.
 *
 * Error strings are formatted "<field> must ..." / "<field>.<sub> must ..." /
 * "<field>[i].<sub> must ...", so the leading segment names the top-level key
 * to reset. Resetting the whole top-level key (rather than the exact nested
 * leaf) is deliberate: a partially-valid array or nested object is harder to
 * reason about than a known-good default.
 *
 * Falls back to `defaults` if the repair does not produce a valid config.
 *
 * Note what this does and does not guarantee. It cannot widen what
 * VALIDATION accepts — the repaired candidate is re-validated. It does widen
 * what the runtime HONOURS compared with the previous all-or-nothing
 * fallback: a document with one bad field used to run entirely on defaults,
 * and now its remaining valid-but-extreme values take effect. Validation has
 * no upper bounds, so `{ xpPerKilometer: 100000, premiumEarnsXp: "false" }`
 * previously ran at the default 10 XP/km and now runs at 100000.
 *
 * Cross-field rules are attributed to a single key, so the repair can also
 * satisfy a rule in a direction the admin did not intend: stored
 * `{ activityXpCap: 150, dailyXpCap: 120 }` fails "dailyXpCap must be >=
 * activityXpCap", resets `dailyXpCap` to 200, and ends up honouring a raised
 * per-run cap against a daily cap nobody wrote.
 *
 * Both are acceptable because the supported writer — the admin console —
 * validates with the mirrored ruleset and refuses an invalid save outright,
 * so a document reaching this path came from a direct Firestore edit or
 * predates the contract.
 */
function repairInvalidConfigFields<T>(
  merged: T,
  errors: readonly string[],
  defaults: T,
  validate: (candidate: T) => ConfigValidationResult,
): { readonly config: T; readonly resetFields: readonly string[] } | null {
  const resetFields = new Set<string>();

  for (const error of errors) {
    const field = error.split(" ")[0]?.split(".")[0]?.split("[")[0];
    if (field !== undefined && field.length > 0 && field in (defaults as object)) {
      resetFields.add(field);
    }
  }

  if (resetFields.size === 0) {
    return null;
  }

  const repaired = { ...(merged as Record<string, unknown>) };
  for (const field of resetFields) {
    // Cloned, not referenced. Several defaults are objects or arrays
    // (`coolDown`, `levelIncrements`, `streakRewards`), and handing back the
    // module-level constant would let anything that mutates the returned
    // config corrupt DEFAULT_*_CONFIG for the lifetime of the Functions
    // instance — a process-wide change from a single request.
    repaired[field] = structuredClone((defaults as Record<string, unknown>)[field]);
  }

  const candidate = repaired as T;
  return validate(candidate).valid
    ? { config: candidate, resetFields: [...resetFields] }
    : null;
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
      const repaired = repairInvalidConfigFields(
        merged,
        result.errors,
        DEFAULT_PROGRESSION_CONFIG,
        validateProgressionConfig,
      );

      if (repaired !== null) {
        console.warn(
          `configLoader: config/progression failed validation (${result.errors.join(", ")}); reset ${repaired.resetFields.join(", ")} to defaults and kept the rest`,
        );
        return repaired.config;
      }

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
      const repaired = repairInvalidConfigFields(
        merged,
        result.errors,
        DEFAULT_LEADERBOARD_CONFIG,
        validateLeaderboardConfig,
      );

      if (repaired !== null) {
        console.warn(
          `configLoader: config/leaderboard failed validation (${result.errors.join(", ")}); reset ${repaired.resetFields.join(", ")} to defaults and kept the rest`,
        );
        return repaired.config;
      }

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
