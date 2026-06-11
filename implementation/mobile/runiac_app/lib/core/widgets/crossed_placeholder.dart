import 'package:flutter/material.dart';

import '../theme/runiac_colors.dart';

class CrossedPlaceholder extends StatelessWidget {
  const CrossedPlaceholder({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: RuniacColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.border),
      ),
      child: CustomPaint(painter: _PlaceholderCrossPainter()),
    );
  }
}

class _PlaceholderCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RuniacColors.border
      ..strokeWidth = 1.2;

    canvas
      ..drawLine(Offset.zero, Offset(size.width, size.height), paint)
      ..drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
