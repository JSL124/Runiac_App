class PaceGraphSnapshot {
  const PaceGraphSnapshot({
    required this.isAvailable,
    required this.points,
    required this.yAxisLabels,
    required this.xAxisLabels,
    this.unavailableReason,
    this.totalDurationSeconds,
    this.averagePaceSecondsPerKm,
    this.bestPacePoint,
    this.slowestPacePoint,
    this.paceRangeMinSecondsPerKm,
    this.paceRangeMaxSecondsPerKm,
  });

  const PaceGraphSnapshot.unavailable({
    this.unavailableReason = 'insufficient_pace_graph_data',
  }) : isAvailable = false,
       points = const [],
       yAxisLabels = const [],
       xAxisLabels = const [],
       totalDurationSeconds = null,
       averagePaceSecondsPerKm = null,
       bestPacePoint = null,
       slowestPacePoint = null,
       paceRangeMinSecondsPerKm = null,
       paceRangeMaxSecondsPerKm = null;

  final bool isAvailable;
  final List<PaceGraphPoint> points;
  final List<String> yAxisLabels;
  final List<String> xAxisLabels;
  final String? unavailableReason;
  final int? totalDurationSeconds;
  final int? averagePaceSecondsPerKm;
  final PaceGraphPoint? bestPacePoint;
  final PaceGraphPoint? slowestPacePoint;
  final int? paceRangeMinSecondsPerKm;
  final int? paceRangeMaxSecondsPerKm;
}

class PaceGraphPoint {
  const PaceGraphPoint({
    required this.elapsedSeconds,
    required this.progressFraction,
    required this.paceSecondsPerKm,
    this.displayLabel,
  });

  final int elapsedSeconds;
  final double progressFraction;
  final int paceSecondsPerKm;
  final String? displayLabel;
}
