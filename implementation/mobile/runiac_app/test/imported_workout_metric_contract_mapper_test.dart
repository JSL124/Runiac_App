import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/imported_workout_candidate.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';
import 'package:runiac_app/features/run/domain/models/workout_metric_contract.dart';
import 'package:runiac_app/features/run/domain/services/imported_workout_metric_contract_mapper.dart';

void main() {
  group('ImportedWorkoutMetricContractMapper', () {
    const mapper = ImportedWorkoutMetricContractMapper();

    test('maps candidate summaries without inventing samples', () {
      final candidate = ImportedWorkoutCandidate(
        externalId: 'apple-health-run-2026-06-15',
        sourceType: RunSourceType.appleHealth,
        activityType: ImportedWorkoutActivityType.running,
        startedAt: DateTime.utc(2026, 6, 15, 6, 30),
        endedAt: DateTime.utc(2026, 6, 15, 7, 5),
        durationSeconds: 2100,
        distanceMeters: 5000,
        avgPaceSecondsPerKm: 420,
        avgHeartRateBpm: 154,
        maxHeartRateBpm: 171,
        calories: 340,
        heartRateAvailability: HeartRateAvailability.available,
        importedAt: DateTime.utc(2026, 6, 19, 7),
      );

      final mapping = mapper.map(candidate);
      final distance = mapping.metric(WorkoutMetricKind.distance);
      final elapsedDuration = mapping.metric(WorkoutMetricKind.elapsedDuration);
      final movingDuration = mapping.metric(WorkoutMetricKind.movingDuration);
      final averagePace = mapping.metric(WorkoutMetricKind.averagePace);
      final calories = mapping.metric(WorkoutMetricKind.calories);
      final averageHeartRate = mapping.metric(
        WorkoutMetricKind.heartRateSummary,
      );
      final maxHeartRate = mapping.metric(
        WorkoutMetricKind.maxHeartRateSummary,
      );
      final paceSamples = mapping.metric(WorkoutMetricKind.paceSamples);
      final routeSamples = mapping.metric(WorkoutMetricKind.routeSamples);
      final cadenceSamples = mapping.metric(WorkoutMetricKind.cadenceSamples);

      expect(mapping.externalId, 'apple-health-run-2026-06-15');
      expect(mapping.importedAt, DateTime.utc(2026, 6, 19, 7));
      expect(mapping.cadenceAdapterResult, isNull);
      expect(distance.summaryValue, 5000);
      expect(distance.unit, WorkoutMetricUnit.meters);
      expect(elapsedDuration.summaryValue, 2100);
      expect(elapsedDuration.unit, WorkoutMetricUnit.seconds);
      expect(movingDuration.isAvailable, isFalse);
      expect(averagePace.summaryValue, 420);
      expect(averagePace.supportsTrendAnalysis, isFalse);
      expect(calories.summaryValue, 340);
      expect(calories.affectsBackendOwnedProgression, isFalse);
      expect(averageHeartRate.summaryValue, 154);
      expect(maxHeartRate.summaryValue, 171);
      expect(paceSamples.isAvailable, isFalse);
      expect(routeSamples.supportsRouteSamples, isFalse);
      expect(cadenceSamples.isAvailable, isFalse);
      expect(
        distance.provenance.source,
        WorkoutMetricSource.healthKitAppleWatch,
      );
      expect(distance.provenance.sourceAppName, 'Apple Health');
      expect(distance.provenance.sourceExternalId, candidate.externalId);
      expect(distance.provenance.importedAt, candidate.importedAt);
      expect(distance.provenance.isImportedOrWearable, isTrue);
      expect(distance.affectsBackendOwnedProgression, isFalse);
    });

    test('keeps unavailable heart rate and sample metrics explicit', () {
      final candidate = ImportedWorkoutCandidate(
        externalId: 'health-connect-run-2026-06-13',
        sourceType: RunSourceType.healthConnect,
        activityType: ImportedWorkoutActivityType.running,
        startedAt: DateTime.utc(2026, 6, 13, 8),
        endedAt: DateTime.utc(2026, 6, 13, 8, 28),
        durationSeconds: 1680,
        distanceMeters: 3600,
        avgPaceSecondsPerKm: 467,
        calories: 240,
        heartRateAvailability: HeartRateAvailability.unavailableNotShared,
        importedAt: DateTime.utc(2026, 6, 19, 7),
      );

      final mapping = mapper.map(candidate);
      final averageHeartRate = mapping.metric(
        WorkoutMetricKind.heartRateSummary,
      );
      final maxHeartRate = mapping.metric(
        WorkoutMetricKind.maxHeartRateSummary,
      );
      final heartRateSamples = mapping.metric(
        WorkoutMetricKind.heartRateSamples,
      );

      expect(mapping.metric(WorkoutMetricKind.distance).summaryValue, 3600);
      expect(averageHeartRate.isAvailable, isFalse);
      expect(
        averageHeartRate.unavailableReason,
        WorkoutMetricAvailabilityReason.notSharedByUser,
      );
      expect(maxHeartRate.isAvailable, isFalse);
      expect(heartRateSamples.isAvailable, isFalse);
      expect(heartRateSamples.supportsTrendAnalysis, isFalse);
      expect(
        mapping.metric(WorkoutMetricKind.distance).provenance.source,
        WorkoutMetricSource.healthConnect,
      );
    });

    test(
      'maps source confidence conservatively without collapsing imports',
      () {
        expect(
          mapper
              .provenanceFor(
                sourceType: RunSourceType.appleHealth,
                evidenceKind: WorkoutMetricEvidenceKind.summaryOnly,
                externalId: 'apple',
                importedAt: DateTime.utc(2026),
              )
              .source,
          WorkoutMetricSource.healthKitAppleWatch,
        );
        expect(
          mapper
              .provenanceFor(
                sourceType: RunSourceType.healthConnect,
                evidenceKind: WorkoutMetricEvidenceKind.summaryOnly,
                externalId: 'health-connect',
                importedAt: DateTime.utc(2026),
              )
              .source,
          WorkoutMetricSource.healthConnect,
        );
        expect(
          mapper
              .provenanceFor(
                sourceType: RunSourceType.garminViaHealth,
                evidenceKind: WorkoutMetricEvidenceKind.summaryOnly,
                externalId: 'garmin',
                importedAt: DateTime.utc(2026),
              )
              .source,
          WorkoutMetricSource.garminWearable,
        );

        final demo = mapper.provenanceFor(
          sourceType: RunSourceType.demoImport,
          evidenceKind: WorkoutMetricEvidenceKind.summaryOnly,
          externalId: 'demo',
          importedAt: DateTime.utc(2026),
        );
        final local = mapper.provenanceFor(
          sourceType: RunSourceType.runiacGps,
          evidenceKind: WorkoutMetricEvidenceKind.summaryOnly,
          externalId: 'local',
          importedAt: DateTime.utc(2026),
        );

        expect(demo.source, WorkoutMetricSource.staticDemo);
        expect(demo.confidence, WorkoutMetricConfidence.demo);
        expect(demo.isProductionTrusted, isFalse);
        expect(local.source, WorkoutMetricSource.runiacLocalGps);
        expect(local.confidence, WorkoutMetricConfidence.medium);
        expect(local.isImportedOrWearable, isFalse);
      },
    );
  });
}
