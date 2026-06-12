import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../../../core/widgets/runiac_section_header.dart';
import '../../run/domain/models/run_activity_display_model.dart';
import '../../run/presentation/view_summary_screen.dart';
import 'activity_history_screen.dart';
import 'data/weekly_workout_demo_snapshots.dart';
import 'data/you_overview_demo_snapshots.dart';
import 'expert_plan_detail_screen.dart';
import 'expert_plan_list_screen.dart';
import 'goal_plan_detail_screen.dart';
import 'weekly_workout_detail_screen.dart';
import 'widgets/compact_run_activity_card.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class YouTab extends StatefulWidget {
  const YouTab({super.key});

  @override
  State<YouTab> createState() => _YouTabState();
}

class _YouTabState extends State<YouTab> {
  var _plans = false;
  var _expertPlanListVisible = false;
  var _expertPlanDetailVisible = false;
  var _goalPlanDetailVisible = false;
  var _workoutDetailVisible = false;
  var _activityHistoryVisible = false;
  var _workoutDetailSnapshot = weeklyWorkoutDetailSnapshot;
  var _visibleCalendarMonth = DateTime(2026, 5);

  @override
  Widget build(BuildContext context) {
    if (_activityHistoryVisible) {
      return ActivityHistoryScreen(
        onBack: () {
          setState(() => _activityHistoryVisible = false);
        },
        onActivitySelected: _showRunSummary,
      );
    }

    if (_workoutDetailVisible) {
      return WeeklyWorkoutDetailScreen(
        snapshot: _workoutDetailSnapshot,
        onBack: () {
          setState(() => _workoutDetailVisible = false);
        },
      );
    }

    if (_goalPlanDetailVisible) {
      return GoalPlanDetailScreen(
        onBack: () {
          setState(() => _goalPlanDetailVisible = false);
        },
      );
    }

    if (_expertPlanDetailVisible) {
      return ExpertPlanDetailScreen(
        onBack: () {
          setState(() => _expertPlanDetailVisible = false);
        },
      );
    }

    if (_expertPlanListVisible) {
      return ExpertPlanListScreen(
        onBack: () {
          setState(() => _expertPlanListVisible = false);
        },
        onFirstPlanSelected: _showExpertPlanDetail,
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top;
    final headerHeight = topPadding + kToolbarHeight;

    return ColoredBox(
      color: RuniacColors.background,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(overscroll: false),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, headerHeight + 8, 16, 28),
              children: [
                _segments(['Progress', 'Plans'], _plans ? 1 : 0, (index) {
                  setState(() => _plans = index == 1);
                }),
                const SizedBox(height: 12),
                if (_plans)
                  _plansEmpty(
                    _showGoalPlanDetail,
                    _showWorkoutDetail,
                    _showExpertPlanList,
                  )
                else
                  _progress(
                    _visibleCalendarMonth,
                    _showPreviousCalendarMonth,
                    _showNextCalendarMonth,
                    _showRunSummary,
                    _showActivityHistory,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: const _YouHeaderOverlay(),
          ),
        ],
      ),
    );
  }

  void _showPreviousCalendarMonth() {
    setState(() {
      _visibleCalendarMonth = DateTime(
        _visibleCalendarMonth.year,
        _visibleCalendarMonth.month - 1,
      );
    });
  }

  void _showNextCalendarMonth() {
    setState(() {
      _visibleCalendarMonth = DateTime(
        _visibleCalendarMonth.year,
        _visibleCalendarMonth.month + 1,
      );
    });
  }

  void _showGoalPlanDetail() {
    setState(() => _goalPlanDetailVisible = true);
  }

  void _showWorkoutDetail(WeeklyWorkoutDetailSnapshot snapshot) {
    setState(() {
      _workoutDetailSnapshot = snapshot;
      _workoutDetailVisible = true;
    });
  }

  void _showExpertPlanList() {
    setState(() => _expertPlanListVisible = true);
  }

