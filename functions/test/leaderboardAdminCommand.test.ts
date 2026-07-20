import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { createLeaderboardAdminCommandHandlers } from "../src/leaderboard/leaderboardAdminCommand.js";

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
          .doc(`leaderboardContributions/${uid}_monthly_2026-07`)
          .set(contribution(uid)),
      ]);

      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "refresh",
        periodKey: "2026-07",
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
        periodKey: "2026-07",
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

    it("reports skipped_locked when an unexpired lease is already running", async () => {
      await firestore.doc("leaderboardAggregationLocks/monthly_2026-07").set({
        periodType: "monthly",
        periodKey: "2026-07",
        buildId: "already-running",
        status: "running",
        leaseExpiresAt: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
      });

      const ref = firestore.collection("leaderboardAdminCommands").doc();
      const data = {
        command: "refresh",
        periodKey: "2026-07",
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

function contribution(ownerUid: string): Record<string, unknown> {
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
    periodKey: "2026-07",
    timezone: "Asia/Singapore",
    scoreXp: 100,
    eligible: true,
    eligibilityReason: "eligible_basic_awarded_xp",
    lastProgressionAt: "2026-07-10T00:00:00.000Z",
    sourceProgressionEventIds: ["event-1"],
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
