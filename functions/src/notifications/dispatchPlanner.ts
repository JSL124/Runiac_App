import type {
  NotificationDispatch,
  NotificationDispatchKind,
  NotificationDispatchSendResult,
  NotificationInboxPayload,
  NotificationPlanningContext,
  PlannedWorkoutReminder,
  SendNotificationDispatchesInput,
} from "./types.js";

export type {
  NotificationDeviceRecord,
  NotificationDispatch,
  NotificationSendAdapter,
} from "./types.js";

type SingaporeLocalTime = {
  readonly date: string;
  readonly hour: number;
  readonly minute: number;
};

const START_REMINDER_OFFSETS = [
  { minutes: -120, kind: "plan_start_minus_120" },
  { minutes: -60, kind: "plan_start_minus_60" },
  { minutes: -10, kind: "plan_start_minus_10" },
] as const;

const MISSED_REMINDER_OFFSETS = [
  { minutes: 60, kind: "missed_run_plus_60" },
  { minutes: 120, kind: "missed_run_plus_120" },
] as const;

export function planNotificationDispatches(context: NotificationPlanningContext): readonly NotificationDispatch[] {
  const localTime = singaporeLocalTime(context.now);
  const completedWorkoutIds = new Set(context.completedWorkoutIds);
  const dispatches: NotificationDispatch[] = [];

  if (context.notificationPreferences.planRemindersEnabled) {
    for (const workout of context.plannedWorkouts) {
      if (completedWorkoutIds.has(workout.scheduledWorkoutId)) {
        continue;
      }

      dispatches.push(...planWorkoutDispatches(context.uid, workout, localTime));
    }
  }

  const streakRisk = streakRiskDispatch(context, localTime);
  if (streakRisk !== null) {
    dispatches.push(streakRisk);
  }

  return dispatches;
}

export function deliveryKeyFor(dispatch: Omit<NotificationDispatch, "deliveryKey">): string {
  const subject = dispatch.scheduledWorkoutId ?? "daily-streak";

  return `${dispatch.uid}:${dispatch.kind}:${dispatch.scheduledDate}:${subject}`;
}

export function createInboxPayload(
  dispatch: NotificationDispatch,
  tokenFingerprint: string,
  createdAt: string,
): NotificationInboxPayload {
  return {
    ownerUid: dispatch.uid,
    deliveryKey: dispatch.deliveryKey,
    tokenFingerprint,
    kind: dispatch.kind,
    scheduledWorkoutId: dispatch.scheduledWorkoutId,
    scheduledDate: dispatch.scheduledDate,
    title: dispatch.title,
    body: dispatch.body,
    createdAt,
    readAt: null,
  };
}

export async function sendNotificationDispatches(
  input: SendNotificationDispatchesInput,
): Promise<readonly NotificationDispatchSendResult[]> {
  const results: NotificationDispatchSendResult[] = [];

  for (const dispatch of input.dispatches) {
    for (const device of input.devices) {
      if (input.sentDeliveryKeys.has(deviceDeliveryKey(dispatch.deliveryKey, device.tokenFingerprint))) {
        results.push({
          deliveryKey: dispatch.deliveryKey,
          tokenFingerprint: device.tokenFingerprint,
          status: "skipped-duplicate",
        });
        continue;
      }

      const result = await input.adapter.send(
        dispatch,
        device,
        createInboxPayload(dispatch, device.tokenFingerprint, input.now),
      );
      if (result.status === "invalid-token") {
        await input.adapter.disableToken(device, result.disabledAt ?? input.now);
      }
      results.push({
        deliveryKey: dispatch.deliveryKey,
        tokenFingerprint: device.tokenFingerprint,
        status: result.status,
      });
    }
  }

  return results;
}

export function deviceDeliveryKey(deliveryKey: string, tokenFingerprint: string): string {
  return `${deliveryKey}:${tokenFingerprint}`;
}

