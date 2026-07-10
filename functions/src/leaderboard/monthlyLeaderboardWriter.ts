import {
  type DocumentReference,
  type Firestore,
} from "firebase-admin/firestore";
import { isPremiumSubscription } from "../progression/progressionAuditHelpers.js";
import {
  leaderboardLeagueForKey,
  leaderboardLeagueForLevel,
} from "../progression/leaderboardLeagues.js";
import { singaporePlanningAreaForLocationLabel } from "./singaporePlanningAreas.js";
import {
  monthlyLeaderboardSnapshotId,
  planMonthlyLeaderboards,
} from "./monthlyLeaderboardPlanner.js";
import {
  leaderboardTimezone,
  type MonthlyLeaderboardCurrentViewPlan,
} from "./leaderboardTypes.js";

const leaseDurationMs = 15 * 60 * 1000;
const maxBatchOperations = 400;
const profileReadChunkSize = 250;

export type RefreshMonthlyLeaderboardResult = {
  readonly status: "completed" | "skipped_locked";
  readonly buildId: string;
  readonly periodKey: string;
  readonly snapshotCount: number;
  readonly rankCount: number;
  readonly currentViewCount: number;
};

export async function refreshMonthlyLeaderboardSnapshots(
  firestore: Firestore,
  periodKey: string,
  options: {
    readonly now?: Date;
    readonly buildId?: string;
  } = {},
): Promise<RefreshMonthlyLeaderboardResult> {
  const now = options.now ?? new Date();
  const generatedAt = now.toISOString();
  const buildId =
    options.buildId ??
    `monthly_${periodKey}_${generatedAt.replaceAll(/[^0-9]/g, "")}`;
  const lockRef = firestore
    .collection("leaderboardAggregationLocks")
    .doc(`monthly_${periodKey}`);
  const claimed = await claimLease({
    firestore,
    lockRef,
    periodKey,
    buildId,
    now,
  });
  if (!claimed) {
    return {
      status: "skipped_locked",
      buildId,
      periodKey,
      snapshotCount: 0,
      rankCount: 0,
      currentViewCount: 0,
    };
  }

  try {
    const [contributionSnapshot, currentPeriodSnapshot] = await Promise.all([
      firestore
        .collection("leaderboardContributions")
        .where("periodKey", "==", periodKey)
        .get(),
      firestore.collection("leaderboardPeriods").doc("monthly_current").get(),
    ]);
    const previousPeriodKey = readString(
      currentPeriodSnapshot.data()?.["periodKey"],
    );
    const rolloverViews =
      previousPeriodKey !== null && previousPeriodKey !== periodKey
        ? await firestore.collection("leaderboardCurrentViews").get()
        : null;
    const ownerUids = new Set<string>();
    for (const contribution of contributionSnapshot.docs) {
      const ownerUid = readString(contribution.data()["ownerUid"]);
      if (ownerUid !== null) {
        ownerUids.add(ownerUid);
      }
    }
    if (rolloverViews !== null) {
      for (const view of rolloverViews.docs) {
        ownerUids.add(view.id);
      }
    }
    const ownerFacts = await readOwnerFacts(firestore, ownerUids);
    const premiumUids = new Set(
      [...ownerFacts.entries()]
        .filter(([, facts]) => facts.isPremium)
        .map(([uid]) => uid),
    );
    const plan = planMonthlyLeaderboards({
      periodKey,
      contributions: contributionSnapshot.docs.map((document) =>
        document.data(),
      ),
      currentPremiumUids: premiumUids,
    });
    const currentViews = mergeRolloverViews({
      periodKey,
      plannedViews: plan.currentViews,
      rolloverUids:
        rolloverViews?.docs.map((document) => document.id) ?? emptyStringList,
      ownerFacts,
    });

    const refreshesAt = nextSingaporeMonthStart(periodKey);
    const expectedSnapshotIds = new Set(
      plan.snapshots.map((snapshot) => snapshot.snapshotId),
    );
    const expectedRankIds = new Set(plan.ranks.map((rank) => rank.rankId));
    const [existingSnapshots, existingRanks] = await Promise.all([
      firestore
        .collection("leaderboardSnapshots")
        .where("periodKey", "==", periodKey)
        .get(),
      firestore
        .collection("leaderboardUserRanks")
        .where("periodKey", "==", periodKey)
        .get(),
    ]);
    const projectionOperations: WriteOperation[] = [];
    for (const snapshot of plan.snapshots) {
      projectionOperations.push({
        kind: "set",
        ref: firestore
          .collection("leaderboardSnapshots")
          .doc(snapshot.snapshotId),
        data: {
          periodType: "monthly",
          periodKey,
          periodLabel: singaporeMonthLabel(periodKey),
          timezone: leaderboardTimezone,
          regionId: snapshot.regionId,
          divisionKey: snapshot.divisionKey,
          regionLabel: snapshot.regionLabel,
          divisionLabel: snapshot.divisionLabel,
          buildId,
          generatedAt,
          refreshesAt,
          aggregationStatus: "ready",
          entryCount: snapshot.entryCount,
          topEntries: snapshot.topEntries,
          updatedAt: generatedAt,
        },
      });
    }
    for (const rank of plan.ranks) {
      projectionOperations.push({
        kind: "set",
        ref: firestore.collection("leaderboardUserRanks").doc(rank.rankId),
        data: {
          ownerUid: rank.ownerUid,
          periodType: "monthly",
          periodKey,
          periodLabel: singaporeMonthLabel(periodKey),
          timezone: leaderboardTimezone,
          snapshotId: rank.snapshotId,
          regionId: rank.regionId,
          divisionKey: rank.divisionKey,
          rankLabel: rank.rankLabel,
          score: rank.score,
          currentEntry: rank.currentEntry,
          nearbyEntries: rank.nearbyEntries,
          buildId,
          generatedAt,
          updatedAt: generatedAt,
        },
      });
    }
    for (const document of existingSnapshots.docs) {
      if (!expectedSnapshotIds.has(document.id)) {
        projectionOperations.push({ kind: "delete", ref: document.ref });
      }
    }
    for (const document of existingRanks.docs) {
      if (!expectedRankIds.has(document.id)) {
        projectionOperations.push({ kind: "delete", ref: document.ref });
      }
    }
    projectionOperations.push({
      kind: "set",
      ref: firestore.collection("leaderboardPeriods").doc("monthly_current"),
      data: {
        periodType: "monthly",
        periodKey,
        periodLabel: singaporeMonthLabel(periodKey),
        timezone: leaderboardTimezone,
        refreshesAt,
        buildId,
        generatedAt,
        aggregationStatus: "ready",
        updatedAt: generatedAt,
      },
    });
    await commitOperations(firestore, projectionOperations);
    await cleanupExpiredProjections(firestore, retainedPeriodKeys(periodKey));

    const currentViewOperations: WriteOperation[] = currentViews.map((view) => ({
      kind: "set",
      ref: firestore.collection("leaderboardCurrentViews").doc(view.ownerUid),
      data: {
        ownerUid: view.ownerUid,
        activeSnapshotId: view.snapshotId,
        activeRankProjectionId: view.rankId,
        snapshotId: view.snapshotId,
        rankId: view.rankId,
        periodType: "monthly",
        periodKey,
        periodLabel: singaporeMonthLabel(periodKey),
        timezone: leaderboardTimezone,
        homeRegionId: view.regionId,
        regionId: view.regionId,
        divisionKey: view.divisionKey,
        status: view.status,
        refreshesAt,
        buildId,
        generatedAt,
        aggregationStatus: "ready",
        updatedAt: generatedAt,
      },
    }));
    await commitOperations(firestore, currentViewOperations);
    await lockRef.set(
      {
        periodType: "monthly",
        periodKey,
        buildId,
        status: "completed",
        leaseExpiresAt: generatedAt,
        completedAt: generatedAt,
        updatedAt: generatedAt,
      },
      { merge: true },
    );
    return {
      status: "completed",
      buildId,
      periodKey,
      snapshotCount: plan.snapshots.length,
      rankCount: plan.ranks.length,
      currentViewCount: currentViews.length,
    };
  } catch (error) {
    await lockRef.set(
      {
        periodType: "monthly",
        periodKey,
        buildId,
        status: "failed",
        failedAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      { merge: true },
    );
    throw error;
  }
}

async function claimLease(input: {
  readonly firestore: Firestore;
  readonly lockRef: DocumentReference;
  readonly periodKey: string;
  readonly buildId: string;
  readonly now: Date;
}): Promise<boolean> {
  return input.firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(input.lockRef);
    const data = snapshot.data();
    const leaseExpiresAt = readDate(data?.["leaseExpiresAt"]);
    if (
      data?.["status"] === "running" &&
      leaseExpiresAt !== null &&
      leaseExpiresAt.getTime() > input.now.getTime()
    ) {
      return false;
    }
    const startedAt = input.now.toISOString();
    transaction.set(input.lockRef, {
      periodType: "monthly",
      periodKey: input.periodKey,
      buildId: input.buildId,
      status: "running",
      startedAt,
      leaseExpiresAt: new Date(
        input.now.getTime() + leaseDurationMs,
      ).toISOString(),
      updatedAt: startedAt,
    });
    return true;
  });
}

