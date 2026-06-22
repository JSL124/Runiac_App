import '../models/cadence_adapter_result.dart';
import '../models/imported_workout_candidate.dart';
import '../models/run_source_display.dart';
import '../models/workout_metric_contract.dart';

const importedWorkoutCandidateMetricAdapterVersion =
    'imported-workout-candidate-mapper-v1';

class ImportedWorkoutMetricContractMapping {
  ImportedWorkoutMetricContractMapping({
    required this.externalId,
    required this.activityType,
    required this.startedAt,
    required this.endedAt,
    required this.importedAt,
    required List<ImportedWorkoutMetricContract> metrics,
    this.cadenceAdapterResult,
  }) : metrics = List<ImportedWorkoutMetricContract>.unmodifiable(metrics);

  final String externalId;
  final ImportedWorkoutActivityType activityType;
  final DateTime startedAt;
  final DateTime endedAt;
  final DateTime importedAt;
  final List<ImportedWorkoutMetricContract> metrics;
  final CadenceAdapterResult? cadenceAdapterResult;

  ImportedWorkoutMetricContract metric(WorkoutMetricKind kind) {
    return metrics.firstWhere(
      (metric) => metric.metric == kind,
      orElse: () => throw StateError('missing imported workout metric: $kind'),
    );
  }
}

class ImportedWorkoutMetricContractMapper {
  const ImportedWorkoutMetricContractMapper();

  ImportedWorkoutMetricContractMapping map(ImportedWorkoutCandidate candidate) {
    final summaryProvenance = provenanceFor(
      sourceType: candidate.sourceType,
      evidenceKind: WorkoutMetricEvidenceKind.summaryOnly,
      externalId: candidate.externalId,
      importedAt: candidate.importedAt,
    );
    final unavailableProvenance = summaryProvenance.copyWith(
      evidenceKind: WorkoutMetricEvidenceKind.unavailable,
    );
    final metrics = <ImportedWorkoutMetricContract>[
      _summary(
        WorkoutMetricKind.distance,
        WorkoutMetricUnit.meters,
        candidate.distanceMeters,
        summaryProvenance,
      ),
      _summary(
        WorkoutMetricKind.elapsedDuration,
        WorkoutMetricUnit.seconds,
        candidate.durationSeconds,
        summaryProvenance,
      ),
      _unavailable(
        WorkoutMetricKind.movingDuration,
        WorkoutMetricUnit.seconds,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.unavailableUnknown,
      ),
      _unavailable(
        WorkoutMetricKind.pauseDuration,
        WorkoutMetricUnit.seconds,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.unavailableUnknown,
      ),
      _summary(
        WorkoutMetricKind.averagePace,
        WorkoutMetricUnit.secondsPerKilometer,
        candidate.avgPaceSecondsPerKm,
        summaryProvenance,
      ),
      _unavailable(
        WorkoutMetricKind.paceSamples,
        WorkoutMetricUnit.secondsPerKilometer,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.notProvidedBySource,
      ),
      _unavailable(
        WorkoutMetricKind.routeSamples,
        WorkoutMetricUnit.coordinate,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.notProvidedBySource,
      ),
      _unavailable(
        WorkoutMetricKind.gpsQuality,
        WorkoutMetricUnit.qualityEvent,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.notProvidedBySource,
      ),
      _heartRateSummary(
        kind: WorkoutMetricKind.heartRateSummary,
        value: candidate.avgHeartRateBpm,
        availability: candidate.heartRateAvailability,
        summaryProvenance: summaryProvenance,
        unavailableProvenance: unavailableProvenance,
      ),
      _heartRateSummary(
        kind: WorkoutMetricKind.maxHeartRateSummary,
        value: candidate.maxHeartRateBpm,
        availability: candidate.heartRateAvailability,
        summaryProvenance: summaryProvenance,
        unavailableProvenance: unavailableProvenance,
      ),
      _unavailable(
        WorkoutMetricKind.heartRateSamples,
        WorkoutMetricUnit.beatsPerMinute,
        unavailableProvenance,
        _heartRateUnavailableReason(candidate.heartRateAvailability),
      ),
      _unavailable(
        WorkoutMetricKind.cadenceSummary,
        WorkoutMetricUnit.stepsPerMinute,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.notProvidedBySource,
      ),
      _unavailable(
        WorkoutMetricKind.cadenceSamples,
        WorkoutMetricUnit.stepsPerMinute,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.notProvidedBySource,
      ),
      _unavailable(
        WorkoutMetricKind.strideLength,
        WorkoutMetricUnit.meters,
        unavailableProvenance,
        WorkoutMetricAvailabilityReason.notProvidedBySource,
      ),
      _summary(
        WorkoutMetricKind.calories,
        WorkoutMetricUnit.kilocalories,
        candidate.calories,
        summaryProvenance,
      ),
    ];

    return ImportedWorkoutMetricContractMapping(
      externalId: candidate.externalId,
      activityType: candidate.activityType,
      startedAt: candidate.startedAt,
      endedAt: candidate.endedAt,
      importedAt: candidate.importedAt,
      metrics: metrics,
    );
  }

