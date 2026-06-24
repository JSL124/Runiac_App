import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../run/domain/models/run_location_sample.dart';
import '../../../run/domain/models/run_route_snapshot.dart';

class ActivityRoutePreview extends StatelessWidget {
  const ActivityRoutePreview({required this.route, super.key});

  final RunRouteSnapshot route;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('activity_route_preview_slot'),
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(9),
      decoration: _routeTileDecoration,
      child: DecoratedBox(
        decoration: _routeTileInnerDecoration,
        child: route.hasRoute
            ? CustomPaint(
                key: const ValueKey('activity_route_preview_polyline'),
                painter: _RoutePolylinePreviewPainter(route),
              )
            : const CustomPaint(
                key: ValueKey('activity_route_preview_fallback'),
                painter: _FallbackRoutePreviewPainter(),
              ),
      ),
    );
  }
}

class _FallbackRoutePreviewPainter extends CustomPainter {
  const _FallbackRoutePreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintPreviewGrid(canvas, size);

    final pathPaint = _routePathPaint(const Color(0x802F50C7), 2.4);
    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.68)
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.62,
        size.width * 0.48,
        size.height * 0.48,
        size.width * 0.64,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.48,
        size.width * 0.78,
        size.height * 0.28,
      );

    canvas.drawPath(path, pathPaint);
    _paintRouteDots(
      canvas,
      start: Offset(size.width * 0.24, size.height * 0.68),
      end: Offset(size.width * 0.78, size.height * 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant _FallbackRoutePreviewPainter oldDelegate) {
    return false;
  }
}

class _RoutePolylinePreviewPainter extends CustomPainter {
  const _RoutePolylinePreviewPainter(this.route);

  final RunRouteSnapshot route;

  @override
  void paint(Canvas canvas, Size size) {
    _paintPreviewGrid(canvas, size);

    final projection = _RoutePreviewProjection.fromRoute(route, size);
    if (projection == null) {
      const _FallbackRoutePreviewPainter().paint(canvas, size);
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
    return oldDelegate.route != route;
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

void _paintPreviewGrid(Canvas canvas, Size size) {
  final gridPaint = Paint()
    ..color = const Color(0x1A2F50C7)
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
}

final _routeTileDecoration = BoxDecoration(
  color: RuniacColors.innerTileSurface,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: RuniacColors.cardBorder, width: 1.4),
);

final _routeTileInnerDecoration = BoxDecoration(
  color: RuniacColors.sectionSurface,
  borderRadius: BorderRadius.circular(12),
);

const _previewPadding = 7.0;
const _minRouteSpan = 0.000001;
