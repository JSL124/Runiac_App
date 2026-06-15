import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_location_permission_status.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_diagnostics.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_startup_readiness.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_state.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_permission_service.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_provider.dart';
import 'package:runiac_app/features/run/data/real_foreground_run_location_provider.dart';
import 'package:runiac_app/features/run/presentation/controllers/run_tracking_controller.dart';

class _FakePermissionService implements RunLocationPermissionService {
  _FakePermissionService(this.status);

  RunLocationPermissionStatus status;

  @override
  Future<RunLocationPermissionStatus> checkStatus() async => status;

  @override
  Future<RunLocationPermissionStatus> requestPermission() async => status;
}

class _LifecycleTrackingProvider extends ConstantSpeedRunLocationProvider {
  _LifecycleTrackingProvider() : super(metersPerSecond: 2.5);

  int startCount = 0;
  int pauseCount = 0;
  int resumeCount = 0;
  int stopCount = 0;

  @override
  Future<void> start({required DateTime startedAt}) async {
    startCount += 1;
  }

  @override
  Future<void> pause() async {
    pauseCount += 1;
  }

  @override
  Future<void> resume({
    required DateTime resumedAt,
    required Duration activeOffset,
  }) async {
    resumeCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}

void main() {
  group('RunTrackingController', () {
    test('starts idle with no trusted completion state', () {
      final controller = RunTrackingController();

      expect(controller.state.phase, RunTrackingPhase.idle);
      expect(controller.state.elapsedSeconds, 0);
      expect(controller.state.distanceMeters, 0);
      expect(controller.state.averagePaceSecondsPerKm, 0);
      expect(controller.state.isPaused, isFalse);
    });

    test('start creates an active local session', () {
      final controller = RunTrackingController();
      final startedAt = DateTime.utc(2026, 6, 14, 7);

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'local-session-1',
      );

      expect(controller.state.phase, RunTrackingPhase.active);
      expect(controller.state.clientRunSessionId, 'local-session-1');
      expect(controller.state.startedAt, startedAt);
      expect(controller.state.source, 'local_simulation');
      expect(controller.state.routePrivacy, 'private');
    });

    test('deterministic tick advances elapsed time, distance, and pace', () {
      final controller = RunTrackingController(metersPerSecond: 2.5);

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'local-session-2',
      );
      controller.advanceBy(const Duration(seconds: 120));

      expect(controller.state.elapsedSeconds, 120);
      expect(controller.state.distanceMeters, 300);
      expect(controller.state.averagePaceSecondsPerKm, 400);
    });

    test('live pace is hidden below 50 meters while time keeps running', () {
      final controller = RunTrackingController(metersPerSecond: 2.5);

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'small-distance-run',
      );
      controller.advanceBy(const Duration(seconds: 10));

      final snapshot = RunTrackingSnapshot.fromState(controller.state);
      expect(controller.state.elapsedSeconds, 10);
      expect(controller.state.distanceMeters, 25);
      expect(controller.state.averagePaceSecondsPerKm, 400);
      expect(snapshot.elapsedTimeLabel, '00:10');
      expect(snapshot.distanceLabel, '0.03 km');
      expect(snapshot.averagePaceLabel, '--:--/km');
    });

