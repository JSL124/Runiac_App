import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../run/domain/models/run_location_sample.dart';
import '../../../run/domain/models/run_route_snapshot.dart';
import 'activity_route_preview.dart';

class ActivityRouteSnapshotThumbnailCacheKey {
  const ActivityRouteSnapshotThumbnailCacheKey({
    required this.activityIdentity,
    required this.routeFingerprint,
    required this.styleId,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.devicePixelRatioBucket,
    required this.privacyMode,
  });

  factory ActivityRouteSnapshotThumbnailCacheKey.fromRequest(
    ActivityRouteThumbnailRequest request, {
    String styleId = _defaultStyleId,
  }) {
    return ActivityRouteSnapshotThumbnailCacheKey(
      activityIdentity: request.activityId,
      routeFingerprint: _routeFingerprint(request.route.segments),
      styleId: styleId,
      logicalWidth: request.logicalSize.width.round(),
      logicalHeight: request.logicalSize.height.round(),
      devicePixelRatioBucket: _devicePixelRatioBucket(request.devicePixelRatio),
      privacyMode: _privacyMode(request),
    );
  }

  final String? activityIdentity;
  final int routeFingerprint;
  final String styleId;
  final int logicalWidth;
  final int logicalHeight;
  final int devicePixelRatioBucket;
  final String privacyMode;

  @override
  bool operator ==(Object other) {
    return other is ActivityRouteSnapshotThumbnailCacheKey &&
        other.activityIdentity == activityIdentity &&
        other.routeFingerprint == routeFingerprint &&
        other.styleId == styleId &&
        other.logicalWidth == logicalWidth &&
        other.logicalHeight == logicalHeight &&
        other.devicePixelRatioBucket == devicePixelRatioBucket &&
        other.privacyMode == privacyMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      activityIdentity,
      routeFingerprint,
      styleId,
      logicalWidth,
      logicalHeight,
      devicePixelRatioBucket,
      privacyMode,
    );
  }
}

class ActivityRouteSnapshotThumbnailMemoryCache {
  final Map<
    ActivityRouteSnapshotThumbnailCacheKey,
    ActivityRouteThumbnailResult
  >
  _entries =
      <ActivityRouteSnapshotThumbnailCacheKey, ActivityRouteThumbnailResult>{};

  int get length => _entries.length;

  ActivityRouteThumbnailResult? resolve(
    ActivityRouteSnapshotThumbnailCacheKey key,
  ) {
    return _entries[key];
  }

  void store(
    ActivityRouteSnapshotThumbnailCacheKey key,
    ActivityRouteThumbnailResult result,
  ) {
    _entries[key] = result;
  }

  void clear() {
    _entries.clear();
  }
}

abstract interface class ActivityRouteSnapshotThumbnailGenerator {
  Future<ActivityRouteThumbnailResult> generate(
    ActivityRouteSnapshotThumbnailGenerationRequest request,
  );
}

class ActivityRouteSnapshotThumbnailGenerationRequest {
  const ActivityRouteSnapshotThumbnailGenerationRequest({
    required this.logicalSize,
    required this.devicePixelRatio,
    required this.styleId,
    required this.camera,
    this.activityId,
  });

  static ActivityRouteSnapshotThumbnailGenerationRequest? fromThumbnailRequest(
    ActivityRouteThumbnailRequest request, {
    required String styleId,
  }) {
    final camera = ActivityRouteSnapshotCamera.fromRoute(
      request.route,
      logicalSize: request.logicalSize,
    );
    if (camera == null) {
      return null;
    }
    return ActivityRouteSnapshotThumbnailGenerationRequest(
      logicalSize: request.logicalSize,
      devicePixelRatio: request.devicePixelRatio,
      styleId: styleId,
      camera: camera,
      activityId: request.activityId,
    );
  }

  final Size logicalSize;
  final double devicePixelRatio;
  final String styleId;
  final ActivityRouteSnapshotCamera camera;
  final String? activityId;
}

