import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runiac_app/features/run/data/static_run_repository.dart';
import 'package:runiac_app/features/run/domain/models/cadence_analysis_series.dart';
import 'package:runiac_app/features/run/domain/models/complete_run_result.dart';
import 'package:runiac_app/features/run/domain/models/elevation_analysis_series.dart';
import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/pace_analysis_series.dart';
import 'package:runiac_app/features/run/domain/models/run_activity_display_model.dart';
import 'package:runiac_app/features/run/domain/models/run_activity_read_model.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_completion_error.dart';
import 'package:runiac_app/features/run/domain/models/run_route_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_read_model.dart';
import 'package:runiac_app/features/run/domain/models/xp_update_display_model.dart';
import 'package:runiac_app/features/run/domain/repositories/run_repository.dart';
import 'package:runiac_app/features/run/domain/services/pace_graph_data_builder.dart';
import 'package:runiac_app/features/you/data/local_pending_run_activity_store.dart';
import 'package:runiac_app/features/you/presentation/current_session_activity_history.dart';

void main() {
  const ownerUid = 'owner-1';
  const otherOwnerUid = 'owner-2';

  test('restores saved pending run after store recreation', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final firstStore = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(firstStore.dispose);

    await firstStore.saveCompletedRun(
      _completionResult('persisted-client-session'),
      payload: _payload('persisted-client-session'),
    );

    final restoredStore = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(restoredStore.dispose);
    await restoredStore.restoreSavedActivities();

    expect(restoredStore.activities.map((run) => run.activityId), [
      'local-persisted-client-session',
    ]);
  });

  test('restores saved pending run from shared preferences storage', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const storage = SharedPreferencesLocalPendingRunActivityStore(
      key: 'test.pendingRunActivities',
    );
    final firstStore = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(firstStore.dispose);

    await firstStore.saveCompletedRun(
      _completionResult('shared-prefs-client-session'),
      payload: _payload('shared-prefs-client-session'),
    );

    final restoredStore = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(restoredStore.dispose);
    await restoredStore.restoreSavedActivities();

    expect(restoredStore.activities.map((run) => run.activityId), [
      'local-shared-prefs-client-session',
    ]);
  });

  test(
    'restores saved pending run route snapshot after store recreation',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const storage = SharedPreferencesLocalPendingRunActivityStore(
        key: 'test.pendingRunActivitiesWithRoute',
      );
      final route = _routeSnapshot();
      final firstStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(firstStore.dispose);

      await firstStore.saveCompletedRun(
        _completionResult('route-client-session', route: route),
        payload: _payload('route-client-session'),
      );

      final restoredStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(restoredStore.dispose);
      await restoredStore.restoreSavedActivities();

      final restoredRoute =
          restoredStore.activities.single.display.summary.route;
      expect(restoredRoute.hasRoute, isTrue);
      expect(restoredRoute.segments.single, hasLength(3));
      expect(restoredRoute.lastKnownLocation?.latitude, 1.3033);
      expect(restoredRoute.lastKnownLocation?.longitude, 103.8333);
    },
  );

  test(
    'restores rich local run snapshot from shared preferences storage',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const storage = SharedPreferencesLocalPendingRunActivityStore(
        key: 'test.pendingRichRunSnapshot',
      );
      final route = _routeSnapshot();
      final firstStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(firstStore.dispose);

      await firstStore.saveCompletedRun(
        _richCompletionResult('rich-client-session', route: route),
        payload: _richPayload('rich-client-session'),
      );

      final restoredStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(restoredStore.dispose);
      await restoredStore.restoreSavedActivities();

      final restoredActivity = restoredStore.activities.single;
      final restoredSummary = restoredActivity.display.summary;
      final restoredPayload = (await storage.load()).single.payload;

      expect(restoredSummary.hasSufficientData, isTrue);
      expect(restoredSummary.route.hasRoute, isTrue);
      expect(restoredSummary.paceGraph.isAvailable, isTrue);
      expect(restoredSummary.paceAnalysisSeries?.isLocalAcceptedSource, isTrue);
      expect(
        restoredSummary.cadenceAnalysisSeries?.isProductionAnalysisEligible,
        isTrue,
      );
      expect(restoredSummary.elevationSeries.isUnavailable, isFalse);
      expect(restoredPayload.paceGraphSamples, hasLength(4));
      expect(restoredPayload.cadenceAnalysisSeries?.samples, hasLength(3));
      expect(restoredPayload.elevationAnalysisSeries?.samples, hasLength(3));
      expect(
        restoredPayload.elevationUnavailableReason,
        ElevationUnavailableReason.none,
      );
    },
  );

  test('sync marks saved pending run after repository accepts it', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final store = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(store.dispose);
    final repository = _RecordingRunRepository();

    await store.saveCompletedRun(
      _completionResult('sync-client-session'),
      payload: _payload('sync-client-session'),
    );
    final savedBeforeSync = await storage.load();
    expect(savedBeforeSync.single.syncState, RunSyncState.localSaved);
    expect(store.syncDebugSnapshots.single.syncState, RunSyncState.localSaved);

    await store.syncPendingRuns(repository);

    expect(repository.completedClientRunSessionIds, ['sync-client-session']);
    final savedAfterSync = await storage.load();
    expect(savedAfterSync.map((run) => run.clientRunSessionId), [
      'sync-client-session',
    ]);
    expect(savedAfterSync.map((run) => run.syncAccepted), [true]);
    expect(savedAfterSync.single.syncState, RunSyncState.syncAccepted);
    expect(
      store.syncDebugSnapshots.single.syncState,
      RunSyncState.syncAccepted,
    );
    expect(store.activities.map((run) => run.activityId), [
      'activity_sync-client-session',
    ]);
  });

  test(
    'sync exposes pending state while repository call is in flight',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);
      final repository = _DelayedRecordingRunRepository();

      await store.saveCompletedRun(
        _completionResult('pending-observable-client-session'),
        payload: _payload('pending-observable-client-session'),
      );

      final sync = store.syncPendingRuns(repository);
      await Future<void>.delayed(Duration.zero);

      final inFlight = await storage.load();
      expect(inFlight.single.syncState, RunSyncState.pendingSync);
      expect(
        store.syncDebugSnapshots.single.syncState,
        RunSyncState.pendingSync,
      );
      expect(inFlight.single.syncAttemptCount, 1);

      repository.complete();
      await sync;

      expect(
        (await storage.load()).single.syncState,
        RunSyncState.syncAccepted,
      );
    },
  );

  test('sync merges remote scalar identity into rich local snapshot', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final store = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(store.dispose);
    final repository = _RecordingRunRepository();

    await store.saveCompletedRun(
      _richCompletionResult(
        'rich-sync-client-session',
        route: _routeSnapshot(),
      ),
      payload: _richPayload('rich-sync-client-session'),
    );
    await store.syncPendingRuns(repository);

    final saved = (await storage.load()).single;
    expect(saved.syncAccepted, isTrue);
    expect(saved.result.activityId, 'activity_rich-sync-client-session');
    expect(saved.result.summaryId, 'summary_rich-sync-client-session');
    expect(
      saved.result.progressionEventId,
      'progression_rich-sync-client-session',
    );
    expect(
      store.activities.single.activityId,
      'activity_rich-sync-client-session',
    );
    expect(saved.result.summary.route.hasRoute, isTrue);
    expect(saved.result.summary.paceGraph.isAvailable, isTrue);
    expect(saved.result.summary.cadenceAnalysisSeries, isNotNull);
    expect(saved.result.summary.elevationSeries.isUnavailable, isFalse);
  });

  test(
    'merged rich local snapshot survives shared preferences restore',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const storage = SharedPreferencesLocalPendingRunActivityStore(
        key: 'test.pendingMergedRichRun',
      );
      final firstStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(firstStore.dispose);
      final repository = _RecordingRunRepository();

      await firstStore.saveCompletedRun(
        _richCompletionResult(
          'rich-restore-merged-client-session',
          route: _routeSnapshot(),
        ),
        payload: _richPayload('rich-restore-merged-client-session'),
      );
      await firstStore.syncPendingRuns(repository);

      final restoredStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(restoredStore.dispose);
      await restoredStore.restoreSavedActivities();

      final restoredActivity = restoredStore.activities.single;
      expect(
        restoredActivity.activityId,
        'activity_rich-restore-merged-client-session',
      );
      expect(restoredActivity.display.summary.route.hasRoute, isTrue);
      expect(restoredActivity.display.summary.paceGraph.isAvailable, isTrue);
      expect(restoredActivity.display.summary.cadenceAnalysisSeries, isNotNull);
      expect(
        restoredActivity.display.summary.elevationSeries.isUnavailable,
        isFalse,
      );
    },
  );

  test('low-data save stores confirmation and sync submits it', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final store = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(store.dispose);
    final repository = _RecordingRunRepository();

    await store.saveCompletedRun(
      _completionResult('confirmed-low-data-client-session'),
      payload: _payload(
        'confirmed-low-data-client-session',
        userConfirmedLowDataSave: true,
      ),
    );

    final savedBeforeSync = await storage.load();
    expect(savedBeforeSync.single.payload.userConfirmedLowDataSave, isTrue);

    await store.syncPendingRuns(repository);

    expect(repository.completedClientRunSessionIds, [
      'confirmed-low-data-client-session',
    ]);
    expect(
      repository.submittedPayloads.single.userConfirmedLowDataSave,
      isTrue,
    );
    expect(
      (await storage.load()).single.payload.userConfirmedLowDataSave,
      isTrue,
    );
    expect((await storage.load()).single.syncAccepted, isTrue);
  });

  test(
    'restores low-data save confirmation from shared preferences storage',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const storage = SharedPreferencesLocalPendingRunActivityStore(
        key: 'test.pendingConfirmedLowDataRun',
      );
      final firstStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(firstStore.dispose);

      await firstStore.saveCompletedRun(
        _completionResult('confirmed-low-data-shared-prefs-session'),
        payload: _payload(
          'confirmed-low-data-shared-prefs-session',
          userConfirmedLowDataSave: true,
        ),
      );

      final restored = await storage.load();

      expect(restored.single.payload.userConfirmedLowDataSave, isTrue);
    },
  );

  test('static repository sync does not mark pending run accepted', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final store = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(store.dispose);

    await store.saveCompletedRun(
      _completionResult('static-sync-client-session'),
      payload: _payload('static-sync-client-session'),
    );
    await store.syncPendingRuns(const StaticRunRepository());

    expect((await storage.load()).map((run) => run.clientRunSessionId), [
      'static-sync-client-session',
    ]);
    expect((await storage.load()).map((run) => run.syncAccepted), [false]);
  });

  test('concurrent sync calls submit a pending run once', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final store = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(store.dispose);
    final repository = _DelayedRecordingRunRepository();

    await store.saveCompletedRun(
      _completionResult('concurrent-client-session'),
      payload: _payload('concurrent-client-session'),
    );

    final firstSync = store.syncPendingRuns(repository);
    final secondSync = store.syncPendingRuns(repository);
    await Future<void>.delayed(Duration.zero);

    expect(repository.completedClientRunSessionIds, [
      'concurrent-client-session',
    ]);

    repository.complete();
    await Future.wait([firstSync, secondSync]);

    expect(repository.completedClientRunSessionIds, [
      'concurrent-client-session',
    ]);
    expect((await storage.load()).map((run) => run.syncAccepted), [true]);
  });

  test(
    'active sync drains a new request saved while sync is in flight',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);
      final repository = _DelayedRecordingRunRepository();

      await store.saveCompletedRun(
        _completionResult('first-in-flight-client-session'),
        payload: _payload('first-in-flight-client-session'),
      );

      final firstSync = store.syncPendingRuns(repository);
      await Future<void>.delayed(Duration.zero);

      await store.saveCompletedRun(
        _completionResult('second-in-flight-client-session'),
        payload: _payload('second-in-flight-client-session'),
      );
      final secondSync = store.syncPendingRuns(repository);

      repository.complete();
      await Future.wait([firstSync, secondSync]);

      expect(repository.completedClientRunSessionIds, [
        'first-in-flight-client-session',
        'second-in-flight-client-session',
      ]);
      expect((await storage.load()).map((run) => run.syncAccepted), [
        true,
        true,
      ]);
    },
  );

  test(
    'remote reconcile clears accepted pending run after read-side appears',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);
      final repository = _RecordingRunRepository();

      await store.saveCompletedRun(
        _completionResult('reconcile-client-session'),
        payload: _payload('reconcile-client-session'),
      );
      await store.syncPendingRuns(repository);

      store.reconcileWithRemote([_remoteActivity('reconcile-client-session')]);
      await Future<void>.delayed(Duration.zero);

      expect(await storage.load(), isEmpty);
      expect(store.activities, isEmpty);
    },
  );

  test(
    'remote reconcile keeps accepted rich local snapshot after read-side appears',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);
      final repository = _RecordingRunRepository();

      await store.saveCompletedRun(
        _richCompletionResult(
          'rich-reconcile-client-session',
          route: _routeSnapshot(),
        ),
        payload: _richPayload('rich-reconcile-client-session'),
      );
      await store.syncPendingRuns(repository);

      store.reconcileWithRemote([
        _remoteActivity('rich-reconcile-client-session'),
      ]);
      await Future<void>.delayed(Duration.zero);

      final saved = await storage.load();
      expect(saved.single.syncAccepted, isTrue);
      expect(store.activities, hasLength(1));
      final summary = store.activities.single.display.summary;
      expect(summary.route.hasRoute, isTrue);
      expect(summary.paceGraph.isAvailable, isTrue);
      expect(summary.cadenceAnalysisSeries, isNotNull);
      expect(summary.elevationSeries.isUnavailable, isFalse);
    },
  );

  test(
    'remote reconcile merges scalar identity into rich local snapshot',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);
      final repository = _RecordingRunRepository();

      await store.saveCompletedRun(
        _richCompletionResult(
          'rich-reconcile-merge-client-session',
          route: _routeSnapshot(),
        ),
        payload: _richPayload('rich-reconcile-merge-client-session'),
      );
      await store.syncPendingRuns(repository);

      store.reconcileWithRemote([
        _remoteActivity('rich-reconcile-merge-client-session'),
      ]);
      await Future<void>.delayed(Duration.zero);

      final saved = await storage.load();
      expect(
        saved.single.result.activityId,
        'firestore-rich-reconcile-merge-client-session',
      );
      expect(
        store.activities.single.activityId,
        'firestore-rich-reconcile-merge-client-session',
      );
      final summary = store.activities.single.display.summary;
      expect(summary.route.hasRoute, isTrue);
      expect(summary.paceGraph.isAvailable, isTrue);
      expect(summary.cadenceAnalysisSeries, isNotNull);
      expect(summary.elevationSeries.isUnavailable, isFalse);
    },
  );

  test('local save failure does not leave an in-memory saved run', () async {
    final storage = _FailingSavePendingRunActivityStore();
    final store = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(store.dispose);

    await expectLater(
      store.saveCompletedRun(
        _completionResult('failed-save-client-session'),
        payload: _payload('failed-save-client-session'),
      ),
      throwsStateError,
    );

    expect(store.activities, isEmpty);
  });

  test(
    'save does not register in memory if owner changes before persistence completes',
    () async {
      final storage = _DelayedSavePendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);

      final save = store.saveCompletedRun(
        _completionResult('save-race-client-session'),
        payload: _payload('save-race-client-session'),
      );
      await Future<void>.delayed(Duration.zero);

      store.updateOwnerUid(otherOwnerUid);
      storage.completeSave();
      await save;

      expect(store.activities, isEmpty);
      expect((await storage.load()).single.ownerUid, ownerUid);
    },
  );

  test('sync keeps saved pending run when repository rejects it', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final store = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(store.dispose);
    final repository = _RejectingRunRepository();

    await store.saveCompletedRun(
      _completionResult('retry-client-session'),
      payload: _payload('retry-client-session'),
    );
    await store.syncPendingRuns(repository);

    expect(repository.completedClientRunSessionIds, ['retry-client-session']);
    expect((await storage.load()).map((run) => run.clientRunSessionId), [
      'retry-client-session',
    ]);
    expect(store.activities.map((run) => run.activityId), [
      'local-retry-client-session',
    ]);
    final saved = await storage.load();
    expect(saved.single.syncState, RunSyncState.syncRetryableFailure);
    expect(saved.single.lastSyncFailureCode, 'unknown');
    expect(
      saved.single.lastSyncFailureMessage,
      contains('repository unavailable'),
    );
    expect(
      store.syncDebugSnapshots.single.syncState,
      RunSyncState.syncRetryableFailure,
    );
  });

  test(
    'sync records non-retryable completion failures without resubmitting',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);
      final repository = _RunCompletionErrorRepository(
        code: 'invalid-argument',
        isRetryable: false,
      );

      await store.saveCompletedRun(
        _completionResult('non-retryable-client-session'),
        payload: _payload('non-retryable-client-session'),
      );
      await store.syncPendingRuns(repository);
      await store.syncPendingRuns(repository);

      expect(repository.completedClientRunSessionIds, [
        'non-retryable-client-session',
      ]);
      final saved = await storage.load();
      expect(saved.single.syncAccepted, isFalse);
      expect(saved.single.syncState, RunSyncState.syncNonRetryableFailure);
      expect(saved.single.lastSyncFailureCode, 'invalid-argument');
      expect(
        store.syncDebugSnapshots.single.syncState,
        RunSyncState.syncNonRetryableFailure,
      );
    },
  );

  test('restore and sync ignore pending runs for another owner', () async {
    final storage = MemoryLocalPendingRunActivityStore();
    final firstStore = CurrentSessionActivityHistoryStore(
      ownerUid: ownerUid,
      persistence: storage,
    );
    addTearDown(firstStore.dispose);
    await firstStore.saveCompletedRun(
      _completionResult('owner-client-session'),
      payload: _payload('owner-client-session'),
    );

    final secondStore = CurrentSessionActivityHistoryStore(
      ownerUid: otherOwnerUid,
      persistence: storage,
    );
    addTearDown(secondStore.dispose);
    final repository = _RecordingRunRepository();

    await secondStore.restoreSavedActivities();
    await secondStore.syncPendingRuns(repository);

    expect(secondStore.activities, isEmpty);
    expect(repository.completedClientRunSessionIds, isEmpty);
    expect((await storage.load()).map((run) => run.ownerUid), [ownerUid]);
  });

  test(
    'same client session id from another owner does not overwrite pending',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final firstStore = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      final secondStore = CurrentSessionActivityHistoryStore(
        ownerUid: otherOwnerUid,
        persistence: storage,
      );
      addTearDown(firstStore.dispose);
      addTearDown(secondStore.dispose);

      await firstStore.saveCompletedRun(
        _completionResult('local-run-1'),
        payload: _payload('local-run-1'),
      );
      await secondStore.saveCompletedRun(
        _completionResult('local-run-1'),
        payload: _payload('local-run-1'),
      );

      expect((await storage.load()).map((run) => run.ownerUid), [
        otherOwnerUid,
        ownerUid,
      ]);
    },
  );

  test(
    'restore ignores loaded records if owner changes before load completes',
    () async {
      final storage = _DelayedLoadPendingRunActivityStore([
        LocalPendingRunActivity.fromCompletedRun(
          ownerUid: ownerUid,
          result: _completionResult('race-client-session'),
          payload: _payload('race-client-session'),
        ),
      ]);
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);

      final restore = store.restoreSavedActivities();
      await Future<void>.delayed(Duration.zero);

      store.updateOwnerUid(otherOwnerUid);
      storage.completeLoad();
      await restore;

      expect(store.activities, isEmpty);
    },
  );

  test(
    'sync stops if owner changes before repository call completes',
    () async {
      final storage = MemoryLocalPendingRunActivityStore();
      final store = CurrentSessionActivityHistoryStore(
        ownerUid: ownerUid,
        persistence: storage,
      );
      addTearDown(store.dispose);
      final repository = _DelayedRecordingRunRepository();

      await store.saveCompletedRun(
        _completionResult('owner-switch-client-session'),
        payload: _payload('owner-switch-client-session'),
      );

      final sync = store.syncPendingRuns(repository);
      await Future<void>.delayed(Duration.zero);

      store.updateOwnerUid(otherOwnerUid);
      repository.complete();
      await sync;

      expect((await storage.load()).single.syncAccepted, isFalse);
    },
  );
}

