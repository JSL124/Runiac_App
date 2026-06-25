import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_route_snapshot.dart';
import 'package:runiac_app/features/you/presentation/widgets/activity_route_preview.dart';
import 'package:runiac_app/features/you/presentation/widgets/activity_route_snapshot_thumbnail_cache.dart';

RunRouteSnapshot _routeFixture({
  double latitudeOffset = 0,
  double longitudeOffset = 0,
}) {
  final startedAt = DateTime.utc(2026, 6, 18, 8, 10);
  return RunRouteSnapshot(
    segments: [
      [
        RunLocationSample(
          recordedAt: startedAt,
          latitude: 1.301 + latitudeOffset,
          longitude: 103.801 + longitudeOffset,
        ),
        RunLocationSample(
          recordedAt: startedAt.add(const Duration(seconds: 90)),
          latitude: 1.302 + latitudeOffset,
          longitude: 103.802 + longitudeOffset,
        ),
      ],
    ],
    lastKnownLocation: RunLocationSample(
      recordedAt: startedAt.add(const Duration(seconds: 90)),
      latitude: 1.302 + latitudeOffset,
      longitude: 103.802 + longitudeOffset,
    ),
  );
}

ActivityRouteThumbnailRequest _request({
  required RunRouteSnapshot route,
  Size logicalSize = const Size(88, 88),
  double devicePixelRatio = 3,
  bool allowExternalStaticMap = true,
  bool isDemoRoute = true,
  String? activityId = 'activity-1',
}) {
  return ActivityRouteThumbnailRequest(
    route: route,
    logicalSize: logicalSize,
    devicePixelRatio: devicePixelRatio,
    allowExternalStaticMap: allowExternalStaticMap,
    isDemoRoute: isDemoRoute,
    activityId: activityId,
  );
}

void main() {
  test('cache returns deterministic hit for stored thumbnail result', () {
    // Given: a session cache with a stored fake snapshot result.
    final cache = ActivityRouteSnapshotThumbnailMemoryCache();
    final request = _request(route: _routeFixture());
    final image = MemoryImage(Uint8List.fromList(const [1, 2, 3]));
    final result = ActivityRouteThumbnailResult.readyImage(image);
    const styleId = 'runiac-card-streets-v1';
    final key = ActivityRouteSnapshotThumbnailCacheKey.fromRequest(
      request,
      styleId: styleId,
    );

    // When: the result is stored and resolved through the provider.
    cache.store(key, result);
    final provider = CachedActivityRouteThumbnailProvider(
      cache: cache,
      styleId: styleId,
    );
    final resolved = provider.resolve(request);

    // Then: the same ready image result is returned from memory.
    expect(resolved.state, ActivityRouteThumbnailState.readyImage);
    expect(resolved.imageProvider, same(image));
    expect(cache.length, 1);
  });

  test('cache miss returns unavailable without creating external work', () {
    // Given: an empty session cache and a meaningful route request.
    final cache = ActivityRouteSnapshotThumbnailMemoryCache();
    final provider = CachedActivityRouteThumbnailProvider(cache: cache);

    // When: no thumbnail was stored for this route.
    final resolved = provider.resolve(_request(route: _routeFixture()));

    // Then: the provider reports unavailable so the preview can use CustomPaint.
    expect(resolved, const ActivityRouteThumbnailResult.unavailable());
    expect(cache.length, 0);
  });

  test(
    'cache key changes for activity, route, size, dpr, style, and privacy',
    () {
      // Given: equivalent and changed route thumbnail requests.
      final base = _request(route: _routeFixture());
      final same = _request(route: _routeFixture());
      final moved = _request(route: _routeFixture(latitudeOffset: 0.001));
      final resized = _request(
        route: _routeFixture(),
        logicalSize: const Size(96, 88),
      );
      final dprChanged = _request(route: _routeFixture(), devicePixelRatio: 2);
      final activityChanged = _request(
        route: _routeFixture(),
        activityId: 'activity-2',
      );
      final privacyChanged = _request(
        route: _routeFixture(),
        allowExternalStaticMap: false,
      );

      // When: deterministic cache keys are derived.
      final baseKey = ActivityRouteSnapshotThumbnailCacheKey.fromRequest(base);

      // Then: identical requests match, while meaningful dimensions differ.
      expect(ActivityRouteSnapshotThumbnailCacheKey.fromRequest(same), baseKey);
      expect(
        ActivityRouteSnapshotThumbnailCacheKey.fromRequest(moved),
        isNot(baseKey),
      );
      expect(
        ActivityRouteSnapshotThumbnailCacheKey.fromRequest(resized),
        isNot(baseKey),
      );
      expect(
        ActivityRouteSnapshotThumbnailCacheKey.fromRequest(dprChanged),
        isNot(baseKey),
      );
      expect(
        ActivityRouteSnapshotThumbnailCacheKey.fromRequest(activityChanged),
        isNot(baseKey),
      );
      expect(
        ActivityRouteSnapshotThumbnailCacheKey.fromRequest(
          base,
          styleId: 'alternate-style',
        ),
        isNot(baseKey),
      );
      expect(
        ActivityRouteSnapshotThumbnailCacheKey.fromRequest(privacyChanged),
        isNot(baseKey),
      );
    },
  );

  test('cache clear removes only current session memory', () {
    // Given: a memory-only cache with one stored result.
    final cache = ActivityRouteSnapshotThumbnailMemoryCache();
    final key = ActivityRouteSnapshotThumbnailCacheKey.fromRequest(
      _request(route: _routeFixture()),
    );
    cache.store(
      key,
      ActivityRouteThumbnailResult.readyImage(
        MemoryImage(Uint8List.fromList(const [4, 5, 6])),
      ),
    );

    // When: the current session cache is cleared.
    cache.clear();

    // Then: the entry is removed without any disk persistence surface.
    expect(cache.resolve(key), isNull);
    expect(cache.length, 0);
  });
}
