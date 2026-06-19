import '../domain/models/imported_workout_candidate.dart';
import '../domain/models/run_source_display.dart';
import '../domain/repositories/health_workout_import_repository.dart';

class MockHealthWorkoutImportRepository
    implements HealthWorkoutImportRepository {
  const MockHealthWorkoutImportRepository();

  static final DateTime _importedAt = DateTime.utc(2026, 6, 19, 7);

  static final List<ImportedWorkoutCandidate> _candidates = [
    ImportedWorkoutCandidate(
      externalId: 'apple-health-run-2026-06-15',
      sourceType: RunSourceType.appleHealth,
      activityType: ImportedWorkoutActivityType.running,
      startedAt: DateTime.utc(2026, 6, 15, 6, 30),
      endedAt: DateTime.utc(2026, 6, 15, 7, 5),
      durationSeconds: 2100,
      distanceMeters: 5000,
      avgPaceSecondsPerKm: 420,
      avgHeartRateBpm: 154,
      maxHeartRateBpm: 171,
      calories: 340,
      heartRateAvailability: HeartRateAvailability.available,
      importedAt: _importedAt,
    ),
    ImportedWorkoutCandidate(
      externalId: 'health-connect-run-2026-06-13',
      sourceType: RunSourceType.healthConnect,
      activityType: ImportedWorkoutActivityType.running,
      startedAt: DateTime.utc(2026, 6, 13, 8),
      endedAt: DateTime.utc(2026, 6, 13, 8, 28),
      durationSeconds: 1680,
      distanceMeters: 3600,
      avgPaceSecondsPerKm: 467,
      calories: 240,
      heartRateAvailability: HeartRateAvailability.unavailableNotShared,
      importedAt: _importedAt,
    ),
    ImportedWorkoutCandidate(
      externalId: 'garmin-via-health-run-2026-06-10',
      sourceType: RunSourceType.garminViaHealth,
      activityType: ImportedWorkoutActivityType.running,
      startedAt: DateTime.utc(2026, 6, 10, 6, 45),
      endedAt: DateTime.utc(2026, 6, 10, 7, 23),
      durationSeconds: 2280,
      distanceMeters: 5200,
      avgPaceSecondsPerKm: 438,
      avgHeartRateBpm: 148,
      maxHeartRateBpm: 166,
      calories: 355,
      heartRateAvailability: HeartRateAvailability.available,
      importedAt: _importedAt,
    ),
  ];

  @override
  Future<List<ImportedWorkoutCandidate>> listRecentRunningWorkouts() async {
    return List<ImportedWorkoutCandidate>.unmodifiable(_candidates);
  }

  @override
  Future<ImportedWorkoutCandidate?> findByExternalId(String externalId) async {
    for (final candidate in _candidates) {
      if (candidate.externalId == externalId) {
        return candidate;
      }
    }
    return null;
  }
}
