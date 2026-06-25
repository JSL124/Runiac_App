import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../run/domain/models/run_location_sample.dart';
import '../../../run/domain/models/run_route_snapshot.dart';

class ActivityRoutePreview extends StatelessWidget {
  const ActivityRoutePreview({
    required this.route,
    this.thumbnailProvider = const NoopActivityRouteThumbnailProvider(),
    this.allowExternalStaticMap = false,
    this.isDemoRoute = false,
    this.activityId,
    super.key,
  });

  final RunRouteSnapshot route;
  final ActivityRouteThumbnailProvider thumbnailProvider;
  final bool allowExternalStaticMap;
  final bool isDemoRoute;
  final String? activityId;

  @override
  Widget build(BuildContext context) {
    const logicalSize = Size(_previewSlotSize, _previewSlotSize);
    final mode = _RoutePreviewMode.forRoute(route, logicalSize: logicalSize);
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return ClipRRect(
      key: const ValueKey('activity_route_preview_slot'),
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: _previewSlotSize,
        height: _previewSlotSize,
        child: switch (mode) {
          _RoutePreviewMode.polyline => _RoutePreviewPolylineSlot(
            route: route,
            thumbnailProvider: thumbnailProvider,
            thumbnailRequest: ActivityRouteThumbnailRequest(
              route: route,
              logicalSize: logicalSize,
              devicePixelRatio: devicePixelRatio,
              allowExternalStaticMap: allowExternalStaticMap,
              isDemoRoute: isDemoRoute,
              activityId: activityId,
            ),
          ),
          _RoutePreviewMode.tinyRoute => Semantics(
            label: 'Tiny route preview',
            child: CustomPaint(
              key: const ValueKey('activity_route_preview_tiny_route'),
              painter: _TinyRoutePreviewPainter(route),
            ),
          ),
          _RoutePreviewMode.fallback => Semantics(
            label: 'Route preview unavailable',
            child: const CustomPaint(
              key: ValueKey('activity_route_preview_fallback'),
              painter: _FallbackRoutePreviewPainter(),
            ),
          ),
        },
      ),
    );
  }
}

abstract interface class ActivityRouteThumbnailProvider {
  Future<ActivityRouteThumbnailResult> resolve(
    ActivityRouteThumbnailRequest request,
  );
}

class ActivityRouteThumbnailRequest {
  const ActivityRouteThumbnailRequest({
    required this.route,
    required this.logicalSize,
    required this.devicePixelRatio,
    required this.allowExternalStaticMap,
    required this.isDemoRoute,
    this.activityId,
  });

  final RunRouteSnapshot route;
  final Size logicalSize;
  final double devicePixelRatio;
  final bool allowExternalStaticMap;
  final bool isDemoRoute;
  final String? activityId;

  @override
  bool operator ==(Object other) {
    return other is ActivityRouteThumbnailRequest &&
        other.route == route &&
        other.logicalSize == logicalSize &&
        other.devicePixelRatio == devicePixelRatio &&
        other.allowExternalStaticMap == allowExternalStaticMap &&
        other.isDemoRoute == isDemoRoute &&
        other.activityId == activityId;
  }

  @override
  int get hashCode {
    return Object.hash(
      route,
      logicalSize,
      devicePixelRatio,
      allowExternalStaticMap,
      isDemoRoute,
      activityId,
    );
  }
}

enum ActivityRouteThumbnailState {
  readyImage,
  loading,
  privacyDisabled,
  tokenMissing,
  requestFailed,
  timedOut,
  unavailable,
}

class ActivityRouteThumbnailResult {
  const ActivityRouteThumbnailResult._(this.state, {this.imageProvider});

  const ActivityRouteThumbnailResult.readyImage(ImageProvider imageProvider)
    : this._(
        ActivityRouteThumbnailState.readyImage,
        imageProvider: imageProvider,
      );

  const ActivityRouteThumbnailResult.loading()
    : this._(ActivityRouteThumbnailState.loading);

  const ActivityRouteThumbnailResult.privacyDisabled()
    : this._(ActivityRouteThumbnailState.privacyDisabled);