  WorkoutMetricProvenance provenanceFor({
    required RunSourceType sourceType,
    required WorkoutMetricEvidenceKind evidenceKind,
    required String externalId,
    required DateTime importedAt,
  }) {
    return WorkoutMetricProvenance(
      source: _metricSource(sourceType),
      confidence: _metricConfidence(sourceType),
      evidenceKind: evidenceKind,
      sourceAppName: sourceType.label,
      sourceExternalId: externalId,
      importedAt: importedAt,
      adapterVersion: importedWorkoutCandidateMetricAdapterVersion,
    );
  }

  ImportedWorkoutMetricContract _heartRateSummary({
    required WorkoutMetricKind kind,
    required int? value,
    required HeartRateAvailability availability,
    required WorkoutMetricProvenance summaryProvenance,
    required WorkoutMetricProvenance unavailableProvenance,
  }) {
    final heartRateValue = value;
    if (heartRateValue == null) {
      return _unavailable(
        kind,
        WorkoutMetricUnit.beatsPerMinute,
        unavailableProvenance,
        _heartRateUnavailableReason(availability),
      );
    }
    return _summary(
      kind,
      WorkoutMetricUnit.beatsPerMinute,
      heartRateValue,
      summaryProvenance,
    );
  }

  ImportedWorkoutMetricContract _summary(
    WorkoutMetricKind kind,
    WorkoutMetricUnit unit,
    num value,
    WorkoutMetricProvenance provenance,
  ) {
    return ImportedWorkoutMetricContract.summaryOnly(
      metric: kind,
      unit: unit,
      provenance: provenance,
      summaryValue: value,
    );
  }

  ImportedWorkoutMetricContract _unavailable(
    WorkoutMetricKind kind,
    WorkoutMetricUnit unit,
    WorkoutMetricProvenance provenance,
    WorkoutMetricAvailabilityReason reason,
  ) {
    return ImportedWorkoutMetricContract.unavailable(
      metric: kind,
      unit: unit,
      provenance: provenance,
      unavailableReason: reason,
    );
  }

  WorkoutMetricSource _metricSource(RunSourceType sourceType) {
    return switch (sourceType) {
      RunSourceType.runiacGps => WorkoutMetricSource.runiacLocalGps,
      RunSourceType.appleHealth => WorkoutMetricSource.healthKitAppleWatch,
      RunSourceType.healthConnect => WorkoutMetricSource.healthConnect,
      RunSourceType.garminViaHealth => WorkoutMetricSource.garminWearable,
      RunSourceType.demoImport => WorkoutMetricSource.staticDemo,
    };
  }

  WorkoutMetricConfidence _metricConfidence(RunSourceType sourceType) {
    return switch (sourceType) {
      RunSourceType.runiacGps => WorkoutMetricConfidence.medium,
      RunSourceType.appleHealth ||
      RunSourceType.healthConnect ||
      RunSourceType.garminViaHealth => WorkoutMetricConfidence.high,
      RunSourceType.demoImport => WorkoutMetricConfidence.demo,
    };
  }

  WorkoutMetricAvailabilityReason _heartRateUnavailableReason(
    HeartRateAvailability availability,
  ) {
    return switch (availability) {
      HeartRateAvailability.available =>
        WorkoutMetricAvailabilityReason.unavailableUnknown,
      HeartRateAvailability.unavailableNoSensor =>
        WorkoutMetricAvailabilityReason.notProvidedBySource,
      HeartRateAvailability.unavailableNotShared =>
        WorkoutMetricAvailabilityReason.notSharedByUser,
    };
  }
}
