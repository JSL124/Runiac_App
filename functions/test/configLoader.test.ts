import assert from "node:assert/strict";
import { describe, it } from "node:test";
import type { Firestore } from "firebase-admin/firestore";
import {
  DEFAULT_FEATURE_ACCESS_CONFIG,
  DEFAULT_LEADERBOARD_CONFIG,
  DEFAULT_PROGRESSION_CONFIG,
  deepMerge,
  loadFeatureAccessConfig,
  loadLeaderboardConfig,
  loadProgressionConfig,
  type ProgressionConfig,
  validateFeatureAccessConfig,
  validateLeaderboardConfig,
  validateProgressionConfig,
} from "../src/config/configLoader.js";

type FakeSnapshot = {
  readonly exists: boolean;
  data(): unknown;
};

function fakeDb(docPath: string, snapshot: FakeSnapshot | (() => Promise<FakeSnapshot>)): Firestore {
  return {
    doc(path: string) {
      return {
        async get() {
          if (path !== docPath) {
            return { exists: false, data: () => undefined };
          }

          if (typeof snapshot === "function") {
            return snapshot();
          }

          return snapshot;
        },
      };
    },
  } as unknown as Firestore;
}

function missingDb(docPath: string): Firestore {
  return fakeDb(docPath, { exists: false, data: () => undefined });
}

function rejectingDb(docPath: string): Firestore {
  return {
    doc(path: string) {
      return {
        async get() {
          if (path !== docPath) {
            return { exists: false, data: () => undefined };
          }

          throw new Error("simulated firestore read failure");
        },
      };
    },
  } as unknown as Firestore;
}

describe("configLoader deepMerge", () => {
  it("partial nested config preserves missing default fields", () => {
    const merged = deepMerge(DEFAULT_PROGRESSION_CONFIG, { coolDown: { percent: 0.3 } });

    assert.equal(merged.coolDown.percent, 0.3);
    assert.equal(merged.coolDown.min, DEFAULT_PROGRESSION_CONFIG.coolDown.min);
    assert.equal(merged.coolDown.max, DEFAULT_PROGRESSION_CONFIG.coolDown.max);
    assert.equal(merged.baseCompletionXp, DEFAULT_PROGRESSION_CONFIG.baseCompletionXp);
  });

  it("replaces arrays wholesale instead of merging elements", () => {
    const merged = deepMerge(DEFAULT_PROGRESSION_CONFIG, { levelIncrements: [50, 60] });

    assert.deepEqual(merged.levelIncrements, [50, 60]);
  });
});

describe("validateProgressionConfig", () => {
  it("accepts the default config", () => {
    const result = validateProgressionConfig(DEFAULT_PROGRESSION_CONFIG);
    assert.equal(result.valid, true);
    assert.deepEqual(result.errors, []);
  });

  it("rejects negative XP fields", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      baseCompletionXp: -5,
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("baseCompletionXp")));
  });

  it("rejects dailyXpCap less than activityXpCap", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      activityXpCap: 100,
      dailyXpCap: 50,
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("dailyXpCap")));
  });

  it("rejects coolDown.min greater than coolDown.max", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      coolDown: { percent: 0.2, min: 30, max: 10 },
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("coolDown.min")));
  });

  it("rejects empty levelIncrements", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      levelIncrements: [],
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("levelIncrements")));
  });

  it("includes default streakRewards milestones", () => {
    assert.deepEqual(DEFAULT_PROGRESSION_CONFIG.streakRewards, [
      { milestoneDays: 3, bonusXp: 30 },
      { milestoneDays: 7, bonusXp: 90 },
      { milestoneDays: 14, bonusXp: 220 },
      { milestoneDays: 30, bonusXp: 600 },
    ]);
  });

  it("accepts a custom streakRewards array", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      streakRewards: [
        { milestoneDays: 2, bonusXp: 0 },
        { milestoneDays: 10, bonusXp: 250 },
      ],
    });

    assert.equal(result.valid, true);
    assert.deepEqual(result.errors, []);
  });

  it("rejects a non-array streakRewards", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      streakRewards: {} as unknown as ProgressionConfig["streakRewards"],
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("streakRewards must be an array")));
  });

  it("rejects a negative streakRewards bonusXp", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      streakRewards: [{ milestoneDays: 3, bonusXp: -1 }],
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("streakRewards[0].bonusXp")));
  });

  it("rejects non-increasing streakRewards milestoneDays", () => {
    const result = validateProgressionConfig({
      ...DEFAULT_PROGRESSION_CONFIG,
      streakRewards: [
        { milestoneDays: 7, bonusXp: 90 },
        { milestoneDays: 7, bonusXp: 120 },
      ],
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("streakRewards[1].milestoneDays")));
  });
});

describe("validateLeaderboardConfig", () => {
  it("accepts the default config", () => {
    const result = validateLeaderboardConfig(DEFAULT_LEADERBOARD_CONFIG);
    assert.equal(result.valid, true);
  });

  it("rejects a non-positive seasonLengthDays", () => {
    const result = validateLeaderboardConfig({
      ...DEFAULT_LEADERBOARD_CONFIG,
      seasonLengthDays: 0,
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("seasonLengthDays")));
  });
});

describe("validateFeatureAccessConfig", () => {
  it("accepts the default config", () => {
    const result = validateFeatureAccessConfig(DEFAULT_FEATURE_ACCESS_CONFIG);
    assert.equal(result.valid, true);
  });

  it("rejects a bad minimumTier value", () => {
    const result = validateFeatureAccessConfig({
      features: {
        advancedAnalysis: { minimumTier: "gold" as unknown as "premium", enabled: true },
      },
      version: 1,
    });

    assert.equal(result.valid, false);
    assert.ok(result.errors.some((error) => error.includes("minimumTier")));
  });
});

