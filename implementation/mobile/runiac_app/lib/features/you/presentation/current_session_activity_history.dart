// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../run/domain/models/complete_run_result.dart';
import '../../run/domain/models/local_run_completion_payload.dart';
import '../../run/domain/models/run_activity_display_model.dart';
import '../../run/domain/models/run_completion_error.dart';
import '../../run/domain/models/run_summary_snapshot.dart';
import '../../run/domain/repositories/run_repository.dart';
import '../data/local_pending_run_activity_store.dart';
import 'data/activity_history_demo_snapshots.dart';

part 'current_session_activity_history_persistence.dart';
part 'current_session_activity_history_queries.dart';

class SessionCompletedRunActivity {
  const SessionCompletedRunActivity({
    required this.activityId,
    this.ownerUid,
    required this.display,
    required this.completionResult,
  });

  final String activityId;
  final String? ownerUid;
  final RunActivityDisplayModel display;
  final CompleteRunResult completionResult;
}

class RunSyncDebugSnapshot {
  const RunSyncDebugSnapshot({
    required this.ownerUid,
    required this.clientRunSessionId,
    required this.syncState,
    required this.syncAccepted,
    required this.syncAttemptCount,
    this.activityId,
    this.lastSyncAttemptedAt,
    this.lastSyncFailureCode,
    this.lastSyncFailureMessage,
  });

  final String ownerUid;
  final String clientRunSessionId;
  final RunSyncState syncState;
  final bool syncAccepted;
  final int syncAttemptCount;
  final String? activityId;
  final DateTime? lastSyncAttemptedAt;
  final String? lastSyncFailureCode;
  final String? lastSyncFailureMessage;
}

class CurrentSessionActivityHistoryStore extends ChangeNotifier {
  CurrentSessionActivityHistoryStore({
    DateTime Function()? now,
    String? ownerUid,
    this.persistence,
  }) : _now = now ?? DateTime.now,
       _ownerUid = ownerUid;

  final DateTime Function() _now;
  final LocalPendingRunActivityStore? persistence;
  final List<SessionCompletedRunActivity> _activities =
      <SessionCompletedRunActivity>[];
  final List<RunSyncDebugSnapshot> _syncDebugSnapshots =
      <RunSyncDebugSnapshot>[];
  Future<void> _pendingStorageMutation = Future<void>.value();
  Future<void>? _pendingSync;
  String? _ownerUid;
  var _ownerGeneration = 0;
  var _syncRequestSerial = 0;

  UnmodifiableListView<SessionCompletedRunActivity> get activities {
    return UnmodifiableListView(_activities);
  }

  String? get ownerUid => _ownerUid;

  UnmodifiableListView<RunSyncDebugSnapshot> get syncDebugSnapshots {
    return UnmodifiableListView(_syncDebugSnapshots);
  }

  void updateOwnerUid(String? ownerUid) {
    if (_ownerUid == ownerUid) {
      return;
    }
    _ownerUid = ownerUid;
    _ownerGeneration += 1;
    final hadState = _activities.isNotEmpty || _syncDebugSnapshots.isNotEmpty;
    if (hadState) {
      _activities.clear();
      _syncDebugSnapshots.clear();
      notifyListeners();
    }
  }

  void registerCompletedRun(
    CompleteRunResult result, {
    String? ownerUid,
    int? distanceMeters,
  }) {
    final activity = SessionCompletedRunActivity(
      activityId: result.activityId,
      ownerUid: ownerUid ?? _ownerUid,
      display: RunActivityDisplayModel(
        activityId: result.activityId,
        clientRunSessionId: result.clientRunSessionId,
        title: result.summary.title,
        timeAgoLabel: result.summary.dateTimeLabel,
        distanceLabel: '${result.summary.distanceKm} km',
        distanceMeters: distanceMeters ?? _distanceMetersFor(result),
        paceLabel: result.summary.avgPace,
        durationLabel: result.summary.duration,
        summary: result.summary,
        completionResult: result,
      ),
      completionResult: result,
    );

    _activities.removeWhere((item) => item.activityId == activity.activityId);
    _activities.insert(0, activity);
    notifyListeners();
  }

