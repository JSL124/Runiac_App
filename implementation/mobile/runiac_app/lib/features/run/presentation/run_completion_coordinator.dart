import 'package:flutter/foundation.dart';

import '../../you/presentation/current_session_activity_history.dart';
import '../data/static_run_repository.dart';
import '../domain/models/complete_run_result.dart';
import '../domain/models/local_run_completion_payload.dart';
import '../domain/repositories/run_repository.dart';
import '../domain/services/run_summary_local_analysis_merger.dart';

class RunCompletionCoordinator {
  const RunCompletionCoordinator();

  Future<CompleteRunResult> complete({
    required RunRepository repository,
    required LocalRunCompletionPayload payload,
    CurrentSessionActivityHistoryStore? activityHistoryStore,
  }) async {
    final localResult = _mergeLocalAnalysis(
      await const StaticRunRepository().completeRun(payload),
      payload,
    );
    if (!localResult.summary.hasSufficientData) {
      return localResult;
    }
    final store = activityHistoryStore;
    RunCompletionContext? completionContext;
    if (store != null) {
      try {
        completionContext = store.captureRunCompletionContext();
      } catch (error, stackTrace) {
        _report(error, stackTrace, 'capturing run completion owner');
      }
    }
    final shouldSaveLocally = store != null && completionContext != null;
    var didSaveLocally = false;

    if (shouldSaveLocally) {
      try {
        await store.saveCompletedRun(localResult, payload: payload);
        didSaveLocally = true;
      } catch (error, stackTrace) {
        _report(error, stackTrace, 'saving a completed run locally');
      }
    }

    try {
      final remoteResult = _mergeLocalAnalysis(
        await repository.completeRun(payload),
        payload,
      );
      if (store != null &&
          completionContext != null &&
          !store.isRunCompletionContextCurrent(completionContext)) {
        return localResult;
      }
      if (didSaveLocally) {
        try {
          final acceptedResult = await store!.acceptForegroundCompletion(
            remoteResult,
            payload: payload,
            completionContext: completionContext!,
          );
          return acceptedResult ?? localResult;
        } catch (error, stackTrace) {
          _report(error, stackTrace, 'saving a completed run result');
        }
      }
      return remoteResult;
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'completing a run');
      if (didSaveLocally &&
          store != null &&
          completionContext != null &&
          store.isRunCompletionContextCurrent(completionContext)) {
        try {
          await store.recordForegroundRunSyncFailure(
            payload: payload,
            completionContext: completionContext,
            error: error,
          );
        } catch (persistenceError, persistenceStackTrace) {
          _report(
            persistenceError,
            persistenceStackTrace,
            'recording a run completion sync failure',
          );
        }
      }
      return localResult;
    }
  }

  CompleteRunResult _mergeLocalAnalysis(
    CompleteRunResult result,
    LocalRunCompletionPayload payload,
  ) {
    return result.copyWith(
      clientRunSessionId: payload.clientRunSessionId,
      summary: const RunSummaryLocalAnalysisMerger().merge(
        backendSummary: result.summary,
        localPayload: payload,
        localRoute: payload.routeSnapshot,
        resultClientRunSessionId: payload.clientRunSessionId,
      ),
    );
  }

  void _report(Object error, StackTrace stackTrace, String operation) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'runiac run tracking',
        context: ErrorDescription(operation),
      ),
    );
  }
}
