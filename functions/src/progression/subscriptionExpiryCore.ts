// Premium subscription expiry sweep.
//
// `subscriptionStatus: "premium"` is otherwise permanent once an admin grants
// it: there is no expiry/renewal concept without this sweep. The client-facing
// gate, firestore.rules `isPremiumUser()`, can only compare the stored
// `subscriptionStatus` — it cannot evaluate an expiry instant — so the
// downgrade to `basic` has to be materialised here rather than derived on
// read. This mirrors `isPremiumSubscription()` in `progressionAuditHelpers.ts`,
// which treats a past `subscriptionExpiresAt` as "not premium" for in-request
// XP/leaderboard checks; this sweep is what keeps the stored document
// consistent with that in-request evaluation over time.
//
// Every downgrade appends an `adminAuditLogs` entry (actor "system") so the
// change is traceable the same way admin-driven subscription changes are
// (see website `setUserSubscription` / `appendAuditLog`).

import { Timestamp, type Firestore } from "firebase-admin/firestore";

// Upper bound per sweep query/commit; a daily cadence drains any backlog
// within a small number of runs without risking an oversized batch commit.
const SWEEP_QUERY_LIMIT = 200;

export type SubscriptionExpirySweepResult = {
  readonly expiredCount: number;
};

export async function runSubscriptionExpirySweep(
  firestore: Firestore,
  nowMs: number,
): Promise<SubscriptionExpirySweepResult> {
  const nowTimestamp = Timestamp.fromMillis(nowMs);
  const lapsed = await firestore
    .collection("users")
    .where("subscriptionStatus", "==", "premium")
    .where("subscriptionExpiresAt", "<=", nowTimestamp)
    .limit(SWEEP_QUERY_LIMIT)
    .get();

  if (lapsed.empty) {
    return { expiredCount: 0 };
  }

  const batch = firestore.batch();
  for (const userSnapshot of lapsed.docs) {
    const before = {
      subscriptionStatus: userSnapshot.data()["subscriptionStatus"] ?? null,
      subscriptionExpiresAt: userSnapshot.data()["subscriptionExpiresAt"] ?? null,
    };
    const after = { subscriptionStatus: "basic", subscriptionExpiresAt: null };

    batch.set(
      userSnapshot.ref,
      {
        subscriptionStatus: "basic",
        subscriptionExpiresAt: null,
        subscriptionUpdatedAt: nowTimestamp,
        subscriptionSource: "system-expiry",
      },
      { merge: true },
    );

    batch.set(firestore.collection("adminAuditLogs").doc(), {
      actor: "system",
      action: "user.subscription.expire",
      targetType: "user",
      targetId: userSnapshot.id,
      detail: `Premium subscription expired for user ${userSnapshot.id}.`,
      changedFields: ["subscriptionStatus", "subscriptionExpiresAt"],
      before,
      after,
      createdAt: nowTimestamp,
    });
  }
  await batch.commit();

  return { expiredCount: lapsed.docs.length };
}