describe("configLoader loaders fall back to defaults", () => {
  it("loadProgressionConfig returns defaults when the doc does not exist", async () => {
    const config = await loadProgressionConfig(missingDb("config/progression"));
    assert.deepEqual(config, DEFAULT_PROGRESSION_CONFIG);
  });

  it("loadProgressionConfig returns defaults when the read rejects", async () => {
    const config = await loadProgressionConfig(rejectingDb("config/progression"));
    assert.deepEqual(config, DEFAULT_PROGRESSION_CONFIG);
  });

  it("loadProgressionConfig returns defaults when the stored doc is invalid", async () => {
    const db = fakeDb("config/progression", {
      exists: true,
      data: () => ({ dailyXpCap: -1 }),
    });

    const config = await loadProgressionConfig(db);
    assert.deepEqual(config, DEFAULT_PROGRESSION_CONFIG);
  });

  it("loadLeaderboardConfig returns defaults when the doc does not exist", async () => {
    const config = await loadLeaderboardConfig(missingDb("config/leaderboard"));
    assert.deepEqual(config, DEFAULT_LEADERBOARD_CONFIG);
  });

  it("loadLeaderboardConfig returns defaults when the read rejects", async () => {
    const config = await loadLeaderboardConfig(rejectingDb("config/leaderboard"));
    assert.deepEqual(config, DEFAULT_LEADERBOARD_CONFIG);
  });

  it("loadFeatureAccessConfig returns defaults when the doc does not exist", async () => {
    const config = await loadFeatureAccessConfig(missingDb("config/featureAccess"));
    assert.deepEqual(config, DEFAULT_FEATURE_ACCESS_CONFIG);
  });

  it("loadFeatureAccessConfig returns defaults when the read rejects", async () => {
    const config = await loadFeatureAccessConfig(rejectingDb("config/featureAccess"));
    assert.deepEqual(config, DEFAULT_FEATURE_ACCESS_CONFIG);
  });

  it("loadFeatureAccessConfig merges a partial stored override with defaults", async () => {
    const db = fakeDb("config/featureAccess", {
      exists: true,
      data: () => ({ features: { leaderboard: { minimumTier: "basic", enabled: false } } }),
    });

    const config = await loadFeatureAccessConfig(db);
    assert.equal(config.features["leaderboard"]?.enabled, false);
    assert.deepEqual(config.features["advancedAnalysis"], DEFAULT_FEATURE_ACCESS_CONFIG.features["advancedAnalysis"]);
  });
});

// Both flags are read as plain truthiness tests and deepMerge passes stored
// values through verbatim, so a wrong TYPE silently inverts the policy rather
// than failing. These pin that the validator rejects them instead.
describe("policy flag type validation", () => {
  it("rejects a non-boolean premiumEarnsXp", () => {
    for (const value of ["false", "true", 0, 1, null]) {
      const result = validateProgressionConfig({
        ...DEFAULT_PROGRESSION_CONFIG,
        premiumEarnsXp: value as unknown as boolean,
      });
      assert.equal(result.valid, false, `premiumEarnsXp ${JSON.stringify(value)} must be rejected`);
      assert.ok(result.errors.some((error) => error.includes("premiumEarnsXp")));
    }
  });

  it("rejects a non-boolean excludePremium", () => {
    for (const value of ["false", "true", 0, 1, null]) {
      const result = validateLeaderboardConfig({
        ...DEFAULT_LEADERBOARD_CONFIG,
        excludePremium: value as unknown as boolean,
      });
      assert.equal(result.valid, false, `excludePremium ${JSON.stringify(value)} must be rejected`);
      assert.ok(result.errors.some((error) => error.includes("excludePremium")));
    }
  });

  it("accepts the shipped defaults", () => {
    assert.equal(validateProgressionConfig(DEFAULT_PROGRESSION_CONFIG).valid, true);
    assert.equal(validateLeaderboardConfig(DEFAULT_LEADERBOARD_CONFIG).valid, true);
  });
});

// A single bad value used to discard the whole document, so an admin fixing a
// typo would have found every other tuned field reverted with only a
// console.warn as the signal.
describe("per-field config repair", () => {
  it("keeps valid fields when one field is invalid", async () => {
    const db = fakeDb("config/progression", {
      exists: true,
      data: () => ({ premiumEarnsXp: "false", dailyXpCap: 500, xpPerKilometer: 25 }),
    });

    const config = await loadProgressionConfig(db);

    // The bad flag is reset to its default...
    assert.equal(config.premiumEarnsXp, DEFAULT_PROGRESSION_CONFIG.premiumEarnsXp);
    // ...and the admin's other tuning survives.
    assert.equal(config.dailyXpCap, 500);
    assert.equal(config.xpPerKilometer, 25);
  });

  it("keeps valid leaderboard fields when excludePremium is the wrong type", async () => {
    const db = fakeDb("config/leaderboard", {
      exists: true,
      data: () => ({ excludePremium: "false", minRunsToQualify: 4 }),
    });

    const config = await loadLeaderboardConfig(db);

    assert.equal(config.excludePremium, DEFAULT_LEADERBOARD_CONFIG.excludePremium);
    assert.equal(config.minRunsToQualify, 4);
  });

  it("still falls back to the whole default when the repair cannot succeed", async () => {
    // dailyXpCap < activityXpCap is a cross-field rule, so resetting the named
    // field alone does not necessarily satisfy it; whatever the repair does,
    // the result must be valid.
    const db = fakeDb("config/progression", {
      exists: true,
      data: () => ({ dailyXpCap: 10, activityXpCap: 100 }),
    });

    const config = await loadProgressionConfig(db);

    assert.equal(validateProgressionConfig(config).valid, true);
  });
});
