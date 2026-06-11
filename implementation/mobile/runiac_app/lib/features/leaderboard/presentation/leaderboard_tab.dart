import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_bottom_sheet_handle.dart';
import '../../../core/widgets/runiac_share_bottom_sheet.dart';

const _shareRankCardAsset =
    'assets/images/leaderboard/share_rank_card_background.png';
const _instagramStoriesIconAsset = 'assets/icons/instagram_stories.png';

const _leaderboardPreviewSnapshot = _LeaderboardPreviewSnapshot(
  tipsTitle: 'Tips',
  leaguesTipTitle: 'Leagues',
  cadenceTipTitle: 'Board timing',
  readinessTipTitle: 'Static sample data',
  leaguesTipBody:
      'Leagues group runners by broad progress bands so the board feels fair and beginner-friendly.',
  cadenceTipBody:
      'This static preview keeps one monthly board context for a calmer comparison.',
  readinessTipBody:
      'Leaderboard values shown here are display-only sample rows for this UI milestone.',
);

const _leaderboardLeagueSnapshot = _LeaderboardLeagueSnapshot(
  selectedDivision: 'Rising Runner Division',
  selectedLevelRange: 'Lv.11 - Lv.20',
  dialogTitle: 'Leagues',
  entries: [
    _LeagueTaxonomyEntry('Apex Runner League', 'Lv.81 - Lv.90'),
    _LeagueTaxonomyEntry('Summitborn League', 'Lv.71 - Lv.80'),
    _LeagueTaxonomyEntry('Roadrunner League', 'Lv.51 - Lv.60'),
    _LeagueTaxonomyEntry('Endurancer League', 'Lv.41 - Lv.50'),
    _LeagueTaxonomyEntry('Milehunter League', 'Lv.31 - Lv.40'),
    _LeagueTaxonomyEntry('Pacebreaker League', 'Lv.21 - Lv.30'),
    _LeagueTaxonomyEntry('Strideforge League', 'Lv.11 - Lv.20'),
    _LeagueTaxonomyEntry('Trailborn League', 'Lv.1 - Lv.10'),
  ],
);

const _leaderboardRegionSnapshot = _LeaderboardRegionSnapshot(
  regionName: 'Jurong East',
  rankPreviewTitle: 'My Rank Preview',
  primaryActionLabel: 'View More Ranking',
  secondaryActionLabel: 'Share My Rank',
  userAreaLabel: 'Your ranked area',
);

