import 'pace_graph_snapshot.dart';

class RunSummarySnapshot {
  const RunSummarySnapshot({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.distanceKm,
    required this.avgPace,
    required this.duration,
    required this.avgHeartRate,
    required this.calories,
    required this.routeName,
    this.hasSufficientData = true,
    this.paceGraph = const PaceGraphSnapshot.unavailable(),
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final String distanceKm;
  final String avgPace;
  final String duration;
  final String avgHeartRate;
  final String calories;
  final String routeName;
  final bool hasSufficientData;
  final PaceGraphSnapshot paceGraph;

  String get dateTimeLabel => '$dateLabel · $timeLabel';

  RunSummarySnapshot copyWith({PaceGraphSnapshot? paceGraph}) {
    return RunSummarySnapshot(
      title: title,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      distanceKm: distanceKm,
      avgPace: avgPace,
      duration: duration,
      avgHeartRate: avgHeartRate,
      calories: calories,
      routeName: routeName,
      hasSufficientData: hasSufficientData,
      paceGraph: paceGraph ?? this.paceGraph,
    );
  }
}