RunActivityDisplayModel _remoteActivity(String clientRunSessionId) {
  final result = _completionResult(clientRunSessionId);
  return RunActivityDisplayModel(
    activityId: 'firestore-$clientRunSessionId',
    clientRunSessionId: clientRunSessionId,
    title: result.summary.title,
    timeAgoLabel: result.summary.dateTimeLabel,
    distanceLabel: '${result.summary.distanceKm} km',
    paceLabel: result.summary.avgPace,
    durationLabel: result.summary.duration,
    summary: result.summary,
  );
}

CompleteRunResult _completionResult(
  String clientRunSessionId, {
  RunRouteSnapshot route = RunRouteSnapshot.empty,
}) {
  return CompleteRunResult(
    clientRunSessionId: clientRunSessionId,
    activityId: 'local-$clientRunSessionId',
    summary: RunSummarySnapshot(
      title: 'Completed Run',
      dateLabel: 'Today',
      timeLabel: '7:25 AM',
      distanceKm: '0.00',
      avgPace: '--',
      duration: '0:02',
      avgHeartRate: '--',
      calories: '--',
      routeName: 'Private route',
      hasSufficientData: false,
      route: route,
    ),
    xpUpdate: const XpUpdateDisplayModel(
      runnerName: 'Runiac Runner',
      earnedXpLabel: '+0 XP',
      totalXpLabel: 'Deferred by backend',
      levelLabel: 'Pending',
      nextLevelLabel: 'Pending',
      progressTargetLabel: 'Pending',
      xpRemainingLabel: 'Formula pending',
      previousProgressFraction: 0,
      currentProgressFraction: 0,
      streakChangeLabel: 'Deferred',
      streakNote: 'Backend validation accepted the run.',
      didLevelUp: false,
    ),
  );
}

