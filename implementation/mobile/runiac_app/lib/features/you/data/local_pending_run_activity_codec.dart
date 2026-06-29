part of 'local_pending_run_activity_store.dart';

Map<String, Object?> _localPendingRunActivityToJson(
  LocalPendingRunActivity activity,
) {
  return <String, Object?>{
    'ownerUid': activity.ownerUid,
    'clientRunSessionId': activity.clientRunSessionId,
    'activityId': activity.result.activityId,
    'summaryId': activity.result.summaryId,
    'progressionEventId': activity.result.progressionEventId,
    'validationStatus': activity.result.validationStatus,
    'message': activity.result.message,
    'syncAccepted': activity.syncAccepted,
    'summary': <String, Object?>{
      'title': activity.result.summary.title,
      'dateLabel': activity.result.summary.dateLabel,
      'timeLabel': activity.result.summary.timeLabel,
      'distanceKm': activity.result.summary.distanceKm,
      'avgPace': activity.result.summary.avgPace,
      'duration': activity.result.summary.duration,
      'avgHeartRate': activity.result.summary.avgHeartRate,
      'calories': activity.result.summary.calories,
      'routeName': activity.result.summary.routeName,
      'hasSufficientData': activity.result.summary.hasSufficientData,
      'route': _routeToJson(activity.result.summary.route),
    },
    'payload': <String, Object?>{
      'clientRunSessionId': activity.payload.clientRunSessionId,
      'startedAt': activity.payload.startedAt.toUtc().toIso8601String(),
      'completedAt': activity.payload.completedAt.toUtc().toIso8601String(),
      'durationSeconds': activity.payload.durationSeconds,
      'distanceMeters': activity.payload.distanceMeters,
      'avgPaceSecondsPerKm': activity.payload.avgPaceSecondsPerKm,
      'source': activity.payload.source,
      'routePrivacy': activity.payload.routePrivacy,
      if (activity.payload.routeLabel != null)
        'routeLabel': activity.payload.routeLabel,
      if (activity.payload.clientAppVersion != null)
        'clientAppVersion': activity.payload.clientAppVersion,
    },
  };
}

