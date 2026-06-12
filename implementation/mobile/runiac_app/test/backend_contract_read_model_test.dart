import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/home/domain/models/home_dashboard_read_model.dart';
import 'package:runiac_app/features/leaderboard/domain/models/leaderboard_entry_read_model.dart';
import 'package:runiac_app/features/maps/domain/models/route_read_model.dart';
import 'package:runiac_app/features/run/domain/models/run_activity_read_model.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_read_model.dart';
import 'package:runiac_app/features/you/domain/models/user_progress_read_model.dart';

void main() {
  group('Backend contract read models', () {
    test('constructs immutable backend-produced read models', () {
      // Given: backend-produced display/read outputs for each current feature.
      const activity = RunActivityReadModel(
        activityId: 'activity_20260612_001',
        title: 'Saturday Morning Run',
        completedAtLabel: 'Today · 7:06 AM',
        distanceLabel: '4.03 km',
        durationLabel: '30:15',
        avgPaceLabel: '6’30” / km',
        routeLabel: 'East Coast Park Loop',
      );
      const summary = RunSummaryReadModel(
        summaryId: 'summary_20260612_001',
        title: 'Saturday Morning Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceLabel: '4.03 km',
        avgPaceLabel: '6’30” / km',
        durationLabel: '30:15',
        avgHeartRateLabel: '145 bpm',
        caloriesLabel: '212 kcal',
        routeName: 'East Coast Park Loop',
      );
      const route = RouteReadModel(
        routeId: 'route_east_coast_easy',
        title: 'East Coast flat run',
        distanceLabel: '4.0 km',
        durationLabel: '32 min',
        difficultyLabel: 'Easy',
        locationLabel: 'East Coast',
      );
      const home = HomeDashboardReadModel(
        todayPlanTitle: '20 min easy run',
        todayPlanSubtitle: 'Comfortable effort',
        goalTitle: 'First 10K Preparation',
        goalProgressLabel: '43%',
        streakLabel: '6 days',
        xpLabel: '1,240 XP',
        levelLabel: 'Level 12',
        weeklySummaryLabel: '3 runs this week',
      );
      const leaderboardEntry = LeaderboardEntryReadModel(
        userId: 'user_123',
        displayName: 'Jinseo',
        rankLabel: '#12',
        scoreLabel: '1,240 XP',
        levelLabel: 'Level 12',
        divisionLabel: 'Bronze',
        regionLabel: 'Jurong East',
      );
      const progress = UserProgressReadModel(
        userId: 'user_123',
        streakLabel: '6 days',
        levelLabel: 'Level 12',
        totalXpLabel: '2,520 XP',
        weeklyXpLabel: '520 XP',
        monthlyXpLabel: '1,240 XP',
        weeklyDistanceLabel: '12.4 km',
        goalProgressLabel: '43%',
      );

      // When / Then: the read models expose immutable backend-produced labels.
      expect(activity.activityId, 'activity_20260612_001');
      expect(activity.avgPaceLabel, '6’30” / km');
      expect(summary.summaryId, 'summary_20260612_001');
      expect(summary.caloriesLabel, '212 kcal');
      expect(route.routeId, 'route_east_coast_easy');
      expect(route.locationLabel, 'East Coast');
      expect(home.todayPlanTitle, '20 min easy run');
      expect(home.xpLabel, '1,240 XP');
      expect(leaderboardEntry.rankLabel, '#12');
      expect(leaderboardEntry.scoreLabel, '1,240 XP');
      expect(progress.weeklyXpLabel, '520 XP');
      expect(progress.monthlyXpLabel, '1,240 XP');
    });

    test('keeps read model sources backend-free and immutable', () {
      // Given: only the new read model files and the existing raw payload file.
      const readModelPaths = [
        _ReadModelContract(
          path: 'lib/features/run/domain/models/run_activity_read_model.dart',
          className: 'RunActivityReadModel',
          fields: [
            'activityId',
            'title',
            'completedAtLabel',
            'distanceLabel',
            'durationLabel',
            'avgPaceLabel',
            'routeLabel',
          ],
        ),
        _ReadModelContract(
          path: 'lib/features/run/domain/models/run_summary_read_model.dart',
          className: 'RunSummaryReadModel',
          fields: [
            'summaryId',
            'title',
            'dateLabel',
            'timeLabel',
            'distanceLabel',
            'avgPaceLabel',
            'durationLabel',
            'avgHeartRateLabel',
            'caloriesLabel',
            'routeName',
          ],
        ),
        _ReadModelContract(
          path: 'lib/features/maps/domain/models/route_read_model.dart',
          className: 'RouteReadModel',
          fields: [
            'routeId',
            'title',
            'distanceLabel',
            'durationLabel',
            'difficultyLabel',
            'locationLabel',
          ],
        ),
        _ReadModelContract(
          path:
              'lib/features/home/domain/models/home_dashboard_read_model.dart',
          className: 'HomeDashboardReadModel',
          fields: [
            'todayPlanTitle',
            'todayPlanSubtitle',
            'goalTitle',
            'goalProgressLabel',
            'streakLabel',
            'xpLabel',
            'levelLabel',
            'weeklySummaryLabel',
          ],
        ),
        _ReadModelContract(
          path:
              'lib/features/leaderboard/domain/models/'
              'leaderboard_entry_read_model.dart',
          className: 'LeaderboardEntryReadModel',
          fields: [
            'userId',
            'displayName',
            'rankLabel',
            'scoreLabel',
            'levelLabel',
            'divisionLabel',
            'regionLabel',
          ],
        ),
        _ReadModelContract(
          path: 'lib/features/you/domain/models/user_progress_read_model.dart',
          className: 'UserProgressReadModel',
          fields: [
            'userId',
            'streakLabel',
            'levelLabel',
            'totalXpLabel',
            'weeklyXpLabel',
            'monthlyXpLabel',
            'weeklyDistanceLabel',
            'goalProgressLabel',
          ],
        ),
      ];
      const forbiddenTerms = [
        'Firebase',
        'Firestore',
        'Auth',
        'firebase_core',
        'cloud_firestore',
        'firebase_auth',
        'collection(',
        'doc(',
        'set(',
        'update(',
        'fromJson',
        'toJson',
        'Repository',
        'repository',
        'Service',
        'service',
        'Datasource',
        'datasource',
        'calculateXP',
        'calculateLevel',
        'calculateStreak',
        'calculateRank',
        'aggregateWeeklyXp',
        'aggregateMonthlyXp',
        'deriveLeaderboard',
        'validateActivity',
        'countsTowardProgression',
      ];

      // When / Then: read models are simple immutable display contracts.
      for (final contract in readModelPaths) {
        final source = File(contract.path).readAsStringSync();

        _expectReadModelContract(source, contract);
        expect(source, isNot(contains('var ')));

        for (final term in forbiddenTerms) {
          expect(
            source,
            isNot(contains(term)),
            reason: '${contract.path} contains $term',
          );
        }
      }

      final payloadSource = File(
        'lib/features/run/domain/models/run_completed_payload.dart',
      ).readAsStringSync();

      for (final term in forbiddenTerms) {
        expect(
          payloadSource,
          isNot(contains(term)),
          reason: 'RunCompletedPayload contains $term',
        );
      }

      for (final importName in [
        'run_activity_read_model.dart',
        'run_summary_read_model.dart',
        'route_read_model.dart',
        'home_dashboard_read_model.dart',
        'leaderboard_entry_read_model.dart',
        'user_progress_read_model.dart',
      ]) {
        expect(payloadSource, isNot(contains(importName)));
      }
    });
  });
}

