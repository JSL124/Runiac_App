import 'run_activity_display_model.dart';
import 'run_summary_snapshot.dart';

const recentRunningDisplayData = [
  RunActivityDisplayModel(
    timeAgoLabel: '4/11/26',
    title: 'Saturday Night Run',
    distanceLabel: '4.03 km',
    paceLabel: '6\'30"',
    durationLabel: '30:15',
    summary: RunSummarySnapshot(
      title: 'Saturday Night Run',
      dateLabel: '4/11/26',
      timeLabel: '9:18 PM',
      distanceKm: '4.03',
      avgPace: '6’30”',
      duration: '30:15',
      avgHeartRate: '145',
      calories: '145',
      routeName: 'East Coast Park Night Loop',
    ),
  ),
  RunActivityDisplayModel(
    timeAgoLabel: '4/11/26',
    title: 'Morning Easy Run',
    distanceLabel: '3.20 km',
    paceLabel: '7\'05"',
    durationLabel: '24:10',
    summary: RunSummarySnapshot(
      title: 'Morning Easy Run',
      dateLabel: '4/11/26',
      timeLabel: '6:45 AM',
      distanceKm: '3.20',
      avgPace: '7’05”',
      duration: '24:10',
      avgHeartRate: '138',
      calories: '212',
      routeName: 'Neighbourhood Easy Loop',
    ),
  ),
  RunActivityDisplayModel(
    timeAgoLabel: '4/11/26',
    title: 'Recovery Jog',
    distanceLabel: '5.17 km',
    paceLabel: '7\'40"',
    durationLabel: '39:38',
    summary: RunSummarySnapshot(
      title: 'Recovery Jog',
      dateLabel: '4/11/26',
      timeLabel: '8:10 PM',
      distanceKm: '5.17',
      avgPace: '7’40”',
      duration: '39:38',
      avgHeartRate: '132',
      calories: '286',
      routeName: 'Park Connector Recovery Loop',
    ),
  ),
];
