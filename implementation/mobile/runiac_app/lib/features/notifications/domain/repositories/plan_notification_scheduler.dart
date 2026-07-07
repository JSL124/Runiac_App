import '../models/plan_notification_schedule.dart';

enum PlanNotificationPermissionStatus { granted, denied, notRequired }

abstract interface class PlanNotificationScheduler {
  Future<PlanNotificationPermissionStatus> requestPermission();

  Future<void> syncPlanNotifications(
    List<ScheduledPlanNotification> notifications,
  );

  Future<void> cancelPlanNotifications();
}

class NoopPlanNotificationScheduler implements PlanNotificationScheduler {
  const NoopPlanNotificationScheduler();

  @override
  Future<PlanNotificationPermissionStatus> requestPermission() async {
    return PlanNotificationPermissionStatus.notRequired;
  }

  @override
  Future<void> syncPlanNotifications(
    List<ScheduledPlanNotification> notifications,
  ) async {}

  @override
  Future<void> cancelPlanNotifications() async {}
}
