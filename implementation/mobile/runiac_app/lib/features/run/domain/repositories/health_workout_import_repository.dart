import '../models/imported_workout_candidate.dart';

abstract class HealthWorkoutImportRepository {
  Future<List<ImportedWorkoutCandidate>> listRecentRunningWorkouts();

  Future<ImportedWorkoutCandidate?> findByExternalId(String externalId);
}
