import 'package:flutter/services.dart';

import '../domain/models/imported_workout_candidate.dart';
import '../domain/models/run_source_display.dart';
import '../domain/repositories/health_workout_import_repository.dart';

class AppleHealthWorkoutImportRepository
    implements HealthWorkoutImportRepository {
  const AppleHealthWorkoutImportRepository();

  static const MethodChannel _channel = MethodChannel(
    'runiac/healthkit_import',
  );

  @override
  Future<List<ImportedWorkoutCandidate>> listRecentRunningWorkouts() async {
    final response = await _channel.invokeMethod<Object?>(
      'listRunningWorkouts',
      const <String, int>{'lookbackDays': 30, 'limit': 20},
    );

    if (response is! Map) {
      return List<ImportedWorkoutCandidate>.unmodifiable(
        const <ImportedWorkoutCandidate>[],
      );
    }

    if (response['status'] != 'available') {
      return List<ImportedWorkoutCandidate>.unmodifiable(
        const <ImportedWorkoutCandidate>[],
      );
    }

    final workouts = response['workouts'];
    if (workouts is! List) {
      return List<ImportedWorkoutCandidate>.unmodifiable(
        const <ImportedWorkoutCandidate>[],
      );
    }

    final importedAt = DateTime.now().toUtc();
    final candidates = <ImportedWorkoutCandidate>[];
    for (final workout in workouts) {
      if (workout is! Map) {
        continue;
      }
      final candidate = _candidateFromWorkout(workout, importedAt);
      if (candidate != null) {
        candidates.add(candidate);
      }
    }

    return List<ImportedWorkoutCandidate>.unmodifiable(candidates);
  }

  @override
  Future<ImportedWorkoutCandidate?> findByExternalId(String externalId) async {
    final candidates = await listRecentRunningWorkouts();
    for (final candidate in candidates) {
      if (candidate.externalId == externalId) {
        return candidate;
      }
    }
    return null;
  }

  ImportedWorkoutCandidate? _candidateFromWorkout(
    Map<dynamic, dynamic> workout,
    DateTime importedAt,
  ) {
    final uuid = _stringField(workout, 'uuid');
    if (uuid == null || _stringField(workout, 'activityType') != 'running') {
      return null;
    }

    final startDateMillis = _intField(workout, 'startDateMillis');
    final endDateMillis = _intField(workout, 'endDateMillis');
    if (startDateMillis == null || endDateMillis == null) {
      return null;
    }

    final startedAt = DateTime.fromMillisecondsSinceEpoch(
      startDateMillis,
      isUtc: true,
    );
    final endedAt = DateTime.fromMillisecondsSinceEpoch(
      endDateMillis,
      isUtc: true,
    );
    if (!endedAt.isAfter(startedAt)) {
      return null;
    }

    final durationSeconds = _positiveIntField(workout, 'durationSeconds');
    final distanceValue = _finiteNumField(workout, 'distanceMeters');
    if (durationSeconds == null || distanceValue == null) {
      return null;
    }

    final distanceMeters = distanceValue.round();
    if (distanceMeters <= 0) {
      return null;
    }

    final avgPaceSecondsPerKm = (durationSeconds / (distanceMeters / 1000))
        .round();
    if (avgPaceSecondsPerKm <= 0) {
      return null;
    }

    final avgHeartRate = _positiveRoundedField(workout, 'averageHeartRateBpm');
    final maxHeartRate = avgHeartRate == null
        ? null
        : _positiveRoundedField(workout, 'maxHeartRateBpm');

    return ImportedWorkoutCandidate(
      externalId: 'appleHealth:$uuid',
      sourceType: RunSourceType.appleHealth,
      activityType: ImportedWorkoutActivityType.running,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      avgPaceSecondsPerKm: avgPaceSecondsPerKm,
      calories: _nonnegativeRoundedField(workout, 'activeEnergyKcal') ?? 0,
      heartRateAvailability: avgHeartRate == null
          ? HeartRateAvailability.unavailableNotShared
          : HeartRateAvailability.available,
      importedAt: importedAt,
      avgHeartRateBpm: avgHeartRate,
      maxHeartRateBpm: maxHeartRate,
    );
  }

  String? _stringField(Map<dynamic, dynamic> map, String key) {
    final value = map[key];
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int? _intField(Map<dynamic, dynamic> map, String key) {
    final value = _finiteNumField(map, key);
    if (value == null) {
      return null;
    }
    return value.round();
  }

  int? _positiveIntField(Map<dynamic, dynamic> map, String key) {
    final value = _intField(map, key);
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  num? _finiteNumField(Map<dynamic, dynamic> map, String key) {
    final value = map[key];
    if (value is! num || !value.isFinite) {
      return null;
    }
    return value;
  }

  int? _positiveRoundedField(Map<dynamic, dynamic> map, String key) {
    final value = _finiteNumField(map, key);
    if (value == null || value <= 0) {
      return null;
    }
    final rounded = value.round();
    return rounded <= 0 ? null : rounded;
  }

  int? _nonnegativeRoundedField(Map<dynamic, dynamic> map, String key) {
    final value = _finiteNumField(map, key);
    if (value == null || value < 0) {
      return null;
    }
    return value.round();
  }
}