CompleteRunResult _richCompletionResult(
  String clientRunSessionId, {
  RunRouteSnapshot route = RunRouteSnapshot.empty,
}) {
  return CompleteRunResult(
    clientRunSessionId: clientRunSessionId,
    activityId: 'local-$clientRunSessionId',
    summary: RunSummarySnapshot(
      title: 'Completed Run',
      dateLabel: 'Today',
      timeLabel: '7:25 AM',
      distanceKm: '1.00',
      avgPace: '5:00',
      duration: '5:00',
      avgHeartRate: '--',
      calories: '--',
      routeName: 'Private route',
      hasSufficientData: true,
      paceAnalysisSeries: PaceAnalysisSeries.localAccepted(
        samples: _paceAnalysisSamples(),
      ),
      cadenceAnalysisSeries: _cadenceAnalysisSeries(),
      elevationSeries: _elevationAnalysisSeries(),
      paceGraph: const PaceGraphDataBuilder().build(
        samples: _paceGraphSamples(),
        durationSeconds: 300,
        distanceMeters: 1000,
        averagePaceSecondsPerKm: 300,
      ),
      route: route,
    ),
    xpUpdate: const XpUpdateDisplayModel(
      runnerName: 'Runiac Runner',
      earnedXpLabel: '+0 XP',
      totalXpLabel: 'Deferred by backend',
      levelLabel: 'Pending',
      nextLevelLabel: 'Pending',
      progressTargetLabel: 'Pending',
      xpRemainingLabel: 'Formula pending',
      previousProgressFraction: 0,
      currentProgressFraction: 0,
      streakChangeLabel: 'Deferred',
      streakNote: 'Backend validation accepted the run.',
      didLevelUp: false,
    ),
  );
}

