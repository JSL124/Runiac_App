import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/pace_analysis_series.dart';
import 'package:runiac_app/features/run/domain/models/pace_graph_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/services/advanced_analysis_snapshot_builder.dart';

void main() {
  group('AdvancedAnalysisSnapshotBuilder', () {
    const builder = AdvancedAnalysisSnapshotBuilder();

    test('marks trusted scalar run summary fields as available', () {
      const summary = RunSummarySnapshot(
        title: 'Easy Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '--',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(snapshot.performance.duration.valueLabel, '30:15');
      expect(
        snapshot.performance.duration.availability,
        AdvancedAnalysisMetricAvailability.available,
      );
      expect(
        snapshot.performance.duration.source,
        AdvancedAnalysisMetricSource.localRunSummary,
      );
      expect(
        snapshot.performance.duration.confidence,
        AdvancedAnalysisMetricConfidence.trusted,
      );
      expect(snapshot.performance.distance.valueLabel, '4.03 km');
      expect(
        snapshot.pace.averagePace.availability,
        AdvancedAnalysisMetricAvailability.available,
      );
      expect(snapshot.pace.averagePace.valueLabel, '6’30” / km');
    });

    test('keeps unsupported analysis metrics unavailable by default', () {
      const summary = RunSummarySnapshot(
        title: 'Easy Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '145 bpm',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(
        snapshot.performance.score.reason,
        AdvancedAnalysisMetricReason.undefinedPerformanceFormula,
      );
      expect(snapshot.heartRate.zones.isAvailable, isFalse);
      expect(
        snapshot.heartRate.zones.reason,
        AdvancedAnalysisMetricReason.missingHeartRateZonePolicy,
      );
      expect(snapshot.formCadence.averageCadence.isAvailable, isFalse);
      expect(
        snapshot.formCadence.strideLength.reason,
        AdvancedAnalysisMetricReason.missingStrideSource,
      );
      expect(snapshot.elevation.totalGain.isAvailable, isFalse);
      expect(
        snapshot.elevation.routeDifficulty.reason,
        AdvancedAnalysisMetricReason.undefinedRouteDifficultySource,
      );
      expect(snapshot.pace.fastestPace.isAvailable, isFalse);
      expect(snapshot.pace.slowestPace.isAvailable, isFalse);
      expect(snapshot.pace.paceStability.isAvailable, isFalse);
    });

    test('derives pace analysis metrics from accountable local series', () {
      final summary = RunSummarySnapshot(
        title: 'Local Pace Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '--',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        paceAnalysisSeries: PaceAnalysisSeries.localAccepted(
          samples: const <PaceAnalysisSample>[
            PaceAnalysisSample.accepted(
              elapsedSeconds: 60,
              cumulativeDistanceMeters: 250,
              paceSecondsPerKm: 420,
            ),
            PaceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cumulativeDistanceMeters: 500,
              paceSecondsPerKm: 360,
            ),
            PaceAnalysisSample.accepted(
              elapsedSeconds: 180,
              cumulativeDistanceMeters: 750,
              paceSecondsPerKm: 480,
            ),
          ],
        ),
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(snapshot.pace.fastestPace.valueLabel, '6’00”');
      expect(snapshot.pace.slowestPace.valueLabel, '8’00”');
      expect(snapshot.pace.paceStability.valueLabel, '33');
      for (final metric in <AdvancedAnalysisMetric<String>>[
        snapshot.pace.fastestPace,
        snapshot.pace.slowestPace,
        snapshot.pace.paceStability,
      ]) {
        expect(
          metric.availability,
          AdvancedAnalysisMetricAvailability.available,
        );
        expect(metric.source, AdvancedAnalysisMetricSource.localGpsDerived);
        expect(metric.confidence, AdvancedAnalysisMetricConfidence.derived);
        expect(
          metric.source,
          isNot(AdvancedAnalysisMetricSource.backendDerived),
        );
        expect(metric.isTrustedProduction, isFalse);
      }
    });

    test('keeps pace analysis metrics unavailable for insufficient series', () {
      final summary = RunSummarySnapshot(
        title: 'Short Pace Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '--',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        paceAnalysisSeries: PaceAnalysisSeries.localAccepted(
          samples: const <PaceAnalysisSample>[
            PaceAnalysisSample.accepted(
              elapsedSeconds: 60,
              cumulativeDistanceMeters: 250,
              paceSecondsPerKm: 420,
            ),
            PaceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cumulativeDistanceMeters: 500,
              paceSecondsPerKm: 360,
            ),
          ],
        ),
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(snapshot.pace.fastestPace.isAvailable, isFalse);
      expect(snapshot.pace.slowestPace.isAvailable, isFalse);
      expect(snapshot.pace.paceStability.isAvailable, isFalse);
      expect(
        snapshot.pace.fastestPace.reason,
        AdvancedAnalysisMetricReason.insufficientPaceSamples,
      );
    });

    test('does not trust demo pace analysis series as local derivation', () {
      final summary = RunSummarySnapshot(
        title: 'Demo Pace Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '--',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        sourceType: RunSourceType.demoImport,
        paceAnalysisSeries: PaceAnalysisSeries.staticDemo(
          samples: const <PaceAnalysisSample>[
            PaceAnalysisSample.accepted(
              elapsedSeconds: 60,
              cumulativeDistanceMeters: 250,
              paceSecondsPerKm: 420,
            ),
            PaceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cumulativeDistanceMeters: 500,
              paceSecondsPerKm: 360,
            ),
            PaceAnalysisSample.accepted(
              elapsedSeconds: 180,
              cumulativeDistanceMeters: 750,
              paceSecondsPerKm: 480,
            ),
          ],
        ),
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(snapshot.pace.fastestPace.isAvailable, isFalse);
      expect(snapshot.pace.slowestPace.isAvailable, isFalse);
      expect(snapshot.pace.paceStability.isAvailable, isFalse);
    });

    test(
      'does not classify demo/static metrics as trusted production data',
      () {
        const metric = AdvancedAnalysisMetric<String>.demoOnly('82');

        expect(
          metric.availability,
          AdvancedAnalysisMetricAvailability.demoOnly,
        );
        expect(metric.source, AdvancedAnalysisMetricSource.staticDemo);
        expect(metric.confidence, AdvancedAnalysisMetricConfidence.demo);
        expect(metric.isTrustedProduction, isFalse);
      },
    );

    test(
      'keeps demo import summary scalars out of trusted production data',
      () {
        const summary = RunSummarySnapshot(
          title: 'Demo Run',
          dateLabel: 'Today',
          timeLabel: '7:06 AM',
          distanceKm: '4.03 km',
          avgPace: '6’30” / km',
          duration: '30:15',
          avgHeartRate: '145 bpm',
          calories: '212 kcal',
          routeName: 'East Coast Park Loop',
          sourceType: RunSourceType.demoImport,
        );

        final snapshot = builder.fromRunSummary(summary);

        expect(
          snapshot.performance.duration.availability,
          AdvancedAnalysisMetricAvailability.demoOnly,
        );
        expect(
          snapshot.performance.duration.source,
          AdvancedAnalysisMetricSource.staticDemo,
        );
        expect(
          snapshot.performance.duration.confidence,
          AdvancedAnalysisMetricConfidence.demo,
        );
        expect(snapshot.performance.duration.isTrustedProduction, isFalse);
        expect(snapshot.pace.averagePace.isTrustedProduction, isFalse);
      },
    );

    test('keeps demo import pace graphs out of local GPS derived data', () {
      const summary = RunSummarySnapshot(
        title: 'Demo Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '145 bpm',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        sourceType: RunSourceType.demoImport,
        paceGraph: PaceGraphSnapshot(
          isAvailable: true,
          points: <PaceGraphPoint>[
            PaceGraphPoint(
              elapsedSeconds: 0,
              progressFraction: 0,
              paceSecondsPerKm: 390,
            ),
            PaceGraphPoint(
              elapsedSeconds: 120,
              progressFraction: 0.5,
              paceSecondsPerKm: 392,
            ),
            PaceGraphPoint(
              elapsedSeconds: 240,
              progressFraction: 1,
              paceSecondsPerKm: 388,
            ),
          ],
          yAxisLabels: <String>['6:00', '6:30', '7:00'],
          xAxisLabels: <String>['0:00', '2:00', '4:00'],
        ),
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(
        snapshot.pace.paceGraph.availability,
        AdvancedAnalysisMetricAvailability.demoOnly,
      );
      expect(
        snapshot.pace.paceGraph.source,
        AdvancedAnalysisMetricSource.staticDemo,
      );
      expect(
        snapshot.pace.paceGraph.confidence,
        AdvancedAnalysisMetricConfidence.demo,
      );
      expect(snapshot.pace.paceGraph.isTrustedProduction, isFalse);
    });

    test('derives local GPS split rows from distance-backed pace graph', () {
      const summary = RunSummarySnapshot(
        title: 'Local Split Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '26:26',
        avgHeartRate: '--',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        paceGraph: PaceGraphSnapshot(
          isAvailable: true,
          points: <PaceGraphPoint>[
            PaceGraphPoint(
              elapsedSeconds: 0,
              progressFraction: 0,
              paceSecondsPerKm: 390,
              distanceProgressFraction: 0,
            ),
            PaceGraphPoint(
              elapsedSeconds: 360,
              progressFraction: 0.25,
              paceSecondsPerKm: 360,
              distanceProgressFraction: 1 / 4.03,
            ),
            PaceGraphPoint(
              elapsedSeconds: 750,
              progressFraction: 0.5,
              paceSecondsPerKm: 390,
              distanceProgressFraction: 2 / 4.03,
            ),
            PaceGraphPoint(
              elapsedSeconds: 1170,
              progressFraction: 0.75,
              paceSecondsPerKm: 420,
              distanceProgressFraction: 3 / 4.03,
            ),
            PaceGraphPoint(
              elapsedSeconds: 1560,
              progressFraction: 0.98,
              paceSecondsPerKm: 390,
              distanceProgressFraction: 4 / 4.03,
            ),
          ],
          yAxisLabels: <String>['6:00', '6:30', '7:00'],
          xAxisLabels: <String>['0:00', '13:13', '26:26'],
          distanceAxisLabels: <String>['0 km', '2 km', '4.03 km'],
          totalDurationSeconds: 1586,
        ),
      );

      final snapshot = builder.fromRunSummary(summary);
      final splits = snapshot.pace.splits.value!;

      expect(
        snapshot.pace.splits.availability,
        AdvancedAnalysisMetricAvailability.available,
      );
      expect(
        snapshot.pace.splits.source,
        AdvancedAnalysisMetricSource.localGpsDerived,
      );
      expect(
        snapshot.pace.splits.confidence,
        AdvancedAnalysisMetricConfidence.derived,
      );
      expect(splits.map((split) => split.distanceLabel), <String>[
        '1 km',
        '2 km',
        '3 km',
        '4 km',
        '0.03 km',
      ]);
      expect(splits.map((split) => split.paceLabel), <String>[
        '6’00”',
        '6’30”',
        '7’00”',
        '6’30”',
        '0’26”',
      ]);
      expect(splits.map((split) => split.paceSecondsPerKm), <int>[
        360,
        390,
        420,
        390,
        26,
      ]);
      expect(splits.last.isPartial, isTrue);
      expect(splits.last.elevationLabel, '--');
      expect(splits.last.heartRateLabel, '--');
    });

    test('keeps splits unavailable without distance-axis graph metadata', () {
      const summary = RunSummarySnapshot(
        title: 'No Distance Axis Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '26:26',
        avgHeartRate: '--',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        paceGraph: PaceGraphSnapshot(
          isAvailable: true,
          points: <PaceGraphPoint>[
            PaceGraphPoint(
              elapsedSeconds: 0,
              progressFraction: 0,
              paceSecondsPerKm: 390,
            ),
            PaceGraphPoint(
              elapsedSeconds: 780,
              progressFraction: 0.5,
              paceSecondsPerKm: 390,
            ),
            PaceGraphPoint(
              elapsedSeconds: 1560,
              progressFraction: 1,
              paceSecondsPerKm: 390,
            ),
          ],
          yAxisLabels: <String>['6:00', '6:30', '7:00'],
          xAxisLabels: <String>['0:00', '13:00', '26:00'],
          totalDurationSeconds: 1560,
        ),
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(snapshot.pace.splits.isAvailable, isFalse);
      expect(
        snapshot.pace.splits.reason,
        AdvancedAnalysisMetricReason.insufficientPaceSamples,
      );
      expect(snapshot.pace.splits.value, isNull);
    });

    test('preserves Health Connect heart rate source identity', () {
      const summary = RunSummarySnapshot(
        title: 'Imported Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '145 bpm',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        sourceType: RunSourceType.healthConnect,
        heartRateAvailability: HeartRateAvailability.available,
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(snapshot.heartRate.averageHeartRate.isAvailable, isTrue);
      expect(
        snapshot.heartRate.averageHeartRate.source,
        AdvancedAnalysisMetricSource.healthConnect,
      );
      expect(
        snapshot.heartRate.averageHeartRate.confidence,
        AdvancedAnalysisMetricConfidence.derived,
      );
    });

    test('preserves source and confidence for estimated future metrics', () {
      const metric = AdvancedAnalysisMetric<String>.estimated(
        valueLabel: '0.98 m',
        source: AdvancedAnalysisMetricSource.phoneSensorEstimated,
        reason: AdvancedAnalysisMetricReason.estimatedFromPhoneSensors,
      );

      expect(metric.availability, AdvancedAnalysisMetricAvailability.estimated);
      expect(metric.source, AdvancedAnalysisMetricSource.phoneSensorEstimated);
      expect(metric.confidence, AdvancedAnalysisMetricConfidence.estimated);
      expect(
        metric.reason,
        AdvancedAnalysisMetricReason.estimatedFromPhoneSensors,
      );
      expect(metric.isTrustedProduction, isFalse);
    });

    test('does not add backend-owned mutation fields to client payload paths', () {
      final sources = <String>[
        File(
          'lib/features/run/domain/models/local_run_completion_payload.dart',
        ).readAsStringSync(),
        File(
          'lib/features/run/domain/models/run_completion_request_adapter.dart',
        ).readAsStringSync(),
        File(
          'lib/features/run/domain/models/advanced_analysis_snapshot.dart',
        ).readAsStringSync(),
        File(
          'lib/features/run/domain/services/advanced_analysis_snapshot_builder.dart',
        ).readAsStringSync(),
      ];
      const forbiddenTerms = <String>[
        'calculateXp',
        'calculateXP',
        'streakCount',
        'leaderboardScore',
        'weeklyXp',
        'weeklyXP',
        'monthlyXp',
        'monthlyXP',
        'subscriptionPrivilegeState',
        'expertPlanPublicationState',
        'validatedActivityContributionState',
        'countsTowardProgression',
      ];

      for (final source in sources) {
        for (final term in forbiddenTerms) {
          expect(source, isNot(contains(term)), reason: term);
        }
      }
    });

    test('keeps Runiac GPS heart rate unavailable without trusted source', () {
      const summary = RunSummarySnapshot(
        title: 'Runiac GPS Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.03 km',
        avgPace: '6’30” / km',
        duration: '30:15',
        avgHeartRate: '145 bpm',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
        sourceType: RunSourceType.runiacGps,
        heartRateAvailability: HeartRateAvailability.unavailableNoSensor,
      );

      final snapshot = builder.fromRunSummary(summary);

      expect(snapshot.heartRate.averageHeartRate.isAvailable, isFalse);
      expect(
        snapshot.heartRate.averageHeartRate.reason,
        AdvancedAnalysisMetricReason.missingHeartRateSource,
      );
    });
  });
}
