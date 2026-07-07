import '../../../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../repositories/notification_center_settings_repository.dart';
import '../repositories/plan_notification_scheduler.dart';
import 'generated_plan_notification_schedule_builder.dart';

class PlanNotificationSyncService {
  const PlanNotificationSyncService({
    required this.settingsRepository,
    required this.scheduler,
    this.scheduleBuilder = const GeneratedPlanNotificationScheduleBuilder(),
  });

  final NotificationCenterSettingsRepository settingsRepository;
  final PlanNotificationScheduler scheduler;
  final GeneratedPlanNotificationScheduleBuilder scheduleBuilder;

  Future<void> syncGeneratedPlan(
    BeginnerAdaptivePlanSnapshot? snapshot, {
    required DateTime now,
    Set<String> completedScheduledWorkoutIds = const <String>{},
  }) async {
    final settings = await settingsRepository.loadSettings();
    if (!settings.notificationsEnabled || snapshot == null) {
      await scheduler.cancelPlanNotifications();
      return;
    }

    final permissionStatus = await scheduler.requestPermission();
    if (permissionStatus == PlanNotificationPermissionStatus.denied) {
      return;
    }

    final notifications = scheduleBuilder.notificationsForPlan(
      snapshot,
      settings: settings,
      now: now,
      completedScheduledWorkoutIds: completedScheduledWorkoutIds,
    );
    await scheduler.syncPlanNotifications(notifications);
  }
}
