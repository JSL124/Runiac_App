import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import {
  createActivityFeedbackAgentHandler,
  type ActivityFeedbackCallableRequest,
} from "../src/agent/activityFeedbackAgentHandler.js";
import type {
  ActivityFeedbackModelProvider,
  ActivityFeedbackProviderRequest,
} from "../src/agent/activityFeedbackModel.js";
import { activityFeedbackSingaporeDayKey } from "../src/agent/activityFeedbackQuota.js";

const PROJECT_ID = "runiac-functions-test";
const USER_UID = "activity-feedback-runner";
const BASE_NOW = new Date("2026-07-10T01:00:00.000Z");
const CALLABLE_URL = "http://127.0.0.1:5001/runiac-functions-test/asia-southeast1/activityFeedbackAgent";
let firestore: Firestore;

before(() => {
  if (getApps().length === 0) initializeApp({ projectId: PROJECT_ID });
  firestore = getFirestore();
});

beforeEach(async () => {
  const snapshot = await firestore.doc(`agentUsage/${USER_UID}`)
    .collection("activityFeedbackDaily").get();
  await Promise.all(snapshot.docs.map((document) => document.ref.delete()));
});

describe("activityFeedbackAgent callable emulator surface", { skip: process.env["FIRESTORE_EMULATOR_HOST"] === undefined }, () => {
  it("rejects unauthenticated and malformed requests before quota state exists", async () => {
    // Given
    const handler = injectableHandler(new CountingProvider(safeOutput()));

    // When / Then
    await assert.rejects(() => handler({ data: validRequest() }), hasHttpsCode("unauthenticated"));
    await assert.rejects(
      () => handler(authenticatedRequest({ ...validRequest(), routeName: "Private loop" })),
      hasHttpsCode("invalid-argument"),
    );
    assert.equal((await dailyDocument(BASE_NOW)).exists, false);
  });

  it("returns generated sections with the exact shared response schema", async () => {
    // Given
    const provider = new CountingProvider(safeOutput());
    const handler = injectableHandler(provider);

    // When
    const result = await handler(authenticatedRequest(validRequest()));

    // Then
    assert.deepEqual(Object.keys(result).sort(), ["delivery", "sections", "source"]);
    assert.equal(result.source, "agent");
    assert.equal(result.delivery, "generated");
    assert.deepEqual(Object.keys(result.sections).sort(), ["improve", "nextFocus", "summary", "wentWell"]);
    assert.equal(provider.calls, 1);
  });

  it("returns deterministic fallback without persisting prompts or generated feedback", async () => {
    // Given
    const handler = injectableHandler(new CountingProvider(() => Promise.reject(new Error("private provider detail"))));

    // When
    const first = await handler(authenticatedRequest(validRequest()));
    const second = await injectableHandler(new CountingProvider({ summary: "malformed" }))(authenticatedRequest(validRequest()));
    const document = await dailyDocument(BASE_NOW);

    // Then
    assert.equal(first.source, "unavailable");
    assert.equal(first.delivery, "fallback");
    assert.deepEqual(second.sections, first.sections);
    assert.deepEqual(Object.keys(document.data() ?? {}).sort(), [
      "attemptCount",
      "createdAt",
      "dayKey",
      "schemaVersion",
      "updatedAt",
    ]);
    const persisted = JSON.stringify(document.data());
    for (const forbidden of ["prompt", "generated", "summary", "wentWell", "private provider detail"]) {
      assert.equal(persisted.includes(forbidden), false);
    }
  });

  it("permits five attempts per Singapore day and returns quota on the sixth", async () => {
    // Given
    const provider = new CountingProvider(safeOutput());
    const handler = injectableHandler(provider);

    // When
    const results = [];
    for (let attempt = 0; attempt < 6; attempt += 1) {
      results.push(await handler(authenticatedRequest(validRequest())));
    }

    // Then
    assert.equal(results.slice(0, 5).every((result) => result.delivery === "generated"), true);
    assert.deepEqual(results[5], {
      source: "quota",
      delivery: "quota",
      sections: results[5]?.sections,
      retryAfterDate: "2026-07-11",
    });
    assert.equal(provider.calls, 5);
    assert.equal((await dailyDocument(BASE_NOW)).get("attemptCount"), 5);
  });

  it("uses yyyyMMdd documents and resets at the Asia Singapore midnight boundary", async () => {
    // Given
    const beforeMidnight = new Date("2026-07-10T15:59:59.000Z");
    const afterMidnight = new Date("2026-07-10T16:00:00.000Z");
    const provider = new CountingProvider(safeOutput());

    // When
    await injectableHandler(provider, beforeMidnight)(authenticatedRequest(validRequest()));
    await injectableHandler(provider, afterMidnight)(authenticatedRequest(validRequest()));

    // Then
    assert.equal(activityFeedbackSingaporeDayKey(beforeMidnight), "20260710");
    assert.equal(activityFeedbackSingaporeDayKey(afterMidnight), "20260711");
    assert.equal((await dailyDocument(beforeMidnight)).get("attemptCount"), 1);
    assert.equal((await dailyDocument(afterMidnight)).get("attemptCount"), 1);
  });

  it("exposes the authenticated callable through the Functions emulator", async () => {
    // Given
    const response = await postCallable(validRequest(), USER_UID);

    // When
    const body: unknown = await response.json();

    // Then
    assert.equal(response.status, 200);
    assert.ok(isRecord(body));
    assert.ok(isRecord(body["result"]));
    assert.ok(body["result"]["source"] === "agent" || body["result"]["source"] === "unavailable");
    assert.ok(isRecord(body["result"]["sections"]));
    assert.deepEqual(Object.keys(body["result"]["sections"]).sort(), ["improve", "nextFocus", "summary", "wentWell"]);
  });
});