  void _showExpertPlanDetail() {
    setState(() => _expertPlanDetailVisible = true);
  }

  void _showActivityHistory() {
    setState(() => _activityHistoryVisible = true);
  }

  void _showRunSummary(RunActivityDisplayModel run) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            ViewSummaryScreen(summary: run.summary, showXpUpdateAction: false),
      ),
    );
  }
}

class _YouHeaderOverlay extends StatelessWidget {
  const _YouHeaderOverlay();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('You', style: _headerTitleStyle),
              SizedBox(height: 8),
              _HomeStyleAccentStrip(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _progress(
  DateTime visibleCalendarMonth,
  VoidCallback onPreviousMonth,
  VoidCallback onNextMonth,
  ValueChanged<RunActivityDisplayModel> onRunSelected,
  VoidCallback onMoreActivities,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _RuniacAccentStrip(),
      const SizedBox(height: 12),
      _segments(['Week', 'Month', 'Year', 'All'], 0, null, compact: true),
      const SizedBox(height: 12),
      _thisWeek(),
      const SizedBox(height: 10),
      _streak(),
      const SizedBox(height: 10),
      _calendarCard(visibleCalendarMonth, onPreviousMonth, onNextMonth),
      const SizedBox(height: 18),
      _recentRunningHeader(onMoreActivities),
      const SizedBox(height: 12),
      for (final run in youProgressSnapshot.runs) ...[
        CompactRunActivityCard(
          key: ValueKey('recent_running_card_${run.title}'),
          activity: run,
          onTap: () => onRunSelected(run),
        ),
        const SizedBox(height: 10),
      ],
      _moreActivities(onMoreActivities),
      const SizedBox(height: 14),
      _runLevel(),
    ],
  );
}

Widget _recentRunningHeader(VoidCallback onSeeAll) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Expanded(child: Text('Recent Running', style: _sectionStyle)),
      RuniacTappableSurface(
        key: const ValueKey('recent_running_see_all'),
        onTap: onSeeAll,
        borderRadius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: const Text('See all', style: _seeAllTextStyle),
      ),
    ],
  );
}

class _RuniacAccentStrip extends StatelessWidget {
  const _RuniacAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
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

class _HomeStyleAccentStrip extends StatelessWidget {
  const _HomeStyleAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.primaryBlue,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

Widget _segments(
  List<String> labels,
  int selected,
  ValueChanged<int>? onTap, {
  bool compact = false,
}) {
  return Container(
    height: compact ? 34 : 38,
    decoration: _pillDecoration(RuniacColors.white),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: onTap == null ? null : () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected ? RuniacColors.primaryBlue : null,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: i == selected
                        ? RuniacColors.white
                        : RuniacColors.textPrimary,
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _plansEmpty(
  VoidCallback onViewGoalPlan,
  ValueChanged<WeeklyWorkoutDetailSnapshot> onViewWorkout,
  VoidCallback onViewExpertPlans,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _RuniacAccentStrip(),
      const SizedBox(height: 12),
      _CurrentGoalPlanCard(onViewGoalPlan),
      const SizedBox(height: 12),
      _WeeklyPlanCard(onViewWorkout),
      const SizedBox(height: 12),
      _ExpertPlansCard(onViewExpertPlans),
    ],
  );
}

class _CurrentGoalPlanCard extends StatelessWidget {
  const _CurrentGoalPlanCard(this.onViewGoalPlan);

  final VoidCallback onViewGoalPlan;

