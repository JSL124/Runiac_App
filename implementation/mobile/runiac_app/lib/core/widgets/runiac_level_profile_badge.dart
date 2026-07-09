import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/runiac_colors.dart';

class RuniacLevelProfileBadge extends StatelessWidget {
  const RuniacLevelProfileBadge({
    required this.initials,
    required this.levelLabel,
    required this.progressFraction,
    this.size = 96,
    this.badgeHeight = 30,
    this.badgeMinWidth = 72,
    this.badgeHorizontalPadding = 13,
    this.badgeFontSize = 13,
    this.ringStrokeWidth,
    super.key,
  });

  final String initials;
  final String levelLabel;
  final double progressFraction;
  final double size;
  final double badgeHeight;
  final double badgeMinWidth;
  final double badgeHorizontalPadding;
  final double badgeFontSize;
  final double? ringStrokeWidth;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size * 0.74;
    final ringStroke = ringStrokeWidth ?? (size < 80 ? 7.0 : 8.0);
    final badgeTop = size - (badgeHeight * 0.85);
    return Semantics(
      label: levelLabel.isEmpty
          ? 'Runner profile'
          : 'Runner profile $levelLabel',
      button: false,
      child: SizedBox(
        width: size,
        height: size + (badgeHeight * 0.12),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _RuniacLevelRingPainter(
                progress: progressFraction,
                strokeWidth: ringStroke,
              ),
            ),
            Positioned(
              top: (size - avatarSize) / 2,
              child: _ProfileInitialsDisc(
                initials: initials,
                size: avatarSize,
                fontSize: size < 80 ? 24 : 30,
              ),
            ),
            if (levelLabel.isNotEmpty)
              Positioned(
                top: badgeTop,
                child: _LevelPill(
                  label: levelLabel,
                  height: badgeHeight,
                  minWidth: badgeMinWidth,
                  horizontalPadding: badgeHorizontalPadding,
                  fontSize: badgeFontSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInitialsDisc extends StatelessWidget {
  const _ProfileInitialsDisc({
    required this.initials,
    required this.size,
    required this.fontSize,
  });

  final String initials;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue.withValues(alpha: 0.06),
        shape: BoxShape.circle,
        border: Border.all(
          color: RuniacColors.primaryBlue.withValues(alpha: 0.10),
          width: 2,
        ),
      ),
      child: Text(
        _initialLabel(initials),
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: RuniacColors.primaryBlue,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }

  String _initialLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'R';
    }
    return trimmed.characters.first.toUpperCase();
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({
    required this.label,
    required this.height,
    required this.minWidth,
    required this.horizontalPadding,
    required this.fontSize,
  });

  final String label;
  final double height;
  final double minWidth;
  final double horizontalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: minWidth),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: RuniacColors.accentOrange,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RuniacColors.accentOrange, width: 2),
        boxShadow: [
          BoxShadow(
            color: RuniacColors.accentOrange.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: RuniacColors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _RuniacLevelRingPainter extends CustomPainter {
  const _RuniacLevelRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  static const _startAngle = math.pi * 0.68;

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = RuniacColors.primaryBlue.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = RuniacColors.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RuniacLevelRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
