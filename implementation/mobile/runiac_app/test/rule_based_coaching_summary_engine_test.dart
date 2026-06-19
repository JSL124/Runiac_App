import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/coaching_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/pace_graph_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/services/rule_based_coaching_summary_engine.dart';

void main() {
  group('RuleBasedCoachingSummaryEngine diary rulebook', () {
    test('low_data_no_hr_no_graph_diary_copy', () {
      final coaching = _build(
        distanceKm: '0.03',
        avgPace: '--',
        duration: '0:25',
        calories: '--',
        hasSufficientData: false,
        paceGraph: const PaceGraphSnapshot.unavailable(),
      );

      expect(
        coaching.interpretationId,
        CoachingInterpretationId.lowDataInterpretation,
      );
      expect(coaching.message, contains('limited'));
      expect(
        coaching.message,
        contains(
          RegExp('heart-rate data was not available', caseSensitive: false),
        ),
      );
      expect(coaching.message, isNot(contains('graph shows')));
      expect(coaching.nextAction, contains('GPS ready'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('very_short_suppresses_pace_pattern_claim', () {
      final coaching = _build(
        distanceKm: '0.16',
        duration: '1:40',
        paceGraph: _strongFinishGraph(),
      );

      expect(coaching.message, contains('short check-in'));
      expect(coaching.message, isNot(contains('finished stronger')));
      expect(coaching.message, isNot(contains('pace graph shows')));
      expect(coaching.nextAction, contains('easy minutes'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('short_steady_no_hr_diary_copy', () {
      final coaching = _build(
        distanceKm: '0.72',
        duration: '5:45',
        paceGraph: _steadyGraph(),
      );

      expect(coaching.message, contains('short but useful'));
      expect(coaching.message, contains('steady'));
      expect(
        coaching.message,
        contains(
          RegExp('heart-rate data was not available', caseSensitive: false),
        ),
      );
      expect(coaching.nextAction, contains('same calm start'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('short_uneven_no_hr_diary_copy', () {
      final coaching = _build(
        distanceKm: '0.75',
        duration: '5:50',
        paceGraph: _unevenGraph(),
      );

      expect(coaching.message, contains('pace moved around'));
      expect(coaching.message, contains('normal'));
      expect(
        coaching.message,
        contains(
          RegExp('heart-rate data was not available', caseSensitive: false),
        ),
      );
      expect(coaching.nextAction, contains('first few minutes'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('normal_steady_hr_available_no_zone_claim', () {
      final coaching = _build(
        avgHeartRate: '145',
        heartRateAvailability: HeartRateAvailability.available,
        paceGraph: _steadyGraph(),
      );

      expect(coaching.message, contains('controlled rhythm'));
      expect(coaching.message, contains('Heart-rate data was recorded'));
      expect(coaching.message, contains('steady pacing'));
      expect(coaching.nextAction, contains('calm start'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('normal_steady_hr_unavailable_no_effort_claim', () {
      final coaching = _build(paceGraph: _steadyGraph());

      expect(coaching.message, contains('steady rhythm'));
      expect(coaching.message, contains('avoids guessing how hard it felt'));
      expect(coaching.message, isNot(contains('comfortable effort')));
      expect(coaching.nextAction, contains('easy rhythm'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('fast_start_fade_no_hr_gentle_start_focus', () {
      final coaching = _build(paceGraph: _fastStartFadeGraph());

      expect(coaching.message, contains('quicker early'));
      expect(coaching.message, contains('slower later'));
      expect(
        coaching.message,
        contains(
          RegExp('heart-rate data was not available', caseSensitive: false),
        ),
      );
      expect(coaching.nextAction, contains('first 5 minutes'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('fast_start_fade_hr_available_no_fatigue_claim', () {
      final coaching = _build(
        avgHeartRate: '150',
        heartRateAvailability: HeartRateAvailability.available,
        paceGraph: _fastStartFadeGraph(),
      );

      expect(coaching.message, contains('quicker early'));
      expect(coaching.message, contains('Heart-rate data was recorded'));
      expect(coaching.message, isNot(contains('fatigue')));
      expect(coaching.nextAction, contains('calmer first few minutes'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('longer_fade_no_hr_endurance_praise_first', () {
      final coaching = _build(
        distanceKm: '5.80',
        duration: '43:20',
        paceGraph: _fastStartFadeGraph(),
      );

      expect(coaching.message, startsWith('This was a longer beginner run'));
      expect(coaching.message, contains('later pace eased'));
      expect(
        coaching.message,
        contains(
          RegExp('heart-rate data was not available', caseSensitive: false),
        ),
      );
      expect(coaching.nextAction, contains('opening third'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('strong_finish_no_hr_controlled_finish_copy', () {
      final coaching = _build(paceGraph: _strongFinishGraph());

      expect(coaching.message, contains('finished a little stronger'));
      expect(
        coaching.message,
        contains(
          RegExp('heart-rate data was not available', caseSensitive: false),
        ),
      );
      expect(coaching.nextAction, contains('early part relaxed'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('strong_finish_hr_available_no_sprint_or_zone_claim', () {
      final coaching = _build(
        avgHeartRate: '142',
        heartRateAvailability: HeartRateAvailability.available,
        paceGraph: _strongFinishGraph(),
      );

      expect(coaching.message, contains('finished a little stronger'));
      expect(coaching.message, contains('Heart-rate data was recorded'));
      expect(coaching.message, isNot(contains('sprint')));
      expect(coaching.nextAction, contains('first half controlled'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('uneven_no_hr_rhythm_practice_copy', () {
      final coaching = _build(paceGraph: _unevenGraph());

      expect(coaching.message, contains('rhythm changed'));
      expect(
        coaching.message,
        contains(
          RegExp('heart-rate data was not available', caseSensitive: false),
        ),
      );
      expect(coaching.nextAction, contains('almost too easy'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('imported_or_static_run_avoids_live_gps_claim', () {
      final coaching = _build(
        sourceType: RunSourceType.demoImport,
        heartRateAvailability: HeartRateAvailability.available,
        avgHeartRate: '136',
        paceGraph: _steadyGraph(),
      );

      expect(coaching.message, contains('imported summary'));
      expect(coaching.message, isNot(contains('tracked live')));
      expect(coaching.message, isNot(contains('Runiac GPS observed')));
      expect(coaching.nextAction, contains('Compare the rhythm'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('graph_unavailable_valid_scalars_avoids_graph_claim', () {
      final coaching = _build(paceGraph: const PaceGraphSnapshot.unavailable());

      expect(coaching.message, contains('distance, time, and average pace'));
      expect(coaching.message, isNot(contains('graph shows')));
      expect(coaching.message, isNot(contains('finished stronger')));
      expect(coaching.nextAction, contains('simple'));
      _expectDiaryShape(coaching);
      _expectSafeCopy(coaching);
    });

    test('copy_length_guard', () {
      final outputs = [
        _build(hasSufficientData: false, avgPace: '--'),
        _build(distanceKm: '0.16', duration: '1:40'),
        _build(distanceKm: '0.72', duration: '5:45', paceGraph: _steadyGraph()),
        _build(distanceKm: '0.75', duration: '5:50', paceGraph: _unevenGraph()),
        _build(paceGraph: _steadyGraph()),
        _build(paceGraph: _fastStartFadeGraph()),
        _build(paceGraph: _strongFinishGraph()),
        _build(paceGraph: const PaceGraphSnapshot.unavailable()),
      ];

      for (final coaching in outputs) {
        _expectDiaryShape(coaching);
        _expectSafeCopy(coaching);
      }
    });
  });
}

CoachingSummarySnapshot _build({
  String distanceKm = '4.20',
  String avgPace = '6’12”',
  String duration = '26:02',
  String avgHeartRate = '--',
  String calories = '245',
  bool hasSufficientData = true,
  RunSourceType sourceType = RunSourceType.runiacGps,
  HeartRateAvailability heartRateAvailability =
      HeartRateAvailability.unavailableNoSensor,
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
  return const RuleBasedCoachingSummaryEngine().build(
    RunSummarySnapshot(
      title: 'Morning Run',
      dateLabel: '19/6/26',
      timeLabel: '7:10 AM',
      distanceKm: distanceKm,
      avgPace: avgPace,
      duration: duration,
      avgHeartRate: avgHeartRate,
      calories: calories,
      routeName: 'Private route',
      hasSufficientData: hasSufficientData,
      sourceType: sourceType,
      heartRateAvailability: heartRateAvailability,
      paceGraph: paceGraph,
    ),
  );
}

PaceGraphSnapshot _steadyGraph() {
  return const PaceGraphSnapshot(
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
  );
}

PaceGraphSnapshot _unevenGraph() {
  return const PaceGraphSnapshot(
    isAvailable: true,
    points: [
      PaceGraphPoint(
        elapsedSeconds: 0,
        progressFraction: 0,
        paceSecondsPerKm: 390,
      ),
      PaceGraphPoint(
        elapsedSeconds: 600,
        progressFraction: 0.33,
        paceSecondsPerKm: 470,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1200,
        progressFraction: 0.66,
        paceSecondsPerKm: 410,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1800,
        progressFraction: 1,
        paceSecondsPerKm: 455,
      ),
    ],
    yAxisLabels: ['6:00', '7:00', '8:00'],
    xAxisLabels: ['0', '10', '20', '30'],
  );
}

PaceGraphSnapshot _fastStartFadeGraph() {
  return const PaceGraphSnapshot(
    isAvailable: true,
    points: [
      PaceGraphPoint(
        elapsedSeconds: 0,
        progressFraction: 0,
        paceSecondsPerKm: 360,
      ),
      PaceGraphPoint(
        elapsedSeconds: 600,
        progressFraction: 0.33,
        paceSecondsPerKm: 405,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1200,
        progressFraction: 0.66,
        paceSecondsPerKm: 432,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1800,
        progressFraction: 1,
        paceSecondsPerKm: 455,
      ),
    ],
    yAxisLabels: ['6:00', '7:00', '8:00'],
    xAxisLabels: ['0', '10', '20', '30'],
  );
}

PaceGraphSnapshot _strongFinishGraph() {
  return const PaceGraphSnapshot(
    isAvailable: true,
    points: [
      PaceGraphPoint(
        elapsedSeconds: 0,
        progressFraction: 0,
        paceSecondsPerKm: 430,
      ),
      PaceGraphPoint(
        elapsedSeconds: 600,
        progressFraction: 0.33,
        paceSecondsPerKm: 415,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1200,
        progressFraction: 0.66,
        paceSecondsPerKm: 400,
      ),
      PaceGraphPoint(
        elapsedSeconds: 1800,
        progressFraction: 1,
        paceSecondsPerKm: 372,
      ),
    ],
    yAxisLabels: ['6:00', '7:00', '8:00'],
    xAxisLabels: ['0', '10', '20', '30'],
  );
}

void _expectDiaryShape(CoachingSummarySnapshot coaching) {
  final wordCount = coaching.message
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .length;
  final sentenceCount = RegExp(r'[.!?]').allMatches(coaching.message).length;

  expect(wordCount, inInclusiveRange(35, 80), reason: coaching.message);
  expect(sentenceCount, inInclusiveRange(2, 4), reason: coaching.message);
  expect(coaching.message, isNot(contains('\n')));
  expect(coaching.bullets, isEmpty);
  expect(coaching.headline, isNotEmpty);
  expect(coaching.nextAction, isNotEmpty);
}

void _expectSafeCopy(CoachingSummarySnapshot coaching) {
  final copy = _allCopy(coaching);
  expect(copy, isNot(contains(_blockedCopyTerms())));
  expect(copy, isNot(contains(_futureServiceTerms())));
  expect(copy, isNot(contains(_medicalOrIntensityTerms())));
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
      'bad',
      'po'
          'or',
      'burned'
          ' out',
      'over'
          'trained',
      'exhaust'
          'ed',
      'danger',
      'max'
          ' effort',
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

RegExp _medicalOrIntensityTerms() {
  return RegExp(
    [
      'Zone',
      'threshold',
      'fat'
          'igue',
      'medical',
      'recovery',
      'heart rate showed',
      'effort was',
      'comfortable effort',
      'high effort',
      'GPS was accurate',
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
