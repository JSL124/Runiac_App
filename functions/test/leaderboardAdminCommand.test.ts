import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { createLeaderboardAdminCommandHandlers } from "../src/leaderboard/leaderboardAdminCommand.js";
import { currentSingaporeMonthKey } from "../src/leaderboard/monthlyLeaderboard.js";

// The handler derives the period itself and only ever accepts the current
// Singapore month, so these fixtures must track the real clock rather than
// hardcode a month that would silently stop matching after a rollover.
const periodKey = currentSingaporeMonthKey(new Date());

describe(
  "leaderboard admin command handler",
  { skip: process.env["FIRESTORE_EMULATOR_HOST"] === undefined },
  () => {
    let firestore: Firestore;
    let handlers: ReturnType<typeof createLeaderboardAdminCommandHandlers>;

    before(() => {
      if (getApps().length === 0) {
        initializeApp({ projectId: "runiac-functions-test" });
      }
      firestore = getFirestore();
      handlers = createLeaderboardAdminCommandHandlers({ firestore });
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
        "leaderboardAdminCommands",
        "config",
      ]);
    });

    it("runs a valid refresh command to completion with real counts", async () => {
      const uid = "admin-command-runner";
      await Promise.all([
        firestore.doc(`users/${uid}`).set({ subscriptionStatus: "basic" }),
        firestore.doc(`userProfiles/${uid}`).set({
          nickname: "Admin Command Runner",
          locationLabel: "Jurong East, Singapore",
          divisionKey: "tier_01",
          level: 1,
        }),
        firestore
          .doc(`leaderboardContributions/${uid}_monthly_${periodKey}`)
          .set(contribution(uid, periodKey)),
      ]);

      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "refresh",
        periodKey,
        requestedBy: "admin@runiac.test",
        status: "pending",
      };
      await ref.set(data);

      await handlers.onCommandCreated(ref.id, data);

      const after = await ref.get();
      assert.equal(after.get("status"), "completed");
      assert.equal(after.get("snapshotCount"), 1);
      assert.equal(after.get("rankCount"), 1);
      assert.equal(after.get("currentViewCount"), 1);
      assert.equal(typeof after.get("buildId"), "string");
      assert.equal(typeof after.get("completedAt"), "string");

      const snapshots = await firestore.collection("leaderboardSnapshots").get();
      assert.equal(snapshots.size, 1);
    });

    it("rejects an unsupported command without running the aggregation", async () => {
      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "wipe-everything",
        periodKey,
        requestedBy: "admin@runiac.test",
        status: "pending",
      };
      await ref.set(data);

      await handlers.onCommandCreated(ref.id, data);

      const after = await ref.get();
      assert.equal(after.get("status"), "rejected");
      assert.equal(typeof after.get("error"), "string");

      const snapshots = await firestore.collection("leaderboardSnapshots").get();
      assert.equal(snapshots.size, 0);
      const locks = await firestore.collection("leaderboardAggregationLocks").get();
      assert.equal(locks.size, 0);
    });

    it("rejects a malformed periodKey without running the aggregation", async () => {
      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "refresh",
        periodKey: "not-a-period",
        requestedBy: "admin@runiac.test",
        status: "pending",
      };
      await ref.set(data);

      await handlers.onCommandCreated(ref.id, data);

      const after = await ref.get();
      assert.equal(after.get("status"), "rejected");
      assert.equal(typeof after.get("error"), "string");

      const snapshots = await firestore.collection("leaderboardSnapshots").get();
      assert.equal(snapshots.size, 0);
    });

    // Regression: `refreshMonthlyLeaderboardSnapshots` repoints
    // `leaderboardPeriods/monthly_current` to whatever key it is given and
    // then deletes every projection outside the three-month window around
    // it. An older month would therefore both mislead the app and destroy
    // the live period's snapshots, so the handler must never forward one.
    it("rejects a past periodKey without touching live projections", async () => {
      const pastPeriodKey = `${Number(periodKey.slice(0, 4)) - 1}${periodKey.slice(4)}`;

      await seedLiveProjection(firestore, periodKey);

      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "refresh",
        periodKey: pastPeriodKey,
        requestedBy: "admin@runiac.test",
        status: "pending",
      };
      await ref.set(data);

      await handlers.onCommandCreated(ref.id, data);

      const after = await ref.get();
      assert.equal(after.get("status"), "rejected");

      // The live snapshot and the current-period pointer both survive.
      const snapshots = await firestore.collection("leaderboardSnapshots").get();
      assert.equal(snapshots.size, 1);
      const current = await firestore.doc("leaderboardPeriods/monthly_current").get();
      assert.equal(current.get("periodKey"), periodKey);
    });

    // Regression: "2026-13" satisfies a naive /^\d{4}-\d{2}$/ check but is
    // unparseable, which degrades `retainedPeriodKeys` to a single-key set
    // and would delete essentially every projection.
    it("rejects a syntactically valid but impossible month", async () => {
      const impossiblePeriodKey = `${periodKey.slice(0, 4)}-13`;

      await seedLiveProjection(firestore, periodKey);

      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "refresh",
        periodKey: impossiblePeriodKey,
        requestedBy: "admin@runiac.test",
        status: "pending",
      };
      await ref.set(data);

      await handlers.onCommandCreated(ref.id, data);

      const after = await ref.get();
      assert.equal(after.get("status"), "rejected");

      const snapshots = await firestore.collection("leaderboardSnapshots").get();
      assert.equal(snapshots.size, 1);
      const current = await firestore.doc("leaderboardPeriods/monthly_current").get();
      assert.equal(current.get("periodKey"), periodKey);
    });

    it("reports skipped_locked when an unexpired lease is already running", async () => {
      await firestore.doc(`leaderboardAggregationLocks/monthly_${periodKey}`).set({
        periodType: "monthly",
        periodKey,
        buildId: "already-running",
        status: "running",
        leaseExpiresAt: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
      });

      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "refresh",
        periodKey,
        requestedBy: "admin@runiac.test",
        status: "pending",
      };
      await ref.set(data);

      await handlers.onCommandCreated(ref.id, data);

      const after = await ref.get();
      assert.equal(after.get("status"), "skipped_locked");
      assert.equal(typeof after.get("completedAt"), "string");
    });
  },
);

