import { FieldValue, type Firestore, type Transaction } from "firebase-admin/firestore";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

if (getApps().length === 0) {
  initializeApp();
}

export const leaderboardTimezone = "Asia/Singapore";
export const defaultLeaderboardRegionId = "sg";
export const defaultLeaderboardRegionLabel = "Singapore";

export type LeaderboardContributionDocument = {
  readonly ownerUid: string;
  readonly displayName: string;
  readonly regionId: string;
  readonly regionLabel: string;
  readonly divisionKey: string;
  readonly divisionLabel: string;
  readonly levelLabel: string;
  readonly periodType: "monthly";
  readonly periodKey: string;
  readonly timezone: typeof leaderboardTimezone;
  readonly scoreXp: number;
  readonly eligible: boolean;
  readonly eligibilityReason: string;
  readonly lastProgressionAt: string;
  readonly sourceProgressionEventIds: readonly string[];
};

export type LeaderboardSnapshotEntry = {
  readonly userId: string;
  readonly displayName: string;
  readonly rankLabel: string;
  readonly scoreLabel: string;
  readonly levelLabel: string;
  readonly divisionLabel: string;
  readonly regionLabel: string;
  readonly score: number;
};

export type MonthlyLeaderboardPlan = {
  readonly snapshotId: string;
  readonly periodKey: string;
  readonly regionId: string;
  readonly divisionKey: string;
  readonly regionLabel: string;
  readonly divisionLabel: string;
  readonly entries: readonly LeaderboardSnapshotEntry[];
  readonly ranks: readonly MonthlyLeaderboardRankWrite[];
  readonly currentViews: readonly MonthlyLeaderboardCurrentViewWrite[];
};

export type MonthlyLeaderboardRankWrite = {
  readonly rankId: string;
  readonly uid: string;
  readonly rankLabel: string;
  readonly score: number;
  readonly snapshotId: string;
  readonly periodKey: string;
  readonly regionId: string;
  readonly divisionKey: string;
};

export type MonthlyLeaderboardCurrentViewWrite = {
  readonly uid: string;
  readonly snapshotId: string;
  readonly rankId: string;
  readonly periodKey: string;
  readonly regionId: string;
  readonly divisionKey: string;
};

export const refreshLeaderboardSnapshots = onSchedule(
  {
    schedule: "every 60 minutes",
    region: "asia-southeast1",
    timeZone: leaderboardTimezone,
  },
  async () => {
    await refreshMonthlyLeaderboardSnapshots(getFirestore(), currentSingaporeMonthKey(new Date()));
  },
);

export async function refreshMonthlyLeaderboardSnapshots(
  firestore: Firestore,
  periodKey: string,
): Promise<void> {
  const events = await firestore
    .collection("leaderboardContributions")
    .where("periodKey", "==", periodKey)
    .where("eligible", "==", true)
    .get();
  const plan = planMonthlyLeaderboard({
    periodKey,
    contributions: events.docs.map((document) => document.data()),
  });

  await firestore.runTransaction(async (transaction) => {
    writeMonthlyLeaderboardPlan(transaction, firestore, plan);
  });
}

export function writeMonthlyLeaderboardPlan(
  transaction: Transaction,
  firestore: Firestore,
  plan: MonthlyLeaderboardPlan,
): void {
  const snapshotRef = firestore.collection("leaderboardSnapshots").doc(plan.snapshotId);
  const lockRef = firestore.collection("leaderboardAggregationLocks").doc(plan.snapshotId);
  const generatedAt = new Date().toISOString();
  const refreshesAt = nextSingaporeMonthStart(plan.periodKey);

  transaction.set(snapshotRef, {
    periodType: "monthly",
    periodKey: plan.periodKey,
    timezone: leaderboardTimezone,
    regionId: plan.regionId,
    divisionKey: plan.divisionKey,
    regionLabel: plan.regionLabel,
    divisionLabel: plan.divisionLabel,
    generatedAt,
    refreshesAt,
    aggregationStatus: "ready",
    entryCount: plan.entries.length,
    topEntries: plan.entries.slice(0, 100),
    entries: plan.entries,
    updatedAt: generatedAt,
  });
  transaction.set(lockRef, {
    buildId: `${plan.snapshotId}_${generatedAt}`,
    snapshotId: plan.snapshotId,
    periodKey: plan.periodKey,
    regionId: plan.regionId,
    divisionKey: plan.divisionKey,
    status: "completed",
    startedAt: generatedAt,
    completedAt: generatedAt,
    updatedAt: generatedAt,
  });

  for (const rank of plan.ranks) {
    transaction.set(firestore.collection("leaderboardUserRanks").doc(rank.rankId), {
      ownerUid: rank.uid,
      uid: rank.uid,
      rankLabel: rank.rankLabel,
      score: rank.score,
      snapshotId: rank.snapshotId,
      periodType: "monthly",
      periodKey: rank.periodKey,
      timezone: leaderboardTimezone,
      regionId: rank.regionId,
      divisionKey: rank.divisionKey,
      generatedAt,
    });
  }
  for (const currentView of plan.currentViews) {
    transaction.set(firestore.collection("leaderboardCurrentViews").doc(currentView.uid), {
      ownerUid: currentView.uid,
      activeSnapshotId: currentView.snapshotId,
      activeRankProjectionId: currentView.rankId,
      snapshotId: currentView.snapshotId,
      rankId: currentView.rankId,
      periodType: "monthly",
      periodKey: currentView.periodKey,
      timezone: leaderboardTimezone,
      regionId: currentView.regionId,
      divisionKey: currentView.divisionKey,
      refreshesAt,
      generatedAt,
      aggregationStatus: "ready",
    });
  }
}

