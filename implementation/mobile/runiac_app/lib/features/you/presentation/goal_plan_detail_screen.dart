import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';

enum GoalPlanWeekStatus { completed, current, upcoming, goalWeek }

const goalPlanDisplaySnapshot = GoalPlanDisplaySnapshot(
  title: '10K Goal Plan',
  planName: '10K Preparation',
  weekSummary: 'Week 3 of 8',
  progressValue: 0.43,
  progressPercentLabel: '43%',
  progressLabel: '43% completed',
  currentPhaseLabel: 'Current Phase',
  currentPhase: 'Base Endurance',
  weeks: [
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 1',
      title: 'Build Routine',
      status: GoalPlanWeekStatus.completed,
      statusLabel: 'Completed',
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 2',
      title: 'Easy Distance',
      status: GoalPlanWeekStatus.completed,
      statusLabel: 'Completed',
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 3',
      title: 'Base Endurance',
      status: GoalPlanWeekStatus.current,
      statusLabel: 'Current',
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 4',
      title: '6 km Milestone',
      status: GoalPlanWeekStatus.upcoming,
      statusLabel: 'Upcoming',
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 5',
      title: 'Longer Effort',
      status: GoalPlanWeekStatus.upcoming,
      statusLabel: 'Upcoming',
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 6',
      title: '8 km Progression',
      status: GoalPlanWeekStatus.upcoming,
      statusLabel: 'Upcoming',
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 7',
      title: '10K Preparation',
      status: GoalPlanWeekStatus.upcoming,
      statusLabel: 'Upcoming',
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 8',
      title: '10K Attempt',
      status: GoalPlanWeekStatus.goalWeek,
      statusLabel: 'Goal Week',
    ),
  ],
);

class GoalPlanDisplaySnapshot {
  const GoalPlanDisplaySnapshot({
    required this.title,
    required this.planName,
    required this.weekSummary,
    required this.progressValue,
    required this.progressPercentLabel,
    required this.progressLabel,
    required this.currentPhaseLabel,
    required this.currentPhase,
    required this.weeks,
  });

  final String title;
  final String planName;
  final String weekSummary;
  final double progressValue;
  final String progressPercentLabel;
  final String progressLabel;
  final String currentPhaseLabel;
  final String currentPhase;
  final List<GoalPlanWeekDisplaySnapshot> weeks;
}

class GoalPlanWeekDisplaySnapshot {
  const GoalPlanWeekDisplaySnapshot({
    required this.weekLabel,
    required this.title,
    required this.status,
    required this.statusLabel,
  });

  final String weekLabel;
  final String title;
  final GoalPlanWeekStatus status;
  final String statusLabel;
}

class GoalPlanDetailScreen extends StatelessWidget {
  const GoalPlanDetailScreen({
    required this.onBack,
    this.snapshot = goalPlanDisplaySnapshot,
    super.key,
  });

  final VoidCallback onBack;
  final GoalPlanDisplaySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            _GoalPlanHeader(title: snapshot.title, onBack: onBack),
            const SizedBox(height: 16),
            _GoalPlanSummaryCard(snapshot),
            const SizedBox(height: 12),
            _GoalPlanTimelineCard(snapshot.weeks),
          ],
        ),
      ),
    );
  }
}

class _GoalPlanHeader extends StatelessWidget {
  const _GoalPlanHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Back to Plans',
              icon: const Icon(
                Icons.chevron_left,
                color: RuniacColors.textPrimary,
                size: 32,
              ),
              onPressed: onBack,
            ),
          ),
          Text(title, textAlign: TextAlign.center, style: _screenTitleStyle),
        ],
      ),
    );
  }
}

class _GoalPlanSummaryCard extends StatelessWidget {
  const _GoalPlanSummaryCard(this.snapshot);