LocalPendingRunActivity? _localPendingRunActivityFromJson(
  Map<String, Object?> source,
) {
  final clientRunSessionId = _readString(source, 'clientRunSessionId');
  final ownerUid = _readString(source, 'ownerUid');
  final summary = _readMap(source, 'summary');
  final payload = _readMap(source, 'payload');
  if (ownerUid == null ||
      clientRunSessionId == null ||
      summary == null ||
      payload == null) {
    return null;
  }

  return LocalPendingRunActivity(
    ownerUid: ownerUid,
    clientRunSessionId: clientRunSessionId,
    result: CompleteRunResult(
      clientRunSessionId: clientRunSessionId,
      activityId:
          _readString(source, 'activityId') ?? 'local-$clientRunSessionId',
      summaryId:
          _readString(source, 'summaryId') ??
          'local-summary-$clientRunSessionId',
      progressionEventId:
          _readString(source, 'progressionEventId') ??
          'local-progression-$clientRunSessionId',
      validationStatus: _readString(source, 'validationStatus') ?? 'validated',
      summary: RunSummarySnapshot(
        title: _readString(summary, 'title') ?? 'Completed Run',
        dateLabel: _readString(summary, 'dateLabel') ?? 'Today',
        timeLabel: _readString(summary, 'timeLabel') ?? '--',
        distanceKm: _readString(summary, 'distanceKm') ?? '0.00',
        avgPace: _readString(summary, 'avgPace') ?? '--',
        duration: _readString(summary, 'duration') ?? '--',
        avgHeartRate: _readString(summary, 'avgHeartRate') ?? '--',
        calories: _readString(summary, 'calories') ?? '--',
        routeName: _readString(summary, 'routeName') ?? 'Private route',
        hasSufficientData: _readBool(summary, 'hasSufficientData') ?? false,
        route: _routeFromJson(_readMap(summary, 'route')),
      ),
      progressionDisplay: const ProgressionDisplayModel(
        xpDelta: 0,
        countsTowardLeaderboard: false,
        status: 'deferred',
        reason: 'progression_formula_deferred',
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
      message: _readString(source, 'message') ?? 'Saved locally.',
    ),
    payload: _payloadFromJson(payload, clientRunSessionId),
    syncAccepted: _readBool(source, 'syncAccepted') ?? false,
  );
}

LocalRunCompletionPayload _payloadFromJson(
  Map<String, Object?> source,
  String clientRunSessionId,
) {
  return LocalRunCompletionPayload(
    clientRunSessionId:
        _readString(source, 'clientRunSessionId') ?? clientRunSessionId,
    startedAt:
        _readDate(source, 'startedAt') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    completedAt:
        _readDate(source, 'completedAt') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    durationSeconds: _readInt(source, 'durationSeconds') ?? 0,
    distanceMeters: _readInt(source, 'distanceMeters') ?? 0,
    avgPaceSecondsPerKm: _readInt(source, 'avgPaceSecondsPerKm') ?? 0,
    source: _readString(source, 'source') ?? 'mobile',
    routePrivacy: _readString(source, 'routePrivacy') ?? 'private',
    routeLabel: _readString(source, 'routeLabel'),
    clientAppVersion: _readString(source, 'clientAppVersion'),
  );
}

Map<String, Object?> _routeToJson(RunRouteSnapshot route) {
  return <String, Object?>{
    'segments': [
      for (final segment in route.segments)
        [for (final sample in segment) _locationSampleToJson(sample)],
    ],
    if (route.lastKnownLocation != null)
      'lastKnownLocation': _locationSampleToJson(route.lastKnownLocation!),
  };
}

Map<String, Object?> _locationSampleToJson(RunLocationSample sample) {
  return <String, Object?>{
    'recordedAt': sample.recordedAt.toUtc().toIso8601String(),
    'latitude': sample.latitude,
    'longitude': sample.longitude,
    if (sample.altitudeMeters != null) 'altitudeMeters': sample.altitudeMeters,
    if (sample.horizontalAccuracyMeters != null)
      'horizontalAccuracyMeters': sample.horizontalAccuracyMeters,
    if (sample.speedMetersPerSecond != null)
      'speedMetersPerSecond': sample.speedMetersPerSecond,
  };
}

RunRouteSnapshot _routeFromJson(Map<String, Object?>? source) {
  if (source == null) {
    return RunRouteSnapshot.empty;
  }

  final segments = <List<RunLocationSample>>[];
  for (final rawSegment in _readList(source, 'segments')) {
    if (rawSegment is! List) {
      continue;
    }
    final segment = <RunLocationSample>[];
    for (final rawSample in rawSegment) {
      final sample = _locationSampleFromJson(_readObjectMap(rawSample));
      if (sample != null) {
        segment.add(sample);
      }
    }
    if (segment.isNotEmpty) {
      segments.add(segment);
    }
  }

  final lastKnownLocation = _locationSampleFromJson(
    _readMap(source, 'lastKnownLocation'),
  );
  return RunRouteSnapshot(
    segments: segments,
    lastKnownLocation: lastKnownLocation ?? _lastRoutePoint(segments),
  );
}

RunLocationSample? _locationSampleFromJson(Map<String, Object?>? source) {
  if (source == null) {
    return null;
  }
  final recordedAt = _readDate(source, 'recordedAt');
  final latitude = _readDouble(source, 'latitude');
  final longitude = _readDouble(source, 'longitude');
  if (recordedAt == null || latitude == null || longitude == null) {
    return null;
  }
  return RunLocationSample(
    recordedAt: recordedAt,
    latitude: latitude,
    longitude: longitude,
    altitudeMeters: _readDouble(source, 'altitudeMeters'),
    horizontalAccuracyMeters: _readDouble(source, 'horizontalAccuracyMeters'),
    speedMetersPerSecond: _readDouble(source, 'speedMetersPerSecond'),
  );
}

RunLocationSample? _lastRoutePoint(List<List<RunLocationSample>> segments) {
  for (final segment in segments.reversed) {
    if (segment.isNotEmpty) {
      return segment.last;
    }
  }
  return null;
}

Map<String, Object?>? _readObjectMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

Map<String, Object?>? _readMap(Map<String, Object?> source, String key) {
  return _readObjectMap(source[key]);
}

List<Object?> _readList(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  return const <Object?>[];
}

String? _readString(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}

int? _readInt(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is int) {
    return value;
  }
  if (value is num && value.isFinite) {
    return value.round();
  }
  return null;
}

double? _readDouble(Map<String, Object?> source, String key) {
  final value = source[key];
  if (value is num && value.isFinite) {
    return value.toDouble();
  }
  return null;
}

bool? _readBool(Map<String, Object?> source, String key) {
  final value = source[key];
  return value is bool ? value : null;
}

DateTime? _readDate(Map<String, Object?> source, String key) {
  final value = _readString(source, key);
  return value == null ? null : DateTime.tryParse(value);
}
