import 'coaching_summary_snapshot.dart';
import 'pace_graph_snapshot.dart';
import 'run_route_snapshot.dart';
import 'run_source_display.dart';

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
    this.route = RunRouteSnapshot.empty,
    this.sourceType = RunSourceType.runiacGps,
    this.heartRateAvailability = HeartRateAvailability.unavailableNoSensor,
    this.coachingSummary = const CoachingSummarySnapshot(
      source: CoachingSummarySource.ruleBased,
      headline: 'Good work finishing this run',
      message: 'This summary uses the run data available on this device.',
      nextAction: 'Keep your next run easy and comfortable.',
    ),
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
  final RunRouteSnapshot route;
  final RunSourceType sourceType;
  final HeartRateAvailability heartRateAvailability;
  final CoachingSummarySnapshot coachingSummary;

  String get dateTimeLabel => '$dateLabel · $timeLabel';
  String get sourceLabel => sourceType.label;
  String? get heartRateHelperText => heartRateAvailability.helperText;

  RunSummarySnapshot copyWith({
    PaceGraphSnapshot? paceGraph,
    RunRouteSnapshot? route,
    RunSourceType? sourceType,
    HeartRateAvailability? heartRateAvailability,
    CoachingSummarySnapshot? coachingSummary,
  }) {
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
      route: route ?? this.route,
      sourceType: sourceType ?? this.sourceType,
      heartRateAvailability:
          heartRateAvailability ?? this.heartRateAvailability,
      coachingSummary: coachingSummary ?? this.coachingSummary,
    );
  }
}