type OwnerFacts = {
  readonly isPremium: boolean;
  readonly profile: FirebaseFirestore.DocumentData | undefined;
};

async function readOwnerFacts(
  firestore: Firestore,
  ownerUids: ReadonlySet<string>,
): Promise<ReadonlyMap<string, OwnerFacts>> {
  const result = new Map<string, OwnerFacts>();
  const uids = [...ownerUids];
  for (let index = 0; index < uids.length; index += profileReadChunkSize) {
    const chunk = uids.slice(index, index + profileReadChunkSize);
    const refs = chunk.flatMap((uid) => [
      firestore.collection("users").doc(uid),
      firestore.collection("userProfiles").doc(uid),
    ]);
    const snapshots = refs.length === 0 ? [] : await firestore.getAll(...refs);
    for (let offset = 0; offset < chunk.length; offset += 1) {
      const uid = chunk[offset];
      if (uid === undefined) {
        continue;
      }
      const userData = snapshots[offset * 2]?.data();
      const profileData = snapshots[offset * 2 + 1]?.data();
      result.set(uid, {
        isPremium:
          isPremiumSubscription(userData) ||
          isPremiumSubscription(profileData),
        profile: profileData,
      });
    }
  }
  return result;
}

function mergeRolloverViews(input: {
  readonly periodKey: string;
  readonly plannedViews: readonly MonthlyLeaderboardCurrentViewPlan[];
  readonly rolloverUids: readonly string[];
  readonly ownerFacts: ReadonlyMap<string, OwnerFacts>;
}): MonthlyLeaderboardCurrentViewPlan[] {
  const views = new Map(
    input.plannedViews.map((view) => [view.ownerUid, view]),
  );
  for (const uid of input.rolloverUids) {
    if (views.has(uid)) {
      continue;
    }
    const facts = input.ownerFacts.get(uid);
    const area = singaporePlanningAreaForLocationLabel(
      facts?.profile?.["locationLabel"],
    );
    const league =
      leaderboardLeagueForKey(facts?.profile?.["divisionKey"]) ??
      leaderboardLeagueForLevel(readLevel(facts?.profile?.["level"]));
    const status = facts?.isPremium
      ? "ineligible_premium"
      : area === null
        ? "region_required"
        : "unranked";
    views.set(uid, {
      ownerUid: uid,
      snapshotId:
        area === null
          ? null
          : monthlyLeaderboardSnapshotId({
              periodKey: input.periodKey,
              regionId: area.regionId,
              divisionKey: league.key,
            }),
      rankId: null,
      periodKey: input.periodKey,
      regionId: area?.regionId ?? null,
      divisionKey: league.key,
      status,
    });
  }
  return [...views.values()].sort((left, right) =>
    left.ownerUid.localeCompare(right.ownerUid),
  );
}

