import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class RoutePreviewCard extends StatelessWidget {
  const RoutePreviewCard({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 82, maxHeight: 82),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: RuniacColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RuniacColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A172033),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const _RouteThumbnailPlaceholder(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RuniacColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: RuniacColors.primaryBlue,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteThumbnailPlaceholder extends StatelessWidget {
  const _RouteThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDE6FF)),
        ),
        child: const CustomPaint(painter: _RouteThumbnailPainter()),
      ),
    );
  }
}

class _RouteThumbnailPainter extends CustomPainter {
  const _RouteThumbnailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = RuniacColors.white
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(-6, 8),
        Offset(size.width + 6, size.height - 10),
        roadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.58, -4),
        Offset(size.width * 0.35, size.height + 4),
        roadPaint,
      );

    final routePaint = Paint()
      ..color = RuniacColors.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final routePath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.68)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.24,
        size.width * 0.62,
        size.height * 0.84,
        size.width * 0.78,
        size.height * 0.36,
      );
    canvas.drawPath(routePath, routePaint);

    final startPaint = Paint()..color = RuniacColors.accentOrange;
    final endPaint = Paint()..color = RuniacColors.primaryBlue;
    canvas
      ..drawCircle(Offset(size.width * 0.24, size.height * 0.68), 4, startPaint)
      ..drawCircle(Offset(size.width * 0.78, size.height * 0.36), 4, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