  const ActivityRouteThumbnailResult.tokenMissing()
    : this._(ActivityRouteThumbnailState.tokenMissing);

  const ActivityRouteThumbnailResult.requestFailed()
    : this._(ActivityRouteThumbnailState.requestFailed);

  const ActivityRouteThumbnailResult.timedOut()
    : this._(ActivityRouteThumbnailState.timedOut);

  const ActivityRouteThumbnailResult.unavailable()
    : this._(ActivityRouteThumbnailState.unavailable);

  final ActivityRouteThumbnailState state;
  final ImageProvider? imageProvider;

  bool get hasReadyImage {
    return state == ActivityRouteThumbnailState.readyImage &&
        imageProvider != null;
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityRouteThumbnailResult &&
        other.state == state &&
        other.imageProvider == imageProvider;
  }

  @override
  int get hashCode => Object.hash(state, imageProvider);
}

class NoopActivityRouteThumbnailProvider
    implements ActivityRouteThumbnailProvider {
  const NoopActivityRouteThumbnailProvider();

  @override
  Future<ActivityRouteThumbnailResult> resolve(
    ActivityRouteThumbnailRequest request,
  ) async {
    if (!request.allowExternalStaticMap) {
      return const ActivityRouteThumbnailResult.privacyDisabled();
    }
    return const ActivityRouteThumbnailResult.unavailable();
  }
}

class _RoutePreviewPolylineSlot extends StatefulWidget {
  const _RoutePreviewPolylineSlot({
    required this.route,
    required this.thumbnailProvider,
    required this.thumbnailRequest,
  });

  final RunRouteSnapshot route;
  final ActivityRouteThumbnailProvider thumbnailProvider;
  final ActivityRouteThumbnailRequest thumbnailRequest;

  @override
  State<_RoutePreviewPolylineSlot> createState() =>
      _RoutePreviewPolylineSlotState();
}

class _RoutePreviewPolylineSlotState extends State<_RoutePreviewPolylineSlot> {
  late Future<ActivityRouteThumbnailResult> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = widget.thumbnailProvider.resolve(
      widget.thumbnailRequest,
    );
  }

  @override
  void didUpdateWidget(covariant _RoutePreviewPolylineSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thumbnailProvider != widget.thumbnailProvider ||
        oldWidget.thumbnailRequest != widget.thumbnailRequest) {
      _thumbnailFuture = widget.thumbnailProvider.resolve(
        widget.thumbnailRequest,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivityRouteThumbnailResult>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        final thumbnailResult =
            snapshot.data ?? const ActivityRouteThumbnailResult.loading();
        final imageProvider = thumbnailResult.imageProvider;
        if (thumbnailResult.hasReadyImage && imageProvider != null) {
          return Semantics(
            label: 'Static route map thumbnail',
            image: true,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  key: const ValueKey(
                    'activity_route_preview_static_thumbnail',
                  ),
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                CustomPaint(
                  key: const ValueKey(
                    'activity_route_preview_static_thumbnail_route_overlay',
                  ),
                  painter: _RoutePolylinePreviewPainter(
                    widget.route,
                    paintBackdrop: false,
                  ),
                ),
              ],
            ),
          );
        }

        return Semantics(
          label: 'Route-backed activity preview',
          child: CustomPaint(
            key: const ValueKey('activity_route_preview_polyline'),
            painter: _RoutePolylinePreviewPainter(widget.route),
          ),
        );
      },
    );
  }
}

enum _RoutePreviewMode {
  polyline,
  tinyRoute,
  fallback;

  static _RoutePreviewMode forRoute(
    RunRouteSnapshot route, {
    required Size logicalSize,
  }) {
    if (!route.hasRoute) {
      return _RoutePreviewMode.fallback;
    }

    final points = _drawableRoutePoints(route);
    if (points.length < 2) {
      return _RoutePreviewMode.fallback;
    }

    if (_isTinyRoute(points, logicalSize)) {
      return _RoutePreviewMode.tinyRoute;
    }

    return _RoutePreviewMode.polyline;
  }
}

