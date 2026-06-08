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
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 2',
      title: 'Easy Distance',
      status: GoalPlanWeekStatus.completed,
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 3',
      title: 'Base Endurance',
      status: GoalPlanWeekStatus.current,
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 4',
      title: '6 km Milestone',
      status: GoalPlanWeekStatus.upcoming,
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 5',
      title: 'Longer Effort',
      status: GoalPlanWeekStatus.upcoming,
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 6',
      title: '8 km Progression',
      status: GoalPlanWeekStatus.upcoming,
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 7',
      title: '10K Preparation',
      status: GoalPlanWeekStatus.upcoming,
    ),
    GoalPlanWeekDisplaySnapshot(
      weekLabel: 'Week 8',
      title: '10K Attempt',
      status: GoalPlanWeekStatus.goalWeek,
    ),
  ],
);

const _sampleDailyPlan = [
  GoalPlanDayDisplaySnapshot(
    weekday: 'Monday',
    workoutType: 'Easy Run',
    distanceOrTime: '3 km',
  ),
  GoalPlanDayDisplaySnapshot(
    weekday: 'Tuesday',
    workoutType: 'Rest',
    distanceOrTime: '0 min',
  ),
  GoalPlanDayDisplaySnapshot(
    weekday: 'Wednesday',
    workoutType: 'Tempo Run',
    distanceOrTime: '25 min',
  ),
  GoalPlanDayDisplaySnapshot(
    weekday: 'Thursday',
    workoutType: 'Rest',
    distanceOrTime: '0 min',
  ),
  GoalPlanDayDisplaySnapshot(
    weekday: 'Friday',
    workoutType: 'Easy Run',
    distanceOrTime: '4 km',
  ),
  GoalPlanDayDisplaySnapshot(
    weekday: 'Saturday',
    workoutType: 'Long Run',
    distanceOrTime: '5 km',
  ),
  GoalPlanDayDisplaySnapshot(
    weekday: 'Sunday',
    workoutType: 'Rest',
    distanceOrTime: '0 min',
  ),
];

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
    this.dailyPlan = _sampleDailyPlan,
  });

  final String weekLabel;
  final String title;
  final GoalPlanWeekStatus status;
  final List<GoalPlanDayDisplaySnapshot> dailyPlan;
}

class GoalPlanDayDisplaySnapshot {
  const GoalPlanDayDisplaySnapshot({
    required this.weekday,
    required this.workoutType,
    required this.distanceOrTime,
  });

  final String weekday;
  final String workoutType;
  final String distanceOrTime;
}

class GoalPlanDetailScreen extends StatefulWidget {
  const GoalPlanDetailScreen({
    required this.onBack,
    this.snapshot = goalPlanDisplaySnapshot,
    super.key,
  });

  final VoidCallback onBack;
  final GoalPlanDisplaySnapshot snapshot;

  @override
  State<GoalPlanDetailScreen> createState() => _GoalPlanDetailScreenState();
}

class _GoalPlanDetailScreenState extends State<GoalPlanDetailScreen> {
  final _expandedWeekIndexes = <int>{};

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
              child: _GoalPlanHeader(
                title: widget.snapshot.title,
                onBack: widget.onBack,
              ),
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
                      const _GoalPlanDetailAccentStrip(),
                      const SizedBox(height: 14),
                      _GoalPlanSummaryCard(widget.snapshot),
                      const SizedBox(height: 12),
                      _GoalPlanTimelineCard(
                        weeks: widget.snapshot.weeks,
                        expandedWeekIndexes: _expandedWeekIndexes,
                        onWeekSelected: (index) {
                          setState(() {
                            if (_expandedWeekIndexes.contains(index)) {
                              _expandedWeekIndexes.remove(index);
                            } else {
                              _expandedWeekIndexes.add(index);
                            }
                          });
                        },
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

class _GoalPlanHeader extends StatelessWidget {
  const _GoalPlanHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Back to Plans',
          icon: const Icon(Icons.arrow_back),
          color: RuniacColors.textPrimary,
          onPressed: onBack,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: _screenTitleStyle),
          ),
        ),
      ],
    );
  }
}

