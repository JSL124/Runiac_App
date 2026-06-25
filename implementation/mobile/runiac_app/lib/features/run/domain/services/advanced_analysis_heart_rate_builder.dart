import '../models/advanced_analysis_snapshot.dart';
import '../models/heart_rate_analysis_eligibility.dart';
import '../models/run_source_display.dart';
import '../models/run_summary_snapshot.dart';
import '../models/workout_metric_contract.dart';
import 'advanced_analysis_heart_rate_zone_policy.dart';

class AdvancedAnalysisHeartRateBuilder {
  const AdvancedAnalysisHeartRateBuilder({
    this.zonePolicy = const AdvancedAnalysisHeartRateZonePolicy(),
  });

  final AdvancedAnalysisHeartRateZonePolicy zonePolicy;

  AdvancedAnalysisHeartRateAnalysis build(RunSummarySnapshot summary) {
    final sampleMetric = _metric(summary, WorkoutMetricKind.heartRateSamples);
    final samples = _acceptedHeartRateSamples(sampleMetric);
    final hasSampleMetrics = samples.length >= 2;
    final sampleAverageMetric = hasSampleMetrics
        ? _heartRateTextMetric(
            '${_averageHeartRate(samples)}',
            _heartRateMetricSource(sampleMetric!, summary.sourceType),
          )
        : null;
    final sampleMaxMetric = hasSampleMetrics
        ? _heartRateTextMetric(
            '${_maxHeartRate(samples)}',
            _heartRateMetricSource(sampleMetric!, summary.sourceType),
          )
        : null;

    final averageMetric =
        sampleAverageMetric ??
        _scalarHeartRateMetric(
          summary: summary,
          kind: WorkoutMetricKind.heartRateSummary,
          fallbackLabel: summary.avgHeartRate,
        );
    final maxMetric =
        sampleMaxMetric ??
        _scalarHeartRateMetric(
          summary: summary,
          kind: WorkoutMetricKind.maxHeartRateSummary,
        );
    final eligibility = _eligibility(
      summary: summary,
      sampleMetric: sampleMetric,
      samples: samples,
      averageMetric: averageMetric,
      maxMetric: maxMetric,
    );

    if (samples.length >= 2) {
      final source = _heartRateMetricSource(sampleMetric!, summary.sourceType);
      final zones = zonePolicy.zonesForSamples(
        samples,
        _durationSeconds(summary.duration),
      );
      if (eligibility.allowsZoneAnalysis && zones.isNotEmpty) {
        final targetPercent = zonePolicy.targetPercent(zones);
        return AdvancedAnalysisHeartRateAnalysis(
          eligibility: eligibility,
          averageHeartRate: averageMetric,
          maxHeartRate: maxMetric,
          targetZone: _heartRateTextMetric(zonePolicy.targetLabel, source),
          timeInZone: _heartRateTextMetric('$targetPercent%', source),
          zones:
              AdvancedAnalysisMetric<
                List<AdvancedAnalysisHeartRateZone>
              >.available(
                value: zones,
                source: source,
                confidence: AdvancedAnalysisMetricConfidence.derived,
              ),
        );
      }
    }

    return AdvancedAnalysisHeartRateAnalysis(
      eligibility: eligibility,
      averageHeartRate: averageMetric,
      maxHeartRate: maxMetric,
      targetZone: const AdvancedAnalysisMetric<String>.unavailable(
        reason: AdvancedAnalysisMetricReason.missingHeartRateZonePolicy,
      ),
      timeInZone: const AdvancedAnalysisMetric<String>.unavailable(
        reason: AdvancedAnalysisMetricReason.missingHeartRateZonePolicy,
      ),
      zones:
          const AdvancedAnalysisMetric<
            List<AdvancedAnalysisHeartRateZone>
          >.unavailable(
            reason: AdvancedAnalysisMetricReason.missingHeartRateZonePolicy,
          ),
    );
  }

  AdvancedAnalysisMetric<String> _scalarHeartRateMetric({
    required RunSummarySnapshot summary,
    required WorkoutMetricKind kind,
    String? fallbackLabel,
  }) {
    final metric = _metric(summary, kind);
    if (metric != null &&
        metric.isAvailable &&
        metric.isSummaryOnly &&
        metric.summaryValue != null) {
      return _heartRateTextMetric(
        metric.summaryValue!.round().toString(),
        _heartRateMetricSource(metric, summary.sourceType),
      );
    }
    if (kind == WorkoutMetricKind.heartRateSummary &&
        _hasTrustedHeartRateSource(summary) &&
        fallbackLabel != null &&
        _hasDisplayValue(fallbackLabel)) {
      return _heartRateTextMetric(
        fallbackLabel,
        _heartRateSource(summary.sourceType),
      );
    }
    return const AdvancedAnalysisMetric<String>.unavailable(
      reason: AdvancedAnalysisMetricReason.missingHeartRateSource,
    );
  }

  AdvancedAnalysisMetric<String> _heartRateTextMetric(
    String valueLabel,
    AdvancedAnalysisMetricSource source,
  ) {
    return AdvancedAnalysisMetric<String>.available(
      value: valueLabel,
      valueLabel: valueLabel,
      source: source,
      confidence: AdvancedAnalysisMetricConfidence.derived,
    );
  }

  ImportedWorkoutMetricContract? _metric(
    RunSummarySnapshot summary,
    WorkoutMetricKind kind,
  ) {
    for (final metric in summary.importedMetrics) {
      if (metric.metric == kind) {
        return metric;
      }
    }
    return null;
  }

