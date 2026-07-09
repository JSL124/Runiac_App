import { applicationDefault, getApps, initializeApp } from "firebase-admin/app";
import {
  getFirestore,
  type Firestore,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { generateMockLeaderboardDataset } from "./leaderboardMockDataset.js";
import { refreshMonthlyLeaderboardSnapshots } from "./monthlyLeaderboardWriter.js";

type SeedArguments = {
  readonly projectId: string;
  readonly periodKey: string;
  readonly runId: string;
  readonly usersPerRegion: number;
  readonly dryRun: boolean;
  readonly seed: boolean;
  readonly refresh: boolean;
  readonly verify: boolean;
  readonly cleanup: boolean;
  readonly lifecycle: boolean;
  readonly firebaseCliAuth: boolean;
  readonly confirmProject: string | null;
  readonly confirmCleanup: string | null;
};

const allowedProductionProject = "runiac-fypp";

export async function runSeedCommand(
  rawArguments: readonly string[],
): Promise<Record<string, unknown>> {
  const args = parseArguments(rawArguments);
  const dataset = generateMockLeaderboardDataset({
    runId: args.runId,
    periodKey: args.periodKey,
    usersPerRegion: args.usersPerRegion,
  });
  const summary = datasetSummary(args.projectId, dataset);
  if (args.dryRun) {
    return { action: "dry-run", ...summary };
  }
  assertMutationConfirmation(args);
  const cleanupCredential = args.firebaseCliAuth
    ? await configureFirebaseCliApplicationDefault()
    : null;
  try {
    return await executeSeedActions(args, dataset, summary);
  } finally {
    await cleanupCredential?.();
  }
}

async function executeSeedActions(
  args: SeedArguments,
  dataset: ReturnType<typeof generateMockLeaderboardDataset>,
  summary: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const firestore = productionOrEmulatorFirestore(args.projectId);
  const results: Record<string, unknown> = { ...summary };
  if (args.lifecycle) {
    results["seed"] = await seedDataset(firestore, dataset, args.projectId);
    results["refresh"] = await refreshMonthlyLeaderboardSnapshots(
      firestore,
      args.periodKey,
      { buildId: `lifecycle_${args.runId}_${args.periodKey}` },
    );
    results["verify"] = await verifySeedRun({
      firestore,
      runId: args.runId,
      periodKey: args.periodKey,
      expectedProfiles: dataset.records.length,
      expectedRegions: dataset.regionCount,
    });
    results["cleanup"] = await cleanupSeedRun({
      firestore,
      runId: args.runId,
      periodKey: args.periodKey,
    });
    results["remainingMockDocuments"] = await remainingMockDocumentCount(
      firestore,
      args.runId,
    );
    return results;
  }
  if (args.cleanup) {
    results["cleanup"] = await cleanupSeedRun({
      firestore,
      runId: args.runId,
      periodKey: args.periodKey,
    });
    return results;
  }
  if (args.seed) {
    results["seed"] = await seedDataset(firestore, dataset, args.projectId);
  }
  if (args.refresh) {
    results["refresh"] = await refreshMonthlyLeaderboardSnapshots(
      firestore,
      args.periodKey,
      {
        buildId: `seed_${args.runId}_${args.periodKey}`,
      },
    );
  }
  if (args.verify) {
    results["verify"] = await verifySeedRun({
      firestore,
      runId: args.runId,
      periodKey: args.periodKey,
      expectedProfiles: dataset.records.length,
      expectedRegions: dataset.regionCount,
    });
  }
  return results;
}

function parseArguments(raw: readonly string[]): SeedArguments {
  const values = new Map<string, string>();
  const flags = new Set<string>();
  for (let index = 0; index < raw.length; index += 1) {
    const token = raw[index];
    if (token === undefined || !token.startsWith("--")) {
      throw new Error(`unexpected argument: ${token ?? ""}`);
    }
    const key = token.slice(2);
    const next = raw[index + 1];
    if (next !== undefined && !next.startsWith("--")) {
      values.set(key, next);
      index += 1;
    } else {
      flags.add(key);
    }
  }
  const projectId = requiredValue(values, "project");
  const periodKey = requiredValue(values, "period");
  const runId = requiredValue(values, "run-id");
  const usersPerRegion = Number(values.get("users-per-region") ?? "100");
  const dryRun = flags.has("dry-run");
  const seed = flags.has("seed");
  const refresh = flags.has("refresh");
  const verify = flags.has("verify");
  const cleanup = flags.has("cleanup");
  const lifecycle = flags.has("lifecycle");
  const firebaseCliAuth = flags.has("firebase-cli-auth");
  const actionCount = [dryRun, seed, refresh, verify, cleanup, lifecycle].filter(
    Boolean,
  ).length;
  if (actionCount === 0) {
    throw new Error(
      "choose --dry-run or one or more of --seed --refresh --verify; --cleanup is standalone",
    );
  }
  if (cleanup && actionCount !== 1) {
    throw new Error("--cleanup must be used alone");
  }
  if (lifecycle && actionCount !== 1) {
    throw new Error("--lifecycle must be used alone");
  }
  if (dryRun && actionCount !== 1) {
    throw new Error("--dry-run must be used alone");
  }
  return {
    projectId,
    periodKey,
    runId,
    usersPerRegion,
    dryRun,
    seed,
    refresh,
    verify,
    cleanup,
    lifecycle,
    firebaseCliAuth,
    confirmProject: values.get("confirm-project") ?? null,
    confirmCleanup: values.get("confirm-cleanup") ?? null,
  };
}

function assertMutationConfirmation(args: SeedArguments): void {
  const usingEmulator = process.env["FIRESTORE_EMULATOR_HOST"] !== undefined;
  if (args.lifecycle && !usingEmulator) {
    throw new Error("--lifecycle is emulator-only");
  }
  if (!usingEmulator) {
    if (args.projectId !== allowedProductionProject) {
      throw new Error(
        `production mutation is restricted to ${allowedProductionProject}`,
      );
    }
    if (args.confirmProject !== args.projectId) {
      throw new Error(
        `repeat --confirm-project ${args.projectId} for production mutation`,
      );
    }
  }
  if (args.cleanup && args.confirmCleanup !== args.runId) {
    throw new Error(`repeat --confirm-cleanup ${args.runId} for cleanup`);
  }
}

async function remainingMockDocumentCount(
  firestore: Firestore,
  runId: string,
): Promise<number> {
  const [users, profiles, contributions] = await Promise.all([
    mockDocuments(firestore, "users", runId),
    mockDocuments(firestore, "userProfiles", runId),
    mockDocuments(firestore, "leaderboardContributions", runId),
  ]);
  const prefix = `lbmock_${runId}_`;
  const [ranks, views] = await Promise.all([
    firestore.collection("leaderboardUserRanks").get(),
    firestore.collection("leaderboardCurrentViews").get(),
  ]);
  return (
    users.length +
    profiles.length +
    contributions.length +
    ranks.docs.filter((document) => document.id.startsWith(prefix)).length +
    views.docs.filter((document) => document.id.startsWith(prefix)).length
  );
}

function productionOrEmulatorFirestore(
  projectId: string,
): Firestore {
  const isEmulator = process.env["FIRESTORE_EMULATOR_HOST"] !== undefined;
  const app =
    getApps()[0] ??
    initializeApp(
      !isEmulator
        ? {
            projectId,
            credential: applicationDefault(),
          }
        : { projectId },
    );
  return getFirestore(app);
}

type FirebaseCliAccount = {
  readonly tokens?: {
    readonly refresh_token?: unknown;
  };
};

type FirebaseCliAuthModule = {
  readonly getGlobalDefaultAccount: () => FirebaseCliAccount | undefined;
};

type FirebaseCliApiModule = {
  readonly clientId: () => string;
  readonly clientSecret: () => string;
};

async function configureFirebaseCliApplicationDefault(): Promise<
  () => Promise<void>
> {
  if (process.env["FIRESTORE_EMULATOR_HOST"] !== undefined) {
    return async () => {};
  }
  const require = createRequire(import.meta.url);
  const authCandidate: unknown = require("firebase-tools/lib/auth.js");
  const apiCandidate: unknown = require("firebase-tools/lib/api.js");
  if (!isFirebaseCliAuthModule(authCandidate) || !isFirebaseCliApiModule(apiCandidate)) {
    throw new Error("installed firebase-tools auth module is incompatible");
  }
  const account = authCandidate.getGlobalDefaultAccount();
  const refreshToken = account?.tokens?.refresh_token;
  if (typeof refreshToken !== "string" || refreshToken.length === 0) {
    throw new Error("no Firebase CLI login found; run firebase login first");
  }
  const directory = await mkdtemp(join(tmpdir(), "runiac-firebase-adc-"));
  const credentialFile = join(directory, "application_default_credentials.json");
  await writeFile(
    credentialFile,
    JSON.stringify({
      type: "authorized_user",
      client_id: apiCandidate.clientId(),
      client_secret: apiCandidate.clientSecret(),
      refresh_token: refreshToken,
    }),
    { encoding: "utf8", mode: 0o600 },
  );
  const previousCredentialPath = process.env["GOOGLE_APPLICATION_CREDENTIALS"];
  process.env["GOOGLE_APPLICATION_CREDENTIALS"] = credentialFile;
  return async () => {
    if (previousCredentialPath === undefined) {
      delete process.env["GOOGLE_APPLICATION_CREDENTIALS"];
    } else {
      process.env["GOOGLE_APPLICATION_CREDENTIALS"] = previousCredentialPath;
    }
    await rm(directory, { recursive: true, force: true });
  };
}

function isFirebaseCliAuthModule(value: unknown): value is FirebaseCliAuthModule {
  if (typeof value !== "object" || value === null) {
    return false;
  }
  const record = value as Record<string, unknown>;
  return typeof record["getGlobalDefaultAccount"] === "function";
}

function isFirebaseCliApiModule(value: unknown): value is FirebaseCliApiModule {
  if (typeof value !== "object" || value === null) {
    return false;
  }
  const record = value as Record<string, unknown>;
  return (
    typeof record["clientId"] === "function" &&
    typeof record["clientSecret"] === "function"
  );
}

async function seedDataset(
  firestore: Firestore,
  dataset: ReturnType<typeof generateMockLeaderboardDataset>,
  projectId: string,
): Promise<Record<string, unknown>> {
  const manifestRef = firestore
    .collection("leaderboardSeedRuns")
    .doc(dataset.runId);
  const manifest = await manifestRef.get();
  if (manifest.exists && manifest.get("status") !== "cleaned") {
    throw new Error(`seed run already exists: ${dataset.runId}`);
  }
  const startedAt = new Date().toISOString();
  await manifestRef.set({
    runId: dataset.runId,
    projectId,
    periodKey: dataset.periodKey,
    usersPerRegion: dataset.usersPerRegion,
    regionCount: dataset.regionCount,
    profileCount: dataset.records.length,
    status: "seeding",
    startedAt,
    updatedAt: startedAt,
  });
  const writer = firestore.bulkWriter();
  for (const record of dataset.records) {
    writer.set(firestore.collection("users").doc(record.uid), record.user);
    writer.set(
      firestore.collection("userProfiles").doc(record.uid),
      record.profile,
    );
    writer.set(
      firestore
        .collection("leaderboardContributions")
        .doc(`${record.uid}_monthly_${dataset.periodKey}`),
      record.contribution,
    );
  }
  await writer.close();
  const completedAt = new Date().toISOString();
  await manifestRef.set(
    {
      status: "seeded",
      completedAt,
      updatedAt: completedAt,
      writeCount: dataset.records.length * 3,
    },
    { merge: true },
  );
  return {
    status: "seeded",
    profileCount: dataset.records.length,
    writeCount: dataset.records.length * 3,
  };
}

async function verifySeedRun(input: {
  readonly firestore: Firestore;
  readonly runId: string;
  readonly periodKey: string;
  readonly expectedProfiles: number;
  readonly expectedRegions: number;
}): Promise<Record<string, unknown>> {
  const [users, profiles, contributions, snapshots, ranks, currentViews] =
    await Promise.all([
      mockDocuments(input.firestore, "users", input.runId),
      mockDocuments(input.firestore, "userProfiles", input.runId),
      mockDocuments(
        input.firestore,
        "leaderboardContributions",
        input.runId,
      ),
      input.firestore
        .collection("leaderboardSnapshots")
        .where("periodKey", "==", input.periodKey)
        .get(),
      input.firestore
        .collection("leaderboardUserRanks")
        .where("periodKey", "==", input.periodKey)
        .get(),
      input.firestore.collection("leaderboardCurrentViews").get(),
    ]);
  assertCount("users", users.length, input.expectedProfiles);
  assertCount("profiles", profiles.length, input.expectedProfiles);
  assertCount("contributions", contributions.length, input.expectedProfiles);
  const mockPrefix = `lbmock_${input.runId}_`;
  const mockRanks = ranks.docs.filter((document) =>
    document.id.startsWith(mockPrefix),
  );
  const mockViews = currentViews.docs.filter((document) =>
    document.id.startsWith(mockPrefix),
  );
  assertCount("currentViews", mockViews.length, input.expectedProfiles);
  const expectedRankCount =
    input.expectedProfiles - input.expectedRegions;
  assertCount("ranks", mockRanks.length, expectedRankCount);
  const regionIds = new Set<string>();
  for (const document of snapshots.docs) {
    const data = document.data();
    if (typeof data["regionId"] === "string") {
      regionIds.add(data["regionId"]);
    }
    const topEntries = data["topEntries"];
    if (!Array.isArray(topEntries) || topEntries.length > 10) {
      throw new Error(`invalid topEntries bound: ${document.id}`);
    }
    if ("entries" in data) {
      throw new Error(`unbounded entries field exists: ${document.id}`);
    }
    for (const rawEntry of topEntries) {
      if (!isSafePublicEntry(rawEntry)) {
        throw new Error(`unsafe public entry: ${document.id}`);
      }
    }
  }
  assertCount("regions", regionIds.size, input.expectedRegions);
  const verifiedAt = new Date().toISOString();
  await input.firestore.collection("leaderboardSeedRuns").doc(input.runId).set(
    {
      status: "verified",
      verifiedAt,
      updatedAt: verifiedAt,
      verifiedProfileCount: profiles.length,
      verifiedRankCount: mockRanks.length,
      verifiedCurrentViewCount: mockViews.length,
      verifiedRegionCount: regionIds.size,
    },
    { merge: true },
  );
  return {
    status: "verified",
    profileCount: profiles.length,
    contributionCount: contributions.length,
    rankCount: mockRanks.length,
    currentViewCount: mockViews.length,
    regionCount: regionIds.size,
    snapshotCount: snapshots.size,
  };
}

async function cleanupSeedRun(input: {
  readonly firestore: Firestore;
  readonly runId: string;
  readonly periodKey: string;
}): Promise<Record<string, unknown>> {
  const manifestRef = input.firestore
    .collection("leaderboardSeedRuns")
    .doc(input.runId);
  const manifest = await manifestRef.get();
  if (!manifest.exists || manifest.get("runId") !== input.runId) {
    throw new Error(`seed manifest not found: ${input.runId}`);
  }
  const mockPrefix = `lbmock_${input.runId}_`;
  const [users, profiles, contributions, ranks, currentViews] =
    await Promise.all([
      mockDocuments(input.firestore, "users", input.runId),
      mockDocuments(input.firestore, "userProfiles", input.runId),
      mockDocuments(
        input.firestore,
        "leaderboardContributions",
        input.runId,
      ),
      input.firestore.collection("leaderboardUserRanks").get(),
      input.firestore.collection("leaderboardCurrentViews").get(),
    ]);
  const ownedDocuments = [
    ...users,
    ...profiles,
    ...contributions,
    ...ranks.docs.filter((document) => document.id.startsWith(mockPrefix)),
    ...currentViews.docs.filter((document) =>
      document.id.startsWith(mockPrefix),
    ),
  ];
  const writer = input.firestore.bulkWriter();
  for (const document of ownedDocuments) {
    writer.delete(document.ref);
  }
  await writer.close();
  const refresh = await refreshMonthlyLeaderboardSnapshots(
    input.firestore,
    input.periodKey,
    {
      buildId: `cleanup_${input.runId}_${input.periodKey}`,
    },
  );
  const cleanedAt = new Date().toISOString();
  await manifestRef.set(
    {
      status: "cleaned",
      cleanedAt,
      updatedAt: cleanedAt,
      deletedDocumentCount: ownedDocuments.length,
    },
    { merge: true },
  );
  return {
    status: "cleaned",
    deletedDocumentCount: ownedDocuments.length,
    refresh,
  };
}

async function mockDocuments(
  firestore: Firestore,
  collection: string,
  runId: string,
): Promise<readonly QueryDocumentSnapshot[]> {
  const snapshot = await firestore
    .collection(collection)
    .where("mockSeedRunId", "==", runId)
    .get();
  return snapshot.docs;
}

function isSafePublicEntry(value: unknown): boolean {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return false;
  }
  const keys = Object.keys(value).sort();
  return (
    JSON.stringify(keys) ===
    JSON.stringify(
      [
        "divisionLabel",
        "levelLabel",
        "publicAlias",
        "rankLabel",
        "regionLabel",
        "score",
        "scoreLabel",
      ].sort(),
    )
  );
}

function assertCount(label: string, actual: number, expected: number): void {
  if (actual !== expected) {
    throw new Error(`${label} count ${actual} did not match ${expected}`);
  }
}

function datasetSummary(
  projectId: string,
  dataset: ReturnType<typeof generateMockLeaderboardDataset>,
): Record<string, unknown> {
  const premiumCount = dataset.regionCount;
  return {
    projectId,
    runId: dataset.runId,
    periodKey: dataset.periodKey,
    regionCount: dataset.regionCount,
    usersPerRegion: dataset.usersPerRegion,
    profileCount: dataset.records.length,
    basicCount: dataset.records.length - premiumCount,
    premiumCount,
    sourceWriteCount: dataset.records.length * 3,
  };
}

function requiredValue(values: ReadonlyMap<string, string>, key: string): string {
  const value = values.get(key)?.trim();
  if (value === undefined || value.length === 0) {
    throw new Error(`missing --${key}`);
  }
  return value;
}

if (
  process.argv[1] !== undefined &&
  import.meta.url === pathToFileURL(process.argv[1]).href
) {
  const result = await runSeedCommand(process.argv.slice(2));
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}
