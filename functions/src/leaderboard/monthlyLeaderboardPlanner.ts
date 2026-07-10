import {
  leaderboardLeagueForKey,
  type LeaderboardLeagueDefinition,
} from "../progression/leaderboardLeagues.js";
import {
  singaporePlanningAreaForRegionId,
  type SingaporePlanningArea,
} from "./singaporePlanningAreas.js";
import {
  leaderboardContributionSchemaVersion,
  leaderboardTimezone,
  type LeaderboardContributionDocument,
  type LeaderboardPublicEntry,
  type MonthlyLeaderboardCurrentViewPlan,
  type MonthlyLeaderboardPlan,
  type MonthlyLeaderboardRankPlan,
  type MonthlyLeaderboardSnapshotPlan,
} from "./leaderboardTypes.js";

export function planMonthlyLeaderboards(input: {
  readonly periodKey: string;
  readonly contributions: readonly FirebaseFirestore.DocumentData[];
  readonly currentPremiumUids?: ReadonlySet<string>;
}): MonthlyLeaderboardPlan {
  const premiumUids = input.currentPremiumUids ?? emptyUidSet;
  const contributionByOwner = new Map<string, LeaderboardContributionDocument>();
  for (const rawContribution of input.contributions) {
    const contribution = parseContribution(rawContribution, input.periodKey);
    if (contribution === null) {
      continue;
    }
    const existing = contributionByOwner.get(contribution.ownerUid);
    if (
      existing === undefined ||
      contribution.lastProgressionAt >= existing.lastProgressionAt
    ) {
      contributionByOwner.set(contribution.ownerUid, contribution);
    }
  }

  const groups = new Map<string, LeaderboardContributionDocument[]>();
  const excludedCurrentViews: MonthlyLeaderboardCurrentViewPlan[] = [];
  for (const contribution of contributionByOwner.values()) {
    if (premiumUids.has(contribution.ownerUid)) {
      excludedCurrentViews.push({
        ownerUid: contribution.ownerUid,
        snapshotId: null,
        rankId: null,
        periodKey: input.periodKey,
        regionId: contribution.regionId,
        divisionKey: contribution.divisionKey,
        status: "ineligible_premium",
      });
      continue;
    }
    if (!contribution.eligible || contribution.scoreXp <= 0) {
      continue;
    }
    const groupKey = `${contribution.regionId}\u0000${contribution.divisionKey}`;
    const group = groups.get(groupKey);
    if (group === undefined) {
      groups.set(groupKey, [contribution]);
    } else {
      group.push(contribution);
    }
  }

  const snapshots: MonthlyLeaderboardSnapshotPlan[] = [];
  const ranks: MonthlyLeaderboardRankPlan[] = [];
  const currentViews: MonthlyLeaderboardCurrentViewPlan[] = [
    ...excludedCurrentViews,
  ];
  const orderedGroups = [...groups.values()].sort(compareGroups);
  for (const group of orderedGroups) {
    const area = singaporePlanningAreaForRegionId(group[0]?.regionId);
    const league = leaderboardLeagueForKey(group[0]?.divisionKey);
    if (area === null || league === null) {
      continue;
    }
    const ranked = [...group].sort(compareContributions);
    const snapshotId = monthlyLeaderboardSnapshotId({
      periodKey: input.periodKey,
      regionId: area.regionId,
      divisionKey: league.key,
    });
    const publicEntries = ranked.map((contribution, index) =>
      publicEntry(contribution, area, league, index + 1),
    );
    snapshots.push({
      snapshotId,
      periodKey: input.periodKey,
      regionId: area.regionId,
      divisionKey: league.key,
      regionLabel: area.regionName,
      divisionLabel: league.label,
      entryCount: publicEntries.length,
      topEntries: publicEntries.slice(0, 10),
    });
    for (const [index, contribution] of ranked.entries()) {
      const rankId = monthlyLeaderboardRankId(
        contribution.ownerUid,
        input.periodKey,
      );
      const currentEntry = publicEntries[index];
      if (currentEntry === undefined) {
        continue;
      }
      const nearbyStart = Math.min(
        Math.max(0, index - 2),
        Math.max(0, publicEntries.length - 5),
      );
      ranks.push({
        rankId,
        ownerUid: contribution.ownerUid,
        snapshotId,
        periodKey: input.periodKey,
        regionId: area.regionId,
        divisionKey: league.key,
        rankLabel: currentEntry.rankLabel,
        score: contribution.scoreXp,
        currentEntry,
        nearbyEntries: publicEntries.slice(nearbyStart, nearbyStart + 5),
      });
      currentViews.push({
        ownerUid: contribution.ownerUid,
        snapshotId,
        rankId,
        periodKey: input.periodKey,
        regionId: area.regionId,
        divisionKey: league.key,
        status: "ranked",
      });
    }
  }

  return {
    periodKey: input.periodKey,
    snapshots,
    ranks,
    currentViews,
  };
}

