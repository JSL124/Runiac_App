import '../models/complete_run_result.dart';
import '../models/local_run_completion_payload.dart';
import '../models/run_activity_read_model.dart';
import '../models/run_summary_read_model.dart';

abstract interface class RunRepository {
  Future<RunSummaryReadModel> loadLatestRunSummary();

  Future<CompleteRunResult> loadLatestCompletionResult();

  Future<RunActivityReadModel> loadLatestRunActivity();

  Future<CompleteRunResult> completeRun(LocalRunCompletionPayload payload);
}
