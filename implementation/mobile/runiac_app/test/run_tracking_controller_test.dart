import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/run_location_permission_status.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_state.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_permission_service.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_provider.dart';
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