RunRouteSnapshot _routeSnapshot() {
  final samples = <RunLocationSample>[
    RunLocationSample(
      recordedAt: DateTime.utc(2026, 6, 14, 9),
      latitude: 1.3001,
      longitude: 103.8301,
      altitudeMeters: 12,
      horizontalAccuracyMeters: 8,
      speedMetersPerSecond: 2.6,
    ),
    RunLocationSample(
      recordedAt: DateTime.utc(2026, 6, 14, 9, 0, 1),
      latitude: 1.3016,
      longitude: 103.8318,
      altitudeMeters: 14,
      horizontalAccuracyMeters: 7,
      speedMetersPerSecond: 2.8,
    ),
    RunLocationSample(
      recordedAt: DateTime.utc(2026, 6, 14, 9, 0, 2),
      latitude: 1.3033,
      longitude: 103.8333,
      altitudeMeters: 16,
      horizontalAccuracyMeters: 6,
      speedMetersPerSecond: 2.9,
    ),
  ];
  return RunRouteSnapshot(segments: [samples], lastKnownLocation: samples.last);
}

List<PaceGraphSample> _paceGraphSamples() {
  return const <PaceGraphSample>[
    PaceGraphSample(
      elapsedSeconds: 60,
      paceSecondsPerKm: 300,
      cumulativeDistanceMeters: 200,
    ),
    PaceGraphSample(
      elapsedSeconds: 120,
      paceSecondsPerKm: 295,
      cumulativeDistanceMeters: 400,
    ),
    PaceGraphSample(
      elapsedSeconds: 210,
      paceSecondsPerKm: 305,
      cumulativeDistanceMeters: 700,
    ),
    PaceGraphSample(
      elapsedSeconds: 300,
      paceSecondsPerKm: 300,
      cumulativeDistanceMeters: 1000,
    ),
  ];
}