class _FallbackRoutePreviewPainter extends CustomPainter {
  const _FallbackRoutePreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintPreviewBackdrop(canvas, size);
    _paintPreviewGrid(canvas, size);

    final center = Offset(size.width * 0.5, size.height * 0.52);
    final outerPaint = Paint()
      ..color = const Color(0x247D93E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final innerPaint = Paint()
      ..color = const Color(0x1A7D93E1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 9, outerPaint);
    canvas.drawCircle(center, 3.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _FallbackRoutePreviewPainter oldDelegate) {
    return false;
  }
}

class _TinyRoutePreviewPainter extends CustomPainter {
  const _TinyRoutePreviewPainter(this.route);

  final RunRouteSnapshot route;

  @override
  void paint(Canvas canvas, Size size) {
    _paintPreviewBackdrop(canvas, size);
    _paintPreviewGrid(canvas, size);

    final center = Offset(size.width * 0.5, size.height * 0.5);

    final haloPaint = Paint()
      ..color = const Color(0x2E2F50C7)
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()..color = RuniacColors.primaryBlue;
    final ringPaint = Paint()
      ..color = RuniacColors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 10, haloPaint);
    canvas.drawCircle(center, 5.5, dotPaint);
    canvas.drawCircle(center, 5.5, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _TinyRoutePreviewPainter oldDelegate) {
    return oldDelegate.route != route;
  }
}

class _RoutePolylinePreviewPainter extends CustomPainter {
  const _RoutePolylinePreviewPainter(this.route, {this.paintBackdrop = true});

  final RunRouteSnapshot route;
  final bool paintBackdrop;

