import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';
import '../../domain/models/friends_read_model.dart';

class FriendRowBadge extends StatelessWidget {
  const FriendRowBadge({required this.user, super.key});

  final FriendUserReadModel user;

  @override
  Widget build(BuildContext context) {
    final levelLabel = user.levelLabel;
    // The level label is already formatted by the backend. No trusted
    // progress fraction is available, so the ring remains empty. An absent
    // label uses the display-only zero-level placeholder used by Home.
    return ExcludeSemantics(
      child: RuniacLevelProfileBadge(
        initials: user.avatarInitials,
        levelLabel: levelLabel.trim().isEmpty ? 'Lv.0' : levelLabel,
        progressFraction: 0,
        size: 42,
        badgeHeight: 16,
        badgeMinWidth: 42,
        badgeHorizontalPadding: 6,
        badgeFontSize: 9,
        ringStrokeWidth: 4,
        discColor: RuniacColors.primaryBlue,
        discBorderColor: RuniacColors.white,
        initialsColor: RuniacColors.white,
      ),
    );
  }
}

class FriendRowIdentity extends StatelessWidget {
  const FriendRowIdentity({required this.user, super.key});

  final FriendUserReadModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FriendRowName(user: user),
        const SizedBox(height: 3),
        Text(
          user.subtitleLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class FriendRowName extends StatelessWidget {
  const FriendRowName({required this.user, super.key});

  final FriendUserReadModel user;

  @override
  Widget build(BuildContext context) {
    return Text(
      user.displayName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }
}
