import 'package:flutter/material.dart' hide Visibility;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../../core/theme/runiac_colors.dart';
import '../../../run/presentation/widgets/mapbox_runtime_config.dart';
import '../models/leaderboard_display_models.dart';

class LeaderboardMapBackground extends StatelessWidget {
  const LeaderboardMapBackground({
    super.key,
    required this.regions,
    required this.selectedRegionId,
    required this.onRegionSelected,
  });

  final List<LeaderboardMapRegionDisplaySnapshot> regions;
  final String selectedRegionId;
  final ValueChanged<String> onRegionSelected;

  @override
  Widget build(BuildContext context) {
    final mapboxConfig = MapboxRuntimeConfig.fromEnvironment();
    return Stack(
      key: Key(
        mapboxConfig.hasPublicAccessToken
            ? 'leaderboard_mapbox_surface'
            : 'leaderboard_mapbox_fallback_surface',
      ),
      children: [
        Positioned.fill(
          child: mapboxConfig.hasPublicAccessToken
              ? _LeaderboardSingaporeMapboxBackground(config: mapboxConfig)
              : const CustomPaint(painter: _LeaderboardMapPainter()),
        ),
        for (final region in regions)
          Align(
            alignment: region.alignment,
            child: _RegionMarker(
              markerKey: Key('leaderboard_region_polygon_${region.regionId}'),
              region: region,
              selected: region.regionId == selectedRegionId,
              onTap: () => onRegionSelected(region.regionId),
            ),
          ),
      ],
    );
  }
}

class _LeaderboardSingaporeMapboxBackground extends StatefulWidget {
  const _LeaderboardSingaporeMapboxBackground({required this.config});

  final MapboxRuntimeConfig config;

  @override
  State<_LeaderboardSingaporeMapboxBackground> createState() {
    return _LeaderboardSingaporeMapboxBackgroundState();
  }
}

class _LeaderboardSingaporeMapboxBackgroundState
    extends State<_LeaderboardSingaporeMapboxBackground> {
  static final mapbox.CameraViewportState _singaporeViewport =
      mapbox.CameraViewportState(
        center: mapbox.Point(coordinates: mapbox.Position(103.8198, 1.3521)),
        zoom: 10.25,
        pitch: 0,
        bearing: 0,
      );

  @override
  void initState() {
    super.initState();
    mapbox.MapboxOptions.setAccessToken(widget.config.accessToken);
  }

  @override
  void didUpdateWidget(
    covariant _LeaderboardSingaporeMapboxBackground oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.accessToken != widget.config.accessToken) {
      mapbox.MapboxOptions.setAccessToken(widget.config.accessToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return mapbox.MapWidget(
      key: const Key('leaderboard_mapbox_widget'),
      styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
      viewport: _singaporeViewport,
    );
  }
}

class _RegionMarker extends StatelessWidget {
  const _RegionMarker({
    required this.markerKey,
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final Key markerKey;
  final LeaderboardMapRegionDisplaySnapshot region;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: region.semanticLabel,
      child: GestureDetector(
        key: markerKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: region.isUserRegion
                  ? const Key('leaderboard_user_region_highlight')
                  : null,
              width: selected || region.isUserRegion ? 86 : 70,
              height: selected || region.isUserRegion ? 86 : 70,
              child: CustomPaint(
                painter: _RegionPolygonPainter(
                  region: region,
                  selected: selected,
                ),
                child: Center(
                  child: Container(
                    width: selected || region.isUserRegion ? 24 : 18,
                    height: selected || region.isUserRegion ? 24 : 18,
                    decoration: BoxDecoration(
                      color: region.color,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x24172033),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (region.isUserRegion) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xF7FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFFD1BC)),
                ),
                child: const Text(
                  'Your ranked area',
                  style: TextStyle(
                    color: RuniacColors.accentOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RegionPolygonPainter extends CustomPainter {
  const _RegionPolygonPainter({required this.region, required this.selected});

  final LeaderboardMapRegionDisplaySnapshot region;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.54,
        0,
        size.width * 0.88,
        size.height * 0.24,
      )
      ..quadraticBezierTo(
        size.width,
        size.height * 0.58,
        size.width * 0.70,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height,
        size.width * 0.08,
        size.height * 0.62,
      )
      ..close();
    final fillPaint = Paint()
      ..color = region.color.withValues(
        alpha: selected || region.isUserRegion ? 0.26 : 0.16,
      )
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = region.color.withValues(
        alpha: selected || region.isUserRegion ? 0.72 : 0.36,
      )
      ..strokeWidth = selected || region.isUserRegion ? 3 : 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RegionPolygonPainter oldDelegate) {
    return oldDelegate.region != region || oldDelegate.selected != selected;
  }
}

class _LeaderboardMapPainter extends CustomPainter {
  const _LeaderboardMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE9E3D8),
    );

    _drawLandBlocks(canvas, size);
    _drawRoads(canvas, size);
    _drawRegionBoundaries(canvas, size);
    _drawRoute(canvas, size);
  }

  void _drawLandBlocks(Canvas canvas, Size size) {
    final lightBlockPaint = Paint()..color = const Color(0xFFF2EEE5);
    final greenBlockPaint = Paint()..color = const Color(0xFFDDE7D8);
    final warmBlockPaint = Paint()..color = const Color(0xFFEFE0D3);

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-30, 96, size.width * 0.52, size.height * 0.26),
          const Radius.circular(28),
        ),
        greenBlockPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.54,
            128,
            size.width * 0.58,
            size.height * 0.28,
          ),
          const Radius.circular(30),
        ),
        lightBlockPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(18, size.height * 0.47, size.width * 0.48, 148),
          const Radius.circular(26),
        ),
        warmBlockPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.53,
            size.height * 0.58,
            size.width * 0.44,
            154,
          ),
          const Radius.circular(26),
        ),
        greenBlockPaint,
      );
  }

  void _drawRoads(Canvas canvas, Size size) {
    final mainRoadPaint = Paint()
      ..color = const Color(0xEFFFFFFF)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    final softRoadPaint = Paint()
      ..color = const Color(0xBFFFFFFF)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(
        Offset(-size.width * 0.12, 164),
        Offset(size.width * 1.08, size.height * 0.44),
        mainRoadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.72, -30),
        Offset(size.width * 0.32, size.height * 0.98),
        mainRoadPaint,
      )
      ..drawLine(
        Offset(-28, size.height * 0.62),
        Offset(size.width * 0.86, size.height * 0.55),
        softRoadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.12, size.height * 0.30),
        Offset(size.width * 0.92, size.height * 0.82),
        softRoadPaint,
      );
  }

  void _drawRegionBoundaries(Canvas canvas, Size size) {
    final boundaryPaint = Paint()
      ..color = RuniacColors.white.withValues(alpha: 0.38)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(18, 150, size.width * 0.36, size.height * 0.24),
          const Radius.circular(32),
        ),
        boundaryPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.56,
            210,
            size.width * 0.34,
            size.height * 0.25,
          ),
          const Radius.circular(34),
        ),
        boundaryPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(54, size.height * 0.58, size.width * 0.45, 156),
          const Radius.circular(30),
        ),
        boundaryPaint,
      );
  }

  void _drawRoute(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = RuniacColors.primaryBlue.withValues(alpha: 0.74)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(size.width * 0.16, size.height * 0.34)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.24,
        size.width * 0.47,
        size.height * 0.44,
        size.width * 0.64,
        size.height * 0.34,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.27,
        size.width * 0.86,
        size.height * 0.44,
        size.width * 0.72,
        size.height * 0.52,
      );

    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
