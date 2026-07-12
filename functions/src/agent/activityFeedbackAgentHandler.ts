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