  @override
  Widget build(BuildContext context) {
    return _YouDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      youPlansSnapshot.goalLabel,
                      style: _planAccentLabelStyle,
                    ),
                    SizedBox(height: 6),
                    Text(youPlansSnapshot.goalTitle, style: _largeValueStyle),
                  ],
                ),
              ),
              _planBadge(youPlansSnapshot.goalBadge),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                youPlansSnapshot.completionLabel,
                style: _planAccentLabelStyle,
              ),
              const Spacer(),
              Text(
                youPlansSnapshot.completionPercentLabel,
                style: _planPercentStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              value: youPlansSnapshot.completionProgress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE8EEF8),
              valueColor: const AlwaysStoppedAnimation(
                RuniacColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _PlanMilestoneRow(),
          const SizedBox(height: 14),
          _StaticPlanAction(
            youPlansSnapshot.goalActionLabel,
            onTap: onViewGoalPlan,
          ),
        ],
      ),
    );
  }
}

class _PlanMilestoneRow extends StatelessWidget {
  const _PlanMilestoneRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: _softIconDecoration,
          child: const Icon(
            Icons.flag_outlined,
            color: RuniacColors.primaryBlue,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(youPlansSnapshot.milestoneLabel, style: _smallStrongStyle),
              const SizedBox(height: 2),
              Text(youPlansSnapshot.milestoneTitle, style: _bodyStrongStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyPlanCard extends StatelessWidget {
  const _WeeklyPlanCard(this.onViewWorkout);

  final ValueChanged<WeeklyWorkoutDetailSnapshot> onViewWorkout;

  @override
  Widget build(BuildContext context) {
    return _YouDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  youPlansSnapshot.weeklyTitle,
                  style: _cardTitleStyle,
                ),
              ),
              const SizedBox(width: 12),
              const Text('2 of 3 done', style: _weeklyPlanProgressLabelStyle),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              value: 2 / 3,
              minHeight: 7,
              backgroundColor: RuniacColors.primaryBlue.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation(
                RuniacColors.accentOrange,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: RuniacColors.primaryBlue.withValues(alpha: 0.10),
          ),
          const SizedBox(height: 4),
          for (
            var index = 0;
            index < youPlansSnapshot.scheduleRows.length;
            index++
          )
            _WeeklyPlanDayRow(
              youPlansSnapshot.scheduleRows[index],
              showDivider: index > 0,
              onTap: _workoutDetailTap(
                youPlansSnapshot.scheduleRows[index],
                onViewWorkout,
              ),
            ),
        ],
      ),
    );
  }
}

VoidCallback? _workoutDetailTap(
  YouPlanScheduleRow row,
  ValueChanged<WeeklyWorkoutDetailSnapshot> onViewWorkout,
) {
  final detailSnapshot = row.detailSnapshot;
  if (!row.opensWorkoutDetail || detailSnapshot == null) {
    return null;
  }

  return () => onViewWorkout(detailSnapshot);
}

class _WeeklyPlanDayRow extends StatelessWidget {
  const _WeeklyPlanDayRow(
    this.display, {
    required this.showDivider,
    this.onTap,
  });

  final YouPlanScheduleRow display;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;
    final completed = display.status == 'Completed';
    final next = display.status == 'Upcoming · 7:30 AM';
    final upcoming = tappable && !next && !completed;
    final rest = display.title == 'Rest Day';
    final rowColor = next
        ? RuniacColors.accentOrange.withValues(alpha: 0.06)
        : upcoming
        ? RuniacColors.primaryBlue.withValues(alpha: 0.06)
        : null;
    final dayColor = next
        ? const Color(0xFFE8550A)
        : (completed || upcoming)
        ? RuniacColors.primaryBlue
        : RuniacColors.primaryBlue.withValues(alpha: 0.45);
    final subtitleColor = next
        ? const Color(0xFFE8550A)
        : RuniacColors.primaryBlue.withValues(alpha: 0.60);
    final status = display.status;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: rowColor,
        border: showDivider && !next && !upcoming
            ? Border(
                top: BorderSide(
                  color: RuniacColors.primaryBlue.withValues(alpha: 0.10),
                ),
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                display.day,
                style: TextStyle(
                  color: dayColor,
                  fontSize: 13,
                  fontWeight: (next || completed || upcoming)
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              child: _WeeklyPlanStatusNode(
                completed: completed,
                next: next,
                upcoming: upcoming,
                rest: rest,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    display.title,
                    style: TextStyle(
                      color: rest
                          ? RuniacColors.primaryBlue.withValues(alpha: 0.75)
                          : RuniacColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                        fontWeight: next ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (tappable) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                key: ValueKey('weekly_workout_detail_chevron'),
                color: next
                    ? RuniacColors.accentOrange
                    : RuniacColors.primaryBlue.withValues(alpha: 0.45),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );

    if (!tappable) {
      return row;
    }

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: row,
        ),
      ),
    );
  }
}

