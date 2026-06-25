import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/cadence_analysis_series.dart';
import 'package:runiac_app/features/run/domain/models/elevation_analysis_series.dart';
import 'package:runiac_app/features/run/domain/models/heart_rate_analysis_eligibility.dart';
import 'package:runiac_app/features/run/domain/models/pace_analysis_series.dart';
import 'package:runiac_app/features/run/domain/models/pace_graph_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/workout_metric_contract.dart';
import 'package:runiac_app/features/run/domain/services/advanced_analysis_achievement_badge_builder.dart';
import 'package:runiac_app/features/run/domain/services/advanced_analysis_snapshot_builder.dart';

void main() {
  group('Advanced Analysis policy', () {
    const builder = AdvancedAnalysisSnapshotBuilder();

    test('calculates deterministic scores for every analysis source mode', () {
      final mobilePerformance = builder
          .fromRunSummary(_scoreFixtureSummary())
          .performance;
      final mixedPerformance = builder
          .fromRunSummary(
            _scoreFixtureSummary(
              cadenceAnalysisSeries: _phoneMotionCadenceSeries(),
            ),
          )
          .performance;
      final wearablePerformance = builder
          .fromRunSummary(
            _scoreFixtureSummary(
              sourceType: RunSourceType.appleHealth,
              heartRateAvailability: HeartRateAvailability.available,
              heartRateAnalysisEligibility:
                  HeartRateAnalysisEligibility.zoneReady,
              importedMetrics: [
                _heartRateSamples([
                  (elapsedSeconds: 0, bpm: 124),
                  (elapsedSeconds: 300, bpm: 132),
                  (elapsedSeconds: 600, bpm: 141),
                  (elapsedSeconds: 900, bpm: 148),
                  (elapsedSeconds: 1200, bpm: 136),
                  (elapsedSeconds: 1560, bpm: 130),
                ]),
                _heartRateSummary(135),
                _maxHeartRateSummary(148),
              ],
            ),
          )
          .performance;
      final demoPerformance = builder
          .fromRunSummary(
            const RunSummarySnapshot(
              title: 'Demo Run',
              dateLabel: 'Today',
              timeLabel: '7:06 AM',
              distanceKm: '4.00 km',
              avgPace: '6’30” / km',
              duration: '26:00',
              avgHeartRate: '--',
              calories: '212 kcal',
              routeName: 'East Coast Park Loop',
              sourceType: RunSourceType.demoImport,
            ),
          )
          .performance;

      expect(
        mobilePerformance.scoreMode,
        AdvancedAnalysisScoreSourceMode.mobileOnly,
      );
      expect(mobilePerformance.score.value, 97);
      expect(
        mixedPerformance.scoreMode,
        AdvancedAnalysisScoreSourceMode.mixedSource,
      );
      expect(mixedPerformance.score.value, 97);
      expect(
        wearablePerformance.scoreMode,
        AdvancedAnalysisScoreSourceMode.wearableBacked,
      );
      expect(wearablePerformance.score.value, 85);
      expect(
        demoPerformance.scoreMode,
        AdvancedAnalysisScoreSourceMode.demoOnly,
      );
      expect(demoPerformance.score.value, 65);
      expect(demoPerformance.score.isTrustedProduction, isFalse);
    });

    test('keeps mobile-only scoring fair without cadence or heart rate', () {
      const mobileSummary = RunSummarySnapshot(
        title: 'Phone Run',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '4.00 km',
        avgPace: '6’30” / km',
        duration: '26:00',
        avgHeartRate: '--',
        calories: '212 kcal',
        routeName: 'East Coast Park Loop',
      );
      final phoneEnhancedSummary = mobileSummary.copyWith(
        cadenceAnalysisSeries: _phoneMotionCadenceSeries(),
      );

      final mobilePerformance = builder
          .fromRunSummary(mobileSummary)
          .performance;
      final phoneEnhancedPerformance = builder
          .fromRunSummary(phoneEnhancedSummary)
          .performance;

      expect(
        mobilePerformance.scoreMode,
        AdvancedAnalysisScoreSourceMode.mobileOnly,
      );
      expect(mobilePerformance.score.isAvailable, isTrue);
      expect(mobilePerformance.score.value, 90);
      expect(
        phoneEnhancedPerformance.scoreMode,
        AdvancedAnalysisScoreSourceMode.mixedSource,
      );
      expect(
        phoneEnhancedPerformance.score.value,
        greaterThan(mobilePerformance.score.value!),
      );
    });

    test(
      'returns unavailable performance score without distance or duration',
      () {
        const missingDistance = RunSummarySnapshot(
          title: 'Missing Distance',
          dateLabel: 'Today',
          timeLabel: '7:06 AM',
          distanceKm: '--',
          avgPace: '6’30” / km',
          duration: '26:00',
          avgHeartRate: '--',
          calories: '212 kcal',
          routeName: 'East Coast Park Loop',
        );
        const missingDuration = RunSummarySnapshot(
          title: 'Missing Duration',
          dateLabel: 'Today',
          timeLabel: '7:06 AM',
          distanceKm: '4.00 km',
          avgPace: '6’30” / km',
          duration: '--',
          avgHeartRate: '--',
          calories: '212 kcal',
          routeName: 'East Coast Park Loop',
        );

        for (final summary in [missingDistance, missingDuration]) {
          final score = builder.fromRunSummary(summary).performance.score;

          expect(score.isAvailable, isFalse, reason: summary.title);
          expect(
            score.reason,
            AdvancedAnalysisMetricReason.missingSummaryField,
            reason: summary.title,
          );
        }
      },
    );

    test('gates achievement badges by supporting metric data', () {
      final mobileSnapshot = builder.fromRunSummary(_scoreFixtureSummary());
      final supportingDataSnapshot = builder.fromRunSummary(
        _scoreFixtureSummary(
          sourceType: RunSourceType.runiacGps,
          heartRateAvailability: HeartRateAvailability.available,
          heartRateAnalysisEligibility: HeartRateAnalysisEligibility.zoneReady,
          importedMetrics: [
            _heartRateSamples([
              (elapsedSeconds: 0, bpm: 118),
              (elapsedSeconds: 300, bpm: 126),
              (elapsedSeconds: 600, bpm: 132),
              (elapsedSeconds: 900, bpm: 138),
              (elapsedSeconds: 1200, bpm: 134),
              (elapsedSeconds: 1560, bpm: 128),
            ]),
            _heartRateSummary(130),
            _maxHeartRateSummary(138),
          ],
          cadenceAnalysisSeries: _phoneMotionCadenceSeries(),
          elevationSeries: ElevationAnalysisSeries.localAccepted(
            samples: const [
              ElevationAnalysisSample(distanceKm: 0, elevationMeters: 4),
              ElevationAnalysisSample(distanceKm: 2, elevationMeters: 10),
              ElevationAnalysisSample(distanceKm: 4, elevationMeters: 5),
            ],
          ),
        ),
      );

      expect(
        mobileSnapshot.performance.badges.map((badge) => badge.kind),
        isNot(contains(AdvancedAnalysisBadgeKind.controlledHeartRate)),
      );
      expect(
        mobileSnapshot.performance.badges.map((badge) => badge.kind),
        isNot(contains(AdvancedAnalysisBadgeKind.consistentCadence)),
      );
      expect(
        mobileSnapshot.performance.badges.map((badge) => badge.kind),
        isNot(contains(AdvancedAnalysisBadgeKind.hillSteady)),
      );
      expect(
        supportingDataSnapshot.performance.badges.map((badge) => badge.kind),
        containsAll([
          AdvancedAnalysisBadgeKind.controlledHeartRate,
          AdvancedAnalysisBadgeKind.consistentCadence,
          AdvancedAnalysisBadgeKind.hillSteady,
        ]),
      );
    });

    test('documents positive badge rules with supporting metric data', () {
      final snapshot = builder.fromRunSummary(
        _scoreFixtureSummary(
          sourceType: RunSourceType.appleHealth,
          heartRateAvailability: HeartRateAvailability.available,
          heartRateAnalysisEligibility: HeartRateAnalysisEligibility.zoneReady,
          importedMetrics: [
            _heartRateSamples([
              (elapsedSeconds: 0, bpm: 126),
              (elapsedSeconds: 300, bpm: 132),
              (elapsedSeconds: 600, bpm: 140),
              (elapsedSeconds: 900, bpm: 146),
              (elapsedSeconds: 1200, bpm: 138),
              (elapsedSeconds: 1560, bpm: 130),
            ]),
            _heartRateSummary(135),
            _maxHeartRateSummary(146),
          ],
          cadenceAnalysisSeries: CadenceAnalysisSeries(
            source: CadenceAnalysisSource.healthKitAppleWatch,
            confidence: CadenceAnalysisConfidence.high,
            samples: const [
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 0,
                cadenceSpm: 162,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 600,
                cadenceSpm: 164,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 1200,
                cadenceSpm: 163,
              ),
            ],
          ),
          elevationSeries: ElevationAnalysisSeries.localAccepted(
            samples: const [
              ElevationAnalysisSample(distanceKm: 0, elevationMeters: 4),
              ElevationAnalysisSample(distanceKm: 2, elevationMeters: 10),
              ElevationAnalysisSample(distanceKm: 4, elevationMeters: 5),
            ],
          ),
        ),
      );

      expect(
        snapshot.performance.badges.map((badge) => badge.kind),
        containsAll([
          AdvancedAnalysisBadgeKind.firstStep,
          AdvancedAnalysisBadgeKind.goodEndurance,
          AdvancedAnalysisBadgeKind.evenSplit,
          AdvancedAnalysisBadgeKind.controlledHeartRate,
          AdvancedAnalysisBadgeKind.easyEffort,
          AdvancedAnalysisBadgeKind.recoveryRun,
          AdvancedAnalysisBadgeKind.consistentCadence,
          AdvancedAnalysisBadgeKind.smoothRhythm,
          AdvancedAnalysisBadgeKind.hillSteady,
        ]),
      );
      final stablePaceBadges = builder
          .fromRunSummary(
            _scoreFixtureSummary().copyWith(
              paceAnalysisSeries: PaceAnalysisSeries.localAccepted(
                samples: const [
                  PaceAnalysisSample.accepted(
                    elapsedSeconds: 0,
                    cumulativeDistanceMeters: 0,
                    paceSecondsPerKm: 420,
                  ),
                  PaceAnalysisSample.accepted(
                    elapsedSeconds: 780,
                    cumulativeDistanceMeters: 2000,
                    paceSecondsPerKm: 400,
                  ),
                  PaceAnalysisSample.accepted(
                    elapsedSeconds: 1560,
                    cumulativeDistanceMeters: 4000,
                    paceSecondsPerKm: 390,
                  ),
                ],
              ),
            ),
          )
          .performance
          .badges
          .map((badge) => badge.kind);
      final strongFinishSummary = _scoreFixtureSummary();
      final strongFinishBadges = const AdvancedAnalysisAchievementBadgeBuilder()
          .build(
            summary: strongFinishSummary,
            paceAnalysis: null,
            cadenceAnalysis: null,
            heartRateAnalysis: builder
                .fromRunSummary(strongFinishSummary)
                .heartRate,
            splits: const [
              AdvancedAnalysisSplitSnapshot(
                distanceLabel: '1 km',
                paceLabel: '7’00”',
                paceSecondsPerKm: 420,
                isPartial: false,
              ),
              AdvancedAnalysisSplitSnapshot(
                distanceLabel: '2 km',
                paceLabel: '6’30”',
                paceSecondsPerKm: 390,
                isPartial: false,
              ),
            ],
          )
          .map((badge) => badge.kind);

      expect(
        stablePaceBadges,
        containsAll([
          AdvancedAnalysisBadgeKind.stablePace,
          AdvancedAnalysisBadgeKind.goodConsistency,
        ]),
      );
      expect(
        strongFinishBadges,
        containsAll([
          AdvancedAnalysisBadgeKind.strongFinish,
          AdvancedAnalysisBadgeKind.negativeSplit,
        ]),
      );
    });

    test(
      'documents even split badge when splits are steady but not faster',
      () {
        final snapshot = builder.fromRunSummary(
          _scoreFixtureSummary().copyWith(
            paceAnalysisSeries: PaceAnalysisSeries.localAccepted(
              samples: const [
                PaceAnalysisSample.accepted(
                  elapsedSeconds: 0,
                  cumulativeDistanceMeters: 0,
                  paceSecondsPerKm: 400,
                ),
                PaceAnalysisSample.accepted(
                  elapsedSeconds: 800,
                  cumulativeDistanceMeters: 2000,
                  paceSecondsPerKm: 404,
                ),
                PaceAnalysisSample.accepted(
                  elapsedSeconds: 1600,
                  cumulativeDistanceMeters: 4000,
                  paceSecondsPerKm: 410,
                ),
              ],
            ),
          ),
        );

        expect(
          snapshot.performance.badges.map((badge) => badge.kind),
          contains(AdvancedAnalysisBadgeKind.evenSplit),
        );
        expect(
          snapshot.performance.badges.map((badge) => badge.kind),
          isNot(contains(AdvancedAnalysisBadgeKind.strongFinish)),
        );
      },
    );

    test('does not award badges when required data is missing', () {
      const missingSummaryData = RunSummarySnapshot(
        title: 'Missing Summary',
        dateLabel: 'Today',
        timeLabel: '7:06 AM',
        distanceKm: '--',
        avgPace: '--',
        duration: '--',
        avgHeartRate: '--',
        calories: '0 kcal',
        routeName: 'No Data',
      );

      final badges = builder
          .fromRunSummary(missingSummaryData)
          .performance
          .badges
          .map((badge) => badge.kind);

      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.firstStep)));
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.goodEndurance)));
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.stablePace)));
      expect(
        badges,
        isNot(contains(AdvancedAnalysisBadgeKind.goodConsistency)),
      );
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.strongFinish)));
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.negativeSplit)));
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.evenSplit)));
      expect(
        badges,
        isNot(contains(AdvancedAnalysisBadgeKind.controlledHeartRate)),
      );
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.easyEffort)));
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.recoveryRun)));
      expect(
        badges,
        isNot(contains(AdvancedAnalysisBadgeKind.consistentCadence)),
      );
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.smoothRhythm)));
      expect(badges, isNot(contains(AdvancedAnalysisBadgeKind.hillSteady)));
    });

    test('missing heart rate leaves every heart rate metric unavailable', () {
      final heartRate = builder
          .fromRunSummary(_scoreFixtureSummary())
          .heartRate;

      expect(heartRate.averageHeartRate.isAvailable, isFalse);
      expect(heartRate.maxHeartRate.isAvailable, isFalse);
      expect(heartRate.targetZone.isAvailable, isFalse);
      expect(heartRate.timeInZone.isAvailable, isFalse);
      expect(heartRate.zones.isAvailable, isFalse);
      expect(
        heartRate.averageHeartRate.reason,
        AdvancedAnalysisMetricReason.missingHeartRateSource,
      );
      expect(
        heartRate.maxHeartRate.reason,
        AdvancedAnalysisMetricReason.missingHeartRateSource,
      );
    });

    test('sample-backed heart rate ignores rejected and invalid samples', () {
      final summary = _scoreFixtureSummary(
        sourceType: RunSourceType.healthConnect,
        heartRateAvailability: HeartRateAvailability.available,
        heartRateAnalysisEligibility: HeartRateAnalysisEligibility.zoneReady,
        importedMetrics: [
          ImportedWorkoutMetricContract.sampleBased(
            metric: WorkoutMetricKind.heartRateSamples,
            unit: WorkoutMetricUnit.beatsPerMinute,
            provenance: _heartRateProvenance(
              WorkoutMetricEvidenceKind.sampleBased,
            ),
            samples: [
              WorkoutMetricSample.accepted(
                elapsedSeconds: 0,
                recordedAt: null,
                value: 110,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 300,
                recordedAt: null,
                value: 130,
              ),
              WorkoutMetricSample.rejected(
                elapsedSeconds: 450,
                recordedAt: null,
                value: 220,
                rejectionReason: WorkoutSampleRejectionReason.outOfRange,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 600,
                recordedAt: null,
                value: 260,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 900,
                recordedAt: null,
                value: 150,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 1200,
                recordedAt: null,
                value: 130,
              ),
            ],
          ),
          _heartRateSummary(175),
          _maxHeartRateSummary(220),
        ],
      );

      final heartRate = builder.fromRunSummary(summary).heartRate;

      expect(heartRate.averageHeartRate.valueLabel, '130');
      expect(heartRate.maxHeartRate.valueLabel, '150');
      expect(heartRate.timeInZone.valueLabel, '81%');
      expect(
        heartRate.zones.value!
            .map((zone) => zone.percent)
            .reduce((a, b) => a + b),
        100,
      );
    });

    test('heart rate zones ignore duplicate sample intervals', () {
      final summary = _scoreFixtureSummary(
        sourceType: RunSourceType.healthConnect,
        heartRateAvailability: HeartRateAvailability.available,
        heartRateAnalysisEligibility: HeartRateAnalysisEligibility.zoneReady,
        importedMetrics: [
          ImportedWorkoutMetricContract.sampleBased(
            metric: WorkoutMetricKind.heartRateSamples,
            unit: WorkoutMetricUnit.beatsPerMinute,
            provenance: _heartRateProvenance(
              WorkoutMetricEvidenceKind.sampleBased,
            ),
            samples: [
              WorkoutMetricSample.accepted(
                elapsedSeconds: 0,
                recordedAt: null,
                value: 110,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 300,
                recordedAt: null,
                value: 130,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 300,
                recordedAt: null,
                value: 190,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 900,
                recordedAt: null,
                value: 150,
              ),
              WorkoutMetricSample.accepted(
                elapsedSeconds: 1200,
                recordedAt: null,
                value: 130,
              ),
            ],
          ),
        ],
      );

      final heartRate = builder.fromRunSummary(summary).heartRate;

      expect(heartRate.zones.value!.map((zone) => (zone.label, zone.percent)), [
        ('Zone 1', 19),
        ('Zone 2', 23),
        ('Zone 3', 19),
        ('Zone 4', 0),
        ('Zone 5', 39),
      ]);
      expect(heartRate.timeInZone.valueLabel, '42%');
    });
  });
}

