import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/data/static_user_profile_repository.dart';
import 'package:runiac_app/features/account/data/static_viewer_access_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/viewer_access_repository.dart';
import 'package:runiac_app/features/home/data/static_home_dashboard_repository.dart';
import 'package:runiac_app/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:runiac_app/features/leaderboard/data/static_leaderboard_repository.dart';
import 'package:runiac_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:runiac_app/features/maps/data/static_shared_routes_repository.dart';
import 'package:runiac_app/features/maps/domain/repositories/shared_routes_repository.dart';
import 'package:runiac_app/features/run/data/static_run_repository.dart';
import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/repositories/run_repository.dart';
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
      expect(HomeDashboardRepository, isA<Type>());
      expect(RunRepository, isA<Type>());
    });

    test('repository interfaces expose only approved methods', () {
      const repositoryContracts = <_RepositoryContract>[
        _RepositoryContract(
          path:
              'lib/features/account/domain/repositories/'
              'user_profile_repository.dart',
          declarations: <String>[
            'Future<UserProfileReadModel> loadUserProfile();',
          ],
        ),
        _RepositoryContract(
          path:
              'lib/features/you/domain/repositories/'
              'activity_history_repository.dart',
          declarations: <String>[
            'Future<ActivityHistoryReadModel> loadActivityHistory();',
          ],
        ),
        _RepositoryContract(
          path:
              'lib/features/leaderboard/domain/repositories/'
              'leaderboard_repository.dart',
          declarations: <String>[
            'Future<LeaderboardReadModel> loadLeaderboard();',
          ],
        ),
        _RepositoryContract(
          path:
              'lib/features/maps/domain/repositories/'
              'shared_routes_repository.dart',
          declarations: <String>[
            'Future<SharedRoutesReadModel> loadSharedRoutes();',
          ],
        ),
        _RepositoryContract(
          path:
              'lib/features/you/domain/repositories/'
              'expert_plans_repository.dart',
          declarations: <String>[
            'Future<ExpertPlansReadModel> loadExpertPlans();',
          ],
        ),
        _RepositoryContract(
          path:
              'lib/features/account/domain/repositories/'
              'viewer_access_repository.dart',
          declarations: <String>[
            'Future<ViewerAccessReadModel> loadViewerAccess();',
          ],
        ),
        _RepositoryContract(
          path:
              'lib/features/home/domain/repositories/'
              'home_dashboard_repository.dart',
          declarations: <String>[
            'Future<HomeDashboardReadModel> loadHomeDashboard();',
          ],
        ),
        _RepositoryContract(
          path: 'lib/features/run/domain/repositories/run_repository.dart',
          declarations: <String>[
            'Future<RunSummaryReadModel> loadLatestRunSummary();',
            'Future<CompleteRunResult> loadLatestCompletionResult();',
            'Future<RunActivityReadModel> loadLatestRunActivity();',
            'Future<CompleteRunResult> completeRun(LocalRunCompletionPayload payload);',
          ],
          allowedCommandMethods: <String>['completeRun'],
        ),
      ];

      for (final contract in repositoryContracts) {
        final source = File(contract.path).readAsStringSync();
        final className = contract.path
            .split('/')
            .last
            .replaceFirst('.dart', '')
            .split('_')
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join();
        final declarations = _repositoryInterfaceDeclarations(
          source,
          className,
        );
        final methods = declarations.map(_repositoryMethodName).toList();

        expect(declarations, contract.declarations, reason: contract.path);
        for (final method in methods) {
          expect(method, isNotNull, reason: contract.path);
          expect(
            method!.startsWith('load') ||
                contract.allowedCommandMethods.contains(method),
            isTrue,
            reason:
                '${contract.path} contains an unapproved repository member: '
                '$declarations',
          );
        }

        for (final verb in _trustedMutationVerbs) {
          for (final declaration in declarations) {
            if (contract.allowedCommandMethods.contains(verb)) {
              continue;
            }
            expect(
              declaration,
              isNot(contains(RegExp('\\b$verb\\b'))),
              reason: '${contract.path} exposes $verb in $declaration',
            );
          }
        }
      }
    });

    test('Run repository does not expose raw completion payloads', () {
      final source = File(
        'lib/features/run/domain/repositories/run_repository.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('RunCompletedPayload')));
      expect(source, contains('LocalRunCompletionPayload'));
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

    test('return demo-preserving Home dashboard values', () async {
      final repository = StaticHomeDashboardRepository();

      final dashboard = await repository.loadHomeDashboard();

      expect(dashboard.todayPlanTitle, '20 min easy run');
      expect(dashboard.goalTitle, 'First 10K Preparation');
      expect(dashboard.goalProgressLabel, '43%');
      expect(dashboard.streakLabel, '6 days');
      expect(dashboard.xpLabel, '1,240 xp');
      expect(dashboard.levelLabel, '360 XP to Lv.13');
      expect(dashboard.weeklySummaryLabel, 'Week 3 of 8');
    });

    test('return demo-preserving Run values', () async {
      final repository = StaticRunRepository();
      final payload = LocalRunCompletionPayload(
        clientRunSessionId: 'local-session-20260614-0700',
        startedAt: DateTime.utc(2026, 6, 14, 7),
        completedAt: DateTime.utc(2026, 6, 14, 7, 25),
        durationSeconds: 1500,
        distanceMeters: 3200,
        avgPaceSecondsPerKm: 469,
        source: 'local_simulation',
        routePrivacy: 'private',
        routeLabel: 'Repository Result Route',
        clientAppVersion: 'm3-test',
      );

      final summary = await repository.loadLatestRunSummary();
      final completion = await repository.loadLatestCompletionResult();
      final completedRun = await repository.completeRun(payload);
      final activity = await repository.loadLatestRunActivity();

      expect(summary.title, 'Saturday Morning Run');
      expect(summary.distanceLabel, '4.03 km');
      expect(summary.avgPaceLabel, '6’30”');
      expect(summary.routeName, 'East Coast Park Loop');
      expect(completion.xpUpdate.earnedXpLabel, '+120 XP');
      expect(completion.xpUpdate.streakChangeLabel, '5 → 6 days');
      expect(completedRun.activityId, 'static-local-session-20260614-0700');
      expect(
        completedRun.summaryId,
        'static-summary-local-session-20260614-0700',
      );
      expect(
        completedRun.progressionEventId,
        'static-progression-local-session-20260614-0700',
      );
      expect(completedRun.validationStatus, 'validated');
      expect(completedRun.summary.title, 'Sunday Morning Run');
      expect(completedRun.summary.distanceKm, '3.20');
      expect(completedRun.summary.duration, '25:00');
      expect(completedRun.summary.avgPace, '7’49”');
      expect(completedRun.summary.calories, '270');
      expect(completedRun.progressionDisplay.xpDelta, 0);
      expect(completedRun.progressionDisplay.countsTowardLeaderboard, isFalse);
      expect(completedRun.progressionDisplay.status, 'deferred');
      expect(
        completedRun.progressionDisplay.reason,
        'progression_formula_deferred',
      );
      expect(activity.title, 'Saturday Morning Run');
      expect(activity.routeLabel, 'East Coast Park Loop');
    });

    test(
      'completeRun returns zero summary values for zero run payloads',
      () async {
        final repository = StaticRunRepository();
        final payload = LocalRunCompletionPayload(
          clientRunSessionId: 'zero-run-session',
          startedAt: DateTime.utc(2026, 6, 14, 7),
          completedAt: DateTime.utc(2026, 6, 14, 7),
          durationSeconds: 0,
          distanceMeters: 0,
          avgPaceSecondsPerKm: 0,
          source: 'local_simulation',
          routePrivacy: 'private',
          routeLabel: 'Easy local route',
          clientAppVersion: 'zero-run-test',
        );

        final completedRun = await repository.completeRun(payload);

        expect(completedRun.summary.title, 'Sunday Morning Run');
        expect(completedRun.summary.distanceKm, '0.00');
        expect(completedRun.summary.duration, '0:00');
        expect(completedRun.summary.avgPace, '--');
        expect(completedRun.summary.avgHeartRate, '--');
        expect(completedRun.summary.calories, '--');
        expect(completedRun.summary.routeName, 'Easy local route');
        expect(completedRun.summary.title, isNot('Easy local route'));
        expect(completedRun.summary.distanceKm, isNot('4.03'));
        expect(completedRun.summary.avgPace, isNot('6’30”'));
        expect(completedRun.summary.duration, isNot('30:15'));
        expect(completedRun.summary.avgHeartRate, isNot('145'));
        expect(completedRun.summary.calories, isNot('145'));
        expect(completedRun.summary.routeName, isNot('East Coast Park Loop'));
        expect(completedRun.xpUpdate.earnedXpLabel, '+0 XP');
        expect(completedRun.xpUpdate.streakChangeLabel, 'Deferred');
      },
    );

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

    test('new Home and Run seam files stay Firebase-free', () {
      const seamPaths = <String>[
        'lib/features/home/domain/repositories/home_dashboard_repository.dart',
        'lib/features/home/data/static_home_dashboard_repository.dart',
        'lib/features/run/domain/repositories/run_repository.dart',
        'lib/features/run/data/static_run_repository.dart',
      ];
      const forbiddenBackendTerms = <String>[
        'Firebase',
        'Firestore',
        'FirebaseAuth',
        'FirebaseFirestore',
        'firebase_core',
        'cloud_firestore',
        'firebase_auth',
        'collection(',
        'doc(',
        'set(',
        'update(',
      ];

      for (final path in seamPaths) {
        final source = File(path).readAsStringSync();

        for (final term in forbiddenBackendTerms) {
          expect(source, isNot(contains(term)), reason: '$path contains $term');
        }
      }
    });
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
  'completeRun',
  'submitRun',
  'saveRun',
  'syncRun',
  'validateRun',
  'uploadRun',
  'persistRun',
];

class _RepositoryContract {
  const _RepositoryContract({
    required this.path,
    required this.declarations,
    this.allowedCommandMethods = const <String>[],
  });

  final String path;
  final List<String> declarations;
  final List<String> allowedCommandMethods;
}

List<String> _repositoryInterfaceDeclarations(String source, String className) {
  final uncommentedSource = _removeDartComments(source);
  final classMatch = RegExp(
    'abstract\\s+interface\\s+class\\s+$className\\s*{',
  ).firstMatch(uncommentedSource);

  expect(classMatch, isNotNull, reason: 'Missing $className declaration');

  final bodyStart = classMatch!.end;
  var depth = 1;
  for (var index = bodyStart; index < uncommentedSource.length; index += 1) {
    final char = uncommentedSource[index];

    if (char == '{') {
      depth += 1;
    } else if (char == '}') {
      depth -= 1;

      if (depth == 0) {
        return _splitTopLevelDeclarations(
          uncommentedSource.substring(bodyStart, index),
        );
      }
    }
  }

  fail('Missing closing brace for $className');
}

String _removeDartComments(String source) {
  return source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//.*', multiLine: true), '');
}

List<String> _splitTopLevelDeclarations(String body) {
  final declarations = <String>[];
  final buffer = StringBuffer();
  var angleDepth = 0;
  var parenthesisDepth = 0;
  var bracketDepth = 0;

  for (var index = 0; index < body.length; index += 1) {
    final char = body[index];

    if (char == '<') {
      angleDepth += 1;
    } else if (char == '>' && angleDepth > 0) {
      angleDepth -= 1;
    } else if (char == '(') {
      parenthesisDepth += 1;
    } else if (char == ')' && parenthesisDepth > 0) {
      parenthesisDepth -= 1;
    } else if (char == '[') {
      bracketDepth += 1;
    } else if (char == ']' && bracketDepth > 0) {
      bracketDepth -= 1;
    }

    buffer.write(char);

    if (char == ';' &&
        angleDepth == 0 &&
        parenthesisDepth == 0 &&
        bracketDepth == 0) {
      declarations.add(_normalizeDeclaration(buffer.toString()));
      buffer.clear();
    }
  }

  final trailingBody = buffer.toString().trim();
  expect(trailingBody, isEmpty, reason: 'Unexpected repository body content');

  return declarations;
}

String _normalizeDeclaration(String declaration) {
  return declaration.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String? _repositoryMethodName(String declaration) {
  return RegExp(
    r'^[A-Za-z0-9_<>, ?]+ ([A-Za-z0-9]+)\([^;]*\);$',
  ).firstMatch(declaration)?.group(1);
}
