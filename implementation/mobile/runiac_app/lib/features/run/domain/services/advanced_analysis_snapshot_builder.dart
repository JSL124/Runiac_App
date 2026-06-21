import '../models/advanced_analysis_snapshot.dart';
import '../models/pace_graph_snapshot.dart';
import '../models/run_source_display.dart';
import '../models/run_summary_snapshot.dart';

class AdvancedAnalysisSnapshotBuilder {
  const AdvancedAnalysisSnapshotBuilder();

  AdvancedAnalysisSnapshot fromRunSummary(RunSummarySnapshot summary) {
    return AdvancedAnalysisSnapshot(
      performance: AdvancedAnalysisPerformanceOverview(
        score: const AdvancedAnalysisMetric<int>.unavailable(
          reason: AdvancedAnalysisMetricReason.undefinedPerformanceFormula,
        ),
        duration: _trustedLocalSummaryMetric(summary.duration, summary),
        distance: _trustedLocalSummaryMetric(summary.distanceKm, summary),
      ),
      pace: AdvancedAnalysisPaceAnalysis(
        averagePace: _trustedLocalSummaryMetric(summary.avgPace, summary),
        fastestPace: const AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
        ),
        slowestPace: const AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
        ),
        paceStability: const AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
        ),
        paceGraph: _paceGraphMetric(summary),
        splits: const AdvancedAnalysisMetric<List<String>>.unavailable(
          reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
        ),
      ),
      heartRate: AdvancedAnalysisHeartRateAnalysis(
        averageHeartRate: _heartRateAverageMetric(summary),
        maxHeartRate: const AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingHeartRateSource,
        ),
        targetZone: const AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingHeartRateZonePolicy,
        ),
        timeInZone: const AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingHeartRateZonePolicy,
        ),
        zones: const AdvancedAnalysisMetric<List<String>>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingHeartRateZonePolicy,
        ),
      ),
      elevation: const AdvancedAnalysisElevationAnalysis(
        totalGain: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingElevationSource,
        ),
        highestPoint: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingElevationSource,
        ),
        lowestPoint: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingElevationSource,
        ),
        routeDifficulty: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.undefinedRouteDifficultySource,
        ),
        elevationGraph: AdvancedAnalysisMetric<List<String>>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingElevationSource,
        ),
      ),
      formCadence: const AdvancedAnalysisFormCadenceAnalysis(
        averageCadence: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingCadenceSource,
        ),
        targetRange: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingCadenceSource,
        ),
        strideConsistency: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingCadenceSource,
        ),
        cadenceStatus: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingCadenceSource,
        ),
        strideLength: AdvancedAnalysisMetric<String>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingStrideSource,
        ),
        cadenceGraph: AdvancedAnalysisMetric<List<String>>.unavailable(
          reason: AdvancedAnalysisMetricReason.missingCadenceSource,
        ),
      ),
    );
  }

  AdvancedAnalysisMetric<String> _trustedLocalSummaryMetric(
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
      source: AdvancedAnalysisMetricSource.localRunSummary,
      confidence: AdvancedAnalysisMetricConfidence.trusted,
    );
  }

  AdvancedAnalysisMetric<PaceGraphSnapshot> _paceGraphMetric(
    RunSummarySnapshot summary,
  ) {
    final graph = summary.paceGraph;
    if (!graph.isAvailable) {
      return const AdvancedAnalysisMetric<PaceGraphSnapshot>.unavailable(
        reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
      );
    }
    if (summary.sourceType == RunSourceType.demoImport) {
      return AdvancedAnalysisMetric<PaceGraphSnapshot>(
        availability: AdvancedAnalysisMetricAvailability.demoOnly,
        source: AdvancedAnalysisMetricSource.staticDemo,
        confidence: AdvancedAnalysisMetricConfidence.demo,
        value: graph,
        reason: AdvancedAnalysisMetricReason.demoFixtureOnly,
      );
    }
    return AdvancedAnalysisMetric<PaceGraphSnapshot>.available(
      value: graph,
      source: AdvancedAnalysisMetricSource.localGpsDerived,
      confidence: AdvancedAnalysisMetricConfidence.derived,
    );
  }

  AdvancedAnalysisMetric<String> _heartRateAverageMetric(
    RunSummarySnapshot summary,
  ) {
    if (!_hasTrustedHeartRateSource(summary) ||
        !_hasDisplayValue(summary.avgHeartRate)) {
      return const AdvancedAnalysisMetric<String>.unavailable(
        reason: AdvancedAnalysisMetricReason.missingHeartRateSource,
      );
    }
    return AdvancedAnalysisMetric<String>.available(
      value: summary.avgHeartRate,
      valueLabel: summary.avgHeartRate,
      source: _heartRateSource(summary.sourceType),
      confidence: AdvancedAnalysisMetricConfidence.derived,
    );
  }

  bool _hasTrustedHeartRateSource(RunSummarySnapshot summary) {
    if (!summary.heartRateAvailability.isAvailable) {
      return false;
    }
    return switch (summary.sourceType) {
      RunSourceType.appleHealth ||
      RunSourceType.healthConnect ||
      RunSourceType.garminViaHealth => true,
      RunSourceType.runiacGps || RunSourceType.demoImport => false,
    };
  }

  AdvancedAnalysisMetricSource _heartRateSource(RunSourceType sourceType) {
    return switch (sourceType) {
      RunSourceType.appleHealth =>
        AdvancedAnalysisMetricSource.healthKitAppleWatch,
      RunSourceType.healthConnect => AdvancedAnalysisMetricSource.healthConnect,
      RunSourceType.garminViaHealth =>
        AdvancedAnalysisMetricSource.garminWearable,
      RunSourceType.runiacGps ||
      RunSourceType.demoImport => AdvancedAnalysisMetricSource.unavailable,
    };
  }

  bool _hasDisplayValue(String valueLabel) {
    final normalized = valueLabel.trim();
    return normalized.isNotEmpty && normalized != '--';
  }
}
