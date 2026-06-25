import '../../../run/domain/models/run_location_sample.dart';
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

class CachedActivityRouteThumbnailProvider
    implements ActivityRouteThumbnailProvider {
  const CachedActivityRouteThumbnailProvider({
    required this.cache,
    this.styleId = _defaultStyleId,
  });

  final ActivityRouteSnapshotThumbnailMemoryCache cache;
  final String styleId;

  @override
  ActivityRouteThumbnailResult resolve(ActivityRouteThumbnailRequest request) {
    final key = ActivityRouteSnapshotThumbnailCacheKey.fromRequest(
      request,
      styleId: styleId,
    );
    return cache.resolve(key) ??
        const ActivityRouteThumbnailResult.unavailable();
  }
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
  return request.isDemoRoute ? 'demo-static-allowed' : 'real-route-disabled';
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
const _coordinatePrecision = 1000000;
const _devicePixelRatioPrecision = 4;
const _segmentSeparator = 0x9e3779b9;
const _fnvOffsetBasis = 0xcbf29ce484222325;
const _fnvPrime = 0x100000001b3;
const _hashMask = 0x7fffffffffffffff;
