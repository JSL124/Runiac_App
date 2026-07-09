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
  | "ineligible_premium";

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
