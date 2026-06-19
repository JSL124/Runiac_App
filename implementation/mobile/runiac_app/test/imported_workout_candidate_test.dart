import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/imported_workout_candidate.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';

void main() {
  group('ImportedWorkoutCandidate', () {
    test('exposes source and heart rate display semantics', () {
      final candidate = ImportedWorkoutCandidate(
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
        importedAt: DateTime.utc(2026, 6, 19, 7),
      );

      expect(candidate.sourceLabel, 'Apple Health');
      expect(candidate.avgHeartRateDisplay, '154 bpm');
      expect(candidate.heartRateHelperText, isNull);
    });

    test('without shared heart rate is truthful', () {
      final candidate = ImportedWorkoutCandidate(
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
        importedAt: DateTime.utc(2026, 6, 19, 7),
      );

      expect(candidate.sourceLabel, 'Health Connect');
      expect(candidate.avgHeartRateDisplay, '--');
      expect(
        candidate.heartRateHelperText,
        contains('Heart rate was not shared'),
      );
    });

    test('rejects inconsistent heart rate availability', () {
      expect(
        () => ImportedWorkoutCandidate(
          externalId: 'invalid-available-hr',
          sourceType: RunSourceType.appleHealth,
          activityType: ImportedWorkoutActivityType.running,
          startedAt: DateTime.utc(2026, 6, 15, 6, 30),
          endedAt: DateTime.utc(2026, 6, 15, 7, 5),
          durationSeconds: 2100,
          distanceMeters: 5000,
          avgPaceSecondsPerKm: 420,
          calories: 340,
          heartRateAvailability: HeartRateAvailability.available,
          importedAt: DateTime.utc(2026, 6, 19, 7),
        ),
        throwsAssertionError,
      );

      expect(
        () => ImportedWorkoutCandidate(
          externalId: 'invalid-unavailable-hr',
          sourceType: RunSourceType.healthConnect,
          activityType: ImportedWorkoutActivityType.running,
          startedAt: DateTime.utc(2026, 6, 15, 6, 30),
          endedAt: DateTime.utc(2026, 6, 15, 7, 5),
          durationSeconds: 2100,
          distanceMeters: 5000,
          avgPaceSecondsPerKm: 420,
          avgHeartRateBpm: 154,
          maxHeartRateBpm: 171,
          calories: 340,
          heartRateAvailability: HeartRateAvailability.unavailableNotShared,
          importedAt: DateTime.utc(2026, 6, 19, 7),
        ),
        throwsAssertionError,
      );
    });
  });
}
