import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/home/presentation/home_tab.dart';
import 'package:runiac_app/features/plan/domain/models/plan_progress_read_model.dart';
import 'package:runiac_app/features/plan/domain/plan_completion_seen_store.dart';
import 'package:runiac_app/features/profile/data/static_user_profile_repository.dart';
import 'package:runiac_app/features/profile/domain/repositories/user_profile_persistence_repository.dart';

import 'support/fake_runiac_auth_repository.dart';

const _activePlanId = 'plan-alpha';
final _completedAt = DateTime.utc(2026, 7, 5, 9, 30);

Map<String, Object?> _backendData({
  required String completionPlanId,
  String completedAt = '2026-07-05T09:30:00.000Z',
}) {
  return <String, Object?>{
    'workouts': <String, Object?>{
      '${_activePlanId}__w1': <String, Object?>{
        'completedAt': '2026-07-02T00:00:00.000Z',
      },
    },
    'planCompletions': <String, Object?>{
      completionPlanId: <String, Object?>{
        'planId': completionPlanId,
        'completedAt': completedAt,
        'completedWorkoutCount': 3,
        'plannedWorkoutTotal': 3,
      },
    },
  };
}

Future<void> _pumpHomeTab(
  WidgetTester tester, {
  required DateTime? planCompletedAt,
  required PlanCompletionSeenStore? seenStore,
}) async {
  final authRepository = FakeRuniacAuthRepository()
    ..emitSignedIn(uid: 'runner-1');
  await tester.pumpWidget(
    MaterialApp(
      home: HomeTab(
        authRepository: authRepository,
        profileRepository: const StaticUserProfileRepository(),
        profilePersistenceRepository:
            const NoopUserProfilePersistenceRepository(),
        planCompletedAt: planCompletedAt,
        planCompletionSeenStore: seenStore,
        enableForegroundGps: false,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('PlanProgressReadModel.planCompletedAt', () {
    test('reads the backend completion for the active plan', () {
      final model = PlanProgressReadModel.fromBackend(
        activeGeneratedPlanId: _activePlanId,
        data: _backendData(completionPlanId: _activePlanId),
      );

      expect(model.planCompletedAt, _completedAt.toLocal());
      expect(model.completedScheduledWorkoutIds, {'w1'});
    });

    test('ignores a completion recorded for a different plan', () {
      final model = PlanProgressReadModel.fromBackend(
        activeGeneratedPlanId: _activePlanId,
        data: _backendData(completionPlanId: 'plan-previous'),
      );

      expect(model.planCompletedAt, isNull);
    });

    test('is null when the backend recorded no completion', () {
      final model = PlanProgressReadModel.fromBackend(
        activeGeneratedPlanId: _activePlanId,
        data: const <String, Object?>{
          'workouts': <String, Object?>{},
        },
      );

      expect(model.planCompletedAt, isNull);
    });

    test('survives a malformed completion entry', () {
      final model = PlanProgressReadModel.fromBackend(
        activeGeneratedPlanId: _activePlanId,
        data: const <String, Object?>{
          'workouts': <String, Object?>{},
          'planCompletions': <String, Object?>{
            _activePlanId: <String, Object?>{'completedAt': 42},
          },
        },
      );

      expect(model.planCompletedAt, isNull);
    });

    test('is preserved when the plan has no per-workout entries', () {
      final model = PlanProgressReadModel.fromBackend(
        activeGeneratedPlanId: _activePlanId,
        data: <String, Object?>{
          'planCompletions': _backendData(
            completionPlanId: _activePlanId,
          )['planCompletions'],
        },
      );

      expect(model.planCompletedAt, _completedAt.toLocal());
    });
  });

  group('HomeTab plan-completion ceremony', () {
    testWidgets('celebrates a newly recorded completion once', (tester) async {
      final seenStore = InMemoryPlanCompletionSeenStore();

      await _pumpHomeTab(
        tester,
        planCompletedAt: _completedAt,
        seenStore: seenStore,
      );

      expect(find.text('Plan Completed!'), findsOneWidget);
      expect(
        await seenStore.lastSeenPlanCompletedAtMs(),
        _completedAt.millisecondsSinceEpoch,
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Plan Completed!'), findsNothing);
    });

    testWidgets('does not re-celebrate an already-seen completion', (
      tester,
    ) async {
      final seenStore = InMemoryPlanCompletionSeenStore(
        initialCompletedAtMs: _completedAt.millisecondsSinceEpoch,
      );

      await _pumpHomeTab(
        tester,
        planCompletedAt: _completedAt,
        seenStore: seenStore,
      );

      expect(find.text('Plan Completed!'), findsNothing);
    });

    testWidgets('stays silent while the plan is still in progress', (
      tester,
    ) async {
      await _pumpHomeTab(
        tester,
        planCompletedAt: null,
        seenStore: InMemoryPlanCompletionSeenStore(),
      );

      expect(find.text('Plan Completed!'), findsNothing);
    });

    testWidgets('stays silent when no seen store is composed', (tester) async {
      await _pumpHomeTab(
        tester,
        planCompletedAt: _completedAt,
        seenStore: null,
      );

      expect(find.text('Plan Completed!'), findsNothing);
    });

    testWidgets('celebrates a completion that arrives after the first frame', (
      tester,
    ) async {
      final seenStore = InMemoryPlanCompletionSeenStore();
      final authRepository = FakeRuniacAuthRepository()
        ..emitSignedIn(uid: 'runner-1');

      Widget buildHome({required DateTime? planCompletedAt}) {
        return MaterialApp(
          home: HomeTab(
            authRepository: authRepository,
            profileRepository: const StaticUserProfileRepository(),
            profilePersistenceRepository:
                const NoopUserProfilePersistenceRepository(),
            planCompletedAt: planCompletedAt,
            planCompletionSeenStore: seenStore,
            enableForegroundGps: false,
          ),
        );
      }

      await tester.pumpWidget(buildHome(planCompletedAt: null));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Plan Completed!'), findsNothing);

      // The async plan-progress load resolves and pushes the signal down.
      await tester.pumpWidget(buildHome(planCompletedAt: _completedAt));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Plan Completed!'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });
  });
}
