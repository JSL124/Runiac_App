const defaultRunSummarySnapshot = RunSummarySnapshot(
  title: 'Saturday Morning Run',
  dateLabel: 'Today',
  timeLabel: '7:06 AM',
  distanceKm: '4.03',
  avgPace: '6’30”',
  duration: '30:15',
  avgHeartRate: '145',
  calories: '145',
  routeName: 'East Coast Park Loop',
);

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

  String get dateTimeLabel => '$dateLabel · $timeLabel';
}
