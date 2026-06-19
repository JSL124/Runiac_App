import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/apple_health_workout_import_repository.dart';
import 'package:runiac_app/features/run/domain/models/imported_workout_candidate.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';

void main() {
  group('AppleHealthWorkoutImportRepository', () {
    test(
      'returns no candidates until HealthKit reading is implemented',
      () async {
        final candidates = await const AppleHealthWorkoutImportRepository()
            .listRecentRunningWorkouts();

        expect(candidates, isEmpty);
        expect(() => candidates.add(_candidate()), throwsUnsupportedError);
      },
    );

    test('maps unavailable external ids to null', () async {
      final candidate = await const AppleHealthWorkoutImportRepository()
          .findByExternalId('apple-health-run-2026-06-15');

      expect(candidate, isNull);
    });
  });
}

ImportedWorkoutCandidate _candidate() {
  return ImportedWorkoutCandidate(
    externalId: 'apple-health-run-2026-06-15',
    sourceType: RunSourceType.appleHealth,
    activityType: ImportedWorkoutActivityType.running,
    startedAt: DateTime.utc(2026, 6, 15, 6, 30),
    endedAt: DateTime.utc(2026, 6, 15, 7, 5),
    durationSeconds: 2100,
    distanceMeters: 5000,
    avgPaceSecondsPerKm: 420,
    calories: 340,
    heartRateAvailability: HeartRateAvailability.unavailableNotShared,
    importedAt: DateTime.utc(2026, 6, 19, 7),
  );
}
