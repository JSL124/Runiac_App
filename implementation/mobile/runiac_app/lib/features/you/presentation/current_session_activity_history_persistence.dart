part of 'current_session_activity_history.dart';

extension CurrentSessionActivityHistoryPersistence
    on CurrentSessionActivityHistoryStore {
  Future<void> restoreSavedActivities() async {
    final storage = persistence;
    if (storage == null) {
      return;
    }
    final ownerUid = _ownerUid;
    if (ownerUid == null) {
      return;
    }
    final ownerGeneration = _ownerGeneration;

    final records = await _enqueueStorageMutation(
      () => _loadPendingActivities(storage),
    );
    if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
      return;
    }
    for (final record in records.reversed.where(
      (record) => record.ownerUid == ownerUid,
    )) {
      if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
        return;
      }
      registerCompletedRun(record.result, ownerUid: record.ownerUid);
    }
  }

  Future<void> syncPendingRuns(RunRepository repository) async {
    _syncRequestSerial += 1;
    final activeSync = _pendingSync;
    if (activeSync != null) {
      return activeSync;
    }

    final sync = _drainPendingSyncRequests(repository);
    late final Future<void> trackedSync;
    trackedSync = sync.whenComplete(() {
      if (identical(_pendingSync, trackedSync)) {
        _pendingSync = null;
      }
    });
    _pendingSync = trackedSync;
    return trackedSync;
  }

  Future<void> _drainPendingSyncRequests(RunRepository repository) async {
    var completedSerial = 0;
    while (completedSerial != _syncRequestSerial) {
      completedSerial = _syncRequestSerial;
      await _syncPendingRuns(repository);
    }
  }

  Future<void> _syncPendingRuns(RunRepository repository) async {
    final storage = persistence;
    if (storage == null) {
      return;
    }
    final ownerUid = _ownerUid;
    if (ownerUid == null) {
      return;
    }
    final ownerGeneration = _ownerGeneration;

    final records = await _enqueueStorageMutation(
      () => _loadPendingActivities(storage),
    );
    if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
      return;
    }
    final pendingRecords = records
        .where((record) => record.ownerUid == ownerUid && !record.syncAccepted)
        .toList(growable: false);

    for (final record in pendingRecords) {
      CompleteRunResult syncedResult;
      try {
        if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
          return;
        }
        syncedResult = await repository.completeRun(record.payload);
      } catch (error, stackTrace) {
        _reportAsyncError(error, stackTrace, 'syncing a pending run');
        return;
      }
      if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
        return;
      }
      if (!_looksLikeRemoteCompletion(syncedResult)) {
        continue;
      }
      try {
        final syncedRecord = await _mergePendingRunSyncAccepted(
          storage: storage,
          ownerUid: ownerUid,
          clientRunSessionId: record.clientRunSessionId,
          remoteResult: syncedResult,
        );
        if (syncedRecord != null &&
            _ownerUid == ownerUid &&
            _ownerGeneration == ownerGeneration) {
          _replaceCompletedRun(syncedRecord.result, ownerUid: ownerUid);
        }
      } catch (error, stackTrace) {
        _reportAsyncError(error, stackTrace, 'saving pending run sync state');
        return;
      }
    }
  }

  void reconcileWithRemote(Iterable<RunActivityDisplayModel> remoteActivities) {
    final remoteByClientRunSessionId = <String, RunActivityDisplayModel>{
      for (final activity in remoteActivities)
        if (activity.clientRunSessionId != null &&
            activity.clientRunSessionId!.isNotEmpty)
          activity.clientRunSessionId!: activity,
    };
    final remoteClientRunSessionIds = remoteByClientRunSessionId.keys.toSet();
    final remoteActivityIds = remoteActivities
        .map((activity) => activity.activityId)
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
    if (remoteClientRunSessionIds.isEmpty && remoteActivityIds.isEmpty) {
      return;
    }

    var changed = false;
    final nextActivities = <SessionCompletedRunActivity>[];
    for (final activity in _activities) {
      final clientRunSessionId = activity.completionResult.clientRunSessionId;
      final remoteActivity = clientRunSessionId == null
          ? null
          : remoteByClientRunSessionId[clientRunSessionId];
      final hasRemoteMatch =
          remoteActivity != null ||
          remoteActivityIds.contains(activity.activityId);
      if (!hasRemoteMatch) {
        nextActivities.add(activity);
        continue;
      }
      if (_hasLocalOnlySnapshot(activity)) {
        final mergedActivity = remoteActivity == null
            ? activity
            : _mergeRemoteActivityIdentity(activity, remoteActivity);
        if (!identical(mergedActivity, activity)) {
          changed = true;
        }
        nextActivities.add(mergedActivity);
        continue;
      }
      changed = true;
    }
    if (changed) {
      _activities
        ..clear()
        ..addAll(nextActivities);
      _notifyActivityHistoryChanged();
      unawaited(
        _persistCurrentPendingActivities().catchError(
          (Object error, StackTrace stackTrace) => _reportAsyncError(
            error,
            stackTrace,
            'persisting reconciled run activities',
          ),
        ),
      );
    }
  }

  bool _hasLocalOnlySnapshot(SessionCompletedRunActivity activity) {
    final summary = activity.display.summary;
    return summary.route.hasRoute ||
        summary.paceGraph.isAvailable ||
        (summary.paceAnalysisSeries != null &&
            !summary.paceAnalysisSeries!.isUnavailable) ||
        (summary.cadenceAnalysisSeries != null &&
            !summary.cadenceAnalysisSeries!.isUnavailable) ||
        !summary.elevationSeries.isUnavailable;
  }

  Future<List<LocalPendingRunActivity>> _loadPendingActivities(
    LocalPendingRunActivityStore storage,
  ) async {
    try {
      return await storage.load();
    } catch (error, stackTrace) {
      _reportAsyncError(error, stackTrace, 'loading pending run activities');
      return const <LocalPendingRunActivity>[];
    }
  }

  Future<void> _persistCurrentPendingActivities() async {
    final storage = persistence;
    if (storage == null) {
      return;
    }
    final ownerUid = _ownerUid;
    if (ownerUid == null) {
      return;
    }

    await _enqueueStorageMutation(() async {
      final activitiesByClientRunSessionId =
          <String, SessionCompletedRunActivity>{
            for (final activity in _activities)
              if (activity.ownerUid == ownerUid &&
                  activity.completionResult.clientRunSessionId != null &&
                  activity.completionResult.clientRunSessionId!.isNotEmpty)
                activity.completionResult.clientRunSessionId!: activity,
          };
      final saved = await storage.load();
      final kept = <LocalPendingRunActivity>[
        for (final record in saved)
          if (record.ownerUid != ownerUid)
            record
          else if (activitiesByClientRunSessionId.containsKey(
            record.clientRunSessionId,
          ))
            record.copyWith(
              result: activitiesByClientRunSessionId[record.clientRunSessionId]!
                  .completionResult,
            ),
      ];
      await storage.save(kept);
    });
  }

  Future<LocalPendingRunActivity?> _mergePendingRunSyncAccepted({
    required LocalPendingRunActivityStore storage,
    required String ownerUid,
    required String clientRunSessionId,
    required CompleteRunResult remoteResult,
  }) {
    return _enqueueStorageMutation(() async {
      final saved = await storage.load();
      LocalPendingRunActivity? mergedRecord;
      final next = <LocalPendingRunActivity>[
        for (final record in saved)
          if (record.ownerUid == ownerUid &&
              record.clientRunSessionId == clientRunSessionId)
            mergedRecord = record.mergeRemoteCompletion(
              remoteResult,
              syncAccepted: true,
            )
          else
            record,
      ];
      if (mergedRecord != null) {
        await storage.save(next);
      }
      return mergedRecord;
    });
  }

  void _replaceCompletedRun(CompleteRunResult result, {String? ownerUid}) {
    final clientRunSessionId = result.clientRunSessionId;
    if (clientRunSessionId != null) {
      _activities.removeWhere(
        (activity) =>
            activity.ownerUid == (ownerUid ?? _ownerUid) &&
            activity.completionResult.clientRunSessionId == clientRunSessionId,
      );
    }
    registerCompletedRun(result, ownerUid: ownerUid);
  }

  SessionCompletedRunActivity _mergeRemoteActivityIdentity(
    SessionCompletedRunActivity activity,
    RunActivityDisplayModel remoteActivity,
  ) {
    if (activity.activityId == remoteActivity.activityId) {
      return activity;
    }
    final result = activity.completionResult.copyWith(
      activityId: remoteActivity.activityId,
    );
    return SessionCompletedRunActivity(
      activityId: result.activityId,
      ownerUid: activity.ownerUid,
      display: RunActivityDisplayModel(
        activityId: result.activityId,
        clientRunSessionId: result.clientRunSessionId,
        title: result.summary.title,
        timeAgoLabel: result.summary.dateTimeLabel,
        distanceLabel: '${result.summary.distanceKm} km',
        paceLabel: result.summary.avgPace,
        durationLabel: result.summary.duration,
        summary: result.summary,
        completionResult: result,
      ),
      completionResult: result,
    );
  }
}