  List<WorkoutMetricSample> _acceptedHeartRateSamples(
    ImportedWorkoutMetricContract? metric,
  ) {
    if (metric == null ||
        !metric.isAvailable ||
        !metric.isSampleBased ||
        metric.metric != WorkoutMetricKind.heartRateSamples) {
      return const <WorkoutMetricSample>[];
    }
    final samples = metric.acceptedSamples
        .where((sample) {
          final value = sample.value;
          return value.isFinite && value >= 30 && value <= 240;
        })
        .toList(growable: false);
    samples.sort((a, b) => a.elapsedSeconds.compareTo(b.elapsedSeconds));
    return List<WorkoutMetricSample>.unmodifiable(samples);
  }

  int _averageHeartRate(List<WorkoutMetricSample> samples) {
    final total = samples.fold<num>(0, (sum, sample) => sum + sample.value);
    return (total / samples.length).round();
  }

  int _maxHeartRate(List<WorkoutMetricSample> samples) {
    return samples
        .map((sample) => sample.value.round())
        .reduce((a, b) => a > b ? a : b);
  }

  HeartRateAnalysisEligibility _eligibility({
    required RunSummarySnapshot summary,
    required ImportedWorkoutMetricContract? sampleMetric,
    required List<WorkoutMetricSample> samples,
    required AdvancedAnalysisMetric<String> averageMetric,
    required AdvancedAnalysisMetric<String> maxMetric,
  }) {
    final hasHeartRateMetric =
        averageMetric.isAvailable || maxMetric.isAvailable;
    final requestedEligibility = summary.heartRateAnalysisEligibility;
    if (!requestedEligibility.allowsZoneAnalysis) {
      return hasHeartRateMetric
          ? HeartRateAnalysisEligibility.recordedOnly
          : HeartRateAnalysisEligibility.unavailable;
    }
    if (sampleMetric == null ||
        !sampleMetric.supportsTrendAnalysis ||
        samples.length < 2 ||
        !summary.heartRateAvailability.isAvailable) {
      return hasHeartRateMetric
          ? HeartRateAnalysisEligibility.qualityLimited
          : HeartRateAnalysisEligibility.unavailable;
    }
    return HeartRateAnalysisEligibility.zoneReady;
  }

  bool _hasTrustedHeartRateSource(RunSummarySnapshot summary) {
    if (!summary.heartRateAvailability.isAvailable) {
      return false;
    }
    return _hasWearableSource(summary.sourceType);
  }

  AdvancedAnalysisMetricSource _heartRateMetricSource(
    ImportedWorkoutMetricContract metric,
    RunSourceType fallbackSource,
  ) {
    return switch (metric.provenance.source) {
      WorkoutMetricSource.healthKitAppleWatch =>
        AdvancedAnalysisMetricSource.healthKitAppleWatch,
      WorkoutMetricSource.healthConnect =>
        AdvancedAnalysisMetricSource.healthConnect,
      WorkoutMetricSource.garminWearable =>
        AdvancedAnalysisMetricSource.garminWearable,
      WorkoutMetricSource.backendDerived =>
        AdvancedAnalysisMetricSource.backendDerived,
      _ => _heartRateSource(fallbackSource),
    };
  }

  AdvancedAnalysisMetricSource _heartRateSource(RunSourceType sourceType) {
    return switch (sourceType) {
      RunSourceType.appleHealth =>
        AdvancedAnalysisMetricSource.healthKitAppleWatch,
      RunSourceType.healthConnect => AdvancedAnalysisMetricSource.healthConnect,
      RunSourceType.garminViaHealth =>
        AdvancedAnalysisMetricSource.garminWearable,
      RunSourceType.runiacGps => AdvancedAnalysisMetricSource.localGpsDerived,
      RunSourceType.demoImport => AdvancedAnalysisMetricSource.staticDemo,
    };
  }

  bool _hasWearableSource(RunSourceType sourceType) {
    return switch (sourceType) {
      RunSourceType.appleHealth ||
      RunSourceType.healthConnect ||
      RunSourceType.garminViaHealth => true,
      RunSourceType.runiacGps || RunSourceType.demoImport => false,
    };
  }

  bool _hasDisplayValue(String valueLabel) {
    final normalized = valueLabel.trim();
    return normalized.isNotEmpty && normalized != '--';
  }

  int? _durationSeconds(String durationLabel) {
    final normalized = durationLabel.trim();
    if (normalized.isEmpty || normalized == '--') {
      return null;
    }

    final minuteSecondMatch = RegExp(
      r'^(\d+):([0-5]\d)$',
    ).firstMatch(normalized);
    if (minuteSecondMatch != null) {
      final minutes = int.parse(minuteSecondMatch.group(1)!);
      final seconds = int.parse(minuteSecondMatch.group(2)!);
      final totalSeconds = minutes * 60 + seconds;
      return totalSeconds > 0 ? totalSeconds : null;
    }

    final hourMinuteSecondMatch = RegExp(
      r'^(\d+):([0-5]\d):([0-5]\d)$',
    ).firstMatch(normalized);
    if (hourMinuteSecondMatch == null) {
      return null;
    }
    final hours = int.parse(hourMinuteSecondMatch.group(1)!);
    final minutes = int.parse(hourMinuteSecondMatch.group(2)!);
    final seconds = int.parse(hourMinuteSecondMatch.group(3)!);
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    return totalSeconds > 0 ? totalSeconds : null;
  }
}
