import assert from "node:assert/strict";
import test from "node:test";
import type { DocumentData, DocumentReference, Transaction } from "firebase-admin/firestore";
import { persistCompletedWorkoutProgress } from "../src/plan/planProgress.js";
import type { CompleteRunIds, RawRunCompletionPayload } from "../src/run/runCompletionTypes.js";

const PLAN_ID = "plan-alpha";
const IDS: CompleteRunIds = {
  activityId: "activity-1",
  summaryId: "summary-1",
  progressionEventId: "progression-1",
};

type CapturedWrite = {
  readonly data: DocumentData;
};

/**
 * Minimal `Transaction` stand-in that records what would be merged into
 * `planProgress/{uid}`. Only `set` is exercised by
 * `persistCompletedWorkoutProgress`.
 */
function fakeTransaction(): { transaction: Transaction; writes: CapturedWrite[] } {
  const writes: CapturedWrite[] = [];
  const transaction = {
    set(_ref: DocumentReference, data: DocumentData) {
      writes.push({ data });
      return transaction;
    },
  } as unknown as Transaction;
  return { transaction, writes };
}

function payloadFor(scheduledWorkoutId: string, completedAt: string): RawRunCompletionPayload {
  return {
    clientRunSessionId: "session-1",
    startedAt: completedAt,
    completedAt,
    durationSeconds: 3600,
    activeDurationSeconds: 3600,
    elapsedWallSeconds: 3600,
    pausedDurationSeconds: 0,
    distanceMeters: 10000,
    avgPaceSecondsPerKm: 360,
    source: "mobile",
    routePrivacy: "private",
    scheduledWorkoutId,
  };
}

/** A plan with `workoutCount` planned (non-rest, objective-bearing) workouts. */
function planWith(workoutCount: number): DocumentData {
  return {
    planId: PLAN_ID,
    startsOnDate: "2026-07-01",
    weeks: [
      {
        weekNumber: 1,
        workouts: Array.from({ length: workoutCount }, (_unused, index) => ({
          scheduledWorkoutId: `w${index + 1}`,
          dayLabel: "Mon",
          title: `Workout ${index + 1}`,
          durationMinutes: 30,
        })),
      },
    ],
  };
}

/** Progress doc where `completedKeys` are already recorded for this plan. */
function progressWith(completedKeys: readonly string[], planCompletions?: DocumentData): DocumentData {
  const workouts: Record<string, unknown> = {};
  for (const key of completedKeys) {
    workouts[key] = { status: "completed", completedAt: "2026-07-02T00:00:00.000Z" };
  }
  return {
    workouts,
    completedWorkoutCount: completedKeys.length,
    ...(planCompletions === undefined ? {} : { planCompletions }),
  };
}

function persist(input: {
  readonly generatedPlanData: DocumentData;
  readonly progressData: DocumentData | undefined;
  readonly scheduledWorkoutId: string;
  readonly completedAt?: string;
}) {
  const { transaction, writes } = fakeTransaction();
  const result = persistCompletedWorkoutProgress({
    transaction,
    progressRef: {} as DocumentReference,
    uid: "uid-1",
    ids: IDS,
    payload: payloadFor(input.scheduledWorkoutId, input.completedAt ?? "2026-07-03T10:00:00.000Z"),
    generatedPlanData: input.generatedPlanData,
    progressData: input.progressData,
  });
  return { result, writes };
}

test("records no plan completion while planned workouts remain", () => {
  const { result, writes } = persist({
    generatedPlanData: planWith(3),
    progressData: progressWith([`${PLAN_ID}__w1`]),
    scheduledWorkoutId: "w2",
  });

  assert.equal(result.completedWorkoutRecorded, true);
  assert.equal(writes.length, 1);
  assert.equal(writes[0]?.data["planCompletions"], undefined);
});

test("records the plan completion when the final planned workout lands", () => {
  const { result, writes } = persist({
    generatedPlanData: planWith(3),
    progressData: progressWith([`${PLAN_ID}__w1`, `${PLAN_ID}__w2`]),
    scheduledWorkoutId: "w3",
    completedAt: "2026-07-05T09:30:00.000Z",
  });

  assert.equal(result.completedWorkoutRecorded, true);
  const planCompletions = writes[0]?.data["planCompletions"] as DocumentData;
  assert.deepEqual(planCompletions[PLAN_ID], {
    planId: PLAN_ID,
    completedAt: "2026-07-05T09:30:00.000Z",
    completedWorkoutCount: 3,
    plannedWorkoutTotal: 3,
  });
});

test("does not re-record or overwrite an already-completed plan", () => {
  const existing = {
    [PLAN_ID]: {
      planId: PLAN_ID,
      completedAt: "2026-07-05T09:30:00.000Z",
      completedWorkoutCount: 3,
      plannedWorkoutTotal: 3,
    },
  };
  const { writes } = persist({
    generatedPlanData: planWith(4),
    progressData: progressWith(
      [`${PLAN_ID}__w1`, `${PLAN_ID}__w2`, `${PLAN_ID}__w3`],
      existing,
    ),
    scheduledWorkoutId: "w4",
    completedAt: "2026-07-09T09:30:00.000Z",
  });

  assert.equal(writes[0]?.data["planCompletions"], undefined);
});

test("counts only this plan's workouts, not a previous plan's", () => {
  // Lifetime `completedWorkoutCount` is 3, but two of those belong to an
  // earlier plan — the current plan still has one workout outstanding.
  const { writes } = persist({
    generatedPlanData: planWith(3),
    progressData: progressWith([
      "plan-previous__w1",
      "plan-previous__w2",
      `${PLAN_ID}__w1`,
    ]),
    scheduledWorkoutId: "w2",
  });

  assert.equal(writes[0]?.data["planCompletions"], undefined);
});

test("ignores rest days and objective-less entries in the planned total", () => {
  const planData = planWith(2) as { weeks: { workouts: unknown[] }[] };
  planData.weeks[0]?.workouts.push(
    { scheduledWorkoutId: "rest", dayLabel: "Sun", title: "Rest", kind: "rest", durationMinutes: 0 },
    { scheduledWorkoutId: "no-objective", dayLabel: "Sat", title: "Mobility" },
  );

  const { writes } = persist({
    generatedPlanData: planData as unknown as DocumentData,
    progressData: progressWith([`${PLAN_ID}__w1`]),
    scheduledWorkoutId: "w2",
  });

  const planCompletions = writes[0]?.data["planCompletions"] as DocumentData;
  assert.deepEqual(planCompletions[PLAN_ID], {
    planId: PLAN_ID,
    completedAt: "2026-07-03T10:00:00.000Z",
    completedWorkoutCount: 2,
    plannedWorkoutTotal: 2,
  });
});

test("records nothing when the workout was already recorded (replay)", () => {
  const { result, writes } = persist({
    generatedPlanData: planWith(2),
    progressData: progressWith([`${PLAN_ID}__w1`, `${PLAN_ID}__w2`]),
    scheduledWorkoutId: "w2",
  });

  assert.equal(result.completedWorkoutRecorded, false);
  assert.equal(writes.length, 0);
});