type WriteOperation =
  | {
      readonly kind: "set";
      readonly ref: DocumentReference;
      readonly data: FirebaseFirestore.DocumentData;
    }
  | {
      readonly kind: "delete";
      readonly ref: DocumentReference;
    };

async function commitOperations(
  firestore: Firestore,
  operations: readonly WriteOperation[],
): Promise<void> {
  for (
    let index = 0;
    index < operations.length;
    index += maxBatchOperations
  ) {
    const batch = firestore.batch();
    for (const operation of operations.slice(
      index,
      index + maxBatchOperations,
    )) {
      if (operation.kind === "set") {
        batch.set(operation.ref, operation.data);
      } else {
        batch.delete(operation.ref);
      }
    }
    await batch.commit();
  }
}

async function cleanupExpiredProjections(
  firestore: Firestore,
  retainedPeriods: ReadonlySet<string>,
): Promise<void> {
  const collections = [
    "leaderboardSnapshots",
    "leaderboardUserRanks",
    "leaderboardAggregationLocks",
  ];
  const operations: WriteOperation[] = [];
  for (const collection of collections) {
    const snapshot = await firestore
      .collection(collection)
      .where("periodType", "==", "monthly")
      .get();
    for (const document of snapshot.docs) {
      const periodKey = readString(document.data()["periodKey"]);
      if (periodKey !== null && !retainedPeriods.has(periodKey)) {
        operations.push({ kind: "delete", ref: document.ref });
      }
    }
  }
  await commitOperations(firestore, operations);
}

