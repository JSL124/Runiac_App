enum PlanNotificationKind {
  planStartReminder,
  todaysPlanReminder,
  missedRunNudge,
  planUpdate,
}

class PlanNotificationWorkoutInput {
  const PlanNotificationWorkoutInput({
    required this.planId,
    required this.scheduledWorkoutId,
    required this.title,
    required this.startsAt,
    required this.completed,
  });

  final String planId;
  final String scheduledWorkoutId;
  final String title;
  final DateTime startsAt;
  final bool completed;
}

class ScheduledPlanNotification {
  const ScheduledPlanNotification({
    required this.id,
    required this.kind,
    required this.scheduledAt,
    required this.title,
    required this.body,
    this.payload = const <String, String>{},
  });

  final String id;
  final PlanNotificationKind kind;
  final DateTime scheduledAt;
  final String title;
  final String body;
  final Map<String, String> payload;

  Map<String, Object?> toChannelMap() {
    return <String, Object?>{
      'id': id,
      'kind': kind.name,
      'scheduledAtMillis': scheduledAt.millisecondsSinceEpoch,
      'title': title,
      'body': body,
      'payload': payload,
    };
  }
}
