import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import {
  refreshMonthlyLeaderboardSnapshots,
  writeLeaderboardContribution,
} from "../src/leaderboard/monthlyLeaderboard.js";

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
        "config",
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

      await firestore.doc("leaderboardAggregationLocks/monthly_2026-07").set({
        periodType: "monthly",
        periodKey: "2026-07",
        buildId: "already-running",
        status: "running",
        leaseExpiresAt: "2026-07-10T00:10:00.000Z",
      });
      const locked = await refreshMonthlyLeaderboardSnapshots(firestore, "2026-07", {
        now: new Date("2026-07-10T00:00:01.000Z"),
        buildId: "writer-build-b",
      });
      assert.equal(locked.status, "skipped_locked");
      await firestore.doc("leaderboardAggregationLocks/monthly_2026-07").delete();
      const completed = await refreshMonthlyLeaderboardSnapshots(firestore, "2026-07", {
        now: new Date("2026-07-10T00:00:02.000Z"),
        buildId: "writer-build-a",
      });
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
        firestore.doc(`leaderboardContributions/${uid}_monthly_2026-07`).set(
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

      const currentView = await firestore.doc(`leaderboardCurrentViews/${uid}`).get();
      assert.equal(currentView.get("periodKey"), "2026-08");
      assert.equal(currentView.get("homeRegionId"), "tampines");
      assert.equal(currentView.get("status"), "unranked");
      assert.equal(currentView.get("activeRankProjectionId"), null);
    });

    // Premium parity: premium runners earn XP on the same terms as Basic
    // runners, so with no config document they rank on the same board.
    it("includes a premium user by default (config/leaderboard missing)", async () => {
      const uid = "premium-runner-default";
      await Promise.all([
        firestore.doc(`users/${uid}`).set({ subscriptionStatus: "premium" }),
        firestore.doc(`userProfiles/${uid}`).set({
          nickname: "Premium Default",
          locationLabel: "Jurong East, Singapore",
          divisionKey: "tier_01",
          level: 1,
        }),
        firestore
          .doc(`leaderboardContributions/${uid}_monthly_2026-07`)
          .set(contribution({ ownerUid: uid })),
      ]);
      await refreshMonthlyLeaderboardSnapshots(firestore, "2026-07", {
        now: new Date("2026-07-10T00:00:00.000Z"),
        buildId: "premium-default-build",
      });

      const currentView = await firestore
        .doc(`leaderboardCurrentViews/${uid}`)
        .get();
      assert.equal(currentView.get("status"), "ranked");
    });

    // Exclusion remains a supported configuration, just no longer the default.
    it("excludes a premium user when config/leaderboard.excludePremium is true", async () => {
      const uid = "premium-runner-excluded";
      await firestore.doc("config/leaderboard").set({ excludePremium: true });
      await Promise.all([
        firestore.doc(`users/${uid}`).set({ subscriptionStatus: "premium" }),
        firestore.doc(`userProfiles/${uid}`).set({
          nickname: "Premium Excluded",
          locationLabel: "Jurong East, Singapore",
          divisionKey: "tier_01",
          level: 1,
        }),
        firestore
          .doc(`leaderboardContributions/${uid}_monthly_2026-07`)
          .set(contribution({ ownerUid: uid })),
      ]);
      await refreshMonthlyLeaderboardSnapshots(firestore, "2026-07", {
        now: new Date("2026-07-10T00:00:00.000Z"),
        buildId: "premium-excluded-build",
      });

      const currentView = await firestore
        .doc(`leaderboardCurrentViews/${uid}`)
        .get();
      assert.equal(currentView.get("status"), "ineligible_premium");
      await firestore.doc("config/leaderboard").delete();
    });

    it("writes qualifyingRunCount as an absolute value, never an increment", async () => {
      const uid = "absolute-count-runner";
      const contributionRef = firestore.doc(
        `leaderboardContributions/${uid}_monthly_2026-07`,
      );

      // Seed a stored count of 3, as if a prior write already recomputed it.
      await firestore.runTransaction(async (transaction) => {
        writeLeaderboardContribution({
          transaction,
          firestore,
          uid,
          progressionEventId: "progression-absolute-count-1",
          completedAt: "2026-07-10T00:00:00.000Z",
          periodKey: "2026-07",
          scoreXp: 50,
          divisionKey: "tier_01",
          divisionLabel: "Iron League",
          levelLabel: "Level 1",
          profileData: {
            nickname: "Absolute Count",
            locationLabel: "Jurong East, Singapore",
          },
          existingContributionData: undefined,
          qualifyingRunCount: 3,
        });
      });
      const afterFirst = await contributionRef.get();
      assert.equal(afterFirst.get("qualifyingRunCount"), 3);

      // A later recompute of 7 must land as 7, not 3 + 7 = 10. This is the
      // exact regression `FieldValue.increment` would have reintroduced.
      await firestore.runTransaction(async (transaction) => {
        writeLeaderboardContribution({
          transaction,
          firestore,
          uid,
          progressionEventId: "progression-absolute-count-2",
          completedAt: "2026-07-11T00:00:00.000Z",
          periodKey: "2026-07",
          scoreXp: 50,
          divisionKey: "tier_01",
          divisionLabel: "Iron League",
          levelLabel: "Level 1",
          profileData: {
            nickname: "Absolute Count",
            locationLabel: "Jurong East, Singapore",
          },
          existingContributionData: afterFirst.data(),
          qualifyingRunCount: 7,
        });
      });
      const afterSecond = await contributionRef.get();
      assert.equal(afterSecond.get("qualifyingRunCount"), 7);

      // A `null` qualifyingRunCount (completeCoolDown's contract) must leave
      // the previously-recomputed value untouched.
      await firestore.runTransaction(async (transaction) => {
        writeLeaderboardContribution({
          transaction,
          firestore,
          uid,
          progressionEventId: "progression-absolute-count-3",
          completedAt: "2026-07-12T00:00:00.000Z",
          periodKey: "2026-07",
          scoreXp: 50,
          divisionKey: "tier_01",
          divisionLabel: "Iron League",
          levelLabel: "Level 1",
          profileData: {
            nickname: "Absolute Count",
            locationLabel: "Jurong East, Singapore",
          },
          existingContributionData: afterSecond.data(),
          qualifyingRunCount: null,
        });
      });
      const afterCoolDown = await contributionRef.get();
      assert.equal(afterCoolDown.get("qualifyingRunCount"), 7);
    });

    it("leaves qualifyingRunCount unset when a first write passes null", async () => {
      const uid = "null-first-write-runner";
      const contributionRef = firestore.doc(
        `leaderboardContributions/${uid}_monthly_2026-07`,
      );

      await firestore.runTransaction(async (transaction) => {
        writeLeaderboardContribution({
          transaction,
          firestore,
          uid,
          progressionEventId: "progression-null-first-write",
          completedAt: "2026-07-10T00:00:00.000Z",
          periodKey: "2026-07",
          scoreXp: 50,
          divisionKey: "tier_01",
          divisionLabel: "Iron League",
          levelLabel: "Level 1",
          profileData: {
            nickname: "Null First Write",
            locationLabel: "Jurong East, Singapore",
          },
          existingContributionData: undefined,
          qualifyingRunCount: null,
        });
      });
      const afterWrite = await contributionRef.get();
      assert.equal(afterWrite.get("qualifyingRunCount"), undefined);
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
