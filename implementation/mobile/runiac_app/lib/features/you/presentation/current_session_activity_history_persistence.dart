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

  Future<bool> syncPendingRuns(RunRepository repository) async {
    _syncRequestSerial += 1;
    final activeSync = _pendingSync;
    if (activeSync != null) {
      return activeSync;
    }

    final sync = _drainPendingSyncRequests(repository);
    late final Future<bool> trackedSync;
    trackedSync = sync.whenComplete(() {
      if (identical(_pendingSync, trackedSync)) {
        _pendingSync = null;
      }
    });
    _pendingSync = trackedSync;
    return trackedSync;
  }

  Future<bool> _drainPendingSyncRequests(RunRepository repository) async {
    var completedSerial = 0;
    var syncAccepted = true;
    while (completedSerial != _syncRequestSerial) {
      completedSerial = _syncRequestSerial;
      syncAccepted = await _syncPendingRuns(repository) && syncAccepted;
    }
    return syncAccepted;
  }

  Future<bool> _syncPendingRuns(RunRepository repository) async {
    final storage = persistence;
    if (storage == null) {
      return false;
    }
    final ownerUid = _ownerUid;
    if (ownerUid == null) {
      return false;
    }
    final ownerGeneration = _ownerGeneration;

    final records = await _enqueueStorageMutation(
      () => _loadPendingActivities(storage),
    );
    if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
      return false;
    }
    final pendingRecords = records
        .where((record) => record.ownerUid == ownerUid && !record.syncAccepted)
        .toList(growable: false);
    if (pendingRecords.isEmpty) {
      return true;
    }

    for (final record in pendingRecords) {
      CompleteRunResult syncedResult;
      try {
        if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
          return false;
        }
        syncedResult = await repository.completeRun(record.payload);
      } catch (error, stackTrace) {
        _reportAsyncError(error, stackTrace, 'syncing a pending run');
        return false;
      }
      if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
        return false;
      }
      if (!_looksLikeRemoteCompletion(syncedResult)) {
        return false;
      }
      try {
        await _markPendingRunSyncAccepted(
          storage: storage,
          ownerUid: ownerUid,
          clientRunSessionId: record.clientRunSessionId,
        );
      } catch (error, stackTrace) {
        _reportAsyncError(error, stackTrace, 'saving pending run sync state');
        return false;
      }
    }
    return true;
  }

  void reconcileWithRemote(Iterable<RunActivityDisplayModel> remoteActivities) {
    final remoteClientRunSessionIds = remoteActivities
        .map((activity) => activity.clientRunSessionId)
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
    final remoteActivityIds = remoteActivities
        .map((activity) => activity.activityId)
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
    if (remoteClientRunSessionIds.isEmpty && remoteActivityIds.isEmpty) {
      return;
    }

    final previousLength = _activities.length;
    _activities.removeWhere((activity) {
      final clientRunSessionId = activity.completionResult.clientRunSessionId;
      return (clientRunSessionId != null &&
              remoteClientRunSessionIds.contains(clientRunSessionId)) ||
          remoteActivityIds.contains(activity.activityId);
    });
    if (_activities.length != previousLength) {
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
      final records = _activities
          .where((activity) => activity.ownerUid == ownerUid)
          .map((activity) => activity.completionResult.clientRunSessionId)
          .whereType<String>()
          .toSet();
      final saved = await storage.load();
      final kept = saved
          .where(
            (record) =>
                record.ownerUid != ownerUid ||
                records.contains(record.clientRunSessionId),
          )
          .toList(growable: false);
      await storage.save(kept);
    });
  }

  Future<void> _markPendingRunSyncAccepted({
    required LocalPendingRunActivityStore storage,
    required String ownerUid,
    required String clientRunSessionId,
  }) {
    return _enqueueStorageMutation(() async {
      final saved = await storage.load();
      final next = <LocalPendingRunActivity>[
        for (final record in saved)
          if (record.ownerUid == ownerUid &&
              record.clientRunSessionId == clientRunSessionId)
            record.copyWith(syncAccepted: true)
          else
            record,
      ];
      final changed = next.any(
        (record) =>
            record.ownerUid == ownerUid &&
            record.clientRunSessionId == clientRunSessionId &&
            record.syncAccepted,
      );
      if (changed) {
        await storage.save(next);
      }
    });
  }
}
