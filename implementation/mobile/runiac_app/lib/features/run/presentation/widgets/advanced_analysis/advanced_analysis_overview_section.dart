import 'package:flutter/material.dart';
import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';

import 'advanced_analysis_score_ring.dart';
import 'advanced_analysis_shared_widgets.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisOverviewSection extends StatelessWidget {
  const AdvancedAnalysisOverviewSection({super.key, this.analysis});

  final AdvancedAnalysisPerformanceOverview? analysis;

  @override
  Widget build(BuildContext context) {
    final performance = analysis;
    final score = performance?.score.value ?? 0;
    final title = _scoreTitle(score, performance?.scoreMode);
    final detail = _scoreDetail(performance);
    final badges =
        performance?.badges ?? const <AdvancedAnalysisAchievementBadge>[];

    return AdvancedAnalysisSection(
      title: 'Performance Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AdvancedAnalysisScoreRing(
                value: score,
                size: 112,
                stroke: 9,
                color: advancedAnalysisBlue,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: advancedAnalysisInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: advancedAnalysisBlue75,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 16),
            _AdvancedAnalysisBadgeList(
              badges: badges,
              iconForBadge: _badgeIcon,
            ),
          ],
        ],
      ),
    );
  }

  String _scoreTitle(int score, AdvancedAnalysisScoreSourceMode? scoreMode) {
    if (score <= 0 || scoreMode == null) {
      return 'Analysis pending';
    }
    return switch (scoreMode) {
      AdvancedAnalysisScoreSourceMode.mobileOnly => 'Phone-tracked effort',
      AdvancedAnalysisScoreSourceMode.wearableBacked =>
        'Wearable-backed effort',
      AdvancedAnalysisScoreSourceMode.mixedSource => 'Mixed-source effort',
      AdvancedAnalysisScoreSourceMode.demoOnly => 'Demo run effort',
    };
  }

  String _scoreDetail(AdvancedAnalysisPerformanceOverview? performance) {
    final score = performance?.score.value;
    if (score == null) {
      return 'Complete a run with enough distance and duration to unlock a data-backed score.';
    }
    return '${performance!.scoreConfidenceLabel} score from available run metrics. Missing wearable-only data is not filled in.';
  }

  IconData _badgeIcon(AdvancedAnalysisBadgeKind kind) {
    return switch (kind) {
      AdvancedAnalysisBadgeKind.stablePace ||
      AdvancedAnalysisBadgeKind.goodConsistency ||
      AdvancedAnalysisBadgeKind.evenSplit ||
      AdvancedAnalysisBadgeKind.negativeSplit ||
      AdvancedAnalysisBadgeKind.strongFinish => Icons.speed_rounded,
      AdvancedAnalysisBadgeKind.controlledHeartRate ||
      AdvancedAnalysisBadgeKind.easyEffort ||
      AdvancedAnalysisBadgeKind.recoveryRun => Icons.favorite_border_rounded,
      AdvancedAnalysisBadgeKind.consistentCadence ||
      AdvancedAnalysisBadgeKind.smoothRhythm => Icons.directions_run_rounded,
      AdvancedAnalysisBadgeKind.hillSteady => Icons.terrain_rounded,
      AdvancedAnalysisBadgeKind.goodEndurance => Icons.emoji_events_outlined,
      AdvancedAnalysisBadgeKind.firstStep => Icons.flag_outlined,
    };
  }
}

class _AdvancedAnalysisBadgeList extends StatefulWidget {
  const _AdvancedAnalysisBadgeList({
    required this.badges,
    required this.iconForBadge,
  });

  static const collapsedBadgeCount = 4;

  final List<AdvancedAnalysisAchievementBadge> badges;
  final IconData Function(AdvancedAnalysisBadgeKind kind) iconForBadge;

  @override
  State<_AdvancedAnalysisBadgeList> createState() =>
      _AdvancedAnalysisBadgeListState();
}

class _AdvancedAnalysisBadgeListState
    extends State<_AdvancedAnalysisBadgeList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasOverflow =
        widget.badges.length > _AdvancedAnalysisBadgeList.collapsedBadgeCount;
    final visibleBadges = _expanded || !hasOverflow
        ? widget.badges
        : widget.badges.take(_AdvancedAnalysisBadgeList.collapsedBadgeCount);

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: Wrap(
        key: ValueKey(
          _expanded
              ? 'advanced_analysis_badges_expanded'
              : 'advanced_analysis_badges_collapsed',
        ),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final badge in visibleBadges)
            AdvancedAnalysisInsightBadge(
              icon: widget.iconForBadge(badge.kind),
              label: badge.kind.label,
              highlighted: badge.highlighted,
            ),
          if (hasOverflow)
            _AdvancedAnalysisBadgeToggle(
              expanded: _expanded,
              hiddenCount:
                  widget.badges.length -
                  _AdvancedAnalysisBadgeList.collapsedBadgeCount,
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
        ],
      ),
    );
  }
}

class _AdvancedAnalysisBadgeToggle extends StatelessWidget {
  const _AdvancedAnalysisBadgeToggle({
    required this.expanded,
    required this.hiddenCount,
    required this.onPressed,
  });

  final bool expanded;
  final int hiddenCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = expanded ? 'Show less' : 'More +$hiddenCount';

    return TextButton.icon(
      key: const ValueKey('advanced_analysis_badge_toggle'),
      onPressed: onPressed,
      icon: Icon(
        expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
        size: 17,
      ),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: advancedAnalysisBlue,
        backgroundColor: advancedAnalysisCard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: const BorderSide(color: advancedAnalysisBlue12),
        ),
      ),
    );
  }
}