List<PaceAnalysisSample> _paceAnalysisSamples() {
  return const <PaceAnalysisSample>[
    PaceAnalysisSample.accepted(
      elapsedSeconds: 60,
      cumulativeDistanceMeters: 200,
      paceSecondsPerKm: 300,
    ),
    PaceAnalysisSample.accepted(
      elapsedSeconds: 120,
      cumulativeDistanceMeters: 400,
      paceSecondsPerKm: 295,
    ),
    PaceAnalysisSample.accepted(
      elapsedSeconds: 210,
      cumulativeDistanceMeters: 700,
      paceSecondsPerKm: 305,
    ),
    PaceAnalysisSample.accepted(
      elapsedSeconds: 300,
      cumulativeDistanceMeters: 1000,
      paceSecondsPerKm: 300,
    ),
  ];
}

CadenceAnalysisSeries _cadenceAnalysisSeries() {
  return CadenceAnalysisSeries.phoneMotionEstimated(
    samples: const <CadenceAnalysisSample>[
      CadenceAnalysisSample.accepted(elapsedSeconds: 60, cadenceSpm: 170),
      CadenceAnalysisSample.accepted(elapsedSeconds: 120, cadenceSpm: 174),
      CadenceAnalysisSample.accepted(elapsedSeconds: 210, cadenceSpm: 172),
    ],
  );
}

