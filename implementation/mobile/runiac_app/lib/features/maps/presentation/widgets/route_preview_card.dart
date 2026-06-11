import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class RoutePreviewCard extends StatelessWidget {
  const RoutePreviewCard({
    required this.title,
    required this.message,
    this.onTap,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(11),
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
        ],
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 92, maxHeight: 92),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: card,
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
      width: 64,
      height: 50,
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
