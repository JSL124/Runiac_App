import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/data/static_user_profile_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'package:runiac_app/features/feed/data/static_feed_repository.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';
import 'package:runiac_app/features/shell/current_day_rollover.dart';
import 'package:runiac_app/features/shell/runiac_shell.dart';
import 'package:runiac_app/features/you/domain/models/user_progress_read_model.dart';
import 'package:runiac_app/features/you/domain/repositories/user_progress_repository.dart';
import 'package:runiac_app/features/you/presentation/current_session_activity_history.dart';

import 'support/fake_runiac_auth_repository.dart';

void main() {
  test('refresh advances the shell date after local midnight', () {
    var now = DateTime(2026, 7, 10, 23, 59);
    final controller = CurrentDayRolloverController(now: () => now);
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications += 1);

    expect(controller.today, DateTime(2026, 7, 10));

    now = DateTime(2026, 7, 11);
    controller.refresh();

    expect(controller.today, DateTime(2026, 7, 11));
    expect(notifications, 1);
  });

  test('next refresh delay targets the next local midnight', () {
    expect(
      nextLocalDayRefreshDelay(DateTime(2026, 7, 10, 23, 59, 30)),
      const Duration(seconds: 30),
    );
  });

  testWidgets('shell refreshes backend-owned progress on local midnight', (
    tester,
  ) async {
    var now = DateTime(2026, 7, 10, 23, 59);
    final controller = CurrentDayRolloverController(now: () => now);
    final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
    final progressRepository = _CountingUserProgressRepository();
    final activityHistoryStore = CurrentSessionActivityHistoryStore(
      ownerUid: 'test-auth-user-1',
    );
    addTearDown(authRepository.dispose);
    addTearDown(activityHistoryStore.dispose);

    final generatedPlanStore = CurrentSessionGeneratedPlanStore();
    addTearDown(generatedPlanStore.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CurrentSessionActivityHistoryScope(
          store: activityHistoryStore,
          child: CurrentSessionGeneratedPlanScope(
            store: generatedPlanStore,
            child: RuniacShell(
              authRepository: authRepository,
              feedRepository: const StaticFeedRepository(),
              userProgressRepository: progressRepository,
              profileRepository: const StaticUserProfileRepository(),
              profilePersistenceRepository:
                  const NoopUserProfilePersistenceRepository(),
              enableForegroundGps: false,
              currentDayRolloverController: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Feed'));
    await tester.pumpAndSettle();

    expect(progressRepository.refreshCalls, 0);

    now = DateTime(2026, 7, 11);
    controller.refresh();
    await tester.pumpAndSettle();

    expect(progressRepository.refreshCalls, 1);
    expect(
      activityHistoryStore.latestUserProgressRefresh?.officialStreakLabel,
      '4 days',
    );
    expect(activityHistoryStore.userProgressRefreshRevision, 1);
    controller.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _CountingUserProgressRepository implements UserProgressRepository {
  int loadCalls = 0;
  int refreshCalls = 0;

  @override
  Future<UserProgressReadModel> loadUserProgress() async {
    loadCalls += 1;
    return _progress;
  }

  @override
  Future<UserProgressReadModel> refreshUserProgress() async {
    refreshCalls += 1;
    return _progress;
  }
}

const _progress = UserProgressReadModel(
  userId: 'test-auth-user-1',
  officialStreakLabel: '4 days',
  levelLabel: 'Level 4',
  totalXpLabel: '400 XP',
  weeklyXpLabel: '',
  monthlyXpLabel: '',
  weeklyDistanceLabel: '',
  goalProgressLabel: '',
);