const _leaderboardDetailSnapshot = _LeaderboardDetailDisplaySnapshot(
  regionName: 'Jurong East',
  periodLabel: 'June 2026',
  fallbackPeriodLabel: 'Monthly board',
  refreshLabel: 'Refreshes in 24:14:05:45',
  fallbackRefreshLabel: 'Refreshes in 00:00:00:00',
  divisionLabel: 'Rising Runner Division',
  topRanksTitle: 'Regional ranking',
  nearbyRanksTitle: 'Nearby your rank',
  currentUser: _CurrentUserRankSummaryDisplaySnapshot(
    rankLabel: '#18',
    title: 'You · Monthly ranking preview',
    xpLabel: '520 XP',
  ),
  topRanks: [
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#1',
      name: 'Alex T.',
      levelLabel: 'Level 18',
      xpLabel: '1,240 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Alex T.',
        initial: 'A',
        regionRankLabel: 'Jurong East · Rank #1',
        levelBadgeLabel: 'Lv.18',
        divisionLevelLabel: 'Rising Runner Division · Level 18',
        totalDistanceLabel: '10000 km',
        bestStreakLabel: '365 days',
      ),
      trophy: true,
      medalTone: _RegionPreviewMedalTone.gold,
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#2',
      name: 'Maya L.',
      levelLabel: 'Level 17',
      xpLabel: '1,180 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Maya L.',
        initial: 'M',
        regionRankLabel: 'Jurong East · Rank #2',
        levelBadgeLabel: 'Lv.17',
        divisionLevelLabel: 'Rising Runner Division · Level 17',
        totalDistanceLabel: '198.2 km',
        bestStreakLabel: '19 days',
      ),
      medalTone: _RegionPreviewMedalTone.silver,
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#3',
      name: 'Ryan K.',
      levelLabel: 'Level 16',
      xpLabel: '1,050 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Ryan K.',
        initial: 'R',
        regionRankLabel: 'Jurong East · Rank #3',
        levelBadgeLabel: 'Lv.16',
        divisionLevelLabel: 'Rising Runner Division · Level 16',
        totalDistanceLabel: '176.0 km',
        bestStreakLabel: '18 days',
      ),
      medalTone: _RegionPreviewMedalTone.bronze,
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#4',
      name: 'Ethan G.',
      levelLabel: 'Level 15',
      xpLabel: '870 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Ethan G.',
        initial: 'E',
        regionRankLabel: 'Jurong East · Rank #4',
        levelBadgeLabel: 'Lv.15',
        divisionLevelLabel: 'Rising Runner Division · Level 15',
        totalDistanceLabel: '154.5 km',
        bestStreakLabel: '16 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#5',
      name: 'Sarah C.',
      levelLabel: 'Level 14',
      xpLabel: '760 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Sarah C.',
        initial: 'S',
        regionRankLabel: 'Jurong East · Rank #5',
        levelBadgeLabel: 'Lv.14',
        divisionLevelLabel: 'Rising Runner Division · Level 14',
        totalDistanceLabel: '143.6 km',
        bestStreakLabel: '15 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#6',
      name: 'Priya N.',
      levelLabel: 'Level 14',
      xpLabel: '735 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Priya N.',
        initial: 'P',
        regionRankLabel: 'Jurong East · Rank #6',
        levelBadgeLabel: 'Lv.14',
        divisionLevelLabel: 'Rising Runner Division · Level 14',
        totalDistanceLabel: '139.2 km',
        bestStreakLabel: '14 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#7',
      name: 'Omar R.',
      levelLabel: 'Level 13',
      xpLabel: '710 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Omar R.',
        initial: 'O',
        regionRankLabel: 'Jurong East · Rank #7',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '135.8 km',
        bestStreakLabel: '13 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#8',
      name: 'Hana S.',
      levelLabel: 'Level 13',
      xpLabel: '690 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Hana S.',
        initial: 'H',
        regionRankLabel: 'Jurong East · Rank #8',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '132.4 km',
        bestStreakLabel: '12 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#9',
      name: 'Leo P.',
      levelLabel: 'Level 13',
      xpLabel: '675 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Leo P.',
        initial: 'L',
        regionRankLabel: 'Jurong East · Rank #9',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '130.1 km',
        bestStreakLabel: '12 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#10',
      name: 'Grace L.',
      levelLabel: 'Level 13',
      xpLabel: '660 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Grace L.',
        initial: 'G',
        regionRankLabel: 'Jurong East · Rank #10',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '128.8 km',
        bestStreakLabel: '11 days',
      ),
    ),
  ],
  nearbyRanks: [
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#16',
      name: 'Chloe B.',
      levelLabel: 'Level 13',
      xpLabel: '650 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Chloe B.',
        initial: 'C',
        regionRankLabel: 'Jurong East · Rank #16',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '126.1 km',
        bestStreakLabel: '11 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#17',
      name: 'Daniel W.',
      levelLabel: 'Level 13',
      xpLabel: '640 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Daniel W.',
        initial: 'D',
        regionRankLabel: 'Jurong East · Rank #17',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '124.7 km',
        bestStreakLabel: '10 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#18',
      name: 'Jinseo (You)',
      levelLabel: 'Level 12',
      xpLabel: '520 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Jinseo',
        initial: 'J',
        regionRankLabel: 'Jurong East · Rank #18',
        levelBadgeLabel: 'Lv.12',
        divisionLevelLabel: 'Rising Runner Division · Level 12',
        totalDistanceLabel: '128.4 km',
        bestStreakLabel: '14 days',
        isCurrentUser: true,
      ),
      isCurrentUser: true,
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#19',
      name: 'Noah K.',
      levelLabel: 'Level 12',
      xpLabel: '505 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Noah K.',
        initial: 'N',
        regionRankLabel: 'Jurong East · Rank #19',
        levelBadgeLabel: 'Lv.12',
        divisionLevelLabel: 'Rising Runner Division · Level 12',
        totalDistanceLabel: '119.3 km',
        bestStreakLabel: '9 days',
      ),
    ),
    _LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#20',
      name: 'Aisha P.',
      levelLabel: 'Level 12',
      xpLabel: '492 XP',
      profile: _RunnerAchievementProfileSnapshot(
        name: 'Aisha P.',
        initial: 'A',
        regionRankLabel: 'Jurong East · Rank #20',
        levelBadgeLabel: 'Lv.12',
        divisionLevelLabel: 'Rising Runner Division · Level 12',
        totalDistanceLabel: '116.6 km',
        bestStreakLabel: '8 days',
      ),
    ),
  ],
);

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  static const double _expandedSheetHeight = 464;
  static const double _collapsedSheetHeight = 46;

  double _sheetProgress = 1;
  bool _showingDetail = false;
  _RunnerAchievementProfileSnapshot? _selectedProfile;

  void _openDetail() {
    setState(() {
      _showingDetail = true;
    });
  }

  void _closeDetail() {
    setState(() {
      _showingDetail = false;
      _selectedProfile = null;
    });
  }

  void _openRunnerProfile(_RunnerAchievementProfileSnapshot profile) {
    setState(() {
      _selectedProfile = profile;
    });
  }

  void _openShareRankPanel() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: RuniacColors.textPrimary.withValues(alpha: 0.48),
      builder: (context) {
        final currentUserRow = _leaderboardDetailSnapshot.nearbyRanks
            .firstWhere((row) => row.isCurrentUser);

        return _ShareRankFloatingPanel(
          regionName: _leaderboardRegionSnapshot.regionName,
          divisionName: _leaderboardDetailSnapshot.divisionLabel,
          rankLabel: currentUserRow.rankLabel,
        );
      },
    );
  }

  void _closeRunnerProfile() {
    setState(() {
      _selectedProfile = null;
    });
  }

  void _expandSheet() {
    setState(() {
      _sheetProgress = 1;
    });
  }

  void _handleSheetDragUpdate(DragUpdateDetails details) {
    setState(() {
      _sheetProgress =
          (_sheetProgress -
                  details.delta.dy /
                      (_expandedSheetHeight - _collapsedSheetHeight))
              .clamp(0, 1);
    });
  }

  void _handleSheetDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    setState(() {
      if (velocity > 260) {
        _sheetProgress = 0;
      } else if (velocity < -260) {
        _sheetProgress = 1;
      } else {
        _sheetProgress = _sheetProgress >= 0.5 ? 1 : 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedProfile = _selectedProfile;
    if (selectedProfile != null) {
      return _RunnerAchievementProfileScreen(
        profile: selectedProfile,
        onBack: _closeRunnerProfile,
      );
    }

    if (_showingDetail) {
      return _LeaderboardDetailScreen(
        onBack: _closeDetail,
        onProfileSelected: _openRunnerProfile,
      );
    }

    final hiddenSheetHeight =
        (_expandedSheetHeight - _collapsedSheetHeight) * (1 - _sheetProgress);

    return ColoredBox(
      color: const Color(0xFFEAE6DD),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _expandSheet,
              child: const _LeaderboardMapBackground(),
            ),
          ),
          const Positioned(
            left: 14,
            right: 14,
            top: 0,
            child: SafeArea(
              minimum: EdgeInsets.only(top: 14),
              child: _LeaderboardTopOverlay(),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: -hiddenSheetHeight,
            child: _RegionPreviewSheet(
              height: _expandedSheetHeight,
              onVerticalDragUpdate: _handleSheetDragUpdate,
              onVerticalDragEnd: _handleSheetDragEnd,
              onViewMoreRanking: _openDetail,
              onShareMyRank: _openShareRankPanel,
              onProfileSelected: _openRunnerProfile,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPreviewSnapshot {
  const _LeaderboardPreviewSnapshot({
    required this.tipsTitle,
    required this.leaguesTipTitle,
    required this.cadenceTipTitle,
    required this.readinessTipTitle,
    required this.leaguesTipBody,
    required this.cadenceTipBody,
    required this.readinessTipBody,
  });

  final String tipsTitle;
  final String leaguesTipTitle;
  final String cadenceTipTitle;
  final String readinessTipTitle;
  final String leaguesTipBody;
  final String cadenceTipBody;
  final String readinessTipBody;
}

class _LeaderboardLeagueSnapshot {
  const _LeaderboardLeagueSnapshot({
    required this.selectedDivision,
    required this.selectedLevelRange,
    required this.dialogTitle,
    required this.entries,
  });

  final String selectedDivision;
  final String selectedLevelRange;
  final String dialogTitle;
  final List<_LeagueTaxonomyEntry> entries;
}

class _LeaderboardRegionSnapshot {
  const _LeaderboardRegionSnapshot({
    required this.regionName,
    required this.rankPreviewTitle,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.userAreaLabel,
  });

  final String regionName;
  final String rankPreviewTitle;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final String userAreaLabel;
}

class _LeaderboardDetailDisplaySnapshot {
  const _LeaderboardDetailDisplaySnapshot({
    required this.regionName,
    required this.periodLabel,
    required this.fallbackPeriodLabel,
    required this.refreshLabel,
    required this.fallbackRefreshLabel,
    required this.divisionLabel,
    required this.topRanksTitle,
    required this.nearbyRanksTitle,
    required this.currentUser,
    required this.topRanks,
    required this.nearbyRanks,
  });

  final String regionName;
  final String periodLabel;
  final String fallbackPeriodLabel;
  final String refreshLabel;
  final String fallbackRefreshLabel;
  final String divisionLabel;
  final String topRanksTitle;
  final String nearbyRanksTitle;
  final _CurrentUserRankSummaryDisplaySnapshot currentUser;
  final List<_LeaderboardRankRowDisplaySnapshot> topRanks;
  final List<_LeaderboardRankRowDisplaySnapshot> nearbyRanks;
}

String resolveLeaderboardPeriodLabelForDisplay({
  required String periodLabel,
  required String fallbackPeriodLabel,
}) {
  final trimmedPeriodLabel = periodLabel.trim();
  if (trimmedPeriodLabel.isNotEmpty) {
    return trimmedPeriodLabel;
  }

  return fallbackPeriodLabel;
}

class _LeaderboardRankRowDisplaySnapshot {
  const _LeaderboardRankRowDisplaySnapshot({
    required this.rankLabel,
    required this.name,
    required this.levelLabel,
    required this.xpLabel,
    required this.profile,
    this.trophy = false,
    this.isCurrentUser = false,
    this.medalTone,
  });

  final String rankLabel;
  final String name;
  final String levelLabel;
  final String xpLabel;
  final _RunnerAchievementProfileSnapshot profile;
  final bool trophy;
  final bool isCurrentUser;
  final _RegionPreviewMedalTone? medalTone;
}

const _runnerAchievementBadges = [
  _RunnerAchievementBadgeSnapshot(
    icon: Icons.flag_outlined,
    label: 'First 5K',
    highlighted: true,
  ),
  _RunnerAchievementBadgeSnapshot(
    icon: Icons.check,
    label: 'Consistency Starter',
  ),
  _RunnerAchievementBadgeSnapshot(
    icon: Icons.favorite_border,
    label: 'Weekend Runner',
  ),
  _RunnerAchievementBadgeSnapshot(
    icon: Icons.wb_sunny_outlined,
    label: 'Morning Miles',
    highlighted: true,
  ),
  _RunnerAchievementBadgeSnapshot(
    icon: Icons.route_outlined,
    label: 'Steady Builder',
  ),
  _RunnerAchievementBadgeSnapshot(
    icon: Icons.location_on_outlined,
    label: 'Park Route Fan',
  ),
];

class _RunnerAchievementProfileSnapshot {
  const _RunnerAchievementProfileSnapshot({
    required this.name,
    required this.initial,
    required this.regionRankLabel,
    required this.levelBadgeLabel,
    required this.divisionLevelLabel,
    required this.totalDistanceLabel,
    required this.bestStreakLabel,
    this.isCurrentUser = false,
  });

  final String name;
  final String initial;
  final String regionRankLabel;
  final String levelBadgeLabel;
  final String divisionLevelLabel;
  final String totalDistanceLabel;
  final String bestStreakLabel;
  final String privacyNote = 'Only public running achievements are shown.';
  final List<_RunnerAchievementBadgeSnapshot> badges = _runnerAchievementBadges;
  final bool isCurrentUser;
}

class _RunnerAchievementBadgeSnapshot {
  const _RunnerAchievementBadgeSnapshot({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;
}

class _CurrentUserRankSummaryDisplaySnapshot {
  const _CurrentUserRankSummaryDisplaySnapshot({
    required this.rankLabel,
    required this.title,
    required this.xpLabel,
  });

  final String rankLabel;
  final String title;
  final String xpLabel;
}

class _RunnerAchievementProfileScreen extends StatelessWidget {
  const _RunnerAchievementProfileScreen({
    required this.profile,
    required this.onBack,
  });

  final _RunnerAchievementProfileSnapshot profile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Runner profile',
              tooltip: 'Back to Rankings',
              onBack: onBack,
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RunnerIdentityCard(profile: profile),
                      const SizedBox(height: 16),
                      _RunnerPublicMetrics(profile: profile),
                      const SizedBox(height: 18),
                      _RunnerAchievementsSection(profile: profile),
                      const SizedBox(height: 14),
                      Text(
                        profile.privacyNote,
                        key: const Key('runner_profile_privacy_note'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunnerIdentityCard extends StatelessWidget {
  const _RunnerIdentityCard({required this.profile});

  final _RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 12,
            decoration: const BoxDecoration(
              color: RuniacColors.accentOrange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    _RunnerProfileAvatar(profile: profile),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RuniacColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFFE1E8FF),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  profile.regionRankLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFE1E8FF),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: RuniacColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          color: RuniacColors.accentOrange,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profile.divisionLevelLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RuniacColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _RunnerProfileAvatar extends StatelessWidget {
  const _RunnerProfileAvatar({required this.profile});

  final _RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: RuniacColors.accentOrange, width: 3),
          ),
          child: Text(
            profile.initial,
            style: const TextStyle(
              color: RuniacColors.primaryBlue,
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          bottom: -11,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: RuniacColors.accentOrange,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                profile.levelBadgeLabel,
                style: const TextStyle(
                  color: RuniacColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RunnerPublicMetrics extends StatelessWidget {
  const _RunnerPublicMetrics({required this.profile});

  final _RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RunnerMetricTile(
            key: const Key('runner_profile_total_distance_metric'),
            icon: Icons.route_outlined,
            value: profile.totalDistanceLabel,
            label: 'Total distance',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RunnerMetricTile(
            key: const Key('runner_profile_best_streak_metric'),
            icon: Icons.water_drop_outlined,
            value: profile.bestStreakLabel,
            label: 'Best streak',
          ),
        ),
      ],
    );
  }
}

class _RunnerMetricTile extends StatelessWidget {
  const _RunnerMetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE3F8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: RuniacColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RunnerMetricValueText(value: value),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _RunnerMetricValueText extends StatelessWidget {
  const _RunnerMetricValueText({required this.value});

  static const double maxFontSize = 24;
  static const double minFontSize = 16;

  final String value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = resolveRunnerMetricValueFontSize(
          value: value,
          maxWidth: constraints.maxWidth,
        );

        return Text(
          value,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            color: RuniacColors.primaryBlue,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
        );
      },
    );
  }
}

double resolveRunnerMetricValueFontSize({
  required String value,
  required double maxWidth,
}) {
  if (!maxWidth.isFinite || maxWidth <= 0) {
    return _RunnerMetricValueText.minFontSize;
  }

  const minSize = _RunnerMetricValueText.minFontSize;
  const maxSize = _RunnerMetricValueText.maxFontSize;
  final painter = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);

  for (var fontSize = maxSize; fontSize >= minSize; fontSize--) {
    painter.text = TextSpan(
      text: value,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900),
    );
    painter.layout(maxWidth: double.infinity);

    if (painter.width <= maxWidth) {
      return fontSize;
    }
  }

  return minSize;
}

class _RunnerAchievementsSection extends StatelessWidget {
  const _RunnerAchievementsSection({required this.profile});

  final _RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('runner_profile_achievements_section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Achievements',
                style: TextStyle(
                  color: RuniacColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${profile.badges.length} earned',
              style: const TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 18),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDDE3F8)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) =>
                _RunnerAchievementBadge(badge: profile.badges[index]),
          ),
        ),
      ],
    );
  }
}

