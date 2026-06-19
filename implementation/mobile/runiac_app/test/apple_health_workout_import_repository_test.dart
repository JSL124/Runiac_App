import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/apple_health_workout_import_repository.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('runiac/healthkit_import');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('AppleHealthWorkoutImportRepository', () {
    test(
      'maps valid running workout payload from fake MethodChannel',
      () async {
        Map<dynamic, dynamic>? capturedArgs;
        messenger.setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'listRunningWorkouts');
          capturedArgs = call.arguments as Map<dynamic, dynamic>;
          return {
            'status': 'available',
            'workouts': [
              _workout(
                uuid: 'hk-run-1',
                durationSeconds: 1800,
                distanceMeters: 4500.4,
                activeEnergyKcal: 321.6,
                averageHeartRateBpm: 151.4,
                maxHeartRateBpm: 176.6,
              ),
            ],
          };
        });

        final candidates = await const AppleHealthWorkoutImportRepository()
            .listRecentRunningWorkouts();

        expect(capturedArgs, {'lookbackDays': 30, 'limit': 20});
        expect(candidates, hasLength(1));
        expect(() => candidates.add(candidates.single), throwsUnsupportedError);

        final candidate = candidates.single;
        expect(candidate.externalId, 'appleHealth:hk-run-1');
        expect(candidate.sourceType, RunSourceType.appleHealth);
        expect(candidate.sourceLabel, 'Apple Health');
        expect(
          candidate.startedAt,
          DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true),
        );
        expect(
          candidate.endedAt,
          DateTime.fromMillisecondsSinceEpoch(1801000, isUtc: true),
        );
        expect(candidate.durationSeconds, 1800);
        expect(candidate.distanceMeters, 4500);
        expect(candidate.avgPaceSecondsPerKm, 400);
        expect(candidate.calories, 322);
        expect(
          candidate.heartRateAvailability,
          HeartRateAvailability.available,
        );
        expect(candidate.avgHeartRateBpm, 151);
        expect(candidate.maxHeartRateBpm, 177);
        expect(candidate.avgHeartRateDisplay, '151 bpm');
      },
    );

    test('maps missing heart rate to unavailable display state', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return {
          'status': 'available',
          'workouts': [_workout(uuid: 'hk-run-no-hr')],
        };
      });

      final candidates = await const AppleHealthWorkoutImportRepository()
          .listRecentRunningWorkouts();

      expect(candidates, hasLength(1));
      expect(
        candidates.single.heartRateAvailability,
        HeartRateAvailability.unavailableNotShared,
      );
      expect(candidates.single.avgHeartRateBpm, isNull);
      expect(candidates.single.maxHeartRateBpm, isNull);
      expect(candidates.single.avgHeartRateDisplay, '--');
    });

    test('skips non-running workout payloads', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return {
          'status': 'available',
          'workouts': [
            _workout(uuid: 'hk-walk-1', activityType: 'walking'),
            _workout(uuid: 'hk-run-2'),
          ],
        };
      });

      final candidates = await const AppleHealthWorkoutImportRepository()
          .listRecentRunningWorkouts();

      expect(candidates.map((candidate) => candidate.externalId), [
        'appleHealth:hk-run-2',
      ]);
    });

    test('skips malformed or unsafe workout payloads', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return {
          'status': 'available',
          'workouts': [
            {
              'activityType': 'running',
              'startDateMillis': 1000,
              'endDateMillis': 1801000,
              'durationSeconds': 1800,
              'distanceMeters': 4500,
            },
            _workout(uuid: ''),
            {
              'uuid': 'hk-malformed-types',
              'activityType': 'running',
              'startDateMillis': '1000',
              'endDateMillis': 1801000,
              'durationSeconds': 1800,
              'distanceMeters': 4500,
            },
            _workout(uuid: 'hk-duration-zero', durationSeconds: 0),
            _workout(uuid: 'hk-distance-zero', distanceMeters: 0),
            _workout(
              uuid: 'hk-invalid-date-order',
              startDateMillis: 2000,
              endDateMillis: 1000,
            ),
            _workout(uuid: 'hk-valid'),
          ],
        };
      });

      final candidates = await const AppleHealthWorkoutImportRepository()
          .listRecentRunningWorkouts();

      expect(candidates.map((candidate) => candidate.externalId), [
        'appleHealth:hk-valid',
      ]);
    });

    test('failure statuses do not throw and return empty results', () async {
      for (final status in [
        'permissionDenied',
        'unavailable',
        'protectedDataUnavailable',
        'noData',
      ]) {
        messenger.setMockMethodCallHandler(channel, (call) async {
          return {
            'status': status,
            'workouts': [_workout(uuid: status)],
          };
        });

        final candidates = await const AppleHealthWorkoutImportRepository()
            .listRecentRunningWorkouts();
        final candidate = await const AppleHealthWorkoutImportRepository()
            .findByExternalId('appleHealth:$status');

        expect(candidates, isEmpty, reason: status);
        expect(candidate, isNull, reason: status);
      }
    });

    test(
      'findByExternalId returns matching candidate from channel payload',
      () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          return {
            'status': 'available',
            'workouts': [
              _workout(uuid: 'hk-run-3'),
              _workout(uuid: 'hk-run-4'),
            ],
          };
        });

        final candidate = await const AppleHealthWorkoutImportRepository()
            .findByExternalId('appleHealth:hk-run-4');

        expect(candidate?.externalId, 'appleHealth:hk-run-4');
      },
    );

    test(
      'uses only import listing channel without backend progression fields',
      () async {
        final calls = <MethodCall>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          expect(call.method, 'listRunningWorkouts');
          expect(call.arguments, {'lookbackDays': 30, 'limit': 20});
          expect(
            (call.arguments as Map<dynamic, dynamic>).keys,
            isNot(contains('xp')),
          );
          expect(
            (call.arguments as Map<dynamic, dynamic>).keys,
            isNot(contains('leaderboard')),
          );
          return {'status': 'available', 'workouts': <Map<String, Object?>>[]};
        });

        await const AppleHealthWorkoutImportRepository()
            .listRecentRunningWorkouts();

        expect(calls, hasLength(1));
      },
    );
  });
}

Map<String, Object?> _workout({
  required String uuid,
  String activityType = 'running',
  int startDateMillis = 1000,
  int endDateMillis = 1801000,
  int durationSeconds = 1800,
  num distanceMeters = 4500,
  num? activeEnergyKcal,
  num? averageHeartRateBpm,
  num? maxHeartRateBpm,
}) {
  return {
    'uuid': uuid,
    'activityType': activityType,
    'sourceName': 'Apple Health',
    'startDateMillis': startDateMillis,
    'endDateMillis': endDateMillis,
    'durationSeconds': durationSeconds,
    'distanceMeters': distanceMeters,
    'activeEnergyKcal': activeEnergyKcal,
    'averageHeartRateBpm': averageHeartRateBpm,
    'maxHeartRateBpm': maxHeartRateBpm,
  };
}
