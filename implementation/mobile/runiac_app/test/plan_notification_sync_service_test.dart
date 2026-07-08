import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/notifications/domain/models/notification_center_settings.dart';
import 'package:runiac_app/features/notifications/domain/models/plan_notification_schedule.dart';
import 'package:runiac_app/features/notifications/domain/repositories/notification_center_settings_repository.dart';
import 'package:runiac_app/features/notifications/domain/repositories/plan_notification_scheduler.dart';
import 'package:runiac_app/features/notifications/domain/services/plan_notification_sync_service.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';

void main() {
  group('PlanNotificationSyncService', () {
    test(
      'cancels scheduled notifications when the user turns notifications off',
      () async {
        // Given: native notifications may already have future plan reminders.
        final settingsRepository = InMemoryNotificationCenterSettingsRepository(
          initialSettings: NotificationCenterSettings.defaults.copyWith(
            notificationsEnabled: false,
          ),
        );
        final scheduler = _RecordingPlanNotificationScheduler();
        final service = PlanNotificationSyncService(
          settingsRepository: settingsRepository,
          scheduler: scheduler,
        );

        // When: the app syncs after the master notification toggle is off.
        await service.syncGeneratedPlan(
          _snapshot(
            startsOnDate: '2026-07-06',
            workout: _workout(dayLabel: 'Wed', scheduleTimeLabel: '7:30 AM'),
          ),
          now: DateTime(2026, 7, 7, 9),
        );

        // Then: scheduled native notifications are cleared, and no new
        // permission prompt or schedule sync can send notifications.
        expect(scheduler.cancelCallCount, 1);
        expect(scheduler.requestPermissionCallCount, 0);
        expect(scheduler.syncedNotifications, isEmpty);
      },
    );

    test(
      'syncs explicit streak-risk notifications with generated plan reminders',
      () async {
        // Given: backend-owned/read streak-risk state is supplied explicitly.
        final settingsRepository = InMemoryNotificationCenterSettingsRepository(
          initialSettings: NotificationCenterSettings.defaults,
        );
        final scheduler = _RecordingPlanNotificationScheduler();
        final service = PlanNotificationSyncService(
          settingsRepository: settingsRepository,
          scheduler: scheduler,
        );

        // When: notification sync receives the explicit read-only risk input.
        await service.syncGeneratedPlan(
          _snapshot(
            startsOnDate: '2026-07-06',
            workout: _workout(dayLabel: 'Wed', scheduleTimeLabel: '7:30 AM'),
          ),
          now: DateTime(2026, 7, 8, 21),
          streakRisk: StreakRiskNotificationInput(
            planId: 'generated-plan',
            riskDate: DateTime(2026, 7, 8),
            streakWouldBreakWithoutValidatedRun: true,
          ),
        );

        // Then: local notifications include streak-risk nudges without client
        // writes or trusted XP/streak/leaderboard payload fields.
        final streakRiskNotifications = scheduler.syncedNotifications.where(
          (notification) =>
              notification.kind == PlanNotificationKind.streakRiskNudge,
        );
        expect(
          streakRiskNotifications.map(
            (notification) => notification.scheduledAt,
          ),
          [DateTime(2026, 7, 8, 22), DateTime(2026, 7, 8, 23)],
        );
        expect(
          streakRiskNotifications.every(
            (notification) =>
                !notification.payload.containsKey('xp') &&
                !notification.payload.containsKey('streak') &&
                !notification.payload.containsKey('leaderboardScore'),
          ),
          isTrue,
        );
      },
    );
  });
}

class _RecordingPlanNotificationScheduler implements PlanNotificationScheduler {
  var requestPermissionCallCount = 0;
  var cancelCallCount = 0;
  final syncedNotifications = <ScheduledPlanNotification>[];

  @override
  Future<PlanNotificationPermissionStatus> requestPermission() async {
    requestPermissionCallCount += 1;
    return PlanNotificationPermissionStatus.granted;
  }

  @override
  Future<void> syncPlanNotifications(
    List<ScheduledPlanNotification> notifications,
  ) async {
    syncedNotifications.addAll(notifications);
  }

  @override
  Future<void> cancelPlanNotifications() async {
    cancelCallCount += 1;
  }
}

BeginnerAdaptivePlanSnapshot _snapshot({
  required String startsOnDate,
  required BeginnerAdaptiveWorkout workout,
}) {
  return BeginnerAdaptivePlanSnapshot(
    id: 'generated-plan',
    title: 'Generated plan',
    subtitle: 'Beginner schedule',
    planKind: BeginnerAdaptivePlanKind.onboardingBased,
    sourceLabel: 'Generated onboarding plan',
    startsOnDate: startsOnDate,
    durationWeeks: 1,
    safetyBand: BeginnerPlanSafetyBand.clear,
    templateKind: BeginnerPlanTemplateKind.standardBeginnerStart,
    family: null,
    familyCategory: null,
    familyReason: 'Test fixture',
    supportStyleLabel: 'Gentle',
    weeklyFrequencyLabel: '3 days',
    preferredScheduleLabel: workout.dayLabel,
    sessionDurationLabel: '20 min',
    safetyNote: 'Stop if anything feels wrong.',
    weeks: [
      BeginnerAdaptivePlanWeek(
        weekNumber: 1,
        title: 'Week 1',
        focus: 'Start easy',
        workouts: [workout],
      ),
    ],
  );
}

BeginnerAdaptiveWorkout _workout({
  required String dayLabel,
  String? scheduleTimeLabel,
}) {
  return BeginnerAdaptiveWorkout(
    dayLabel: dayLabel,
    title: 'Easy Run',
    durationMinutes: 20,
    kind: BeginnerWorkoutKind.easyRun,
    intensity: BeginnerPlanIntensity.gentle,
    description: 'Easy effort',
    steps: const ['Warm up', 'Run easy'],
    supportiveNote: 'Keep it relaxed.',
    detail: BeginnerAdaptiveWorkoutDetail(
      metrics: const [
        BeginnerAdaptiveWorkoutMetric(label: 'Time', value: '20 min'),
      ],
      breakdown: const [
        BeginnerAdaptiveWorkoutBreakdownStep(
          kind: BeginnerAdaptiveWorkoutBreakdownStepKind.run,
          title: 'Easy run',
          detail: 'Run relaxed.',
        ),
      ],
      effortGuide: 'Easy',
      coachNotes: const ['Stay conversational.'],
    ),
    scheduleTimeLabel: scheduleTimeLabel,
  );
}