function validRequest(): Record<string, unknown> {
  return {
    schemaVersion: 1,
    summary: {
      distanceKm: 5,
      durationSeconds: 1800,
      averagePaceSecondsPerKm: 360,
      caloriesKcal: 310,
      sourceLabel: "Runiac GPS",
    },
    performance: { score: 78, qualityLabel: "Steady", takeaway: "Controlled pacing", nextFocus: "Relaxed start" },
    cadence: { averageSpm: 164, isEstimated: true, confidence: "estimated" },
    unavailable: ["heartRate"],
  };
}

function safeOutput(): Readonly<Record<string, unknown>> {
  return {
    summary: "You completed a steady run with useful pacing data.",
    wentWell: "Your effort stayed controlled across the available metrics.",
    improve: "Ease into the first part of the next run.",
    nextFocus: "Keep the next session calm and repeatable.",
  };
}

function authenticatedRequest(data: Record<string, unknown>): ActivityFeedbackCallableRequest {
  return { auth: { uid: USER_UID }, data };
}

function injectableHandler(provider: ActivityFeedbackModelProvider, now: Date = BASE_NOW) {
  return createActivityFeedbackAgentHandler({
    firestore: () => firestore,
    now: () => now,
    providerFactory: () => provider,
  });
}

class CountingProvider implements ActivityFeedbackModelProvider {
  public calls = 0;

  public constructor(private readonly result: unknown | (() => Promise<unknown>)) {}

  public async invoke(_request: ActivityFeedbackProviderRequest): Promise<unknown> {
    this.calls += 1;
    return typeof this.result === "function" ? this.result() : this.result;
  }
}

async function dailyDocument(now: Date) {
  return firestore.doc(`agentUsage/${USER_UID}/activityFeedbackDaily/${activityFeedbackSingaporeDayKey(now)}`).get();
}

function hasHttpsCode(code: string): (error: unknown) => boolean {
  return (error) => isRecord(error) && error["code"] === code;
}

async function postCallable(data: Record<string, unknown>, uid: string): Promise<Response> {
  return fetch(CALLABLE_URL, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${emulatorJwt(uid)}`,
    },
    body: JSON.stringify({ data }),
  });
}

function emulatorJwt(uid: string): string {
  const header = base64UrlEncode(JSON.stringify({ alg: "none", typ: "JWT" }));
  const payload = base64UrlEncode(JSON.stringify({ sub: uid, uid }));
  return `${header}.${payload}.signature`;
}

function base64UrlEncode(value: string): string {
  return Buffer.from(value).toString("base64").replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
