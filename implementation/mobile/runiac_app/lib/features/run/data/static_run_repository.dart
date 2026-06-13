import '../domain/models/complete_run_result.dart';
import '../domain/models/run_activity_read_model.dart';
import '../domain/models/run_summary_read_model.dart';
import '../domain/repositories/run_repository.dart';
import '../presentation/data/run_completion_demo_snapshots.dart';

class StaticRunRepository implements RunRepository {
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
}
