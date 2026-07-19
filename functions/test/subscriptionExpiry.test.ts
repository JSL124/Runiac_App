import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp, type Firestore } from "firebase-admin/firestore";
import { runSubscriptionExpirySweep } from "../src/progression/subscriptionExpiryCore.js";

describe(
  "runSubscriptionExpirySweep",
  { skip: process.env["FIRESTORE_EMULATOR_HOST"] === undefined },
  () => {
    let firestore: Firestore;
    const nowMs = Date.UTC(2026, 6, 13, 3, 0, 0);
    const pastMs = nowMs - 24 * 60 * 60 * 1000;
    const futureMs = nowMs + 24 * 60 * 60 * 1000;

    before(() => {
      if (getApps().length === 0) {
        initializeApp({ projectId: "runiac-functions-test" });
      }
      firestore = getFirestore();
    });

    beforeEach(async () => {
      await clearCollections(firestore, ["users", "adminAuditLogs"]);
    });

    it("downgrades exactly the lapsed premium docs and leaves others untouched", async () => {
      await Promise.all([
        firestore.doc("users/lapsed-premium").set({
          subscriptionStatus: "premium",
          subscriptionExpiresAt: Timestamp.fromMillis(pastMs),
        }),
        firestore.doc("users/current-premium").set({
          subscriptionStatus: "premium",
          subscriptionExpiresAt: Timestamp.fromMillis(futureMs),
        }),
        firestore.doc("users/lifetime-premium").set({
          subscriptionStatus: "premium",
        }),
        firestore.doc("users/already-basic").set({
          subscriptionStatus: "basic",
        }),
      ]);

      const result = await runSubscriptionExpirySweep(firestore, nowMs);

      assert.equal(result.expiredCount, 1);

      const [lapsed, current, lifetime, basic] = await Promise.all([
        firestore.doc("users/lapsed-premium").get(),
        firestore.doc("users/current-premium").get(),
        firestore.doc("users/lifetime-premium").get(),
        firestore.doc("users/already-basic").get(),
      ]);

      assert.equal(lapsed.data()?.["subscriptionStatus"], "basic");
      assert.equal(lapsed.data()?.["subscriptionExpiresAt"], null);
      assert.equal(lapsed.data()?.["subscriptionSource"], "system-expiry");
      assert.ok(lapsed.data()?.["subscriptionUpdatedAt"] instanceof Timestamp);

      assert.equal(current.data()?.["subscriptionStatus"], "premium");
      assert.equal(lifetime.data()?.["subscriptionStatus"], "premium");
      assert.equal(basic.data()?.["subscriptionStatus"], "basic");

      const auditSnapshot = await firestore.collection("adminAuditLogs").get();
      assert.equal(auditSnapshot.size, 1);
      const auditEntry = auditSnapshot.docs[0]?.data();
      assert.equal(auditEntry?.["actor"], "system");
      assert.equal(auditEntry?.["action"], "user.subscription.expire");
      assert.equal(auditEntry?.["targetType"], "user");
      assert.equal(auditEntry?.["targetId"], "lapsed-premium");
      assert.deepEqual(auditEntry?.["before"], {
        subscriptionStatus: "premium",
        subscriptionExpiresAt: Timestamp.fromMillis(pastMs),
      });
      assert.deepEqual(auditEntry?.["after"], {
        subscriptionStatus: "basic",
        subscriptionExpiresAt: null,
      });
    });

    it("is a no-op when no premium subscription has lapsed", async () => {
      await firestore.doc("users/current-premium").set({
        subscriptionStatus: "premium",
        subscriptionExpiresAt: Timestamp.fromMillis(futureMs),
      });

      const result = await runSubscriptionExpirySweep(firestore, nowMs);

      assert.equal(result.expiredCount, 0);
      const auditSnapshot = await firestore.collection("adminAuditLogs").get();
      assert.equal(auditSnapshot.size, 0);
    });
  },
);

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
