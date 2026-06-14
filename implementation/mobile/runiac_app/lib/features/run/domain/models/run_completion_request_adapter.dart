import 'local_run_completion_payload.dart';

class RunCompletionRequestAdapter {
  const RunCompletionRequestAdapter._();

  static Map<String, Object?> toBackendRequest(
    LocalRunCompletionPayload payload,
  ) {
    return <String, Object?>{
      'clientRunSessionId': payload.clientRunSessionId,
      'startedAt': _toBackendIsoString(payload.startedAt),
      'completedAt': _toBackendIsoString(payload.completedAt),
      'durationSeconds': payload.durationSeconds,
      'distanceMeters': payload.distanceMeters,
      'avgPaceSecondsPerKm': payload.avgPaceSecondsPerKm,
      'source': 'mobile',
      'routePrivacy': payload.routePrivacy,
      if (payload.routeLabel != null) 'routeLabel': payload.routeLabel,
      if (payload.clientAppVersion != null)
        'clientAppVersion': payload.clientAppVersion,
    };
  }

  static String _toBackendIsoString(DateTime value) {
    return value.toUtc().toIso8601String();
  }
}