class _RunnerAchievementBadge extends StatelessWidget {
  const _RunnerAchievementBadge({required this.badge});

  final _RunnerAchievementBadgeSnapshot badge;

  @override
  Widget build(BuildContext context) {
    final badgeColor = badge.highlighted
        ? RuniacColors.accentOrange
        : RuniacColors.primaryBlue;

    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: badge.highlighted
                ? const Color(0xFFFFECE5)
                : RuniacColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: badgeColor.withValues(alpha: 0.28)),
          ),
          child: Icon(badge.icon, color: badgeColor, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          badge.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 13,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardDetailScreen extends StatelessWidget {
  const _LeaderboardDetailScreen({
    required this.onBack,
    required this.onProfileSelected,
  });

  final VoidCallback onBack;
  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    const snapshot = _leaderboardDetailSnapshot;

    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: snapshot.regionName,
              tooltip: 'Back to Leaderboard',
              onBack: onBack,
            ),
            Expanded(
              child: Stack(
                children: [
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 122),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LeaderboardDetailAccentStrip(),
                          const SizedBox(height: 14),
                          _LeaderboardDetailSummary(snapshot: snapshot),
                          const SizedBox(height: 12),
                          _LeaderboardRankListCard(
                            title: snapshot.topRanksTitle,
                            rows: snapshot.topRanks,
                            keyPrefix: 'leaderboard_detail_top_rank_row',
                            onProfileSelected: onProfileSelected,
                          ),
                          const SizedBox(height: 14),
                          _LeaderboardNearbyDivider(
                            title: snapshot.nearbyRanksTitle,
                          ),
                          const SizedBox(height: 10),
                          _LeaderboardRankListCard(
                            rows: snapshot.nearbyRanks,
                            keyPrefix: 'leaderboard_detail_nearby_rank_row',
                            onProfileSelected: onProfileSelected,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 18,
                    child: _CurrentUserFloatingRankBar(
                      summary: snapshot.currentUser,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardDetailAccentStrip extends StatelessWidget {
  const _LeaderboardDetailAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('leaderboard_detail_header_accent_strip'),
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardDetailSummary extends StatelessWidget {
  const _LeaderboardDetailSummary({required this.snapshot});

  final _LeaderboardDetailDisplaySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE3F8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolveLeaderboardPeriodLabelForDisplay(
                    periodLabel: snapshot.periodLabel,
                    fallbackPeriodLabel: snapshot.fallbackPeriodLabel,
                  ),
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  snapshot.divisionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              snapshot.refreshLabel,
              style: const TextStyle(
                color: RuniacColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRankListCard extends StatelessWidget {
  const _LeaderboardRankListCard({
    required this.rows,
    required this.keyPrefix,
    required this.onProfileSelected,
    this.title,
  });

  final String? title;
  final List<_LeaderboardRankRowDisplaySnapshot> rows;
  final String keyPrefix;
  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDDE3F8)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  _LeaderboardRankRow(
                    key: ValueKey('${keyPrefix}_$index'),
                    row: rows[index],
                    onProfileSelected: onProfileSelected,
                  ),
                  if (index != rows.length - 1)
                    const Divider(height: 1, color: Color(0xFFE4E9FA)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRankRow extends StatelessWidget {
  const _LeaderboardRankRow({
    super.key,
    required this.row,
    required this.onProfileSelected,
  });

  final _LeaderboardRankRowDisplaySnapshot row;
  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    final background = row.isCurrentUser
        ? const Color(0xFFFFF1EA)
        : Colors.transparent;

    return Semantics(
      button: true,
      label: 'Open ${row.name} runner profile',
      child: Material(
        color: background,
        child: InkWell(
          onTap: () => onProfileSelected(row.profile),
          child: Container(
            key: row.isCurrentUser
                ? const Key('leaderboard_detail_current_user_row')
                : null,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _RankBadge(row: row),
                const SizedBox(width: 12),
                _InitialBadge(name: row.name, isCurrentUser: row.isCurrentUser),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: row.isCurrentUser
                              ? RuniacColors.primaryBlue
                              : RuniacColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.levelLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  row.xpLabel,
                  style: const TextStyle(
                    color: RuniacColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.row});

  final _LeaderboardRankRowDisplaySnapshot row;

  @override
  Widget build(BuildContext context) {
    final medalTone = row.medalTone;
    if (medalTone != null) {
      final colors = _resolveRegionPreviewMedalColors(medalTone);

      return Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          Icons.emoji_events_outlined,
          color: colors.foreground,
          size: 22,
        ),
      );
    }

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: row.trophy
            ? const Color(0xFFFFF2E9)
            : RuniacColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: row.trophy
          ? const Icon(
              Icons.emoji_events_outlined,
              color: RuniacColors.accentOrange,
              size: 22,
            )
          : Text(
              row.rankLabel,
              style: TextStyle(
                color: row.isCurrentUser
                    ? RuniacColors.accentOrange
                    : RuniacColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class _InitialBadge extends StatelessWidget {
  const _InitialBadge({required this.name, required this.isCurrentUser});

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

class _LeaderboardNearbyDivider extends StatelessWidget {
  const _LeaderboardNearbyDivider({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: RuniacColors.primaryBlue.withValues(alpha: 0.18),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(
            color: RuniacColors.primaryBlue.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

class _CurrentUserFloatingRankBar extends StatelessWidget {
  const _CurrentUserFloatingRankBar({required this.summary});

  final _CurrentUserRankSummaryDisplaySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('leaderboard_current_user_floating_bar'),
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33172033),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: RuniacColors.accentOrange,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                summary.rankLabel,
                style: const TextStyle(
                  color: RuniacColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                summary.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: RuniacColors.white,
                  fontSize: 15,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              summary.xpLabel,
              style: const TextStyle(
                color: RuniacColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTopOverlay extends StatelessWidget {
  const _LeaderboardTopOverlay();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _LeagueSelector()),
        SizedBox(width: 10),
        _InfoBadge(),
      ],
    );
  }
}

class _RegionPreviewSheet extends StatelessWidget {
  const _RegionPreviewSheet({
    required this.height,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
    required this.onViewMoreRanking,
    required this.onShareMyRank,
    required this.onProfileSelected,
  });

  final double height;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final VoidCallback onViewMoreRanking;
  final VoidCallback onShareMyRank;
  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('leaderboard_sheet_surface'),
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFAFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.fromBorderSide(BorderSide(color: Color(0x332F50C7))),
            boxShadow: [
              BoxShadow(
                color: Color(0x30172033),
                blurRadius: 28,
                offset: Offset(0, -12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LeaderboardSheetHandleArea(),
                const _LeaderboardAccentStrip(),
                const SizedBox(height: 10),
                Text(
                  _leaderboardRegionSnapshot.regionName,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _leaderboardDetailSnapshot.refreshLabel,
                  style: const TextStyle(
                    color: RuniacColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _RegionPreviewList(onProfileSelected: onProfileSelected),
                const SizedBox(height: 12),
                _MyRankPreviewCard(onProfileSelected: onProfileSelected),
                const SizedBox(height: 12),
                _RegionPreviewActions(
                  onViewMoreRanking: onViewMoreRanking,
                  onShareMyRank: onShareMyRank,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardAccentStrip extends StatelessWidget {
  const _LeaderboardAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('leaderboard_region_accent_strip'),
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardSheetHandleArea extends StatelessWidget {
  const _LeaderboardSheetHandleArea();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: Key('leaderboard_sheet_handle_area'),
      height: 46,
      child: Center(child: _SheetHandle()),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return const RuniacBottomSheetHandle(
      key: Key('leaderboard_sheet_handle'),
      width: 44,
      height: 5,
      semanticLabel: 'Leaderboard sheet handle',
    );
  }
}

class _RegionPreviewList extends StatelessWidget {
  const _RegionPreviewList({required this.onProfileSelected});

  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RegionPreviewRankCard(
          rows: _leaderboardDetailSnapshot.topRanks.take(3).toList(),
          onProfileSelected: onProfileSelected,
          keyPrefix: 'leaderboard_region_top_rank_row',
          useTopMedals: true,
        ),
      ],
    );
  }
}

class _RegionPreviewRankCard extends StatelessWidget {
  const _RegionPreviewRankCard({
    required this.rows,
    required this.onProfileSelected,
    required this.keyPrefix,
    this.useTopMedals = false,
    this.useDetailRowSizing = false,
  });

  final List<_LeaderboardRankRowDisplaySnapshot> rows;
  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;
  final String keyPrefix;
  final bool useTopMedals;
  final bool useDetailRowSizing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE3F8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              _RegionPreviewRankRow(
                key: ValueKey('${keyPrefix}_$index'),
                row: rows[index],
                medalTone: useTopMedals
                    ? _RegionPreviewMedalTone.values[index]
                    : null,
                onProfileSelected: onProfileSelected,
                useDetailRowSizing: useDetailRowSizing,
              ),
              if (index != rows.length - 1)
                const Divider(height: 1, color: Color(0xFFE4E9FA)),
            ],
          ],
        ),
      ),
    );
  }
}

enum _RegionPreviewMedalTone { gold, silver, bronze }

({Color background, Color foreground}) _resolveRegionPreviewMedalColors(
  _RegionPreviewMedalTone tone,
) {
  return switch (tone) {
    _RegionPreviewMedalTone.gold => (
      background: const Color(0xFFFFF2E2),
      foreground: RuniacColors.accentOrange,
    ),
    _RegionPreviewMedalTone.silver => (
      background: const Color(0xFFEFF3FB),
      foreground: RuniacColors.textSecondary,
    ),
    _RegionPreviewMedalTone.bronze => (
      background: const Color(0xFFFFEBDD),
      foreground: const Color(0xFFB56A36),
    ),
  };
}

class _RegionPreviewRankRow extends StatelessWidget {
  const _RegionPreviewRankRow({
    super.key,
    required this.row,
    required this.onProfileSelected,
    this.medalTone,
    this.useDetailRowSizing = false,
  });

  final _LeaderboardRankRowDisplaySnapshot row;
  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;
  final _RegionPreviewMedalTone? medalTone;
  final bool useDetailRowSizing;

  @override
  Widget build(BuildContext context) {
    final rowMinHeight = useDetailRowSizing ? 64.0 : 56.0;
    final horizontalPadding = useDetailRowSizing ? 12.0 : 10.0;
    final verticalPadding = useDetailRowSizing ? 10.0 : 7.0;
    final rankGap = useDetailRowSizing ? 12.0 : 10.0;
    final nameGap = useDetailRowSizing ? 12.0 : 10.0;
    final xpGap = useDetailRowSizing ? 12.0 : 8.0;
    final badgeSize = useDetailRowSizing ? 42.0 : 38.0;
    final nameFontSize = useDetailRowSizing ? 16.0 : 14.0;
    final levelFontSize = useDetailRowSizing ? 12.0 : 11.0;
    final xpFontSize = useDetailRowSizing ? 16.0 : 14.0;

    return Semantics(
      button: true,
      label: 'Open ${row.name} runner profile',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onProfileSelected(row.profile),
          child: Container(
            key: row.isCurrentUser
                ? const Key('leaderboard_region_current_user_row')
                : null,
            constraints: BoxConstraints(minHeight: rowMinHeight),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Row(
              children: [
                _RegionPreviewRankBadge(
                  row: row,
                  medalTone: medalTone,
                  size: badgeSize,
                  useDetailSizing: useDetailRowSizing,
                ),
                SizedBox(width: rankGap),
                _InitialBadge(name: row.name, isCurrentUser: row.isCurrentUser),
                SizedBox(width: nameGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        row.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: row.isCurrentUser
                              ? RuniacColors.primaryBlue
                              : RuniacColors.textPrimary,
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.levelLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: levelFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: xpGap),
                Text(
                  row.xpLabel,
                  style: TextStyle(
                    color: RuniacColors.primaryBlue,
                    fontSize: xpFontSize,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionPreviewRankBadge extends StatelessWidget {
  const _RegionPreviewRankBadge({
    required this.row,
    required this.size,
    required this.useDetailSizing,
    this.medalTone,
  });

  final _LeaderboardRankRowDisplaySnapshot row;
  final double size;
  final bool useDetailSizing;
  final _RegionPreviewMedalTone? medalTone;

  @override
  Widget build(BuildContext context) {
    final tone = medalTone;
    if (tone != null) {
      final colors = _resolveRegionPreviewMedalColors(tone);

      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          Icons.emoji_events_outlined,
          color: colors.foreground,
          size: useDetailSizing ? 22 : 21,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: row.isCurrentUser
            ? const Color(0xFFFFE2D2)
            : RuniacColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        row.rankLabel,
        style: TextStyle(
          color: row.isCurrentUser
              ? RuniacColors.accentOrange
              : RuniacColors.primaryBlue,
          fontSize: useDetailSizing ? 16 : 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MyRankPreviewCard extends StatelessWidget {
  const _MyRankPreviewCard({required this.onProfileSelected});

  final ValueChanged<_RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    final currentUserRow = _leaderboardDetailSnapshot.nearbyRanks.firstWhere(
      (row) => row.isCurrentUser,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _leaderboardRegionSnapshot.rankPreviewTitle,
          style: const TextStyle(
            color: RuniacColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        _RegionPreviewRankCard(
          rows: [currentUserRow],
          onProfileSelected: onProfileSelected,
          keyPrefix: 'leaderboard_region_my_rank_row',
          useDetailRowSizing: true,
        ),
      ],
    );
  }
}

class _RegionPreviewActions extends StatelessWidget {
  const _RegionPreviewActions({
    required this.onViewMoreRanking,
    required this.onShareMyRank,
  });

  final VoidCallback onViewMoreRanking;
  final VoidCallback onShareMyRank;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _VisualCta(
            key: const Key('leaderboard_view_more_ranking_button'),
            label: _leaderboardRegionSnapshot.primaryActionLabel,
            filled: true,
            onTap: onViewMoreRanking,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _VisualCta(
            key: const Key('leaderboard_share_my_rank_button'),
            label: _leaderboardRegionSnapshot.secondaryActionLabel,
            filled: false,
            onTap: onShareMyRank,
          ),
        ),
      ],
    );
  }
}

class _ShareRankFloatingPanel extends StatelessWidget {
  const _ShareRankFloatingPanel({
    required this.regionName,
    required this.divisionName,
    required this.rankLabel,
  });

  final String regionName;
  final String divisionName;
  final String rankLabel;

  Future<void> _copyRank(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            'I\'m ranked $rankLabel in $regionName\'s $divisionName on Runiac.',
      ),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rank copied to clipboard')));
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share action coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return RuniacShareBottomSheet(
      key: const Key('leaderboard_share_rank_panel'),
      title: 'Share your rank',
      preview: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (MediaQuery.sizeOf(context).width * 0.88)
              .clamp(0.0, constraints.maxWidth)
              .toDouble();

          return SizedBox(
            height: constraints.maxHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _ShareRankCardPreview(
                        regionName: regionName,
                        divisionName: divisionName,
                        rankLabel: rankLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _ShareRankPageIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      shareTargets: [
        RuniacShareTargetButton(
          icon: Icons.camera_alt_outlined,
          iconAsset: _instagramStoriesIconAsset,
          label: 'Instagram',
          onPressed: () => _showComingSoon(context),
        ),
        RuniacShareTargetButton(
          key: const Key('leaderboard_copy_rank_action'),
          icon: Icons.content_paste_outlined,
          label: 'Copy to Clipboard',
          onPressed: () => _copyRank(context),
        ),
        RuniacShareTargetButton(
          icon: Icons.file_download_outlined,
          label: 'Save',
          onPressed: () => _showComingSoon(context),
        ),
        RuniacShareTargetButton(
          icon: Icons.link,
          label: 'Copy Link',
          onPressed: () => _showComingSoon(context),
        ),
        RuniacShareTargetButton(
          icon: Icons.more_horiz,
          label: 'More',
          onPressed: () => _showComingSoon(context),
        ),
      ],
    );
  }
}

class _ShareRankPageIndicator extends StatelessWidget {
  const _ShareRankPageIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: Key('leaderboard_share_rank_page_indicator'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShareRankIndicatorDot(active: true),
        SizedBox(width: 6),
        _ShareRankIndicatorDot(active: false),
        SizedBox(width: 6),
        _ShareRankIndicatorDot(active: false),
      ],
    );
  }
}

class _ShareRankIndicatorDot extends StatelessWidget {
  const _ShareRankIndicatorDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? RuniacColors.primaryBlue
            : RuniacColors.primaryBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(width: active ? 18 : 7, height: 7),
    );
  }
}

class _ShareRankCardPreview extends StatelessWidget {
  const _ShareRankCardPreview({
    required this.regionName,
    required this.divisionName,
    required this.rankLabel,
  });

  final String regionName;
  final String divisionName;
  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1122 / 1402,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;

          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              key: const Key('leaderboard_share_rank_card_preview'),
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _shareRankCardAsset,
                  key: const Key('leaderboard_share_rank_card_background'),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: cardWidth * 0.34,
                  right: cardWidth * 0.29,
                  top: cardHeight * 0.344,
                  height: cardHeight * 0.075,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      regionName,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: RuniacColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: cardWidth * 0.18,
                  right: cardWidth * 0.18,
                  top: cardHeight * 0.435,
                  height: cardHeight * 0.052,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      divisionName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE1E8FF),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: cardWidth * 0.2,
                  right: cardWidth * 0.2,
                  top: cardHeight * 0.535,
                  height: cardHeight * 0.225,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _ShareRankNumber(rankLabel: rankLabel),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShareRankNumber extends StatelessWidget {
  const _ShareRankNumber({required this.rankLabel});

  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    final rankNumber = rankLabel.startsWith('#')
        ? rankLabel.substring(1)
        : rankLabel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Text(
          '#',
          style: TextStyle(
            color: RuniacColors.accentOrange,
            fontSize: 122,
            fontWeight: FontWeight.w900,
            height: 0.94,
            shadows: [
              Shadow(
                color: Color(0xAA000000),
                blurRadius: 16,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        Text(
          rankNumber,
          style: const TextStyle(
            color: RuniacColors.white,
            fontSize: 150,
            fontWeight: FontWeight.w900,
            height: 0.94,
            shadows: [
              Shadow(
                color: Color(0xAA000000),
                blurRadius: 16,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisualCta extends StatelessWidget {
  const _VisualCta({
    super.key,
    required this.label,
    required this.filled,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            height: 36,
            decoration: BoxDecoration(
              color: filled ? RuniacColors.textPrimary : RuniacColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: filled
                    ? RuniacColors.textPrimary
                    : RuniacColors.textSecondary.withValues(alpha: 0.48),
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filled ? RuniacColors.white : RuniacColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeagueSelector extends StatelessWidget {
  const _LeagueSelector();

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
            onTap: () => _showLeaderboardLeaguesDialog(context),
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
                  const _LeagueMedalIcon(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _leaderboardLeagueSnapshot.selectedDivision,
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
                    _leaderboardLeagueSnapshot.selectedLevelRange,
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

void _showLeaderboardLeaguesDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: RuniacColors.textPrimary.withValues(alpha: 0.38),
    builder: (context) => const _LeaderboardLeaguesDialog(),
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
                    Expanded(
                      child: Center(
                        child: Text(
                          _leaderboardPreviewSnapshot.tipsTitle,
                          style: const TextStyle(
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
                _TipsSection(
                  icon: Icons.emoji_events_outlined,
                  title: _leaderboardPreviewSnapshot.leaguesTipTitle,
                  body: _leaderboardPreviewSnapshot.leaguesTipBody,
                ),
                const SizedBox(height: 10),
                _TipsSection(
                  icon: Icons.calendar_month_outlined,
                  title: _leaderboardPreviewSnapshot.cadenceTipTitle,
                  body: _leaderboardPreviewSnapshot.cadenceTipBody,
                ),
                const SizedBox(height: 10),
                _TipsSection(
                  icon: Icons.verified_user_outlined,
                  title: _leaderboardPreviewSnapshot.readinessTipTitle,
                  body: _leaderboardPreviewSnapshot.readinessTipBody,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardLeaguesDialog extends StatelessWidget {
  const _LeaderboardLeaguesDialog();

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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Close leagues',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: RuniacColors.textPrimary,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _leaderboardLeagueSnapshot.dialogTitle,
                          style: const TextStyle(
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
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: RuniacColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDADDE1)),
                  ),
                  child: Column(
                    children: [
                      for (final entry
                          in _leaderboardLeagueSnapshot.entries) ...[
                        _LeagueTaxonomyRow(entry: entry),
                        if (entry != _leaderboardLeagueSnapshot.entries.last)
                          const Divider(height: 1, color: Color(0xFFE7E9EC)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeagueTaxonomyEntry {
  const _LeagueTaxonomyEntry(this.name, this.range);

  final String name;
  final String range;
}

class _LeagueTaxonomyRow extends StatelessWidget {
  const _LeagueTaxonomyRow({required this.entry});

  final _LeagueTaxonomyEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 28,
            height: 32,
            child: CustomPaint(painter: _LeagueMedalPainter()),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${entry.name} (${entry.range})',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
      label: _leaderboardRegionSnapshot.userAreaLabel,
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
            child: Text(
              _leaderboardRegionSnapshot.userAreaLabel,
              style: const TextStyle(
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
