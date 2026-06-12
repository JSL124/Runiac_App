const runLaunchDemoSnapshot = RunLaunchDemoSnapshot(
  planLabel: 'TODAY\'S PLAN',
  switchRouteLabel: 'Switch route',
  distanceValue: '4.5',
  distanceUnitLabel: 'km easy run',
  paceLabel: 'Pace 7:10-7:40 / km · ~32 min',
  startLabel: 'Start run',
);

const runLiveDemoSnapshot = RunLiveDemoSnapshot(
  progressSummaryLabel: '4.10 of 4.50 km',
  progressPercentLabel: '91%',
  progressValue: 0.91,
  distanceLabel: 'DISTANCE',
  distanceValue: '4.10',
  distanceUnitLabel: 'km',
  timeLabel: 'TIME',
  timeValue: '30:10',
  avgPaceLabel: 'AVG PACE',
  avgPaceValue: '6:30/km',
);

class RunLaunchDemoSnapshot {
  const RunLaunchDemoSnapshot({
    required this.planLabel,
    required this.switchRouteLabel,
    required this.distanceValue,
    required this.distanceUnitLabel,
    required this.paceLabel,
    required this.startLabel,
  });

  final String planLabel;
  final String switchRouteLabel;
  final String distanceValue;
  final String distanceUnitLabel;
  final String paceLabel;
  final String startLabel;
}

class RunLiveDemoSnapshot {
  const RunLiveDemoSnapshot({
    required this.progressSummaryLabel,
    required this.progressPercentLabel,
    required this.progressValue,
    required this.distanceLabel,
    required this.distanceValue,
    required this.distanceUnitLabel,
    required this.timeLabel,
    required this.timeValue,
    required this.avgPaceLabel,
    required this.avgPaceValue,
  });

  final String progressSummaryLabel;
  final String progressPercentLabel;
  final double progressValue;
  final String distanceLabel;
  final String distanceValue;
  final String distanceUnitLabel;
  final String timeLabel;
  final String timeValue;
  final String avgPaceLabel;
  final String avgPaceValue;
}
