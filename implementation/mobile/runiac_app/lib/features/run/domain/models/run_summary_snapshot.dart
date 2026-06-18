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

  String get dateTimeLabel => '$dateLabel · $timeLabel';
}
