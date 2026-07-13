part of 'home_stage_map.dart';

class _HomeStageHeader extends StatelessWidget {
  const _HomeStageHeader({
    required this.streakCount,
    required this.unreadNotificationCount,
    required this.levelBadgeLabel,
    required this.levelProgressFraction,
    required this.progressLoading,
    required this.profileLoading,
    required this.profileInitials,
    required this.onNotifications,
    required this.onProfile,
    required this.socialMenuOpen,
    required this.onToggleSocialMenu,
    required this.activeChallenge,
    required this.onOpenChallengeProgress,
    required this.challengeClock,
    required this.challengeTicker,
  });

  final int streakCount;
  final int unreadNotificationCount;
  final String levelBadgeLabel;
  final double levelProgressFraction;
  final bool progressLoading;
  final bool profileLoading;
  final String profileInitials;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final bool socialMenuOpen;
  final VoidCallback onToggleSocialMenu;
  final HomeActiveChallengeDisplay? activeChallenge;
  final VoidCallback? onOpenChallengeProgress;
  final DateTime Function()? challengeClock;
  final ChallengeTicker? challengeTicker;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return IgnorePointer(
      ignoring: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, topPadding + 8, 12, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              RuniacColors.textPrimary.withValues(alpha: 0.72),
              RuniacColors.textPrimary.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StreakPill(streakCount: streakCount, loading: progressLoading),
                if (activeChallenge != null) ...[
                  const SizedBox(height: 8),
                  _HomeActiveChallengeControl(
                    display: activeChallenge!,
                    onOpen: onOpenChallengeProgress,
                    clock: challengeClock,
                    ticker: challengeTicker,
                  ),
                ],
              ],
            ),
            const Spacer(),
            _NotificationButton(
              unreadNotificationCount: unreadNotificationCount,
              onNotifications: onNotifications,
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  container: true,
                  label: 'Profile',
                  button: true,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onProfile,
                      child: SizedBox(
                        width: 60,
                        height: 62,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: _homeStageControlDecoration(
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (progressLoading || profileLoading)
                              const _LoadingProfileBadge()
                            else
                              RuniacLevelProfileBadge(
                                initials: profileInitials,
                                levelLabel: levelBadgeLabel,
                                progressFraction: levelProgressFraction,
                                size: 54,
                                badgeHeight: 17,
                                badgeMinWidth: 44,
                                badgeHorizontalPadding: 7,
                                badgeFontSize: 10,
                                ringStrokeWidth: 4.5,
                                discColor: RuniacColors.primaryBlue,
                                discBorderColor: RuniacColors.white,
                                initialsColor: RuniacColors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _SocialMenuTrigger(
                  open: socialMenuOpen,
                  onTap: onToggleSocialMenu,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular header control shown under the Streak pill while a challenge is
/// ACTIVE or SETTLING. The whole badge + countdown area is ONE semantic button
/// that opens Progress; it contains only the tier badge PNG and a fixed-width
/// `DD:HH:MM:SS` countdown (or the short "Calculating…" copy while settling).
/// No title, distance, percent, participant count, progress bar, or chevron.
