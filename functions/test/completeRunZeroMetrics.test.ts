import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { completeRunForCallable } from "../src/run/completeRun.js";
import type { CompleteRunResult } from "../src/run/runCompletionTypes.js";

const PROJECT_ID = "runiac-functions-test";
const USER_UID = "zero-distance-runner-001";

let firestore: Firestore;

before(() => {
  if (getApps().length === 0) {
    initializeApp({ projectId: PROJECT_ID });
  }

  firestore = getFirestore();
});

beforeEach(async () => {
  await clearCollections(["activities", "runSummaries", "progressionEvents"]);
});

describe("completeRun zero metric boundary", () => {
  it("accepts a short zero-distance completion when GPS has not produced movement", async () => {
    const result: CompleteRunResult = await completeRunForCallable(
      {
        auth: { uid: USER_UID },
        data: {
          clientRunSessionId: "zero-distance-session-001",
          startedAt: "2026-06-14T09:00:00.000Z",
          completedAt: "2026-06-14T09:00:02.000Z",
          durationSeconds: 2,
          distanceMeters: 0,
          avgPaceSecondsPerKm: 0,
          source: "mobile",
          routePrivacy: "private",
        },
      },
      firestore,
    );

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();

    assert.equal(result.validationStatus, "validated");
    assert.equal(result.progressionDisplay.xpDelta, 0);
    assert.equal(result.progressionDisplay.countsTowardLeaderboard, false);
    assert.equal(activity.get("durationSeconds"), 2);
    assert.equal(activity.get("distanceMeters"), 0);
    assert.equal(activity.get("averagePaceSecondsPerKm"), 0);
    assert.equal(summary.get("clientRunSessionId"), "zero-distance-session-001");
    assert.equal(summary.get("durationSeconds"), 2);
    assert.equal(summary.get("distanceMeters"), 0);
    assert.equal(summary.get("averagePaceSecondsPerKm"), 0);
  });

  it("accepts a paused zero-distance completion after wall-clock time keeps passing", async () => {
    const result: CompleteRunResult = await completeRunForCallable(
      {
        auth: { uid: USER_UID },
        data: {
          clientRunSessionId: "paused-zero-distance-session-001",
          startedAt: "2026-06-14T09:00:00.000Z",
          completedAt: "2026-06-14T09:03:00.000Z",
          durationSeconds: 2,
          distanceMeters: 0,
          avgPaceSecondsPerKm: 0,
          source: "mobile",
          routePrivacy: "private",
        },
      },
      firestore,
    );

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();

    assert.equal(result.validationStatus, "validated");
    assert.equal(result.progressionDisplay.xpDelta, 0);
    assert.equal(result.progressionDisplay.countsTowardLeaderboard, false);
    assert.equal(activity.get("durationSeconds"), 2);
    assert.equal(activity.get("distanceMeters"), 0);
    assert.equal(summary.get("endedAt"), "2026-06-14T09:03:00.000Z");
    assert.equal(summary.get("durationSeconds"), 2);
    assert.equal(summary.get("distanceMeters"), 0);
  });

  it("rejects positive distance with zero average pace", async () => {
    await expectRejectsCode(
      () =>
        completeRunForCallable(
          {
            auth: { uid: USER_UID },
            data: {
              clientRunSessionId: "positive-distance-zero-pace-session-001",
              startedAt: "2026-06-14T09:00:00.000Z",
              completedAt: "2026-06-14T09:03:00.000Z",
              durationSeconds: 180,
              distanceMeters: 20,
              avgPaceSecondsPerKm: 0,
              source: "mobile",
              routePrivacy: "private",
            },
          },
          firestore,
        ),
      "invalid-argument",
    );
  });

  it("rejects duration that exceeds completedAt wall-clock tolerance", async () => {
    await expectRejectsCode(
      () =>
        completeRunForCallable(
          {
            auth: { uid: USER_UID },
            data: {
              clientRunSessionId: "impossible-duration-session-001",
              startedAt: "2026-06-14T09:00:00.000Z",
              completedAt: "2026-06-14T09:00:02.000Z",
              durationSeconds: 300,
              distanceMeters: 0,
              avgPaceSecondsPerKm: 0,
              source: "mobile",
              routePrivacy: "private",
            },
          },
          firestore,
        ),
      "invalid-argument",
    );
  });
});

async function clearCollections(collectionNames: readonly string[]): Promise<void> {
  await Promise.all(
    collectionNames.map(async (collectionName) => {
      const snapshot = await firestore.collection(collectionName).get();
      await Promise.all(snapshot.docs.map((document) => document.ref.delete()));
    }),
  );
}

async function expectRejectsCode(action: () => Promise<unknown>, code: string): Promise<void> {
  await assert.rejects(
    action,
    (error: unknown) =>
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      error.code === code,
  );
}
