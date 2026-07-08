import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { persistAdaptiveEstimateLearning } from "../plan/adaptiveEstimate.js";
import { persistCompletedWorkoutProgress } from "../plan/planProgress.js";
import {
  calculateProgressionAudit,
  noCompletedWorkoutRecorded,
  profileProgressionData,
  progressionEventData,
  progressionDisplayFromEvent,
} from "../progression/progressionAudit.js";
import { dailyCapDateForCompletedAt } from "../progression/progressionCalculator.js";
import { deferredProgressionDisplay } from "../progression/progressionEventWriter.js";
import { readTrustedProtectedRestDates, readTrustedStreakState } from "../progression/planBoundedStreakState.js";
import { calculateStreakTransition, type StreakState } from "../progression/streakCalculator.js";
import {
  assertExistingActivityMatchesPayload,
  buildRunSummary,
  deterministicIds,
  fingerprintPayload,
} from "./runCompletionArtifacts.js";
import type { CompleteRunResult, ProgressionDisplay } from "./runCompletionTypes.js";
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
  const dailyCapDate = dailyCapDateForCompletedAt(payload.completedAt);
  let progressionDisplay: ProgressionDisplay = deferredProgressionDisplay();

  await firestore.runTransaction(async (transaction) => {
    const activityRef = firestore.collection("activities").doc(ids.activityId);
    const summaryRef = firestore.collection("runSummaries").doc(ids.summaryId);
    const progressionRef = firestore.collection("progressionEvents").doc(ids.progressionEventId);
    const userRef = firestore.collection("users").doc(uid);
    const profileRef = firestore.collection("userProfiles").doc(uid);
    const generatedPlanRef = firestore.collection("generatedPlans").doc(uid);
    const planProgressRef = firestore.collection("planProgress").doc(uid);
    const adaptiveEstimateRef = firestore.collection("adaptivePlanEstimates").doc(uid);
    const activitiesQuery = firestore.collection("activities").where("ownerUid", "==", uid);
    const progressionEventsQuery = firestore
      .collection("progressionEvents")
      .where("ownerUid", "==", uid)
      .where("dailyCapDate", "==", dailyCapDate);
    const [
      activitySnapshot,
      summarySnapshot,
      progressionSnapshot,
      userSnapshot,
      profileSnapshot,
      generatedPlanSnapshot,
      planProgressSnapshot,
      adaptiveEstimateSnapshot,
      activitySnapshots,
      progressionEventSnapshots,
    ] = await Promise.all([
        transaction.get(activityRef),
        transaction.get(summaryRef),
        transaction.get(progressionRef),
        transaction.get(userRef),
        transaction.get(profileRef),
        transaction.get(generatedPlanRef),
        transaction.get(planProgressRef),
        transaction.get(adaptiveEstimateRef),
        transaction.get(activitiesQuery),
        transaction.get(progressionEventsQuery),
      ]);

    if (activitySnapshot.exists) {
      assertExistingActivityMatchesPayload(activitySnapshot.data(), payloadFingerprint);
    }

    const shouldPersistProgression = !activitySnapshot.exists;
    const streakTransition = shouldPersistProgression
      ? calculateStreakTransition(
          {
            currentState: readTrustedStreakState({
              profileState: readStreakState(profileSnapshot.data()),
              generatedPlanData: generatedPlanSnapshot.data(),
              activityDocuments: activitySnapshots.docs.map((document) => document.data()),
            }),
            completedAt: payload.completedAt,
            protectedRestDates: readTrustedProtectedRestDates(generatedPlanSnapshot.data()),
          },
        )
      : undefined;

    let planProgressResult = noCompletedWorkoutRecorded();
    if (shouldPersistProgression) {
      planProgressResult = persistCompletedWorkoutProgress({
        transaction,
        progressRef: planProgressRef,
        uid,
        ids,
        payload,
        generatedPlanData: generatedPlanSnapshot.data(),
        progressData: planProgressSnapshot.data(),
      });
    }

    const xpAudit = shouldPersistProgression
      ? calculateProgressionAudit({
          payload,
          profileData: profileSnapshot.data(),
          subscriptionData: userSnapshot.data(),
          dailyCapDate,
          sameDayProgressionEventDocuments: progressionEventSnapshots.docs.map((document) => document.data()),
          planProgressResult,
        })
      : null;

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
        validatedActivityContributionState: xpAudit?.xpDelta === 0 ? "not_awarded" : "awarded",
        countsTowardProgression: (xpAudit?.xpDelta ?? 0) > 0,
        validationReason: xpAudit?.reason ?? "progression_formula_deferred",
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
      if (xpAudit === null) {
        throw new HttpsError("already-exists", "Existing run completion XP state is unreadable.");
      }

      progressionDisplay = {
        ...xpAudit.progressionDisplay,
        previousStreak: streakTransition.previousStreak,
        streak: streakTransition.nextStreak,
      };
      transaction.set(
        progressionRef,
        progressionEventData({ uid, ids, payload, audit: xpAudit, streakTransition, planProgressResult }),
      );
    } else {
      progressionDisplay = progressionDisplayFromEvent(progressionSnapshot.data());
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

    if (shouldPersistProgression && xpAudit !== null && xpAudit.xpDelta > 0) {
      transaction.set(profileRef, profileProgressionData(xpAudit, payload.completedAt), { merge: true });
    }

    if (shouldPersistProgression) {
      persistAdaptiveEstimateLearning({
        transaction,
        estimateRef: adaptiveEstimateRef,
        uid,
        ids,
        payload,
        estimateData: adaptiveEstimateSnapshot.data(),
      });
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
