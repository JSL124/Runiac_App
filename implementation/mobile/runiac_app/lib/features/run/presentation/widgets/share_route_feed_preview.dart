import 'package:flutter/material.dart';

const _previewBlue = Color(0xFF2F51C8);

class ShareRouteFeedPreview extends StatelessWidget {
  const ShareRouteFeedPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEFF3FF),
      child: CustomPaint(
        painter: const _ShareRoutePreviewPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ShareRoutePreviewPainter extends CustomPainter {
  const _ShareRoutePreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1;
    for (var x = 24.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 20.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final routePaint = Paint()
      ..color = _previewBlue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(size.width * .18, size.height * .7)
      ..cubicTo(
        size.width * .34,
        size.height * .22,
        size.width * .6,
        size.height * .2,
        size.width * .74,
        size.height * .48,
      )
      ..cubicTo(
        size.width * .88,
        size.height * .78,
        size.width * .5,
        size.height * .84,
        size.width * .38,
        size.height * .62,
      );
    canvas.drawPath(routePath, routePaint);
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .7),
      5,
      Paint()..color = const Color(0xFFFB6414),
    );
  }

  @override
  bool shouldRepaint(covariant _ShareRoutePreviewPainter oldDelegate) {
    return false;
  }
}
