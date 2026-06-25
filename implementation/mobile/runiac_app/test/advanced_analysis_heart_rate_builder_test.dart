import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/heart_rate_analysis_eligibility.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/workout_metric_contract.dart';
import 'package:runiac_app/features/run/domain/services/advanced_analysis_heart_rate_builder.dart';

void main() {
  group('AdvancedAnalysisHeartRateBuilder', () {
    const builder = AdvancedAnalysisHeartRateBuilder();

    test('keeps accepted heart-rate samples recorded-only by default', () {
      final summary = _summary(
        sourceType: RunSourceType.healthConnect,
        heartRateAvailability: HeartRateAvailability.available,
        importedMetrics: [
          _heartRateSamples([
            (elapsedSeconds: 0, bpm: 110),
            (elapsedSeconds: 300, bpm: 128),
            (elapsedSeconds: 600, bpm: 142),
            (elapsedSeconds: 900, bpm: 151),
            (elapsedSeconds: 1200, bpm: 135),
            (elapsedSeconds: 1560, bpm: 132),
          ]),
        ],
      );

      final heartRate = builder.build(summary);

      expect(heartRate.eligibility, HeartRateAnalysisEligibility.recordedOnly);
      expect(heartRate.averageHeartRate.valueLabel, '133');
      expect(heartRate.maxHeartRate.valueLabel, '151');
      expect(heartRate.targetZone.isAvailable, isFalse);
      expect(heartRate.timeInZone.isAvailable, isFalse);
      expect(heartRate.zones.isAvailable, isFalse);
    });

    test('exposes zones only for explicit zone-ready summaries', () {
      final summary = _summary(
        sourceType: RunSourceType.healthConnect,
        heartRateAvailability: HeartRateAvailability.available,
        heartRateAnalysisEligibility: HeartRateAnalysisEligibility.zoneReady,
        importedMetrics: [
          _heartRateSamples([
            (elapsedSeconds: 0, bpm: 110),
            (elapsedSeconds: 300, bpm: 128),
            (elapsedSeconds: 600, bpm: 142),
            (elapsedSeconds: 900, bpm: 151),
            (elapsedSeconds: 1200, bpm: 135),
            (elapsedSeconds: 1560, bpm: 132),
          ]),
        ],
      );

      final heartRate = builder.build(summary);

      expect(heartRate.eligibility, HeartRateAnalysisEligibility.zoneReady);
      expect(heartRate.targetZone.valueLabel, '120-169 bpm');
      expect(heartRate.timeInZone.valueLabel, '81%');
      expect(heartRate.zones.isAvailable, isTrue);
      expect(heartRate.zones.value!.map((zone) => (zone.label, zone.percent)), [
        ('Zone 1', 19),
        ('Zone 2', 62),
        ('Zone 3', 19),
        ('Zone 4', 0),
        ('Zone 5', 0),
      ]);
    });
  });
}

RunSummarySnapshot _summary({
  required RunSourceType sourceType,
  required HeartRateAvailability heartRateAvailability,
  HeartRateAnalysisEligibility heartRateAnalysisEligibility =
      HeartRateAnalysisEligibility.unavailable,
  List<ImportedWorkoutMetricContract> importedMetrics =
      const <ImportedWorkoutMetricContract>[],
}) {
  return RunSummarySnapshot(
    title: 'Heart Rate Run',
    dateLabel: 'Today',
    timeLabel: '7:06 AM',
    distanceKm: '4.00 km',
    avgPace: '6’30” / km',
    duration: '26:00',
    avgHeartRate: heartRateAvailability.isAvailable ? '133' : '--',
    calories: '212 kcal',
    routeName: 'East Coast Park Loop',
    sourceType: sourceType,
    heartRateAvailability: heartRateAvailability,
    heartRateAnalysisEligibility: heartRateAnalysisEligibility,
    importedMetrics: importedMetrics,
  );
}

ImportedWorkoutMetricContract _heartRateSamples(
  List<({int elapsedSeconds, int bpm})> samples,
) {
  return ImportedWorkoutMetricContract.sampleBased(
    metric: WorkoutMetricKind.heartRateSamples,
    unit: WorkoutMetricUnit.beatsPerMinute,
    provenance: const WorkoutMetricProvenance(
      source: WorkoutMetricSource.healthConnect,
      confidence: WorkoutMetricConfidence.high,
      evidenceKind: WorkoutMetricEvidenceKind.sampleBased,
    ),
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
