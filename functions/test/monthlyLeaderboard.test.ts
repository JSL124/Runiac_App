import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  currentSingaporeMonthKey,
  leaderboardContributionFields,
  planMonthlyLeaderboards,
  singaporeMonthLabel,
} from "../src/leaderboard/monthlyLeaderboard.js";

describe("monthly leaderboard aggregation", () => {
  it("partitions one monthly score by planning area and current league", () => {
    const plan = planMonthlyLeaderboards({
      periodKey: "2026-07",
      contributions: [
        contribution({ ownerUid: "je-iron-2", scoreXp: 90 }),
        contribution({ ownerUid: "je-iron-1", scoreXp: 130 }),
        contribution({
          ownerUid: "tm-iron-1",
          scoreXp: 80,
          regionId: "tampines",
          regionLabel: "Tampines",
          planningAreaName: "TAMPINES",
          planningAreaCode: "TM",
          planningRegionCode: "ER",
        }),
        contribution({
          ownerUid: "je-bronze-1",
          scoreXp: 70,
          divisionKey: "tier_02",
          divisionLabel: "Bronze League",
          levelLabel: "Level 11",
        }),
      ],
    });

    assert.deepEqual(
      plan.snapshots.map((snapshot) => snapshot.snapshotId),
      [
        "monthly_jurong-east_tier_01_2026-07",
        "monthly_jurong-east_tier_02_2026-07",
        "monthly_tampines_tier_01_2026-07",
      ],
    );
    const jurongIron = plan.snapshots[0];
    assert.equal(jurongIron?.entryCount, 2);
    assert.deepEqual(
      jurongIron?.topEntries.map((entry) => [
        entry.publicAlias,
        entry.rankLabel,
        entry.scoreLabel,
      ]),
      [
        ["Runner je-iron-1", "#1", "130 XP"],
        ["Runner je-iron-2", "#2", "90 XP"],
      ],
    );
    assert.equal(
      Object.hasOwn(jurongIron?.topEntries[0] ?? {}, "ownerUid"),
      false,
    );
  });

  it("bounds public top rows at ten and private nearby rows at five", () => {
    const plan = planMonthlyLeaderboards({
      periodKey: "2026-07",
      contributions: Array.from({ length: 15 }, (_, index) =>
        contribution({
          ownerUid: `runner-${String(index + 1).padStart(2, "0")}`,
          scoreXp: 1_000 - index,
        }),
      ),
    });

    assert.equal(plan.snapshots[0]?.entryCount, 15);
    assert.equal(plan.snapshots[0]?.topEntries.length, 10);
    const rank = plan.ranks.find((item) => item.ownerUid === "runner-12");
    assert.equal(rank?.rankLabel, "#12");
    assert.equal(rank?.nearbyEntries.length, 5);
    assert.ok(
      rank?.nearbyEntries.some((entry) => entry.rankLabel === "#12"),
    );
    assert.equal(Object.hasOwn(rank?.currentEntry ?? {}, "ownerUid"), false);
  });

  it("re-checks current Premium status and rejects malformed legacy rows", () => {
    const plan = planMonthlyLeaderboards({
      periodKey: "2026-07",
      currentPremiumUids: new Set(["premium"]),
      contributions: [
        contribution({ ownerUid: "basic", scoreXp: 70 }),
        contribution({ ownerUid: "premium", scoreXp: 500 }),
        {
          ...contribution({ ownerUid: "legacy", scoreXp: 900 }),
          schemaVersion: 1,
        },
        {
          ...contribution({ ownerUid: "unsupported", scoreXp: 800 }),
          regionId: "sg",
        },
      ],
    });

    assert.deepEqual(
      plan.snapshots.flatMap((snapshot) =>
        snapshot.topEntries.map((entry) => entry.publicAlias),
      ),
      ["Runner basic"],
    );
    assert.equal(
      plan.currentViews.find((view) => view.ownerUid === "premium")?.status,
      "ineligible_premium",
    );
  });

  it("preserves zero-score Premium exclusions without projecting inactive rows", () => {
    const plan = planMonthlyLeaderboards({
      periodKey: "2026-07",
      currentPremiumUids: new Set(["premium-zero"]),
      contributions: [
        contribution({ ownerUid: "ranked-basic", scoreXp: 70 }),
        {
          ...contribution({ ownerUid: "premium-zero", scoreXp: 0 }),
          eligible: false,
          eligibilityReason: "ineligible_premium",
        },
        contribution({ ownerUid: "basic-zero", scoreXp: 0 }),
        contribution({ ownerUid: "negative", scoreXp: -1 }),
      ],
    });

    assert.deepEqual(
      plan.currentViews.filter((view) => view.ownerUid === "premium-zero"),
      [
        {
          ownerUid: "premium-zero",
          snapshotId: null,
          rankId: null,
          periodKey: "2026-07",
          regionId: "jurong-east",
          divisionKey: "tier_01",
          status: "ineligible_premium",
        },
      ],
    );
    assert.deepEqual(
      plan.snapshots.flatMap((snapshot) =>
        snapshot.topEntries.map((entry) => entry.publicAlias),
      ),
      ["Runner ranked-basic"],
    );
    assert.deepEqual(plan.ranks.map((rank) => rank.ownerUid), ["ranked-basic"]);
    assert.equal(plan.currentViews.some((view) => ["basic-zero", "negative"].includes(view.ownerUid)), false);
  });

  it("ranks a contribution normally at the default minRunsToQualify of 1 (zero regression)", () => {
    const plan = planMonthlyLeaderboards({
      periodKey: "2026-07",
      contributions: [
        contribution({ ownerUid: "one-run", scoreXp: 70, qualifyingRunCount: 1 }),
      ],
    });

    assert.deepEqual(
      plan.snapshots.flatMap((snapshot) =>
        snapshot.topEntries.map((entry) => entry.publicAlias),
      ),
      ["Runner one-run"],
    );
    assert.equal(
      plan.currentViews.find((view) => view.ownerUid === "one-run")?.status,
      "ranked",
    );
  });

  it("excludes a contribution under minRunsToQualify and emits an ineligible_min_runs currentView", () => {
    const plan = planMonthlyLeaderboards({
      periodKey: "2026-07",
      minRunsToQualify: 3,
      contributions: [
        contribution({ ownerUid: "under-quota", scoreXp: 70, qualifyingRunCount: 2 }),
      ],
    });

    assert.deepEqual(
      plan.snapshots.flatMap((snapshot) =>
        snapshot.topEntries.map((entry) => entry.publicAlias),
      ),
      [],
    );
    const view = plan.currentViews.find(
      (candidate) => candidate.ownerUid === "under-quota",
    );
    assert.ok(view !== undefined, "expected an ineligible_min_runs currentView to be emitted");
    assert.deepEqual(view, {
      ownerUid: "under-quota",
      snapshotId: null,
      rankId: null,
      periodKey: "2026-07",
      regionId: "jurong-east",
      divisionKey: "tier_01",
      status: "ineligible_min_runs",
    });
  });

  it("grandfathers a legacy contribution with no qualifyingRunCount field", () => {
    const plan = planMonthlyLeaderboards({
      periodKey: "2026-07",
      minRunsToQualify: 5,
      contributions: [
        contribution({ ownerUid: "legacy-runner", scoreXp: 70 }),
      ],
    });

    assert.deepEqual(
      plan.snapshots.flatMap((snapshot) =>
        snapshot.topEntries.map((entry) => entry.publicAlias),
      ),
      ["Runner legacy-runner"],
    );
    assert.equal(
      plan.currentViews.find((view) => view.ownerUid === "legacy-runner")
        ?.status,
      "ranked",
    );
  });

  it("uses Asia Singapore month boundaries and labels", () => {
    assert.equal(
      currentSingaporeMonthKey(new Date("2026-06-30T15:59:59.000Z")),
      "2026-06",
    );
    assert.equal(
      currentSingaporeMonthKey(new Date("2026-06-30T16:00:00.000Z")),
      "2026-07",
    );
    assert.equal(singaporeMonthLabel("2026-07"), "July 2026");
  });

  it("derives contribution geography from profile and freezes it for the month", () => {
    const initial = leaderboardContributionFields({
      uid: "runner-1",
      progressionEventId: "progression-runner-1-session-1",
      completedAt: "2026-07-10T00:00:00.000Z",
      periodKey: "2026-07",
      scoreXp: 75,
      divisionKey: "tier_01",
      divisionLabel: "ignored client label",
      levelLabel: "Level 1",
      profileData: {
        nickname: "Jinseo",
        locationLabel: "Jurong East, Singapore",
      },
    });
    assert.equal(initial?.regionId, "jurong-east");
    assert.equal(initial?.planningAreaCode, "JE");
    assert.equal(initial?.divisionLabel, "Iron League");
    assert.equal(initial?.publicAlias, "Jinseo");

    const movedProfile = leaderboardContributionFields({
      uid: "runner-1",
      progressionEventId: "progression-runner-1-session-2",
      completedAt: "2026-07-11T00:00:00.000Z",
      periodKey: "2026-07",
      scoreXp: 50,
      divisionKey: "tier_02",
      divisionLabel: "ignored client label",
      levelLabel: "Level 11",
      profileData: {
        nickname: "Jinseo",
        locationLabel: "Jurong East, Singapore",
      },
      existingContributionData: contribution({
        ownerUid: "runner-1",
        regionId: "tampines",
        regionLabel: "Tampines",
        planningAreaName: "TAMPINES",
        planningAreaCode: "TM",
        planningRegionCode: "ER",
      }),
    });
    assert.equal(movedProfile?.regionId, "tampines");
    assert.equal(movedProfile?.divisionKey, "tier_02");
    assert.equal(movedProfile?.divisionLabel, "Bronze League");

    const unsupported = leaderboardContributionFields({
      uid: "runner-2",
      progressionEventId: "progression-runner-2-session-1",
      completedAt: "2026-07-10T00:00:00.000Z",
      periodKey: "2026-07",
      scoreXp: 75,
      divisionKey: "tier_01",
      divisionLabel: "Iron League",
      levelLabel: "Level 1",
      profileData: { nickname: "No Area", locationLabel: "Tuas, Singapore" },
    });
    assert.equal(unsupported, null);
  });
});

