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

import {
  mergeRolloverViews,
  readOwnerFacts,
} from "./monthlyLeaderboardOwnerFacts.js";
import {
  currentSingaporeMonthKey,
  nextSingaporeMonthStart,
  retainedPeriodKeys,
  singaporeMonthLabel,
} from "./monthlyLeaderboardPeriod.js";
import {
  cleanupExpiredProjections,
  commitOperations,
  type WriteOperation,
} from "./monthlyLeaderboardWrites.js";
import { loadLeaderboardConfig } from "../config/configLoader.js";

export {
  currentSingaporeMonthKey,
  nextSingaporeMonthStart,
  singaporeMonthLabel,
};

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
    // Loaded once, up front, before any aggregation reads so the whole
    // refresh run is consistent under a single config snapshot.
    const leaderboardConfig = await loadLeaderboardConfig(firestore);
    // NOTE: `leaderboardConfig.seasonLengthDays` is not wired here. The
    // monthly period boundaries (`currentSingaporeMonthKey` /
    // `nextSingaporeMonthStart` / `retainedPeriodKeys`) are calendar-month
    // based, not a rolling day-count window, so a day-count setting doesn't
    // cleanly apply without changing the period model itself. Left
    // unchanged per scope; see worker report.
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
    // Read on EVERY run, not only on a period change. A currentView is the
    // document the app reads to decide what to show, and it is only ever
    // `set` — nothing deletes one. An owner who has no contribution this
    // period is absent from `ownerUids`, so without this their view keeps
    // whatever status it was last written with, forever.
    //
    // That is not merely stale, it is wrong: a premium owner excluded under
    // `excludePremium: true` keeps `ineligible_premium`, and the app keeps
    // rendering "Monthly ranking is not available for this account yet" long
    // after the policy stopped excluding them. Re-planning every existing view
    // owner each run recomputes the status from current facts and current
    // config instead.
    const rolloverViews = await firestore
      .collection("leaderboardCurrentViews")
      .get();
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
    const ownerFacts = await readOwnerFacts(firestore, ownerUids, now.getTime());
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
      excludePremium: leaderboardConfig.excludePremium,
      minRunsToQualify: leaderboardConfig.minRunsToQualify,
    });
    const currentViews = mergeRolloverViews({
      periodKey,
      plannedViews: plan.currentViews,
      rolloverUids:
        rolloverViews?.docs.map((document) => document.id) ?? emptyStringList,
      ownerFacts,
      excludePremium: leaderboardConfig.excludePremium,
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


const emptyStringList: readonly string[] = [];
