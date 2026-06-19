import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/mock_health_workout_import_repository.dart';
import 'package:runiac_app/features/run/domain/models/imported_workout_candidate.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';

void main() {
  group('MockHealthWorkoutImportRepository', () {
    test('returns deterministic recent running workouts', () async {
      final candidates = await const MockHealthWorkoutImportRepository()
          .listRecentRunningWorkouts();

      expect(candidates, hasLength(3));
      expect(candidates.map((candidate) => candidate.externalId), [
        'apple-health-run-2026-06-15',
        'health-connect-run-2026-06-13',
        'garmin-via-health-run-2026-06-10',
      ]);
      expect(
        candidates.map((candidate) => candidate.externalId).toSet(),
        hasLength(3),
      );
      expect(
        candidates.every(
          (candidate) =>
              candidate.activityType == ImportedWorkoutActivityType.running,
        ),
        isTrue,
      );
    });

    test('models truthful source and heart rate availability', () async {
      final repository = const MockHealthWorkoutImportRepository();
      final apple = await repository.findByExternalId(
        'apple-health-run-2026-06-15',
      );
      final healthConnect = await repository.findByExternalId(
        'health-connect-run-2026-06-13',
      );
      final garmin = await repository.findByExternalId(
        'garmin-via-health-run-2026-06-10',
      );

      expect(apple?.sourceLabel, 'Apple Health');
      expect(apple?.heartRateAvailability, HeartRateAvailability.available);
      expect(apple?.avgHeartRateBpm, 154);
      expect(apple?.maxHeartRateBpm, 171);

      expect(healthConnect?.sourceLabel, 'Health Connect');
      expect(
        healthConnect?.heartRateAvailability,
        HeartRateAvailability.unavailableNotShared,
      );
      expect(healthConnect?.avgHeartRateBpm, isNull);
      expect(healthConnect?.maxHeartRateBpm, isNull);
      expect(healthConnect?.avgHeartRateDisplay, '--');

      expect(garmin?.sourceType, RunSourceType.garminViaHealth);
      expect(garmin?.sourceLabel, 'Garmin via Health');
      expect(garmin?.avgHeartRateBpm, 148);
      expect(garmin?.maxHeartRateBpm, 166);
      expect(await repository.findByExternalId('missing'), isNull);
    });

    test('keeps import candidates local and display-only', () async {
      final repository = const MockHealthWorkoutImportRepository();
      final candidates = await repository.listRecentRunningWorkouts();

      for (final candidate in candidates) {
        expect(candidate.externalId, isNotEmpty);
        expect(candidate.sourceLabel, isNotEmpty);
        expect(candidate.distanceMeters, greaterThan(0));
        expect(candidate.durationSeconds, greaterThan(0));
        expect(candidate.calories, greaterThanOrEqualTo(0));
      }
    });
  });
}
