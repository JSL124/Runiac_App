import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/services/local_run_tracking_session.dart';
import 'package:runiac_app/features/run/domain/services/run_distance_calculator.dart';

void main() {
  RunLocationSample sampleAt(
    DateTime startedAt,
    int seconds, {
    required double latitude,
    required double longitude,
    double? horizontalAccuracyMeters,
  }) {
    return RunLocationSample(
      recordedAt: startedAt.add(Duration(seconds: seconds)),
      latitude: latitude,
      longitude: longitude,
      horizontalAccuracyMeters: horizontalAccuracyMeters,
    );
  }

  group('RunDistanceCalculator', () {
    test('returns zero meters for the same coordinate', () {
      final calculator = RunDistanceCalculator();
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final first = sampleAt(
        startedAt,
        0,
        latitude: 1.300000,
        longitude: 103.800000,
      );
      final second = sampleAt(
        startedAt,
        30,
        latitude: 1.300000,
        longitude: 103.800000,
      );

      expect(calculator.distanceMeters(first, second), 0);
    });

    test('calculates one degree of longitude at the equator', () {
      final calculator = RunDistanceCalculator();
      final startedAt = DateTime.utc(2026, 6, 14, 7);

      final distanceMeters = calculator.distanceMeters(
        sampleAt(startedAt, 0, latitude: 0, longitude: 0),
        sampleAt(startedAt, 30, latitude: 0, longitude: 1),
      );

      expect(distanceMeters, closeTo(111195, 2));
    });

    test('calculates one degree of latitude at the prime meridian', () {
      final calculator = RunDistanceCalculator();
      final startedAt = DateTime.utc(2026, 6, 14, 7);

      final distanceMeters = calculator.distanceMeters(
        sampleAt(startedAt, 0, latitude: 0, longitude: 0),
        sampleAt(startedAt, 30, latitude: 1, longitude: 0),
      );

      expect(distanceMeters, closeTo(111195, 2));
    });

    test('calculates haversine distance between nearby samples', () {
      final calculator = RunDistanceCalculator();
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final first = RunLocationSample(
        recordedAt: startedAt,
        latitude: 1.300000,
        longitude: 103.800000,
      );
      final second = RunLocationSample(
        recordedAt: startedAt.add(const Duration(seconds: 240)),
        latitude: 1.304497,
        longitude: 103.800000,
      );

      final distanceMeters = calculator.distanceMeters(first, second);

      expect(distanceMeters, closeTo(500, 2));
    });
  });

  group('LocalRunTrackingSession', () {
    test('rejects invalid coordinates and keeps distance finite', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 120),
        samples: [
          sampleAt(startedAt, 0, latitude: 1.300000, longitude: 103.800000),
          sampleAt(startedAt, 10, latitude: 91, longitude: 103.800000),
          sampleAt(startedAt, 20, latitude: -91, longitude: 103.800000),
          sampleAt(startedAt, 30, latitude: 1.300000, longitude: 181),
          sampleAt(startedAt, 40, latitude: 1.300000, longitude: -181),
          sampleAt(startedAt, 50, latitude: double.nan, longitude: 103.800000),
          sampleAt(
            startedAt,
            60,
            latitude: double.infinity,
            longitude: 103.800000,
          ),
          sampleAt(
            startedAt,
            70,
            latitude: 1.300000,
            longitude: double.negativeInfinity,
          ),
          sampleAt(startedAt, 120, latitude: 1.300899, longitude: 103.800000),
        ],
      );

      expect(() => session.distanceMeters, returnsNormally);
      expect(session.distanceMeters.isFinite, isTrue);
      expect(session.distanceMeters, closeTo(100, 2));
      expect(session.acceptedSampleCount, 2);
      expect(session.rejectedSampleCount, 7);
    });

    test('rejects bad horizontal accuracy without inflating distance', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 120),
        samples: [
          sampleAt(
            startedAt,
            0,
            latitude: 1.300000,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
          ),
          sampleAt(
            startedAt,
            20,
            latitude: 1.300100,
            longitude: 103.800000,
            horizontalAccuracyMeters: -1,
          ),
          sampleAt(
            startedAt,
            40,
            latitude: 1.300200,
            longitude: 103.800000,
            horizontalAccuracyMeters: double.nan,
          ),
          sampleAt(
            startedAt,
            60,
            latitude: 1.300300,
            longitude: 103.800000,
            horizontalAccuracyMeters: double.infinity,
          ),
          sampleAt(
            startedAt,
            80,
            latitude: 1.300400,
            longitude: 103.800000,
            horizontalAccuracyMeters: 250,
          ),
          sampleAt(
            startedAt,
            120,
            latitude: 1.300899,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
          ),
        ],
      );

      expect(session.distanceMeters, closeTo(100, 2));
      expect(session.acceptedSampleCount, 2);
      expect(session.rejectedSampleCount, 4);
    });

    test('ignores duplicate-time samples', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 120),
        samples: [
          sampleAt(startedAt, 0, latitude: 1.300000, longitude: 103.800000),
          sampleAt(startedAt, 60, latitude: 1.300450, longitude: 103.800000),
          sampleAt(startedAt, 60, latitude: 1.301800, longitude: 103.800000),
          sampleAt(startedAt, 120, latitude: 1.300899, longitude: 103.800000),
        ],
      );

      expect(session.distanceMeters, closeTo(100, 2));
      expect(session.acceptedSampleCount, 3);
      expect(session.rejectedSampleCount, 1);
    });

    test('ignores out-of-order samples', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 120),
        samples: [
          sampleAt(startedAt, 0, latitude: 1.300000, longitude: 103.800000),
          sampleAt(startedAt, 120, latitude: 1.300899, longitude: 103.800000),
          sampleAt(startedAt, 60, latitude: 1.301800, longitude: 103.800000),
        ],
      );

      expect(session.distanceMeters, closeTo(100, 2));
      expect(session.acceptedSampleCount, 2);
      expect(session.rejectedSampleCount, 1);
    });

    test('does not bridge movement while paused after resume', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 60),
        samples: [
          sampleAt(startedAt, 0, latitude: 1.300000, longitude: 103.800000),
          sampleAt(startedAt, 60, latitude: 1.300899, longitude: 103.800000),
        ],
      );
      session.pause();
      session.advanceBy(
        const Duration(seconds: 60),
        samples: [
          sampleAt(startedAt, 90, latitude: 1.350000, longitude: 103.800000),
          sampleAt(startedAt, 120, latitude: 1.400000, longitude: 103.800000),
        ],
      );
      session.resume();
      session.advanceBy(
        const Duration(seconds: 60),
        samples: [
          sampleAt(startedAt, 120, latitude: 1.400000, longitude: 103.800000),
          sampleAt(startedAt, 180, latitude: 1.400899, longitude: 103.800000),
        ],
      );

      expect(session.activeDurationSeconds, 120);
      expect(session.distanceMeters, closeTo(200, 3));
      expect(session.acceptedSampleCount, 4);
      expect(session.rejectedSampleCount, 0);
    });

    test('ignores impossible jumps without corrupting later valid samples', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 120),
        samples: [
          sampleAt(startedAt, 0, latitude: 1.300000, longitude: 103.800000),
          sampleAt(startedAt, 60, latitude: 2.300000, longitude: 103.800000),
          sampleAt(startedAt, 120, latitude: 1.300899, longitude: 103.800000),
        ],
      );

      expect(session.distanceMeters, closeTo(100, 2));
      expect(session.acceptedSampleCount, 2);
      expect(session.rejectedSampleCount, 1);
    });

    test('updates local distance and pace from replay samples', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 120),
        samples: [
          RunLocationSample(
            recordedAt: startedAt,
            latitude: 1.300000,
            longitude: 103.800000,
          ),
          RunLocationSample(
            recordedAt: startedAt.add(const Duration(seconds: 120)),
            latitude: 1.302698,
            longitude: 103.800000,
          ),
        ],
      );

      expect(session.activeDurationSeconds, 120);
      expect(session.distanceMeters, closeTo(300, 2));
      expect(session.averagePaceSecondsPerKm, closeTo(400, 3));
    });

    test('excludes paused time from active duration and pace', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 60),
        samples: [
          RunLocationSample(
            recordedAt: startedAt,
            latitude: 1.300000,
            longitude: 103.800000,
          ),
          RunLocationSample(
            recordedAt: startedAt.add(const Duration(seconds: 60)),
            latitude: 1.301349,
            longitude: 103.800000,
          ),
        ],
      );
      session.pause();
      session.advanceBy(
        const Duration(seconds: 60),
        samples: [
          RunLocationSample(
            recordedAt: startedAt.add(const Duration(seconds: 120)),
            latitude: 1.310000,
            longitude: 103.800000,
          ),
        ],
      );
      session.resume();
      session.advanceBy(
        const Duration(seconds: 60),
        samples: [
          RunLocationSample(
            recordedAt: startedAt.add(const Duration(seconds: 120)),
            latitude: 1.302698,
            longitude: 103.800000,
          ),
          RunLocationSample(
            recordedAt: startedAt.add(const Duration(seconds: 180)),
            latitude: 1.304047,
            longitude: 103.800000,
          ),
        ],
      );

      expect(session.activeDurationSeconds, 120);
      expect(session.distanceMeters, closeTo(300, 3));
      expect(session.averagePaceSecondsPerKm, closeTo(400, 4));
    });

    test('ignores impossible GPS jumps', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 30),
        samples: [
          RunLocationSample(
            recordedAt: startedAt,
            latitude: 1.300000,
            longitude: 103.800000,
          ),
          RunLocationSample(
            recordedAt: startedAt.add(const Duration(seconds: 10)),
            latitude: 2.300000,
            longitude: 103.800000,
          ),
          RunLocationSample(
            recordedAt: startedAt.add(const Duration(seconds: 30)),
            latitude: 1.300899,
            longitude: 103.800000,
          ),
        ],
      );

      expect(session.activeDurationSeconds, 30);
      expect(session.distanceMeters, closeTo(100, 2));
      expect(session.acceptedSampleCount, 2);
      expect(session.rejectedSampleCount, 1);
    });
  });
}
