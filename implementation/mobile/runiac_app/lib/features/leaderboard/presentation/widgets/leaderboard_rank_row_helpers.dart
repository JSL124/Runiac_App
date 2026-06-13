import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../models/leaderboard_display_models.dart';

({Color background, Color foreground}) resolveRegionPreviewMedalColors(
  RegionPreviewMedalTone tone,
) {
  return switch (tone) {
    RegionPreviewMedalTone.gold => (
      background: const Color(0xFFFFF2E2),
      foreground: RuniacColors.accentOrange,
    ),
    RegionPreviewMedalTone.silver => (
      background: const Color(0xFFEFF3FB),
      foreground: RuniacColors.textSecondary,
    ),
    RegionPreviewMedalTone.bronze => (
      background: const Color(0xFFFFEBDD),
      foreground: const Color(0xFFB56A36),
    ),
  };
}

class LeaderboardInitialBadge extends StatelessWidget {
  const LeaderboardInitialBadge({
    super.key,
    required this.name,
    required this.isCurrentUser,
  });

  final String name;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFFFFE2D2)
            : RuniacColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD4DDF7)),
      ),
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: RuniacColors.primaryBlue,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
