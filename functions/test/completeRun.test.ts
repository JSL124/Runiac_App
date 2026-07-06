import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { completeRunForCallable } from "../src/run/completeRun.js";

const PROJECT_ID = "runiac-functions-test";
const USER_UID = "runner-001";

type CallableRequest = {
  readonly auth?: {
    readonly uid: string;
  };
  readonly data: unknown;
};

type CompletionResult = {
  readonly activityId: string;
  readonly summaryId: string;
  readonly progressionEventId: string;
  readonly validationStatus: string;
  readonly progressionDisplay: {
    readonly xpDelta: number;
    readonly countsTowardLeaderboard: boolean;
    readonly status: string;
    readonly reason: string;
  };
};

let firestore: Firestore;

before(() => {
  if (getApps().length === 0) {
    initializeApp({ projectId: PROJECT_ID });
  }

  firestore = getFirestore();
});

beforeEach(async () => {
  await clearCollections(["activities", "runSummaries", "progressionEvents", "userProfiles", "generatedPlans"]);
});

describe("completeRun callable boundary", () => {
  it("fails when auth is missing", async () => {
    await expectRejectsCode(
      () => completeRunForCallable({ data: validPayload() }, firestore),
      "unauthenticated",
    );
  });

  it("writes backend-owned completion artifacts when a minimal payload is valid", async () => {
    const result = await callCompleteRun({ auth: { uid: USER_UID }, data: validPayload() });

    assert.equal(result.validationStatus, "validated");
    assert.equal(result.progressionDisplay.xpDelta, 0);
    assert.equal(result.progressionDisplay.countsTowardLeaderboard, false);
    assert.equal(result.progressionDisplay.status, "deferred");
    assert.equal(result.progressionDisplay.reason, "progression_formula_deferred");

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();
    const progressionEvent = await firestore.doc(`progressionEvents/${result.progressionEventId}`).get();

    assert.equal(activity.get("ownerUid"), USER_UID);
    assert.equal(activity.get("validationStatus"), "validated");
    assert.equal(activity.get("validatedActivityContributionState"), "deferred");
    assert.equal(activity.get("countsTowardProgression"), false);
    assert.equal(activity.get("validationReason"), "progression_formula_deferred");
    assert.equal(summary.get("ownerUid"), USER_UID);
    assert.equal(progressionEvent.get("xpDelta"), 0);
    assert.equal(progressionEvent.get("countsTowardLeaderboard"), false);
  });

  it("persists valid cadence analysis samples on activity and summary documents", async () => {
    const cadenceAnalysisSeries = validCadenceAnalysisSeries();
    const result = await callCompleteRun({
      auth: { uid: USER_UID },
      data: {
        ...validPayload(),
        clientRunSessionId: "local-session-cadence-persistence",
        cadenceAnalysisSeries,
      },
    });

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();

    assert.deepEqual(activity.get("cadenceAnalysisSeries"), cadenceAnalysisSeries);
    assert.deepEqual(summary.get("cadenceAnalysisSeries"), cadenceAnalysisSeries);
  });

  it("persists the maximum bounded cadence analysis sample count", async () => {
    const cadenceAnalysisSeries = validCadenceAnalysisSeriesWithSampleCount(720);
    const result = await callCompleteRun({
      auth: { uid: USER_UID },
      data: {
        ...validPayload(),
        clientRunSessionId: "local-session-cadence-max-samples",
        cadenceAnalysisSeries,
      },
    });

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();

    assert.equal(activity.get("cadenceAnalysisSeries.samples").length, 720);
    assert.deepEqual(activity.get("cadenceAnalysisSeries"), cadenceAnalysisSeries);
    assert.deepEqual(summary.get("cadenceAnalysisSeries"), cadenceAnalysisSeries);
  });

  it("accepts paused duration fields without using wall-clock time as active duration", async () => {
    const result = await callCompleteRun({
      auth: { uid: USER_UID },
      data: pausedRunPayload(),
    });

    assert.equal(result.validationStatus, "validated");

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();

    assert.equal(activity.get("durationSeconds"), 3207);
    assert.equal(activity.get("activeDurationSeconds"), 3207);
    assert.equal(activity.get("elapsedWallSeconds"), 3900);
    assert.equal(activity.get("pausedDurationSeconds"), 693);
    assert.equal(summary.get("durationSeconds"), 3207);
    assert.equal(summary.get("activeDurationSeconds"), 3207);
    assert.equal(summary.get("elapsedWallSeconds"), 3900);
    assert.equal(summary.get("pausedDurationSeconds"), 693);
    assert.equal(summary.get("displayDuration"), "53:27");
    assert.equal(summary.get("displayPace"), "379 sec/km");
  });

  it("rejects inconsistent duration aliases and paused duration math", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...pausedRunPayload(),
            clientRunSessionId: "paused-duration-alias-mismatch",
            durationSeconds: 3208,
          },
        }),
      "invalid-argument",
    );

    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...pausedRunPayload(),
            clientRunSessionId: "paused-duration-math-mismatch",
            pausedDurationSeconds: 1,
          },
        }),
      "invalid-argument",
    );

    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...pausedRunPayload(),
            clientRunSessionId: "paused-duration-active-exceeds-elapsed",
            activeDurationSeconds: 4000,
            durationSeconds: 4000,
          },
        }),
      "invalid-argument",
    );
  });

  it("accepts user-confirmed low-data saves and rejects raw low-data payloads", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: lowDataPayload(),
        }),
      "invalid-argument",
    );

    const result = await callCompleteRun({
      auth: { uid: USER_UID },
      data: {
        ...lowDataPayload(),
        userConfirmedLowDataSave: true,
      },
    });

    assert.equal(result.validationStatus, "validated");
    assert.equal(result.progressionDisplay.xpDelta, 0);
    assert.equal(result.progressionDisplay.countsTowardLeaderboard, false);

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();
    const progressionEvent = await firestore.doc(`progressionEvents/${result.progressionEventId}`).get();

    assert.equal(activity.exists, true);
    assert.equal(summary.exists, true);
    assert.equal(progressionEvent.exists, true);
    assert.equal(activity.get("distanceMeters"), 0);
    assert.equal(activity.get("averagePaceSecondsPerKm"), 0);
    assert.equal(summary.get("distanceMeters"), 0);
    assert.equal(summary.get("averagePaceSecondsPerKm"), 0);
    assert.equal(progressionEvent.get("xpDelta"), 0);
    assert.equal(progressionEvent.get("countsTowardLeaderboard"), false);
  });

  it("rejects confirmed positive-distance saves with zero pace", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            clientRunSessionId: "positive-distance-zero-pace",
            userConfirmedLowDataSave: true,
            avgPaceSecondsPerKm: 0,
          },
        }),
      "invalid-argument",
    );
  });

  it("completeRun writes owner scoped run summaries", async () => {
    const result = await callCompleteRun({ auth: { uid: "alice" }, data: validPayload() });

    const activity = await firestore.doc(`activities/${result.activityId}`).get();
    const summary = await firestore.doc(`runSummaries/${result.summaryId}`).get();
    const progressionEvent = await firestore.doc(`progressionEvents/${result.progressionEventId}`).get();

    assert.equal(activity.get("ownerUid"), "alice");
    assert.equal(summary.get("ownerUid"), "alice");
    assert.equal(summary.get("activityId"), result.activityId);
    assert.equal(progressionEvent.get("ownerUid"), "alice");
  });

  it("completeRun scopes deterministic ids by uid", async () => {
    const aliceResult = await callCompleteRun({ auth: { uid: "alice" }, data: validPayload() });
    const bobResult = await callCompleteRun({ auth: { uid: "bob" }, data: validPayload() });

    assert.notEqual(aliceResult.activityId, bobResult.activityId);
    assert.notEqual(aliceResult.summaryId, bobResult.summaryId);
    assert.notEqual(aliceResult.progressionEventId, bobResult.progressionEventId);
  });

  it("completeRun gives distinct artifacts to distinct client run session ids", async () => {
    const firstResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: {
        ...validPayload(),
        clientRunSessionId: "local-run-20260618-080000-a",
      },
    });
    const secondResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: {
        ...validPayload(),
        clientRunSessionId: "local-run-20260618-090000-b",
        startedAt: "2026-06-14T10:00:00.000Z",
        completedAt: "2026-06-14T10:25:00.000Z",
      },
    });

    assert.notEqual(firstResult.activityId, secondResult.activityId);
    assert.notEqual(firstResult.summaryId, secondResult.summaryId);
    assert.notEqual(
      firstResult.progressionEventId,
      secondResult.progressionEventId,
    );
    assert.equal(await countDocuments("activities"), 2);
    assert.equal(await countDocuments("runSummaries"), 2);
    assert.equal(await countDocuments("progressionEvents"), 2);
  });

  it("persists backend-owned streak state and progression audit for consecutive run days", async () => {
    const firstResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-day-20260614",
        startedAt: "2026-06-14T09:00:00.000Z",
        completedAt: "2026-06-14T09:25:00.000Z",
      }),
    });
    const secondResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-day-20260615",
        startedAt: "2026-06-15T09:00:00.000Z",
        completedAt: "2026-06-15T09:25:00.000Z",
      }),
    });

    const profile = await firestore.doc(`userProfiles/${USER_UID}`).get();
    const firstProgressionEvent = await firestore.doc(`progressionEvents/${firstResult.progressionEventId}`).get();
    const secondProgressionEvent = await firestore.doc(`progressionEvents/${secondResult.progressionEventId}`).get();

    assert.equal(profile.get("streakCount"), 2);
    assert.equal(profile.get("lastStreakRunDate"), "2026-06-15");
    assert.equal(profile.get("streakUpdatedAt"), "2026-06-15T09:25:00.000Z");
    assert.equal(firstProgressionEvent.get("previousStreak"), 0);
    assert.equal(firstProgressionEvent.get("nextStreak"), 1);
    assert.equal(firstProgressionEvent.get("previousStreakRunDate"), null);
    assert.equal(firstProgressionEvent.get("nextStreakRunDate"), "2026-06-14");
    assert.equal(secondProgressionEvent.get("previousStreak"), 1);
    assert.equal(secondProgressionEvent.get("nextStreak"), 2);
    assert.equal(secondProgressionEvent.get("previousStreakRunDate"), "2026-06-14");
    assert.equal(secondProgressionEvent.get("nextStreakRunDate"), "2026-06-15");
  });

  it("does not double increment streak state for duplicate clientRunSessionId values", async () => {
    const payload = runPayloadForSession({
      clientRunSessionId: "streak-duplicate-session",
      startedAt: "2026-06-14T09:00:00.000Z",
      completedAt: "2026-06-14T09:25:00.000Z",
    });

    const firstResult = await callCompleteRun({ auth: { uid: USER_UID }, data: payload });
    const secondResult = await callCompleteRun({ auth: { uid: USER_UID }, data: payload });

    const profile = await firestore.doc(`userProfiles/${USER_UID}`).get();
    const progressionEvent = await firestore.doc(`progressionEvents/${firstResult.progressionEventId}`).get();

    assert.deepEqual(secondResult, firstResult);
    assert.equal(profile.get("streakCount"), 1);
    assert.equal(profile.get("lastStreakRunDate"), "2026-06-14");
    assert.equal(profile.get("streakUpdatedAt"), "2026-06-14T09:25:00.000Z");
    assert.equal(progressionEvent.get("previousStreak"), 0);
    assert.equal(progressionEvent.get("nextStreak"), 1);
    assert.equal(progressionEvent.get("previousStreakRunDate"), null);
    assert.equal(progressionEvent.get("nextStreakRunDate"), "2026-06-14");
    assert.equal(await countDocuments("progressionEvents"), 1);
  });

  it("does not increment streak state beyond one for a second same-day valid run", async () => {
    const firstResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-same-day-first",
        startedAt: "2026-06-14T09:00:00.000Z",
        completedAt: "2026-06-14T09:25:00.000Z",
      }),
    });
    const secondResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-same-day-second",
        startedAt: "2026-06-14T18:00:00.000Z",
        completedAt: "2026-06-14T18:25:00.000Z",
      }),
    });

    const profile = await firestore.doc(`userProfiles/${USER_UID}`).get();
    const firstProgressionEvent = await firestore.doc(`progressionEvents/${firstResult.progressionEventId}`).get();
    const secondProgressionEvent = await firestore.doc(`progressionEvents/${secondResult.progressionEventId}`).get();

    assert.equal(profile.get("streakCount"), 1);
    assert.equal(profile.get("lastStreakRunDate"), "2026-06-14");
    assert.equal(profile.get("streakUpdatedAt"), "2026-06-14T18:25:00.000Z");
    assert.equal(firstProgressionEvent.get("previousStreak"), 0);
    assert.equal(firstProgressionEvent.get("nextStreak"), 1);
    assert.equal(firstProgressionEvent.get("previousStreakRunDate"), null);
    assert.equal(firstProgressionEvent.get("nextStreakRunDate"), "2026-06-14");
    assert.equal(secondProgressionEvent.get("previousStreak"), 1);
    assert.equal(secondProgressionEvent.get("nextStreak"), 1);
    assert.equal(secondProgressionEvent.get("previousStreakRunDate"), "2026-06-14");
    assert.equal(secondProgressionEvent.get("nextStreakRunDate"), "2026-06-14");
  });

  it("restarts streak state after a missed-day gap", async () => {
    await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-gap-first",
        startedAt: "2026-06-14T09:00:00.000Z",
        completedAt: "2026-06-14T09:25:00.000Z",
      }),
    });
    const secondResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-gap-second",
        startedAt: "2026-06-17T09:00:00.000Z",
        completedAt: "2026-06-17T09:25:00.000Z",
      }),
    });

    const profile = await firestore.doc(`userProfiles/${USER_UID}`).get();
    const secondProgressionEvent = await firestore.doc(`progressionEvents/${secondResult.progressionEventId}`).get();

    assert.equal(profile.get("streakCount"), 1);
    assert.equal(profile.get("lastStreakRunDate"), "2026-06-17");
    assert.equal(profile.get("streakUpdatedAt"), "2026-06-17T09:25:00.000Z");
    assert.equal(secondProgressionEvent.get("previousStreak"), 1);
    assert.equal(secondProgressionEvent.get("nextStreak"), 1);
    assert.equal(secondProgressionEvent.get("previousStreakRunDate"), "2026-06-14");
    assert.equal(secondProgressionEvent.get("nextStreakRunDate"), "2026-06-17");
  });

  it("does not regress persisted streak state when an older valid run syncs later", async () => {
    await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-current-first",
        startedAt: "2026-06-14T09:00:00.000Z",
        completedAt: "2026-06-14T09:25:00.000Z",
      }),
    });
    await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-current-second",
        startedAt: "2026-06-15T09:00:00.000Z",
        completedAt: "2026-06-15T09:25:00.000Z",
      }),
    });
    const olderResult = await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-late-older-sync",
        startedAt: "2026-06-13T09:00:00.000Z",
        completedAt: "2026-06-13T09:25:00.000Z",
      }),
    });

    const profile = await firestore.doc(`userProfiles/${USER_UID}`).get();
    const olderProgressionEvent = await firestore.doc(`progressionEvents/${olderResult.progressionEventId}`).get();

    assert.equal(profile.get("streakCount"), 2);
    assert.equal(profile.get("lastStreakRunDate"), "2026-06-15");
    assert.equal(profile.get("streakUpdatedAt"), "2026-06-15T09:25:00.000Z");
    assert.equal(olderProgressionEvent.get("previousStreak"), 2);
    assert.equal(olderProgressionEvent.get("nextStreak"), 2);
    assert.equal(olderProgressionEvent.get("previousStreakRunDate"), "2026-06-15");
    assert.equal(olderProgressionEvent.get("nextStreakRunDate"), "2026-06-15");
  });

  it("recalculates streak from validated activities after the generated plan creation date", async () => {
    await firestore.doc(`userProfiles/${USER_UID}`).set({
      streakCount: 17,
      lastStreakRunDate: "2026-07-04",
      streakUpdatedAt: "2026-07-04T09:25:00.000Z",
    });
    await firestore.doc(`generatedPlans/${USER_UID}`).set({
      createdAt: "2026-07-05T00:05:00.000Z",
      updatedAt: "2026-07-05T00:05:00.000Z",
    });
    await firestore.doc("activities/pre-plan-run").set({
      ownerUid: USER_UID,
      activityType: "run",
      validationStatus: "validated",
      endedAt: "2026-07-04T09:25:00.000Z",
    });

    const result = await callCompleteRun({
      auth: { uid: USER_UID },
      data: runPayloadForSession({
        clientRunSessionId: "streak-after-onboarding-plan",
        startedAt: "2026-07-05T09:00:00.000Z",
        completedAt: "2026-07-05T09:25:00.000Z",
      }),
    });

    const profile = await firestore.doc(`userProfiles/${USER_UID}`).get();
    const progressionEvent = await firestore.doc(`progressionEvents/${result.progressionEventId}`).get();

    assert.equal(profile.get("streakCount"), 1);
    assert.equal(profile.get("lastStreakRunDate"), "2026-07-05");
    assert.equal(profile.get("streakUpdatedAt"), "2026-07-05T09:25:00.000Z");
    assert.equal(progressionEvent.get("previousStreak"), 0);
    assert.equal(progressionEvent.get("nextStreak"), 1);
    assert.equal(progressionEvent.get("previousStreakRunDate"), null);
    assert.equal(progressionEvent.get("nextStreakRunDate"), "2026-07-05");
  });

  it("fails when a required field is missing", async () => {
    const payload = validPayloadWithout("distanceMeters");

    await expectRejectsCode(
      () => callCompleteRun({ auth: { uid: USER_UID }, data: payload }),
      "invalid-argument",
    );
  });

  it("fails when completedAt is not after startedAt", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            completedAt: "2026-06-14T09:00:00.000Z",
          },
        }),
      "invalid-argument",
    );
  });

  it("fails when timestamps are not strict UTC ISO strings", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            startedAt: "June 14 2026 09:00",
          },
        }),
      "invalid-argument",
    );
  });

  it("fails when metrics exceed emulator skeleton safety limits", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            distanceMeters: 1_000_000,
          },
        }),
      "invalid-argument",
    );

    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            avgPaceSecondsPerKm: 1,
          },
        }),
      "invalid-argument",
    );
  });

  it("rejects protected backend-owned fields", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            xp: 100,
            validationStatus: "validated",
            countsTowardProgression: true,
            leaderboardScore: 100,
          },
        }),
      "invalid-argument",
    );
  });

  it("rejects malformed cadence analysis payloads", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            clientRunSessionId: "cadence-malformed-non-array-samples",
            cadenceAnalysisSeries: {
              ...validCadenceAnalysisSeries(),
              samples: "not-samples",
            },
          },
        }),
      "invalid-argument",
    );

    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            clientRunSessionId: "cadence-malformed-out-of-range-sample",
            cadenceAnalysisSeries: {
              ...validCadenceAnalysisSeries(),
              samples: [
                { elapsedSeconds: 30, cadenceSpm: 301, status: "accepted" },
              ],
            },
          },
        }),
      "invalid-argument",
    );

    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            clientRunSessionId: "cadence-malformed-too-many-samples",
            cadenceAnalysisSeries: validCadenceAnalysisSeriesWithSampleCount(721),
          },
        }),
      "invalid-argument",
    );

    assert.equal(await countDocuments("activities"), 0);
    assert.equal(await countDocuments("runSummaries"), 0);
    assert.equal(await countDocuments("progressionEvents"), 0);
  });

  it("is idempotent for duplicate clientRunSessionId values", async () => {
    const first = await callCompleteRun({ auth: { uid: USER_UID }, data: validPayload() });
    const second = await callCompleteRun({ auth: { uid: USER_UID }, data: validPayload() });

    assert.deepEqual(second, first);
    assert.equal(await countDocuments("activities"), 1);
    assert.equal(await countDocuments("runSummaries"), 1);
    assert.equal(await countDocuments("progressionEvents"), 1);
  });

  it("rejects duplicate clientRunSessionId values with changed payload content", async () => {
    await callCompleteRun({ auth: { uid: USER_UID }, data: validPayload() });

    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            completedAt: "2026-06-14T09:30:00.000Z",
            durationSeconds: 1800,
            distanceMeters: 4000,
          },
        }),
      "already-exists",
    );

    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            routeLabel: "Changed route label",
          },
        }),
      "already-exists",
    );
  });

  it("gives premium users no XP, rank, or leaderboard advantage", async () => {
    await firestore.doc(`userProfiles/${USER_UID}`).set({
      subscriptionStatus: "premium",
      xp: 999,
      rank: 3,
      leaderboardScore: 999,
    });

    const result = await callCompleteRun({ auth: { uid: USER_UID }, data: validPayload() });
    const profileAfter = await firestore.doc(`userProfiles/${USER_UID}`).get();

    assert.equal(result.progressionDisplay.xpDelta, 0);
    assert.equal(result.progressionDisplay.countsTowardLeaderboard, false);
    assert.equal(profileAfter.get("xp"), 999);
    assert.equal(profileAfter.get("rank"), 3);
    assert.equal(profileAfter.get("leaderboardScore"), 999);
  });

  it("rejects precise route traces and does not persist them", async () => {
    await expectRejectsCode(
      () =>
        callCompleteRun({
          auth: { uid: USER_UID },
          data: {
            ...validPayload(),
            routeTrace: [{ coordinate: "synthetic-private-route-point" }],
          },
        }),
      "invalid-argument",
    );

    assert.equal(await countDocuments("activities"), 0);
    assert.equal(await countDocuments("runSummaries"), 0);
    assert.equal(await countDocuments("progressionEvents"), 0);
  });
});