  @override
  void paint(Canvas canvas, Size size) {
    if (paintBackdrop) {
      _paintPreviewBackdrop(canvas, size);
      _paintPreviewGrid(canvas, size);
    }

    final projection = _RoutePreviewProjection.fromRoute(route, size);
    if (projection == null) {
      if (paintBackdrop) {
        const _FallbackRoutePreviewPainter().paint(canvas, size);
      }
      return;
    }

    final pathPaint = _routePathPaint(RuniacColors.primaryBlue, 3);
    for (final segment in route.segments) {
      final segmentPath = _pathForSegment(segment, projection);
      if (segmentPath != null) {
        canvas.drawPath(segmentPath, pathPaint);
      }
    }

    _paintRouteDots(
      canvas,
      start: projection.project(projection.first),
      end: projection.project(projection.last),
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePolylinePreviewPainter oldDelegate) {
    return oldDelegate.route != route ||
        oldDelegate.paintBackdrop != paintBackdrop;
  }
}

Path? _pathForSegment(
  List<RunLocationSample> segment,
  _RoutePreviewProjection projection,
) {
  final points = segment.where(_isDrawableRoutePoint).toList(growable: false);
  if (points.length < 2) {
    return null;
  }

  final start = projection.project(points.first);
  final path = Path()..moveTo(start.dx, start.dy);
  for (final point in points.skip(1)) {
    final projected = projection.project(point);
    path.lineTo(projected.dx, projected.dy);
  }

  return path;
}

bool _isDrawableRoutePoint(RunLocationSample point) {
  return point.latitude.isFinite && point.longitude.isFinite;
}

List<RunLocationSample> _drawableRoutePoints(RunRouteSnapshot route) {
  return route.segments
      .expand((segment) => segment)
      .where(_isDrawableRoutePoint)
      .toList(growable: false);
}

bool _isTinyRoute(List<RunLocationSample> points, Size logicalSize) {
  if (_routeMovementMeters(points) < _stationaryMovementThresholdMeters) {
    return true;
  }

  final projectedBounds = _RoutePreviewProjection.fromPoints(
    points,
    logicalSize,
  )?.projectedBounds(points);
  if (projectedBounds == null) {
    return true;
  }

  return projectedBounds.width < _tinyRouteProjectedThresholdPx &&
      projectedBounds.height < _tinyRouteProjectedThresholdPx;
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

void _paintPreviewBackdrop(Canvas canvas, Size size) {
  final backdropPaint = Paint()..color = const Color(0xFFF8FAFF);
  canvas.drawRect(Offset.zero & size, backdropPaint);
}

void _paintPreviewGrid(Canvas canvas, Size size) {
  final gridPaint = Paint()
    ..color = const Color(0x0F2F50C7)
    ..strokeWidth = 1;

  canvas.drawLine(
    Offset(size.width * 0.32, 0),
    Offset(size.width * 0.32, size.height),
    gridPaint,
  );
  canvas.drawLine(
    Offset(size.width * 0.68, 0),
    Offset(size.width * 0.68, size.height),
    gridPaint,
  );
  canvas.drawLine(
    Offset(0, size.height * 0.45),
    Offset(size.width, size.height * 0.45),
    gridPaint,
  );
}

Paint _routePathPaint(Color color, double strokeWidth) {
  return Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
}

void _paintRouteDots(
  Canvas canvas, {
  required Offset start,
  required Offset end,
}) {
  final endPaint = Paint()..color = RuniacColors.accentOrange;
  final startPaint = Paint()
    ..color = RuniacColors.white
    ..style = PaintingStyle.fill;
  final startBorderPaint = Paint()
    ..color = RuniacColors.primaryBlue
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  canvas.drawCircle(start, 4, startPaint);
  canvas.drawCircle(start, 4, startBorderPaint);
  canvas.drawCircle(end, 5, endPaint);
}

class _RoutePreviewProjection {
  const _RoutePreviewProjection({
    required this.first,
    required this.last,
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
    required this.offset,
    required this.scale,
  });

  final RunLocationSample first;
  final RunLocationSample last;
  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;
  final Offset offset;
  final double scale;

  static _RoutePreviewProjection? fromRoute(RunRouteSnapshot route, Size size) {
    final points = route.segments
        .expand((segment) => segment)
        .where(_isDrawableRoutePoint)
        .toList(growable: false);
    return _RoutePreviewProjection.fromPoints(points, size);
  }

  static _RoutePreviewProjection? fromPoints(
    List<RunLocationSample> points,
    Size size,
  ) {
    if (points.length < 2) {
      return null;
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

    final drawableSize = Size(
      math.max(1, size.width - (_previewPadding * 2)),
      math.max(1, size.height - (_previewPadding * 2)),
    );
    final longitudeSpan = math.max(maxLongitude - minLongitude, _minRouteSpan);
    final latitudeSpan = math.max(maxLatitude - minLatitude, _minRouteSpan);
    final scale = math.min(
      drawableSize.width / longitudeSpan,
      drawableSize.height / latitudeSpan,
    );
    final projectedWidth = longitudeSpan * scale;
    final projectedHeight = latitudeSpan * scale;

    return _RoutePreviewProjection(
      first: points.first,
      last: points.last,
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
      offset: Offset(
        _previewPadding + ((drawableSize.width - projectedWidth) / 2),
        _previewPadding + ((drawableSize.height - projectedHeight) / 2),
      ),
      scale: scale,
    );
  }

  Offset project(RunLocationSample point) {
    final x = (point.longitude - minLongitude) * scale;
    final y = (maxLatitude - point.latitude) * scale;
    return offset + Offset(x, y);
  }

  Rect projectedBounds(List<RunLocationSample> points) {
    final firstProjected = project(points.first);
    var minX = firstProjected.dx;
    var maxX = firstProjected.dx;
    var minY = firstProjected.dy;
    var maxY = firstProjected.dy;

    for (final point in points.skip(1)) {
      final projected = project(point);
      minX = math.min(minX, projected.dx);
      maxX = math.max(maxX, projected.dx);
      minY = math.min(minY, projected.dy);
      maxY = math.max(maxY, projected.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

const _previewPadding = 7.0;
const _previewSlotSize = 88.0;
const _minRouteSpan = 0.000001;
const _stationaryMovementThresholdMeters = 6.0;
const _tinyRouteProjectedThresholdPx = 6.0;