class _WeeklyPlanStatusNode extends StatelessWidget {
  const _WeeklyPlanStatusNode({
    required this.completed,
    required this.next,
    required this.upcoming,
    required this.rest,
  });

  final bool completed;
  final bool next;
  final bool upcoming;
  final bool rest;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: RuniacColors.primaryBlue,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: RuniacColors.primaryBlue.withValues(alpha: 0.24),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          color: RuniacColors.white,
          size: 17,
        ),
      );
    }

    if (next || upcoming) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: next
              ? RuniacColors.accentOrange.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            width: next ? 2.3 : 2,
            color: next
                ? RuniacColors.accentOrange
                : RuniacColors.primaryBlue.withValues(alpha: 0.30),
          ),
        ),
      );
    }

    if (rest) {
      return Icon(
        Icons.hotel_outlined,
        color: RuniacColors.primaryBlue.withValues(alpha: 0.45),
        size: 24,
      );
    }

    return const SizedBox(width: 28, height: 28);
  }
}

class _ExpertPlansCard extends StatelessWidget {
  const _ExpertPlansCard(this.onViewExpertPlans);

  final VoidCallback onViewExpertPlans;

  @override
  Widget build(BuildContext context) {
    return _YouDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(Icons.school_outlined, youPlansSnapshot.expertTitle),
          const SizedBox(height: 8),
          Text(youPlansSnapshot.expertCopy, style: _bodyStyle),
          const SizedBox(height: 14),
          Row(
            children: [
              _ExpertPlanOption(youPlansSnapshot.expertOptions[0]),
              const SizedBox(width: 10),
              _ExpertPlanOption(youPlansSnapshot.expertOptions[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ExpertPlanOption(youPlansSnapshot.expertOptions[2]),
              const SizedBox(width: 10),
              _ExpertPlanOption(youPlansSnapshot.expertOptions[3]),
            ],
          ),
          const SizedBox(height: 12),
          const _CoachCreatedBadge(),
          const SizedBox(height: 16),
          _StaticPlanAction(
            youPlansSnapshot.expertActionLabel,
            onTap: onViewExpertPlans,
          ),
        ],
      ),
    );
  }
}

class _ExpertPlanOption extends StatelessWidget {
  const _ExpertPlanOption(this.display);

  final YouExpertPlanOptionDisplay display;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 74),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: display.featured
              ? const Color(0xFFF7FAFF)
              : RuniacColors.white,
          borderRadius: BorderRadius.circular(_youInnerRadius),
          border: Border.all(
            color: display.featured
                ? RuniacColors.primaryBlue
                : RuniacColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              display.icon,
              color: display.featured
                  ? RuniacColors.primaryBlue
                  : RuniacColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 7),
            Text(
              display.label,
              textAlign: TextAlign.center,
              style: _bodyStrongStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCreatedBadge extends StatelessWidget {
  const _CoachCreatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: _pillDecoration(const Color(0xFFF7FAFF)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user,
            size: 14,
            color: RuniacColors.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(youPlansSnapshot.expertBadgeLabel, style: _smallStrongStyle),
        ],
      ),
    );
  }
}

class _StaticPlanAction extends StatelessWidget {
  const _StaticPlanAction(this.label, {this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      onTap: onTap,
      semanticsButton: onTap != null,
      borderRadius: BorderRadius.circular(_youInnerRadius),
      height: 44,
      alignment: Alignment.center,
      decoration: _cardLikeDecoration,
      child: Text(label, style: _buttonTextStyle),
    );
  }
}

