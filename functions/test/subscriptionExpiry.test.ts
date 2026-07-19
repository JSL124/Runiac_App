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

    // Regression: the sweep re-reads each candidate in a transaction, so a
    // renewal landing between the candidate query and the write must win. An
    // unconditional batch write would strip Premium from a user who just
    // renewed.
    //
    // The renewal is applied through the afterCandidateQuery hook, i.e. after
    // the query has already returned the stale lapsed snapshot. Renewing before
    // the call would leave the query empty and the test would pass even with
    // the re-check removed.
    it("does not downgrade a candidate renewed after the candidate query", async () => {
      const userRef = firestore.collection("users").doc("renewed-mid-sweep");
      await userRef.set({
        subscriptionStatus: "premium",
        subscriptionExpiresAt: Timestamp.fromMillis(pastMs),
      });

      let candidateWasStale = false;
      const result = await runSubscriptionExpirySweep(firestore, nowMs, {
        afterCandidateQuery: async () => {
          candidateWasStale = true;
          await userRef.set(
            { subscriptionExpiresAt: Timestamp.fromMillis(futureMs) },
            { merge: true },
          );
        },
      });

      // Guards the test itself: if the query stopped returning the candidate,
      // the assertions below would pass vacuously.
      assert.equal(candidateWasStale, true);
      assert.equal(result.expiredCount, 0);
      const stored = (await userRef.get()).data();
      assert.equal(stored?.["subscriptionStatus"], "premium");
      assert.equal(
        (stored?.["subscriptionExpiresAt"] as Timestamp).toMillis(),
        futureMs,
      );
      assert.equal((await firestore.collection("adminAuditLogs").get()).size, 0);
    });

    // Regression: an out-of-contract numeric expiry must not be selected at
    // all. Numbers sort below every Timestamp, so without the range's lower
    // bound these would fill the candidate window, be rejected by the
    // re-check, and starve genuinely lapsed subscriptions behind them on every
    // run.
    it("does not select expiries stored as millis numbers, so they cannot starve the window", async () => {
      await firestore.collection("users").doc("millis-future-expiry").set({
        subscriptionStatus: "premium",
        subscriptionExpiresAt: futureMs,
      });
      await firestore.collection("users").doc("millis-past-expiry").set({
        subscriptionStatus: "premium",
        subscriptionExpiresAt: pastMs,
      });
      // A genuinely lapsed Timestamp document sorted after both numeric ones.
      await firestore.collection("users").doc("real-lapsed").set({
        subscriptionStatus: "premium",
        subscriptionExpiresAt: Timestamp.fromMillis(pastMs),
      });

      const result = await runSubscriptionExpirySweep(firestore, nowMs);

      // Only the Timestamp-backed document is swept; the numeric ones are
      // untouched and did not consume a candidate slot.
      assert.equal(result.expiredCount, 1);
      assert.equal(
        (await firestore.collection("users").doc("real-lapsed").get()).data()?.[
          "subscriptionStatus"
        ],
        "basic",
      );
      for (const id of ["millis-future-expiry", "millis-past-expiry"]) {
        assert.equal(
          (await firestore.collection("users").doc(id).get()).data()?.[
            "subscriptionStatus"
          ],
          "premium",
        );
      }
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