function planWorkoutDispatches(
  uid: string,
  workout: PlannedWorkoutReminder,
  localTime: SingaporeLocalTime,
): readonly NotificationDispatch[] {
  if (workout.scheduledDate !== localTime.date) {
    return [];
  }

  const localMinutes = localTime.hour * 60 + localTime.minute;
  const startMinutes = startTimeMinutes(workout.startTime);
  const kind =
    midnightKind(localTime) ??
    reminderKindForOffset(localMinutes - startMinutes, START_REMINDER_OFFSETS) ??
    reminderKindForOffset(localMinutes - startMinutes, MISSED_REMINDER_OFFSETS);

  if (kind === null) {
    return [];
  }

  return [
    withDeliveryKey({
      uid,
      kind,
      scheduledWorkoutId: workout.scheduledWorkoutId,
      scheduledDate: workout.scheduledDate,
      title: titleFor(kind, workout.title),
      body: bodyFor(kind, workout.title),
    }),
  ];
}

function streakRiskDispatch(
  context: NotificationPlanningContext,
  localTime: SingaporeLocalTime,
): NotificationDispatch | null {
  if (
    !context.notificationPreferences.streakRiskEnabled ||
    context.streakState.streakCount <= 0 ||
    context.streakState.lastStreakRunDate === localTime.date ||
    localTime.minute !== 0
  ) {
    return null;
  }

  const kind = streakRiskKind(localTime.hour);
  if (kind === null) {
    return null;
  }

  return withDeliveryKey({
    uid: context.uid,
    kind,
    scheduledWorkoutId: null,
    scheduledDate: localTime.date,
    title: "Keep your streak alive",
    body: "A short validated run before midnight keeps your streak safe.",
  });
}

function withDeliveryKey(dispatch: Omit<NotificationDispatch, "deliveryKey">): NotificationDispatch {
  return {
    ...dispatch,
    deliveryKey: deliveryKeyFor(dispatch),
  };
}

function midnightKind(localTime: SingaporeLocalTime): NotificationDispatchKind | null {
  if (localTime.hour === 0 && localTime.minute === 0) {
    return "today_plan_midnight";
  }

  return null;
}

function reminderKindForOffset<TKind extends NotificationDispatchKind>(
  offset: number,
  reminders: readonly { readonly minutes: number; readonly kind: TKind }[],
): TKind | null {
  for (const reminder of reminders) {
    if (offset === reminder.minutes) {
      return reminder.kind;
    }
  }

  return null;
}

function streakRiskKind(hour: number): NotificationDispatchKind | null {
  if (hour === 22) {
    return "streak_risk_22";
  }
  if (hour === 23) {
    return "streak_risk_23";
  }

  return null;
}

function titleFor(kind: NotificationDispatchKind, workoutTitle: string): string {
  if (kind === "today_plan_midnight") {
    return "Today's run is ready";
  }
  if (kind === "missed_run_plus_60" || kind === "missed_run_plus_120") {
    return "Run still available";
  }

  return workoutTitle;
}

function bodyFor(kind: NotificationDispatchKind, workoutTitle: string): string {
  if (kind === "today_plan_midnight") {
    return `${workoutTitle} is on your plan today.`;
  }
  if (kind === "missed_run_plus_60" || kind === "missed_run_plus_120") {
    return `${workoutTitle} was not completed yet.`;
  }

  return `${workoutTitle} starts soon.`;
}

function startTimeMinutes(startTime: string): number {
  const match = /^([01]\d|2[0-3]):([0-5]\d)$/.exec(startTime);
  if (match === null) {
    return Number.NaN;
  }

  const hour = Number(match[1]);
  const minute = Number(match[2]);

  return hour * 60 + minute;
}

function singaporeLocalTime(now: string): SingaporeLocalTime {
  const date = new Date(now);
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Singapore",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);

  return {
    date: `${partValue(parts, "year")}-${partValue(parts, "month")}-${partValue(parts, "day")}`,
    hour: Number(partValue(parts, "hour")),
    minute: Number(partValue(parts, "minute")),
  };
}

function partValue(parts: readonly Intl.DateTimeFormatPart[], type: Intl.DateTimeFormatPartTypes): string {
  for (const part of parts) {
    if (part.type === type) {
      return part.value;
    }
  }

  return "";
}
