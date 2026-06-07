import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';

const _leaderboardPreviewSnapshot = _LeaderboardPreviewSnapshot(
  weeklyLabel: 'Weekly XP',
  monthlyLabel: 'Monthly XP',
  tipsTitle: 'Tips',
  leaguesTipTitle: 'Leagues',
  cadenceTipTitle: 'Weekly vs Monthly',
  readinessTipTitle: 'Ranking readiness',
  leaguesTipBody:
      'Leagues group runners by broad progress bands so the board feels fair and beginner-friendly.',
  cadenceTipBody:
      'Weekly and monthly views will help compare progress once leaderboard data is ready.',
  readinessTipBody: 'Real rankings will be prepared safely by Runiac later.',
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
  cadenceDivisionLabel: 'Weekly XP · Rising Runner Division',
  previewTitle: 'Region Preview',
  previewStatus: 'Ranking preview pending',
  pendingRowLabel: 'Pending',
  rankPreviewTitle: 'My Rank Preview',
  rankPreviewBody: 'Your position will appear after leaderboard data is ready.',
  primaryActionLabel: 'View More Ranking',
  secondaryActionLabel: 'Share My Rank',
  userAreaLabel: 'Your ranked area',
);

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  static const double _expandedSheetHeight = 396;
  static const double _collapsedSheetHeight = 28;

  double _sheetProgress = 1;

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
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPreviewSnapshot {
  const _LeaderboardPreviewSnapshot({
    required this.weeklyLabel,
    required this.monthlyLabel,
    required this.tipsTitle,
    required this.leaguesTipTitle,
    required this.cadenceTipTitle,
    required this.readinessTipTitle,
    required this.leaguesTipBody,
    required this.cadenceTipBody,
    required this.readinessTipBody,
  });

  final String weeklyLabel;
  final String monthlyLabel;
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
    required this.cadenceDivisionLabel,
    required this.previewTitle,
    required this.previewStatus,
    required this.pendingRowLabel,
    required this.rankPreviewTitle,
    required this.rankPreviewBody,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.userAreaLabel,
  });

  final String regionName;
  final String cadenceDivisionLabel;
  final String previewTitle;
  final String previewStatus;
  final String pendingRowLabel;
  final String rankPreviewTitle;
  final String rankPreviewBody;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final String userAreaLabel;
}

class _LeaderboardTopOverlay extends StatelessWidget {
  const _LeaderboardTopOverlay();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _XpSegmentedControl(),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _LeagueSelector()),
            SizedBox(width: 10),
            _InfoBadge(),
          ],
        ),
      ],
    );
  }
}

class _XpSegmentedControl extends StatelessWidget {
  const _XpSegmentedControl();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xEFFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x662F50C7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A172033),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2F5FD7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _leaderboardPreviewSnapshot.weeklyLabel,
                style: const TextStyle(
                  color: RuniacColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _leaderboardPreviewSnapshot.monthlyLabel,
                style: const TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionPreviewSheet extends StatelessWidget {
  const _RegionPreviewSheet({
    required this.height,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final double height;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _SheetHandle()),
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
                  _leaderboardRegionSnapshot.cadenceDivisionLabel,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const _RegionPreviewList(),
                const SizedBox(height: 12),
                const _MyRankPreviewCard(),
                const SizedBox(height: 12),
                const _RegionPreviewActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('leaderboard_sheet_handle'),
      label: 'Leaderboard sheet handle',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RuniacColors.textSecondary.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const SizedBox(width: 34, height: 4),
      ),
    );
  }
}

class _RegionPreviewList extends StatelessWidget {
  const _RegionPreviewList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _leaderboardRegionSnapshot.previewTitle,
          style: const TextStyle(
            color: RuniacColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _leaderboardRegionSnapshot.previewStatus,
          style: const TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        const _PreviewListShell(),
      ],
    );
  }
}

class _PreviewListShell extends StatelessWidget {
  const _PreviewListShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: RuniacColors.textSecondary.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        children: const [
          _PreviewShellRow(widthFactor: 0.82),
          Divider(height: 12, color: Color(0xFFE4E7EB)),
          _PreviewShellRow(widthFactor: 0.68),
          Divider(height: 12, color: Color(0xFFE4E7EB)),
          _PreviewShellRow(widthFactor: 0.74),
        ],
      ),
    );
  }
}

class _PreviewShellRow extends StatelessWidget {
  const _PreviewShellRow({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: RuniacColors.textSecondary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            Icons.person_outline,
            color: RuniacColors.textSecondary.withValues(alpha: 0.44),
            size: 15,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: widthFactor,
                alignment: Alignment.centerLeft,
                child: const _PreviewBar(height: 9),
              ),
              const SizedBox(height: 5),
              const FractionallySizedBox(
                widthFactor: 0.42,
                alignment: Alignment.centerLeft,
                child: _PreviewBar(height: 7),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _leaderboardRegionSnapshot.pendingRowLabel,
          style: TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(height: height),
    );
  }
}

class _MyRankPreviewCard extends StatelessWidget {
  const _MyRankPreviewCard();

  @override
  Widget build(BuildContext context) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: RuniacColors.textSecondary.withValues(alpha: 0.38),
            ),
          ),
          child: Row(
            children: [
              const _RankPreviewIcon(),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  _leaderboardRegionSnapshot.rankPreviewBody,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankPreviewIcon extends StatelessWidget {
  const _RankPreviewIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Icon(
        Icons.emoji_events_outlined,
        color: RuniacColors.accentOrange,
        size: 18,
      ),
    );
  }
}

class _RegionPreviewActions extends StatelessWidget {
  const _RegionPreviewActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _VisualCta(
            label: _leaderboardRegionSnapshot.primaryActionLabel,
            filled: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _VisualCta(
            label: _leaderboardRegionSnapshot.secondaryActionLabel,
            filled: false,
          ),
        ),
      ],
    );
  }
}

class _VisualCta extends StatelessWidget {
  const _VisualCta({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? RuniacColors.textPrimary : RuniacColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: filled
              ? RuniacColors.textPrimary
              : RuniacColors.textSecondary.withValues(alpha: 0.48),
        ),
      ),
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