Widget _planBadge(String label) {
  return Container(
    height: 30,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: _pillDecoration(const Color(0xFFF7FAFF)),
    child: Text(label, style: _smallStrongStyle),
  );
}

Widget _thisWeek() {
  return _YouDashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(Icons.directions_run, 'This Week'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(youProgressSnapshot.weeklyDistance, style: _heroNumberStyle),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                youProgressSnapshot.weeklyDistanceUnit,
                style: _labelStrongStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(youProgressSnapshot.weeklyRunSummary, style: _bodyStyle),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          child: LinearProgressIndicator(
            value: youProgressSnapshot.weeklyGoalProgress,
            minHeight: 7,
            backgroundColor: RuniacColors.border,
            valueColor: const AlwaysStoppedAnimation(RuniacColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 8),
        Text(youProgressSnapshot.weeklyGoalLabel, style: _smallBodyStyle),
      ],
    ),
  );
}

Widget _streak() {
  return _YouDashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(Icons.local_fire_department, 'Consistency Streak'),
        const SizedBox(height: 10),
        Text(youProgressSnapshot.streakValue, style: _heroNumberStyle),
        const SizedBox(height: 8),
        Text(youProgressSnapshot.streakCopy, style: _bodyStyle),
      ],
    ),
  );
}

Widget _calendarCard(
  DateTime visibleMonth,
  VoidCallback onPreviousMonth,
  VoidCallback onNextMonth,
) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final monthStart = DateTime(visibleMonth.year, visibleMonth.month);
  final calendarStart = monthStart.subtract(
    Duration(days: monthStart.weekday - DateTime.monday),
  );
  final calendarDays = [
    for (var offset = 0; offset < 42; offset++)
      calendarStart.add(Duration(days: offset)),
  ];

  return _YouDashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(Icons.calendar_month, 'Running Calendar'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _calendarButton(
              Icons.chevron_left,
              onPreviousMonth,
              'Previous month',
            ),
            Text(_monthLabel(visibleMonth), style: _calendarTitleStyle),
            _calendarButton(Icons.chevron_right, onNextMonth, 'Next month'),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [for (final day in weekdays) _cell(day, isLabel: true)]),
        const SizedBox(height: 8),
        for (var weekStart = 0; weekStart < 42; weekStart += 7) ...[
          Row(
            children: [
              for (final day in calendarDays.skip(weekStart).take(7))
                _dateCell(day, visibleMonth),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    ),
  );
}

Widget _calendarButton(IconData icon, VoidCallback onPressed, String label) {
  return SizedBox(
    width: 28,
    height: 28,
    child: IconButton(
      padding: EdgeInsets.zero,
      tooltip: label,
      icon: Icon(icon, size: 18, color: RuniacColors.primaryBlue),
      onPressed: onPressed,
    ),
  );
}

String _monthLabel(DateTime month) {
  return '${_monthNames[month.month - 1]} ${month.year}';
}

