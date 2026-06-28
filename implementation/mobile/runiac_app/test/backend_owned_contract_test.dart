import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/contracts/backend_owned_value_contract.dart';
import 'package:runiac_app/features/account/domain/models/user_profile_read_model.dart';
import 'package:runiac_app/features/account/domain/models/viewer_access_read_model.dart';
import 'package:runiac_app/features/leaderboard/domain/models/leaderboard_read_model.dart';
import 'package:runiac_app/features/maps/domain/models/shared_routes_read_model.dart';
import 'package:runiac_app/features/you/domain/models/activity_history_read_model.dart';
import 'package:runiac_app/features/you/domain/models/expert_plans_read_model.dart';

void main() {
  group('BackendOwnedValueContract', () {
    test('exposes protected backend-owned field names', () {
      expect(
        BackendOwnedValueContract.protectedFieldNames,
        containsAll(<String>[
          'xp',
          'level',
          'rank',
          'streak',
          'leaderboardScore',
          'weeklyXp',
          'monthlyXp',
          'subscriptionPrivilegeState',
          'expertPlanPublicationState',
          'validatedActivityContributionState',
        ]),
      );
    });

    test('forbids client mutation verbs for trusted backend-owned values', () {
      expect(
        BackendOwnedValueContract.forbiddenClientMutationVerbs,
        containsAll(<String>[
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
        ]),
      );
    });
  });

  group('Backend seam read models', () {
    test('construct display-only user profile output', () {
      final profile = UserProfileReadModel(
        userId: 'demo-user',
        displayName: 'Runiac Runner',
        avatarInitials: 'RR',
        locationLabel: 'Singapore',
      );

      expect(profile.displayName, 'Runiac Runner');
      expect(profile.avatarInitials, 'RR');
    });

    test('construct display-only activity history output', () {
      final history = ActivityHistoryReadModel(
        recentRuns: <ActivityHistoryItemReadModel>[
          ActivityHistoryItemReadModel(
            activityId: 'demo-activity-001',
            title: 'Easy Marina Bay run',
            completedAtLabel: 'Today',
            distanceLabel: '3.2 km',
            paceLabel: '7:20 / km',
          ),
        ],
      );

      expect(history.recentRuns.single.title, 'Easy Marina Bay run');
    });

    test('construct display-only leaderboard output', () {
      final leaderboard = LeaderboardReadModel(
        regionLabel: 'Singapore',
        currentRunnerRankLabel: 'Display after first run',
        entries: <LeaderboardRowReadModel>[
          LeaderboardRowReadModel(
            userId: 'demo-user',
            displayName: 'Runiac Runner',
            rankLabel: 'Pending',
            scoreLabel: 'Runs count after backend validation',
          ),
        ],
      );

      expect(leaderboard.regionLabel, 'Singapore');
      expect(leaderboard.entries.single.rankLabel, 'Pending');
    });

    test('construct display-only shared routes output', () {
      final routes = SharedRoutesReadModel(
        selectedRoute: SharedRouteReadModel(
          routeId: 'marina-bay-easy-loop',
          title: 'Marina Bay easy loop',
          distanceLabel: '3.2 km',
          difficultyLabel: 'Easy',
        ),
        routes: <SharedRouteReadModel>[],
      );

      expect(routes.selectedRoute.title, 'Marina Bay easy loop');
    });

    test('construct display-only expert plans output', () {
      final plans = ExpertPlansReadModel(
        plans: <ExpertPlanReadModel>[
          ExpertPlanReadModel(
            planId: 'first-5k-preparation',
            title: 'First 5K Preparation',
            authorLabel: 'Coach reviewed',
            publicationStatusLabel: 'Approved',
          ),
        ],
      );

      expect(plans.plans.first.title, 'First 5K Preparation');
    });

    test('construct display-only viewer access output', () {
      const access = ViewerAccessReadModel(
        subscriptionStatusLabel: 'Basic',
        userRoleLabel: 'Basic User',
      );

      expect(access.subscriptionStatusLabel, 'Basic');
      expect(access.userRoleLabel, 'Basic User');
    });

    test('defensively copies collection fields into unmodifiable lists', () {
      final profileSetupItems = <UserProfileInfoItemReadModel>[
        const UserProfileInfoItemReadModel(title: 'Region', value: 'Singapore'),
      ];
      final leaderboardEntries = <LeaderboardRowReadModel>[
        const LeaderboardRowReadModel(
          userId: 'demo-user',
          displayName: 'Runiac Runner',
          rankLabel: 'Pending',
          scoreLabel: 'Backend validated',
        ),
      ];
      final routes = <SharedRouteReadModel>[
        const SharedRouteReadModel(
          routeId: 'route-1',
          title: 'Route 1',
          distanceLabel: '3 km',
          difficultyLabel: 'Easy',
        ),
      ];
      final activities = <ActivityHistoryItemReadModel>[
        const ActivityHistoryItemReadModel(
          activityId: 'activity-1',
          title: 'Easy run',
          completedAtLabel: 'Today',
          distanceLabel: '3 km',
          paceLabel: '7:00 / km',
        ),
      ];
      final filters = <String>['Beginner'];
      final bullets = <String>['Start easy'];
      final weeks = <ExpertPlanWeekReadModel>[
        ExpertPlanWeekReadModel(
          weekLabel: 'Week 1',
          title: 'Build routine',
          bullets: bullets,
        ),
      ];
      final expertPlans = <ExpertPlanReadModel>[
        const ExpertPlanReadModel(
          planId: 'plan-1',
          title: 'First 5K',
          authorLabel: 'Coach reviewed',
          publicationStatusLabel: 'Approved',
        ),
      ];

      final profile = UserProfileReadModel(
        userId: 'demo-user',
        displayName: 'Runiac Runner',
        avatarInitials: 'RR',
        locationLabel: 'Singapore',
        setupItems: profileSetupItems,
      );
      final leaderboard = LeaderboardReadModel(
        regionLabel: 'Singapore',
        currentRunnerRankLabel: 'Pending',
        entries: leaderboardEntries,
      );
      final sharedRoutes = SharedRoutesReadModel(
        selectedRoute: routes.first,
        routes: routes,
      );
      final history = ActivityHistoryReadModel(recentRuns: activities);
      final month = ActivityHistoryMonthReadModel(
        label: 'June',
        activities: activities,
      );
      final detail = ExpertPlanDetailReadModel(
        planId: 'plan-1',
        title: 'First 5K',
        subtitle: 'Beginner plan',
        durationLabel: '8 weeks',
        frequencyLabel: '3 runs / week',
        levelLabel: 'Beginner',
        pressureLabel: 'Gentle',
        coachInsight: 'Keep it easy.',
        weeklyPreview: weeks,
        publicationStatusLabel: 'Approved',
      );
      final plans = ExpertPlansReadModel(
        plans: expertPlans,
        filters: filters,
        featuredPlan: detail,
      );

      profileSetupItems.clear();
      leaderboardEntries.clear();
      routes.clear();
      activities.clear();
      filters.clear();
      bullets.clear();
      weeks.clear();
      expertPlans.clear();

      expect(profile.setupItems, hasLength(1));
      expect(leaderboard.entries, hasLength(1));
      expect(sharedRoutes.routes, hasLength(1));
      expect(history.recentRuns, hasLength(1));
      expect(month.activities, hasLength(1));
      expect(plans.filters, hasLength(1));
      expect(plans.plans, hasLength(1));
      expect(detail.weeklyPreview, hasLength(1));
      expect(detail.weeklyPreview.single.bullets, hasLength(1));

      expect(
        () => profile.setupItems.add(
          const UserProfileInfoItemReadModel(title: 'Goal', value: '5K'),
        ),
        throwsUnsupportedError,
      );
      expect(() => leaderboard.entries.clear(), throwsUnsupportedError);
      expect(() => sharedRoutes.routes.clear(), throwsUnsupportedError);
      expect(() => history.recentRuns.clear(), throwsUnsupportedError);
      expect(() => month.activities.clear(), throwsUnsupportedError);
      expect(() => plans.filters.add('Advanced'), throwsUnsupportedError);
      expect(() => plans.plans.clear(), throwsUnsupportedError);
      expect(() => detail.weeklyPreview.clear(), throwsUnsupportedError);
      expect(
        () => detail.weeklyPreview.single.bullets.clear(),
        throwsUnsupportedError,
      );
    });
  });

  group('Firestore base boundary', () {
    test('keeps feature code free of Firestore data access APIs', () {
      const allowedProfilePersistencePath =
          'lib/features/account/data/'
          'firestore_user_profile_persistence_repository.dart';
      const forbiddenFeatureTerms = <String>[
        'package:cloud_firestore',
        'FirebaseFirestore',
        'QuerySnapshot',
        'DocumentSnapshot',
        'CollectionReference',
        'DocumentReference',
        'WriteBatch',
        'Transaction',
        '.collection(',
        '.collectionGroup(',
        '.doc(',
        '.get(',
        '.snapshots(',
        '.set(',
      ];

      for (final file in _dartFilesIn(
        'lib/features',
      ).where((file) => file.path != allowedProfilePersistencePath)) {
        final source = file.readAsStringSync();
        for (final term in forbiddenFeatureTerms) {
          expect(source, isNot(contains(term)), reason: '${file.path}: $term');
        }
      }
    });

    test('limits Firestore feature access to user profile persistence', () {
      final source = File(
        'lib/features/account/data/'
        'firestore_user_profile_persistence_repository.dart',
      ).readAsStringSync();

      expect(source, contains("collection('userProfiles')"));
      expect(source, isNot(contains("collection('users')")));
      expect(source, isNot(contains('FirebaseFirestore get')));
      expect(source, isNot(contains('get firestore')));
      for (final field in BackendOwnedValueContract.protectedFieldNames) {
        expect(source, isNot(contains("'$field'")), reason: field);
      }
    });
  });
}

List<File> _dartFilesIn(String path) {
  final files =
      Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));
  return files;
}
