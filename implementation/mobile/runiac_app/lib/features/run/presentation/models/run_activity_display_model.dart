import 'run_summary_snapshot.dart';

class RunActivityDisplayModel {
  const RunActivityDisplayModel({
    required this.title,
    required this.timeAgoLabel,
    required this.distanceLabel,
    required this.paceLabel,
    required this.durationLabel,
    required this.summary,
  });

  final String title;
  final String timeAgoLabel;
  final String distanceLabel;
  final String paceLabel;
  final String durationLabel;
  final RunSummarySnapshot summary;
}
