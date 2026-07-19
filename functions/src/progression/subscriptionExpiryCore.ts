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
const USER_PROFILES = "userProfiles";

// Upper bound on candidates examined per sweep; a daily cadence drains any
// backlog within a small number of runs while keeping one run bounded.
const SWEEP_QUERY_LIMIT = 200;

export type SubscriptionExpirySweepOptions = {
  // Test seam. Invoked once after the candidate query resolves and before any
  // downgrade transaction runs, which is the exact window in which an admin
  // renewal must be able to win.
  readonly afterCandidateQuery?: () => Promise<void>;
  // Test seam. Overrides SWEEP_QUERY_LIMIT so a starvation regression can fill
  // the candidate window with a handful of documents instead of 200.
  readonly candidateLimit?: number;
};

export type SubscriptionExpirySweepResult = {
  readonly expiredCount: number;
};

export async function runSubscriptionExpirySweep(
  firestore: Firestore,
  nowMs: number,
  options?: SubscriptionExpirySweepOptions,
): Promise<SubscriptionExpirySweepResult> {
  const nowTimestamp = Timestamp.fromMillis(nowMs);

  // A single upper bound is sufficient to restrict selection to Timestamps.
  // Firestore inequality filters are type-scoped: `<= <Timestamp>` matches only
  // Timestamp values, so out-of-contract numbers and ISO strings are not
  // returned at all — they can neither be downgraded nor occupy a candidate
  // slot. Verified against the emulator: with numeric, Timestamp and string
  // expiries all present, `orderBy` reports the documented cross-type ordering
  // (numbers < timestamps < strings) while `where("<=", Timestamp)` returns the
  // Timestamp document alone. An explicit lower bound to "pin the type" would
  // therefore be dead weight.
  const lapsed = await firestore
    .collection("users")
    .where("subscriptionStatus", "==", "premium")
    .where("subscriptionExpiresAt", "<=", nowTimestamp)
    .limit(options?.candidateLimit ?? SWEEP_QUERY_LIMIT)
    .get();

  if (lapsed.empty) {
    return { expiredCount: 0 };
  }

  if (options?.afterCandidateQuery !== undefined) {
    await options.afterCandidateQuery();
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

      // Entitlement is evaluated as users OR userProfiles — see
      // readOwnerFacts() and calculateProgressionAudit(). A mirrored
      // `userProfiles/{uid}.subscriptionStatus` (the leaderboard seed dataset
      // writes one) would therefore keep a lapsed user counted as premium even
      // after this sweep downgrades the user document, silently continuing to
      // suppress their XP and exclude them from leaderboards. Clearing the
      // mirror in the same transaction keeps both sides of that OR consistent;
      // the field is only touched when it is actually present, so profiles
      // without it are left alone.
      const profileRef = firestore.collection(USER_PROFILES).doc(candidate.id);
      const profileSnapshot = await transaction.get(profileRef);
      const profileData = profileSnapshot.data();
      const profileMirrorsPremium =
        profileData !== undefined &&
        profileData["subscriptionStatus"] !== undefined &&
        profileData["subscriptionStatus"] !== "basic";

      const before = {
        subscriptionStatus: data["subscriptionStatus"] ?? null,
        subscriptionExpiresAt: data["subscriptionExpiresAt"] ?? null,
        ...(profileMirrorsPremium
          ? { profileSubscriptionStatus: profileData["subscriptionStatus"] }
          : {}),
      };
      const after = {
        subscriptionStatus: "basic",
        subscriptionExpiresAt: null,
        ...(profileMirrorsPremium ? { profileSubscriptionStatus: "basic" } : {}),
      };

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

      if (profileMirrorsPremium) {
        transaction.set(
          profileRef,
          { subscriptionStatus: "basic" },
          { merge: true },
        );
      }

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
