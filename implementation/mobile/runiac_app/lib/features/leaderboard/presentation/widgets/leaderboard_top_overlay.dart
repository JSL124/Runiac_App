import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../data/leaderboard_demo_snapshots.dart';

class LeaderboardTopOverlay extends StatelessWidget {
  const LeaderboardTopOverlay({
    super.key,
    required this.onShowLeagues,
    required this.onShowTips,
  });

  final VoidCallback onShowLeagues;
  final VoidCallback onShowTips;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _LeagueSelector(onTap: onShowLeagues)),
        const SizedBox(width: 10),
        _InfoBadge(onTap: onShowTips),
      ],
    );
  }
}

class _LeagueSelector extends StatelessWidget {
  const _LeagueSelector({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Open leagues list',
      button: true,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Ink(
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
              child: Row(
                children: [
                  const LeaderboardLeagueMedalIcon(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      leaderboardLeagueDemoSnapshot.selectedDivision,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RuniacColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    leaderboardLeagueDemoSnapshot.selectedLevelRange,
                    style: const TextStyle(
                      color: RuniacColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LeaderboardLeagueMedalIcon extends StatelessWidget {
  const LeaderboardLeagueMedalIcon({
    super.key,
    this.width = 30,
    this.height = 34,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _LeagueMedalPainter()),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.onTap});

  final VoidCallback onTap;

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
            onTap: onTap,
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
