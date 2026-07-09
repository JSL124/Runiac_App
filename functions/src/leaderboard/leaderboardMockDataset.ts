import { leaderboardLeagueDefinitions } from "../progression/leaderboardLeagues.js";
import {
  supportedSingaporePlanningAreas,
  type SingaporePlanningArea,
} from "./singaporePlanningAreas.js";
import {
  leaderboardContributionSchemaVersion,
  leaderboardTimezone,
  type LeaderboardContributionDocument,
} from "./leaderboardTypes.js";

export type MockLeaderboardRecord = {
  readonly uid: string;
  readonly user: FirebaseFirestore.DocumentData;
  readonly profile: FirebaseFirestore.DocumentData;
  readonly contribution: LeaderboardContributionDocument &
    FirebaseFirestore.DocumentData;
};

export type MockLeaderboardDataset = {
  readonly runId: string;
  readonly periodKey: string;
  readonly usersPerRegion: number;
  readonly regionCount: number;
  readonly records: readonly MockLeaderboardRecord[];
};

export function generateMockLeaderboardDataset(input: {
  readonly runId: string;
  readonly periodKey: string;
  readonly usersPerRegion?: number;
}): MockLeaderboardDataset {
  const runId = validateRunId(input.runId);
  const periodKey = validatePeriodKey(input.periodKey);
  const usersPerRegion = input.usersPerRegion ?? 100;
  if (
    !Number.isInteger(usersPerRegion) ||
    usersPerRegion < 1 ||
    usersPerRegion > 500
  ) {
    throw new Error("usersPerRegion must be an integer from 1 to 500");
  }
  const records = supportedSingaporePlanningAreas.flatMap(
    (area, regionIndex) =>
      Array.from({ length: usersPerRegion }, (_, userIndex) =>
        mockRecord({
          runId,
          periodKey,
          area,
          regionIndex,
          userIndex,
          usersPerRegion,
        }),
      ),
  );
  return {
    runId,
    periodKey,
    usersPerRegion,
    regionCount: supportedSingaporePlanningAreas.length,
    records,
  };
}

function mockRecord(input: {
  readonly runId: string;
  readonly periodKey: string;
  readonly area: SingaporePlanningArea;
  readonly regionIndex: number;
  readonly userIndex: number;
  readonly usersPerRegion: number;
}): MockLeaderboardRecord {
  const leagueIndex = leagueIndexForUser(
    input.userIndex,
    input.usersPerRegion,
  );
  const league =
    leaderboardLeagueDefinitions[leagueIndex] ??
    leaderboardLeagueDefinitions[0];
  const levelOffset = (input.regionIndex + input.userIndex) % 10;
  const level = Math.min(league.maxLevel, league.minLevel + levelOffset);
  const sequence = input.userIndex + 1;
  const uid = `lbmock_${input.runId}_${input.area.regionId}_${String(sequence).padStart(3, "0")}`;
  const publicAlias = `Mock ${input.area.regionName} ${String(sequence).padStart(3, "0")}`;
  const isPremium = input.userIndex === input.usersPerRegion - 1;
  const scoreXp =
    1_000_000 -
    input.regionIndex * 10_000 -
    leagueIndex * 500 -
    input.userIndex;
  const marker = {
    isMockData: true,
    mockSeedRunId: input.runId,
  };
  return {
    uid,
    user: {
      ...marker,
      subscriptionStatus: isPremium ? "premium" : "basic",
      userRole: "user",
    },
    profile: {
      ...marker,
      displayName: publicAlias,
      nickname: publicAlias,
      locationLabel: input.area.locationLabel,
      level,
      levelLabel: `Level ${level}`,
      divisionTier: league.tier,
      divisionKey: league.key,
      divisionLabel: league.label,
      subscriptionStatus: isPremium ? "premium" : "basic",
    },
    contribution: {
      ...marker,
      schemaVersion: leaderboardContributionSchemaVersion,
      ownerUid: uid,
      publicAlias,
      regionId: input.area.regionId,
      regionLabel: input.area.regionName,
      planningAreaName: input.area.planningAreaName,
      planningAreaCode: input.area.planningAreaCode,
      planningRegionCode: input.area.planningRegionCode,
      divisionKey: league.key,
      divisionLabel: league.label,
      levelLabel: `Level ${level}`,
      periodType: "monthly",
      periodKey: input.periodKey,
      timezone: leaderboardTimezone,
      scoreXp,
      eligible: true,
      eligibilityReason: "mock_seed_basic_awarded_xp",
      lastProgressionAt: `${input.periodKey}-15T04:00:00.000Z`,
      sourceProgressionEventIds: [
        `mock_${input.runId}_${input.area.regionId}_${sequence}`,
      ],
    },
  };
}

function leagueIndexForUser(userIndex: number, usersPerRegion: number): number {
  if (usersPerRegion !== 100) {
    return userIndex % leaderboardLeagueDefinitions.length;
  }
  if (userIndex < 15) {
    return 0;
  }
  if (userIndex < 20) {
    return 1;
  }
  return Math.min(9, 2 + Math.floor((userIndex - 20) / 10));
}

function validateRunId(value: string): string {
  const runId = value.trim().toLowerCase();
  if (!/^[a-z0-9][a-z0-9-]{2,47}$/.test(runId)) {
    throw new Error(
      "runId must be 3-48 lowercase letters, numbers, or hyphens",
    );
  }
  return runId;
}

function validatePeriodKey(value: string): string {
  const periodKey = value.trim();
  if (!/^\d{4}-(0[1-9]|1[0-2])$/.test(periodKey)) {
    throw new Error("periodKey must use YYYY-MM");
  }
  return periodKey;
}
