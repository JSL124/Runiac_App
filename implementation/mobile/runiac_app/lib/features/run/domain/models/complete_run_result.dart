import 'progression_display_model.dart';
import 'run_summary_snapshot.dart';
import 'xp_update_display_model.dart';

/// Future backend-produced display result for a completed run.
///
/// This presentation-only shape must not calculate rewards, decide progression
/// eligibility, or perform backend, network, or storage actions.
class CompleteRunResult {
  const CompleteRunResult({
    this.clientRunSessionId,
    this.activityId = 'static-latest-run-activity',
    this.summaryId = 'static-latest-run-summary',
    this.progressionEventId = 'static-latest-progression-event',
    this.validationStatus = 'validated',
    required this.summary,
    this.progressionDisplay = const ProgressionDisplayModel(
      xpDelta: 0,
      countsTowardLeaderboard: false,
      status: 'deferred',
      reason: 'progression_formula_deferred',
    ),
    required this.xpUpdate,
    this.message = 'Static completion result.',
  });

  final String? clientRunSessionId;
  final String activityId;
  final String summaryId;
  final String progressionEventId;
  final String validationStatus;
  final RunSummarySnapshot summary;
  final ProgressionDisplayModel progressionDisplay;
  final XpUpdateDisplayModel xpUpdate;
  final String message;

  CompleteRunResult copyWith({
    String? clientRunSessionId,
    RunSummarySnapshot? summary,
  }) {
    return CompleteRunResult(
      clientRunSessionId: clientRunSessionId ?? this.clientRunSessionId,
      activityId: activityId,
      summaryId: summaryId,
      progressionEventId: progressionEventId,
      validationStatus: validationStatus,
      summary: summary ?? this.summary,
      progressionDisplay: progressionDisplay,
      xpUpdate: xpUpdate,
      message: message,
    );
  }
}
