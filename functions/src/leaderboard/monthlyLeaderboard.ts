import { getApps, initializeApp } from "firebase-admin/app";
import {
  FieldValue,
  type Firestore,
  type Transaction,
} from "firebase-admin/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { leaderboardLeagueForKey } from "../progression/leaderboardLeagues.js";
import {
  singaporePlanningAreaForLocationLabel,
  singaporePlanningAreaForRegionId,
} from "./singaporePlanningAreas.js";
import {
  leaderboardContributionSchemaVersion,
  leaderboardTimezone,
  type LeaderboardContributionDocument,
} from "./leaderboardTypes.js";
import {
  currentSingaporeMonthKey,
  nextSingaporeMonthStart,
  refreshMonthlyLeaderboardSnapshots,
  singaporeMonthLabel,
} from "./monthlyLeaderboardWriter.js";

if (getApps().length === 0) {
  initializeApp();
}

export {
  monthlyLeaderboardRankId,
  monthlyLeaderboardSnapshotId,
  planMonthlyLeaderboards,
} from "./monthlyLeaderboardPlanner.js";
export {
  currentSingaporeMonthKey,
  nextSingaporeMonthStart,
  refreshMonthlyLeaderboardSnapshots,
  singaporeMonthLabel,
} from "./monthlyLeaderboardWriter.js";
export {
  leaderboardContributionSchemaVersion,
  leaderboardTimezone,
} from "./leaderboardTypes.js";
export type {
  LeaderboardContributionDocument,
  LeaderboardCurrentViewStatus,
  LeaderboardPublicEntry,
  MonthlyLeaderboardCurrentViewPlan,
  MonthlyLeaderboardPlan,
  MonthlyLeaderboardRankPlan,
  MonthlyLeaderboardSnapshotPlan,
} from "./leaderboardTypes.js";

export const refreshLeaderboardSnapshots = onSchedule(
  {
    schedule: "every 60 minutes",
    region: "asia-southeast1",
    timeZone: leaderboardTimezone,
  },
  async () => {
    await refreshMonthlyLeaderboardSnapshots(
      getFirestore(),
      currentSingaporeMonthKey(new Date()),
    );
  },
);

export function leaderboardContributionId(
  uid: string,
  periodKey: string,
): string {
  return `${uid}_monthly_${periodKey}`;
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
  readonly existingContributionData:
    | FirebaseFirestore.DocumentData
    | undefined;
  /**
   * The caller's authoritative recompute of the qualifying-run count used to
   * gate `config/leaderboard.minRunsToQualify` — NOT an accumulator.
   * `completeRun` derives this from the full validated activity history it
   * already reads inside its transaction (validated runs completed within
   * the same monthly period), so every write is a correct absolute value and
   * self-heals any prior under-count. It is written as a plain value (never
   * `FieldValue.increment`), floored and clamped to `>= 0`. `completeCoolDown`
   * does not fetch activity history and passes `null`, which leaves the
   * stored `qualifyingRunCount` untouched.
   */
  readonly qualifyingRunCount: number | null;
}): LeaderboardContributionDocument | null {
  const contribution = leaderboardContributionFields(input);
  if (contribution === null) {
    return null;
  }
  input.transaction.set(
    input.firestore
      .collection("leaderboardContributions")
      .doc(leaderboardContributionId(input.uid, input.periodKey)),
    {
      ...contribution,
      scoreXp: FieldValue.increment(contribution.scoreXp),
      sourceProgressionEventIds: FieldValue.arrayUnion(
        input.progressionEventId,
      ),
      ...(input.qualifyingRunCount === null
        ? {}
        : { qualifyingRunCount: Math.max(0, Math.floor(input.qualifyingRunCount)) }),
    },
    { merge: true },
  );
  return contribution;
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
  readonly existingContributionData?:
    | FirebaseFirestore.DocumentData
    | undefined;
}): LeaderboardContributionDocument | null {
  if (!Number.isFinite(input.scoreXp) || input.scoreXp <= 0) {
    return null;
  }
  const existingArea =
    input.existingContributionData?.["schemaVersion"] ===
      leaderboardContributionSchemaVersion &&
    input.existingContributionData?.["periodKey"] === input.periodKey
      ? singaporePlanningAreaForRegionId(
          input.existingContributionData["regionId"],
        )
      : null;
  const selectedArea = singaporePlanningAreaForLocationLabel(
    input.profileData?.["locationLabel"],
  );
  const area = existingArea ?? selectedArea;
  const league = leaderboardLeagueForKey(input.divisionKey);
  if (area === null || league === null) {
    return null;
  }
  return {
    schemaVersion: leaderboardContributionSchemaVersion,
    ownerUid: input.uid,
    publicAlias: publicAliasFromProfile(input.profileData),
    regionId: area.regionId,
    regionLabel: area.regionName,
    planningAreaName: area.planningAreaName,
    planningAreaCode: area.planningAreaCode,
    planningRegionCode: area.planningRegionCode,
    divisionKey: league.key,
    divisionLabel: league.label,
    levelLabel: input.levelLabel.trim(),
    periodType: "monthly",
    periodKey: input.periodKey,
    timezone: leaderboardTimezone,
    scoreXp: Math.floor(input.scoreXp),
    eligible: true,
    eligibilityReason: "eligible_basic_awarded_xp",
    lastProgressionAt: input.completedAt,
    sourceProgressionEventIds: [input.progressionEventId],
  };
}

function publicAliasFromProfile(
  profileData: FirebaseFirestore.DocumentData | undefined,
): string {
  const nickname = profileData?.["nickname"];
  return typeof nickname === "string" && nickname.trim().length > 0
    ? nickname.trim()
    : "Runiac Runner";
}
