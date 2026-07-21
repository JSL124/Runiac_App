import 'package:flutter/material.dart';

import '../../../../core/formatting/level_label.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';
import '../../domain/models/friends_read_model.dart';

class FriendRowBadge extends StatelessWidget {
  const FriendRowBadge({required this.user, super.key});

  final FriendUserReadModel user;

  @override
  Widget build(BuildContext context) {
    // The level label and progress are already backend-owned. An unresolved
    // level (empty label) falls through to RuniacLevelProfileBadge, which
    // hides the pill entirely rather than rendering a misleading "Lv.0".
    return ExcludeSemantics(
      child: RuniacLevelProfileBadge.row(
        initials: user.avatarInitials,
        levelLabel: compactLevelLabel(user.levelLabel),
        progressFraction: user.levelProgressFraction ?? 0,
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