ElevationAnalysisSeries _elevationAnalysisSeries() {
  return ElevationAnalysisSeries.localAccepted(
    samples: const <ElevationAnalysisSample>[
      ElevationAnalysisSample(distanceKm: 0, elevationMeters: 12),
      ElevationAnalysisSample(distanceKm: 0.5, elevationMeters: 18),
      ElevationAnalysisSample(distanceKm: 1, elevationMeters: 16),
    ],
  );
}

LocalRunCompletionPayload _payload(
  String clientRunSessionId, {
  bool userConfirmedLowDataSave = false,
}) {
  return LocalRunCompletionPayload(
    clientRunSessionId: clientRunSessionId,
    startedAt: DateTime.utc(2026, 6, 14, 9),
    completedAt: DateTime.utc(2026, 6, 14, 9, 0, 2),
    durationSeconds: 2,
    distanceMeters: 0,
    avgPaceSecondsPerKm: 0,
    source: 'mobile',
    routePrivacy: 'private',
    userConfirmedLowDataSave: userConfirmedLowDataSave,
  );
}

LocalRunCompletionPayload _richPayload(String clientRunSessionId) {
  return LocalRunCompletionPayload(
    clientRunSessionId: clientRunSessionId,
    startedAt: DateTime.utc(2026, 6, 14, 9),
    completedAt: DateTime.utc(2026, 6, 14, 9, 5),
    durationSeconds: 300,
    distanceMeters: 1000,
    avgPaceSecondsPerKm: 300,
    source: 'mobile',
    routePrivacy: 'private',
    paceGraphSamples: _paceGraphSamples(),
    cadenceAnalysisSeries: _cadenceAnalysisSeries(),
    elevationAnalysisSeries: _elevationAnalysisSeries(),
    elevationUnavailableReason: ElevationUnavailableReason.none,
  );
}

