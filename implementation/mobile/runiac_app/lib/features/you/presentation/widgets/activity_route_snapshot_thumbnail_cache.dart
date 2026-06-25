import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../run/domain/models/run_route_snapshot.dart';
import 'activity_route_preview.dart';
import 'activity_route_thumbnail_viewport.dart';

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
      routeFingerprint: _routeFingerprint(request.route),
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
    final viewport = ActivityRouteThumbnailViewport.fromRoute(
      request.route,
      logicalSize: request.logicalSize,
    );
    final camera = ActivityRouteSnapshotCamera.fromViewport(viewport);
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

  static ActivityRouteSnapshotCamera? fromViewport(
    ActivityRouteThumbnailViewport viewport,
  ) {
    if (viewport.mode == ActivityRouteThumbnailViewportMode.noRoute) {
      return null;
    }
    return ActivityRouteSnapshotCamera(
      centerLatitude: viewport.centerLatitude,
      centerLongitude: viewport.centerLongitude,
      zoom: viewport.cameraZoom,
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
    this.onDiagnostic,
  });

  final ActivityRouteSnapshotThumbnailMemoryCache cache;
  final ActivityRouteSnapshotThumbnailGenerator? generator;
  final bool snapshotThumbnailsEnabled;
  final bool hasValidMapboxToken;
  final Duration generationTimeout;
  final String styleId;
  final ActivityRouteThumbnailDiagnosticSink? onDiagnostic;
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
      final cached = cache.resolve(key);
      final result = cached ?? const ActivityRouteThumbnailResult.unavailable();
      _reportDiagnostic(
        request: request,
        result: result,
        source: cached == null
            ? ActivityRouteThumbnailDiagnosticSource.generatorMissing
            : ActivityRouteThumbnailDiagnosticSource.memoryCache,
      );
      return result;
    }

    final policyResult = _resolvePolicy(request);
    if (policyResult != null) {
      _reportDiagnostic(
        request: request,
        result: policyResult,
        source: ActivityRouteThumbnailDiagnosticSource.policy,
      );
      return policyResult;
    }

    final cached = cache.resolve(key);
    if (cached != null) {
      _reportDiagnostic(
        request: request,
        result: cached,
        source: ActivityRouteThumbnailDiagnosticSource.memoryCache,
      );
      return cached;
    }

    final pending = _inFlight[key];
    if (pending != null) {
      return _resolveWithTimeout(pending);
    }

    final generation = _generateAndCache(
      key: key,
      request: request,
      generator: generator,
    );
    _inFlight[key] = generation;
    unawaited(
      generation.whenComplete(() {
        if (identical(_inFlight[key], generation)) {
          _inFlight.remove(key);
        }
      }),
    );
    final result = await _resolveWithTimeout(generation);
    _reportDiagnostic(
      request: request,
      result: result,
      source: ActivityRouteThumbnailDiagnosticSource.generator,
    );
    return result;
  }

  Future<ActivityRouteThumbnailResult> _resolveWithTimeout(
    Future<ActivityRouteThumbnailResult> generation,
  ) async {
    try {
      return await generation.timeout(
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
    final result = await _generate(generator, generationRequest);
    if (result.hasReadyImage) {
      cache.store(key, result);
    }
    return result;
  }

  Future<ActivityRouteThumbnailResult> _generate(
    ActivityRouteSnapshotThumbnailGenerator generator,
    ActivityRouteSnapshotThumbnailGenerationRequest request,
  ) async {
    try {
      return await generator.generate(request);
    } on Object {
      return const ActivityRouteThumbnailResult.requestFailed();
    }
  }

  void _reportDiagnostic({
    required ActivityRouteThumbnailRequest request,
    required ActivityRouteThumbnailResult result,
    required ActivityRouteThumbnailDiagnosticSource source,
  }) {
    final onDiagnostic = this.onDiagnostic;
    if (onDiagnostic == null) {
      return;
    }
    onDiagnostic(
      ActivityRouteThumbnailDiagnostic(
        activityId: request.activityId,
        resultState: result.state,
        source: source,
        allowExternalStaticMap: request.allowExternalStaticMap,
        isDemoRoute: request.isDemoRoute,
        isCurrentSessionRoute: request.isCurrentSessionRoute,
        snapshotThumbnailsEnabled: snapshotThumbnailsEnabled,
        hasValidMapboxToken: hasValidMapboxToken,
        hasKnownLocation: ActivityRouteThumbnailViewport.fromRoute(
          request.route,
          logicalSize: request.logicalSize,
        ).hasKnownLocation,
      ),
    );
  }
}

typedef ActivityRouteThumbnailDiagnosticSink =
    void Function(ActivityRouteThumbnailDiagnostic diagnostic);

enum ActivityRouteThumbnailDiagnosticSource {
  policy,
  generatorMissing,
  generator,
  memoryCache,
}

class ActivityRouteThumbnailDiagnostic {
  const ActivityRouteThumbnailDiagnostic({
    required this.activityId,
    required this.resultState,
    required this.source,
    required this.allowExternalStaticMap,
    required this.isDemoRoute,
    required this.isCurrentSessionRoute,
    required this.snapshotThumbnailsEnabled,
    required this.hasValidMapboxToken,
    required this.hasKnownLocation,
  });

  final String? activityId;
  final ActivityRouteThumbnailState resultState;
  final ActivityRouteThumbnailDiagnosticSource source;
  final bool allowExternalStaticMap;
  final bool isDemoRoute;
  final bool isCurrentSessionRoute;
  final bool snapshotThumbnailsEnabled;
  final bool hasValidMapboxToken;
  final bool hasKnownLocation;

  String get fallbackReason {
    return switch (resultState) {
      ActivityRouteThumbnailState.readyImage => 'readyImage',
      ActivityRouteThumbnailState.loading => 'loading',
      ActivityRouteThumbnailState.privacyDisabled => 'privacyDisabled',
      ActivityRouteThumbnailState.tokenMissing => 'tokenMissing',
      ActivityRouteThumbnailState.requestFailed => 'requestFailed',
      ActivityRouteThumbnailState.timedOut => 'timedOut',
      ActivityRouteThumbnailState.unavailable => 'unavailable',
    };
  }
}

int _routeFingerprint(RunRouteSnapshot route) {
  var hash = _fnvOffsetBasis;
  for (final segment in route.segments) {
    hash = _combineHash(hash, _segmentSeparator);
    for (final point in segment) {
      if (!point.latitude.isFinite || !point.longitude.isFinite) {
        continue;
      }
      hash = _combineHash(hash, _quantizeCoordinate(point.latitude));
      hash = _combineHash(hash, _quantizeCoordinate(point.longitude));
    }
  }
  final lastKnownLocation = route.lastKnownLocation;
  if (lastKnownLocation != null &&
      lastKnownLocation.latitude.isFinite &&
      lastKnownLocation.longitude.isFinite) {
    hash = _combineHash(hash, _lastKnownLocationSeparator);
    hash = _combineHash(hash, _quantizeCoordinate(lastKnownLocation.latitude));
    hash = _combineHash(hash, _quantizeCoordinate(lastKnownLocation.longitude));
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
const _coordinatePrecision = 1000000;
const _devicePixelRatioPrecision = 4;
const _segmentSeparator = 0x9e3779b9;
const _lastKnownLocationSeparator = 0x85ebca6b;
const _fnvOffsetBasis = 0xcbf29ce484222325;
const _fnvPrime = 0x100000001b3;
const _hashMask = 0x7fffffffffffffff;
