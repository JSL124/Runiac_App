import 'cadence_graph_snapshot.dart';
import 'pace_graph_snapshot.dart';

enum AdvancedAnalysisMetricAvailability {
  available,
  unavailable,
  estimated,
  demoOnly,
  pendingSource,
}

enum AdvancedAnalysisMetricSource {
  localRunSummary,
  localGpsDerived,
  phoneSensorEstimated,
  healthKitAppleWatch,
  healthConnect,
  garminWearable,
  backendDerived,
  staticDemo,
  unavailable,
}

enum AdvancedAnalysisMetricConfidence {
  trusted,
  derived,
  estimated,
  demo,
  unavailable,
}

enum AdvancedAnalysisMetricReason {
  none,
  missingSummaryField,
  insufficientPaceSamples,
  missingHeartRateSource,
  missingHeartRateZonePolicy,
  missingCadenceSource,
  missingStrideSource,
  missingElevationSource,
  undefinedPerformanceFormula,
  undefinedRouteDifficultySource,
  estimatedFromPhoneSensors,
  demoFixtureOnly,
  pendingBackendAnalysis,
}

class AdvancedAnalysisMetric<T> {
  const AdvancedAnalysisMetric({
    required this.availability,
    required this.source,
    required this.confidence,
    this.value,
    this.valueLabel,
    this.reason = AdvancedAnalysisMetricReason.none,
  });

  const AdvancedAnalysisMetric.available({
    required this.source,
    required this.confidence,
    this.value,
    this.valueLabel,
  }) : availability = AdvancedAnalysisMetricAvailability.available,
       reason = AdvancedAnalysisMetricReason.none;

  const AdvancedAnalysisMetric.unavailable({
    this.reason = AdvancedAnalysisMetricReason.pendingBackendAnalysis,
  }) : availability = AdvancedAnalysisMetricAvailability.unavailable,
       source = AdvancedAnalysisMetricSource.unavailable,
       confidence = AdvancedAnalysisMetricConfidence.unavailable,
       value = null,
       valueLabel = null;

  const AdvancedAnalysisMetric.estimated({
    required this.valueLabel,
    required this.source,
    this.reason = AdvancedAnalysisMetricReason.estimatedFromPhoneSensors,
  }) : availability = AdvancedAnalysisMetricAvailability.estimated,
       confidence = AdvancedAnalysisMetricConfidence.estimated,
       value = null;

  const AdvancedAnalysisMetric.demoOnly(this.valueLabel)
    : availability = AdvancedAnalysisMetricAvailability.demoOnly,
      source = AdvancedAnalysisMetricSource.staticDemo,
      confidence = AdvancedAnalysisMetricConfidence.demo,
      value = null,
      reason = AdvancedAnalysisMetricReason.demoFixtureOnly;

  final AdvancedAnalysisMetricAvailability availability;
  final AdvancedAnalysisMetricSource source;
  final AdvancedAnalysisMetricConfidence confidence;
  final T? value;
  final String? valueLabel;
  final AdvancedAnalysisMetricReason reason;

  bool get isAvailable {
    return availability == AdvancedAnalysisMetricAvailability.available ||
        availability == AdvancedAnalysisMetricAvailability.estimated;
  }

  bool get isTrustedProduction {
    return availability == AdvancedAnalysisMetricAvailability.available &&
        confidence == AdvancedAnalysisMetricConfidence.trusted &&
        source != AdvancedAnalysisMetricSource.staticDemo &&
        source != AdvancedAnalysisMetricSource.unavailable;
  }
}

class AdvancedAnalysisSnapshot {
  const AdvancedAnalysisSnapshot({
    required this.performance,
    required this.pace,
    required this.heartRate,
    required this.elevation,
    required this.formCadence,
  });

  final AdvancedAnalysisPerformanceOverview performance;
  final AdvancedAnalysisPaceAnalysis pace;
  final AdvancedAnalysisHeartRateAnalysis heartRate;
  final AdvancedAnalysisElevationAnalysis elevation;
  final AdvancedAnalysisFormCadenceAnalysis formCadence;
}

class AdvancedAnalysisPerformanceOverview {
  const AdvancedAnalysisPerformanceOverview({
    required this.score,
    required this.duration,
    required this.distance,
  });

  final AdvancedAnalysisMetric<int> score;
  final AdvancedAnalysisMetric<String> duration;
  final AdvancedAnalysisMetric<String> distance;
}

class AdvancedAnalysisPaceAnalysis {
  const AdvancedAnalysisPaceAnalysis({
    required this.averagePace,
    required this.fastestPace,
    required this.slowestPace,
    required this.paceStability,
    required this.paceGraph,
    required this.splits,
  });

  final AdvancedAnalysisMetric<String> averagePace;
  final AdvancedAnalysisMetric<String> fastestPace;
  final AdvancedAnalysisMetric<String> slowestPace;
  final AdvancedAnalysisMetric<String> paceStability;
  final AdvancedAnalysisMetric<PaceGraphSnapshot> paceGraph;
  final AdvancedAnalysisMetric<List<AdvancedAnalysisSplitSnapshot>> splits;
}

class AdvancedAnalysisSplitSnapshot {
  const AdvancedAnalysisSplitSnapshot({
    required this.distanceLabel,
    required this.paceLabel,
    required this.paceSecondsPerKm,
    required this.isPartial,
    this.elevationLabel = '--',
    this.heartRateLabel = '--',
    this.barScalePaceSecondsPerKm,
  });

  final String distanceLabel;
  final String paceLabel;
  final int paceSecondsPerKm;
  final bool isPartial;
  final String elevationLabel;
  final String heartRateLabel;
  final int? barScalePaceSecondsPerKm;
}

class AdvancedAnalysisHeartRateAnalysis {
  const AdvancedAnalysisHeartRateAnalysis({
    required this.averageHeartRate,
    required this.maxHeartRate,
    required this.targetZone,
    required this.timeInZone,
    required this.zones,
  });

  final AdvancedAnalysisMetric<String> averageHeartRate;
  final AdvancedAnalysisMetric<String> maxHeartRate;
  final AdvancedAnalysisMetric<String> targetZone;
  final AdvancedAnalysisMetric<String> timeInZone;
  final AdvancedAnalysisMetric<List<String>> zones;
}

class AdvancedAnalysisElevationAnalysis {
  const AdvancedAnalysisElevationAnalysis({
    required this.totalGain,
    required this.highestPoint,
    required this.lowestPoint,
    required this.routeDifficulty,
    required this.elevationGraph,
  });

  final AdvancedAnalysisMetric<String> totalGain;
  final AdvancedAnalysisMetric<String> highestPoint;
  final AdvancedAnalysisMetric<String> lowestPoint;
  final AdvancedAnalysisMetric<String> routeDifficulty;
  final AdvancedAnalysisMetric<List<String>> elevationGraph;
}

class AdvancedAnalysisFormCadenceAnalysis {
  const AdvancedAnalysisFormCadenceAnalysis({
    required this.averageCadence,
    required this.targetRange,
    required this.strideConsistency,
    required this.cadenceStatus,
    required this.strideLength,
    required this.cadenceGraph,
  });

  final AdvancedAnalysisMetric<String> averageCadence;
  final AdvancedAnalysisMetric<String> targetRange;
  final AdvancedAnalysisMetric<String> strideConsistency;
  final AdvancedAnalysisMetric<String> cadenceStatus;
  final AdvancedAnalysisMetric<String> strideLength;
  final AdvancedAnalysisMetric<CadenceGraphSnapshot> cadenceGraph;
}
