import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { DEFAULT_PROGRESSION_CONFIG } from "../src/config/configLoader.js";
import {
  applyDailyXpCap,
  calculateActivityXp,
  calculateCoolDownBonus,
  dailyCapDateForCompletedAt,
  monthlyPeriodForCompletedAt,
  resolveLevelProgression,
} from "../src/progression/progressionCalculator.js";

const config = DEFAULT_PROGRESSION_CONFIG;

describe("progression calculator", () => {
  it("awards hybrid activity XP without pace input", () => {
    const result = calculateActivityXp(
      {
        distanceMeters: 4200,
        activeDurationSeconds: 1860,
        lowDataConfirmed: false,
        planCompletionBonusEligible: false,
      },
      config,
    );

    assert.equal(result.xpDeltaBeforeDailyCap, 75);
    assert.equal(result.baseCompletionXp, 20);
    assert.equal(result.distanceXp, 40);
    assert.equal(result.durationXp, 15);
    assert.equal(result.planCompletionBonusXp, 0);
    assert.equal(result.rawXpBeforeActivityCap, 75);
    assert.equal(result.activityCapApplied, false);
    assert.equal(result.reason, "run_completion_xp_awarded");
  });

  it("caps one accepted activity at 100 XP before the daily cap", () => {
    const result = calculateActivityXp(
      {
        distanceMeters: 15000,
        activeDurationSeconds: 7200,
        lowDataConfirmed: false,
        planCompletionBonusEligible: true,
      },
      config,
    );

    assert.equal(result.rawXpBeforeActivityCap, 250);
    assert.equal(result.xpDeltaBeforeDailyCap, 100);
    assert.equal(result.activityCapApplied, true);
    assert.equal(result.planCompletionBonusXp, 20);
  });

  it("keeps low-data confirmed saves at zero XP", () => {
    const result = calculateActivityXp(
      {
        distanceMeters: 0,
        activeDurationSeconds: 2,
        lowDataConfirmed: true,
        planCompletionBonusEligible: true,
      },
      config,
    );

    assert.equal(result.xpDeltaBeforeDailyCap, 0);
    assert.equal(result.planCompletionBonusXp, 0);
    assert.equal(result.reason, "low_data_no_xp");
  });

  it("applies the Asia Singapore daily cap", () => {
    const capped = applyDailyXpCap(
      {
        xpDeltaBeforeDailyCap: 75,
        dailyXpBefore: 150,
      },
      config,
    );
    const exhausted = applyDailyXpCap(
      {
        xpDeltaBeforeDailyCap: 75,
        dailyXpBefore: 200,
      },
      config,
    );

    assert.equal(capped.xpDelta, 50);
    assert.equal(capped.dailyXpAfter, 200);
    assert.equal(capped.dailyCapApplied, true);
    assert.equal(exhausted.xpDelta, 0);
    assert.equal(exhausted.dailyXpAfter, 200);
    assert.equal(exhausted.dailyCapApplied, true);
  });

  it("derives daily cap date from Asia Singapore local date", () => {
    assert.equal(
      dailyCapDateForCompletedAt("2026-06-14T16:30:00.000Z"),
      "2026-06-15",
    );
  });

  it("derives monthly leaderboard period from Asia Singapore local date", () => {
    assert.equal(
      monthlyPeriodForCompletedAt("2026-06-30T16:30:00.000Z"),
      "2026-07",
    );
  });

  it("resolves Lv.100 at 53600 total XP with stable division keys", () => {
    const initial = resolveLevelProgression(0, config);
    const mid = resolveLevelProgression(53600 - 1, config);
    const max = resolveLevelProgression(53600, config);

    assert.equal(initial.level, 1);
    assert.equal(initial.divisionKey, "tier_01");
    assert.equal(initial.divisionLabel, "Iron League");
    assert.equal(initial.nextLevelXp, 100);
    assert.equal(mid.level, 99);
    assert.equal(mid.divisionKey, "tier_10");
    assert.equal(mid.divisionLabel, "Challenger League");
    assert.equal(max.level, 100);
    assert.equal(max.divisionKey, "tier_10");
    assert.equal(max.divisionLabel, "Challenger League");
    assert.equal(max.nextLevelXp, null);
    assert.equal(max.xpToNextLevel, null);
    assert.equal(max.levelProgressPercent, 100);
  });
});

describe("cool-down bonus calculator", () => {
  it("awards a 20 percent bonus rounded to the nearest 5 XP", () => {
    assert.equal(calculateCoolDownBonus(40, config), 10);
    assert.equal(calculateCoolDownBonus(75, config), 15);
  });

  it("caps the bonus so the activity total never exceeds the 100 XP activity cap", () => {
    assert.equal(calculateCoolDownBonus(95, config), 5);
  });

  it("floors the bonus at 5 XP for small nonzero bases", () => {
    assert.equal(calculateCoolDownBonus(10, config), 5);
  });

  it("awards zero bonus once the base XP already exhausts the activity cap", () => {
    assert.equal(calculateCoolDownBonus(100, config), 0);
  });

  it("awards zero bonus for zero or invalid base XP", () => {
    assert.equal(calculateCoolDownBonus(0, config), 0);
    assert.equal(calculateCoolDownBonus(-10, config), 0);
    assert.equal(calculateCoolDownBonus(Number.NaN, config), 0);
  });
});
