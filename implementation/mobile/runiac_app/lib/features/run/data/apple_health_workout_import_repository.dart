import '../domain/models/imported_workout_candidate.dart';
import '../domain/repositories/health_workout_import_repository.dart';

class AppleHealthWorkoutImportRepository
    implements HealthWorkoutImportRepository {
  const AppleHealthWorkoutImportRepository();

  @override
  Future<List<ImportedWorkoutCandidate>> listRecentRunningWorkouts() async {
    return List<ImportedWorkoutCandidate>.unmodifiable(
      const <ImportedWorkoutCandidate>[],
    );
  }

  @override
  Future<ImportedWorkoutCandidate?> findByExternalId(String externalId) async {
    return null;
  }
}
