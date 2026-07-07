import '../models/notification_center_settings.dart';
import '../models/plan_notification_schedule.dart';

class FixedTimePlanNotificationPolicy {
  const FixedTimePlanNotificationPolicy();

  List<ScheduledPlanNotification> notificationsForWorkout(
    PlanNotificationWorkoutInput workout, {
    required NotificationCenterSettings settings,
    required DateTime now,
  }) {
    if (!settings.notificationsEnabled) {
      return const <ScheduledPlanNotification>[];
    }

    final notifications = <ScheduledPlanNotification>[];
    if (settings.todaysPlanReminderEnabled) {
      notifications.add(
        _notification(
          workout,
          kind: PlanNotificationKind.todaysPlanReminder,
          suffix: 'today',
          scheduledAt: DateTime(
            workout.startsAt.year,
            workout.startsAt.month,
            workout.startsAt.day,
          ),
          title: 'Today has a planned run',
          body: '${workout.title} is scheduled for today.',
        ),
      );
    }

    if (settings.planStartReminderEnabled) {
      notifications.addAll([
        _beforeStart(workout, minutesBeforeStart: 120),
        _beforeStart(workout, minutesBeforeStart: 60),
        _beforeStart(workout, minutesBeforeStart: 10),
      ]);
    }

    if (!workout.completed && settings.missedRunNudgeEnabled) {
      notifications.addAll([
        _afterStart(workout, minutesAfterStart: 60),
        _afterStart(workout, minutesAfterStart: 120),
      ]);
    }

    return [
      for (final notification in notifications)
        if (notification.scheduledAt.isAfter(now)) notification,
    ]..sort((left, right) => left.scheduledAt.compareTo(right.scheduledAt));
  }

  ScheduledPlanNotification? planUpdateNotification({
    required String planId,
    required String title,
    required NotificationCenterSettings settings,
    required DateTime now,
  }) {
    if (!settings.notificationsEnabled || !settings.planUpdatesEnabled) {
      return null;
    }
    return ScheduledPlanNotification(
      id: '$planId-plan-update-${now.millisecondsSinceEpoch}',
      kind: PlanNotificationKind.planUpdate,
      scheduledAt: now,
      title: 'New plan update',
      body: title,
      payload: <String, String>{'planId': planId},
    );
  }

  ScheduledPlanNotification _beforeStart(
    PlanNotificationWorkoutInput workout, {
    required int minutesBeforeStart,
  }) {
    final hours = minutesBeforeStart ~/ 60;
    final label = hours > 0 ? '$hours hour${hours == 1 ? '' : 's'}' : '10 min';
    return _notification(
      workout,
      kind: PlanNotificationKind.planStartReminder,
      suffix: 'start-$minutesBeforeStart',
      scheduledAt: workout.startsAt.subtract(
        Duration(minutes: minutesBeforeStart),
      ),
      title: '${workout.title} starts in $label',
      body: 'Open Runiac when you are ready to start.',
    );
  }

  ScheduledPlanNotification _afterStart(
    PlanNotificationWorkoutInput workout, {
    required int minutesAfterStart,
  }) {
    final hours = minutesAfterStart ~/ 60;
    return _notification(
      workout,
      kind: PlanNotificationKind.missedRunNudge,
      suffix: 'missed-$minutesAfterStart',
      scheduledAt: workout.startsAt.add(Duration(minutes: minutesAfterStart)),
      title: 'Still planning to run?',
      body:
          '${workout.title} was scheduled $hours hour${hours == 1 ? '' : 's'} ago.',
    );
  }

  ScheduledPlanNotification _notification(
    PlanNotificationWorkoutInput workout, {
    required PlanNotificationKind kind,
    required String suffix,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) {
    return ScheduledPlanNotification(
      id: '${workout.planId}-${workout.scheduledWorkoutId}-$suffix',
      kind: kind,
      scheduledAt: scheduledAt,
      title: title,
      body: body,
      payload: <String, String>{
        'planId': workout.planId,
        'scheduledWorkoutId': workout.scheduledWorkoutId,
        'kind': kind.name,
      },
    );
  }
}
