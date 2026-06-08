import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';
import 'goal_plan_detail_screen.dart';
import 'weekly_workout_detail_screen.dart';

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

const _progressSnapshot = _YouProgressSnapshot(
  weeklyDistance: '12.4',
  weeklyDistanceUnit: 'km',
  weeklyRunSummary: '3 runs this week',
  weeklyGoalProgress: 0.82,
  weeklyGoalLabel: '82% of weekly goal',
  streakValue: '6 days',
  streakCopy: 'Planned rest days keep your streak protected.',
  runs: [
    _RunDisplay('4/11/26', 'Saturday Night Run', '4.03 km', '6\'30"', '30:15'),
    _RunDisplay('4/11/26', 'Morning Easy Run', '3.20 km', '7\'05"', '24:10'),
    _RunDisplay('4/11/26', 'Recovery Jog', '5.17 km', '7\'40"', '39:38'),
  ],
  runDayPlaceholders: {
    '2026-5': {1, 3, 5, 8, 10, 12, 15, 17, 20},
  },
  levelTitle: 'Level 12 Runner',
  levelCopy: 'Keep showing up at a comfortable pace.',
);

const _plansSnapshot = _YouPlansSnapshot(
  goalLabel: 'Current Goal',
  goalTitle: '10K Preparation',
  goalBadge: 'Week 3 of 8',
  completionLabel: '43% completed',
  completionPercentLabel: '43%',
  completionProgress: 0.43,
  milestoneLabel: 'Next Milestone',
  milestoneTitle: 'Complete 6 km comfortably',
  goalActionLabel: 'View Goal Plan',
  weeklyTitle: "This Week's 10K Preparation Plan",
  weeklyCopy: 'Take each easy run as a steady step forward.',
  counters: [
    _PlanCounterDisplay('3', 'Planned Runs'),
    _PlanCounterDisplay('2', 'Completed'),
    _PlanCounterDisplay('1', 'Remaining'),
  ],
  scheduleRows: [
    _PlanScheduleRow('Mon', 'Rest Day', 'Rest Day', Icons.hotel_outlined),
    _PlanScheduleRow(
      'Tue',
      '15 min walk-run',
      'Completed',
      Icons.check_circle,
      active: true,
    ),
    _PlanScheduleRow('Wed', 'Rest Day', 'Rest Day', Icons.hotel_outlined),
    _PlanScheduleRow(
      'Thu',
      '20 min easy run',
      'Upcoming · 7:30 AM',
      Icons.radio_button_unchecked,
      active: true,
      opensWorkoutDetail: true,
    ),
    _PlanScheduleRow('Fri', 'Rest Day', 'Rest Day', Icons.hotel_outlined),
    _PlanScheduleRow(
      'Sat',
      '20 min easy run',
      'Completed',
      Icons.check_circle,
      active: true,
    ),
    _PlanScheduleRow('Sun', 'Rest Day', 'Rest Day', Icons.hotel_outlined),
  ],
  expertTitle: 'Explore expert goal plan',
  expertCopy:
      'Browse coach-created plans and apply one to your current goal plan.',
  expertBadgeLabel: 'Coach-created',
  expertActionLabel: 'Explore Expert Plans',
  expertOptions: [
    _ExpertPlanOptionDisplay(Icons.directions_run, 'First 5K', featured: true),
    _ExpertPlanOptionDisplay(Icons.flag_outlined, '10K', featured: true),
    _ExpertPlanOptionDisplay(Icons.terrain_outlined, 'Half Marathon'),
    _ExpertPlanOptionDisplay(Icons.landscape_outlined, 'Full Marathon'),
  ],
);

class _YouProgressSnapshot {
  const _YouProgressSnapshot({
    required this.weeklyDistance,
    required this.weeklyDistanceUnit,
    required this.weeklyRunSummary,
    required this.weeklyGoalProgress,
    required this.weeklyGoalLabel,
    required this.streakValue,
    required this.streakCopy,
    required this.runs,
    required this.runDayPlaceholders,
    required this.levelTitle,
    required this.levelCopy,
  });

