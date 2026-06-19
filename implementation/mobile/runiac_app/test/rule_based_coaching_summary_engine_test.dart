import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/coaching_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/pace_graph_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/services/rule_based_coaching_summary_engine.dart';

void main() {
  group('RuleBasedCoachingSummaryEngine', () {
    test('builds supportive rule-based coaching for sufficient pace data', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(
          paceGraph: const PaceGraphSnapshot(
            isAvailable: true,
            points: [
              PaceGraphPoint(
                elapsedSeconds: 0,
                progressFraction: 0,
                paceSecondsPerKm: 372,
              ),
              PaceGraphPoint(
                elapsedSeconds: 900,
                progressFraction: 0.5,
                paceSecondsPerKm: 378,
              ),
              PaceGraphPoint(
                elapsedSeconds: 1800,
                progressFraction: 1,
                paceSecondsPerKm: 368,
              ),
            ],
            yAxisLabels: ['6:00', '6:30', '7:00'],
            xAxisLabels: ['0', '15', '30'],
          ),
        ),
      );

      expect(coaching.source, CoachingSummarySource.ruleBased);
      expect(coaching.sectionTitle, 'Coaching Summary');
      expect(coaching.headline, isNotEmpty);
      expect(coaching.message, contains('pace graph'));
      expect(coaching.nextAction, 'Keep your next run easy and comfortable.');
      expect(coaching.bullets, hasLength(1));
      expect(_allCopy(coaching), isNot(contains(_aiTitle())));
      expect(_allCopy(coaching), isNot(contains(_blockedCopyTerms())));
    });

    test('keeps scalar-only coaching away from pace graph claims', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(paceGraph: const PaceGraphSnapshot.unavailable()),
      );

      expect(coaching.source, CoachingSummarySource.ruleBased);
      expect(coaching.sectionTitle, 'Coaching Summary');
      expect(_allCopy(coaching), isNot(contains('pace graph')));
      expect(_allCopy(coaching), contains('distance, time, and average pace'));
    });

    test('keeps low-data coaching honest and non-shaming', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(
          distanceKm: '0.03',
          avgPace: '--',
          duration: '0:25',
          calories: '--',
          hasSufficientData: false,
          paceGraph: const PaceGraphSnapshot.unavailable(),
        ),
      );

      final copy = _allCopy(coaching);

      expect(coaching.source, CoachingSummarySource.ruleBased);
      expect(coaching.sectionTitle, 'Coaching Summary');
      expect(copy, contains('limited run data'));
      expect(copy, contains('still counts'));
      expect(coaching.nextAction, 'Try one short easy run with GPS ready.');
      expect(copy, isNot(contains(_blockedCopyTerms())));
      expect(copy, isNot(contains(_unavailableMetricTerms())));
    });

    test('avoids shame guilt and aggressive pressure claims', () {
      final outputs = [
        const RuleBasedCoachingSummaryEngine().build(_summary()),
        const RuleBasedCoachingSummaryEngine().build(
          _summary(paceGraph: PaceGraphSnapshot.unavailable()),
        ),
        const RuleBasedCoachingSummaryEngine().build(
          _summary(hasSufficientData: false, avgPace: '--'),
        ),
      ];

      for (final coaching in outputs) {
        expect(_allCopy(coaching), isNot(contains(_blockedCopyTerms())));
      }
    });

    test('always returns rule-based source in v1', () {
      final summaries = [
        _summary(),
        _summary(paceGraph: const PaceGraphSnapshot.unavailable()),
        _summary(hasSufficientData: false, avgPace: '--'),
      ];

      for (final summary in summaries) {
        expect(
          const RuleBasedCoachingSummaryEngine().build(summary).source,
          CoachingSummarySource.ruleBased,
        );
      }
    });

    test('avoids forbidden copy and unavailable metric claims', () {
      final outputs = [
        const RuleBasedCoachingSummaryEngine().build(_summary()),
        const RuleBasedCoachingSummaryEngine().build(
          _summary(paceGraph: PaceGraphSnapshot.unavailable()),
        ),
        const RuleBasedCoachingSummaryEngine().build(
          _summary(hasSufficientData: false, avgPace: '--'),
        ),
      ];
      final forbidden = RegExp(
        [
          _aiTitle(),
          'sha'
              'me',
          'gu'
              'ilt',
          'cru'
              'sh',
          'des'
              'troy',
          'eli'
              'te',
          'guaran'
              'teed',
          'fitness'
              ' improved',
          'heart'
              ' rate',
          'cad'
              'ence',
          'elev'
              'ation',
          'fati'
              'gue',
          'injury'
              ' risk',
          'VO'
              '2',
          'training'
              ' load',
          'race'
              ' prediction',
          'med'
              'ical',
        ].map(RegExp.escape).join('|'),
        caseSensitive: false,
      );

      for (final coaching in outputs) {
        expect(coaching.sectionTitle, 'Coaching Summary');
        expect(_allCopy(coaching), isNot(contains(forbidden)));
      }
    });
  });
}

RunSummarySnapshot _summary({
  String distanceKm = '4.20',
  String avgPace = '6’12”',
  String duration = '26:02',
  String calories = '245',
  bool hasSufficientData = true,
  PaceGraphSnapshot paceGraph = const PaceGraphSnapshot(
    isAvailable: true,
    points: [
      PaceGraphPoint(
        elapsedSeconds: 0,
        progressFraction: 0,
        paceSecondsPerKm: 372,
      ),
    ],
    yAxisLabels: ['6:00', '6:30'],
    xAxisLabels: ['0', '26'],
  ),
}) {
  return RunSummarySnapshot(
    title: 'Morning Run',
    dateLabel: '19/6/26',
    timeLabel: '7:10 AM',
    distanceKm: distanceKm,
    avgPace: avgPace,
    duration: duration,
    avgHeartRate: '--',
    calories: calories,
    routeName: 'Private route',
    hasSufficientData: hasSufficientData,
    paceGraph: paceGraph,
  );
}

String _allCopy(CoachingSummarySnapshot coaching) {
  return [
    coaching.sectionTitle,
    coaching.headline,
    coaching.message,
    ...coaching.bullets,
    coaching.nextAction,
  ].join('\n');
}

String _aiTitle() =>
    'AI Coaching'
    ' Summary';

RegExp _blockedCopyTerms() {
  return RegExp(
    [
      'sha'
          'me',
      'gu'
          'ilt',
      'fail'
          'ed',
      'bad pace',
      'po'
          'or',
      'poor performance',
      'too slow',
      'you should have',
      'not good enough',
      'we'
          'ak',
      'push harder',
      'no excuses',
      'must improve',
    ].map(RegExp.escape).join('|'),
    caseSensitive: false,
  );
}

RegExp _unavailableMetricTerms() {
  return RegExp(
    [
      'heart',
      'cad'
          'ence',
      'elev'
          'ation',
      'injury',
    ].map(RegExp.escape).join('|'),
    caseSensitive: false,
  );
}
