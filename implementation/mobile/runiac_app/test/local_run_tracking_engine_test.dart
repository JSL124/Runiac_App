import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_diagnostics.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_startup_readiness.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_state.dart';
import 'package:runiac_app/features/run/domain/services/local_run_tracking_session.dart';
import 'package:runiac_app/features/run/domain/services/run_distance_calculator.dart';

void main() {
  RunLocationSample sampleAt(
    DateTime startedAt,
    int seconds, {
    required double latitude,
    required double longitude,
    double? horizontalAccuracyMeters,
    double? speedMetersPerSecond,
  }) {
    return RunLocationSample(
      recordedAt: startedAt.add(Duration(seconds: seconds)),
      latitude: latitude,
      longitude: longitude,
      horizontalAccuracyMeters: horizontalAccuracyMeters,
      speedMetersPerSecond: speedMetersPerSecond,
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

  group('RunTrackingDiagnostics', () {
    test('buckets horizontal accuracy at deterministic boundaries', () {
      expect(
        RunTrackingDiagnostics.bucketForAccuracy(null),
        RunLocationAccuracyBucket.unknown,
      );
      expect(
        RunTrackingDiagnostics.bucketForAccuracy(25),
        RunLocationAccuracyBucket.good,
      );
      expect(
        RunTrackingDiagnostics.bucketForAccuracy(25.1),
        RunLocationAccuracyBucket.weak,
      );
      expect(
        RunTrackingDiagnostics.bucketForAccuracy(100),
        RunLocationAccuracyBucket.weak,
      );
      expect(
        RunTrackingDiagnostics.bucketForAccuracy(100.1),
        RunLocationAccuracyBucket.unusable,
      );
      expect(
        RunTrackingDiagnostics.bucketForAccuracy(-1),
        RunLocationAccuracyBucket.unusable,
      );
      expect(
        RunTrackingDiagnostics.bucketForAccuracy(double.infinity),
        RunLocationAccuracyBucket.unusable,
      );
    });
  });

  group('LocalRunTrackingSession', () {
    test('keeps the first accepted GPS sample as a zero-distance anchor', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 1),
        samples: [
          sampleAt(
            startedAt,
            1,
            latitude: 1.300000,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
          ),
        ],
      );

      final snapshot = RunTrackingSnapshot.fromState(
        RunTrackingState(
          phase: RunTrackingPhase.active,
          clientRunSessionId: 'anchor-readiness',
          startedAt: startedAt,
          completedAt: null,
          elapsedSeconds: session.activeDurationSeconds,
          distanceMeters: session.distanceMeters,
          averagePaceSecondsPerKm: session.averagePaceSecondsPerKm,
          routePrivacy: 'private',
          source: session.source,
          locationStatus: RunTrackingLocationStatus.gpsActive,
          diagnostics: session.diagnostics,
        ),
      );

      expect(session.acceptedSampleCount, 1);
      expect(session.distanceMeters, 0);
      expect(session.averagePaceSecondsPerKm, 0);
      expect(
        snapshot.startupReadiness,
        RunTrackingStartupReadiness.anchoredNoMovement,
      );
      expect(snapshot.averagePaceLabel, '--:--/km');
    });

    test('uses one 50m movement threshold for startup pace readiness', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 20),
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
            latitude: 1.300225,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
          ),
        ],
      );

      var snapshot = RunTrackingSnapshot.fromState(
        RunTrackingState(
          phase: RunTrackingPhase.active,
          clientRunSessionId: 'below-threshold-readiness',
          startedAt: startedAt,
          completedAt: null,
          elapsedSeconds: session.activeDurationSeconds,
          distanceMeters: session.distanceMeters,
          averagePaceSecondsPerKm: session.averagePaceSecondsPerKm,
          routePrivacy: 'private',
          source: session.source,
          locationStatus: RunTrackingLocationStatus.gpsActive,
          diagnostics: session.diagnostics,
        ),
      );

      expect(session.distanceMeters, greaterThan(0));
      expect(session.distanceMeters, lessThan(50));
      expect(
        snapshot.startupReadiness,
        RunTrackingStartupReadiness.movementBelowThreshold,
      );
      expect(snapshot.averagePaceLabel, '--:--/km');

      session.advanceBy(
        const Duration(seconds: 20),
        samples: [
          sampleAt(
            startedAt,
            40,
            latitude: 1.300450,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
          ),
        ],
      );

      snapshot = RunTrackingSnapshot.fromState(
        RunTrackingState(
          phase: RunTrackingPhase.active,
          clientRunSessionId: 'ready-threshold-readiness',
          startedAt: startedAt,
          completedAt: null,
          elapsedSeconds: session.activeDurationSeconds,
          distanceMeters: session.distanceMeters,
          averagePaceSecondsPerKm: session.averagePaceSecondsPerKm,
          routePrivacy: 'private',
          source: session.source,
          locationStatus: RunTrackingLocationStatus.gpsActive,
          diagnostics: session.diagnostics,
        ),
      );

      expect(session.distanceMeters, greaterThanOrEqualTo(50));
      expect(snapshot.startupReadiness, RunTrackingStartupReadiness.ready);
      expect(snapshot.averagePaceLabel, isNot('--:--/km'));
    });

    test('records accepted sample diagnostics without raw route data', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 60),
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
            60,
            latitude: 1.300899,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
          ),
        ],
      );

      final diagnostics = session.diagnostics;
      expect(diagnostics.acceptedSampleCount, 2);
      expect(diagnostics.rejectedSampleCount, 0);
      expect(
        diagnostics.lastSampleReceivedAt,
        startedAt.add(const Duration(seconds: 60)),
      );
      expect(
        diagnostics.lastAcceptedSampleAt,
        startedAt.add(const Duration(seconds: 60)),
      );
      expect(diagnostics.lastRejectedSampleAt, isNull);
      expect(
        diagnostics.latestRejectionReason,
        RunLocationRejectionReason.none,
      );
      expect(diagnostics.latestHorizontalAccuracyMeters, 5);
      expect(diagnostics.latestAccuracyBucket, RunLocationAccuracyBucket.good);
      expect(diagnostics.hasReceivedSample, isTrue);
      expect(diagnostics.hasAcceptedSample, isTrue);
    });

    test('records explicit rejection reasons and timestamps', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);

      LocalRunTrackingSession sessionWith(List<RunLocationSample> samples) {
        final session = LocalRunTrackingSession(startedAt: startedAt);
        session.advanceBy(const Duration(seconds: 120), samples: samples);
        return session;
      }

      expect(
        sessionWith([
          sampleAt(startedAt, 0, latitude: 1.3, longitude: 103.8),
          sampleAt(startedAt, 10, latitude: 91, longitude: 103.8),
        ]).diagnostics.latestRejectionReason,
        RunLocationRejectionReason.invalidCoordinate,
      );
      expect(
        sessionWith([
          sampleAt(startedAt, 0, latitude: 1.3, longitude: 103.8),
          sampleAt(
            startedAt,
            10,
            latitude: 1.300100,
            longitude: 103.8,
            horizontalAccuracyMeters: 250,
          ),
        ]).diagnostics.latestRejectionReason,
        RunLocationRejectionReason.poorAccuracy,
      );
      expect(
        sessionWith([
          sampleAt(startedAt, 0, latitude: 1.3, longitude: 103.8),
          sampleAt(startedAt, 10, latitude: 1.300100, longitude: 103.8),
          sampleAt(startedAt, 10, latitude: 1.300200, longitude: 103.8),
        ]).diagnostics.latestRejectionReason,
        RunLocationRejectionReason.duplicateOrOutOfOrderTimestamp,
      );
      expect(
        sessionWith([
          sampleAt(startedAt, 0, latitude: 1.3, longitude: 103.8),
          sampleAt(startedAt, 10, latitude: 2.3, longitude: 103.8),
        ]).diagnostics.latestRejectionReason,
        RunLocationRejectionReason.impossibleJump,
      );

      final staleSession = sessionWith([
        RunLocationSample(
          recordedAt: startedAt.subtract(const Duration(seconds: 1)),
          latitude: 1.3,
          longitude: 103.8,
        ),
      ]);
      expect(
        staleSession.diagnostics.latestRejectionReason,
        RunLocationRejectionReason.staleTimestamp,
      );
      expect(
        staleSession.diagnostics.lastRejectedSampleAt,
        startedAt.subtract(const Duration(seconds: 1)),
      );
    });

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

    test('rejects non-finite segment distance without inflating distance', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(
        startedAt: startedAt,
        distanceCalculator: const _NonFiniteDistanceCalculator(),
      );

      session.advanceBy(
        const Duration(seconds: 60),
        samples: [
          sampleAt(startedAt, 0, latitude: 1.300000, longitude: 103.800000),
          sampleAt(startedAt, 60, latitude: 1.300899, longitude: 103.800000),
        ],
      );

      expect(session.distanceMeters, 0);
      expect(session.acceptedSampleCount, 1);
      expect(session.rejectedSampleCount, 1);
      expect(
        session.diagnostics.latestRejectionReason,
        RunLocationRejectionReason.nonFiniteDistance,
      );
      expect(
        session.diagnostics.lastRejectedSampleAt,
        startedAt.add(const Duration(seconds: 60)),
      );
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

    test('auto pause freezes moving time and suppresses stationary drift', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 60),
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
            60,
            latitude: 1.300899,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
          ),
        ],
      );
      final movingTimeBeforeStop = session.activeDurationSeconds;
      final distanceBeforeStop = session.distanceMeters;
      final paceBeforeStop = session.averagePaceSecondsPerKm;
      final routePointCountBeforeStop = session.mapViewState.routePointCount;

      session.advanceBy(
        const Duration(seconds: 20),
        samples: [
          sampleAt(
            startedAt,
            70,
            latitude: 1.300908,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 0.1,
          ),
          sampleAt(
            startedAt,
            80,
            latitude: 1.300917,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 0.1,
          ),
        ],
      );

      expect(session.movementStatus, RunMovementStatus.autoPaused);
      expect(session.activeDurationSeconds, movingTimeBeforeStop);
      expect(session.distanceMeters, distanceBeforeStop);
      expect(session.averagePaceSecondsPerKm, paceBeforeStop);
      expect(session.mapViewState.routePointCount, routePointCountBeforeStop);
      expect(session.mapViewState.currentPosition?.latitude, 1.300917);

      session.advanceBy(
        const Duration(seconds: 10),
        samples: [
          sampleAt(
            startedAt,
            90,
            latitude: 1.301000,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 1.2,
          ),
        ],
      );

      expect(session.movementStatus, RunMovementStatus.moving);
      expect(session.activeDurationSeconds, movingTimeBeforeStop);
      expect(session.distanceMeters, distanceBeforeStop);
      expect(session.mapViewState.routeSegments, hasLength(2));
      expect(session.mapViewState.routeSegments.last, hasLength(1));

      session.advanceBy(
        const Duration(seconds: 10),
        samples: [
          sampleAt(
            startedAt,
            100,
            latitude: 1.301090,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 1.2,
          ),
        ],
      );

      expect(session.activeDurationSeconds, movingTimeBeforeStop + 10);
      expect(session.distanceMeters, greaterThan(distanceBeforeStop));
      expect(session.mapViewState.routeSegments.last, hasLength(2));
    });

    test('auto pauses when stationary from the start without route drift', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      session.advanceBy(
        const Duration(seconds: 1),
        samples: [
          sampleAt(
            startedAt,
            1,
            latitude: 1.300000,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 0.1,
          ),
        ],
      );

      expect(session.movementStatus, RunMovementStatus.moving);
      expect(session.distanceMeters, 0);
      expect(session.mapViewState.routePointCount, 1);

      session.advanceBy(
        const Duration(seconds: 20),
        samples: [
          sampleAt(
            startedAt,
            10,
            latitude: 1.300009,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 0.1,
          ),
          sampleAt(
            startedAt,
            20,
            latitude: 1.300018,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 0.1,
          ),
        ],
      );

      expect(session.movementStatus, RunMovementStatus.autoPaused);
      expect(session.activeDurationSeconds, 0);
      expect(session.distanceMeters, 0);
      expect(session.averagePaceSecondsPerKm, 0);
      expect(session.mapViewState.routeSegments, hasLength(1));
      expect(session.mapViewState.routePointCount, 1);
      expect(session.mapViewState.currentPosition?.latitude, 1.300018);

      session.advanceBy(
        const Duration(seconds: 10),
        samples: [
          sampleAt(
            startedAt,
            30,
            latitude: 1.300100,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 1.2,
          ),
        ],
      );

      expect(session.movementStatus, RunMovementStatus.moving);
      expect(session.activeDurationSeconds, 0);
      expect(session.distanceMeters, 0);
      expect(session.mapViewState.routeSegments, hasLength(2));
      expect(session.mapViewState.routeSegments.last, hasLength(1));

      session.advanceBy(
        const Duration(seconds: 10),
        samples: [
          sampleAt(
            startedAt,
            40,
            latitude: 1.300190,
            longitude: 103.800000,
            horizontalAccuracyMeters: 5,
            speedMetersPerSecond: 1.2,
          ),
        ],
      );

      expect(session.activeDurationSeconds, 10);
      expect(session.distanceMeters, greaterThan(0));
      expect(session.mapViewState.routeSegments.last, hasLength(2));
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

class _NonFiniteDistanceCalculator extends RunDistanceCalculator {
  const _NonFiniteDistanceCalculator();

  @override
  double distanceMeters(RunLocationSample from, RunLocationSample to) {
    return double.nan;
  }
}
