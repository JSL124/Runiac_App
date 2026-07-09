import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  currentSingaporeMonthKey,
  leaderboardContributionFields,
  planMonthlyLeaderboard,
} from "../src/leaderboard/monthlyLeaderboard.js";

describe("monthly leaderboard aggregation planner", () => {
  it("builds snapshot rank and current-view writes from eligible contributions", () => {
    const plan = planMonthlyLeaderboard({
      periodKey: "2026-07",
      contributions: [
        awardedContribution({
          ownerUid: "runner-2",
          displayName: "Ari S.",
          xpDelta: 90,
          levelLabel: "Level 19",
        }),
        awardedContribution({
          ownerUid: "runner-1",
          displayName: "Jinseo (You)",
          xpDelta: 130,
          levelLabel: "Level 18",
        }),
      ],
    });

    assert.equal(plan.snapshotId, "monthly_sg_tier_01_2026-07");
    assert.deepEqual(
      plan.entries.map((entry) => [entry.userId, entry.rankLabel, entry.scoreLabel]),
      [
        ["runner-1", "#1", "130 XP"],
        ["runner-2", "#2", "90 XP"],
      ],
    );
    assert.deepEqual(
      plan.ranks.map((rank) => [rank.rankId, rank.uid, rank.rankLabel]),
      [
        ["runner-1_monthly_sg_tier_01_2026-07", "runner-1", "#1"],
        ["runner-2_monthly_sg_tier_01_2026-07", "runner-2", "#2"],
      ],
    );
    assert.deepEqual(
      plan.currentViews.map((view) => [view.uid, view.snapshotId, view.rankId]),
      [
        [
          "runner-1",
          "monthly_sg_tier_01_2026-07",
          "runner-1_monthly_sg_tier_01_2026-07",
        ],
        [
          "runner-2",
          "monthly_sg_tier_01_2026-07",
          "runner-2_monthly_sg_tier_01_2026-07",
        ],
      ],
    );
  });

  it("ignores malformed stale premium or non-leaderboard contributions", () => {
    const plan = planMonthlyLeaderboard({
      periodKey: "2026-07",
      contributions: [
        awardedContribution({ ownerUid: "eligible", xpDelta: 70 }),
        awardedContribution({
          ownerUid: "stale",
          monthlyPeriod: "2026-06",
          xpDelta: 500,
        }),
        awardedContribution({
          ownerUid: "premium",
          scoreXp: 0,
          eligible: true,
        }),
        awardedContribution({
          ownerUid: "not-counted",
          scoreXp: 50,
          eligible: false,
        }),
        { ownerUid: "malformed", periodKey: "2026-07", scoreXp: "90" },
      ],
    });

    assert.deepEqual(
      plan.entries.map((entry) => entry.userId),
      ["eligible"],
    );
  });

  it("uses Asia Singapore month boundaries for scheduled refresh keys", () => {
    assert.equal(
      currentSingaporeMonthKey(new Date("2026-06-30T15:59:59.000Z")),
      "2026-06",
    );
    assert.equal(
      currentSingaporeMonthKey(new Date("2026-06-30T16:00:00.000Z")),
      "2026-07",
    );
  });

  it("builds deterministic backend-only monthly contribution fields", () => {
    const contribution = leaderboardContributionFields({
      uid: "runner-1",
      progressionEventId: "progression-runner-1-session-1",
      completedAt: "2026-07-10T00:00:00.000Z",
      periodKey: "2026-07",
      scoreXp: 75,
      divisionKey: "tier_01",
      divisionLabel: "Trailborn League",
      levelLabel: "Level 1",
      profileData: { displayName: "Jinseo (You)" },
    });

    assert.deepEqual(contribution, {
      ownerUid: "runner-1",
      displayName: "Jinseo (You)",
      regionId: "sg",
      regionLabel: "Singapore",
      divisionKey: "tier_01",
      divisionLabel: "Trailborn League",
      levelLabel: "Level 1",
      periodType: "monthly",
      periodKey: "2026-07",
      timezone: "Asia/Singapore",
      scoreXp: 75,
      eligible: true,
      eligibilityReason: "eligible_basic_awarded_xp",
      lastProgressionAt: "2026-07-10T00:00:00.000Z",
      sourceProgressionEventIds: ["progression-runner-1-session-1"],
    });
  });
});

function awardedContribution(input: {
  readonly ownerUid: string;
  readonly xpDelta?: number;
  readonly scoreXp?: number;
  readonly displayName?: string;
  readonly monthlyPeriod?: string;
  readonly levelLabel?: string;
  readonly eligible?: boolean;
}): Record<string, unknown> {
  return {
    ownerUid: input.ownerUid,
    displayName: input.displayName ?? input.ownerUid,
    regionId: "sg",
    regionLabel: "Singapore",
    divisionKey: "tier_01",
    divisionLabel: "Trailborn League",
    levelLabel: input.levelLabel ?? "Level 1",
    periodType: "monthly",
    periodKey: input.monthlyPeriod ?? "2026-07",
    timezone: "Asia/Singapore",
    scoreXp: input.scoreXp ?? input.xpDelta ?? 0,
    eligible: input.eligible ?? true,
    eligibilityReason: "eligible_basic_awarded_xp",
    lastProgressionAt: "2026-07-10T00:00:00.000Z",
    sourceProgressionEventIds: [`event-${input.ownerUid}`],
  };
}
