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
  });

  final String accessToken;
  final String styleUri;
  final ActivityRouteSnapshotterRuntime runtime;

  @override
  Future<ActivityRouteThumbnailResult> generate(
    ActivityRouteSnapshotThumbnailGenerationRequest request,
  ) async {
    try {
      final bytes = await runtime.capture(
        accessToken: accessToken,
        styleUri: styleUri,
        logicalSize: request.logicalSize,
        pixelRatio: request.devicePixelRatio,
        camera: request.camera,
      );
      if (bytes == null || bytes.isEmpty) {
        return const ActivityRouteThumbnailResult.unavailable();
      }
      return ActivityRouteThumbnailResult.readyImage(
        widgets.MemoryImage(bytes),
      );
    } on Object {
      return const ActivityRouteThumbnailResult.requestFailed();
    }
  }
}
