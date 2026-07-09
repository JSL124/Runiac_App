import assert from "node:assert/strict";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const planningContractPath = resolve(
  root,
  "implementation/shared/leaderboard/singapore-planning-areas.json",
);
const leagueContractPath = resolve(
  root,
  "implementation/shared/leaderboard/league-tiers.json",
);
const geoJsonPath = resolve(
  root,
  "implementation/mobile/runiac_app/assets/maps/master_plan_2025_planning_area_boundary_no_sea.geojson",
);

const outputs = {
  planningTypeScript: resolve(
    root,
    "functions/src/leaderboard/singaporePlanningAreas.ts",
  ),
  planningDart: resolve(
    root,
    "implementation/mobile/runiac_app/lib/core/regions/singapore_planning_area_catalog.dart",
  ),
  leaguesTypeScript: resolve(
    root,
    "functions/src/progression/leaderboardLeagues.ts",
  ),
  leaguesDart: resolve(
    root,
    "implementation/mobile/runiac_app/lib/features/leaderboard/domain/models/leaderboard_league_catalog.dart",
  ),
};

export async function loadAndValidateContracts() {
  const [planningText, leagueText, geoJsonText] = await Promise.all([
    readFile(planningContractPath, "utf8"),
    readFile(leagueContractPath, "utf8"),
    readFile(geoJsonPath, "utf8"),
  ]);
  const planning = JSON.parse(planningText);
  const leagues = JSON.parse(leagueText);
  const geoJson = JSON.parse(geoJsonText);

  assert.equal(planning.schemaVersion, 1);
  assert.equal(leagues.schemaVersion, 1);
  assert.ok(Array.isArray(planning.planningAreas));
  assert.ok(Array.isArray(leagues.tiers));
  assert.ok(Array.isArray(geoJson.features));
  assert.equal(planning.planningAreas.length, 55);
  assert.equal(geoJson.features.length, 55);

  const geoByName = new Map();
  for (const feature of geoJson.features) {
    const properties = feature.properties ?? {};
    const name = properties.PLN_AREA_N;
    assert.equal(typeof name, "string");
    assert.equal(geoByName.has(name), false, `duplicate GeoJSON area ${name}`);
    assert.ok(
      feature.geometry?.type === "Polygon" ||
        feature.geometry?.type === "MultiPolygon",
      `unsupported geometry for ${name}`,
    );
    assert.ok(feature.geometry?.coordinates?.length > 0, `empty geometry for ${name}`);
    geoByName.set(name, properties);
  }

  const contractNames = new Set();
  const supportedRegionIds = new Set();
  const supportedLocationLabels = new Set();
  for (const area of planning.planningAreas) {
    assert.equal(typeof area.planningAreaName, "string");
    assert.equal(contractNames.has(area.planningAreaName), false);
    contractNames.add(area.planningAreaName);
    const properties = geoByName.get(area.planningAreaName);
    assert.ok(properties, `missing GeoJSON area ${area.planningAreaName}`);
    assert.equal(area.planningAreaCode, properties.PLN_AREA_C);
    assert.equal(area.planningRegionCode, properties.REGION_C);
    if (area.supported === true) {
      assert.equal(typeof area.regionId, "string");
      assert.equal(typeof area.regionName, "string");
      assert.equal(typeof area.locationLabel, "string");
      assert.equal(supportedRegionIds.has(area.regionId), false);
      assert.equal(supportedLocationLabels.has(area.locationLabel), false);
      supportedRegionIds.add(area.regionId);
      supportedLocationLabels.add(area.locationLabel);
    } else {
      assert.equal(area.supported, false);
      assert.equal(area.regionId, undefined);
      assert.equal(area.locationLabel, undefined);
    }
  }
  assert.equal(contractNames.size, geoByName.size);
  assert.equal(supportedRegionIds.size, 37);
  assert.equal(planning.planningAreas.filter((area) => !area.supported).length, 18);
  assert.ok(Array.isArray(planning.supportedOrder));
  assert.equal(planning.supportedOrder.length, 37);
  assert.equal(new Set(planning.supportedOrder).size, 37);
  assert.deepEqual(
    new Set(planning.supportedOrder),
    supportedRegionIds,
    "supportedOrder must contain every supported region exactly once",
  );

  const aliasEntries = Object.entries(planning.aliases ?? {});
  for (const [alias, target] of aliasEntries) {
    assert.equal(typeof alias, "string");
    assert.ok(supportedLocationLabels.has(target), `alias target is unsupported: ${target}`);
  }

  assert.equal(leagues.tiers.length, 10);
  for (const [index, tier] of leagues.tiers.entries()) {
    const expectedTier = index + 1;
    assert.equal(tier.tier, expectedTier);
    assert.equal(tier.key, `tier_${String(expectedTier).padStart(2, "0")}`);
    assert.equal(tier.minLevel, index * 10 + 1);
    assert.equal(tier.maxLevel, expectedTier * 10);
  }

  return { planning, leagues };
}

