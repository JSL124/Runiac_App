import type { ProgressionDisplay } from "../run/runCompletionTypes.js";

export function progressionReason(input: {
  readonly isPremium: boolean;
  readonly activityReason: "run_completion_xp_awarded" | "low_data_no_xp";
  readonly xpDeltaBeforeDailyCap: number;
  readonly xpDelta: number;
}): ProgressionDisplay["reason"] {
  if (input.isPremium) {
    return "premium_no_progression";
  }
  if (input.activityReason === "low_data_no_xp") {
    return "low_data_no_xp";
  }
  if (input.xpDeltaBeforeDailyCap > 0 && input.xpDelta === 0) {
    return "daily_cap_reached";
  }
  return "run_completion_xp_awarded";
}

export function readTotalXp(profileData: FirebaseFirestore.DocumentData | undefined): number {
  const totalXp = profileData?.["totalXp"];
  return typeof totalXp === "number" && Number.isInteger(totalXp) && totalXp > 0 ? totalXp : 0;
}

export function sumDailyXp(
  progressionEventDocuments: readonly FirebaseFirestore.DocumentData[],
  dailyCapDate: string,
): number {
  return progressionEventDocuments.reduce((total, eventData) => {
    const eventDailyCapDate = eventData["dailyCapDate"];
    const xpDelta = eventData["xpDelta"];
    if (eventDailyCapDate === dailyCapDate && typeof xpDelta === "number" && xpDelta > 0) {
      return total + xpDelta;
    }
    return total;
  }, 0);
}

export function sumMonthlyXp(
  progressionEventDocuments: readonly FirebaseFirestore.DocumentData[],
  monthlyPeriod: string,
): number {
  return progressionEventDocuments.reduce((total, eventData) => {
    const eventMonthlyPeriod = eventData["monthlyPeriod"];
    const xpDelta = eventData["xpDelta"];
    if (eventMonthlyPeriod === monthlyPeriod && typeof xpDelta === "number" && xpDelta > 0) {
      return total + xpDelta;
    }
    return total;
  }, 0);
}

export function formatXpLabel(xp: number): string {
  return `${xp.toLocaleString("en-US")} XP`;
}

export function isPremiumSubscription(
  data: FirebaseFirestore.DocumentData | undefined,
  nowMs: number,
): boolean {
  const subscriptionStatus = data?.["subscriptionStatus"];
  if (subscriptionStatus !== "premium" && subscriptionStatus !== "Premium") {
    return false;
  }
  const expiresAtMs = readSubscriptionExpiresAtMs(data?.["subscriptionExpiresAt"]);
  // Absent/unreadable expiry means "no expiry" so existing docs keep their
  // current always-premium behaviour; only a resolvable, past expiry lapses.
  return expiresAtMs === null || expiresAtMs > nowMs;
}

// `subscriptionExpiresAt` is contractually a Firestore Timestamp: the only
// writer is the admin console's setUserSubscription(), which stores
// Timestamp.fromDate().
//
// Reading other shapes here would be worse than useless, because the expiry
// sweep selects lapsed documents with a `<= Timestamp` range query and
// Firestore orders values by type before value (numbers < timestamps <
// strings). A millis number would therefore be selected by the range query
// even when it is in the future, and an ISO string would never be selected
// even after it lapses — so the in-request check and the sweep would disagree
// about exactly the documents that matter. Restricting both to Timestamp keeps
// them consistent by construction; any other shape is uniformly treated as
// "no expiry" here, by the sweep, and by firestore.rules alike.
function readSubscriptionExpiresAtMs(value: unknown): number | null {
  if (
    value !== null &&
    typeof value === "object" &&
    typeof (value as { toMillis?: unknown }).toMillis === "function"
  ) {
    const millis = (value as { toMillis: () => number }).toMillis();
    return typeof millis === "number" && Number.isFinite(millis) ? millis : null;
  }
  return null;
}
