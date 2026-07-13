import 'package:flutter/material.dart';

import '../../../../core/assets/runiac_assets.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';
import '../../domain/models/friends_read_model.dart';

/// Display-only row for a friend, suggested runner, or search result.
class FriendUserRow extends StatelessWidget {
  const FriendUserRow({
    required this.user,
    this.onAdd,
    this.isPending = false,
    super.key,
  }) : assert(!isPending || onAdd == null);

  final FriendUserReadModel user;
  final VoidCallback? onAdd;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            _FriendRowBadge(user: user),
            const SizedBox(width: 12),
            Expanded(child: _FriendRowName(user: user)),
            if (onAdd != null || isPending) ...[
              const SizedBox(width: 8),
              _FriendRequestAction(
                user: user,
                onAdd: onAdd,
                isPending: isPending,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Incoming friend request row with session-local Accept/Decline actions.
/// The callbacks only rearrange local display lists; nothing is persisted.
class FriendRequestRow extends StatelessWidget {
  const FriendRequestRow({
    required this.user,
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final FriendUserReadModel user;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            _FriendRowBadge(user: user),
            const SizedBox(width: 12),
            Expanded(child: _FriendRowIdentity(user: user)),
            const SizedBox(width: 10),
            RuniacTappableSurface(
              semanticLabel: 'Accept ${user.displayName}',
              onTap: onAccept,
              borderRadius: BorderRadius.circular(999),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: RuniacColors.primaryBlue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Accept',
                style: TextStyle(
                  color: RuniacColors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            RuniacTappableSurface(
              semanticLabel: 'Decline ${user.displayName}',
              onTap: onDecline,
              borderRadius: BorderRadius.circular(999),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: RuniacColors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: RuniacColors.border),
              ),
              child: const Text(
                'Decline',
                style: TextStyle(
                  color: RuniacColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendRowBadge extends StatelessWidget {
  const _FriendRowBadge({required this.user});

  final FriendUserReadModel user;

  @override
  Widget build(BuildContext context) {
    // Level label is a backend-owned pre-formatted display string; the badge
    // ring stays empty because no trusted progress fraction is supplied.
    return ExcludeSemantics(
      child: RuniacLevelProfileBadge(
        initials: user.avatarInitials,
        levelLabel: user.levelLabel,
        progressFraction: 0,
        size: 42,
        badgeHeight: 16,
        badgeMinWidth: 42,
        badgeHorizontalPadding: 6,
        badgeFontSize: 9,
        ringStrokeWidth: 4,
      ),
    );
  }
}

class _FriendRowIdentity extends StatelessWidget {
  const _FriendRowIdentity({required this.user});

  final FriendUserReadModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: RuniacColors.textPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
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

class _FriendRowName extends StatelessWidget {
  const _FriendRowName({required this.user});

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

class _FriendRequestAction extends StatelessWidget {
  const _FriendRequestAction({
    required this.user,
    required this.onAdd,
    required this.isPending,
  });

  final FriendUserReadModel user;
  final VoidCallback? onAdd;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final icon = ImageIcon(
      AssetImage(
        isPending ? RuniacAssets.friendsPending : RuniacAssets.friendsAdd,
      ),
      color: RuniacColors.primaryBlue,
      size: 22,
    );

    if (isPending) {
      return Semantics(
        container: true,
        label: 'Pending ${user.displayName}',
        enabled: false,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: ExcludeSemantics(child: icon)),
        ),
      );
    }

    return Semantics(
      container: true,
      child: RuniacTappableSurface(
        key: ValueKey('friends-add-action-${user.userId}'),
        semanticLabel: 'Add ${user.displayName}',
        onTap: onAdd,
        width: 44,
        height: 44,
        alignment: Alignment.center,
        borderRadius: BorderRadius.circular(999),
        child: ExcludeSemantics(child: icon),
      ),
    );
  }
}

/// Supportive per-tab empty state for the static Friends shell.
class FriendsEmptyState extends StatelessWidget {
  const FriendsEmptyState({required this.title, required this.body, super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              color: RuniacColors.textSecondary,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