class _ReadModelContract {
  const _ReadModelContract({
    required this.path,
    required this.className,
    required this.fields,
  });

  final String path;
  final String className;
  final List<String> fields;
}

void _expectReadModelContract(String source, _ReadModelContract contract) {
  expect(source, contains('class ${contract.className} {'));
  expect(source, contains('const ${contract.className}({'));

  final declaredFields = RegExp(
    r'^[ \t]*final String ([A-Za-z0-9_]+);$',
    multiLine: true,
  ).allMatches(source).map((match) => match.group(1)).toList();
  expect(declaredFields, contract.fields, reason: contract.path);

  final disallowedFieldDeclarations =
      RegExp(
        r'^[ \t]*(?:late[ \t]+)?(?:final|var|String|int|double|bool|DateTime|List|Map|Set)\b.*$',
        multiLine: true,
      ).allMatches(source).where((match) {
        final line = match.group(0) ?? '';
        return !line.trim().startsWith('final String ');
      }).toList();
  expect(disallowedFieldDeclarations, isEmpty, reason: contract.path);

  expect(
    source,
    isNot(
      matches(
        RegExp(
          r'^[ \t]*(?:set[ \t]+[A-Za-z0-9_]+\(|[A-Za-z0-9_<>,? ]+[ \t]+get[ \t]+[A-Za-z0-9_]+)',
          multiLine: true,
        ),
      ),
    ),
    reason: contract.path,
  );
  final methodLikeLines = source.split('\n').where((line) {
    final trimmed = line.trim();
    final isConstructor = trimmed.startsWith('const ${contract.className}(');
    final isParameter = trimmed.startsWith('required this.');
    return trimmed.contains('(') && !isConstructor && !isParameter;
  }).toList();
  expect(methodLikeLines, isEmpty, reason: contract.path);
}
