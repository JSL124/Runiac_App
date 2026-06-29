export type RoutePrivacy = "private" | "public";

export type RawRunCompletionPayload = {
  readonly clientRunSessionId: string;
  readonly startedAt: string;
  readonly completedAt: string;
  readonly durationSeconds: number;
  readonly activeDurationSeconds: number;
  readonly elapsedWallSeconds: number;
  readonly pausedDurationSeconds: number;
  readonly distanceMeters: number;
  readonly avgPaceSecondsPerKm: number;
  readonly source: "mobile";
  readonly routePrivacy: RoutePrivacy;
  readonly userConfirmedLowDataSave?: boolean;
  readonly routeLabel?: string;
  readonly avgHeartRate?: number;
  readonly caloriesEstimate?: number;
  readonly planEnrollmentId?: string;
  readonly scheduledWorkoutId?: string;
  readonly deviceRecordedAt?: string;
  readonly clientAppVersion?: string;
};

export type CompleteRunIds = {
  readonly activityId: string;
  readonly summaryId: string;
  readonly progressionEventId: string;
};

export type ProgressionDisplay = {
  readonly xpDelta: 0;
  readonly countsTowardLeaderboard: false;
  readonly status: "deferred";
  readonly reason: "progression_formula_deferred";
};

export type RunSummaryResult = {
  readonly title: string;
  readonly startedAt: string;
  readonly endedAt: string;
  readonly distanceMeters: number;
  readonly durationSeconds: number;
  readonly activeDurationSeconds: number;
  readonly elapsedWallSeconds: number;
  readonly pausedDurationSeconds: number;
  readonly averagePaceSecondsPerKm: number;
  readonly displayDistance: string;
  readonly displayDuration: string;
  readonly displayPace: string;
  readonly routeLabel?: string;
};

export type CompleteRunResult = CompleteRunIds & {
  readonly validationStatus: "validated";
  readonly runSummary: RunSummaryResult;
  readonly progressionDisplay: ProgressionDisplay;
  readonly message: string;
};
