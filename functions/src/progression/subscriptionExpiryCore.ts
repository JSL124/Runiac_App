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

import { isPremiumSubscription } from "./progressionAuditHelpers.js";

const ADMIN_AUDIT_LOGS = "adminAuditLogs";

// Upper bound on candidates examined per sweep; a daily cadence drains any
// backlog within a small number of runs while keeping one run bounded.
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

  // The query result is only a candidate list. Each downgrade is applied in its
  // own transaction that re-reads the document and re-asserts the predicate,
  // because an admin can renew or extend a subscription in the window between
  // the query above and the write. An unconditional batch write would silently
  // clobber that newer grant and strip Premium from a user who just paid for
  // it. Re-checking inside the transaction makes the downgrade conditional on
  // the document still being lapsed at commit time.
  //
  // The predicate is isPremiumSubscription() itself rather than a re-derived
  // expiry comparison, so the sweep can never drift from the in-request
  // entitlement check: "stored as premium, but no longer effectively premium"
  // is exactly what this job exists to materialise.
  let expiredCount = 0;

  for (const candidate of lapsed.docs) {
    const applied = await firestore.runTransaction(async (transaction) => {
      const fresh = await transaction.get(candidate.ref);
      const data = fresh.data();

      if (!fresh.exists || data === undefined) {
        return false;
      }

      if (data["subscriptionStatus"] !== "premium") {
        return false;
      }

      if (isPremiumSubscription(data, nowMs)) {
        return false;
      }

      const before = {
        subscriptionStatus: data["subscriptionStatus"] ?? null,
        subscriptionExpiresAt: data["subscriptionExpiresAt"] ?? null,
      };
      const after = { subscriptionStatus: "basic", subscriptionExpiresAt: null };

      transaction.set(
        candidate.ref,
        {
          subscriptionStatus: "basic",
          subscriptionExpiresAt: null,
          subscriptionUpdatedAt: nowTimestamp,
          subscriptionSource: "system-expiry",
        },
        { merge: true },
      );

      transaction.set(firestore.collection(ADMIN_AUDIT_LOGS).doc(), {
        actor: "system",
        action: "user.subscription.expire",
        targetType: "user",
        targetId: candidate.id,
        detail: `Premium subscription expired for user ${candidate.id}.`,
        changedFields: ["subscriptionStatus", "subscriptionExpiresAt"],
        before,
        after,
        createdAt: nowTimestamp,
      });

      return true;
    });

    if (applied) {
      expiredCount += 1;
    }
  }

  return { expiredCount };
}
