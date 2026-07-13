import 'progression_display_model.dart';
import 'run_summary_snapshot.dart';
import 'xp_update_display_model.dart';

class PlanCompletionResult {
  const PlanCompletionResult({
    this.completed = false,
    this.planEnrollmentId,
    this.scheduledWorkoutId,
  });

  final bool completed;
  final String? planEnrollmentId;
  final String? scheduledWorkoutId;
}

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
    this.planCompletion = const PlanCompletionResult(),
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
  final PlanCompletionResult planCompletion;
  final XpUpdateDisplayModel xpUpdate;
  final String message;

  CompleteRunResult copyWith({
    String? clientRunSessionId,
    String? activityId,
    String? summaryId,
    String? progressionEventId,
    String? validationStatus,
    RunSummarySnapshot? summary,
    ProgressionDisplayModel? progressionDisplay,
    PlanCompletionResult? planCompletion,
    XpUpdateDisplayModel? xpUpdate,
    String? message,
  }) {
    return CompleteRunResult(
      clientRunSessionId: clientRunSessionId ?? this.clientRunSessionId,
      activityId: activityId ?? this.activityId,
      summaryId: summaryId ?? this.summaryId,
      progressionEventId: progressionEventId ?? this.progressionEventId,
      validationStatus: validationStatus ?? this.validationStatus,
      summary: summary ?? this.summary,
      progressionDisplay: progressionDisplay ?? this.progressionDisplay,
      planCompletion: planCompletion ?? this.planCompletion,
      xpUpdate: xpUpdate ?? this.xpUpdate,
      message: message ?? this.message,
    );
  }
}
