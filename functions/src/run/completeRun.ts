import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  leaderboardContributionId,
  writeLeaderboardContribution,
} from "../leaderboard/monthlyLeaderboard.js";
import { persistAdaptiveEstimateLearning } from "../plan/adaptiveEstimate.js";
import { persistCompletedWorkoutProgress } from "../plan/planProgress.js";
import {
  calculateProgressionAudit,
  noCompletedWorkoutRecorded,
  planCompletionFromEvent,
  profileProgressionData,
  progressionEventData,
  progressionDisplayFromEvent,
} from "../progression/progressionAudit.js";
import {
  dailyCapDateForCompletedAt,
  monthlyPeriodForCompletedAt,
} from "../progression/progressionCalculator.js";
import { deferredProgressionDisplay } from "../progression/progressionEventWriter.js";
import { readTrustedProtectedRestDates, readTrustedStreakState } from "../progression/planBoundedStreakState.js";
import {
  calculateStreakTransition,
  type StreakState,
  unchangedStreakTransition,
} from "../progression/streakCalculator.js";
import {
  assertExistingActivityMatchesPayload,
  buildRunSummary,
  deterministicIds,
  fingerprintPayload,
} from "./runCompletionArtifacts.js";
import type { CompleteRunResult, PlanCompletionResult, ProgressionDisplay } from "./runCompletionTypes.js";
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
  const monthlyPeriod = monthlyPeriodForCompletedAt(payload.completedAt);
  let progressionDisplay: ProgressionDisplay = deferredProgressionDisplay();
  let planCompletion: PlanCompletionResult = { completed: false };

  await firestore.runTransaction(async (transaction) => {
    const activityRef = firestore.collection("activities").doc(ids.activityId);
    const summaryRef = firestore.collection("runSummaries").doc(ids.summaryId);
    const progressionRef = firestore.collection("progressionEvents").doc(ids.progressionEventId);
    const userRef = firestore.collection("users").doc(uid);
    const profileRef = firestore.collection("userProfiles").doc(uid);
    const generatedPlanRef = firestore.collection("generatedPlans").doc(uid);
    const planProgressRef = firestore.collection("planProgress").doc(uid);
    const adaptiveEstimateRef = firestore.collection("adaptivePlanEstimates").doc(uid);
    const leaderboardContributionRef = firestore
      .collection("leaderboardContributions")
      .doc(leaderboardContributionId(uid, monthlyPeriod));
    const activitiesQuery = firestore.collection("activities").where("ownerUid", "==", uid);
    const progressionEventsQuery = firestore
      .collection("progressionEvents")
      .where("ownerUid", "==", uid)
      .where("dailyCapDate", "==", dailyCapDate);
    const monthlyProgressionEventsQuery = firestore
      .collection("progressionEvents")
      .where("ownerUid", "==", uid)
      .where("monthlyPeriod", "==", monthlyPeriod);
    const [
      activitySnapshot,
      summarySnapshot,
      progressionSnapshot,
      userSnapshot,
      profileSnapshot,
      generatedPlanSnapshot,
      planProgressSnapshot,
      adaptiveEstimateSnapshot,
      leaderboardContributionSnapshot,
      activitySnapshots,
      progressionEventSnapshots,
      monthlyProgressionEventSnapshots,
    ] = await Promise.all([
        transaction.get(activityRef),
        transaction.get(summaryRef),
        transaction.get(progressionRef),
        transaction.get(userRef),
        transaction.get(profileRef),
        transaction.get(generatedPlanRef),
        transaction.get(planProgressRef),
        transaction.get(adaptiveEstimateRef),
        transaction.get(leaderboardContributionRef),
        transaction.get(activitiesQuery),
        transaction.get(progressionEventsQuery),
        transaction.get(monthlyProgressionEventsQuery),
      ]);

    if (activitySnapshot.exists) {
      assertExistingActivityMatchesPayload(activitySnapshot.data(), payloadFingerprint);
    }

    const shouldPersistProgression = !activitySnapshot.exists;
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

    const currentStreakState = readTrustedStreakState({
      profileState: readStreakState(profileSnapshot.data()),
      generatedPlanData: generatedPlanSnapshot.data(),
      activityDocuments: activitySnapshots.docs.map((document) => document.data()),
    });
    const countsTowardStreak =
      !planProgressResult.matchedPlanWorkout || planProgressResult.completedWorkoutRecorded;
    const streakTransition = shouldPersistProgression
      ? countsTowardStreak
        ? calculateStreakTransition({
            currentState: currentStreakState,
            completedAt: payload.completedAt,
            protectedRestDates: readTrustedProtectedRestDates(generatedPlanSnapshot.data()),
          })
        : unchangedStreakTransition(currentStreakState, payload.completedAt)
      : undefined;

    const xpAudit = shouldPersistProgression
      ? calculateProgressionAudit({
          payload,
          profileData: profileSnapshot.data(),
          subscriptionData: userSnapshot.data(),
          dailyCapDate,
          monthlyPeriod,
          sameDayProgressionEventDocuments: progressionEventSnapshots.docs.map((document) => document.data()),
          sameMonthProgressionEventDocuments: monthlyProgressionEventSnapshots.docs.map((document) => document.data()),
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
        countsTowardStreak,
        plannedWorkoutRecorded: planProgressResult.completedWorkoutRecorded,
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
      planCompletion = planProgressResult.completedWorkoutRecorded
        ? {
            completed: true,
            ...(planProgressResult.planEnrollmentId === null
              ? {}
              : { planEnrollmentId: planProgressResult.planEnrollmentId }),
            ...(planProgressResult.scheduledWorkoutId === null
              ? {}
              : { scheduledWorkoutId: planProgressResult.scheduledWorkoutId }),
          }
        : { completed: false };
      transaction.set(
        progressionRef,
        progressionEventData({ uid, ids, payload, audit: xpAudit, streakTransition, planProgressResult }),
      );
      writeLeaderboardContribution({
        transaction,
        firestore,
        uid,
        progressionEventId: ids.progressionEventId,
        completedAt: payload.completedAt,
        periodKey: xpAudit.monthlyPeriod,
        scoreXp: xpAudit.xpDelta,
        divisionKey: xpAudit.nextProgression.divisionKey,
        divisionLabel: xpAudit.nextProgression.divisionLabel,
        levelLabel: xpAudit.nextProgression.levelLabel,
        profileData: profileSnapshot.data(),
        existingContributionData: leaderboardContributionSnapshot.data(),
      });
    } else {
      progressionDisplay = progressionDisplayFromEvent(progressionSnapshot.data());
      planCompletion = planCompletionFromEvent(progressionSnapshot.data());
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

    if (shouldPersistProgression && xpAudit !== null) {
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
    planCompletion,
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
