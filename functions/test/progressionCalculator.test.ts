import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  applyDailyXpCap,
  calculateActivityXp,
  dailyCapDateForCompletedAt,
  resolveLevelProgression,
} from "../src/progression/progressionCalculator.js";

describe("progression calculator", () => {
  it("awards hybrid activity XP without pace input", () => {
    const result = calculateActivityXp({
      distanceMeters: 4200,
      activeDurationSeconds: 1860,
      lowDataConfirmed: false,
      planCompletionBonusEligible: false,
    });

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
    const result = calculateActivityXp({
      distanceMeters: 15000,
      activeDurationSeconds: 7200,
      lowDataConfirmed: false,
      planCompletionBonusEligible: true,
    });

    assert.equal(result.rawXpBeforeActivityCap, 250);
    assert.equal(result.xpDeltaBeforeDailyCap, 100);
    assert.equal(result.activityCapApplied, true);
    assert.equal(result.planCompletionBonusXp, 20);
  });

  it("keeps low-data confirmed saves at zero XP", () => {
    const result = calculateActivityXp({
      distanceMeters: 0,
      activeDurationSeconds: 2,
      lowDataConfirmed: true,
      planCompletionBonusEligible: true,
    });

    assert.equal(result.xpDeltaBeforeDailyCap, 0);
    assert.equal(result.planCompletionBonusXp, 0);
    assert.equal(result.reason, "low_data_no_xp");
  });

  it("applies the Asia Singapore daily cap", () => {
    const capped = applyDailyXpCap({
      xpDeltaBeforeDailyCap: 75,
      dailyXpBefore: 150,
    });
    const exhausted = applyDailyXpCap({
      xpDeltaBeforeDailyCap: 75,
      dailyXpBefore: 200,
    });

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

  it("resolves Lv.100 at 53600 total XP with stable division keys", () => {
    const initial = resolveLevelProgression(0);
    const mid = resolveLevelProgression(53600 - 1);
    const max = resolveLevelProgression(53600);

    assert.equal(initial.level, 1);
    assert.equal(initial.divisionKey, "tier_01");
    assert.equal(initial.nextLevelXp, 100);
    assert.equal(mid.level, 99);
    assert.equal(mid.divisionKey, "tier_10");
    assert.equal(max.level, 100);
    assert.equal(max.divisionKey, "tier_10");
    assert.equal(max.nextLevelXp, null);
    assert.equal(max.xpToNextLevel, null);
    assert.equal(max.levelProgressPercent, 100);
  });
});
