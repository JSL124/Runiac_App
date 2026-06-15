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

    test('exposes accepted samples as local-only map route state', () {
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
            activeOffset: const Duration(seconds: 60),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 60)),
              latitude: 1.300899,
              longitude: 103.800000,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 120),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 120)),
              latitude: 1.301798,
              longitude: 103.800000,
            ),
          ),
        ]),
      );

      controller.start(startedAt: startedAt);
      controller.advanceBy(const Duration(seconds: 120));

      expect(controller.mapViewState.currentPosition?.latitude, 1.301798);
      expect(controller.mapViewState.currentPosition?.longitude, 103.800000);
      expect(controller.mapViewState.routeSegments, hasLength(1));
      expect(controller.mapViewState.routeSegments.single, hasLength(3));
      expect(controller.mapViewState.routePointCount, 3);

      final payloadMap = controller.completionPayload().toRawClientMap();
      expect(payloadMap.keys, isNot(contains('latitude')));
      expect(payloadMap.keys, isNot(contains('longitude')));
      expect(payloadMap.keys, isNot(contains('samples')));
      expect(payloadMap.keys, isNot(contains('routeTrace')));
      expect(payloadMap.keys, isNot(contains('polyline')));
      expect(payloadMap.keys, isNot(contains('positions')));
      expect(payloadMap.keys, isNot(contains('gpsSamples')));
      expect(payloadMap.keys, isNot(contains('rawLocationSamples')));
    });

    test('pause does not extend local map route polyline', () {
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
            activeOffset: const Duration(seconds: 10),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 10)),
              latitude: 1.300100,
              longitude: 103.800000,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 20),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 20)),
              latitude: 1.350000,
              longitude: 103.800000,
            ),
          ),
        ]),
      );

      controller.start(startedAt: startedAt);
      controller.advanceBy(const Duration(seconds: 10));
      controller.pause();
      controller.advanceBy(const Duration(seconds: 10));

      expect(controller.mapViewState.routeSegments, hasLength(1));
      expect(controller.mapViewState.routeSegments.single, hasLength(2));
      expect(controller.mapViewState.currentPosition?.latitude, 1.300100);
    });

    test('resume starts a new local route segment without bridge polyline', () {
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
            activeOffset: const Duration(seconds: 10),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 10)),
              latitude: 1.300100,
              longitude: 103.800000,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 20),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 20)),
              latitude: 1.400000,
              longitude: 103.800000,
            ),
          ),
          RunLocationReplaySample(
            activeOffset: const Duration(seconds: 30),
            sample: RunLocationSample(
              recordedAt: startedAt.add(const Duration(seconds: 30)),
              latitude: 1.400100,
              longitude: 103.800000,
            ),
          ),
        ]),
      );

      controller.start(startedAt: startedAt);
      controller.advanceBy(const Duration(seconds: 10));
      controller.pause();
      controller.resume();
      controller.advanceBy(const Duration(seconds: 10));
      controller.advanceBy(const Duration(seconds: 10));

      expect(controller.mapViewState.routeSegments, hasLength(2));
      expect(
        controller.mapViewState.routeSegments.map((segment) => segment.length),
        [2, 2],
      );
      expect(
        controller.mapViewState.routeSegments.first.last.latitude,
        1.300100,
      );
      expect(
        controller.mapViewState.routeSegments.last.first.latitude,
        1.400000,
      );
    });

    test(
      'resume duplicate anchor makes first displaced sample a no-distance route anchor',
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
              activeOffset: const Duration(seconds: 10),
              sample: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 10)),
                latitude: 1.300100,
                longitude: 103.800000,
              ),
            ),
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 20),
              sample: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 20)),
                latitude: 1.300200,
                longitude: 103.800000,
              ),
            ),
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 30),
              sample: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 30)),
                latitude: 1.300300,
                longitude: 103.800000,
              ),
            ),
          ]),
        );

        controller.start(startedAt: startedAt);
        controller.advanceBy(const Duration(seconds: 10));
        final distanceBeforePause = controller.state.distanceMeters;
        controller.pause();
        controller.resume();
        controller.advanceBy(const Duration(seconds: 10));

        expect(controller.mapViewState.routeSegments, hasLength(2));
        expect(controller.state.distanceMeters, distanceBeforePause);
        expect(
          controller.mapViewState.routeSegments.map((segment) {
            return segment.map((sample) => sample.latitude).toList();
          }),
          [
            [1.300000, 1.300100],
            [1.300200],
          ],
        );
        expect(controller.mapViewState.currentPosition?.latitude, 1.300200);

        controller.advanceBy(const Duration(seconds: 10));

        expect(controller.mapViewState.routeSegments, hasLength(2));
        expect(
          controller.state.distanceMeters,
          greaterThan(distanceBeforePause),
        );
        expect(
          controller.mapViewState.routeSegments.map((segment) {
            return segment.map((sample) => sample.latitude).toList();
          }),
          [
            [1.300000, 1.300100],
            [1.300200, 1.300300],
          ],
        );
      },
    );
  });
}
