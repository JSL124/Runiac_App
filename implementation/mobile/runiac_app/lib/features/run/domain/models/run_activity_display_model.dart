import 'complete_run_result.dart';
import 'run_summary_snapshot.dart';

/// Display-only activity row model backed by future run history read models.
class RunActivityDisplayModel {
  const RunActivityDisplayModel({
    this.activityId,
    this.clientRunSessionId,
    required this.title,
    required this.timeAgoLabel,
    required this.distanceLabel,
    required this.distanceMeters,
    required this.paceLabel,
    required this.durationLabel,
    required this.summary,
    this.completionResult,
  });

  final String? activityId;
  final String? clientRunSessionId;
  final String title;
  final String timeAgoLabel;
  final String distanceLabel;
  final int distanceMeters;
  final String paceLabel;
  final String durationLabel;
  final RunSummarySnapshot summary;
  final CompleteRunResult? completionResult;

  String get sourceLabel => summary.sourceLabel;
  String get identityKey => clientRunSessionId ?? activityId ?? title;
}