RunSummarySnapshot _scoreFixtureSummary({
  RunSourceType sourceType = RunSourceType.runiacGps,
  HeartRateAvailability heartRateAvailability =
      HeartRateAvailability.unavailableNoSensor,
  HeartRateAnalysisEligibility heartRateAnalysisEligibility =
      HeartRateAnalysisEligibility.unavailable,
  List<ImportedWorkoutMetricContract> importedMetrics =
      const <ImportedWorkoutMetricContract>[],
  CadenceAnalysisSeries? cadenceAnalysisSeries,
  ElevationAnalysisSeries elevationSeries =
      const ElevationAnalysisSeries.unavailable(),
}) {
  return RunSummarySnapshot(
    title: 'Scored Run',
    dateLabel: 'Today',
    timeLabel: '7:06 AM',
    distanceKm: '4.00 km',
    avgPace: '6’30” / km',
    duration: '26:00',
    avgHeartRate: heartRateAvailability.isAvailable ? '135' : '--',
    calories: '212 kcal',
    routeName: 'East Coast Park Loop',
    sourceType: sourceType,
    heartRateAvailability: heartRateAvailability,
    heartRateAnalysisEligibility: heartRateAnalysisEligibility,
    importedMetrics: importedMetrics,
    paceAnalysisSeries: PaceAnalysisSeries.localAccepted(
      samples: const [
        PaceAnalysisSample.accepted(
          elapsedSeconds: 0,
          cumulativeDistanceMeters: 0,
          paceSecondsPerKm: 388,
        ),
        PaceAnalysisSample.accepted(
          elapsedSeconds: 780,
          cumulativeDistanceMeters: 2000,
          paceSecondsPerKm: 392,
        ),
        PaceAnalysisSample.accepted(
          elapsedSeconds: 1560,
          cumulativeDistanceMeters: 4000,
          paceSecondsPerKm: 390,
        ),
      ],
    ),
    paceGraph: PaceGraphSnapshot(
      isAvailable: true,
      points: const [
        PaceGraphPoint(
          elapsedSeconds: 0,
          progressFraction: 0,
          paceSecondsPerKm: 388,
          distanceProgressFraction: 0,
        ),
        PaceGraphPoint(
          elapsedSeconds: 780,
          progressFraction: 0.5,
          paceSecondsPerKm: 392,
          distanceProgressFraction: 0.5,
        ),
        PaceGraphPoint(
          elapsedSeconds: 1560,
          progressFraction: 1,
          paceSecondsPerKm: 390,
          distanceProgressFraction: 1,
        ),
      ],
      yAxisLabels: const ['6:20', '6:30', '6:40'],
      xAxisLabels: const ['0:00', '13:00', '26:00'],
      distanceAxisLabels: const ['0 km', '2 km', '4 km'],
      totalDurationSeconds: 1560,
    ),
    cadenceAnalysisSeries: cadenceAnalysisSeries,
    elevationSeries: elevationSeries,
  );
}