class _RecordingRunRepository implements RunRepository {
  final List<String> completedClientRunSessionIds = <String>[];
  final List<LocalRunCompletionPayload> submittedPayloads =
      <LocalRunCompletionPayload>[];

  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    completedClientRunSessionIds.add(payload.clientRunSessionId);
    submittedPayloads.add(payload);
    final result = _completionResult(payload.clientRunSessionId);
    return CompleteRunResult(
      clientRunSessionId: result.clientRunSessionId,
      activityId: 'activity_${payload.clientRunSessionId}',
      summaryId: 'summary_${payload.clientRunSessionId}',
      progressionEventId: 'progression_${payload.clientRunSessionId}',
      validationStatus: result.validationStatus,
      summary: result.summary,
      progressionDisplay: result.progressionDisplay,
      xpUpdate: result.xpUpdate,
      message: result.message,
    );
  }

  @override
  Future<CompleteRunResult> loadLatestCompletionResult() {
    throw UnimplementedError();
  }

  @override
  Future<RunActivityReadModel> loadLatestRunActivity() {
    throw UnimplementedError();
  }

  @override
  Future<RunSummaryReadModel> loadLatestRunSummary() {
    throw UnimplementedError();
  }
}

class _DelayedRecordingRunRepository extends _RecordingRunRepository {
  final Completer<void> _completeRun = Completer<void>();

  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    completedClientRunSessionIds.add(payload.clientRunSessionId);
    await _completeRun.future;
    final result = _completionResult(payload.clientRunSessionId);
    return CompleteRunResult(
      clientRunSessionId: result.clientRunSessionId,
      activityId: 'activity_${payload.clientRunSessionId}',
      summaryId: 'summary_${payload.clientRunSessionId}',
      progressionEventId: 'progression_${payload.clientRunSessionId}',
      validationStatus: result.validationStatus,
      summary: result.summary,
      progressionDisplay: result.progressionDisplay,
      xpUpdate: result.xpUpdate,
      message: result.message,
    );
  }

  void complete() {
    if (!_completeRun.isCompleted) {
      _completeRun.complete();
    }
  }
}

