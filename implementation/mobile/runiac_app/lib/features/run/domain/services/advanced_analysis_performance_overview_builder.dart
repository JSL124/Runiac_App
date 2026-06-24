import '../models/advanced_analysis_snapshot.dart';
import '../models/cadence_analysis_derivation.dart';
import '../models/cadence_analysis_series.dart';
import '../models/run_source_display.dart';
import '../models/run_summary_snapshot.dart';
import 'advanced_analysis_achievement_badge_builder.dart';
import 'pace_analysis_deriver.dart';

class AdvancedAnalysisPerformanceOverviewBuilder {
  const AdvancedAnalysisPerformanceOverviewBuilder();

  AdvancedAnalysisPerformanceOverview build({
    required RunSummarySnapshot summary,
    required PaceAnalysisDerivation? paceAnalysis,
    required CadenceAnalysisDerivation? cadenceAnalysis,
    required AdvancedAnalysisHeartRateAnalysis heartRateAnalysis,
    required List<AdvancedAnalysisSplitSnapshot> splits,
  }) {
    final scoreMode = _scoreMode(summary, cadenceAnalysis, heartRateAnalysis);
    final score = _performanceScore(
      summary: summary,
      paceAnalysis: paceAnalysis,
      cadenceAnalysis: cadenceAnalysis,
      heartRateAnalysis: heartRateAnalysis,
      scoreMode: scoreMode,
    );
    return AdvancedAnalysisPerformanceOverview(
      score: score,
      duration: _sourceAwareSummaryMetric(summary.duration, summary),
      distance: _sourceAwareSummaryMetric(summary.distanceKm, summary),
      scoreMode: scoreMode,
      scoreConfidenceLabel: _scoreConfidenceLabel(scoreMode),
      badges: const AdvancedAnalysisAchievementBadgeBuilder().build(
        summary: summary,
        paceAnalysis: paceAnalysis,
        cadenceAnalysis: cadenceAnalysis,
        heartRateAnalysis: heartRateAnalysis,
        splits: splits,
      ),
    );
  }

  AdvancedAnalysisScoreSourceMode _scoreMode(
    RunSummarySnapshot summary,
    CadenceAnalysisDerivation? cadenceAnalysis,
    AdvancedAnalysisHeartRateAnalysis heartRateAnalysis,
  ) {
    if (summary.sourceType == RunSourceType.demoImport) {
      return AdvancedAnalysisScoreSourceMode.demoOnly;
    }
    if (heartRateAnalysis.zones.isAvailable ||
        _hasWearableSource(summary.sourceType)) {
      return AdvancedAnalysisScoreSourceMode.wearableBacked;
    }
    if (cadenceAnalysis?.source == CadenceAnalysisSource.phoneSensorEstimated) {
      return AdvancedAnalysisScoreSourceMode.mixedSource;
    }
    return AdvancedAnalysisScoreSourceMode.mobileOnly;
  }

  String _scoreConfidenceLabel(AdvancedAnalysisScoreSourceMode mode) {
    return switch (mode) {
      AdvancedAnalysisScoreSourceMode.mobileOnly => 'Phone data',
      AdvancedAnalysisScoreSourceMode.wearableBacked => 'Wearable-backed',
      AdvancedAnalysisScoreSourceMode.mixedSource => 'Mixed phone data',
      AdvancedAnalysisScoreSourceMode.demoOnly => 'Demo data',
    };
  }

