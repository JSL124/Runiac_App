import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_location_permission_status.dart';
import 'package:runiac_app/features/run/domain/models/run_map_view_state.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_diagnostics.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_permission_service.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_preview_provider.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_provider.dart';
import 'package:runiac_app/features/run/presentation/run_active_screen.dart';
import 'package:runiac_app/features/run/presentation/run_launch_screen.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_map_placeholder.dart';
import 'package:runiac_app/features/run/presentation/widgets/run_mapbox_surface_config.dart';

const _demoMapboxPublicToken =
    'p'
    'k.demo-public-token';

void _useMobileRunSurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void _useNarrowRunSurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(360, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void _expectStatusLabelReadable(WidgetTester tester, String label) {
  final textFinder = find.text(label);
  expect(textFinder, findsOneWidget);

  final text = tester.widget<Text>(textFinder);
  expect(text.overflow, isNot(TextOverflow.ellipsis));
  expect(text.maxLines, 1);
}

void _expectSheetAdjacentRecenter({
  required WidgetTester tester,
  required Finder recenter,
  required Finder sheet,
}) {
  final gap = tester.getRect(sheet).top - tester.getRect(recenter).bottom;
  expect(gap, inInclusiveRange(8, 12));
}

Future<void> _openRunLaunch(WidgetTester tester) async {
  await tester.pumpWidget(
    const RuniacApp(showSplash: false, enableForegroundGps: false),
  );
  await tester.tap(find.text('Run'));
  await tester.pumpAndSettle();
}

Future<void> _openDefaultRunLaunch(WidgetTester tester) async {
  await tester.pumpWidget(const RuniacApp(showSplash: false));
  await tester.tap(find.text('Run'));
  await tester.pumpAndSettle();
}

class _RoutePushRecorder extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

class _GrantedRunLocationPermissionService
    implements RunLocationPermissionService {
  const _GrantedRunLocationPermissionService();

  @override
  Future<RunLocationPermissionStatus> checkStatus() async {
    return RunLocationPermissionStatus.granted;
  }

  @override
  Future<RunLocationPermissionStatus> requestPermission() async {
    return RunLocationPermissionStatus.granted;
  }
}

class _ConfigurableRunLocationPermissionService
    implements RunLocationPermissionService {
  _ConfigurableRunLocationPermissionService({
    required this.checkedStatus,
    RunLocationPermissionStatus? requestedStatus,
  }) : requestedStatus = requestedStatus ?? checkedStatus;

  RunLocationPermissionStatus checkedStatus;
  RunLocationPermissionStatus requestedStatus;
  int checkCount = 0;
  int requestCount = 0;

  @override
  Future<RunLocationPermissionStatus> checkStatus() async {
    checkCount += 1;
    return checkedStatus;
  }

  @override
  Future<RunLocationPermissionStatus> requestPermission() async {
    requestCount += 1;
    checkedStatus = requestedStatus;
    return requestedStatus;
  }
}

class _FakeRunLocationPreviewProvider implements RunLocationPreviewProvider {
  _FakeRunLocationPreviewProvider({required this.sample});

  final RunLocationSample sample;
  int requestCount = 0;

  @override
  Future<RunLocationSample> currentLocation() async {
    requestCount += 1;
    return sample;
  }
}

RunLocationSample _previewSample() {
  return RunLocationSample(
    recordedAt: DateTime.utc(2026, 6, 14, 7),
    latitude: 1.3009,
    longitude: 103.8,
    horizontalAccuracyMeters: 5,
  );
}

void main() {
  testWidgets('Run launch top GPS pill fits GPS ready on narrow phones', (
    WidgetTester tester,
  ) async {
    _useNarrowRunSurface(tester);
    final previewProvider = _FakeRunLocationPreviewProvider(
      sample: _previewSample(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          locationProvider: ReplayRunLocationProvider(const []),
          locationPreviewProvider: previewProvider,
          permissionService: const _GrantedRunLocationPermissionService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectStatusLabelReadable(tester, 'GPS ready');
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Run settings'), findsOneWidget);

    await tester.tap(find.byTooltip('Run settings'));
    await tester.pumpAndSettle();

    expect(find.text('Run settings preview is coming soon.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch top GPS pill keeps active labels readable', (
    WidgetTester tester,
  ) async {
    _useNarrowRunSurface(tester);
    final sampleBase = DateTime.now().add(const Duration(days: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          locationProvider: ReplayRunLocationProvider([
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 1),
              sample: RunLocationSample(
                recordedAt: sampleBase.add(const Duration(seconds: 1)),
                latitude: 1.3,
                longitude: 103.8,
                horizontalAccuracyMeters: 5,
              ),
            ),
          ]),
          locationPreviewProvider: _FakeRunLocationPreviewProvider(
            sample: _previewSample(),
          ),
          permissionService: const _GrantedRunLocationPermissionService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    _expectStatusLabelReadable(tester, 'GPS active');
    expect(find.text('Start run'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch top GPS pill handles approximate location label', (
    WidgetTester tester,
  ) async {
    _useNarrowRunSurface(tester);
    final sampleBase = DateTime.now().add(const Duration(days: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          locationProvider: ReplayRunLocationProvider([
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 1),
              sample: RunLocationSample(
                recordedAt: sampleBase.add(const Duration(seconds: 1)),
                latitude: 1.3,
                longitude: 103.8,
                horizontalAccuracyMeters: 5,
              ),
            ),
          ], locationAccuracyStatus: RunTrackingLocationAccuracyStatus.reduced),
          locationPreviewProvider: _FakeRunLocationPreviewProvider(
            sample: _previewSample(),
          ),
          permissionService: const _GrantedRunLocationPermissionService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    _expectStatusLabelReadable(tester, 'Approximate location');
    expect(find.text('Start run'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('default Run tab enters foreground GPS mode', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);

    await _openDefaultRunLaunch(tester);

    expect(find.byType(RunLaunchScreen), findsOneWidget);
    expect(find.text('Demo mode'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch Start run updates sheet without pushing a route', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final observer = _RoutePushRecorder();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const RunLaunchScreen(enableForegroundGps: false),
      ),
    );
    await tester.pumpAndSettle();
    observer.pushedRoutes.clear();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Run settings'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsNothing);
    expect(find.text('DISTANCE'), findsNothing);
    expect(find.text('TIME'), findsNothing);
    expect(find.text('AVG PACE'), findsNothing);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    expect(observer.pushedRoutes, isEmpty);
    expect(find.byType(RunLaunchScreen), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
    expect(find.byTooltip('Run settings'), findsNothing);
    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsNothing);
    expect(find.text('Start run'), findsNothing);
    expect(find.text('0.00 of 4.50 km'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch real GPS path waits without showing demo mode', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          locationProvider: ReplayRunLocationProvider(const []),
          locationPreviewProvider: _FakeRunLocationPreviewProvider(
            sample: _previewSample(),
          ),
          permissionService: const _GrantedRunLocationPermissionService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('Demo mode'), findsNothing);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Waiting for GPS'), findsOneWidget);
    expect(find.text('Demo mode'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch real GPS path becomes active after accepted sample', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final sampleBase = DateTime.now().add(const Duration(days: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          locationProvider: ReplayRunLocationProvider([
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 1),
              sample: RunLocationSample(
                recordedAt: sampleBase.add(const Duration(seconds: 1)),
                latitude: 1.3,
                longitude: 103.8,
                horizontalAccuracyMeters: 5,
              ),
            ),
          ]),
          locationPreviewProvider: _FakeRunLocationPreviewProvider(
            sample: _previewSample(),
          ),
          permissionService: const _GrantedRunLocationPermissionService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('GPS active'), findsOneWidget);
    expect(
      find.text('GPS is ready. Start moving to measure distance.'),
      findsNothing,
    );
    expect(find.text('Demo mode'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch real GPS path shows weak after rejected accuracy', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final sampleBase = DateTime.now().add(const Duration(days: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          locationProvider: ReplayRunLocationProvider([
            RunLocationReplaySample(
              activeOffset: const Duration(seconds: 1),
              sample: RunLocationSample(
                recordedAt: sampleBase.add(const Duration(seconds: 1)),
                latitude: 1.3,
                longitude: 103.8,
                horizontalAccuracyMeters: 250,
              ),
            ),
          ]),
          locationPreviewProvider: _FakeRunLocationPreviewProvider(
            sample: _previewSample(),
          ),
          permissionService: const _GrantedRunLocationPermissionService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('GPS weak'), findsOneWidget);
    expect(
      find.text('GPS signal is weak. Keep moving in an open area.'),
      findsNothing,
    );
    expect(find.text('Demo mode'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'RunMapPlaceholder renders local route polyline and runner marker',
    (WidgetTester tester) async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox.expand(
            child: RunMapPlaceholder(
              mapViewState: RunMapViewState(
                currentPosition: RunLocationSample(
                  recordedAt: startedAt.add(const Duration(seconds: 60)),
                  latitude: 1.300899,
                  longitude: 103.800000,
                ),
                routeSegments: [
                  [
                    RunLocationSample(
                      recordedAt: startedAt,
                      latitude: 1.300000,
                      longitude: 103.800000,
                    ),
                    RunLocationSample(
                      recordedAt: startedAt.add(const Duration(seconds: 60)),
                      latitude: 1.300899,
                      longitude: 103.800000,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('run_map_route_polyline')), findsOneWidget);
      expect(find.byKey(const Key('run_map_runner_marker')), findsOneWidget);
      expect(find.byKey(const Key('run_map_recenter_button')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'RunMapPlaceholder manual pan shows recenter and recenter restores follow',
    (WidgetTester tester) async {
      var isFollowingRunner = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox.expand(
                child: RunMapPlaceholder(
                  isFollowingRunner: isFollowingRunner,
                  onManualPan: () {
                    setState(() => isFollowingRunner = false);
                  },
                  onRecenter: () {
                    setState(() => isFollowingRunner = true);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.byKey(const Key('run_map_recenter_button')), findsNothing);

      await tester.drag(
        find.byKey(const Key('run_map_interaction_layer')),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('run_map_recenter_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('run_map_recenter_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('run_map_recenter_button')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('RunLaunchScreen shows persistent recenter above the sheet', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);

    await tester.pumpWidget(
      const MaterialApp(home: RunLaunchScreen(enableForegroundGps: false)),
    );
    await tester.pumpAndSettle();

    var recenter = find.byKey(const Key('run_map_recenter_button'));
    var sheet = find.byKey(const Key('runLaunchBottomSheet'));
    final switchRoute = find.text('Switch route');
    expect(recenter, findsOneWidget);
    _expectSheetAdjacentRecenter(
      tester: tester,
      recenter: recenter,
      sheet: sheet,
    );
    expect(find.text('Switch route'), findsOneWidget);
    expect(
      tester.getRect(sheet).right - tester.getRect(recenter).right,
      closeTo(28, 1),
    );
    expect(
      tester.getRect(recenter).overlaps(tester.getRect(switchRoute)),
      isFalse,
    );

    await tester.drag(
      find.byKey(const Key('run_map_interaction_layer')),
      const Offset(48, 0),
    );
    await tester.pump();

    recenter = find.byKey(const Key('run_map_recenter_button'));
    sheet = find.byKey(const Key('runLaunchBottomSheet'));
    expect(recenter, findsOneWidget);
    _expectSheetAdjacentRecenter(
      tester: tester,
      recenter: recenter,
      sheet: sheet,
    );

    await tester.tap(recenter);
    await tester.pump();

    expect(find.byKey(const Key('run_map_recenter_button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'RunLaunchScreen recenter is a gentle no-op before current location',
    (WidgetTester tester) async {
      _useMobileRunSurface(tester);
      final permissionService = _ConfigurableRunLocationPermissionService(
        checkedStatus: RunLocationPermissionStatus.deniedForever,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(permissionService: permissionService),
        ),
      );
      await tester.pump();

      final recenter = find.byKey(const Key('run_map_recenter_button'));
      expect(recenter, findsOneWidget);

      await tester.tap(recenter);
      await tester.pump();

      expect(find.byKey(const Key('run_map_recenter_button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'RunLaunchScreen does not request permission on entry when denied',
    (WidgetTester tester) async {
      _useMobileRunSurface(tester);
      final permissionService = _ConfigurableRunLocationPermissionService(
        checkedStatus: RunLocationPermissionStatus.denied,
      );
      final previewProvider = _FakeRunLocationPreviewProvider(
        sample: _previewSample(),
      );
      RunMapboxSurfaceConfig? capturedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            locationPreviewProvider: previewProvider,
            permissionService: permissionService,
            mapboxAccessToken: _demoMapboxPublicToken,
            mapboxBuilder: (context, config) {
              capturedConfig = config;
              return const ColoredBox(color: Colors.black);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(permissionService.checkCount, 1);
      expect(permissionService.requestCount, 0);
      expect(previewProvider.requestCount, 0);
      expect(find.text('Tap location'), findsOneWidget);
      expect(capturedConfig?.mapViewState.currentPosition, isNull);
      expect(find.byKey(const Key('run_map_recenter_button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'RunLaunchScreen granted entry fetches preview current position for map',
    (WidgetTester tester) async {
      _useMobileRunSurface(tester);
      final permissionService = _ConfigurableRunLocationPermissionService(
        checkedStatus: RunLocationPermissionStatus.granted,
      );
      final previewProvider = _FakeRunLocationPreviewProvider(
        sample: _previewSample(),
      );
      RunMapboxSurfaceConfig? capturedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            locationProvider: ReplayRunLocationProvider(const []),
            locationPreviewProvider: previewProvider,
            permissionService: permissionService,
            mapboxAccessToken: _demoMapboxPublicToken,
            mapboxBuilder: (context, config) {
              capturedConfig = config;
              return const ColoredBox(color: Colors.black);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(permissionService.checkCount, 1);
      expect(permissionService.requestCount, 0);
      expect(previewProvider.requestCount, 1);
      expect(find.text('GPS ready'), findsOneWidget);
      expect(capturedConfig?.mapViewState.currentPosition?.latitude, 1.3009);
      expect(capturedConfig?.mapViewState.routeSegments, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'RunLaunchScreen recenter requests permission then keeps button visible',
    (WidgetTester tester) async {
      _useMobileRunSurface(tester);
      final permissionService = _ConfigurableRunLocationPermissionService(
        checkedStatus: RunLocationPermissionStatus.denied,
        requestedStatus: RunLocationPermissionStatus.granted,
      );
      final previewProvider = _FakeRunLocationPreviewProvider(
        sample: _previewSample(),
      );
      final configs = <RunMapboxSurfaceConfig>[];

      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            locationProvider: ReplayRunLocationProvider(const []),
            locationPreviewProvider: previewProvider,
            permissionService: permissionService,
            mapboxAccessToken: _demoMapboxPublicToken,
            mapboxBuilder: (context, config) {
              configs.add(config);
              return const ColoredBox(color: Colors.black);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('run_map_recenter_button')));
      await tester.pumpAndSettle();

      expect(permissionService.requestCount, 1);
      expect(previewProvider.requestCount, 1);
      expect(find.byKey(const Key('run_map_recenter_button')), findsOneWidget);
      expect(find.text('GPS ready'), findsOneWidget);
      expect(configs.last.mapViewState.currentPosition?.latitude, 1.3009);
      expect(configs.last.isFollowingRunner, isTrue);
      expect(
        configs.map((config) => config.recenterRequestId),
        contains(greaterThanOrEqualTo(1)),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('RunLaunchScreen preview position does not seed active metrics', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final permissionService = _ConfigurableRunLocationPermissionService(
      checkedStatus: RunLocationPermissionStatus.granted,
    );
    final previewProvider = _FakeRunLocationPreviewProvider(
      sample: _previewSample(),
    );
    final configs = <RunMapboxSurfaceConfig>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          locationProvider: ReplayRunLocationProvider(const []),
          locationPreviewProvider: previewProvider,
          permissionService: permissionService,
          mapboxAccessToken: _demoMapboxPublicToken,
          mapboxBuilder: (context, config) {
            configs.add(config);
            return const ColoredBox(color: Colors.black);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(configs.last.mapViewState.currentPosition, isNotNull);
    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('0.00 of 4.50 km'), findsOneWidget);
    expect(find.text('--:--/km'), findsOneWidget);
    expect(configs.last.mapViewState.currentPosition?.latitude, 1.3009);
    expect(configs.last.mapViewState.routeSegments, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RunLaunchScreen selects Mapbox path when token is present', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    RunMapboxSurfaceConfig? capturedConfig;

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          enableForegroundGps: false,
          mapboxAccessToken: _demoMapboxPublicToken,
          mapboxBuilder: (context, config) {
            capturedConfig = config;
            return const ColoredBox(
              key: Key('fake_launch_mapbox_surface'),
              color: Colors.black,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('run_mapbox_surface_selected')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('run_mapbox_placeholder_selected')),
      findsNothing,
    );
    expect(find.byKey(const Key('fake_launch_mapbox_surface')), findsOneWidget);
    expect(find.byType(RunMapPlaceholder), findsNothing);
    expect(capturedConfig, isNotNull);
    expect(capturedConfig!.accessToken, _demoMapboxPublicToken);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'RunLaunchScreen recenter forwards a Mapbox camera recenter intent',
    (WidgetTester tester) async {
      _useMobileRunSurface(tester);
      final configs = <RunMapboxSurfaceConfig>[];

      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            enableForegroundGps: false,
            mapboxAccessToken: _demoMapboxPublicToken,
            mapboxBuilder: (context, config) {
              configs.add(config);
              return GestureDetector(
                key: const Key('fake_mapbox_pan_layer'),
                onPanUpdate: (_) => config.onManualPan?.call(),
                child: const ColoredBox(color: Colors.black),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start run'));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('fake_mapbox_pan_layer')),
        const Offset(48, 0),
      );
      await tester.pump();

      final recenter = find.byKey(const Key('run_map_recenter_button'));
      expect(recenter, findsOneWidget);

      await tester.tap(recenter);
      await tester.pump();
      await tester.pump();

      expect(
        configs.map((config) => config.isFollowingRunner),
        contains(false),
      );
      expect(configs.last.isFollowingRunner, isTrue);
      expect(configs.map((config) => config.recenterRequestId), contains(1));
      expect(configs.last.recenterRequestId, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('RunActiveScreen shows persistent recenter above active panel', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: RunActiveScreen()));
    await tester.pump();

    var recenter = find.byKey(const Key('run_map_recenter_button'));
    var panel = find.byKey(const Key('runActivePanel'));
    expect(recenter, findsOneWidget);
    _expectSheetAdjacentRecenter(
      tester: tester,
      recenter: recenter,
      sheet: panel,
    );
    expect(
      tester.getRect(panel).right - tester.getRect(recenter).right,
      closeTo(24, 1),
    );

    await tester.drag(
      find.byKey(const Key('run_map_interaction_layer')),
      const Offset(48, 0),
    );
    await tester.pump();

    recenter = find.byKey(const Key('run_map_recenter_button'));
    panel = find.byKey(const Key('runActivePanel'));
    expect(recenter, findsOneWidget);
    _expectSheetAdjacentRecenter(
      tester: tester,
      recenter: recenter,
      sheet: panel,
    );

    await tester.tap(recenter);
    await tester.pump();

    expect(find.byKey(const Key('run_map_recenter_button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RunActiveScreen selects Mapbox path when token is present', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    RunMapboxSurfaceConfig? capturedConfig;

    await tester.pumpWidget(
      MaterialApp(
        home: RunActiveScreen(
          mapboxAccessToken: _demoMapboxPublicToken,
          mapboxBuilder: (context, config) {
            capturedConfig = config;
            return const ColoredBox(
              key: Key('fake_active_mapbox_surface'),
              color: Colors.black,
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('run_mapbox_surface_selected')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('run_mapbox_placeholder_selected')),
      findsNothing,
    );
    expect(find.byKey(const Key('fake_active_mapbox_surface')), findsOneWidget);
    expect(find.byType(RunMapPlaceholder), findsNothing);
    expect(capturedConfig, isNotNull);
    expect(capturedConfig!.accessToken, _demoMapboxPublicToken);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'RunActiveScreen recenter forwards a Mapbox camera recenter intent',
    (WidgetTester tester) async {
      _useMobileRunSurface(tester);
      final configs = <RunMapboxSurfaceConfig>[];

      await tester.pumpWidget(
        MaterialApp(
          home: RunActiveScreen(
            mapboxAccessToken: _demoMapboxPublicToken,
            mapboxBuilder: (context, config) {
              configs.add(config);
              return GestureDetector(
                key: const Key('fake_mapbox_pan_layer'),
                onPanUpdate: (_) => config.onManualPan?.call(),
                child: const ColoredBox(color: Colors.black),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.drag(
        find.byKey(const Key('fake_mapbox_pan_layer')),
        const Offset(48, 0),
      );
      await tester.pump();

      final recenter = find.byKey(const Key('run_map_recenter_button'));
      expect(recenter, findsOneWidget);

      await tester.tap(recenter);
      await tester.pump();
      await tester.pump();

      expect(
        configs.map((config) => config.isFollowingRunner),
        contains(false),
      );
      expect(configs.last.isFollowingRunner, isTrue);
      expect(configs.map((config) => config.recenterRequestId), contains(1));
      expect(configs.last.recenterRequestId, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Run launch starts deterministic active local tracking', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('0.00 of 4.50 km'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('--:--/km'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('0.02 of 4.50 km'), findsOneWidget);
    expect(find.text('1%'), findsOneWidget);
    expect(find.text('--:--/km'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run pause, resume, and hold End keep local state untrusted', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.byKey(const Key('hold_to_end_button')), findsOneWidget);
    expect(find.text('Pause'), findsNothing);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('0.02 of 4.50 km'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('00:10'), findsNothing);
    expect(find.text('0.02 of 4.50 km'), findsNothing);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('End'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('hold_to_end_button')));
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    final endButton = find.byKey(const Key('hold_to_end_button'));
    final endCenter = tester.getCenter(endButton);
    final gesture = await tester.startGesture(endCenter);
    await tester.pump(const Duration(milliseconds: 1200));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    final holdGesture = await tester.startGesture(endCenter);
    await tester.pump(const Duration(milliseconds: 1600));
    await holdGesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsOneWidget);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.textContaining('Leaderboard'), findsNothing);
    expect(
      find.textContaining(
        'validation'
        'Status',
      ),
      findsNothing,
    );
    expect(
      find.textContaining(
        'countsToward'
        'Progression',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run pause and resume keep the launch sheet geometry stable', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    final sheet = find.byKey(const Key('runLaunchBottomSheet'));
    expect(sheet, findsOneWidget);
    expect(find.byKey(const Key('trackingSheetContent')), findsOneWidget);
    expect(find.byKey(const Key('runningActions')), findsOneWidget);
    expect(find.byKey(const Key('pausedActions')), findsNothing);
    final runningRect = tester.getRect(sheet);

    await tester.tap(find.byKey(const Key('pauseRunButton')));
    await tester.pump(const Duration(milliseconds: 140));
    expect(find.byKey(const Key('trackingSheetContent')), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pausedActions')), findsOneWidget);
    expect(find.byKey(const Key('runningActions')), findsNothing);
    final pausedRect = tester.getRect(sheet);
    expect((pausedRect.top - runningRect.top).abs(), lessThanOrEqualTo(1));
    expect(
      (pausedRect.bottom - runningRect.bottom).abs(),
      lessThanOrEqualTo(1),
    );

    await tester.tap(find.byKey(const Key('resumeRunButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('runningActions')), findsOneWidget);
    expect(find.byKey(const Key('pausedActions')), findsNothing);
    final resumedRect = tester.getRect(sheet);
    expect((resumedRect.top - runningRect.top).abs(), lessThanOrEqualTo(1));
    expect(
      (resumedRect.bottom - runningRect.bottom).abs(),
      lessThanOrEqualTo(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch pre-run sheet collapses and expands from handle', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    final sheet = find.byKey(const Key('runLaunchBottomSheet'));
    final handle = find.byKey(const Key('runLaunchSheetHandleArea'));
    expect(sheet, findsOneWidget);
    expect(handle, findsOneWidget);
    expect(find.byKey(const Key('runLaunchSheetHandle')), findsOneWidget);
    expect(find.byKey(const Key('preRunSheetContent')), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);

    final expandedRect = tester.getRect(sheet);
    await tester.drag(handle, const Offset(0, 700));
    await tester.pumpAndSettle();

    final collapsedRect = tester.getRect(sheet);
    expect(find.byKey(const Key('runLaunchSheetHandle')), findsOneWidget);
    expect(
      find.byKey(const Key('runLaunchSheetCollapsedContent')),
      findsOneWidget,
    );
    expect(find.text('TODAY\'S PLAN'), findsNothing);
    expect(find.text('Start run'), findsNothing);
    expect(collapsedRect.height, lessThan(expandedRect.height));
    expect(collapsedRect.height, greaterThan(40));

    await tester.drag(handle, const Offset(0, -700));
    await tester.pumpAndSettle();

    final reexpandedRect = tester.getRect(sheet);
    expect(find.byKey(const Key('preRunSheetContent')), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect((reexpandedRect.height - expandedRect.height).abs(), lessThan(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch running sheet collapses while tracking continues', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    final sheet = find.byKey(const Key('runLaunchBottomSheet'));
    final handle = find.byKey(const Key('runLaunchSheetHandleArea'));
    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    final expandedRect = tester.getRect(sheet);
    await tester.drag(handle, const Offset(0, 700));
    await tester.pumpAndSettle();

    final collapsedRect = tester.getRect(sheet);
    expect(find.byKey(const Key('runLaunchSheetHandle')), findsOneWidget);
    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsNothing);
    expect(find.text('TIME'), findsNothing);
    expect(find.text('DISTANCE'), findsNothing);
    expect(collapsedRect.height, lessThan(expandedRect.height));
    expect(collapsedRect.height, greaterThan(40));

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsNothing);

    await tester.drag(handle, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('00:00'), findsNothing);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch paused sheet collapses without resuming or ending', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pauseRunButton')));
    await tester.pumpAndSettle();

    final sheet = find.byKey(const Key('runLaunchBottomSheet'));
    final handle = find.byKey(const Key('runLaunchSheetHandleArea'));
    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.byKey(const Key('hold_to_end_button')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsNothing);

    final expandedRect = tester.getRect(sheet);
    await tester.drag(handle, const Offset(0, 700));
    await tester.pumpAndSettle();

    final collapsedRect = tester.getRect(sheet);
    expect(find.byKey(const Key('runLaunchSheetHandle')), findsOneWidget);
    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsNothing);
    expect(find.byKey(const Key('hold_to_end_button')), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsNothing);
    expect(find.text('Cool down'), findsNothing);
    expect(collapsedRect.height, lessThan(expandedRect.height));
    expect(collapsedRect.height, greaterThan(40));

    await tester.drag(handle, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.byKey(const Key('hold_to_end_button')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsNothing);
    expect(find.text('Cool down'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run launch collapse and expand do not push routes', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final observer = _RoutePushRecorder();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const RunLaunchScreen(enableForegroundGps: false),
      ),
    );
    await tester.pumpAndSettle();
    observer.pushedRoutes.clear();

    final handle = find.byKey(const Key('runLaunchSheetHandleArea'));
    await tester.drag(handle, const Offset(0, 700));
    await tester.pumpAndSettle();

    expect(observer.pushedRoutes, isEmpty);
    expect(find.byKey(const Key('runLaunchSheetHandle')), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsNothing);

    await tester.tap(handle);
    await tester.pumpAndSettle();

    expect(observer.pushedRoutes, isEmpty);
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    expect(observer.pushedRoutes, isEmpty);
    expect(find.byType(RunLaunchScreen), findsOneWidget);
    expect(find.text('Demo mode'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Paused End exposes accessible long press and hold progress', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final semantics = tester.ensureSemantics();

    await _openRunLaunch(tester);
    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    final endSemantics = find.bySemanticsLabel('Hold to end run');
    expect(endSemantics, findsOneWidget);
    expect(find.text('Hold for 1.5 seconds to finish your run'), findsNothing);
    final endNode = tester.getSemantics(endSemantics);
    final endData = endNode.getSemanticsData();
    expect(endData.hint, 'Hold for 1.5 seconds to finish your run');
    expect(endData.hasAction(SemanticsAction.longPress), isTrue);
    expect(find.byKey(const Key('hold_to_end_progress_gauge')), findsNothing);

    final endButton = find.byKey(const Key('hold_to_end_button'));
    final gesture = await tester.startGesture(tester.getCenter(endButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final gauge = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('hold_to_end_progress_gauge')),
    );
    expect(gauge.value, greaterThan(0));
    expect(gauge.value, lessThan(1));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hold_to_end_progress_gauge')), findsNothing);
    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('RunActiveScreen keeps shared Pause Resume and End behavior', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: RunActiveScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.byKey(const Key('hold_to_end_button')), findsOneWidget);
    expect(find.text('Pause'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('End'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    final endButton = find.byKey(const Key('hold_to_end_button'));
    await tester.tap(endButton);
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    final holdGesture = await tester.startGesture(tester.getCenter(endButton));
    await tester.pump(const Duration(milliseconds: 1600));
    await holdGesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
