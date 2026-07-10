import type { Firestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import {
  activePlanMarker,
  HomeGuideContractError,
  parseHomeGuidePlanDisplayContext,
  readTrustedHomeGuideActivities,
} from "./homeGuideContracts.js";
import { buildHomeGuideEvidence } from "./homeGuideEvidence.js";
import { assertNever, type HomeGuideModelProvider, generateHomeGuideBundle } from "./homeGuideModel.js";
import {
  createHomeGuideContextFingerprint,
  finalizeHomeGuideAttemptFailure,
  finalizeHomeGuideAttemptReady,
  reserveHomeGuideQuota,
  singaporeDayKey,
  type HomeGuideBundle,
} from "./homeGuideQuotaCache.js";

const FALLBACK_MESSAGES: HomeGuideBundle = {
  planSummary: "Your plan is ready, superstar! Let's keep today comfy and fun.",
  runningTip: "Tiny trainer tip: Keep the effort relaxed and conversational.",
  progressionCheckIn: "You've got this! One comfy session at a time is plenty.",
};

export type CallableGuideRequest = {
  readonly auth?: { readonly uid: string };
  readonly data: unknown;
};

export type HomeGuideAgentResult = {
  readonly source: "agent" | "unavailable";
  readonly delivery: "generated" | "cache" | "fallback";
  readonly messages: HomeGuideBundle;
  readonly message: string;
};

export type HomeGuideAgentDependencies = {
  readonly firestore: () => Firestore;
  readonly now: () => Date;
  readonly providerFactory: () => HomeGuideModelProvider;
};

export function createHomeGuideAgentHandler(
  dependencies: HomeGuideAgentDependencies,
): (request: CallableGuideRequest) => Promise<HomeGuideAgentResult> {
  return async (request) => {
    const uid = authenticatedUid(request);
    const planContext = parsePlanContext(request.data);
    const now = dependencies.now();
    const firestore = dependencies.firestore();
    const [activePlan, activities] = await Promise.all([
      firestore.collection("generatedPlans").doc(uid).get(),
      readTrustedHomeGuideActivities(firestore, uid, now),
    ]);
    const evidence = buildHomeGuideEvidence({ now, activities });
    const fingerprint = createHomeGuideContextFingerprint({
      dayKey: singaporeDayKey(now),
      activePlanMarker: activePlanMarker(activePlan.get("planId")),
      planContext,
      latestAcceptedActivityMarker: latestActivityMarker(activities),
      evidence,
    });
    const outcome = await reserveHomeGuideQuota({
      firestore,
      uid,
      now,
      fingerprint,
      fallback: FALLBACK_MESSAGES,
    });

    switch (outcome.kind) {
      case "cache":
        return availableResult("cache", outcome.bundle);
      case "leased":
      case "fallback":
        return fallbackResult(outcome.fallback);
      case "reserved": {
        const generated = await generateHomeGuideBundle({
          provider: dependencies.providerFactory(),
          planContext,
          evidence,
        });
        if (generated === null) {
          await finalizeHomeGuideAttemptFailure({ firestore, uid, now, reservation: outcome.reservation });
          return fallbackResult(outcome.fallback);
        }
        const finalized = await finalizeHomeGuideAttemptReady({
          firestore,
          uid,
          now,
          reservation: outcome.reservation,
          bundle: generated,
        });
        return finalized ? availableResult("generated", generated) : fallbackResult(outcome.fallback);
      }
      default:
        return assertNever(outcome);
    }
  };
}

function authenticatedUid(request: CallableGuideRequest): string {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) {
    throw new HttpsError("unauthenticated", "Authentication is required to use the home guide agent.");
  }
  return uid;
}

function parsePlanContext(data: unknown) {
  try {
    return parseHomeGuidePlanDisplayContext(data);
  } catch (error) {
    if (error instanceof HomeGuideContractError) {
      throw new HttpsError("invalid-argument", error.message);
    }
    throw error;
  }
}

function latestActivityMarker(activities: readonly { readonly endedAt: string }[]): string {
  return activities.reduce(
    (latest, activity) => activity.endedAt > latest ? activity.endedAt : latest,
    "no-accepted-activity",
  );
}

function availableResult(delivery: "generated" | "cache", messages: HomeGuideBundle): HomeGuideAgentResult {
  return { source: "agent", delivery, messages, message: messages.planSummary };
}

function fallbackResult(messages: HomeGuideBundle): HomeGuideAgentResult {
  return { source: "unavailable", delivery: "fallback", messages, message: messages.planSummary };
}