function contribution(input: {
  readonly ownerUid: string;
  readonly scoreXp?: number;
  readonly regionId?: string;
  readonly regionLabel?: string;
  readonly planningAreaName?: string;
  readonly planningAreaCode?: string;
  readonly planningRegionCode?: string;
  readonly divisionKey?: string;
  readonly divisionLabel?: string;
  readonly levelLabel?: string;
  readonly qualifyingRunCount?: number;
}): Record<string, unknown> {
  return {
    schemaVersion: 2,
    ownerUid: input.ownerUid,
    publicAlias: `Runner ${input.ownerUid}`,
    regionId: input.regionId ?? "jurong-east",
    regionLabel: input.regionLabel ?? "Jurong East",
    planningAreaName: input.planningAreaName ?? "JURONG EAST",
    planningAreaCode: input.planningAreaCode ?? "JE",
    planningRegionCode: input.planningRegionCode ?? "WR",
    divisionKey: input.divisionKey ?? "tier_01",
    divisionLabel: input.divisionLabel ?? "Iron League",
    levelLabel: input.levelLabel ?? "Level 1",
    periodType: "monthly",
    periodKey: "2026-07",
    timezone: "Asia/Singapore",
    scoreXp: input.scoreXp ?? 75,
    eligible: true,
    eligibilityReason: "eligible_basic_awarded_xp",
    lastProgressionAt: "2026-07-10T00:00:00.000Z",
    sourceProgressionEventIds: [`event-${input.ownerUid}`],
    ...(input.qualifyingRunCount === undefined
      ? {}
      : { qualifyingRunCount: input.qualifyingRunCount }),
  };
}
