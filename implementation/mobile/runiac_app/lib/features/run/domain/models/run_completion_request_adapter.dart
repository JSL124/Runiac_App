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
      'activeDurationSeconds': payload.activeDurationSeconds,
      'elapsedWallSeconds': payload.elapsedWallSeconds,
      'pausedDurationSeconds': payload.pausedDurationSeconds,
      'distanceMeters': payload.distanceMeters,
      'avgPaceSecondsPerKm': payload.avgPaceSecondsPerKm,
      'source': 'mobile',
      'routePrivacy': payload.routePrivacy,
      if (payload.userConfirmedLowDataSave) 'userConfirmedLowDataSave': true,
      if (payload.routeLabel != null) 'routeLabel': payload.routeLabel,
      if (payload.clientAppVersion != null)
        'clientAppVersion': payload.clientAppVersion,
    };
  }

  static String _toBackendIsoString(DateTime value) {
    final utc = value.toUtc();
    final millisecondDate = DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
      utc.millisecond,
    );
    return millisecondDate.toIso8601String();
  }
}
