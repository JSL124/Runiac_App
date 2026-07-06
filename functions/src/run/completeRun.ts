import { createHash } from "node:crypto";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { deferredProgressionDisplay } from "../progression/progressionEventWriter.js";
import { readTrustedStreakState } from "../progression/planBoundedStreakState.js";
import { calculateStreakTransition, type StreakState } from "../progression/streakCalculator.js";
import type { CompleteRunIds, CompleteRunResult, RawRunCompletionPayload } from "./runCompletionTypes.js";
import { parseRunCompletionPayload } from "./validateRunPayload.js";

type CallableRunRequest = {
  readonly auth?: {
    readonly uid: string;
  };
  readonly data: unknown;
};

if (getApps().length === 0) {
  initializeApp();
}

export const completeRun = onCall({ region: "asia-southeast1" }, async (request) =>
  completeRunForCallable(request, getFirestore()),
);

export async function completeRunForCallable(
  request: CallableRunRequest,
  firestore: Firestore,
): Promise<CompleteRunResult> {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) {
    throw new HttpsError("unauthenticated", "Authentication is required to complete a run.");
  }

  const payload = parseRunCompletionPayload(request.data);
  const ids = deterministicIds(uid, payload.clientRunSessionId);
  const payloadFingerprint = fingerprintPayload(payload);
  const runSummary = buildRunSummary(payload);
  const progressionDisplay = deferredProgressionDisplay();

  await firestore.runTransaction(async (transaction) => {
    const activityRef = firestore.collection("activities").doc(ids.activityId);
    const summaryRef = firestore.collection("runSummaries").doc(ids.summaryId);
    const progressionRef = firestore.collection("progressionEvents").doc(ids.progressionEventId);
    const profileRef = firestore.collection("userProfiles").doc(uid);
    const generatedPlanRef = firestore.collection("generatedPlans").doc(uid);
    const activitiesQuery = firestore.collection("activities").where("ownerUid", "==", uid);
    const [activitySnapshot, summarySnapshot, progressionSnapshot, profileSnapshot, generatedPlanSnapshot, activitySnapshots] =
      await Promise.all([
        transaction.get(activityRef),
        transaction.get(summaryRef),
        transaction.get(progressionRef),
        transaction.get(profileRef),
        transaction.get(generatedPlanRef),
        transaction.get(activitiesQuery),
      ]);

    if (activitySnapshot.exists) {
      assertExistingActivityMatchesPayload(activitySnapshot.data(), payloadFingerprint);
    }

    const shouldPersistProgression = !activitySnapshot.exists;
    const streakTransition = shouldPersistProgression
      ? calculateStreakTransition(
          readTrustedStreakState({
            profileState: readStreakState(profileSnapshot.data()),
            generatedPlanData: generatedPlanSnapshot.data(),
            activityDocuments: activitySnapshots.docs.map((document) => document.data()),
          }),
          payload.completedAt,
        )
      : undefined;

    if (!activitySnapshot.exists) {
      transaction.set(activityRef, {
        ownerUid: uid,
        status: "validated",
        source: payload.source,
        activityType: "run",
        startedAt: payload.startedAt,
        endedAt: payload.completedAt,
        durationSeconds: payload.durationSeconds,
        activeDurationSeconds: payload.activeDurationSeconds,
        elapsedWallSeconds: payload.elapsedWallSeconds,
        pausedDurationSeconds: payload.pausedDurationSeconds,
        distanceMeters: payload.distanceMeters,
        averagePaceSecondsPerKm: payload.avgPaceSecondsPerKm,
        routePrivacy: payload.routePrivacy,
        clientRunSessionId: payload.clientRunSessionId,
        payloadFingerprint,
        createdAt: payload.completedAt,
        updatedAt: payload.completedAt,
        processedAt: payload.completedAt,
        validationStatus: "validated",
        validatedActivityContributionState: "deferred",
        countsTowardProgression: false,
        validationReason: "progression_formula_deferred",
        ...(payload.cadenceAnalysisSeries === undefined
          ? {}
          : { cadenceAnalysisSeries: payload.cadenceAnalysisSeries }),
      });
    }

    if (!summarySnapshot.exists) {
      transaction.set(summaryRef, {
        ownerUid: uid,
        activityId: ids.activityId,
        clientRunSessionId: payload.clientRunSessionId,
        ...runSummary,
        createdAt: payload.completedAt,
      });
    }

    if (!progressionSnapshot.exists) {
      if (streakTransition === undefined) {
        throw new HttpsError("already-exists", "Existing run completion progression state is unreadable.");
      }

      transaction.set(progressionRef, {
        ownerUid: uid,
        activityId: ids.activityId,
        eventType: "run_completion_placeholder",
        status: progressionDisplay.status,
        createdAt: payload.completedAt,
        xpDelta: progressionDisplay.xpDelta,
        previousTotalXp: 0,
        nextTotalXp: 0,
        previousLevel: null,
        nextLevel: null,
        previousStreak: streakTransition.previousStreak,
        nextStreak: streakTransition.nextStreak,
        previousStreakRunDate: streakTransition.previousStreakRunDate,
        nextStreakRunDate: streakTransition.nextStreakRunDate,
        countsTowardLeaderboard: progressionDisplay.countsTowardLeaderboard,
        reason: progressionDisplay.reason,
      });
    }

    if (streakTransition?.shouldUpdateProfile === true) {
      transaction.set(
        profileRef,
        {
          streakCount: streakTransition.nextStreak,
          lastStreakRunDate: streakTransition.nextStreakRunDate,
          streakUpdatedAt: streakTransition.streakUpdatedAt,
        },
        { merge: true },
      );
    }
  });

  return {
    ...ids,
    validationStatus: "validated",
    runSummary,
    progressionDisplay,
    message: "Run completion accepted by emulator backend skeleton.",
  };
}

