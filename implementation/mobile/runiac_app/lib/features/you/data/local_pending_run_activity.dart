part of 'local_pending_run_activity_store.dart';

class LocalPendingRunActivity {
  const LocalPendingRunActivity({
    required this.ownerUid,
    required this.clientRunSessionId,
    required this.result,
    required this.payload,
    this.syncAccepted = false,
  });

  factory LocalPendingRunActivity.fromCompletedRun({
    required String ownerUid,
    required CompleteRunResult result,
    required LocalRunCompletionPayload payload,
  }) {
    return LocalPendingRunActivity(
      ownerUid: ownerUid,
      clientRunSessionId: payload.clientRunSessionId,
      result: result.copyWith(clientRunSessionId: payload.clientRunSessionId),
      payload: payload,
    );
  }

  final String ownerUid;
  final String clientRunSessionId;
  final CompleteRunResult result;
  final LocalRunCompletionPayload payload;
  final bool syncAccepted;

  LocalPendingRunActivity copyWith({
    CompleteRunResult? result,
    bool? syncAccepted,
  }) {
    return LocalPendingRunActivity(
      ownerUid: ownerUid,
      clientRunSessionId: clientRunSessionId,
      result: result ?? this.result,
      payload: payload,
      syncAccepted: syncAccepted ?? this.syncAccepted,
    );
  }

  LocalPendingRunActivity mergeRemoteCompletion(
    CompleteRunResult remoteResult, {
    bool? syncAccepted,
  }) {
    return copyWith(
      result: result.copyWith(
        clientRunSessionId: clientRunSessionId,
        activityId: remoteResult.activityId,
        summaryId: remoteResult.summaryId,
        progressionEventId: remoteResult.progressionEventId,
        validationStatus: remoteResult.validationStatus,
        progressionDisplay: remoteResult.progressionDisplay,
        xpUpdate: remoteResult.xpUpdate,
        message: remoteResult.message,
      ),
      syncAccepted: syncAccepted,
    );
  }

  String encode() => jsonEncode(_localPendingRunActivityToJson(this));

  static LocalPendingRunActivity? tryDecode(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      return _localPendingRunActivityFromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
