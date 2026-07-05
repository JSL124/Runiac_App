import 'cadence_analysis_series.dart';
import 'local_run_completion_payload.dart';

class RunCompletionRequestAdapter {
  const RunCompletionRequestAdapter._();

  static const int _maxBackendCadenceAnalysisSamples = 720;

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
      if (payload.cadenceAnalysisSeries case final cadenceAnalysisSeries?
          when cadenceAnalysisSeries.validAcceptedSamples.isNotEmpty)
        'cadenceAnalysisSeries': _cadenceAnalysisSeriesToBackendMap(
          cadenceAnalysisSeries,
        ),
    };
  }

  static Map<String, Object?> _cadenceAnalysisSeriesToBackendMap(
    CadenceAnalysisSeries cadenceAnalysisSeries,
  ) {
    return <String, Object?>{
      'source': cadenceAnalysisSeries.source.name,
      'confidence': cadenceAnalysisSeries.confidence.name,
      'samples': [
        for (final sample in _cadenceSamplesForBackend(
          cadenceAnalysisSeries.validAcceptedSamples,
        ))
          <String, Object?>{
            'elapsedSeconds': sample.elapsedSeconds,
            'cadenceSpm': sample.cadenceSpm,
            'status': sample.status.name,
            if (sample.rejectionReason !=
                CadenceAnalysisSampleRejectionReason.none)
              'rejectionReason': sample.rejectionReason.name,
          },
      ],
    };
  }

  static List<CadenceAnalysisSample> _cadenceSamplesForBackend(
    List<CadenceAnalysisSample> samples,
  ) {
    if (samples.length <= _maxBackendCadenceAnalysisSamples) {
      return samples;
    }
    return <CadenceAnalysisSample>[
      for (var index = 0; index < _maxBackendCadenceAnalysisSamples; index += 1)
        samples[(_sourceCadenceSampleIndex(index, samples.length))],
    ];
  }

  static int _sourceCadenceSampleIndex(int targetIndex, int sourceLength) {
    if (_maxBackendCadenceAnalysisSamples == 1) {
      return 0;
    }
    return (targetIndex *
            (sourceLength - 1) /
            (_maxBackendCadenceAnalysisSamples - 1))
        .round();
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
