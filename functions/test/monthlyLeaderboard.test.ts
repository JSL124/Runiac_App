import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import {
  currentSingaporeMonthKey,
  leaderboardContributionFields,
  planMonthlyLeaderboards,
  refreshMonthlyLeaderboardSnapshots,
  singaporeMonthLabel,
} from "../src/leaderboard/monthlyLeaderboard.js";
import { generateMockLeaderboardDataset } from "../src/leaderboard/leaderboardMockDataset.js";

describe("monthly leaderboard aggregation", () => {
  it("generates 100 distinct synthetic profiles for every supported area", () => {
    const dataset = generateMockLeaderboardDataset({
      runId: "test-seed-001",
      periodKey: "2026-07",
    });
    assert.equal(dataset.regionCount, 37);
    assert.equal(dataset.usersPerRegion, 100);
    assert.equal(dataset.records.length, 3_700);
    assert.equal(
      new Set(dataset.records.map((record) => record.uid)).size,
      3_700,
    );
    assert.equal(
      new Set(
        dataset.records.map((record) => record.profile["locationLabel"]),
      ).size,
      37,
    );
    assert.equal(
      dataset.records.filter(
        (record) => record.user["subscriptionStatus"] === "premium",
      ).length,
      37,
    );
  });

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

describe(
  "monthly leaderboard Firestore writer",
  { skip: process.env["FIRESTORE_EMULATOR_HOST"] === undefined },
  () => {
    let firestore: Firestore;

    before(() => {
      if (getApps().length === 0) {
        initializeApp({ projectId: "runiac-functions-test" });
      }
      firestore = getFirestore();
    });

    beforeEach(async () => {
      await clearCollections(firestore, [
        "users",
        "userProfiles",
        "leaderboardContributions",
        "leaderboardSnapshots",
        "leaderboardUserRanks",
        "leaderboardCurrentViews",
        "leaderboardPeriods",
        "leaderboardAggregationLocks",
      ]);
    });

    it("claims one lease and publishes bounded projections before current views", async () => {
      const batch = firestore.batch();
      for (let index = 0; index < 15; index += 1) {
        const uid = `writer-runner-${String(index + 1).padStart(2, "0")}`;
        batch.set(firestore.doc(`users/${uid}`), {
          subscriptionStatus: "basic",
        });
        batch.set(firestore.doc(`userProfiles/${uid}`), {
          nickname: `Writer ${index + 1}`,
          locationLabel: "Jurong East, Singapore",
          divisionKey: "tier_01",
          level: 1,
        });
        batch.set(
          firestore.doc(`leaderboardContributions/${uid}_monthly_2026-07`),
          contribution({ ownerUid: uid, scoreXp: 1_000 - index }),
        );
      }
      await batch.commit();

      await firestore
        .doc("leaderboardAggregationLocks/monthly_2026-07")
        .set({
          periodType: "monthly",
          periodKey: "2026-07",
          buildId: "already-running",
          status: "running",
          leaseExpiresAt: "2026-07-10T00:10:00.000Z",
        });
      const locked = await refreshMonthlyLeaderboardSnapshots(
        firestore,
        "2026-07",
        {
          now: new Date("2026-07-10T00:00:01.000Z"),
          buildId: "writer-build-b",
        },
      );
      assert.equal(locked.status, "skipped_locked");
      await firestore
        .doc("leaderboardAggregationLocks/monthly_2026-07")
        .delete();
      const completed = await refreshMonthlyLeaderboardSnapshots(
        firestore,
        "2026-07",
        {
          now: new Date("2026-07-10T00:00:02.000Z"),
          buildId: "writer-build-a",
        },
      );
      assert.equal(completed.status, "completed");

      const snapshot = await firestore
        .doc("leaderboardSnapshots/monthly_jurong-east_tier_01_2026-07")
        .get();
      assert.equal(snapshot.get("entryCount"), 15);
      assert.equal(snapshot.get("topEntries").length, 10);
      assert.equal(snapshot.get("entries"), undefined);
      const rank = await firestore
        .doc("leaderboardUserRanks/writer-runner-12_monthly_2026-07")
        .get();
      assert.equal(rank.get("nearbyEntries").length, 5);
      const currentView = await firestore
        .doc("leaderboardCurrentViews/writer-runner-12")
        .get();
      assert.equal(currentView.get("status"), "ranked");
      assert.equal(currentView.get("buildId"), snapshot.get("buildId"));
    });

    it("rolls prior participants into an unranked new monthly period", async () => {
      const uid = "rollover-runner";
      await Promise.all([
        firestore.doc(`users/${uid}`).set({ subscriptionStatus: "basic" }),
        firestore.doc(`userProfiles/${uid}`).set({
          nickname: "Rollover",
          locationLabel: "Tampines, Singapore",
          divisionKey: "tier_01",
          level: 1,
        }),
        firestore
          .doc(`leaderboardContributions/${uid}_monthly_2026-07`)
          .set(
            contribution({
              ownerUid: uid,
              regionId: "tampines",
              regionLabel: "Tampines",
              planningAreaName: "TAMPINES",
              planningAreaCode: "TM",
              planningRegionCode: "ER",
            }),
          ),
      ]);
      await refreshMonthlyLeaderboardSnapshots(firestore, "2026-07", {
        now: new Date("2026-07-20T00:00:00.000Z"),
        buildId: "rollover-july",
      });
      await clearCollections(firestore, ["leaderboardContributions"]);
      await refreshMonthlyLeaderboardSnapshots(firestore, "2026-08", {
        now: new Date("2026-08-01T00:00:00.000Z"),
        buildId: "rollover-august",
      });

      const currentView = await firestore
        .doc(`leaderboardCurrentViews/${uid}`)
        .get();
      assert.equal(currentView.get("periodKey"), "2026-08");
      assert.equal(currentView.get("homeRegionId"), "tampines");
      assert.equal(currentView.get("status"), "unranked");
      assert.equal(currentView.get("activeRankProjectionId"), null);
    });
  },
);

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
  };
}

async function clearCollections(
  firestore: Firestore,
  collectionNames: readonly string[],
): Promise<void> {
  for (const collectionName of collectionNames) {
    const snapshot = await firestore.collection(collectionName).get();
    if (snapshot.empty) {
      continue;
    }
    const batch = firestore.batch();
    for (const document of snapshot.docs) {
      batch.delete(document.ref);
    }
    await batch.commit();
  }
}
