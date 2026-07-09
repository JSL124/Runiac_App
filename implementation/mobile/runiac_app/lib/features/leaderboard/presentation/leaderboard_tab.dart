import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';

import 'data/leaderboard_demo_snapshots.dart';
import 'models/leaderboard_display_models.dart';
import 'widgets/leaderboard_detail_screen.dart';
import 'widgets/leaderboard_dialogs.dart';
import 'widgets/leaderboard_map_background.dart';
import 'widgets/leaderboard_region_preview_sheet.dart';
import 'widgets/leaderboard_top_overlay.dart';
import 'widgets/runner_achievement_profile_screen.dart';
import 'widgets/share_rank_floating_panel.dart';

export 'widgets/runner_achievement_profile_screen.dart'
    show resolveRunnerMetricValueFontSize;

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
  LeaderboardDetailDisplaySnapshot _selectedRegion =
      defaultLeaderboardRegionRankingSnapshot;
  RunnerAchievementProfileSnapshot? _selectedProfile;

  void _openDetail() {
    setState(() {
      _showingDetail = true;
    });
  }

  void _selectRegion(String regionId) {
    setState(() {
      _selectedRegion = leaderboardRegionRankingSnapshotById(regionId);
      _sheetProgress = 1;
    });
  }

  void _closeDetail() {
    setState(() {
      _showingDetail = false;
      _selectedProfile = null;
    });
  }

  void _openRunnerProfile(RunnerAchievementProfileSnapshot profile) {
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
        final currentUserRow = _selectedRegion.nearbyRanks.firstWhere(
          (row) => row.isCurrentUser,
        );

        return ShareRankFloatingPanel(
          regionName: _selectedRegion.regionName,
          divisionName: _selectedRegion.divisionLabel,
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
      return RunnerAchievementProfileScreen(
        profile: selectedProfile,
        onBack: _closeRunnerProfile,
      );
    }

    if (_showingDetail) {
      return LeaderboardDetailScreen(
        snapshot: _selectedRegion,
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
            child: LeaderboardMapBackground(
              regions: leaderboardMapRegionDemoSnapshots,
              selectedRegionId: _selectedRegion.regionId,
              onRegionSelected: _selectRegion,
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 14),
              child: LeaderboardTopOverlay(
                onShowLeagues: () => showLeaderboardLeaguesDialog(context),
                onShowTips: () => showLeaderboardTipsDialog(context),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: -hiddenSheetHeight,
            child: LeaderboardRegionPreviewSheet(
              height: _expandedSheetHeight,
              snapshot: _selectedRegion,
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
