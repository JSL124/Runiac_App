import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_map_view_state.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_map_placeholder.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_mapbox_follow_qa_overlay.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_mapbox_geometry.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_mapbox_run_map.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_mapbox_surface_config.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_tracking_map_surface.dart';

const _demoMapboxPublicToken =
    'p'
    'k.demo-public-token';

void main() {
  group('RunTrackingMapSurface Mapbox boundary', () {
    testWidgets('missing token renders placeholder fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.expand(
            child: RunTrackingMapSurface(mapboxAccessToken: ''),
          ),
        ),
      );

      expect(find.byType(RunMapPlaceholder), findsOneWidget);
      expect(
        find.byKey(const Key('run_mapbox_placeholder_selected')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('run_mapbox_surface_selected')),
        findsNothing,
      );
      expect(find.byKey(const Key('run_mapbox_surface')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid token renders placeholder fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.expand(
            child: RunTrackingMapSurface(
              mapboxAccessToken: 'demo-public-token',
            ),
          ),
        ),
      );

      expect(find.byType(RunMapPlaceholder), findsOneWidget);
      expect(
        find.byKey(const Key('run_mapbox_placeholder_selected')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('run_mapbox_surface_selected')),
        findsNothing,
      );
      expect(find.byKey(const Key('run_mapbox_surface')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'token-present path selects injectable Mapbox surface without platform view',
      (tester) async {
        RunMapboxSurfaceConfig? capturedConfig;

        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox.expand(
              child: RunTrackingMapSurface(
                mapboxAccessToken: _demoMapboxPublicToken,
                recenterRequestId: 7,
                mapboxBuilder: (context, config) {
                  capturedConfig = config;
                  return const ColoredBox(
                    key: Key('fake_mapbox_surface'),
                    color: Colors.black,
                  );
                },
              ),
            ),
          ),
        );

        expect(find.byType(RunMapPlaceholder), findsNothing);
        expect(
          find.byKey(const Key('run_mapbox_placeholder_selected')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('run_mapbox_surface_selected')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('fake_mapbox_surface')), findsOneWidget);
        expect(capturedConfig, isNotNull);
        expect(capturedConfig!.accessToken, _demoMapboxPublicToken);
        expect(capturedConfig!.recenterRequestId, 7);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('follow QA overlay is hidden by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.expand(
            child: RunTrackingMapSurface(mapboxAccessToken: ''),
          ),
        ),
      );

      expect(
        find.byKey(const Key('run_mapbox_follow_qa_overlay')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'follow QA overlay shows non-sensitive diagnostics when enabled',
      (tester) async {
        final diagnostics = RunMapboxFollowQaDiagnostics(
          enabled: true,
          screenPath: 'launch',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox.expand(
              child: RunTrackingMapSurface(
                mapboxAccessToken: _demoMapboxPublicToken,
                isFollowingRunner: false,
                recenterRequestId: 3,
                followQaDiagnostics: diagnostics,
                mapboxBuilder: (context, config) {
                  return const ColoredBox(
                    key: Key('fake_mapbox_surface'),
                    color: Colors.black,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();

        diagnostics
          ..recordMapboxGestureCallback()
          ..recordPointerObserverMove()
          ..recordManualGesture()
          ..recordOnManualPan()
          ..recordCameraMoveRequest(
            shouldMoveCamera: false,
            reason: 'skipped',
            generation: 2,
          )
          ..recordRouteSync(isFollowingRunner: false)
          ..recordMarkerSync(isFollowingRunner: false)
          ..recordCameraMoveSkipped(
            shouldMoveCamera: false,
            generation: 2,
            isFollowingRunner: false,
          )
          ..recordCameraMove(shouldMoveCamera: true, generation: 3)
          ..recordCameraCancel(interruptGeneration: 4)
          ..recordCameraStateSample(
            latitude: 1.300899,
            longitude: 103.800000,
            isFollowingRunner: false,
          )
          ..recordCameraStateSample(
            latitude: 1.300999,
            longitude: 103.800000,
            isFollowingRunner: false,
          )
          ..recordResume();
        await tester.pump();

        expect(
          find.byKey(const Key('run_mapbox_follow_qa_overlay')),
          findsOneWidget,
        );
        expect(find.text('map: mapbox'), findsOneWidget);
        expect(find.text('screen: launch'), findsOneWidget);
        expect(find.text('follow: OFF'), findsOneWidget);
        expect(find.text('manual gesture: 1'), findsOneWidget);
        expect(find.text('mapbox cb: 1'), findsOneWidget);
        expect(find.text('pointer move: 1'), findsOneWidget);
        expect(find.text('onManualPan: 1'), findsOneWidget);
        expect(find.text('shouldMoveCamera: false'), findsOneWidget);
        expect(find.text('camera move: 1 should: true'), findsOneWidget);
        expect(find.text('camera cancel: 1'), findsOneWidget);
        expect(find.text('camera sample: 2'), findsOneWidget);
        expect(find.text('center changed: yes'), findsOneWidget);
        expect(find.text('center change count: 1'), findsOneWidget);
        expect(find.text('camera source: unknown/native'), findsOneWidget);
        expect(find.text('camera reason: skipped'), findsOneWidget);
        expect(find.text('unknown/native: 1'), findsOneWidget);
        expect(find.text('route sync: 1'), findsOneWidget);
        expect(find.text('marker sync: 1'), findsOneWidget);
        expect(find.text('camera skipped: 1'), findsOneWidget);
        expect(find.text('follow-off route sync: 1'), findsOneWidget);
        expect(find.text('follow-off marker sync: 1'), findsOneWidget);
        expect(find.text('follow-off skipped: 1'), findsOneWidget);
        expect(find.text('camera gen: 3'), findsOneWidget);
        expect(find.text('interrupt gen: 4'), findsOneWidget);
        expect(find.text('follow-off gen: 1'), findsOneWidget);
        expect(find.text('recenter id: 3'), findsOneWidget);
        expect(find.text('resume: 1'), findsOneWidget);

        final visibleText = tester
            .widgetList<Text>(find.byType(Text))
            .map((widget) => widget.data ?? '')
            .join('\n');
        expect(visibleText, isNot(contains(_demoMapboxPublicToken)));
        expect(visibleText, isNot(contains('http')));
        expect(visibleText, isNot(contains('103.')));
        expect(visibleText, isNot(contains('1.300')));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Mapbox pointer fallback invokes manual interaction callback', (
      tester,
    ) async {
      var manualInteractions = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RunMapboxManualGestureObserver(
            isFollowingRunner: true,
            followQaDiagnostics: null,
            onManualMapInteraction: () {
              manualInteractions++;
            },
            child: const SizedBox.expand(
              child: ColoredBox(
                key: Key('fake_mapbox_pointer_layer'),
                color: Colors.black,
              ),
            ),
          ),
        ),
      );

      await tester.drag(
        find.byKey(const Key('fake_mapbox_pointer_layer')),
        const Offset(48, 0),
      );
      await tester.pump();

      expect(manualInteractions, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'manual pan disables follow and recenter restores camera intent',
      (tester) async {
        var isFollowingRunner = true;
        var recenterCameraRequests = 0;
        final startedAt = DateTime.utc(2026, 6, 14, 7);
        final mapViewState = RunMapViewState(
          currentPosition: RunLocationSample(
            recordedAt: startedAt,
            latitude: 1.300899,
            longitude: 103.800000,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox.expand(
                  child: RunTrackingMapSurface(
                    mapViewState: mapViewState,
                    isFollowingRunner: isFollowingRunner,
                    mapboxAccessToken: _demoMapboxPublicToken,
                    onManualPan: () {
                      setState(() => isFollowingRunner = false);
                    },
                    onRecenter: () {
                      setState(() {
                        isFollowingRunner = true;
                        if (RunMapboxCameraRequest.forCurrentPosition(
                              mapViewState,
                            ) !=
                            null) {
                          recenterCameraRequests++;
                        }
                      });
                    },
                    mapboxBuilder: (context, config) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              key: const Key('fake_mapbox_pan_layer'),
                              onPanUpdate: (_) => config.onManualPan?.call(),
                              child: const ColoredBox(color: Colors.black),
                            ),
                          ),
                          if (!config.isFollowingRunner &&
                              config.onRecenter != null)
                            RunMapRecenterButton(onPressed: config.onRecenter!),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(find.byKey(const Key('run_map_recenter_button')), findsNothing);

        await tester.drag(
          find.byKey(const Key('fake_mapbox_pan_layer')),
          const Offset(40, 0),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('run_map_recenter_button')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('run_map_recenter_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('run_map_recenter_button')), findsNothing);
        expect(recenterCameraRequests, 1);
        expect(tester.takeException(), isNull);
      },
    );

    test(
      'real Mapbox surface wires move and zoom gestures to follow disable',
      () {
        final source = File(
          'lib/features/run/presentation/widgets/run_mapbox_run_map.dart',
        ).readAsStringSync();

        expect(source, contains('onScrollListener: _handleManualGesture'));
        expect(source, contains('onZoomListener: _handleManualGesture'));
        expect(
          source,
          contains('onCameraChangeListener: _handleCameraChanged'),
        );

        expect(source, contains('RunMapboxManualGestureObserver('));
        expect(
          source,
          contains('onManualMapInteraction: _handleManualMapInteraction'),
        );
      },
    );

    test(
      'real Mapbox surface keeps viewport initial-only instead of rebuild-driven',
      () {
        final source = File(
          'lib/features/run/presentation/widgets/run_mapbox_run_map.dart',
        ).readAsStringSync();

        expect(
          source,
          contains('late final CameraViewportState _initialViewport'),
        );
        expect(source, contains('viewport: _initialViewport'));
        expect(source, isNot(contains('viewport: _initialViewport()')));
      },
    );
  });

  group('RunMapboxSyncCoordinator', () {
    test(
      'replays the latest pending state after in-flight sync finishes',
      () async {
        final target = _FakeRunMapboxSyncTarget();
        final coordinator = RunMapboxSyncCoordinator(target);
        final firstBlocker = Completer<void>();
        target.nextBlocker = firstBlocker;

        final startedAt = DateTime.utc(2026, 6, 14, 7);
        RunMapboxSyncRequest request(double latitude) {
          return RunMapboxSyncRequest(
            mapViewState: RunMapViewState(
              currentPosition: RunLocationSample(
                recordedAt: startedAt,
                latitude: latitude,
                longitude: 103.8,
              ),
            ),
            isFollowingRunner: true,
          );
        }

        final firstSync = coordinator.sync(request(1.300000));
        await Future<void>.delayed(Duration.zero);

        expect(target.appliedLatitudes, <double>[1.300000]);

        unawaited(coordinator.sync(request(1.301000)));
        unawaited(coordinator.sync(request(1.302000)));
        await Future<void>.delayed(Duration.zero);

        expect(target.appliedLatitudes, <double>[1.300000]);

        firstBlocker.complete();
        await firstSync;

        expect(target.appliedLatitudes, <double>[1.300000, 1.302000]);
      },
    );

    test('cleans up the map adapter and ignores later sync requests', () async {
      final target = _FakeRunMapboxSyncTarget();
      final coordinator = RunMapboxSyncCoordinator(target);

      await coordinator.dispose();
      await coordinator.sync(
        const RunMapboxSyncRequest(
          mapViewState: RunMapViewState.empty(),
          isFollowingRunner: true,
        ),
      );

      expect(target.disposeCalls, 1);
      expect(target.appliedLatitudes, isEmpty);
    });

    test('dispose waits for an in-flight sync before cleanup', () async {
      final target = _FakeRunMapboxSyncTarget();
      final coordinator = RunMapboxSyncCoordinator(target);
      final blocker = Completer<void>();
      target.nextBlocker = blocker;

      final syncFuture = coordinator.sync(_syncRequest(1.300000));
      await Future<void>.delayed(Duration.zero);

      final disposeFuture = coordinator.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(target.appliedLatitudes, <double>[1.300000]);
      expect(target.disposeCalls, 0);

      blocker.complete();
      await syncFuture;
      await disposeFuture;

      expect(target.disposeCalls, 1);
    });

    test(
      'cancels camera animation without waiting for in-flight sync',
      () async {
        final target = _FakeRunMapboxSyncTarget();
        final coordinator = RunMapboxSyncCoordinator(target);
        final blocker = Completer<void>();
        target.nextBlocker = blocker;

        final syncFuture = coordinator.sync(_syncRequest(1.300000));
        await Future<void>.delayed(Duration.zero);

        await coordinator.cancelCameraAnimation();

        expect(target.appliedLatitudes, <double>[1.300000]);
        expect(target.cancelCameraAnimationCalls, 1);

        blocker.complete();
        await syncFuture;
      },
    );

    test(
      'dispose clears pending sync replay while apply is in flight',
      () async {
        final target = _FakeRunMapboxSyncTarget();
        final coordinator = RunMapboxSyncCoordinator(target);
        final blocker = Completer<void>();
        target.nextBlocker = blocker;

        final syncFuture = coordinator.sync(_syncRequest(1.300000));
        await Future<void>.delayed(Duration.zero);

        unawaited(coordinator.sync(_syncRequest(1.301000)));
        unawaited(coordinator.sync(_syncRequest(1.302000)));
        final disposeFuture = coordinator.dispose();

        blocker.complete();
        await syncFuture;
        await disposeFuture;

        expect(target.appliedLatitudes, <double>[1.300000]);
        expect(target.disposeCalls, 1);
      },
    );

    test('dispose is idempotent and no apply runs after disposal', () async {
      final target = _FakeRunMapboxSyncTarget();
      final coordinator = RunMapboxSyncCoordinator(target);

      await coordinator.dispose();
      await coordinator.dispose();
      await coordinator.sync(_syncRequest(1.300000));

      expect(target.disposeCalls, 1);
      expect(target.appliedLatitudes, isEmpty);
    });
  });

  group('RunMapboxStyleReadySyncController', () {
    test('defers native sync until the Mapbox style is loaded', () async {
      final target = _FakeRunMapboxSyncTarget();
      final controller = RunMapboxStyleReadySyncController(
        RunMapboxSyncCoordinator(target),
      );

      await controller.sync(_syncRequest(1.300899));

      expect(target.appliedLatitudes, isEmpty);

      await controller.markStyleLoaded();

      expect(target.appliedLatitudes, <double>[1.300899]);
    });

    test(
      'applies only the latest pending state when style becomes ready',
      () async {
        final target = _FakeRunMapboxSyncTarget();
        final controller = RunMapboxStyleReadySyncController(
          RunMapboxSyncCoordinator(target),
        );

        await controller.sync(
          const RunMapboxSyncRequest(
            mapViewState: RunMapViewState.empty(),
            isFollowingRunner: true,
          ),
        );
        await controller.sync(_syncRequest(1.301234));

        await controller.markStyleLoaded();

        expect(target.appliedLatitudes, <double>[1.301234]);
      },
    );

    test('syncs null-to-non-null currentPosition after style load', () async {
      final target = _FakeRunMapboxSyncTarget();
      final controller = RunMapboxStyleReadySyncController(
        RunMapboxSyncCoordinator(target),
      );

      await controller.markStyleLoaded();
      await controller.sync(
        const RunMapboxSyncRequest(
          mapViewState: RunMapViewState.empty(),
          isFollowingRunner: true,
        ),
      );
      await controller.sync(_syncRequest(1.302345));

      expect(target.appliedLatitudes, <double?>[null, 1.302345]);
    });

    test('syncs marker state even when camera follow is disabled', () async {
      final target = _FakeRunMapboxSyncTarget();
      final controller = RunMapboxStyleReadySyncController(
        RunMapboxSyncCoordinator(target),
      );
      await controller.markStyleLoaded();

      await controller.sync(
        RunMapboxSyncRequest(
          mapViewState: _viewStateWithCurrentPosition(1.303456),
          isFollowingRunner: false,
        ),
      );

      expect(target.appliedLatitudes, <double>[1.303456]);
      expect(target.appliedFollowStates, <bool>[false]);
      expect(target.appliedCameraMoveIntents, <bool>[false]);
    });

    test(
      'forwards manual gesture camera cancellation to the native seam',
      () async {
        final target = _FakeRunMapboxSyncTarget();
        final controller = RunMapboxStyleReadySyncController(
          RunMapboxSyncCoordinator(target),
        );

        await controller.cancelCameraAnimation();

        expect(target.cancelCameraAnimationCalls, 1);
        expect(target.appliedLatitudes, isEmpty);
      },
    );

    test('allows camera movement only for follow or explicit recenter', () {
      expect(
        RunMapboxSyncRequest(
          mapViewState: _viewStateWithCurrentPosition(1.300899),
          isFollowingRunner: true,
        ).shouldMoveCamera,
        isTrue,
      );
      expect(
        RunMapboxSyncRequest(
          mapViewState: _viewStateWithCurrentPosition(1.300899),
          isFollowingRunner: false,
        ).shouldMoveCamera,
        isFalse,
      );
      expect(
        RunMapboxSyncRequest(
          mapViewState: _viewStateWithCurrentPosition(1.300899),
          isFollowingRunner: false,
          animateCamera: true,
        ).shouldMoveCamera,
        isTrue,
      );
    });

    test('reports camera request reason without exposing coordinates', () {
      expect(
        RunMapboxSyncRequest(
          mapViewState: _viewStateWithCurrentPosition(1.300899),
          isFollowingRunner: true,
        ).cameraMoveReason,
        'follow',
      );
      expect(
        RunMapboxSyncRequest(
          mapViewState: _viewStateWithCurrentPosition(1.300899),
          isFollowingRunner: false,
        ).cameraMoveReason,
        'skipped',
      );
      expect(
        RunMapboxSyncRequest(
          mapViewState: _viewStateWithCurrentPosition(1.300899),
          isFollowingRunner: false,
          animateCamera: true,
        ).cameraMoveReason,
        'recenter',
      );
    });

    test(
      'camera diagnostics mark unknown native movement while follow is off',
      () {
        final diagnostics = RunMapboxFollowQaDiagnostics(
          enabled: true,
          screenPath: 'active',
        );

        diagnostics
          ..updateMapState(
            mapPath: 'mapbox',
            isFollowingRunner: false,
            recenterRequestId: 0,
          )
          ..recordCameraStateSample(
            latitude: 1.300899,
            longitude: 103.800000,
            isFollowingRunner: false,
          )
          ..recordCameraStateSample(
            latitude: 1.300999,
            longitude: 103.800000,
            isFollowingRunner: false,
          );

        expect(diagnostics.cameraStateSampleCount, 2);
        expect(diagnostics.cameraCenterChangedCount, 1);
        expect(diagnostics.cameraCenterChanged, isTrue);
        expect(diagnostics.unknownNativeCameraChangeCount, 1);
        expect(diagnostics.lastCameraMovementSource, 'unknown/native');
      },
    );

    test('camera interrupt gate rejects stale in-flight camera moves', () {
      final gate = RunMapboxCameraInterruptGate();
      final beforeManualGesture = gate.capture();

      gate.interrupt();

      expect(gate.allows(beforeManualGesture), isFalse);
      expect(gate.allows(gate.capture()), isTrue);
    });
  });

  group('RunMapboxRunnerMarkerAnnotation', () {
    test('does not create a runner marker without currentPosition', () {
      expect(
        RunMapboxRunnerMarkerAnnotation.fromViewState(
          const RunMapViewState.empty(),
        ),
        isNull,
      );
    });

    test('does not use fallback camera coordinates as runner marker', () {
      final fallbackCamera = RunMapboxCameraRequest.initialForMapViewState(
        const RunMapViewState.empty(),
      );

      expect(fallbackCamera.center, RunMapboxCameraRequest.fallbackCenter);
      expect(
        RunMapboxRunnerMarkerAnnotation.fromViewState(
          const RunMapViewState.empty(),
        ),
        isNull,
      );
    });

    test('creates a visible runner circle from currentPosition', () {
      final options = RunMapboxRunnerMarkerAnnotation.fromViewState(
        _viewStateWithCurrentPosition(1.300899, longitude: 103.812345),
      );

      expect(options, isNotNull);
      expect(options!.circleRadius, 12);
      expect(options.circleStrokeWidth, 4);
      expect(options.circleSortKey, 1000);
      expect(options.circleColor, const Color(0xFFFF6818).toARGB32());
      expect(options.circleStrokeColor, Colors.white.toARGB32());
      expect(options.geometry.toJson()['coordinates'], <double>[
        103.812345,
        1.300899,
      ]);
    });
  });

  group('RunMapboxGeometry', () {
    test('initial camera uses current position when GPS is available', () {
      // Given: a run map state with a current GPS sample.
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final viewState = RunMapViewState(
        currentPosition: RunLocationSample(
          recordedAt: startedAt,
          latitude: 1.301234,
          longitude: 103.812345,
        ),
      );

      // When: Mapbox derives its initial camera.
      final request = RunMapboxCameraRequest.initialForMapViewState(viewState);

      // Then: the camera starts at the runner location, not the fallback.
      expect(request.center.latitude, 1.301234);
      expect(request.center.longitude, 103.812345);
      expect(request.zoom, 16);
    });

    test('initial camera uses local fallback while GPS is unavailable', () {
      // Given: no current GPS sample has arrived yet.
      const viewState = RunMapViewState.empty();

      // When: Mapbox derives its initial camera.
      final request = RunMapboxCameraRequest.initialForMapViewState(viewState);

      // Then: it uses the presentation-only local fallback, not a world view.
      expect(request.center, RunMapboxCameraRequest.fallbackCenter);
      expect(request.zoom, 14);
    });

    test('current position camera becomes available after GPS transition', () {
      // Given: GPS is initially unavailable.
      const waitingForGps = RunMapViewState.empty();
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final gpsReady = RunMapViewState(
        currentPosition: RunLocationSample(
          recordedAt: startedAt,
          latitude: 1.300899,
          longitude: 103.800000,
        ),
      );

      // When: the camera request is derived before and after GPS arrives.
      final beforeGps = RunMapboxCameraRequest.forCurrentPosition(
        waitingForGps,
      );
      final afterGps = RunMapboxCameraRequest.forCurrentPosition(gpsReady);

      // Then: runtime camera movement remains gated on real current position.
      expect(beforeGps, isNull);
      expect(afterGps, isNotNull);
      expect(afterGps!.center.position, <double>[103.800000, 1.300899]);
    });

    test('uses longitude-first Mapbox coordinate ordering', () {
      final coordinate = RunMapboxCoordinate.fromSample(
        RunLocationSample(
          recordedAt: DateTime.utc(2026, 6, 14, 7),
          latitude: 1.300899,
          longitude: 103.800000,
        ),
      );

      expect(coordinate.position, <double>[103.800000, 1.300899]);
    });

    test('keeps route segments separate for pause and resume gaps', () {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      RunLocationSample sample(int seconds, double latitude) {
        return RunLocationSample(
          recordedAt: startedAt.add(Duration(seconds: seconds)),
          latitude: latitude,
          longitude: 103.800000,
        );
      }

      final geometry = RunMapboxRouteGeometry.fromViewState(
        RunMapViewState(
          routeSegments: [
            [sample(0, 1.300000), sample(60, 1.300899)],
            [sample(180, 1.301100), sample(240, 1.301500)],
          ],
        ),
      );

      expect(geometry.segments, hasLength(2));
      expect(geometry.segments.first.map((point) => point.position), [
        <double>[103.800000, 1.300000],
        <double>[103.800000, 1.300899],
      ]);
      expect(geometry.segments.last.map((point) => point.position), [
        <double>[103.800000, 1.301100],
        <double>[103.800000, 1.301500],
      ]);
    });
  });

  test('Mapbox surface and adapter do not import each other cyclically', () {
    final surfaceSource = File(
      'lib/features/run/presentation/widgets/run_tracking_map_surface.dart',
    ).readAsStringSync();
    final adapterSource = File(
      'lib/features/run/presentation/widgets/run_mapbox_run_map.dart',
    ).readAsStringSync();

    expect(surfaceSource, contains("import 'run_mapbox_run_map.dart';"));
    expect(surfaceSource, contains("import 'run_mapbox_surface_config.dart';"));
    expect(
      adapterSource,
      isNot(contains("import 'run_tracking_map_surface.dart';")),
    );
    expect(adapterSource, contains("import 'run_mapbox_surface_config.dart';"));
  });
}

RunMapboxSyncRequest _syncRequest(double latitude) {
  return RunMapboxSyncRequest(
    mapViewState: _viewStateWithCurrentPosition(latitude),
    isFollowingRunner: true,
  );
}

RunMapViewState _viewStateWithCurrentPosition(
  double latitude, {
  double longitude = 103.8,
}) {
  return RunMapViewState(
    currentPosition: RunLocationSample(
      recordedAt: DateTime.utc(2026, 6, 14, 7),
      latitude: latitude,
      longitude: longitude,
    ),
  );
}

class _FakeRunMapboxSyncTarget implements RunMapboxSyncTarget {
  final List<double?> appliedLatitudes = <double?>[];
  final List<bool> appliedFollowStates = <bool>[];
  final List<bool> appliedCameraMoveIntents = <bool>[];
  Completer<void>? nextBlocker;
  int cancelCameraAnimationCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> apply(RunMapboxSyncRequest request) async {
    appliedLatitudes.add(request.mapViewState.currentPosition?.latitude);
    appliedFollowStates.add(request.isFollowingRunner);
    appliedCameraMoveIntents.add(request.shouldMoveCamera);
    final blocker = nextBlocker;
    nextBlocker = null;
    if (blocker != null) {
      await blocker.future;
    }
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }

  @override
  Future<void> cancelCameraAnimation() async {
    cancelCameraAnimationCalls++;
  }
}