  Future<void> saveCompletedRun(
    CompleteRunResult result, {
    required LocalRunCompletionPayload payload,
  }) async {
    final ownerUid = _requireOwnerUid();
    final ownerGeneration = _ownerGeneration;
    final record = LocalPendingRunActivity.fromCompletedRun(
      ownerUid: ownerUid,
      result: result,
      payload: payload,
    );
    final storage = persistence;
    if (storage == null) {
      if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
        return;
      }
      registerCompletedRun(
        record.result,
        ownerUid: record.ownerUid,
        distanceMeters: record.payload.distanceMeters,
      );
      return;
    }

    try {
      await _enqueueStorageMutation(() async {
        final existing = await storage.load();
        final next = <LocalPendingRunActivity>[
          record,
          for (final activity in existing)
            if (activity.ownerUid != record.ownerUid ||
                activity.clientRunSessionId != record.clientRunSessionId)
              activity,
        ];
        await storage.save(next);
      });
      if (_ownerUid != ownerUid || _ownerGeneration != ownerGeneration) {
        return;
      }
      _upsertSyncDebugSnapshot(record);
      registerCompletedRun(
        record.result,
        ownerUid: record.ownerUid,
        distanceMeters: record.payload.distanceMeters,
      );
    } catch (error, stackTrace) {
      _reportAsyncError(error, stackTrace, 'saving a completed run locally');
      rethrow;
    }
  }

  int _distanceMetersFor(CompleteRunResult result) {
    final kilometers = double.tryParse(result.summary.distanceKm);
    if (kilometers == null || !kilometers.isFinite) {
      return 0;
    }
    return (kilometers * 1000).round();
  }

  String _requireOwnerUid() {
    final ownerUid = _ownerUid;
    if (ownerUid == null || ownerUid.isEmpty) {
      throw StateError('Cannot persist a run without an authenticated owner.');
    }
    return ownerUid;
  }

  bool _looksLikeRemoteCompletion(CompleteRunResult result) {
    return result.activityId.startsWith('activity_');
  }

  Future<T> _enqueueStorageMutation<T>(Future<T> Function() action) {
    final run = _pendingStorageMutation.then(
      (_) => action(),
      onError: (Object _, StackTrace _) => action(),
    );
    _pendingStorageMutation = run.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return run;
  }

  void _reportAsyncError(
    Object error,
    StackTrace stackTrace,
    String operation,
  ) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'runiac activity history',
        context: ErrorDescription(operation),
      ),
    );
  }

  void _notifyActivityHistoryChanged() {
    notifyListeners();
  }

  void _upsertSyncDebugSnapshot(LocalPendingRunActivity record) {
    final snapshot = RunSyncDebugSnapshot(
      ownerUid: record.ownerUid,
      clientRunSessionId: record.clientRunSessionId,
      syncState: record.syncState,
      syncAccepted: record.syncAccepted,
      syncAttemptCount: record.syncAttemptCount,
      activityId: record.result.activityId,
      lastSyncAttemptedAt: record.lastSyncAttemptedAt,
      lastSyncFailureCode: record.lastSyncFailureCode,
      lastSyncFailureMessage: record.lastSyncFailureMessage,
    );
    _syncDebugSnapshots.removeWhere(
      (item) =>
          item.ownerUid == snapshot.ownerUid &&
          item.clientRunSessionId == snapshot.clientRunSessionId,
    );
    _syncDebugSnapshots.insert(0, snapshot);
    assert(() {
      debugPrint(
        'Runiac run sync ${snapshot.clientRunSessionId}: '
        '${snapshot.syncState.name}'
        '${snapshot.lastSyncFailureCode == null ? '' : ' '
                  '(${snapshot.lastSyncFailureCode})'}',
      );
      return true;
    }());
  }
}

class CurrentSessionActivityHistoryScope
    extends InheritedNotifier<CurrentSessionActivityHistoryStore> {
  const CurrentSessionActivityHistoryScope({
    required CurrentSessionActivityHistoryStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static CurrentSessionActivityHistoryStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          CurrentSessionActivityHistoryScope
        >()
        ?.notifier;
  }

  static CurrentSessionActivityHistoryStore of(BuildContext context) {
    final store = maybeOf(context);
    assert(store != null, 'No CurrentSessionActivityHistoryScope found.');
    return store!;
  }
}