export function planMonthlyLeaderboard(input: {
  readonly periodKey: string;
  readonly contributions: readonly FirebaseFirestore.DocumentData[];
}): MonthlyLeaderboardPlan {
  const totals = new Map<string, LeaderboardContributionDocument>();
  for (const rawContribution of input.contributions) {
    const contribution = parseContribution(rawContribution, input.periodKey);
    if (contribution === null) {
      continue;
    }
    const existing = totals.get(contribution.ownerUid);
    totals.set(contribution.ownerUid, {
      ...contribution,
      scoreXp: (existing?.scoreXp ?? 0) + contribution.scoreXp,
      displayName: existing?.displayName ?? contribution.displayName,
      regionId: existing?.regionId ?? contribution.regionId,
      regionLabel: existing?.regionLabel ?? contribution.regionLabel,
      divisionKey: existing?.divisionKey ?? contribution.divisionKey,
      divisionLabel: existing?.divisionLabel ?? contribution.divisionLabel,
      levelLabel: existing?.levelLabel ?? contribution.levelLabel,
    });
  }

  const sortedContributions = [...totals.values()].sort(compareContributions);
  const firstContribution = sortedContributions[0];
  const entries = sortedContributions.map((contribution, index) =>
    snapshotEntry(contribution, index + 1),
  );
  const regionId = firstContribution?.regionId ?? defaultLeaderboardRegionId;
  const divisionKey = firstContribution?.divisionKey ?? "tier_01";
  const regionLabel = entries[0]?.regionLabel ?? defaultLeaderboardRegionLabel;
  const divisionLabel = entries[0]?.divisionLabel ?? "Trailborn League";
  const snapshotId = `monthly_${regionId}_${divisionKey}_${input.periodKey}`;

  return {
    snapshotId,
    periodKey: input.periodKey,
    regionId,
    divisionKey,
    regionLabel,
    divisionLabel,
    entries,
    ranks: entries.map((entry) => ({
      rankId: `${entry.userId}_monthly_${regionId}_${divisionKey}_${input.periodKey}`,
      uid: entry.userId,
      rankLabel: entry.rankLabel,
      score: entry.score,
      snapshotId,
      periodKey: input.periodKey,
      regionId,
      divisionKey,
    })),
    currentViews: entries.map((entry) => ({
      uid: entry.userId,
      snapshotId,
      rankId: `${entry.userId}_monthly_${regionId}_${divisionKey}_${input.periodKey}`,
      periodKey: input.periodKey,
      regionId,
      divisionKey,
    })),
  };
}

export function writeLeaderboardContribution(input: {
  readonly transaction: Transaction;
  readonly firestore: Firestore;
  readonly uid: string;
  readonly progressionEventId: string;
  readonly completedAt: string;
  readonly periodKey: string;
  readonly scoreXp: number;
  readonly divisionKey: string;
  readonly divisionLabel: string;
  readonly levelLabel: string;
  readonly profileData: FirebaseFirestore.DocumentData | undefined;
}): void {
  const contribution = leaderboardContributionFields(input);
  if (!contribution.eligible) {
    return;
  }

  input.transaction.set(
    input.firestore.collection("leaderboardContributions").doc(contributionId(contribution)),
    {
      ...contribution,
      scoreXp: FieldValue.increment(contribution.scoreXp),
      sourceProgressionEventIds: FieldValue.arrayUnion(input.progressionEventId),
    },
    { merge: true },
  );
}

