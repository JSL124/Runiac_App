class PaceGraphSnapshot {
  const PaceGraphSnapshot({
    required this.isAvailable,
    required this.points,
    required this.yAxisLabels,
    required this.xAxisLabels,
    this.unavailableReason,
  });

  const PaceGraphSnapshot.unavailable({
    this.unavailableReason = 'insufficient_pace_graph_data',
  }) : isAvailable = false,
       points = const [],
       yAxisLabels = const [],
       xAxisLabels = const [];

  final bool isAvailable;
  final List<PaceGraphPoint> points;
  final List<String> yAxisLabels;
  final List<String> xAxisLabels;
  final String? unavailableReason;
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