  final GoalPlanDisplaySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RuniacColors.border),
                ),
                child: const Icon(
                  Icons.directions_run,
                  color: RuniacColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.planName, style: _cardTitleStyle),
                    const SizedBox(height: 3),
                    Text(snapshot.weekSummary, style: _bodyStyle),
                    const SizedBox(height: 8),
                    _GoalPlanProgress(snapshot),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: RuniacColors.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: _softIconDecoration,
                child: const Icon(
                  Icons.stacked_bar_chart,
                  color: RuniacColors.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.currentPhaseLabel, style: _smallBodyStyle),
                    const SizedBox(height: 2),
                    Text(snapshot.currentPhase, style: _bodyStrongStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalPlanProgress extends StatelessWidget {
  const _GoalPlanProgress(this.snapshot);

  final GoalPlanDisplaySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              child: LinearProgressIndicator(
                value: snapshot.progressValue,
                minHeight: 12,
                backgroundColor: const Color(0xFFE8EEF8),
                valueColor: const AlwaysStoppedAnimation(
                  RuniacColors.accentOrange,
                ),
              ),
            ),
            Text(snapshot.progressPercentLabel, style: _progressInsideStyle),
          ],
        ),
        const SizedBox(height: 6),
        Text(snapshot.progressLabel, style: _smallBodyStyle),
      ],
    );
  }
}

class _GoalPlanTimelineCard extends StatelessWidget {
  const _GoalPlanTimelineCard(this.weeks);

  final List<GoalPlanWeekDisplaySnapshot> weeks;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          for (var index = 0; index < weeks.length; index++)
            _GoalPlanTimelineRow(
              display: weeks[index],
              isLast: index == weeks.length - 1,
            ),
        ],
      ),
    );
  }
}

class _GoalPlanTimelineRow extends StatelessWidget {
  const _GoalPlanTimelineRow({required this.display, required this.isLast});

  final GoalPlanWeekDisplaySnapshot display;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: display.status == GoalPlanWeekStatus.current
            ? const Color(0xFFF7FAFF)
            : null,
        borderRadius: display.status == GoalPlanWeekStatus.current
            ? BorderRadius.circular(8)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: _TimelineMarker(status: display.status, isLast: isLast),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(display.weekLabel, style: _smallBodyStyle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      display.title,
                      style: display.status == GoalPlanWeekStatus.current
                          ? _bodyStrongStyle
                          : _bodyStyle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(display.statusLabel, style: _smallBodyStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({required this.status, required this.isLast});

  final GoalPlanWeekStatus status;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final markerColor = switch (status) {
      GoalPlanWeekStatus.completed => RuniacColors.primaryBlue,
      GoalPlanWeekStatus.current => RuniacColors.accentOrange,
      GoalPlanWeekStatus.upcoming => RuniacColors.white,
      GoalPlanWeekStatus.goalWeek => RuniacColors.white,
    };
    final borderColor =
        status == GoalPlanWeekStatus.upcoming ||
            status == GoalPlanWeekStatus.goalWeek
        ? RuniacColors.primaryBlue
        : markerColor;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: _markerChild(status),
        ),
        if (!isLast)
          Container(width: 1, height: 20, color: RuniacColors.border),
      ],
    );
  }
}

Widget _markerChild(GoalPlanWeekStatus status) {
  return switch (status) {
    GoalPlanWeekStatus.completed => const Icon(
      Icons.check,
      size: 16,
      color: RuniacColors.white,
    ),
    GoalPlanWeekStatus.current => const Text('3', style: _markerTextStyle),
    GoalPlanWeekStatus.upcoming => const SizedBox.shrink(),
    GoalPlanWeekStatus.goalWeek => const Icon(
      Icons.flag,
      size: 15,
      color: RuniacColors.primaryBlue,
    ),
  };
}

const _screenTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 24,
  fontWeight: FontWeight.w800,
);

const _cardTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w800,
);

const _bodyStrongStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
  fontWeight: FontWeight.w800,
);

const _bodyStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
  fontWeight: FontWeight.w600,
);

const _smallBodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 11,
  fontWeight: FontWeight.w700,
);

const _progressInsideStyle = TextStyle(
  color: RuniacColors.white,
  fontSize: 10,
  fontWeight: FontWeight.w800,
);

const _markerTextStyle = TextStyle(
  color: RuniacColors.white,
  fontSize: 12,
  fontWeight: FontWeight.w800,
);

final _softIconDecoration = BoxDecoration(
  color: const Color(0xFFF7FAFF),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: RuniacColors.border),
);