function contribution(
  ownerUid: string,
  periodKey: string,
): Record<string, unknown> {
  return {
    schemaVersion: 2,
    ownerUid,
    publicAlias: `Runner ${ownerUid}`,
    regionId: "jurong-east",
    regionLabel: "Jurong East",
    planningAreaName: "JURONG EAST",
    planningAreaCode: "JE",
    planningRegionCode: "WR",
    divisionKey: "tier_01",
    divisionLabel: "Iron League",
    levelLabel: "Level 1",
    periodType: "monthly",
    periodKey,
    timezone: "Asia/Singapore",
    scoreXp: 100,
    eligible: true,
    eligibilityReason: "eligible_basic_awarded_xp",
    lastProgressionAt: `${periodKey}-10T00:00:00.000Z`,
    sourceProgressionEventIds: ["event-1"],
  };
}

// Stands in for a healthy live period: one published snapshot plus the
// current-period pointer the mobile app reads first. Both are what a
// wrongly-forwarded periodKey would destroy.
async function seedLiveProjection(
  firestore: Firestore,
  periodKey: string,
): Promise<void> {
  await Promise.all([
    firestore
      .doc(`leaderboardSnapshots/monthly_jurong-east_tier_01_${periodKey}`)
      .set({
        periodType: "monthly",
        periodKey,
        regionId: "jurong-east",
        divisionKey: "tier_01",
        entryCount: 1,
        topEntries: [],
      }),
    firestore.doc("leaderboardPeriods/monthly_current").set({
      periodType: "monthly",
      periodKey,
      timezone: "Asia/Singapore",
    }),
  ]);
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
