import 'dart:async';

import 'package:flutter/material.dart' hide Visibility;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/models/run_map_view_state.dart';
import 'run_map_placeholder.dart';
import 'run_mapbox_geometry.dart';
import 'run_mapbox_surface_config.dart';

const _runnerOrange = Color(0xFFFF6818);
const _routeOrange = Color(0xFFFF7A1A);

class RunMapboxRunMap extends StatefulWidget {
  const RunMapboxRunMap({super.key, required this.config});

  final RunMapboxSurfaceConfig config;

  @override
  State<RunMapboxRunMap> createState() => _RunMapboxRunMapState();
}

class _RunMapboxRunMapState extends State<RunMapboxRunMap> {
  RunMapboxSyncCoordinator? _syncCoordinator;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken(widget.config.accessToken);
  }

  @override
  void didUpdateWidget(covariant RunMapboxRunMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.accessToken != widget.config.accessToken) {
      MapboxOptions.setAccessToken(widget.config.accessToken);
    }
    final shouldAnimateCamera =
        oldWidget.config.recenterRequestId != widget.config.recenterRequestId ||
        (!oldWidget.config.isFollowingRunner &&
            widget.config.isFollowingRunner);
    unawaited(_syncCurrentMap(animateCamera: shouldAnimateCamera));
  }

  @override
  void dispose() {
    _disposed = true;
    final coordinator = _syncCoordinator;
    _syncCoordinator = null;
    if (coordinator != null) {
      unawaited(coordinator.dispose().catchError((Object _) {}));
    }
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    await _configureMapboxOrnaments(mapboxMap);
    if (_disposed) {
      return;
    }

    final adapter = RunMapboxNativeMapAdapter(mapboxMap);
    final coordinator = RunMapboxSyncCoordinator(adapter);
    if (_disposed) {
      await coordinator.dispose();
      return;
    }

    _syncCoordinator = coordinator;
    await _syncCurrentMap();
  }

  Future<void> _configureMapboxOrnaments(MapboxMap mapboxMap) async {
    await mapboxMap.logo.updateSettings(
      LogoSettings(
        enabled: true,
        position: OrnamentPosition.TOP_LEFT,
        marginLeft: 16,
        marginTop: 80,
      ),
    );
    await mapboxMap.attribution.updateSettings(
      AttributionSettings(
        enabled: true,
        clickable: true,
        position: OrnamentPosition.TOP_RIGHT,
        marginTop: 80,
        marginRight: 16,
      ),
    );
  }

  Future<void> _syncCurrentMap({bool animateCamera = false}) {
    final coordinator = _syncCoordinator;
    if (coordinator == null) {
      return Future<void>.value();
    }

    return coordinator.sync(
      RunMapboxSyncRequest(
        mapViewState: widget.config.mapViewState,
        isFollowingRunner: widget.config.isFollowingRunner,
        animateCamera: animateCamera,
      ),
    );
  }

  void _handleManualScroll(MapContentGestureContext context) {
    if (widget.config.isFollowingRunner) {
      widget.config.onManualPan?.call();
    }
  }

  void _handleRecenter() {
    widget.config.onRecenter?.call();
    unawaited(_syncCurrentMap(animateCamera: true));
  }

  CameraViewportState _initialViewport() {
    final request = RunMapboxCameraRequest.initialForMapViewState(
      widget.config.mapViewState,
    );
    return CameraViewportState(
      center: Point(
        coordinates: Position(
          request.center.longitude,
          request.center.latitude,
        ),
      ),
      zoom: request.zoom,
      pitch: 0.0,
      bearing: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('run_mapbox_surface'),
      children: [
        Positioned.fill(
          child: MapWidget(
            key: const Key('run_mapbox_widget'),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            viewport: _initialViewport(),
            onMapCreated: _onMapCreated,
            onScrollListener: _handleManualScroll,
          ),
        ),
        if (widget.config.showRecenterButton &&
            !widget.config.isFollowingRunner &&
            widget.config.onRecenter != null)
          Positioned(
            right: 24,
            bottom: widget.config.recenterButtonBottom,
            child: RunMapRecenterButton(onPressed: _handleRecenter),
          ),
      ],
    );
  }
}

