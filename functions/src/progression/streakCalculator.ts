export type StreakState = {
  readonly streakCount: number;
  readonly lastStreakRunDate: string | null;
};

export type StreakTransition = {
  readonly previousStreak: number;
  readonly nextStreak: number;
  readonly previousStreakRunDate: string | null;
  readonly nextStreakRunDate: string;
  readonly streakUpdatedAt: string;
  readonly shouldUpdateProfile: boolean;
};

export type StreakRun = {
  readonly completedAt: string;
};

type NextStreakState = {
  readonly streakCount: number;
  readonly lastStreakRunDate: string;
  readonly shouldUpdateProfile: boolean;
};

const utcDateLength = 10;
const millisecondsPerDay = 24 * 60 * 60 * 1000;

export function calculateStreakTransition(
  currentState: StreakState,
  completedAt: string,
): StreakTransition {
  const runDate = completedAt.slice(0, utcDateLength);
  const nextState = nextStreakState(currentState, runDate);

  return {
    previousStreak: currentState.streakCount,
    nextStreak: nextState.streakCount,
    previousStreakRunDate: currentState.lastStreakRunDate,
    nextStreakRunDate: nextState.lastStreakRunDate,
    streakUpdatedAt: completedAt,
    shouldUpdateProfile: nextState.shouldUpdateProfile,
  };
}

export function calculateStreakStateFromRuns(runs: readonly StreakRun[]): StreakState {
  const runDates = [...new Set(runs.map((run) => run.completedAt.slice(0, utcDateLength)))]
    .sort((left, right) => left.localeCompare(right));
  return runDates.reduce<StreakState>(
    (state, runDate) => {
      const nextState = nextStreakState(state, runDate);
      return {
        streakCount: nextState.streakCount,
        lastStreakRunDate: nextState.lastStreakRunDate,
      };
    },
    { streakCount: 0, lastStreakRunDate: null },
  );
}

function nextStreakState(currentState: StreakState, runDate: string): NextStreakState {
  const previousDate = currentState.lastStreakRunDate;
  if (previousDate === null) {
    return { streakCount: 1, lastStreakRunDate: runDate, shouldUpdateProfile: true };
  }

  const dayDelta = daysBetween(previousDate, runDate);
  if (dayDelta === 0) {
    return {
      streakCount: currentState.streakCount,
      lastStreakRunDate: previousDate,
      shouldUpdateProfile: true,
    };
  }

  if (dayDelta === 1) {
    return {
      streakCount: currentState.streakCount + 1,
      lastStreakRunDate: runDate,
      shouldUpdateProfile: true,
    };
  }

  if (dayDelta > 1) {
    return { streakCount: 1, lastStreakRunDate: runDate, shouldUpdateProfile: true };
  }

  return {
    streakCount: currentState.streakCount,
    lastStreakRunDate: previousDate,
    shouldUpdateProfile: false,
  };
}

function daysBetween(previousDate: string, nextDate: string): number {
  return (Date.parse(`${nextDate}T00:00:00.000Z`) - Date.parse(`${previousDate}T00:00:00.000Z`)) /
    millisecondsPerDay;
}