class _GoalPlanDetailAccentStrip extends StatelessWidget {
  const _GoalPlanDetailAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('goal_plan_detail_header_accent_strip'),
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
  const _GoalPlanTimelineCard({
    required this.weeks,
    required this.expandedWeekIndexes,
    required this.onWeekSelected,
  });

  final List<GoalPlanWeekDisplaySnapshot> weeks;
  final Set<int> expandedWeekIndexes;
  final ValueChanged<int> onWeekSelected;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          for (var index = 0; index < weeks.length; index++) ...[
            _GoalPlanTimelineRow(
              display: weeks[index],
              isExpanded: expandedWeekIndexes.contains(index),
              onSelected: () => onWeekSelected(index),
            ),
            if (index < weeks.length - 1)
              const Divider(height: 1, color: RuniacColors.border),
          ],
        ],
      ),
    );
  }
}

class _GoalPlanTimelineRow extends StatelessWidget {
  const _GoalPlanTimelineRow({
    required this.display,
    required this.isExpanded,
    required this.onSelected,
  });

  final GoalPlanWeekDisplaySnapshot display;
  final bool isExpanded;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('goal_plan_detail_week_${display.weekLabel}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('goal_plan_detail_week_toggle_${display.weekLabel}'),
            borderRadius: BorderRadius.circular(8),
            onTap: onSelected,
            child: Container(
              key: display.status == GoalPlanWeekStatus.current
                  ? const ValueKey('goal_plan_detail_current_week_highlight')
                  : null,
              constraints: const BoxConstraints(minHeight: 58),
              decoration: BoxDecoration(
                color: display.status == GoalPlanWeekStatus.current
                    ? const Color(0xFFF7FAFF)
                    : null,
                borderRadius: display.status == GoalPlanWeekStatus.current
                    ? BorderRadius.circular(8)
                    : null,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _TimelineMarker(
                            key: ValueKey(
                              'goal_plan_detail_marker_${display.weekLabel}',
                            ),
                            status: display.status,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 52,
                              child: Text(
                                display.weekLabel,
                                style: _smallBodyStyle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                display.title,
                                style:
                                    display.status == GoalPlanWeekStatus.current
                                    ? _bodyStrongStyle
                                    : _bodyStyle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              key: ValueKey(
                                'goal_plan_detail_chevron_${display.weekLabel}_${isExpanded ? 'expanded' : 'collapsed'}',
                              ),
                              color: RuniacColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isExpanded)
          _WeeklyDailyPlanRows(
            weekLabel: display.weekLabel,
            dailyPlan: display.dailyPlan,
          ),
      ],
    );
  }
}

class _WeeklyDailyPlanRows extends StatelessWidget {
  const _WeeklyDailyPlanRows({
    required this.weekLabel,
    required this.dailyPlan,
  });

  final String weekLabel;
  final List<GoalPlanDayDisplaySnapshot> dailyPlan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('goal_plan_detail_daily_plan_$weekLabel'),
      padding: const EdgeInsets.fromLTRB(40, 0, 0, 12),
      child: Column(
        children: [
          for (final day in dailyPlan)
            Padding(
              key: ValueKey('goal_plan_detail_day_${weekLabel}_${day.weekday}'),
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 82,
                    child: Text(day.weekday, style: _smallBodyStyle),
                  ),
                  Expanded(child: Text(day.workoutType, style: _bodyStyle)),
                  const SizedBox(width: 8),
                  Text(day.distanceOrTime, style: _smallBodyStyle),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({super.key, required this.status});

  final GoalPlanWeekStatus status;

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

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: _markerChild(status),
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
    GoalPlanWeekStatus.current => const Icon(
      Icons.directions_run,
      size: 16,
      color: RuniacColors.white,
    ),
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

final _softIconDecoration = BoxDecoration(
  color: const Color(0xFFF7FAFF),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: RuniacColors.border),
);
