import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFEAE6DD),
      child: Stack(
        children: [
          Positioned.fill(child: _LeaderboardMapBackground()),
          Positioned(
            left: 14,
            right: 14,
            top: 0,
            child: SafeArea(
              minimum: EdgeInsets.only(top: 14),
              child: _LeaderboardTopOverlay(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTopOverlay extends StatelessWidget {
  const _LeaderboardTopOverlay();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _XpSegmentedControl(),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _LeagueSelector()),
            SizedBox(width: 10),
            _InfoBadge(),
          ],
        ),
      ],
    );
  }
}

class _XpSegmentedControl extends StatelessWidget {
  const _XpSegmentedControl();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xEFFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x662F50C7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A172033),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2F5FD7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Weekly XP',
                style: TextStyle(
                  color: RuniacColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Monthly XP',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueSelector extends StatelessWidget {
  const _LeagueSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: const Color(0xEFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x552F50C7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17172033),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          _LeagueMedalIcon(),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rising Runner Division',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Lv.11 - Lv.20',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueMedalIcon extends StatelessWidget {
  const _LeagueMedalIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 34,
      child: CustomPaint(painter: _LeagueMedalPainter()),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Leaderboard information',
      button: true,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _showLeaderboardTipsDialog(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xEFFFFFFF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0x552F50C7), width: 1.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x17172033),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.info_outline,
                color: RuniacColors.primaryBlue,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showLeaderboardTipsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: RuniacColors.textPrimary.withValues(alpha: 0.38),
    builder: (context) => const _LeaderboardTipsDialog(),
  );
}

class _LeaderboardTipsDialog extends StatelessWidget {
  const _LeaderboardTipsDialog();

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.sizeOf(context).height - 56;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 430, maxHeight: maxDialogHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xF8FFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x552F50C7)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33172033),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Close tips',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: RuniacColors.textPrimary,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Tips',
                          style: TextStyle(
                            color: RuniacColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 14),
                const _TipsSection(
                  icon: Icons.emoji_events_outlined,
                  title: 'Leagues',
                  body:
                      'Leagues group runners by broad progress bands so the board feels fair and beginner-friendly.',
                ),
                const SizedBox(height: 10),
                const _TipsSection(
                  icon: Icons.calendar_month_outlined,
                  title: 'Weekly vs Monthly',
                  body:
                      'Weekly and monthly views will help compare progress once leaderboard data is ready.',
                ),
                const SizedBox(height: 10),
                const _TipsSection(
                  icon: Icons.verified_user_outlined,
                  title: 'Ranking readiness',
                  body:
                      'Real rankings will be calculated safely by Runiac later.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RuniacColors.primaryBlue.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: RuniacColors.accentOrange, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardMapBackground extends StatelessWidget {
  const _LeaderboardMapBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: _LeaderboardMapPainter()),
        ),
        Positioned(
          left: 22,
          top: 192,
          child: _RegionMarker(
            color: RuniacColors.primaryBlue,
            label: 'North park area',
          ),
        ),
        const Positioned(right: 32, top: 255, child: _UserAreaMarker()),
        Positioned(
          left: 70,
          bottom: 150,
          child: _RegionMarker(
            color: RuniacColors.primaryBlue.withValues(alpha: 0.74),
            label: 'Canal area',
          ),
        ),
        Positioned(
          right: 48,
          bottom: 92,
          child: _RegionMarker(
            color: RuniacColors.primaryBlue.withValues(alpha: 0.62),
            label: 'Track area',
          ),
        ),
      ],
    );
  }
}

class _RegionMarker extends StatelessWidget {
  const _RegionMarker({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.18), width: 2),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
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
    );
  }
}

class _UserAreaMarker extends StatelessWidget {
  const _UserAreaMarker();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your ranked area',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EC),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFFD1BC), width: 2),
            ),
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33FC6818),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xF7FFFFFF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFFD1BC)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x17172033),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Your ranked area',
              style: TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
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

class _LeagueMedalPainter extends CustomPainter {
  const _LeagueMedalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF96999C);
    final center = Offset(size.width * 0.48, size.height * 0.34);
    canvas.drawCircle(center, size.width * 0.34, paint);

    final ribbonPath = Path()
      ..moveTo(size.width * 0.26, size.height * 0.50)
      ..lineTo(size.width * 0.28, size.height * 0.96)
      ..lineTo(size.width * 0.48, size.height * 0.78)
      ..lineTo(size.width * 0.68, size.height * 0.96)
      ..lineTo(size.width * 0.70, size.height * 0.50)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.66,
        size.width * 0.26,
        size.height * 0.50,
      );

    canvas.drawPath(ribbonPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