export function currentSingaporeMonthKey(now: Date): string {
  const singaporeTime = new Date(now.getTime() + 8 * 60 * 60 * 1000);
  return singaporeTime.toISOString().slice(0, 7);
}

export function nextSingaporeMonthStart(periodKey: string): string {
  const parsed = parsePeriodKey(periodKey);
  if (parsed === null) {
    return "";
  }
  return new Date(
    Date.UTC(parsed.year, parsed.month, 0, 16, 0, 0, 0),
  ).toISOString();
}

export function singaporeMonthLabel(periodKey: string): string {
  const parsed = parsePeriodKey(periodKey);
  if (parsed === null) {
    return "";
  }
  return new Intl.DateTimeFormat("en-US", {
    month: "long",
    year: "numeric",
    timeZone: leaderboardTimezone,
  }).format(new Date(Date.UTC(parsed.year, parsed.month - 1, 1)));
}

function retainedPeriodKeys(periodKey: string): ReadonlySet<string> {
  const parsed = parsePeriodKey(periodKey);
  if (parsed === null) {
    return new Set([periodKey]);
  }
  const periods = new Set<string>();
  for (let offset = 0; offset < 3; offset += 1) {
    const date = new Date(Date.UTC(parsed.year, parsed.month - 1 - offset, 1));
    periods.add(
      `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`,
    );
  }
  return periods;
}

function parsePeriodKey(
  periodKey: string,
): { readonly year: number; readonly month: number } | null {
  const match = /^(\d{4})-(\d{2})$/.exec(periodKey);
  if (match === null) {
    return null;
  }
  const year = Number(match[1]);
  const month = Number(match[2]);
  return Number.isInteger(year) &&
    Number.isInteger(month) &&
    month >= 1 &&
    month <= 12
    ? { year, month }
    : null;
}

function readString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : null;
}

function readDate(value: unknown): Date | null {
  const text = readString(value);
  if (text === null) {
    return null;
  }
  const parsed = new Date(text);
  return Number.isFinite(parsed.getTime()) ? parsed : null;
}

function readLevel(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value)
    ? Math.floor(value)
    : 1;
}

const emptyStringList: readonly string[] = [];
