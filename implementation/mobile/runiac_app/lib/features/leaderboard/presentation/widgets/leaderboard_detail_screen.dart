import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_back_header.dart';
import '../data/leaderboard_demo_snapshots.dart';
import '../models/leaderboard_display_models.dart';
import 'leaderboard_rank_row_helpers.dart';

class LeaderboardDetailScreen extends StatelessWidget {
  const LeaderboardDetailScreen({
    super.key,
    required this.onBack,
    required this.onProfileSelected,
  });

  final VoidCallback onBack;
  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    const snapshot = leaderboardDetailDemoSnapshot;

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

  final LeaderboardDetailDisplaySnapshot snapshot;

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
  final List<LeaderboardRankRowDisplaySnapshot> rows;
  final String keyPrefix;
  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;

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

  final LeaderboardRankRowDisplaySnapshot row;
  final ValueChanged<RunnerAchievementProfileSnapshot> onProfileSelected;

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
                LeaderboardInitialBadge(
                  name: row.name,
                  isCurrentUser: row.isCurrentUser,
                ),
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

  final LeaderboardRankRowDisplaySnapshot row;

  @override
  Widget build(BuildContext context) {
    final medalTone = row.medalTone;
    if (medalTone != null) {
      final colors = resolveRegionPreviewMedalColors(medalTone);

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

  final CurrentUserRankSummaryDisplaySnapshot summary;

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