class _RejectingRunRepository extends _RecordingRunRepository {
  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    completedClientRunSessionIds.add(payload.clientRunSessionId);
    throw StateError('repository unavailable');
  }
}

class _RunCompletionErrorRepository extends _RecordingRunRepository {
  _RunCompletionErrorRepository({
    required this.code,
    required this.isRetryable,
  });

  final String code;
  final bool isRetryable;

  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    completedClientRunSessionIds.add(payload.clientRunSessionId);
    throw RunCompletionException(
      code: code,
      message: 'callable rejected ${payload.clientRunSessionId}',
      isRetryable: isRetryable,
    );
  }
}

class _FailingSavePendingRunActivityStore
    implements LocalPendingRunActivityStore {
  @override
  Future<List<LocalPendingRunActivity>> load() async {
    return const <LocalPendingRunActivity>[];
  }

  @override
  Future<void> save(List<LocalPendingRunActivity> activities) {
    throw StateError('local storage unavailable');
  }
}

class _DelayedLoadPendingRunActivityStore
    implements LocalPendingRunActivityStore {
  _DelayedLoadPendingRunActivityStore(this._activities);

  final List<LocalPendingRunActivity> _activities;
  final Completer<void> _loadCompleter = Completer<void>();

  @override
  Future<List<LocalPendingRunActivity>> load() async {
    await _loadCompleter.future;
    return List<LocalPendingRunActivity>.of(_activities);
  }

  @override
  Future<void> save(List<LocalPendingRunActivity> activities) async {}

  void completeLoad() {
    if (!_loadCompleter.isCompleted) {
      _loadCompleter.complete();
    }
  }
}

class _DelayedSavePendingRunActivityStore
    implements LocalPendingRunActivityStore {
  final Completer<void> _saveCompleter = Completer<void>();
  List<LocalPendingRunActivity> _activities = const <LocalPendingRunActivity>[];

  @override
  Future<List<LocalPendingRunActivity>> load() async {
    return List<LocalPendingRunActivity>.of(_activities);
  }

  @override
  Future<void> save(List<LocalPendingRunActivity> activities) async {
    await _saveCompleter.future;
    _activities = List<LocalPendingRunActivity>.of(activities);
  }

  void completeSave() {
    if (!_saveCompleter.isCompleted) {
      _saveCompleter.complete();
    }
  }
}
