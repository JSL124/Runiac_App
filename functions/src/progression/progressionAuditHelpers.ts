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

export function isPremiumSubscription(data: FirebaseFirestore.DocumentData | undefined): boolean {
  const subscriptionStatus = data?.["subscriptionStatus"];
  return subscriptionStatus === "premium" || subscriptionStatus === "Premium";
}
