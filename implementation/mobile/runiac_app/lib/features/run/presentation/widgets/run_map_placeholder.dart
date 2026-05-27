import 'package:flutter/material.dart';

const _mapBlue = Color(0xFF3153C9);
const _softRoadBlue = Color(0x337A91E5);
const _deepRoadBlue = Color(0x28304BB7);
const _routeWhite = Color(0xFFF8FAFF);
const _runnerHalo = Color(0x66304BB7);
const _runnerOrange = Color(0xFFFF6818);

class RunMapPlaceholder extends StatelessWidget {
  const RunMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: _mapBlue),
      child: Stack(
        children: [
          Positioned.fill(child: _RunMapBackground()),
          Center(child: _RunnerMarker()),
        ],
      ),
    );
  }
}

class _RunMapBackground extends StatelessWidget {
  const _RunMapBackground();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _RunMapPainter());
  }
}

class _RunnerMarker extends StatelessWidget {
  const _RunnerMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _runnerHalo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: _runnerOrange,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _RunMapPainter extends CustomPainter {
  const _RunMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = _mapBlue;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final wideRoadPaint = Paint()
      ..color = _softRoadBlue
      ..strokeWidth = size.width * 0.17
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final deepRoadPaint = Paint()
      ..color = _deepRoadBlue
      ..strokeWidth = size.width * 0.13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routePaint = Paint()
      ..color = _routeWhite
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leftRoad = Path()
      ..moveTo(size.width * -0.18, size.height * -0.02)
      ..lineTo(size.width * 0.48, size.height * 0.56);
    final lowerRoad = Path()
      ..moveTo(size.width * -0.12, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.84,
        size.width * 1.14,
        size.height * 0.55,
      );
    final rightRoad = Path()
      ..moveTo(size.width * 1.12, size.height * 0.43)
      ..lineTo(size.width * 0.58, size.height * 0.62)
      ..lineTo(size.width * 0.78, size.height * 1.14);
    final crossRoad = Path()
      ..moveTo(size.width * -0.10, size.height * 0.50)
      ..lineTo(size.width * 1.12, size.height * 0.92);

    canvas.drawPath(leftRoad, wideRoadPaint);
    canvas.drawPath(lowerRoad, wideRoadPaint);
    canvas.drawPath(rightRoad, wideRoadPaint);
    canvas.drawPath(crossRoad, wideRoadPaint);

    final shadowRoad = Path()
      ..moveTo(size.width * 0.56, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.60,
        size.width * 1.08,
        size.height * 0.46,
      );
    canvas.drawPath(shadowRoad, deepRoadPaint);

    final routePath = Path()
      ..moveTo(size.width * -0.08, size.height * 0.64)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.58,
        size.width * 0.34,
        size.height * 0.58,
        size.width * 0.48,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.63,
        size.height * 0.41,
        size.width * 0.72,
        size.height * 0.40,
        size.width * 1.08,
        size.height * 0.42,
      );
    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
