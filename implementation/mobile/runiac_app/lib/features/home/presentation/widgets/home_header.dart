import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';

const _brandBlue = RuniacColors.primaryBlue;
const _sportOrange = RuniacColors.accentOrange;

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.onNotifications,
    required this.onProfile,
    this.unreadNotificationCount = 0,
    this.profileInitials = 'R',
    this.levelBadgeLabel = 'Lv.0',
    this.levelProgressFraction = 0,
    super.key,
  });

  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final int unreadNotificationCount;
  final String profileInitials;
  final String levelBadgeLabel;
  final double levelProgressFraction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeAccentBar(),
              SizedBox(height: 12),
              Text(
                'Good to see you',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your Home dashboard is ready for a calm start.',
                style: TextStyle(
                  color: RuniacColors.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _HomeProfilePlaceholder(
          onNotifications: onNotifications,
          onProfile: onProfile,
          unreadNotificationCount: unreadNotificationCount,
          profileInitials: profileInitials,
          levelBadgeLabel: levelBadgeLabel,
          levelProgressFraction: levelProgressFraction,
        ),
      ],
    );
  }
}

class _HomeProfilePlaceholder extends StatelessWidget {
  const _HomeProfilePlaceholder({
    required this.onNotifications,
    required this.onProfile,
    required this.unreadNotificationCount,
    required this.profileInitials,
    required this.levelBadgeLabel,
    required this.levelProgressFraction,
  });

  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final int unreadNotificationCount;
  final String profileInitials;
  final String levelBadgeLabel;
  final double levelProgressFraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 66,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 11,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Semantics(
                  container: true,
                  label: 'Notifications',
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onNotifications,
                    child: const SizedBox.square(
                      dimension: 44,
                      child: Icon(
                        Icons.notifications_none,
                        color: RuniacColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                if (unreadNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _UnreadNotificationBadge(
                      count: unreadNotificationCount,
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Semantics(
              container: true,
              label: 'Profile',
              button: true,
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onProfile,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: RuniacLevelProfileBadge(
                      initials: profileInitials,
                      levelLabel: levelBadgeLabel,
                      progressFraction: levelProgressFraction,
                      size: 62,
                      badgeHeight: 21,
                      badgeMinWidth: 54,
                      badgeHorizontalPadding: 9,
                      badgeFontSize: 12,
                      ringStrokeWidth: 5,
                      discColor: _brandBlue,
                      discBorderColor: RuniacColors.white,
                      initialsColor: RuniacColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadNotificationBadge extends StatelessWidget {
  const _UnreadNotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: RuniacColors.errorRed,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RuniacColors.white, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: RuniacColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _HomeAccentBar extends StatelessWidget {
  const _HomeAccentBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: _brandBlue,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            color: _sportOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