export function monthlyLeaderboardSnapshotId(input: {
  readonly periodKey: string;
  readonly regionId: string;
  readonly divisionKey: string;
}): string {
  return `monthly_${input.regionId}_${input.divisionKey}_${input.periodKey}`;
}

export function monthlyLeaderboardRankId(
  ownerUid: string,
  periodKey: string,
): string {
  return `${ownerUid}_monthly_${periodKey}`;
}

function parseContribution(
  contribution: FirebaseFirestore.DocumentData,
  periodKey: string,
): LeaderboardContributionDocument | null {
  const ownerUid = readRequiredString(contribution["ownerUid"]);
  const scoreXp = contribution["scoreXp"];
  const area = singaporePlanningAreaForRegionId(contribution["regionId"]);
  const league = leaderboardLeagueForKey(contribution["divisionKey"]);
  if (
    contribution["schemaVersion"] !== leaderboardContributionSchemaVersion ||
    ownerUid === null ||
    contribution["periodType"] !== "monthly" ||
    contribution["periodKey"] !== periodKey ||
    contribution["timezone"] !== leaderboardTimezone ||
    typeof scoreXp !== "number" ||
    !Number.isFinite(scoreXp) ||
    scoreXp < 0 ||
    area === null ||
    league === null
  ) {
    return null;
  }
  return {
    schemaVersion: leaderboardContributionSchemaVersion,
    ownerUid,
    publicAlias: readPublicAlias(contribution["publicAlias"]),
    regionId: area.regionId,
    regionLabel: area.regionName,
    planningAreaName: area.planningAreaName,
    planningAreaCode: area.planningAreaCode,
    planningRegionCode: area.planningRegionCode,
    divisionKey: league.key,
    divisionLabel: league.label,
    levelLabel: readRequiredString(contribution["levelLabel"]) ?? "",
    periodType: "monthly",
    periodKey,
    timezone: leaderboardTimezone,
    scoreXp: Math.floor(scoreXp),
    eligible: contribution["eligible"] === true,
    eligibilityReason:
      readRequiredString(contribution["eligibilityReason"]) ?? "not_eligible",
    lastProgressionAt:
      readRequiredString(contribution["lastProgressionAt"]) ?? "",
    sourceProgressionEventIds: readStringArray(
      contribution["sourceProgressionEventIds"],
    ),
  };
}

function publicEntry(
  contribution: LeaderboardContributionDocument,
  area: SingaporePlanningArea,
  league: LeaderboardLeagueDefinition,
  rank: number,
): LeaderboardPublicEntry {
  return {
    publicAlias: contribution.publicAlias,
    rankLabel: `#${rank}`,
    scoreLabel: `${contribution.scoreXp.toLocaleString("en-US")} XP`,
    levelLabel: contribution.levelLabel,
    divisionLabel: league.label,
    regionLabel: area.regionName,
    score: contribution.scoreXp,
  };
}

function compareGroups(
  left: readonly LeaderboardContributionDocument[],
  right: readonly LeaderboardContributionDocument[],
): number {
  const leftKey = `${left[0]?.regionId ?? ""}\u0000${left[0]?.divisionKey ?? ""}`;
  const rightKey = `${right[0]?.regionId ?? ""}\u0000${right[0]?.divisionKey ?? ""}`;
  return leftKey.localeCompare(rightKey);
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

function readRequiredString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : null;
}

function readPublicAlias(value: unknown): string {
  return readRequiredString(value) ?? "Runiac Runner";
}

function readStringArray(value: unknown): readonly string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : emptyStringList;
}

const emptyUidSet: ReadonlySet<string> = new Set();
const emptyStringList: readonly string[] = [];
