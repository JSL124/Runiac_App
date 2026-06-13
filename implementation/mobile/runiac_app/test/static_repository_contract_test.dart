import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/data/static_user_profile_repository.dart';
import 'package:runiac_app/features/account/data/static_viewer_access_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/viewer_access_repository.dart';
import 'package:runiac_app/features/leaderboard/data/static_leaderboard_repository.dart';
import 'package:runiac_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:runiac_app/features/maps/data/static_shared_routes_repository.dart';
import 'package:runiac_app/features/maps/domain/repositories/shared_routes_repository.dart';
import 'package:runiac_app/features/you/data/static_activity_history_repository.dart';
import 'package:runiac_app/features/you/data/static_expert_plans_repository.dart';
import 'package:runiac_app/features/you/domain/repositories/activity_history_repository.dart';
import 'package:runiac_app/features/you/domain/repositories/expert_plans_repository.dart';

void main() {
  group('Repository contracts', () {
    test('interfaces expose read-only load methods', () {
      expect(UserProfileRepository, isA<Type>());
      expect(ActivityHistoryRepository, isA<Type>());
      expect(LeaderboardRepository, isA<Type>());
      expect(SharedRoutesRepository, isA<Type>());
      expect(ExpertPlansRepository, isA<Type>());
      expect(ViewerAccessRepository, isA<Type>());
    });

    test('repository interfaces do not expose trusted mutation methods', () {
      const repositoryPaths = <String>[
        'lib/features/account/domain/repositories/user_profile_repository.dart',
        'lib/features/you/domain/repositories/activity_history_repository.dart',
        'lib/features/leaderboard/domain/repositories/leaderboard_repository.dart',
        'lib/features/maps/domain/repositories/shared_routes_repository.dart',
        'lib/features/you/domain/repositories/expert_plans_repository.dart',
        'lib/features/account/domain/repositories/viewer_access_repository.dart',
      ];

      for (final path in repositoryPaths) {
        final source = File(path).readAsStringSync();
        expect(source, contains(RegExp(r'Future<.*> load[A-Za-z0-9]+\(\);')));

        for (final verb in _trustedMutationVerbs) {
          expect(
            source,
            isNot(contains('$verb(')),
            reason: '$path exposes $verb',
          );
        }
      }
    });
  });

  group('Static repositories', () {
    test('return demo-preserving profile values', () async {
      final repository = StaticUserProfileRepository();

      final profile = await repository.loadUserProfile();

      expect(profile.displayName, 'Runiac Runner');
    });

    test('return demo-preserving selected shared route', () async {
      final repository = StaticSharedRoutesRepository();

      final routes = await repository.loadSharedRoutes();

      expect(routes.selectedRoute.title, 'Marina Bay easy loop');
    });

    test('return demo-preserving expert plans', () async {
      final repository = StaticExpertPlansRepository();

      final plans = await repository.loadExpertPlans();

      expect(plans.plans.first.title, 'First 5K Preparation');
    });

    test('return display-only viewer access labels', () async {
      final repository = StaticViewerAccessRepository();

      final access = await repository.loadViewerAccess();

      expect(access.subscriptionStatusLabel, isNotEmpty);
      expect(access.userRoleLabel, isNotEmpty);
    });

    test(
      'return read-only activity history and leaderboard snapshots',
      () async {
        final activityHistoryRepository = StaticActivityHistoryRepository();
        final leaderboardRepository = StaticLeaderboardRepository();

        final history = await activityHistoryRepository.loadActivityHistory();
        final leaderboard = await leaderboardRepository.loadLeaderboard();

        expect(history.recentRuns, isNotEmpty);
        expect(leaderboard.entries, isNotEmpty);
      },
    );
  });
}

const _trustedMutationVerbs = <String>[
  'calculate',
  'derive',
  'aggregate',
  'validate',
  'award',
  'increment',
  'publish',
  'approve',
  'reject',
  'suspend',
  'set',
  'update',
  'delete',
];