Widget _cell(String text, {bool isLabel = false}) {
  return Expanded(
    child: Center(
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: isLabel ? 11 : 12,
            fontWeight: isLabel ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

Widget _dateCell(DateTime day, DateTime visibleMonth) {
  final inVisibleMonth =
      day.year == visibleMonth.year && day.month == visibleMonth.month;
  final marked = inVisibleMonth && _runDaysFor(visibleMonth).contains(day.day);

  return Expanded(
    child: Center(
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        decoration: marked
            ? const BoxDecoration(
                color: RuniacColors.accentOrange,
                shape: BoxShape.circle,
              )
            : null,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: marked
                ? RuniacColors.white
                : inVisibleMonth
                ? RuniacColors.textPrimary
                : RuniacColors.textSecondary.withValues(alpha: 0.46),
            fontSize: 12,
            fontWeight: marked || inVisibleMonth
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

Set<int> _runDaysFor(DateTime month) {
  return youProgressSnapshot
          .runDayPlaceholders['${month.year}-${month.month}'] ??
      const {};
}

Widget _moreActivities(VoidCallback onTap) {
  return RuniacTappableSurface(
    key: const ValueKey('more_activities_button'),
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    height: 54,
    alignment: Alignment.center,
    decoration: _moreActivitiesDecoration,
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('More Activities', style: _moreActivitiesTextStyle),
        SizedBox(width: 10),
        Icon(
          Icons.chevron_right_rounded,
          key: ValueKey('more_activities_chevron'),
          color: RuniacColors.primaryBlue,
          size: 26,
        ),
      ],
    ),
  );
}

Widget _runLevel() {
  return _YouDashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(Icons.star_border, 'Run Level', accent: true),
        const SizedBox(height: 12),
        Text(youProgressSnapshot.levelTitle, style: _largeValueStyle),
        const SizedBox(height: 6),
        Text(youProgressSnapshot.levelCopy, style: _bodyStyle),
      ],
    ),
  );
}

class _CardHeader extends StatelessWidget {
  const _CardHeader(this.icon, this.label, {this.accent = false});

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return RuniacSectionHeader(
      title: label,
      leading: Icon(
        icon,
        size: 18,
        color: accent ? RuniacColors.accentOrange : RuniacColors.primaryBlue,
      ),
      titleStyle: _cardTitleStyle,
    );
  }
}

class _YouDashboardCard extends StatelessWidget {
  const _YouDashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: RuniacColors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_youCardRadius),
        side: const BorderSide(color: RuniacColors.cardBorder),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

BoxDecoration _pillDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: RuniacColors.border),
  );
}

final _cardLikeDecoration = BoxDecoration(
  color: RuniacColors.white,
  borderRadius: BorderRadius.circular(_youInnerRadius),
  border: Border.all(color: RuniacColors.cardBorder),
);
final _moreActivitiesDecoration = BoxDecoration(
  color: RuniacColors.white,
  borderRadius: BorderRadius.circular(999),
  border: Border.all(color: RuniacColors.cardBorder, width: 1.2),
);
final _softIconDecoration = BoxDecoration(
  color: RuniacColors.innerTileSurface,
  borderRadius: BorderRadius.circular(_youInnerRadius),
  border: Border.all(color: RuniacColors.border),
);
const _youCardRadius = 20.0;
const _youInnerRadius = 16.0;

const _cardTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w800,
);
const _headerTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 22,
  fontWeight: FontWeight.w900,
);
const _sectionStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 24,
  fontWeight: FontWeight.w900,
);
const _seeAllTextStyle = TextStyle(
  color: Color(0xFF8EA2EA),
  fontSize: 15,
  fontWeight: FontWeight.w800,
);
const _heroNumberStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 34,
  fontWeight: FontWeight.w900,
  height: 1,
);
const _largeValueStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 22,
  fontWeight: FontWeight.w900,
);
const _planPercentStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 22,
  fontWeight: FontWeight.w900,
);
const _buttonTextStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
  fontWeight: FontWeight.w900,
);
const _moreActivitiesTextStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 17,
  fontWeight: FontWeight.w900,
);
const _labelStrongStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 14,
  fontWeight: FontWeight.w700,
);
const _smallStrongStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 12,
  fontWeight: FontWeight.w700,
);
const _planAccentLabelStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 12,
  fontWeight: FontWeight.w800,
);
const _bodyStrongStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
  fontWeight: FontWeight.w800,
);
const _calendarTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
  fontWeight: FontWeight.w800,
);
const _bodyStyle = TextStyle(color: RuniacColors.textSecondary, fontSize: 13);
const _smallBodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 11,
);
const _weeklyPlanProgressLabelStyle = TextStyle(
  color: Color(0xBF2F51C8),
  fontSize: 12,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.1,
);