class ActivityRouteSnapshotCamera {
  const ActivityRouteSnapshotCamera({
    required this.centerLatitude,
    required this.centerLongitude,
    required this.zoom,
  });

  factory ActivityRouteSnapshotCamera.fromBounds({
    required double minLatitude,
    required double maxLatitude,
    required double minLongitude,
    required double maxLongitude,
    required Size logicalSize,
  }) {
    final centerLatitude = (minLatitude + maxLatitude) / 2;
    final centerLongitude = (minLongitude + maxLongitude) / 2;
    final latitudeSpan = (maxLatitude - minLatitude).abs();
    final longitudeSpan = (maxLongitude - minLongitude).abs();
    final adjustedLongitudeSpan =
        longitudeSpan * math.cos(centerLatitude * math.pi / 180).abs();
    final routeSpan = math.max(latitudeSpan, adjustedLongitudeSpan);
    final paddedSpan = math.max(routeSpan * 1.8, _minCameraSpan);
    final zoom = (math.log(360 / paddedSpan) / math.ln2).clamp(
      _minSnapshotZoom,
      _maxSnapshotZoom,
    );

    return ActivityRouteSnapshotCamera(
      centerLatitude: centerLatitude,
      centerLongitude: centerLongitude,
      zoom: zoom.toDouble(),
    );
  }

  static ActivityRouteSnapshotCamera? fromRoute(
    RunRouteSnapshot route, {
    required Size logicalSize,
  }) {
    final points = _drawableRoutePoints(route.segments);
    final knownLocation = _knownPreviewLocation(route);
    if (points.length < 2) {
      return knownLocation == null
          ? null
          : ActivityRouteSnapshotCamera.fromLocation(knownLocation);
    }
    final movementMeters = _routeMovementMeters(points);
    if (movementMeters < _stationaryMovementThresholdMeters) {
      return knownLocation == null
          ? null
          : ActivityRouteSnapshotCamera.fromLocation(knownLocation);
    }

    var minLatitude = points.first.latitude;
    var maxLatitude = points.first.latitude;
    var minLongitude = points.first.longitude;
    var maxLongitude = points.first.longitude;
    for (final point in points.skip(1)) {
      minLatitude = math.min(minLatitude, point.latitude);
      maxLatitude = math.max(maxLatitude, point.latitude);
      minLongitude = math.min(minLongitude, point.longitude);
      maxLongitude = math.max(maxLongitude, point.longitude);
    }

    if (_projectedRouteIsTiny(
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
      logicalSize: logicalSize,
    )) {
      return knownLocation == null
          ? null
          : ActivityRouteSnapshotCamera.fromLocation(knownLocation);
    }

    return ActivityRouteSnapshotCamera.fromBounds(
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
      logicalSize: logicalSize,
    );
  }

  factory ActivityRouteSnapshotCamera.fromLocation(RunLocationSample location) {
    return ActivityRouteSnapshotCamera(
      centerLatitude: location.latitude,
      centerLongitude: location.longitude,
      zoom: _locationSnapshotZoom,
    );
  }

  final double centerLatitude;
  final double centerLongitude;
  final double zoom;
}

