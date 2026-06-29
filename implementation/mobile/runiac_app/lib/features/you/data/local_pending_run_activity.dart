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

  LocalPendingRunActivity copyWith({bool? syncAccepted}) {
    return LocalPendingRunActivity(
      ownerUid: ownerUid,
      clientRunSessionId: clientRunSessionId,
      result: result,
      payload: payload,
      syncAccepted: syncAccepted ?? this.syncAccepted,
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