  final String weeklyDistance;
  final String weeklyDistanceUnit;
  final String weeklyRunSummary;
  final double weeklyGoalProgress;
  final String weeklyGoalLabel;
  final String streakValue;
  final String streakCopy;
  final List<_RunDisplay> runs;
  final Map<String, Set<int>> runDayPlaceholders;
  final String levelTitle;
  final String levelCopy;
}

class _RunDisplay {
  const _RunDisplay(
    this.date,
    this.title,
    this.distance,
    this.avgPace,
    this.time,
  );

  final String date;
  final String title;
  final String distance;
  final String avgPace;
  final String time;
}

class _YouPlansSnapshot {
  const _YouPlansSnapshot({
    required this.goalLabel,
    required this.goalTitle,
    required this.goalBadge,
    required this.completionLabel,
    required this.completionPercentLabel,
    required this.completionProgress,
    required this.milestoneLabel,
    required this.milestoneTitle,
    required this.goalActionLabel,
    required this.weeklyTitle,
    required this.weeklyCopy,
    required this.counters,
    required this.scheduleRows,
    required this.expertTitle,
    required this.expertCopy,
    required this.expertBadgeLabel,
    required this.expertActionLabel,
    required this.expertOptions,
  });

  final String goalLabel;
  final String goalTitle;
  final String goalBadge;
  final String completionLabel;
  final String completionPercentLabel;
  final double completionProgress;
  final String milestoneLabel;
  final String milestoneTitle;
  final String goalActionLabel;
  final String weeklyTitle;
  final String weeklyCopy;
  final List<_PlanCounterDisplay> counters;
  final List<_PlanScheduleRow> scheduleRows;
  final String expertTitle;
  final String expertCopy;
  final String expertBadgeLabel;
  final String expertActionLabel;
  final List<_ExpertPlanOptionDisplay> expertOptions;
}

class _PlanCounterDisplay {
  const _PlanCounterDisplay(this.value, this.label);

  final String value;
  final String label;
}

class _PlanScheduleRow {
  const _PlanScheduleRow(
    this.day,
    this.title,
    this.status,
    this.icon, {
    this.active = false,
    this.opensWorkoutDetail = false,
  });

  final String day;
  final String title;
  final String status;
  final IconData icon;
  final bool active;
  final bool opensWorkoutDetail;
}

class _ExpertPlanOptionDisplay {
  const _ExpertPlanOptionDisplay(
    this.icon,
    this.label, {
    this.featured = false,
  });

  final IconData icon;
  final String label;
  final bool featured;
}

class YouTab extends StatefulWidget {
  const YouTab({super.key});

  @override
  State<YouTab> createState() => _YouTabState();
}

class _YouTabState extends State<YouTab> {
  var _plans = false;
  var _goalPlanDetailVisible = false;
  var _workoutDetailVisible = false;
  var _visibleCalendarMonth = DateTime(2026, 5);