class CachedActivityRouteThumbnailProvider
    implements ActivityRouteThumbnailProvider {
  CachedActivityRouteThumbnailProvider({
    required this.cache,
    this.generator,
    this.snapshotThumbnailsEnabled = false,
    this.hasValidMapboxToken = false,
    this.generationTimeout = const Duration(seconds: 4),
    this.styleId = _defaultStyleId,
  });

  final ActivityRouteSnapshotThumbnailMemoryCache cache;
  final ActivityRouteSnapshotThumbnailGenerator? generator;
  final bool snapshotThumbnailsEnabled;
  final bool hasValidMapboxToken;
  final Duration generationTimeout;
  final String styleId;
  final Map<
    ActivityRouteSnapshotThumbnailCacheKey,
    Future<ActivityRouteThumbnailResult>
  >
  _inFlight =
      <
        ActivityRouteSnapshotThumbnailCacheKey,
        Future<ActivityRouteThumbnailResult>
      >{};

  @override
  Future<ActivityRouteThumbnailResult> resolve(
    ActivityRouteThumbnailRequest request,
  ) async {
    final key = ActivityRouteSnapshotThumbnailCacheKey.fromRequest(
      request,
      styleId: styleId,
    );
    final generator = this.generator;
    if (generator == null) {
      return cache.resolve(key) ??
          const ActivityRouteThumbnailResult.unavailable();
    }

    final policyResult = _resolvePolicy(request);
    if (policyResult != null) {
      return policyResult;
    }

    final cached = cache.resolve(key);
    if (cached != null) {
      return cached;
    }

    final pending = _inFlight[key];
    if (pending != null) {
      return pending;
    }

    final generation = _generateAndCache(
      key: key,
      request: request,
      generator: generator,
    );
    _inFlight[key] = generation;
    try {
      return await generation;
    } finally {
      _inFlight.remove(key);
    }
  }

  ActivityRouteThumbnailResult? _resolvePolicy(
    ActivityRouteThumbnailRequest request,
  ) {
    if (!request.allowExternalStaticMap || !snapshotThumbnailsEnabled) {
      return const ActivityRouteThumbnailResult.privacyDisabled();
    }
    if (!request.isDemoRoute && !request.isCurrentSessionRoute) {
      return const ActivityRouteThumbnailResult.privacyDisabled();
    }
    if (!hasValidMapboxToken) {
      return const ActivityRouteThumbnailResult.tokenMissing();
    }
    return null;
  }

  Future<ActivityRouteThumbnailResult> _generateAndCache({
    required ActivityRouteSnapshotThumbnailCacheKey key,
    required ActivityRouteThumbnailRequest request,
    required ActivityRouteSnapshotThumbnailGenerator generator,
  }) async {
    final generationRequest =
        ActivityRouteSnapshotThumbnailGenerationRequest.fromThumbnailRequest(
          request,
          styleId: styleId,
        );
    if (generationRequest == null) {
      return const ActivityRouteThumbnailResult.unavailable();
    }
    final result = await _generateWithTimeout(generator, generationRequest);
    if (result.hasReadyImage) {
      cache.store(key, result);
    }
    return result;
  }

  Future<ActivityRouteThumbnailResult> _generateWithTimeout(
    ActivityRouteSnapshotThumbnailGenerator generator,
    ActivityRouteSnapshotThumbnailGenerationRequest request,
  ) async {
    try {
      return await generator
          .generate(request)
          .timeout(
            generationTimeout,
            onTimeout: () {
              return const ActivityRouteThumbnailResult.timedOut();
            },
          );
    } on TimeoutException {
      return const ActivityRouteThumbnailResult.timedOut();
    } on Object {
      return const ActivityRouteThumbnailResult.requestFailed();
    }
  }
}

List<RunLocationSample> _drawableRoutePoints(
  List<List<RunLocationSample>> segments,
) {
  return segments
      .expand((segment) => segment)
      .where(_isDrawableRoutePoint)
      .toList(growable: false);
}

bool _isDrawableRoutePoint(RunLocationSample point) {
  return point.latitude.isFinite && point.longitude.isFinite;
}

RunLocationSample? _knownPreviewLocation(RunRouteSnapshot route) {
  final lastKnownLocation = route.lastKnownLocation;
  if (lastKnownLocation != null && _isDrawableRoutePoint(lastKnownLocation)) {
    return lastKnownLocation;
  }
  for (final segment in route.segments.reversed) {
    for (final point in segment.reversed) {
      if (_isDrawableRoutePoint(point)) {
        return point;
      }
    }
  }
  return null;
}

double _routeMovementMeters(List<RunLocationSample> points) {
  var maxDistance = 0.0;
  for (var index = 1; index < points.length; index += 1) {
    maxDistance = math.max(
      maxDistance,
      _distanceMeters(points.first, points[index]),
    );
  }
  return maxDistance;
}

