import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/coaching_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/pace_graph_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/services/rule_based_coaching_summary_engine.dart';

void main() {
  group('RuleBasedCoachingSummaryEngine', () {
    test('returns low-data interpretation before all other rules', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(
          distanceKm: '0.03',
          avgPace: '--',
          duration: '0:25',
          calories: '--',
          hasSufficientData: false,
          paceGraph: _variablePaceGraph(),
        ),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.lowDataInterpretation,
      );
      expect(coaching.headline, 'Thanks for getting out there');
      expect(coaching.message, contains('limited run data'));
      _expectInterpretationShape(coaching);
    });

    test('returns short-valid interpretation for sufficient short runs', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(
          distanceKm: '0.72',
          duration: '5:45',
          paceGraph: _variablePaceGraph(),
        ),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.shortValidInterpretation,
      );
      expect(coaching.headline, 'A solid short start');
      expect(coaching.message, contains('real but short'));
      _expectInterpretationShape(coaching);
    });

    test('returns scalar-only interpretation without graph trend claims', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(paceGraph: const PaceGraphSnapshot.unavailable()),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.scalarOnlyInterpretation,
      );
      expect(coaching.message, contains('distance, time, and average pace'));
      expect(coaching.message, isNot(contains('graph')));
      _expectInterpretationShape(coaching);
    });

    test('returns data-quality fallback for unusable graph data', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(
          paceGraph: const PaceGraphSnapshot(
            isAvailable: true,
            points: [
              PaceGraphPoint(
                elapsedSeconds: 0,
                progressFraction: 0,
                paceSecondsPerKm: 120,
              ),
              PaceGraphPoint(
                elapsedSeconds: 0,
                progressFraction: 0.5,
                paceSecondsPerKm: 1900,
              ),
            ],
            yAxisLabels: ['6:00'],
            xAxisLabels: ['0'],
          ),
        ),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.dataQualityFallbackInterpretation,
      );
      expect(coaching.message, contains('graph detail is too limited'));
      _expectInterpretationShape(coaching);
    });

    test('returns pace-control interpretation for wider pace changes', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(paceGraph: _variablePaceGraph()),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.paceControlInterpretation,
      );
      expect(coaching.headline, 'Your pace moved around today');
      expect(
        coaching.nextAction,
        'Begin the next run slower for the first few minutes.',
      );
      _expectInterpretationShape(coaching);
    });

    test('returns steady-effort interpretation for controlled pace spread', () {
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
                paceSecondsPerKm: 386,
              ),
              PaceGraphPoint(
                elapsedSeconds: 1800,
                progressFraction: 1,
                paceSecondsPerKm: 365,
              ),
            ],
            yAxisLabels: ['6:00', '6:30', '7:00'],
            xAxisLabels: ['0', '15', '30'],
          ),
        ),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.steadyEffortInterpretation,
      );
      expect(coaching.headline, 'You kept a controlled rhythm');
      _expectInterpretationShape(coaching);
    });

    test(
      'returns pacing-awareness interpretation for moderate pace spread',
      () {
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
                  paceSecondsPerKm: 410,
                ),
                PaceGraphPoint(
                  elapsedSeconds: 1800,
                  progressFraction: 1,
                  paceSecondsPerKm: 392,
                ),
              ],
              yAxisLabels: ['6:00', '6:30', '7:00'],
              xAxisLabels: ['0', '15', '30'],
            ),
          ),
        );

        expect(
          coaching.interpretationId,
          CoachingInterpretationId.pacingAwarenessInterpretation,
        );
        expect(coaching.headline, 'You have pacing data to learn from');
        _expectInterpretationShape(coaching);
      },
    );

    test('returns basic completion interpretation as defensive fallback', () {
      final coaching = const RuleBasedCoachingSummaryEngine().build(
        _summary(
          avgPace: '--',
          paceGraph: const PaceGraphSnapshot.unavailable(),
        ),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.basicCompletionInterpretation,
      );
      expect(coaching.headline, 'Good work finishing the run');
      _expectInterpretationShape(coaching);
    });

    test('keeps all rulebook copy local-data-only and beginner-safe', () {
      final outputs = [
        const RuleBasedCoachingSummaryEngine().build(
          _summary(hasSufficientData: false, avgPace: '--'),
        ),
        const RuleBasedCoachingSummaryEngine().build(
          _summary(distanceKm: '0.72', duration: '5:45'),
        ),
        const RuleBasedCoachingSummaryEngine().build(
          _summary(paceGraph: PaceGraphSnapshot.unavailable()),
        ),
        const RuleBasedCoachingSummaryEngine().build(
          _summary(paceGraph: _variablePaceGraph()),
        ),
      ];

      for (final coaching in outputs) {
        expect(coaching.source, CoachingSummarySource.ruleBased);
        expect(coaching.sectionTitle, 'Coaching Summary');
        expect(_allCopy(coaching), isNot(contains(_blockedCopyTerms())));
        expect(_allCopy(coaching), isNot(contains(_unavailableMetricTerms())));
        expect(_allCopy(coaching), isNot(contains(_futureServiceTerms())));
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
      PaceGraphPoint(
        elapsedSeconds: 900,
        progressFraction: 0.5,
        paceSecondsPerKm: 398,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1800,
        progressFraction: 1,
        paceSecondsPerKm: 410,
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

PaceGraphSnapshot _variablePaceGraph() {
  return const PaceGraphSnapshot(
    isAvailable: true,
    points: [
      PaceGraphPoint(
        elapsedSeconds: 0,
        progressFraction: 0,
        paceSecondsPerKm: 360,
      ),
      PaceGraphPoint(
        elapsedSeconds: 900,
        progressFraction: 0.5,
        paceSecondsPerKm: 455,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1800,
        progressFraction: 1,
        paceSecondsPerKm: 420,
      ),
    ],
    yAxisLabels: ['6:00', '7:00', '8:00'],
    xAxisLabels: ['0', '15', '30'],
  );
}

void _expectInterpretationShape(CoachingSummarySnapshot coaching) {
  expect(coaching.bullets, hasLength(2));
  expect(coaching.bullets.first, startsWith('What went well: '));
  expect(coaching.bullets.last, startsWith('What to improve: '));
  expect(coaching.nextAction, isNotEmpty);
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

RegExp _blockedCopyTerms() {
  return RegExp(
    [
      'sha'
          'me',
      'gu'
          'ilt',
      'fail'
          'ed',
      'bad'
          ' pace',
      'po'
          'or',
      'poor'
          ' performance',
      'too'
          ' slow',
      'you should'
          ' have',
      'not good'
          ' enough',
      'we'
          'ak',
      'push'
          ' harder',
      'no'
          ' excuses',
      'must'
          ' improve',
    ].map(RegExp.escape).join('|'),
    caseSensitive: false,
  );
}

RegExp _unavailableMetricTerms() {
  return RegExp(
    [
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
}

RegExp _futureServiceTerms() {
  return RegExp(
    [
      'Open'
          'AI',
      'API'
          ' key',
      'Bear'
          'er',
      'Prem'
          'ium',
      'subscrip'
          'tion',
      'XP',
      'leader'
          'board',
      'str'
          'eak',
      'ra'
          'nk',
      'lev'
          'el',
    ].map(RegExp.escape).join('|'),
    caseSensitive: false,
  );
}