  @override
  Widget build(BuildContext context) {
    if (_workoutDetailVisible) {
      return WeeklyWorkoutDetailScreen(
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
                  _plansEmpty(_showGoalPlanDetail, _showWorkoutDetail)
                else
                  _progress(
                    _visibleCalendarMonth,
                    _showPreviousCalendarMonth,
                    _showNextCalendarMonth,
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

  void _showWorkoutDetail() {
    setState(() => _workoutDetailVisible = true);
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
      const SizedBox(height: 16),
      const Center(child: Text('Recent Running', style: _sectionStyle)),
      const SizedBox(height: 10),
      for (final run in _progressSnapshot.runs) ...[
        _runCard(run),
        const SizedBox(height: 10),
      ],
      _moreActivities(),
      const SizedBox(height: 14),
      _runLevel(),
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

Widget _plansEmpty(VoidCallback onViewGoalPlan, VoidCallback onViewWorkout) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _RuniacAccentStrip(),
      const SizedBox(height: 12),
      _CurrentGoalPlanCard(onViewGoalPlan),
      const SizedBox(height: 12),
      _WeeklyPlanCard(onViewWorkout),
      const SizedBox(height: 12),
      const _ExpertPlansCard(),
    ],
  );
}

class _CurrentGoalPlanCard extends StatelessWidget {
  const _CurrentGoalPlanCard(this.onViewGoalPlan);

  final VoidCallback onViewGoalPlan;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
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
                      _plansSnapshot.goalLabel,
                      style: _planAccentLabelStyle,
                    ),
                    SizedBox(height: 6),
                    Text(_plansSnapshot.goalTitle, style: _largeValueStyle),
                  ],
                ),
              ),
              _planBadge(_plansSnapshot.goalBadge),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _plansSnapshot.completionLabel,
                style: _planAccentLabelStyle,
              ),
              const Spacer(),
              Text(
                _plansSnapshot.completionPercentLabel,
                style: _planPercentStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              value: _plansSnapshot.completionProgress,
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
            _plansSnapshot.goalActionLabel,
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
              Text(_plansSnapshot.milestoneLabel, style: _smallStrongStyle),
              const SizedBox(height: 2),
              Text(_plansSnapshot.milestoneTitle, style: _bodyStrongStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyPlanCard extends StatelessWidget {
  const _WeeklyPlanCard(this.onViewWorkout);

  final VoidCallback onViewWorkout;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_plansSnapshot.weeklyTitle, style: _cardTitleStyle),
          const SizedBox(height: 8),
          Text(_plansSnapshot.weeklyCopy, style: _bodyStyle),
          const SizedBox(height: 14),
          Row(
            children: [
              for (
                var index = 0;
                index < _plansSnapshot.counters.length;
                index++
              ) ...[
                _PlanCounter(_plansSnapshot.counters[index]),
                if (index < _plansSnapshot.counters.length - 1)
                  const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 14),
          for (final row in _plansSnapshot.scheduleRows)
            _WeeklyPlanRow(
              row,
              onTap: row.opensWorkoutDetail ? onViewWorkout : null,
            ),
        ],
      ),
    );
  }
}

class _PlanCounter extends StatelessWidget {
  const _PlanCounter(this.display);

  final _PlanCounterDisplay display;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '${display.value} ${display.label}',
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 62),
            alignment: Alignment.center,
            decoration: _counterDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(display.value, style: _planCounterValueStyle),
                const SizedBox(height: 3),
                Text(
                  display.label,
                  textAlign: TextAlign.center,
                  style: _smallBodyStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyPlanRow extends StatelessWidget {
  const _WeeklyPlanRow(this.display, {this.onTap});

  final _PlanScheduleRow display;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;
    final titleColor = display.active
        ? RuniacColors.textPrimary
        : RuniacColors.textSecondary;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: tappable ? const Color(0xFFF7FAFF) : null,
        border: const Border(top: BorderSide(color: RuniacColors.border)),
        borderRadius: tappable ? BorderRadius.circular(8) : null,
      ),
      child: Padding(
        padding: tappable
            ? const EdgeInsets.symmetric(horizontal: 8)
            : EdgeInsets.zero,
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                display.day,
                style: display.active ? _bodyStrongStyle : _smallBodyStyle,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              display.icon,
              size: 22,
              color: display.active
                  ? RuniacColors.primaryBlue
                  : RuniacColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                display.title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 13,
                  fontWeight: display.active
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              display.status,
              textAlign: TextAlign.right,
              style: _smallBodyStyle,
            ),
            if (tappable) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                key: ValueKey('weekly_workout_detail_chevron'),
                color: RuniacColors.primaryBlue,
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
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: row,
        ),
      ),
    );
  }
}

class _ExpertPlansCard extends StatelessWidget {
  const _ExpertPlansCard();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(Icons.school_outlined, _plansSnapshot.expertTitle),
          const SizedBox(height: 8),
          Text(_plansSnapshot.expertCopy, style: _bodyStyle),
          const SizedBox(height: 14),
          Row(
            children: [
              _ExpertPlanOption(_plansSnapshot.expertOptions[0]),
              const SizedBox(width: 10),
              _ExpertPlanOption(_plansSnapshot.expertOptions[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ExpertPlanOption(_plansSnapshot.expertOptions[2]),
              const SizedBox(width: 10),
              _ExpertPlanOption(_plansSnapshot.expertOptions[3]),
            ],
          ),
          const SizedBox(height: 12),
          const _CoachCreatedBadge(),
          const SizedBox(height: 16),
          _StaticPlanAction(_plansSnapshot.expertActionLabel),
        ],
      ),
    );
  }
}