double _distanceMeters(RunLocationSample a, RunLocationSample b) {
  const metersPerLatitudeDegree = 111320.0;
  final meanLatitudeRadians = ((a.latitude + b.latitude) / 2) * math.pi / 180;
  final metersPerLongitudeDegree =
      metersPerLatitudeDegree * math.cos(meanLatitudeRadians).abs();
  final latitudeMeters = (b.latitude - a.latitude) * metersPerLatitudeDegree;
  final longitudeMeters =
      (b.longitude - a.longitude) * metersPerLongitudeDegree;
  return math.sqrt(
    (latitudeMeters * latitudeMeters) + (longitudeMeters * longitudeMeters),
  );
}

bool _projectedRouteIsTiny({
  required double minLatitude,
  required double maxLatitude,
  required double minLongitude,
  required double maxLongitude,
  required Size logicalSize,
}) {
  final longitudeSpan = math.max(maxLongitude - minLongitude, _minRouteSpan);
  final latitudeSpan = math.max(maxLatitude - minLatitude, _minRouteSpan);
  final drawableWidth = math.max(
    1.0,
    logicalSize.width - (_previewPadding * 2),
  );
  final drawableHeight = math.max(
    1.0,
    logicalSize.height - (_previewPadding * 2),
  );
  final scale = math.min(
    drawableWidth / longitudeSpan,
    drawableHeight / latitudeSpan,
  );
  final projectedWidth = longitudeSpan * scale;
  final projectedHeight = latitudeSpan * scale;

  return projectedWidth < _tinyRouteProjectedThresholdPx &&
      projectedHeight < _tinyRouteProjectedThresholdPx;
}

int _routeFingerprint(List<List<RunLocationSample>> segments) {
  var hash = _fnvOffsetBasis;
  for (final segment in segments) {
    hash = _combineHash(hash, _segmentSeparator);
    for (final point in segment) {
      if (!point.latitude.isFinite || !point.longitude.isFinite) {
        continue;
      }
      hash = _combineHash(hash, _quantizeCoordinate(point.latitude));
      hash = _combineHash(hash, _quantizeCoordinate(point.longitude));
    }
  }
  return hash;
}

int _quantizeCoordinate(double coordinate) {
  return (coordinate * _coordinatePrecision).round();
}

int _devicePixelRatioBucket(double devicePixelRatio) {
  return (devicePixelRatio * _devicePixelRatioPrecision).round();
}

String _privacyMode(ActivityRouteThumbnailRequest request) {
  if (!request.allowExternalStaticMap) {
    return 'privacy-disabled';
  }
  if (request.isDemoRoute) {
    return 'demo-static-allowed';
  }
  if (request.isCurrentSessionRoute) {
    return 'current-session-runtime-allowed';
  }
  return 'real-route-disabled';
}

int _combineHash(int hash, int value) {
  var next = hash;
  for (var shift = 0; shift < 64; shift += 8) {
    next ^= (value >> shift) & 0xff;
    next = (next * _fnvPrime) & _hashMask;
  }
  return next;
}

const _defaultStyleId = 'runiac-card-static-v1';
const _previewPadding = 7.0;
const _minRouteSpan = 0.000001;
const _stationaryMovementThresholdMeters = 6.0;
const _tinyRouteProjectedThresholdPx = 6.0;
const _minCameraSpan = 0.00018;
const _minSnapshotZoom = 11.5;
const _maxSnapshotZoom = 17.2;
const _locationSnapshotZoom = 16.5;
const _coordinatePrecision = 1000000;
const _devicePixelRatioPrecision = 4;
const _segmentSeparator = 0x9e3779b9;
const _fnvOffsetBasis = 0xcbf29ce484222325;
const _fnvPrime = 0x100000001b3;
const _hashMask = 0x7fffffffffffffff;