CadenceAnalysisSeries _phoneMotionCadenceSeries() {
  return CadenceAnalysisSeries.phoneMotionEstimated(
    samples: const [
      CadenceAnalysisSample.accepted(elapsedSeconds: 0, cadenceSpm: 162),
      CadenceAnalysisSample.accepted(elapsedSeconds: 600, cadenceSpm: 164),
      CadenceAnalysisSample.accepted(elapsedSeconds: 1200, cadenceSpm: 163),
    ],
  );
}

ImportedWorkoutMetricContract _heartRateSummary(int bpm) {
  return ImportedWorkoutMetricContract.summaryOnly(
    metric: WorkoutMetricKind.heartRateSummary,
    unit: WorkoutMetricUnit.beatsPerMinute,
    provenance: _heartRateProvenance(WorkoutMetricEvidenceKind.summaryOnly),
    summaryValue: bpm,
  );
}

ImportedWorkoutMetricContract _maxHeartRateSummary(int bpm) {
  return ImportedWorkoutMetricContract.summaryOnly(
    metric: WorkoutMetricKind.maxHeartRateSummary,
    unit: WorkoutMetricUnit.beatsPerMinute,
    provenance: _heartRateProvenance(WorkoutMetricEvidenceKind.summaryOnly),
    summaryValue: bpm,
  );
}

ImportedWorkoutMetricContract _heartRateSamples(
  List<({int elapsedSeconds, int bpm})> samples,
) {
  return ImportedWorkoutMetricContract.sampleBased(
    metric: WorkoutMetricKind.heartRateSamples,
    unit: WorkoutMetricUnit.beatsPerMinute,
    provenance: _heartRateProvenance(WorkoutMetricEvidenceKind.sampleBased),
    samples: [
      for (final sample in samples)
        WorkoutMetricSample.accepted(
          elapsedSeconds: sample.elapsedSeconds,
          recordedAt: null,
          value: sample.bpm,
        ),
    ],
  );
}

WorkoutMetricProvenance _heartRateProvenance(
  WorkoutMetricEvidenceKind evidenceKind,
) {
  return WorkoutMetricProvenance(
    source: WorkoutMetricSource.healthConnect,
    confidence: WorkoutMetricConfidence.high,
    evidenceKind: evidenceKind,
  );
}