function deterministicIds(uid: string, clientRunSessionId: string): CompleteRunIds {
  const digest = createHash("sha256").update(`${uid}:${clientRunSessionId}`).digest("hex").slice(0, 24);
  return {
    activityId: `activity_${digest}`,
    summaryId: `summary_${digest}`,
    progressionEventId: `progression_${digest}`,
  };
}

function fingerprintPayload(payload: RawRunCompletionPayload): string {
  const sortedPayload = Object.fromEntries(
    Object.entries(payload).sort(([left], [right]) => left.localeCompare(right)),
  );
  return createHash("sha256").update(JSON.stringify(sortedPayload)).digest("hex");
}

function buildRunSummary(payload: RawRunCompletionPayload): CompleteRunResult["runSummary"] {
  return {
    title: payload.routeLabel ?? "Completed Run",
    startedAt: payload.startedAt,
    endedAt: payload.completedAt,
    distanceMeters: payload.distanceMeters,
    durationSeconds: payload.durationSeconds,
    activeDurationSeconds: payload.activeDurationSeconds,
    elapsedWallSeconds: payload.elapsedWallSeconds,
    pausedDurationSeconds: payload.pausedDurationSeconds,
    averagePaceSecondsPerKm: payload.avgPaceSecondsPerKm,
    displayDistance: `${(payload.distanceMeters / 1000).toFixed(2)} km`,
    displayDuration: formatDuration(payload.durationSeconds),
    displayPace: `${Math.round(payload.avgPaceSecondsPerKm)} sec/km`,
    ...(payload.routeLabel === undefined ? {} : { routeLabel: payload.routeLabel }),
    ...(payload.cadenceAnalysisSeries === undefined
      ? {}
      : { cadenceAnalysisSeries: payload.cadenceAnalysisSeries }),
  };
}

function formatDuration(totalSeconds: number): string {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, "0")}`;
}

function assertExistingActivityMatchesPayload(
  activityData: FirebaseFirestore.DocumentData | undefined,
  payloadFingerprint: string,
): void {
  if (activityData === undefined) {
    throw new HttpsError("already-exists", "Existing run completion state is unreadable.");
  }

  if (activityData["payloadFingerprint"] !== payloadFingerprint) {
    throw new HttpsError("already-exists", "clientRunSessionId already exists with different run data.");
  }
}

function readStreakState(profileData: FirebaseFirestore.DocumentData | undefined): StreakState {
  if (profileData === undefined) {
    return { streakCount: 0, lastStreakRunDate: null };
  }

  const streakCount = profileData["streakCount"];
  const lastStreakRunDate = profileData["lastStreakRunDate"];
  const hasPersistedStreak = typeof streakCount === "number" && Number.isInteger(streakCount) && streakCount > 0;

  return {
    streakCount: hasPersistedStreak ? streakCount : 0,
    lastStreakRunDate: hasPersistedStreak && typeof lastStreakRunDate === "string" ? lastStreakRunDate : null,
  };
}
