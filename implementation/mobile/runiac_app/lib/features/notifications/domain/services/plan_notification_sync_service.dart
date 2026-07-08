import '../../../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../models/notification_inbox_item.dart';
import '../models/plan_notification_schedule.dart';
import '../repositories/notification_center_settings_repository.dart';
import '../repositories/notification_inbox_repository.dart';
import '../repositories/plan_notification_scheduler.dart';
import 'generated_plan_notification_schedule_builder.dart';

class PlanNotificationSyncService {
  const PlanNotificationSyncService({
    required this.settingsRepository,
    required this.scheduler,
    this.inboxRepository,
    this.debugLog,
    this.scheduleBuilder = const GeneratedPlanNotificationScheduleBuilder(),
    this.maxScheduledNotifications = 48,
  });

  final NotificationCenterSettingsRepository settingsRepository;
  final PlanNotificationScheduler scheduler;
  final NotificationInboxRepository? inboxRepository;
  final void Function(String message)? debugLog;
  final GeneratedPlanNotificationScheduleBuilder scheduleBuilder;
  final int maxScheduledNotifications;

  Future<void> syncGeneratedPlan(
    BeginnerAdaptivePlanSnapshot? snapshot, {
    required DateTime now,
    Set<String> completedScheduledWorkoutIds = const <String>{},
    StreakRiskNotificationInput? streakRisk,
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
      streakRisk: streakRisk,
    );
    await scheduler.syncPlanNotifications(_nearestNotifications(notifications));
  }

  Future<void> scheduleSmokeTestNotification({
    required DateTime now,
    required Duration delay,
  }) async {
    final settings = await settingsRepository.loadSettings();
    if (!settings.notificationsEnabled) {
      debugLog?.call(
        'scheduleSmokeTestNotification skipped: notifications disabled',
      );
      return;
    }

    final permissionStatus = await scheduler.requestPermission();
    if (permissionStatus == PlanNotificationPermissionStatus.denied) {
      debugLog?.call(
        'scheduleSmokeTestNotification skipped: permission denied',
      );
      return;
    }

    final notification = ScheduledPlanNotification(
      id: 'local-notification-smoke-test',
      kind: PlanNotificationKind.planUpdate,
      scheduledAt: now.add(delay),
      title: 'Runiac local notification test',
      body: 'If you can see this, iOS local notifications are working.',
      payload: const <String, String>{'kind': 'localNotificationSmokeTest'},
    );
    await scheduler.schedulePlanNotification(notification);
    debugLog?.call(
      'scheduleSmokeTestNotification scheduled id=${notification.id}',
    );
    await _saveInboxItem(notification);
  }

  List<ScheduledPlanNotification> _nearestNotifications(
    List<ScheduledPlanNotification> notifications,
  ) {
    if (notifications.length <= maxScheduledNotifications) {
      return notifications;
    }

    final sortedNotifications = [...notifications]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return sortedNotifications
        .take(maxScheduledNotifications)
        .toList(growable: false);
  }

  Future<void> _saveInboxItem(ScheduledPlanNotification notification) async {
    final repository = inboxRepository;
    if (repository == null) {
      debugLog?.call(
        'saveInboxItem skipped id=${notification.id}: no repository',
      );
      return;
    }

    debugLog?.call('saveInboxItem -> id=${notification.id}');
    await repository.saveInboxItem(
      NotificationInboxItem(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        createdAt: notification.scheduledAt,
        data: <String, Object?>{
          'kind': notification.kind.name,
          ...notification.payload,
        },
      ),
    );
    debugLog?.call('saveInboxItem <- id=${notification.id}');
  }
}