function orderedSupportedPlanningAreas(planning) {
  const byRegionId = new Map(
    planning.planningAreas
      .filter((area) => area.supported)
      .map((area) => [area.regionId, area]),
  );
  return planning.supportedOrder.map((regionId) => byRegionId.get(regionId));
}

function typeScriptPlanning(planning) {
  const supported = orderedSupportedPlanningAreas(planning).map((area) => ({
    regionId: area.regionId,
    regionName: area.regionName,
    locationLabel: area.locationLabel,
    planningAreaName: area.planningAreaName,
    planningAreaCode: area.planningAreaCode,
    planningRegionCode: area.planningRegionCode,
  }));
  return `// GENERATED FILE. Run: node tools/leaderboard/generate_leaderboard_contracts.mjs
export type SingaporePlanningArea = {
  readonly regionId: string;
  readonly regionName: string;
  readonly locationLabel: string;
  readonly planningAreaName: string;
  readonly planningAreaCode: string;
  readonly planningRegionCode: string;
};

export const supportedSingaporePlanningAreas = ${JSON.stringify(supported, null, 2)} as const satisfies readonly SingaporePlanningArea[];

const aliases: Readonly<Record<string, string>> = ${JSON.stringify(planning.aliases, null, 2)};

function normalize(value: string): string {
  return value.trim().toLocaleLowerCase("en-US");
}

export function singaporePlanningAreaForLocationLabel(
  locationLabel: unknown,
): SingaporePlanningArea | null {
  if (typeof locationLabel !== "string") {
    return null;
  }
  const normalized = normalize(locationLabel);
  const aliased = Object.entries(aliases).find(([alias]) => normalize(alias) === normalized)?.[1];
  const target = normalize(aliased ?? locationLabel);
  return (
    supportedSingaporePlanningAreas.find((area) => normalize(area.locationLabel) === target) ??
    null
  );
}

export function singaporePlanningAreaForRegionId(
  regionId: unknown,
): SingaporePlanningArea | null {
  if (typeof regionId !== "string") {
    return null;
  }
  const normalized = regionId.trim();
  return supportedSingaporePlanningAreas.find((area) => area.regionId === normalized) ?? null;
}
`;
}

function dartPlanning(planning) {
  const supported = orderedSupportedPlanningAreas(planning);
  const entries = supported
    .map(
      (area) => `  SingaporePlanningArea(
    regionId: '${area.regionId}',
    regionName: '${area.regionName}',
    locationLabel: '${area.locationLabel}',
    planningAreaName: '${area.planningAreaName}',
    planningAreaCode: '${area.planningAreaCode}',
    planningRegionCode: '${area.planningRegionCode}',
  ),`,
    )
    .join("\n");
  const aliases = Object.entries(planning.aliases)
    .map(([alias, target]) => `  '${alias.toLowerCase()}': '${target.toLowerCase()}',`)
    .join("\n");
  return `// GENERATED FILE. Run: node tools/leaderboard/generate_leaderboard_contracts.mjs
class SingaporePlanningArea {
  const SingaporePlanningArea({
    required this.regionId,
    required this.regionName,
    required this.locationLabel,
    required this.planningAreaName,
    required this.planningAreaCode,
    required this.planningRegionCode,
  });

  final String regionId;
  final String regionName;
  final String locationLabel;
  final String planningAreaName;
  final String planningAreaCode;
  final String planningRegionCode;
}

const supportedSingaporePlanningAreas = <SingaporePlanningArea>[
${entries}
];

const _planningAreaAliases = <String, String>{
${aliases}
};

SingaporePlanningArea? singaporePlanningAreaForLocationLabel(String value) {
  final normalized = value.trim().toLowerCase();
  final target = _planningAreaAliases[normalized] ?? normalized;
  for (final area in supportedSingaporePlanningAreas) {
    if (area.locationLabel.toLowerCase() == target) {
      return area;
    }
  }
  return null;
}

SingaporePlanningArea? singaporePlanningAreaForRegionId(String value) {
  final normalized = value.trim();
  for (final area in supportedSingaporePlanningAreas) {
    if (area.regionId == normalized) {
      return area;
    }
  }
  return null;
}
`;
}