async function callCompleteRun(request: CallableRequest): Promise<CompletionResult> {
  return completeRunForCallable(request, firestore);
}

function validPayload(): Record<string, unknown> {
  return {
    clientRunSessionId: "local-session-001",
    startedAt: "2026-06-14T09:00:00.000Z",
    completedAt: "2026-06-14T09:25:00.000Z",
    durationSeconds: 1500,
    distanceMeters: 3200,
    avgPaceSecondsPerKm: 469,
    source: "mobile",
    routePrivacy: "private",
  };
}

function validCadenceAnalysisSeries(): Record<string, unknown> {
  return {
    source: "phoneSensorEstimated",
    confidence: "low",
    samples: [
      { elapsedSeconds: 30, cadenceSpm: 95, status: "accepted" },
      { elapsedSeconds: 90, cadenceSpm: 118, status: "accepted" },
      { elapsedSeconds: 120, cadenceSpm: 120, status: "accepted" },
    ],
  };
}

function validCadenceAnalysisSeriesWithSampleCount(sampleCount: number): Record<string, unknown> {
  return {
    source: "phoneSensorEstimated",
    confidence: "low",
    samples: Array.from({ length: sampleCount }, (_, index) => ({
      elapsedSeconds: index,
      cadenceSpm: 95 + (index % 20),
      status: "accepted",
    })),
  };
}

