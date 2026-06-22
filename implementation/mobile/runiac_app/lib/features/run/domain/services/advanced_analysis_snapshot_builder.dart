import '../models/advanced_analysis_snapshot.dart';
import '../models/pace_graph_snapshot.dart';
import '../models/run_source_display.dart';
import '../models/run_summary_snapshot.dart';
import 'pace_analysis_deriver.dart';

class AdvancedAnalysisSnapshotBuilder {
  const AdvancedAnalysisSnapshotBuilder();

  AdvancedAnalysisSnapshot fromRunSummary(RunSummarySnapshot summary) {
    final paceAnalysis = _derivePaceAnalysis(summary);
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
        fastestPace: _derivedPaceMetric(paceAnalysis?.fastestPaceSecondsPerKm),
        slowestPace: _derivedPaceMetric(paceAnalysis?.slowestPaceSecondsPerKm),
        paceStability: _derivedStabilityMetric(
          paceAnalysis?.paceStabilityScore,
        ),
        paceGraph: _paceGraphMetric(summary),
        splits: _splitMetric(summary),
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

  PaceAnalysisDerivation? _derivePaceAnalysis(RunSummarySnapshot summary) {
    if (summary.sourceType != RunSourceType.runiacGps) {
      return null;
    }
    final series = summary.paceAnalysisSeries;
    if (series == null) {
      return null;
    }
    final derivation = const PaceAnalysisDeriver().derive(series);
    return derivation.isAvailable ? derivation : null;
  }

  AdvancedAnalysisMetric<String> _derivedPaceMetric(int? secondsPerKm) {
    if (secondsPerKm == null) {
      return const AdvancedAnalysisMetric<String>.unavailable(
        reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
      );
    }
    final valueLabel = _formatDuration(secondsPerKm);
    return AdvancedAnalysisMetric<String>.available(
      value: valueLabel,
      valueLabel: valueLabel,
      source: AdvancedAnalysisMetricSource.localGpsDerived,
      confidence: AdvancedAnalysisMetricConfidence.derived,
    );
  }

  AdvancedAnalysisMetric<String> _derivedStabilityMetric(int? stabilityScore) {
    if (stabilityScore == null) {
      return const AdvancedAnalysisMetric<String>.unavailable(
        reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
      );
    }
    final valueLabel = stabilityScore.toString();
    return AdvancedAnalysisMetric<String>.available(
      value: valueLabel,
      valueLabel: valueLabel,
      source: AdvancedAnalysisMetricSource.localGpsDerived,
      confidence: AdvancedAnalysisMetricConfidence.derived,
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
      source: _paceSource(summary),
      confidence: AdvancedAnalysisMetricConfidence.derived,
    );
  }

  AdvancedAnalysisMetric<List<AdvancedAnalysisSplitSnapshot>> _splitMetric(
    RunSummarySnapshot summary,
  ) {
    final splits = _deriveSplits(summary);
    if (splits.isEmpty) {
      return const AdvancedAnalysisMetric<
        List<AdvancedAnalysisSplitSnapshot>
      >.unavailable(
        reason: AdvancedAnalysisMetricReason.insufficientPaceSamples,
      );
    }
    if (summary.sourceType == RunSourceType.demoImport) {
      return AdvancedAnalysisMetric<List<AdvancedAnalysisSplitSnapshot>>(
        availability: AdvancedAnalysisMetricAvailability.demoOnly,
        source: AdvancedAnalysisMetricSource.staticDemo,
        confidence: AdvancedAnalysisMetricConfidence.demo,
        value: splits,
        reason: AdvancedAnalysisMetricReason.demoFixtureOnly,
      );
    }
    return AdvancedAnalysisMetric<
      List<AdvancedAnalysisSplitSnapshot>
    >.available(
      value: splits,
      source: _paceSource(summary),
      confidence: AdvancedAnalysisMetricConfidence.derived,
    );
  }

  AdvancedAnalysisMetricSource _paceSource(RunSummarySnapshot summary) {
    return switch (summary.sourceType) {
      RunSourceType.runiacGps => AdvancedAnalysisMetricSource.localGpsDerived,
      RunSourceType.appleHealth =>
        AdvancedAnalysisMetricSource.healthKitAppleWatch,
      RunSourceType.healthConnect => AdvancedAnalysisMetricSource.healthConnect,
      RunSourceType.garminViaHealth =>
        AdvancedAnalysisMetricSource.garminWearable,
      RunSourceType.demoImport => AdvancedAnalysisMetricSource.staticDemo,
    };
  }

  List<AdvancedAnalysisSplitSnapshot> _deriveSplits(
    RunSummarySnapshot summary,
  ) {
    final graph = summary.paceGraph;
    final totalDurationSeconds = graph.totalDurationSeconds;
    final totalDistanceKm = _distanceKm(summary.distanceKm);
    if (!graph.isAvailable ||
        !graph.hasDistanceAxis ||
        totalDurationSeconds == null ||
        totalDistanceKm == null ||
        totalDistanceKm <= 0) {
      return const [];
    }

    final anchors = _splitAnchors(
      graph: graph,
      totalDistanceKm: totalDistanceKm,
      totalDurationSeconds: totalDurationSeconds,
    );
    if (anchors.length < 2 || !_isMonotonicDistance(anchors)) {
      return const [];
    }

    final splits = <AdvancedAnalysisSplitSnapshot>[];
    var previousDistanceKm = 0.0;
    var previousElapsedSeconds = 0;
    final fullKilometres = totalDistanceKm.floor();

    for (var kilometre = 1; kilometre <= fullKilometres; kilometre += 1) {
      final elapsedSeconds = _elapsedAtDistance(anchors, kilometre.toDouble());
      if (elapsedSeconds == null || elapsedSeconds <= previousElapsedSeconds) {
        return const [];
      }
      final segmentSeconds = elapsedSeconds - previousElapsedSeconds;
      splits.add(
        AdvancedAnalysisSplitSnapshot(
          distanceLabel: '$kilometre km',
          paceLabel: _formatDuration(segmentSeconds),
          paceSecondsPerKm: segmentSeconds,
          isPartial: false,
        ),
      );
      previousDistanceKm = kilometre.toDouble();
      previousElapsedSeconds = elapsedSeconds;
    }

    final remainingDistanceKm = totalDistanceKm - previousDistanceKm;
    if (remainingDistanceKm >= 0.01) {
      final segmentSeconds = totalDurationSeconds - previousElapsedSeconds;
      if (segmentSeconds <= 0) {
        return const [];
      }
      splits.add(
        AdvancedAnalysisSplitSnapshot(
          distanceLabel: '${remainingDistanceKm.toStringAsFixed(2)} km',
          paceLabel: _formatDuration(segmentSeconds),
          paceSecondsPerKm: segmentSeconds,
          isPartial: true,
        ),
      );
    }

    return splits;
  }

  List<_SplitAnchor> _splitAnchors({
    required PaceGraphSnapshot graph,
    required double totalDistanceKm,
    required int totalDurationSeconds,
  }) {
    final anchors = <_SplitAnchor>[
      const _SplitAnchor(distanceKm: 0, elapsedSeconds: 0),
    ];

    for (final point in graph.points) {
      final distanceProgress = point.distanceProgressFraction;
      if (distanceProgress == null ||
          distanceProgress < 0 ||
          distanceProgress > 1 ||
          point.elapsedSeconds < 0 ||
          point.elapsedSeconds > totalDurationSeconds) {
        continue;
      }
      anchors.add(
        _SplitAnchor(
          distanceKm: distanceProgress * totalDistanceKm,
          elapsedSeconds: point.elapsedSeconds,
        ),
      );
    }

    anchors.add(
      _SplitAnchor(
        distanceKm: totalDistanceKm,
        elapsedSeconds: totalDurationSeconds,
      ),
    );
    anchors.sort((a, b) {
      final distanceOrder = a.distanceKm.compareTo(b.distanceKm);
      if (distanceOrder != 0) {
        return distanceOrder;
      }
      return a.elapsedSeconds.compareTo(b.elapsedSeconds);
    });
    return anchors;
  }

  bool _isMonotonicDistance(List<_SplitAnchor> anchors) {
    var lastDistanceKm = -1.0;
    var lastElapsedSeconds = -1;
    for (final anchor in anchors) {
      if (anchor.distanceKm < lastDistanceKm ||
          anchor.elapsedSeconds < lastElapsedSeconds) {
        return false;
      }
      lastDistanceKm = anchor.distanceKm;
      lastElapsedSeconds = anchor.elapsedSeconds;
    }
    return true;
  }

  int? _elapsedAtDistance(List<_SplitAnchor> anchors, double distanceKm) {
    for (var index = 1; index < anchors.length; index += 1) {
      final before = anchors[index - 1];
      final after = anchors[index];
      if (distanceKm < before.distanceKm || distanceKm > after.distanceKm) {
        continue;
      }
      final distanceDelta = after.distanceKm - before.distanceKm;
      if (distanceDelta <= 0) {
        return after.elapsedSeconds;
      }
      final ratio = (distanceKm - before.distanceKm) / distanceDelta;
      return (before.elapsedSeconds +
              ratio * (after.elapsedSeconds - before.elapsedSeconds))
          .round();
    }
    return null;
  }

  double? _distanceKm(String label) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(label.trim());
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes’${remainingSeconds.toString().padLeft(2, '0')}”';
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

class _SplitAnchor {
  const _SplitAnchor({required this.distanceKm, required this.elapsedSeconds});

  final double distanceKm;
  final int elapsedSeconds;
}