class RunMapboxNativeMapAdapter implements RunMapboxSyncTarget {
  RunMapboxNativeMapAdapter(this._mapboxMap);

  final MapboxMap _mapboxMap;
  CircleAnnotationManager? _runnerManager;
  PolylineAnnotationManager? _routeManager;
  Future<void>? _disposeFuture;
  bool _disposed = false;

  @override
  Future<void> apply(RunMapboxSyncRequest request) async {
    if (_disposed) {
      return;
    }

    await _ensureAnnotationManagers();
    if (_disposed) {
      return;
    }

    await _syncRunnerMarker(request.mapViewState);
    if (_disposed) {
      return;
    }

    await _syncRouteSegments(request.mapViewState);
    if (!_disposed && (request.isFollowingRunner || request.animateCamera)) {
      await _moveCamera(request.mapViewState, animated: request.animateCamera);
    }
  }

  @override
  Future<void> dispose() {
    return _disposeFuture ??= _dispose();
  }

  Future<void> _dispose() async {
    _disposed = true;
    final runnerManager = _runnerManager;
    final routeManager = _routeManager;
    _runnerManager = null;
    _routeManager = null;

    if (runnerManager != null) {
      await runnerManager.deleteAll();
      await _mapboxMap.annotations.removeAnnotationManager(runnerManager);
    }
    if (routeManager != null) {
      await routeManager.deleteAll();
      await _mapboxMap.annotations.removeAnnotationManager(routeManager);
    }
  }

  Future<void> _ensureAnnotationManagers() async {
    _runnerManager ??= await _mapboxMap.annotations
        .createCircleAnnotationManager();
    _routeManager ??= await _mapboxMap.annotations
        .createPolylineAnnotationManager();
  }

  Future<void> _syncRunnerMarker(RunMapViewState mapViewState) async {
    final runnerManager = _runnerManager;
    final currentPosition = mapViewState.currentPosition;
    if (runnerManager == null) {
      return;
    }

    await runnerManager.deleteAll();
    if (currentPosition == null) {
      return;
    }

    final coordinate = RunMapboxCoordinate.fromSample(currentPosition);
    await runnerManager.create(
      CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(coordinate.longitude, coordinate.latitude),
        ),
        circleColor: _runnerOrange.toARGB32(),
        circleRadius: 12,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 4,
      ),
    );
  }

  Future<void> _syncRouteSegments(RunMapViewState mapViewState) async {
    final routeManager = _routeManager;
    if (routeManager == null) {
      return;
    }

    await routeManager.deleteAll();
    final geometry = RunMapboxRouteGeometry.fromViewState(mapViewState);
    if (!geometry.hasRoute) {
      return;
    }

    await routeManager.createMulti(
      geometry.segments
          .map(
            (segment) => PolylineAnnotationOptions(
              geometry: LineString(
                coordinates: segment
                    .map((point) => Position(point.longitude, point.latitude))
                    .toList(growable: false),
              ),
              lineColor: _routeOrange.toARGB32(),
              lineWidth: 6,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _moveCamera(
    RunMapViewState mapViewState, {
    required bool animated,
  }) async {
    final request = RunMapboxCameraRequest.forCurrentPosition(mapViewState);
    if (request == null) {
      return;
    }

    final camera = CameraOptions(
      center: Point(
        coordinates: Position(
          request.center.longitude,
          request.center.latitude,
        ),
      ),
      zoom: request.zoom,
      pitch: 0,
      bearing: 0,
    );
    if (animated) {
      await _mapboxMap.easeTo(
        camera,
        MapAnimationOptions(duration: request.animationDuration.inMilliseconds),
      );
      return;
    }
    await _mapboxMap.setCamera(camera);
  }
}