    test('live pace is formatted normally at 50 meters', () {
      final controller = RunTrackingController(metersPerSecond: 2.5);

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'ready-distance-run',
      );
      controller.advanceBy(const Duration(seconds: 20));

      final snapshot = RunTrackingSnapshot.fromState(controller.state);
      expect(controller.state.distanceMeters, 50);
      expect(controller.state.averagePaceSecondsPerKm, 399);
      expect(snapshot.averagePaceLabel, '06:39/km');
    });

    test('completion payload remains numeric below live pace threshold', () {
      final controller = RunTrackingController(metersPerSecond: 2.5);

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'tiny-completion-run',
      );
      controller.advanceBy(const Duration(seconds: 10));

      final payload = controller.completionPayload(
        completedAt: DateTime.utc(2026, 6, 14, 7, 1),
      );

      expect(payload.distanceMeters, 25);
      expect(payload.durationSeconds, 10);
      expect(payload.avgPaceSecondsPerKm, 400);
      expect(payload.toRawClientMap().keys, isNot(contains('routeSamples')));
      expect(payload.toRawClientMap().keys, isNot(contains('xp')));
    });

    test('pause stops progression and resume continues from a new anchor', () {
      final controller = RunTrackingController(metersPerSecond: 2.5);

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'local-session-3',
      );
      controller.advanceBy(const Duration(seconds: 60));
      controller.pause();
      controller.advanceBy(const Duration(seconds: 60));

      expect(controller.state.phase, RunTrackingPhase.paused);
      expect(controller.state.elapsedSeconds, 60);
      expect(controller.state.distanceMeters, 150);

      controller.resume();
      controller.advanceBy(const Duration(seconds: 60));

      expect(controller.state.phase, RunTrackingPhase.active);
      expect(controller.state.elapsedSeconds, 120);
      expect(controller.state.distanceMeters, 150);

      controller.advanceBy(const Duration(seconds: 60));

      expect(controller.state.elapsedSeconds, 180);
      expect(controller.state.distanceMeters, 300);
    });

    test('finish creates only raw client-observed completion payload', () {
      final controller = RunTrackingController(metersPerSecond: 2.5);
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final completedAt = DateTime.utc(2026, 6, 14, 7, 2);

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'local-session-4',
        routeLabel: 'Easy local route',
      );
      controller.advanceBy(const Duration(seconds: 120));

      final payload = controller.finish(completedAt: completedAt);
      final payloadMap = payload.toRawClientMap();

      expect(payload, isA<LocalRunCompletionPayload>());
      expect(payload.clientRunSessionId, 'local-session-4');
      expect(payload.startedAt, startedAt);
      expect(payload.completedAt, completedAt);
      expect(payload.durationSeconds, 120);
      expect(payload.distanceMeters, 300);
      expect(payload.avgPaceSecondsPerKm, 400);
      expect(payload.source, 'local_simulation');
      expect(payload.routePrivacy, 'private');
      expect(payload.routeLabel, 'Easy local route');
      expect(controller.state.phase, RunTrackingPhase.finished);
      expect(payloadMap.keys, isNot(contains('xp')));
      expect(payloadMap.keys, isNot(contains('streak')));
      expect(payloadMap.keys, isNot(contains('level')));
      expect(payloadMap.keys, isNot(contains('rank')));
      expect(payloadMap.keys, isNot(contains('leaderboardScore')));
      expect(payloadMap.keys, isNot(contains('weeklyXp')));
      expect(payloadMap.keys, isNot(contains('monthlyXp')));
      expect(
        payloadMap.keys,
        isNot(
          contains(
            'validation'
            'Status',
          ),
        ),
      );
      expect(
        payloadMap.keys,
        isNot(
          contains(
            'countsToward'
            'Progression',
          ),
        ),
      );
    });

    test('completionPayload does not mark the local run finished', () {
      final controller = RunTrackingController(metersPerSecond: 2.5);
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final completedAt = DateTime.utc(2026, 6, 14, 7, 2);

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'local-session-5',
        routeLabel: 'Easy local route',
      );
      controller.advanceBy(const Duration(seconds: 120));
      controller.pause();

      final payload = controller.completionPayload(completedAt: completedAt);

      expect(payload.clientRunSessionId, 'local-session-5');
      expect(payload.completedAt, completedAt);
      expect(controller.state.phase, RunTrackingPhase.paused);
      expect(controller.state.completedAt, isNull);
    });

    test(
      'does not start real provider when foreground permission is denied',
      () async {
        final provider = _LifecycleTrackingProvider();
        final controller = RunTrackingController(
          locationProvider: provider,
          permissionService: _FakePermissionService(
            RunLocationPermissionStatus.denied,
          ),
        );

        final started = await controller.requestStart(
          startedAt: DateTime.utc(2026, 6, 14, 7),
          clientRunSessionId: 'permission-denied-run',
        );

        expect(started, isFalse);
        expect(
          controller.locationPermissionStatus,
          RunLocationPermissionStatus.denied,
        );
        expect(controller.state.phase, RunTrackingPhase.idle);
        expect(provider.startCount, 0);
      },
    );

    test(
      'starts real provider only when foreground permission is granted',
      () async {
        final provider = _LifecycleTrackingProvider();
        final controller = RunTrackingController(
          locationProvider: provider,
          permissionService: _FakePermissionService(
            RunLocationPermissionStatus.granted,
          ),
        );

        final started = await controller.requestStart(
          startedAt: DateTime.utc(2026, 6, 14, 7),
          clientRunSessionId: 'permission-granted-run',
        );

        expect(started, isTrue);
        expect(
          controller.locationPermissionStatus,
          RunLocationPermissionStatus.granted,
        );
        expect(controller.state.phase, RunTrackingPhase.active);
        expect(provider.startCount, 1);

        controller.pause();
        controller.resume();
        controller.finish(completedAt: DateTime.utc(2026, 6, 14, 7, 1));

        expect(provider.pauseCount, 1);
        expect(provider.resumeCount, 1);
        expect(provider.stopCount, 1);
      },
    );

    test('default local simulation starts in demo mode', () {
      final controller = RunTrackingController();

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'demo-run',
      );

      expect(controller.state.locationStatus, RunTrackingLocationStatus.demo);
    });

    test('foreground GPS mode waits before any accepted sample', () {
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider(const []),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'waiting-gps-run',
      );
      controller.advanceBy(const Duration(seconds: 1));

      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.waitingForGps,
      );
      expect(controller.state.diagnostics.hasReceivedSample, isFalse);
      expect(controller.state.diagnostics.acceptedSampleCount, 0);
    });

    test('startup readiness waits before any GPS sample is received', () {
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider(const []),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'readiness-waiting-run',
      );
      controller.advanceBy(const Duration(seconds: 1));

      final snapshot = RunTrackingSnapshot.fromState(controller.state);
      expect(
        snapshot.startupReadiness,
        RunTrackingStartupReadiness.waitingForFirstSample,
      );
      expect(
        snapshot.startupReadinessMessage,
        'Getting GPS ready. Keep the app open while we find your signal.',
      );
      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.waitingForGps,
      );
    });

    test('foreground GPS mode becomes active after an accepted sample', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.3,
              longitude: 103.8,
              horizontalAccuracyMeters: 5,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'active-gps-run',
      );
      controller.advanceBy(const Duration(seconds: 1));

      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsActive,
      );
      expect(controller.state.diagnostics.acceptedSampleCount, 1);
      expect(
        controller.state.diagnostics.latestAccuracyBucket,
        RunLocationAccuracyBucket.good,
      );
    });

    test('startup readiness anchors on the first accepted GPS sample', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.3,
              longitude: 103.8,
              horizontalAccuracyMeters: 5,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'readiness-anchor-run',
      );
      controller.advanceBy(const Duration(seconds: 1));

      final snapshot = RunTrackingSnapshot.fromState(controller.state);
      expect(controller.state.distanceMeters, 0);
      expect(
        snapshot.startupReadiness,
        RunTrackingStartupReadiness.anchoredNoMovement,
      );
      expect(
        snapshot.startupReadinessMessage,
        'GPS is ready. Start moving to measure distance.',
      );
    });

    test('foreground GPS mode becomes weak after rejected accuracy', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.3,
              longitude: 103.8,
              horizontalAccuracyMeters: 250,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'weak-gps-run',
      );
      controller.advanceBy(const Duration(seconds: 1));

      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsWeak,
      );
      expect(
        controller.state.diagnostics.latestRejectionReason,
        RunLocationRejectionReason.poorAccuracy,
      );
      expect(controller.state.diagnostics.rejectedSampleCount, 1);
    });

    test('startup readiness reports weak GPS after latest rejected sample', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.3,
              longitude: 103.8,
              horizontalAccuracyMeters: 250,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'readiness-weak-run',
      );
      controller.advanceBy(const Duration(seconds: 1));

      final snapshot = RunTrackingSnapshot.fromState(controller.state);
      expect(snapshot.startupReadiness, RunTrackingStartupReadiness.gpsWeak);
      expect(
        snapshot.startupReadinessMessage,
        'GPS signal is weak. Keep moving in an open area.',
      );
    });

    test('startup readiness keeps pace hidden below the 50m threshold', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.300000,
              longitude: 103.800000,
              horizontalAccuracyMeters: 5,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 20),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 20)),
              latitude: 1.300225,
              longitude: 103.800000,
              horizontalAccuracyMeters: 5,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'readiness-below-threshold-run',
      );
      controller.advanceBy(const Duration(seconds: 20));

      final snapshot = RunTrackingSnapshot.fromState(controller.state);
      expect(controller.state.distanceMeters, greaterThan(0));
      expect(controller.state.distanceMeters, lessThan(50));
      expect(
        snapshot.startupReadiness,
        RunTrackingStartupReadiness.movementBelowThreshold,
      );
      expect(snapshot.averagePaceLabel, '--:--/km');
      expect(
        snapshot.startupReadinessMessage,
        'Keep going. Pace appears after a little more movement.',
      );
    });

    test('startup readiness becomes ready at the 50m movement threshold', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.300000,
              longitude: 103.800000,
              horizontalAccuracyMeters: 5,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 20),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 20)),
              latitude: 1.300450,
              longitude: 103.800000,
              horizontalAccuracyMeters: 5,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'readiness-ready-run',
      );
      controller.advanceBy(const Duration(seconds: 20));

      final snapshot = RunTrackingSnapshot.fromState(controller.state);
      expect(controller.state.distanceMeters, greaterThanOrEqualTo(50));
      expect(snapshot.startupReadiness, RunTrackingStartupReadiness.ready);
      expect(snapshot.averagePaceLabel, isNot('--:--/km'));
      expect(
        snapshot.startupReadinessMessage,
        'GPS active. Distance and pace are updating.',
      );
    });

    test('foreground GPS mode follows latest active and weak samples', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.3,
              longitude: 103.8,
              horizontalAccuracyMeters: 5,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 2),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 2)),
              latitude: 1.30001,
              longitude: 103.8,
              horizontalAccuracyMeters: 250,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 3),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 3)),
              latitude: 1.30002,
              longitude: 103.8,
              horizontalAccuracyMeters: 5,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'latest-gps-quality-run',
      );
      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.waitingForGps,
      );

      controller.advanceBy(const Duration(seconds: 1));
      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsActive,
      );

      controller.advanceBy(const Duration(seconds: 1));
      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsWeak,
      );

      controller.advanceBy(const Duration(seconds: 1));
      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsActive,
      );
    });

    test(
      'foreground GPS mode shows approximate location only when reduced',
      () {
        final startedAt = DateTime.utc(2026, 6, 14, 7);
        final controller = RunTrackingController(
          locationProvider: ReplayRunLocationProvider([
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 1),
              sample: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 1)),
                latitude: 1.3,
                longitude: 103.8,
                horizontalAccuracyMeters: 5,
              ),
            ),
          ], locationAccuracyStatus: RunTrackingLocationAccuracyStatus.reduced),
          locationStatus: RunTrackingLocationStatus.waitingForGps,
        );

        controller.start(
          startedAt: startedAt,
          clientRunSessionId: 'approximate-gps-run',
        );
        controller.advanceBy(const Duration(seconds: 1));

        expect(
          controller.state.locationStatus,
          RunTrackingLocationStatus.approximateLocation,
        );
        expect(
          controller.state.diagnostics.locationAccuracyStatus,
          RunTrackingLocationAccuracyStatus.reduced,
        );

        final snapshot = RunTrackingSnapshot.fromState(controller.state);
        expect(
          snapshot.startupReadiness,
          RunTrackingStartupReadiness.approximateLocation,
        );
        expect(
          snapshot.startupReadinessMessage,
          'Approximate location is on. Distance may take longer to settle.',
        );
      },
    );

    test('foreground GPS mode follows latest sample in one advance batch', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final controller = RunTrackingController(
        locationProvider: ReplayRunLocationProvider([
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 1),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 1)),
              latitude: 1.3,
              longitude: 103.8,
              horizontalAccuracyMeters: 5,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 2),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 2)),
              latitude: 1.30001,
              longitude: 103.8,
              horizontalAccuracyMeters: 250,
            ),
          ),
        ]),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      controller.start(
        startedAt: startedAt,
        clientRunSessionId: 'batched-latest-gps-quality-run',
      );
      controller.advanceBy(const Duration(seconds: 2));

      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsWeak,
      );
    });

    test(
      'foreground GPS mode shows weak for later duplicate timestamp rejection',
      () {
        final startedAt = DateTime.utc(2026, 6, 14, 7);
        final controller = RunTrackingController(
          locationProvider: ReplayRunLocationProvider([
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 1),
              sample: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 1)),
                latitude: 1.3,
                longitude: 103.8,
                horizontalAccuracyMeters: 5,
              ),
            ),
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 2),
              sample: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 1)),
                latitude: 1.3001,
                longitude: 103.8,
                horizontalAccuracyMeters: 5,
              ),
            ),
          ]),
          locationStatus: RunTrackingLocationStatus.waitingForGps,
        );

        controller.start(
          startedAt: startedAt,
          clientRunSessionId: 'duplicate-timestamp-quality-run',
        );
        controller.advanceBy(const Duration(seconds: 2));

        expect(
          controller.state.locationStatus,
          RunTrackingLocationStatus.gpsWeak,
        );
        expect(
          controller.state.diagnostics.latestRejectionReason,
          RunLocationRejectionReason.duplicateOrOutOfOrderTimestamp,
        );
      },
    );

    test('real foreground late accepted samples advance distance', () async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final adapter = _FakeForegroundAdapter();
      final controller = RunTrackingController(
        locationProvider: RealForegroundRunLocationProvider(adapter: adapter),
        permissionService: _FakePermissionService(
          RunLocationPermissionStatus.granted,
        ),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      final started = await controller.requestStart(
        startedAt: startedAt,
        clientRunSessionId: 'late-real-gps-run',
      );
      expect(started, isTrue);
      controller.advanceBy(const Duration(seconds: 10));

      adapter.emit(
        _ForegroundPosition(
          timestamp: startedAt.add(const Duration(seconds: 1)),
          latitude: 1.300000,
          longitude: 103.800000,
          accuracy: 5,
        ),
      );
      adapter.emit(
        _ForegroundPosition(
          timestamp: startedAt.add(const Duration(seconds: 10)),
          latitude: 1.300899,
          longitude: 103.800000,
          accuracy: 5,
        ),
      );

      controller.advanceBy(const Duration(seconds: 1));

      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsActive,
      );
      expect(controller.state.distanceMeters, closeTo(100, 2));
    });

    test('real foreground late rejected sample surfaces GPS weak', () async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final adapter = _FakeForegroundAdapter();
      final controller = RunTrackingController(
        locationProvider: RealForegroundRunLocationProvider(adapter: adapter),
        permissionService: _FakePermissionService(
          RunLocationPermissionStatus.granted,
        ),
        locationStatus: RunTrackingLocationStatus.waitingForGps,
      );

      await controller.requestStart(
        startedAt: startedAt,
        clientRunSessionId: 'late-weak-gps-run',
      );
      controller.advanceBy(const Duration(seconds: 10));

      adapter.emit(
        _ForegroundPosition(
          timestamp: startedAt.add(const Duration(seconds: 2)),
          latitude: 1.300000,
          longitude: 103.800000,
          accuracy: 250,
        ),
      );

      controller.advanceBy(const Duration(seconds: 1));

      expect(
        controller.state.locationStatus,
        RunTrackingLocationStatus.gpsWeak,
      );
      expect(controller.state.distanceMeters, 0);
      expect(
        controller.state.diagnostics.latestRejectionReason,
        RunLocationRejectionReason.poorAccuracy,
      );
    });

    test(
      'real foreground unconsumed pre-pause sample does not bridge after resume',
      () async {
        final startedAt = DateTime.now().subtract(const Duration(minutes: 1));
        final adapter = _FakeForegroundAdapter();
        final controller = RunTrackingController(
          locationProvider: RealForegroundRunLocationProvider(adapter: adapter),
          permissionService: _FakePermissionService(
            RunLocationPermissionStatus.granted,
          ),
          locationStatus: RunTrackingLocationStatus.waitingForGps,
        );

        await controller.requestStart(
          startedAt: startedAt,
          clientRunSessionId: 'no-bridge-late-pause-run',
        );
        adapter.emit(
          _ForegroundPosition(
            timestamp: startedAt.add(const Duration(seconds: 1)),
            latitude: 1.300000,
            longitude: 103.800000,
            accuracy: 5,
          ),
        );

        controller.pause();
        controller.resume();
        adapter.emit(
          _ForegroundPosition(
            timestamp: DateTime.now().add(const Duration(seconds: 1)),
            latitude: 1.300899,
            longitude: 103.800000,
            accuracy: 5,
          ),
        );

        controller.advanceBy(const Duration(seconds: 2));

        expect(
          controller.state.locationStatus,
          RunTrackingLocationStatus.gpsActive,
        );
        expect(controller.state.distanceMeters, 0);
        expect(controller.mapViewState.routeSegments, hasLength(1));
        expect(controller.mapViewState.routeSegments.single, hasLength(1));
      },
    );

    test('dispose stops the active location provider', () async {
      final provider = _LifecycleTrackingProvider();
      final controller = RunTrackingController(locationProvider: provider);

      controller.start(
        startedAt: DateTime.utc(2026, 6, 14, 7),
        clientRunSessionId: 'dispose-run',
      );
      controller.dispose();

      expect(provider.startCount, 1);
      expect(provider.stopCount, 1);
    });
  });
}

class _FakeForegroundAdapter implements ForegroundLocationAdapter {
  final _controller = StreamController<ForegroundPosition>.broadcast(
    sync: true,
  );

  void emit(_ForegroundPosition position) {
    _controller.add(position);
  }

  @override
  Stream<ForegroundPosition> getPositionStream(
    LocationSettingsRequest settings,
  ) {
    return _controller.stream;
  }

  @override
  Future<RunTrackingLocationAccuracyStatus> getLocationAccuracyStatus() async {
    return RunTrackingLocationAccuracyStatus.precise;
  }
}

class _ForegroundPosition implements ForegroundPosition {
  const _ForegroundPosition({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  @override
  final DateTime timestamp;

  @override
  final double latitude;

  @override
  final double longitude;

  @override
  final double? accuracy;

  @override
  double? get speed => null;
}
