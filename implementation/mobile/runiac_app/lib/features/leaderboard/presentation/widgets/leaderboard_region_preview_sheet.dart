import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_bottom_sheet_handle.dart';
import '../data/leaderboard_demo_snapshots.dart';
import '../models/leaderboard_display_models.dart';
import 'leaderboard_rank_row_helpers.dart';
import 'leaderboard_visual_cta.dart';

class LeaderboardRegionPreviewSheet extends StatelessWidget {
  const LeaderboardRegionPreviewSheet({
    super.key,
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
  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;

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
                  leaderboardRegionDemoSnapshot.regionName,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leaderboardDetailDemoSnapshot.refreshLabel,
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

  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RegionPreviewRankCard(
          rows: leaderboardDetailDemoSnapshot.topRanks.take(3).toList(),
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

  final List<LeaderboardRankRowDisplaySnapshot> rows;
  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;
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
                    ? RegionPreviewMedalTone.values[index]
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

class _RegionPreviewRankRow extends StatelessWidget {
  const _RegionPreviewRankRow({
    super.key,
    required this.row,
    required this.onProfileSelected,
    this.medalTone,
    this.useDetailRowSizing = false,
  });

  final LeaderboardRankRowDisplaySnapshot row;
  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;
  final RegionPreviewMedalTone? medalTone;
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
                LeaderboardInitialBadge(
                  name: row.name,
                  isCurrentUser: row.isCurrentUser,
                ),
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

  final LeaderboardRankRowDisplaySnapshot row;
  final double size;
  final bool useDetailSizing;
  final RegionPreviewMedalTone? medalTone;

  @override
  Widget build(BuildContext context) {
    final tone = medalTone;
    if (tone != null) {
      final colors = resolveRegionPreviewMedalColors(tone);

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

  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    final currentUserRow = leaderboardDetailDemoSnapshot.nearbyRanks.firstWhere(
      (row) => row.isCurrentUser,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          leaderboardRegionDemoSnapshot.rankPreviewTitle,
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
          child: LeaderboardVisualCta(
            key: const Key('leaderboard_view_more_ranking_button'),
            label: leaderboardRegionDemoSnapshot.primaryActionLabel,
            filled: true,
            onTap: onViewMoreRanking,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LeaderboardVisualCta(
            key: const Key('leaderboard_share_my_rank_button'),
            label: leaderboardRegionDemoSnapshot.secondaryActionLabel,
            filled: false,
            onTap: onShareMyRank,
          ),
        ),
      ],
    );
  }
}
