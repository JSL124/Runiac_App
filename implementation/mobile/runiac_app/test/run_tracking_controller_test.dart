import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_state.dart';
import 'package:runiac_app/features/run/presentation/controllers/run_tracking_controller.dart';

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

    test('pause stops progression and resume continues it', () {
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
  });
}
