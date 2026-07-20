export const leaderboardTimezone = "Asia/Singapore" as const;
export const leaderboardContributionSchemaVersion = 2 as const;

export type LeaderboardContributionDocument = {
  readonly schemaVersion: typeof leaderboardContributionSchemaVersion;
  readonly ownerUid: string;
  readonly publicAlias: string;
  readonly regionId: string;
  readonly regionLabel: string;
  readonly planningAreaName: string;
  readonly planningAreaCode: string;
  readonly planningRegionCode: string;
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
  /**
   * Stored-document-only field: the number of validated runs the owner
   * completed within this monthly period, used to gate
   * `config/leaderboard.minRunsToQualify`. `writeLeaderboardContribution`
   * writes it as an authoritative absolute recompute (never an accumulator),
   * so it self-heals; `completeCoolDown` passes `null` and leaves it alone.
   * Absent on the plain value object returned by
   * `leaderboardContributionFields`, and absent on contributions written
   * before this field existed — the planner treats a missing value as
   * "unknown" and always lets those through.
   */
  readonly qualifyingRunCount?: number;
};

export type LeaderboardPublicEntry = {
  readonly publicAlias: string;
  readonly rankLabel: string;
  readonly scoreLabel: string;
  readonly levelLabel: string;
  readonly divisionLabel: string;
  readonly regionLabel: string;
  readonly score: number;
};

export type MonthlyLeaderboardSnapshotPlan = {
  readonly snapshotId: string;
  readonly periodKey: string;
  readonly regionId: string;
  readonly divisionKey: string;
  readonly regionLabel: string;
  readonly divisionLabel: string;
  readonly entryCount: number;
  readonly topEntries: readonly LeaderboardPublicEntry[];
};

export type MonthlyLeaderboardRankPlan = {
  readonly rankId: string;
  readonly ownerUid: string;
  readonly snapshotId: string;
  readonly periodKey: string;
  readonly regionId: string;
  readonly divisionKey: string;
  readonly rankLabel: string;
  readonly score: number;
  readonly currentEntry: LeaderboardPublicEntry;
  readonly nearbyEntries: readonly LeaderboardPublicEntry[];
};

export type LeaderboardCurrentViewStatus =
  | "ranked"
  | "unranked"
  | "region_required"
  | "ineligible_premium"
  | "ineligible_min_runs";

export type MonthlyLeaderboardCurrentViewPlan = {
  readonly ownerUid: string;
  readonly snapshotId: string | null;
  readonly rankId: string | null;
  readonly periodKey: string;
  readonly regionId: string | null;
  readonly divisionKey: string;
  readonly status: LeaderboardCurrentViewStatus;
};

export type MonthlyLeaderboardPlan = {
  readonly periodKey: string;
  readonly snapshots: readonly MonthlyLeaderboardSnapshotPlan[];
  readonly ranks: readonly MonthlyLeaderboardRankPlan[];
  readonly currentViews: readonly MonthlyLeaderboardCurrentViewPlan[];
};
