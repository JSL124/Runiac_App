import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/presentation/models/complete_run_result.dart';
import 'package:runiac_app/features/run/presentation/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/presentation/models/xp_update_display_model.dart';

void main() {
  group('CompleteRunResult', () {
    test('constructs from summary and XP update display models', () {
      const summary = RunSummarySnapshot(
        title: 'Saturday Morning Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03',
        avgPace: '6’30”',
        duration: '30:15',
        avgHeartRate: '145',
        calories: '145',
        routeName: 'East Coast Park Loop',
      );

      const xpUpdate = XpUpdateDisplayModel(
        runnerName: 'Jinseo',
        earnedXpLabel: '+120 XP',
        totalXpLabel: '2,520 XP',
        levelLabel: '12',
        nextLevelLabel: '13',
        progressTargetLabel: 'Progress to Lv.13',
        xpRemainingLabel: '600 XP to go',
        previousProgressFraction: 0.52,
        currentProgressFraction: 0.60,
        streakChangeLabel: '5 -> 6 days',
        streakNote: 'Great consistency!',
        didLevelUp: false,
      );

      const result = CompleteRunResult(summary: summary, xpUpdate: xpUpdate);

      expect(result.summary.title, 'Saturday Morning Run');
      expect(result.summary.distanceKm, '4.03');
      expect(result.summary.dateTimeLabel, 'Today · 7:06 AM');
      expect(result.xpUpdate.earnedXpLabel, '+120 XP');
      expect(result.xpUpdate.levelLabel, '12');
      expect(result.xpUpdate.streakChangeLabel, '5 -> 6 days');
    });

    test('source stays presentation-only and backend free', () {
      final source = File(
        'lib/features/run/presentation/models/complete_run_result.dart',
      ).readAsStringSync();

      const forbiddenTerms = [
        'Firebase',
        'Firestore',
        'Auth',
        'SharedPreferences',
        'validationStatus',
        'countsTowardProgression',
        'leaderboardScore',
        'weeklyXp',
        'monthlyXp',
        'subscriptionPrivilegeState',
        'expertPlanPublicationState',
        'calculateXP',
        'calculateLevel',
        'calculateStreak',
        'save',
        'upload',
        'sync',
        'submit',
        'persist',
        'validate',
      ];

      for (final term in forbiddenTerms) {
        expect(source, isNot(contains(term)));
      }
    });
  });
}