function lowDataPayload(): Record<string, unknown> {
  return {
    clientRunSessionId: "low-data-local-session-001",
    startedAt: "2026-06-14T09:00:00.000Z",
    completedAt: "2026-06-14T09:00:02.000Z",
    durationSeconds: 2,
    distanceMeters: 0,
    avgPaceSecondsPerKm: 0,
    source: "mobile",
    routePrivacy: "private",
  };
}

function pausedRunPayload(): Record<string, unknown> {
  return {
    clientRunSessionId: "paused-local-session-001",
    startedAt: "2026-06-14T09:00:00.000Z",
    completedAt: "2026-06-14T10:05:00.000Z",
    durationSeconds: 3207,
    activeDurationSeconds: 3207,
    elapsedWallSeconds: 3900,
    pausedDurationSeconds: 693,
    distanceMeters: 8460,
    avgPaceSecondsPerKm: 379,
    source: "mobile",
    routePrivacy: "private",
  };
}

function runPayloadForSession(fields: {
  readonly clientRunSessionId: string;
  readonly startedAt: string;
  readonly completedAt: string;
}): Record<string, unknown> {
  return {
    ...validPayload(),
    ...fields,
  };
}

function validPayloadWithout(fieldName: string): Record<string, unknown> {
  const payload = validPayload();
  delete payload[fieldName];
  return payload;
}

async function expectRejectsCode(action: () => Promise<unknown>, code: string): Promise<void> {
  try {
    await action();
  } catch (error: unknown) {
    assert.equal(getErrorCode(error), code);
    return;
  }

  assert.fail(`Expected ${code} rejection`);
}

function getErrorCode(error: unknown): string {
  if (typeof error === "object" && error !== null && "code" in error) {
    const code = error.code;
    if (typeof code === "string") {
      return code;
    }
  }

  return "";
}

async function clearCollections(collectionNames: readonly string[]): Promise<void> {
  await Promise.all(
    collectionNames.map(async (collectionName) => {
      const snapshot = await firestore.collection(collectionName).get();
      await Promise.all(snapshot.docs.map((document) => document.ref.delete()));
    }),
  );
}

async function countDocuments(collectionName: string): Promise<number> {
  const snapshot = await firestore.collection(collectionName).get();
  return snapshot.size;
}