class _ExpertPlanOption extends StatelessWidget {
  const _ExpertPlanOption(this.display);

  final _ExpertPlanOptionDisplay display;

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
          borderRadius: BorderRadius.circular(8),
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
          Text(_plansSnapshot.expertBadgeLabel, style: _smallStrongStyle),
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
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: _cardLikeDecoration,
          child: Text(label, style: _buttonTextStyle),
        ),
      ),
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
  return DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(Icons.directions_run, 'This Week'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_progressSnapshot.weeklyDistance, style: _heroNumberStyle),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _progressSnapshot.weeklyDistanceUnit,
                style: _labelStrongStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(_progressSnapshot.weeklyRunSummary, style: _bodyStyle),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          child: LinearProgressIndicator(
            value: _progressSnapshot.weeklyGoalProgress,
            minHeight: 7,
            backgroundColor: RuniacColors.border,
            valueColor: const AlwaysStoppedAnimation(RuniacColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 8),
        Text(_progressSnapshot.weeklyGoalLabel, style: _smallBodyStyle),
      ],
    ),
  );
}

Widget _streak() {
  return DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(Icons.local_fire_department, 'Consistency Streak'),
        const SizedBox(height: 10),
        Text(_progressSnapshot.streakValue, style: _heroNumberStyle),
        const SizedBox(height: 8),
        Text(_progressSnapshot.streakCopy, style: _bodyStyle),
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

  return DashboardCard(
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
  return _progressSnapshot.runDayPlaceholders['${month.year}-${month.month}'] ??
      const {};
}

Widget _runCard(_RunDisplay run) {
  return DashboardCard(
    child: Row(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: _cardGraphicDecoration,
          child: const Icon(Icons.route, color: RuniacColors.primaryBlue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(run.date, style: _smallStrongStyle),
              Text(run.title, style: _runTitleStyle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _metric(run.distance, 'Distance'),
                  _metric(run.avgPace, 'Avg Pace'),
                  _metric(run.time, 'Time'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _metric(String value, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: _metricStyle),
      const SizedBox(height: 3),
      Text(label, style: _smallBodyStyle),
    ],
  );
}

Widget _moreActivities() {
  return Container(
    height: 44,
    alignment: Alignment.center,
    decoration: _cardLikeDecoration,
    child: const Text('More Activities', style: _buttonTextStyle),
  );
}

Widget _runLevel() {
  return DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(Icons.star_border, 'Run Level', accent: true),
        const SizedBox(height: 12),
        Text(_progressSnapshot.levelTitle, style: _largeValueStyle),
        const SizedBox(height: 6),
        Text(_progressSnapshot.levelCopy, style: _bodyStyle),
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
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: accent ? RuniacColors.accentOrange : RuniacColors.primaryBlue,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: _cardTitleStyle)),
      ],
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

final _cardGraphicDecoration = BoxDecoration(
  color: const Color(0xFFF1F4FA),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: RuniacColors.border),
);

final _cardLikeDecoration = BoxDecoration(
  color: RuniacColors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: RuniacColors.border),
);
final _counterDecoration = BoxDecoration(
  color: RuniacColors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: RuniacColors.border),
);
final _softIconDecoration = BoxDecoration(
  color: const Color(0xFFF7FAFF),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: RuniacColors.border),
);

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
  fontSize: 20,
  fontWeight: FontWeight.w900,
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
const _metricStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 21,
  fontWeight: FontWeight.w900,
  height: 1,
);
const _planPercentStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 22,
  fontWeight: FontWeight.w900,
);
const _planCounterValueStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 24,
  fontWeight: FontWeight.w900,
  height: 1,
);
const _runTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 15,
  fontWeight: FontWeight.w900,
);
const _buttonTextStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
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
