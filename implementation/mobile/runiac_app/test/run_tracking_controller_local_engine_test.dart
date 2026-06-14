import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_provider.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_state.dart';
import 'package:runiac_app/features/run/presentation/controllers/run_tracking_controller.dart';

void main() {
  group('RunTrackingController local engine integration', () {
    test(
      'uses replay location samples for distance and completion summary',
      () {
        final startedAt = DateTime.utc(2026, 6, 14, 7);
        final controller = RunTrackingController(
          locationProvider: ReplayRunLocationProvider([
            RunLocationReplaySample(
              activeOffset: Duration.zero,
              sample: RunLocationSample(
                recordedAt: startedAt,
                latitude: 1.300000,
                longitude: 103.800000,
              ),
            ),
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 120),
              sample: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 120)),
                latitude: 1.302698,
                longitude: 103.800000,
              ),
            ),
          ]),
        );

        controller.start(
          startedAt: startedAt,
          clientRunSessionId: 'local-session-replay',
          routeLabel: 'Replay local route',
        );
        controller.advanceBy(const Duration(seconds: 120));
        final payload = controller.completionPayload(
          completedAt: startedAt.add(const Duration(seconds: 120)),
        );
        final payloadMap = payload.toRawClientMap();

        expect(controller.state.phase, RunTrackingPhase.active);
        expect(controller.state.elapsedSeconds, 120);
        expect(controller.state.distanceMeters, closeTo(300, 2));
        expect(controller.state.averagePaceSecondsPerKm, closeTo(400, 3));
        expect(payload.durationSeconds, 120);
        expect(payload.distanceMeters, closeTo(300, 2));
        expect(payload.avgPaceSecondsPerKm, closeTo(400, 3));
        expect(payloadMap.keys, isNot(contains('latitude')));
        expect(payloadMap.keys, isNot(contains('longitude')));
        expect(payloadMap.keys, isNot(contains('samples')));
        expect(payloadMap.keys, isNot(contains('routeTrace')));
        expect(payloadMap.keys, isNot(contains('polyline')));
      },
    );
  });
}
