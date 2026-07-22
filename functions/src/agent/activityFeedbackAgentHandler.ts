import type { Firestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { HttpsError } from "firebase-functions/v2/https";
import {
  ActivityFeedbackContractError,
  parseActivityFeedbackRequest,
  type ActivityFeedbackAgentResponse,
} from "./activityFeedbackContracts.js";
import {
  ACTIVITY_FEEDBACK_FALLBACK_SECTIONS,
} from "./activityFeedbackModelOutput.js";
import {
  generateActivityFeedbackSections,
  type ActivityFeedbackGenerationFallbackCategory,
  type ActivityFeedbackModelProvider,
} from "./activityFeedbackModel.js";
import { reserveActivityFeedbackQuota } from "./activityFeedbackQuota.js";
import { isPremiumSubscription } from "../progression/progressionAuditHelpers.js";

/**
 * Stable machine-readable reason attached to the permission-denied error so
 * the client can map it to its paywall instead of a generic failure.
 */
export const ACTIVITY_FEEDBACK_PREMIUM_REQUIRED_REASON = "premium-required";

export type ActivityFeedbackCallableRequest = {
  readonly auth?: { readonly uid: string };
  readonly data: unknown;
};

export type ActivityFeedbackAgentDependencies = {
  readonly firestore: () => Firestore;
  readonly now: () => Date;
  readonly providerFactory: () => ActivityFeedbackModelProvider;
};

type ActivityFeedbackDecisionFallbackCategory =
  | "none"
  | "quota"
  | ActivityFeedbackGenerationFallbackCategory;

export function createActivityFeedbackAgentHandler(
  dependencies: ActivityFeedbackAgentDependencies,
): (request: ActivityFeedbackCallableRequest) => Promise<ActivityFeedbackAgentResponse> {
  return async (request) => {
    const uid = authenticatedUid(request);
    const metrics = parseMetrics(request.data);
    const now = dependencies.now();
    // Activity feedback is a Premium feature: enforce the server-owned tier
    // here so the client-side paywall is a UX layer, not the access control.
    await requirePremiumSubscription(dependencies.firestore(), uid, now);
    const quota = await reserveActivityFeedbackQuota({
      firestore: dependencies.firestore(),
      uid,
      now,
    });
    if (quota.kind === "quota") {
      const result: ActivityFeedbackAgentResponse = {
        source: "quota",
        delivery: "quota",
        sections: ACTIVITY_FEEDBACK_FALLBACK_SECTIONS,
        retryAfterDate: quota.retryAfterDate,
      };
      emitActivityFeedbackDecisionLog(result, "quota");
      return result;
    }
    const generated = await generateActivityFeedbackSections({
      provider: dependencies.providerFactory(),
      metrics,
    });
    if (generated.kind === "generated") {
      const result: ActivityFeedbackAgentResponse = {
        source: "agent",
        delivery: "generated",
        sections: generated.sections,
      };
      emitActivityFeedbackDecisionLog(result, "none");
      return result;
    }
    const result: ActivityFeedbackAgentResponse = {
      source: "unavailable",
      delivery: "fallback",
      sections: ACTIVITY_FEEDBACK_FALLBACK_SECTIONS,
    };
    emitActivityFeedbackDecisionLog(result, generated.fallbackCategory);
    return result;
  };
}

async function requirePremiumSubscription(
  firestore: Firestore,
  uid: string,
  now: Date,
): Promise<void> {
  const userSnapshot = await firestore.doc(`users/${uid}`).get();
  if (isPremiumSubscription(userSnapshot.data(), now.getTime())) {
    return;
  }
  throw new HttpsError(
    "permission-denied",
    "Activity feedback is available on Premium.",
    { reason: ACTIVITY_FEEDBACK_PREMIUM_REQUIRED_REASON },
  );
}

function authenticatedUid(request: ActivityFeedbackCallableRequest): string {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) {
    throw new HttpsError(
      "unauthenticated",
      "Authentication is required to use the activity feedback agent.",
    );
  }
  return uid;
}

function parseMetrics(data: unknown) {
  try {
    return parseActivityFeedbackRequest(data);
  } catch (error) {
    if (error instanceof ActivityFeedbackContractError) {
      throw new HttpsError("invalid-argument", error.message);
    }
    throw error;
  }
}

function emitActivityFeedbackDecisionLog(
  result: ActivityFeedbackAgentResponse,
  fallbackCategory: ActivityFeedbackDecisionFallbackCategory,
): void {
  const fields = {
    event: "activity_feedback_agent_result",
    delivery: result.delivery,
    source: result.source,
    fallbackCategory,
  } as const;
  if (result.delivery === "generated") {
    logger.info(fields);
  } else {
    logger.warn(fields);
  }
}