export function leaderboardContributionFields(input: {
  readonly uid: string;
  readonly progressionEventId: string;
  readonly completedAt: string;
  readonly periodKey: string;
  readonly scoreXp: number;
  readonly divisionKey: string;
  readonly divisionLabel: string;
  readonly levelLabel: string;
  readonly profileData: FirebaseFirestore.DocumentData | undefined;
}): LeaderboardContributionDocument {
  return {
    ownerUid: input.uid,
    displayName: displayNameFromProfile(input.profileData),
    regionId: defaultLeaderboardRegionId,
    regionLabel: defaultLeaderboardRegionLabel,
    divisionKey: input.divisionKey,
    divisionLabel: input.divisionLabel,
    levelLabel: input.levelLabel,
    periodType: "monthly",
    periodKey: input.periodKey,
    timezone: leaderboardTimezone,
    scoreXp: input.scoreXp,
    eligible: input.scoreXp > 0,
    eligibilityReason: input.scoreXp > 0 ? "eligible_basic_awarded_xp" : "not_awarded",
    lastProgressionAt: input.completedAt,
    sourceProgressionEventIds: [input.progressionEventId],
  };
}

export function currentSingaporeMonthKey(now: Date): string {
  const singaporeTime = new Date(now.getTime() + 8 * 60 * 60 * 1000);
  return singaporeTime.toISOString().slice(0, 7);
}

export function nextSingaporeMonthStart(periodKey: string): string {
  const [yearText, monthText] = periodKey.split("-");
  const year = Number(yearText);
  const month = Number(monthText);
  if (!Number.isInteger(year) || !Number.isInteger(month) || month < 1 || month > 12) {
    return "";
  }
  const nextMonthUtc = new Date(Date.UTC(year, month, 0, 16, 0, 0, 0));
  return nextMonthUtc.toISOString();
}

function parseContribution(
  contribution: FirebaseFirestore.DocumentData,
  periodKey: string,
): LeaderboardContributionDocument | null {
  const ownerUid = contribution["ownerUid"];
  const contributionPeriodKey = contribution["periodKey"];
  const scoreXp = contribution["scoreXp"];
  if (
    typeof ownerUid !== "string" ||
    ownerUid.length === 0 ||
    contributionPeriodKey !== periodKey ||
    typeof scoreXp !== "number" ||
    !Number.isFinite(scoreXp) ||
    scoreXp <= 0 ||
    contribution["periodType"] !== "monthly" ||
    contribution["eligible"] !== true
  ) {
    return null;
  }

  return {
    ownerUid,
    periodType: "monthly",
    periodKey,
    timezone: leaderboardTimezone,
    scoreXp: Math.floor(scoreXp),
    eligible: true,
    eligibilityReason: readString(contribution["eligibilityReason"], "eligible_basic_awarded_xp"),
    lastProgressionAt: readString(contribution["lastProgressionAt"], ""),
    sourceProgressionEventIds: readStringArray(contribution["sourceProgressionEventIds"]),
    displayName: readString(contribution["displayName"], "Runiac Runner"),
    regionId: readString(contribution["regionId"], defaultLeaderboardRegionId),
    regionLabel: readString(contribution["regionLabel"], defaultLeaderboardRegionLabel),
    divisionKey: readString(contribution["divisionKey"], "tier_01"),
    divisionLabel: readString(contribution["divisionLabel"], "Trailborn League"),
    levelLabel: readString(contribution["levelLabel"], ""),
  };
}

function snapshotEntry(
  contribution: LeaderboardContributionDocument,
  rank: number,
): LeaderboardSnapshotEntry {
  return {
    userId: contribution.ownerUid,
    displayName: contribution.displayName,
    rankLabel: `#${rank}`,
    scoreLabel: `${contribution.scoreXp.toLocaleString("en-US")} XP`,
    levelLabel: contribution.levelLabel,
    divisionLabel: contribution.divisionLabel,
    regionLabel: contribution.regionLabel,
    score: contribution.scoreXp,
  };
}

function compareContributions(
  left: LeaderboardContributionDocument,
  right: LeaderboardContributionDocument,
): number {
  if (left.scoreXp !== right.scoreXp) {
    return right.scoreXp - left.scoreXp;
  }
  return left.ownerUid.localeCompare(right.ownerUid);
}

function readString(value: unknown, fallback: string): string {
  return typeof value === "string" && value.length > 0 ? value : fallback;
}

function readStringArray(value: unknown): readonly string[] {
  if (!Array.isArray(value)) {
    return emptyStringList;
  }
  return value.filter((item): item is string => typeof item === "string");
}

function displayNameFromProfile(
  profileData: FirebaseFirestore.DocumentData | undefined,
): string {
  return readString(profileData?.["displayName"], "Runiac Runner");
}

function contributionId(contribution: LeaderboardContributionDocument): string {
  return `${contribution.ownerUid}_monthly_${contribution.regionId}_${contribution.divisionKey}_${contribution.periodKey}`;
}

const emptyStringList: readonly string[] = [];