  AdvancedAnalysisMetric<int> _performanceScore({
    required RunSummarySnapshot summary,
    required PaceAnalysisDerivation? paceAnalysis,
    required CadenceAnalysisDerivation? cadenceAnalysis,
    required AdvancedAnalysisHeartRateAnalysis heartRateAnalysis,
    required AdvancedAnalysisScoreSourceMode scoreMode,
  }) {
    final distanceKm = _distanceKm(summary.distanceKm);
    final durationSeconds = _durationSeconds(summary.duration);
    if (distanceKm == null || durationSeconds == null) {
      return const AdvancedAnalysisMetric<int>.unavailable(
        reason: AdvancedAnalysisMetricReason.missingSummaryField,
      );
    }

    final paceStability = paceAnalysis?.paceStabilityScore;
    final cadenceStable = cadenceAnalysis?.stability == CadenceStability.stable
        ? 1
        : 0;
    final hasElevation = summary.elevationSeries.hasMinimumValidSamples();
    final targetZonePercent = _targetZonePercent(heartRateAnalysis);

    final score = switch (scoreMode) {
      AdvancedAnalysisScoreSourceMode.mobileOnly =>
        45 +
            (distanceKm * 6).round().clamp(0, 24) +
            (durationSeconds / 120).round().clamp(0, 16) +
            ((paceStability ?? 50) * 0.15).round() +
            (hasElevation ? 4 : 0),
      AdvancedAnalysisScoreSourceMode.mixedSource =>
        48 +
            (distanceKm * 5).round().clamp(0, 20) +
            (durationSeconds / 150).round().clamp(0, 13) +
            ((paceStability ?? 50) * 0.13).round() +
            cadenceStable * 6 +
            (hasElevation ? 3 : 0),
      AdvancedAnalysisScoreSourceMode.wearableBacked =>
        42 +
            (distanceKm * 4).round().clamp(0, 18) +
            (durationSeconds / 180).round().clamp(0, 10) +
            ((paceStability ?? 50) * 0.12).round() +
            ((targetZonePercent ?? 0) * 0.12).round() +
            cadenceStable * 6 +
            (hasElevation ? 4 : 0),
      AdvancedAnalysisScoreSourceMode.demoOnly =>
        40 +
            (distanceKm * 4).round().clamp(0, 18) +
            (durationSeconds / 180).round().clamp(0, 10),
    };

    final clampedScore = score.clamp(0, 100).toInt();
    if (scoreMode == AdvancedAnalysisScoreSourceMode.demoOnly) {
      return AdvancedAnalysisMetric<int>(
        availability: AdvancedAnalysisMetricAvailability.demoOnly,
        source: AdvancedAnalysisMetricSource.staticDemo,
        confidence: AdvancedAnalysisMetricConfidence.demo,
        value: clampedScore,
        valueLabel: '$clampedScore',
        reason: AdvancedAnalysisMetricReason.demoFixtureOnly,
      );
    }
    return AdvancedAnalysisMetric<int>.available(
      value: clampedScore,
      valueLabel: '$clampedScore',
      source: scoreMode == AdvancedAnalysisScoreSourceMode.wearableBacked
          ? _summarySource(summary.sourceType)
          : AdvancedAnalysisMetricSource.localRunSummary,
      confidence: AdvancedAnalysisMetricConfidence.derived,
    );
  }

  int? _targetZonePercent(AdvancedAnalysisHeartRateAnalysis heartRateAnalysis) {
    final zones = heartRateAnalysis.zones.value;
    if (zones == null || zones.isEmpty) {
      return null;
    }
    return zones
        .where((zone) => zone.isTarget)
        .fold<int>(0, (total, zone) => total + zone.percent);
  }

  AdvancedAnalysisMetric<String> _sourceAwareSummaryMetric(
    String valueLabel,
    RunSummarySnapshot summary,
  ) {
    if (!_hasDisplayValue(valueLabel)) {
      return const AdvancedAnalysisMetric<String>.unavailable(
        reason: AdvancedAnalysisMetricReason.missingSummaryField,
      );
    }
    if (summary.sourceType == RunSourceType.demoImport) {
      return AdvancedAnalysisMetric<String>.demoOnly(valueLabel);
    }
    return AdvancedAnalysisMetric<String>.available(
      value: valueLabel,
      valueLabel: valueLabel,
      source: _summarySource(summary.sourceType),
      confidence: _summaryConfidence(summary.sourceType),
    );
  }

  AdvancedAnalysisMetricSource _summarySource(RunSourceType sourceType) {
    return switch (sourceType) {
      RunSourceType.runiacGps => AdvancedAnalysisMetricSource.localRunSummary,
      RunSourceType.appleHealth =>
        AdvancedAnalysisMetricSource.healthKitAppleWatch,
      RunSourceType.healthConnect => AdvancedAnalysisMetricSource.healthConnect,
      RunSourceType.garminViaHealth =>
        AdvancedAnalysisMetricSource.garminWearable,
      RunSourceType.demoImport => AdvancedAnalysisMetricSource.staticDemo,
    };
  }

  AdvancedAnalysisMetricConfidence _summaryConfidence(
    RunSourceType sourceType,
  ) {
    return switch (sourceType) {
      RunSourceType.runiacGps => AdvancedAnalysisMetricConfidence.trusted,
      RunSourceType.appleHealth ||
      RunSourceType.healthConnect ||
      RunSourceType.garminViaHealth => AdvancedAnalysisMetricConfidence.derived,
      RunSourceType.demoImport => AdvancedAnalysisMetricConfidence.demo,
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

  double? _distanceKm(String label) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(label.trim());
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!);
  }
}
