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
  readonly cadenceAnalysisSeries?: CadenceAnalysisSeriesPayload;
};

export type CadenceAnalysisSeriesPayload = {
  readonly source: "phoneSensorEstimated";
  readonly confidence: "low";
  readonly samples: readonly CadenceAnalysisSamplePayload[];
};

export type CadenceAnalysisSamplePayload = {
  readonly elapsedSeconds: number;
  readonly cadenceSpm: number;
  readonly status: "accepted";
};

export type CompleteRunIds = {
  readonly activityId: string;
  readonly summaryId: string;
  readonly progressionEventId: string;
};

export type ProgressionDisplay = {
  readonly xpDelta: number;
  readonly countsTowardLeaderboard: false;
  readonly status: "awarded" | "not_awarded" | "deferred";
  readonly reason:
    | "run_completion_xp_awarded"
    | "low_data_no_xp"
    | "daily_cap_reached"
    | "premium_no_progression"
    | "progression_formula_deferred";
  readonly totalXp?: number;
  readonly level?: number;
  readonly divisionKey?: string;
  readonly previousTotalXp?: number;
  readonly previousLevel?: number;
  readonly previousLevelProgressPercent?: number;
  readonly levelProgressPercent?: number;
  readonly nextLevelXp?: number | null;
  readonly xpToNextLevel?: number | null;
  readonly previousStreak?: number;
  readonly streak?: number;
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
  readonly cadenceAnalysisSeries?: CadenceAnalysisSeriesPayload;
};

export type CompleteRunResult = CompleteRunIds & {
  readonly validationStatus: "validated";
  readonly runSummary: RunSummaryResult;
  readonly progressionDisplay: ProgressionDisplay;
  readonly message: string;
};
