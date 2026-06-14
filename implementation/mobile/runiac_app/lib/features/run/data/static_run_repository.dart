import '../domain/models/complete_run_result.dart';
import '../domain/models/local_run_completion_payload.dart';
import '../domain/models/progression_display_model.dart';
import '../domain/models/run_completion_request_adapter.dart';
import '../domain/models/run_activity_read_model.dart';
import '../domain/models/run_summary_read_model.dart';
import '../domain/models/run_summary_snapshot.dart';
import '../domain/models/xp_update_display_model.dart';
import '../domain/repositories/run_repository.dart';
import '../presentation/data/run_completion_demo_snapshots.dart';

class StaticRunRepository implements RunRepository {
  const StaticRunRepository();

  @override
  Future<RunSummaryReadModel> loadLatestRunSummary() async {
    const snapshot = defaultRunSummarySnapshot;

    return RunSummaryReadModel(
      summaryId: 'static-latest-run-summary',
      title: snapshot.title,
      dateLabel: snapshot.dateLabel,
      timeLabel: snapshot.timeLabel,
      distanceLabel: '${snapshot.distanceKm} km',
      avgPaceLabel: snapshot.avgPace,
      durationLabel: snapshot.duration,
      avgHeartRateLabel: snapshot.avgHeartRate,
      caloriesLabel: snapshot.calories,
      routeName: snapshot.routeName,
    );
  }

  @override
  Future<CompleteRunResult> loadLatestCompletionResult() async {
    return const CompleteRunResult(
      summary: defaultRunSummarySnapshot,
      xpUpdate: defaultXpUpdateDisplayModel,
    );
  }

  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    RunCompletionRequestAdapter.toBackendRequest(payload);

    final sessionId = payload.clientRunSessionId;
    final hasDisplayableRunMetrics =
        payload.durationSeconds > 0 &&
        payload.distanceMeters > 0 &&
        payload.avgPaceSecondsPerKm > 0;
    final summary = hasDisplayableRunMetrics
        ? RunSummarySnapshot(
            title: payload.routeLabel ?? 'Completed Run',
            dateLabel: _formatDate(payload.completedAt),
            timeLabel: _formatTime(payload.completedAt),
            distanceKm: _formatDistanceKm(payload.distanceMeters),
            avgPace: _formatPace(payload.avgPaceSecondsPerKm),
            duration: _formatDuration(payload.durationSeconds),
            avgHeartRate: '--',
            calories: '--',
            routeName: payload.routeLabel ?? 'Private route',
          )
        : defaultRunSummarySnapshot;

    return CompleteRunResult(
      activityId: 'static-$sessionId',
      summaryId: 'static-summary-$sessionId',
      progressionEventId: 'static-progression-$sessionId',
      validationStatus: 'validated',
      summary: summary,
      progressionDisplay: const ProgressionDisplayModel(
        xpDelta: 0,
        countsTowardLeaderboard: false,
        status: 'deferred',
        reason: 'progression_formula_deferred',
      ),
      xpUpdate: hasDisplayableRunMetrics
          ? const XpUpdateDisplayModel(
              runnerName: 'Runiac Runner',
              earnedXpLabel: '+0 XP',
              totalXpLabel: 'Deferred by backend',
              levelLabel: 'Pending',
              nextLevelLabel: 'Pending',
              progressTargetLabel: 'Progression deferred',
              xpRemainingLabel: 'Backend formula pending',
              previousProgressFraction: 0,
              currentProgressFraction: 0,
              streakChangeLabel: 'Deferred',
              streakNote: 'Backend validation accepted the run.',
              didLevelUp: false,
            )
          : defaultXpUpdateDisplayModel,
      message: 'Static repository completion accepted.',
    );
  }

  @override
  Future<RunActivityReadModel> loadLatestRunActivity() async {
    const snapshot = defaultRunSummarySnapshot;

    return RunActivityReadModel(
      activityId: 'static-latest-run-activity',
      title: snapshot.title,
      completedAtLabel: snapshot.dateLabel,
      distanceLabel: '${snapshot.distanceKm} km',
      durationLabel: snapshot.duration,
      avgPaceLabel: snapshot.avgPace,
      routeLabel: snapshot.routeName,
    );
  }

  String _formatDistanceKm(int distanceMeters) {
    return (distanceMeters / 1000).toStringAsFixed(2);
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatPace(int paceSecondsPerKm) {
    final minutes = paceSecondsPerKm ~/ 60;
    final seconds = paceSecondsPerKm % 60;
    return '$minutes’${seconds.toString().padLeft(2, '0')}”';
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().substring(2);
    return '${local.day}/${local.month}/$year';
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