function typeScriptLeagues(leagues) {
  return `// GENERATED FILE. Run: node tools/leaderboard/generate_leaderboard_contracts.mjs
export const leaderboardLeagueDefinitions = ${JSON.stringify(leagues.tiers, null, 2)} as const;

export type LeaderboardLeagueDefinition = (typeof leaderboardLeagueDefinitions)[number];

export function leaderboardLeagueForLevel(level: number): LeaderboardLeagueDefinition {
  const boundedLevel = Math.max(1, Math.min(100, Math.floor(level)));
  return (
    leaderboardLeagueDefinitions.find(
      (league) => boundedLevel >= league.minLevel && boundedLevel <= league.maxLevel,
    ) ?? leaderboardLeagueDefinitions[0]
  );
}

export function leaderboardLeagueForKey(
  key: unknown,
): LeaderboardLeagueDefinition | null {
  if (typeof key !== "string") {
    return null;
  }
  return leaderboardLeagueDefinitions.find((league) => league.key === key.trim()) ?? null;
}
`;
}

function dartLeagues(leagues) {
  const entries = leagues.tiers
    .map(
      (tier) => `  LeaderboardLeagueDefinition(
    tier: ${tier.tier},
    key: '${tier.key}',
    name: '${tier.name}',
    label: '${tier.label}',
    minLevel: ${tier.minLevel},
    maxLevel: ${tier.maxLevel},
  ),`,
    )
    .join("\n");
  return `// GENERATED FILE. Run: node tools/leaderboard/generate_leaderboard_contracts.mjs
class LeaderboardLeagueDefinition {
  const LeaderboardLeagueDefinition({
    required this.tier,
    required this.key,
    required this.name,
    required this.label,
    required this.minLevel,
    required this.maxLevel,
  });

  final int tier;
  final String key;
  final String name;
  final String label;
  final int minLevel;
  final int maxLevel;

  String get levelRangeLabel => 'Lv.$minLevel - Lv.$maxLevel';
}

const leaderboardLeagueDefinitions = <LeaderboardLeagueDefinition>[
${entries}
];

LeaderboardLeagueDefinition? leaderboardLeagueForKey(String value) {
  final key = value.trim();
  for (final league in leaderboardLeagueDefinitions) {
    if (league.key == key) {
      return league;
    }
  }
  return null;
}
`;
}

export async function generatedOutputs() {
  const { planning, leagues } = await loadAndValidateContracts();
  return new Map([
    [outputs.planningTypeScript, typeScriptPlanning(planning)],
    [outputs.planningDart, dartPlanning(planning)],
    [outputs.leaguesTypeScript, typeScriptLeagues(leagues)],
    [outputs.leaguesDart, dartLeagues(leagues)],
  ]);
}

export async function generate({ check = false } = {}) {
  const generated = await generatedOutputs();
  for (const [path, content] of generated) {
    if (check) {
      const existing = await readFile(path, "utf8").catch(() => "");
      assert.equal(existing, content, `generated contract drift: ${path}`);
    } else {
      await mkdir(dirname(path), { recursive: true });
      await writeFile(path, content, "utf8");
    }
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  await generate({ check: process.argv.includes("--check") });
}
