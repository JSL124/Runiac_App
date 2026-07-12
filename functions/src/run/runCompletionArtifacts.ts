import { createHash } from "node:crypto";
import { HttpsError } from "firebase-functions/v2/https";
import type { CompleteRunIds, CompleteRunResult, RawRunCompletionPayload } from "./runCompletionTypes.js";

export function deterministicIds(uid: string, clientRunSessionId: string): CompleteRunIds {
  const digest = createHash("sha256").update(`${uid}:${clientRunSessionId}`).digest("hex").slice(0, 24);
  return {
    activityId: `activity_${digest}`,
    summaryId: `summary_${digest}`,
    progressionEventId: `progression_${digest}`,
  };
}

export function fingerprintPayload(payload: RawRunCompletionPayload): string {
  const sortedPayload = Object.fromEntries(
    Object.entries(payload).sort(([left], [right]) => left.localeCompare(right)),
  );
  return createHash("sha256").update(JSON.stringify(sortedPayload)).digest("hex");
}

export function buildRunSummary(payload: RawRunCompletionPayload): CompleteRunResult["runSummary"] {
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
    ...(payload.routePreview === undefined ? {} : { routePreview: payload.routePreview }),
    ...(payload.paceAnalysisSeries === undefined
      ? {}
      : { paceAnalysisSeries: payload.paceAnalysisSeries }),
    ...(payload.elevationSeries === undefined ? {} : { elevationSeries: payload.elevationSeries }),
  };
}

export function assertExistingActivityMatchesPayload(
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

function formatDuration(totalSeconds: number): string {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, "0")}`;
}
