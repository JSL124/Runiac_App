import 'dart:typed_data';

import 'package:flutter/widgets.dart' as widgets;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import 'activity_route_preview.dart';
import 'activity_route_snapshot_thumbnail_cache.dart';

class ActivityRouteMapboxSnapshotStyle {
  const ActivityRouteMapboxSnapshotStyle._();

  static const defaultStyle = mapbox.MapboxStyles.MAPBOX_STREETS;
}

abstract interface class ActivityRouteSnapshotterRuntime {
  Future<Uint8List?> capture({
    required String accessToken,
    required String styleUri,
    required widgets.Size logicalSize,
    required double pixelRatio,
    required ActivityRouteSnapshotCamera camera,
  });
}

class MapboxActivityRouteSnapshotterRuntime
    implements ActivityRouteSnapshotterRuntime {
  const MapboxActivityRouteSnapshotterRuntime();

  @override
  Future<Uint8List?> capture({
    required String accessToken,
    required String styleUri,
    required widgets.Size logicalSize,
    required double pixelRatio,
    required ActivityRouteSnapshotCamera camera,
  }) async {
    mapbox.MapboxOptions.setAccessToken(accessToken);
    final snapshotter = await mapbox.Snapshotter.create(
      options: mapbox.MapSnapshotOptions(
        size: mapbox.Size(width: logicalSize.width, height: logicalSize.height),
        pixelRatio: pixelRatio,
      ),
    );
    try {
      await snapshotter.setCamera(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              camera.centerLongitude,
              camera.centerLatitude,
            ),
          ),
          zoom: camera.zoom,
        ),
      );
      await snapshotter.style.setStyleURI(styleUri);
      return snapshotter.start();
    } finally {
      await snapshotter.dispose();
    }
  }
}

class MapboxActivityRouteSnapshotThumbnailGenerator
    implements ActivityRouteSnapshotThumbnailGenerator {
  const MapboxActivityRouteSnapshotThumbnailGenerator({
    required this.accessToken,
    this.styleUri = ActivityRouteMapboxSnapshotStyle.defaultStyle,
    this.runtime = const MapboxActivityRouteSnapshotterRuntime(),
    this.onDiagnostic,
  });

  final String accessToken;
  final String styleUri;
  final ActivityRouteSnapshotterRuntime runtime;
  final ActivityRouteSnapshotterDiagnosticSink? onDiagnostic;

  @override
  Future<ActivityRouteThumbnailResult> generate(
    ActivityRouteSnapshotThumbnailGenerationRequest request,
  ) async {
    try {
      _reportDiagnostic(
        ActivityRouteSnapshotterDiagnostic.started(
          request: request,
          styleUri: styleUri,
        ),
      );
      final bytes = await runtime.capture(
        accessToken: accessToken,
        styleUri: styleUri,
        logicalSize: request.logicalSize,
        pixelRatio: request.devicePixelRatio,
        camera: request.camera,
      );
      if (bytes == null || bytes.isEmpty) {
        _reportDiagnostic(
          ActivityRouteSnapshotterDiagnostic.finished(
            request: request,
            styleUri: styleUri,
            state: ActivityRouteThumbnailState.unavailable,
            byteLength: bytes?.lengthInBytes ?? 0,
          ),
        );
        return const ActivityRouteThumbnailResult.unavailable();
      }
      _reportDiagnostic(
        ActivityRouteSnapshotterDiagnostic.finished(
          request: request,
          styleUri: styleUri,
          state: ActivityRouteThumbnailState.readyImage,
          byteLength: bytes.lengthInBytes,
        ),
      );
      return ActivityRouteThumbnailResult.readyImage(
        widgets.MemoryImage(bytes),
      );
    } on Object catch (error) {
      _reportDiagnostic(
        ActivityRouteSnapshotterDiagnostic.failed(
          request: request,
          styleUri: styleUri,
          error: error,
        ),
      );
      return const ActivityRouteThumbnailResult.requestFailed();
    }
  }

  void _reportDiagnostic(ActivityRouteSnapshotterDiagnostic diagnostic) {
    final onDiagnostic = this.onDiagnostic;
    if (onDiagnostic == null) {
      return;
    }
    onDiagnostic(diagnostic);
  }
}

typedef ActivityRouteSnapshotterDiagnosticSink =
    void Function(ActivityRouteSnapshotterDiagnostic diagnostic);

enum ActivityRouteSnapshotterDiagnosticEvent { started, finished, failed }

class ActivityRouteSnapshotterDiagnostic {
  const ActivityRouteSnapshotterDiagnostic._({
    required this.event,
    required this.activityId,
    required this.styleUri,
    required this.logicalSize,
    required this.devicePixelRatio,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.zoom,
    this.state,
    this.byteLength,
    this.errorType,
    this.errorDescription,
  });

  factory ActivityRouteSnapshotterDiagnostic.started({
    required ActivityRouteSnapshotThumbnailGenerationRequest request,
    required String styleUri,
  }) {
    return ActivityRouteSnapshotterDiagnostic._(
      event: ActivityRouteSnapshotterDiagnosticEvent.started,
      activityId: request.activityId,
      styleUri: styleUri,
      logicalSize: request.logicalSize,
      devicePixelRatio: request.devicePixelRatio,
      centerLatitude: request.camera.centerLatitude,
      centerLongitude: request.camera.centerLongitude,
      zoom: request.camera.zoom,
    );
  }

  factory ActivityRouteSnapshotterDiagnostic.finished({
    required ActivityRouteSnapshotThumbnailGenerationRequest request,
    required String styleUri,
    required ActivityRouteThumbnailState state,
    required int byteLength,
  }) {
    return ActivityRouteSnapshotterDiagnostic._(
      event: ActivityRouteSnapshotterDiagnosticEvent.finished,
      activityId: request.activityId,
      styleUri: styleUri,
      logicalSize: request.logicalSize,
      devicePixelRatio: request.devicePixelRatio,
      centerLatitude: request.camera.centerLatitude,
      centerLongitude: request.camera.centerLongitude,
      zoom: request.camera.zoom,
      state: state,
      byteLength: byteLength,
    );
  }

  factory ActivityRouteSnapshotterDiagnostic.failed({
    required ActivityRouteSnapshotThumbnailGenerationRequest request,
    required String styleUri,
    required Object error,
  }) {
    return ActivityRouteSnapshotterDiagnostic._(
      event: ActivityRouteSnapshotterDiagnosticEvent.failed,
      activityId: request.activityId,
      styleUri: styleUri,
      logicalSize: request.logicalSize,
      devicePixelRatio: request.devicePixelRatio,
      centerLatitude: request.camera.centerLatitude,
      centerLongitude: request.camera.centerLongitude,
      zoom: request.camera.zoom,
      state: ActivityRouteThumbnailState.requestFailed,
      byteLength: 0,
      errorType: error.runtimeType.toString(),
      errorDescription: error.toString(),
    );
  }

  final ActivityRouteSnapshotterDiagnosticEvent event;
  final String? activityId;
  final String styleUri;
  final widgets.Size logicalSize;
  final double devicePixelRatio;
  final double centerLatitude;
  final double centerLongitude;
  final double zoom;
  final ActivityRouteThumbnailState? state;
  final int? byteLength;
  final String? errorType;
  final String? errorDescription;
}
