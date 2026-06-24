import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';
import '../../../run/domain/models/run_activity_display_model.dart';
import '../data/you_overview_demo_snapshots.dart';
import 'compact_run_activity_card.dart';
import 'monthly_distance_graph.dart';
import 'you_segmented_control.dart';
import 'you_surface_primitives.dart';

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

class YouProgressSurface extends StatefulWidget {
  const YouProgressSurface({
    required this.runs,
    required this.visibleCalendarMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onRunSelected,
    required this.onMoreActivities,
    super.key,
  });

  final List<RunActivityDisplayModel> runs;
  final DateTime visibleCalendarMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<RunActivityDisplayModel> onRunSelected;
  final VoidCallback onMoreActivities;

  @override
  State<YouProgressSurface> createState() => _YouProgressSurfaceState();
}

class _YouProgressSurfaceState extends State<YouProgressSurface> {
  var _selectedDistancePeriod = 0;

  @override
  Widget build(BuildContext context) {
    final summaries = youProgressSnapshot.distancePeriodSummaries;
    final selectedSummary = summaries[_selectedDistancePeriod];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RuniacAccentStrip(),
        const SizedBox(height: 12),
        YouSegmentedControl(
          labels: [for (final summary in summaries) summary.segmentLabel],
          selected: _selectedDistancePeriod,
          compact: true,
          onTap: (index) {
            setState(() => _selectedDistancePeriod = index);
          },
        ),
        const SizedBox(height: 12),
        _MonthlyDistanceSection(summary: selectedSummary),
        const SizedBox(height: 10),
        const _StreakSection(),
        const SizedBox(height: 10),
        _CalendarSection(
          visibleMonth: widget.visibleCalendarMonth,
          onPreviousMonth: widget.onPreviousMonth,
          onNextMonth: widget.onNextMonth,
        ),
        const SizedBox(height: 18),
        _RecentRunningHeader(onSeeAll: widget.onMoreActivities),
        const SizedBox(height: 12),
        for (final run in widget.runs) ...[
          CompactRunActivityCard(
            key: ValueKey('recent_running_card_${run.identityKey}'),
            activity: run,
            onTap: () => widget.onRunSelected(run),
          ),
          const SizedBox(height: 10),
        ],
        _MoreActivitiesButton(onTap: widget.onMoreActivities),
      ],
    );
  }
}

class _RecentRunningHeader extends StatelessWidget {
  const _RecentRunningHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text('Recent Running', style: YouTextStyles.section),
        ),
        RuniacTappableSurface(
          key: const ValueKey('recent_running_see_all'),
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(999),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: const Text('See all', style: YouTextStyles.seeAll),
        ),
      ],
    );
  }
}

class _MonthlyDistanceSection extends StatelessWidget {
  const _MonthlyDistanceSection({required this.summary});

  final YouDistancePeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary.title, style: YouTextStyles.cardTitle),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(summary.distance, style: YouTextStyles.heroNumber),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(summary.unit, style: YouTextStyles.labelStrong),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const PastTwelveWeeksDistanceGraph(
                key: ValueKey('you_monthly_distance_graph'),
              ),
            ],
          ),
        ),
        const _SectionDivider(),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: RuniacColors.border);
  }
}

class _StreakSection extends StatelessWidget {
  const _StreakSection();

  @override
  Widget build(BuildContext context) {
    return _DividerSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YouCardHeader(
            Icons.local_fire_department,
            'Consistency Streak',
          ),
          const SizedBox(height: 10),
          Text(
            youProgressSnapshot.streakValue,
            style: YouTextStyles.heroNumber,
          ),
          const SizedBox(height: 8),
          Text(youProgressSnapshot.streakCopy, style: YouTextStyles.body),
        ],
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.visibleMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime visibleMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthStart = DateTime(visibleMonth.year, visibleMonth.month);
    final calendarStart = monthStart.subtract(
      Duration(days: monthStart.weekday - DateTime.monday),
    );
    final calendarDays = [
      for (var offset = 0; offset < 42; offset++)
        calendarStart.add(Duration(days: offset)),
    ];

    return _DividerSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YouCardHeader(Icons.calendar_month, 'Running Calendar'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalendarButton(
                icon: Icons.chevron_left,
                onPressed: onPreviousMonth,
                label: 'Previous month',
              ),
              Text(
                _monthLabel(visibleMonth),
                style: YouTextStyles.calendarTitle,
              ),
              _CalendarButton(
                icon: Icons.chevron_right,
                onPressed: onNextMonth,
                label: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final day in weekdays) _CalendarCell(day, isLabel: true),
            ],
          ),
          const SizedBox(height: 8),
          for (var weekStart = 0; weekStart < 42; weekStart += 7) ...[
            Row(
              children: [
                for (final day in calendarDays.skip(weekStart).take(7))
                  _DateCell(day: day, visibleMonth: visibleMonth),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DividerSection extends StatelessWidget {
  const _DividerSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: child,
        ),
        const _SectionDivider(),
      ],
    );
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton({
    required this.icon,
    required this.onPressed,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
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
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell(this.text, {this.isLabel = false});

  final String text;
  final bool isLabel;

  @override
  Widget build(BuildContext context) {
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
}

class _DateCell extends StatelessWidget {
  const _DateCell({required this.day, required this.visibleMonth});

  final DateTime day;
  final DateTime visibleMonth;

  @override
  Widget build(BuildContext context) {
    final inVisibleMonth =
        day.year == visibleMonth.year && day.month == visibleMonth.month;
    final marked =
        inVisibleMonth && _runDaysFor(visibleMonth).contains(day.day);

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
}

class _MoreActivitiesButton extends StatelessWidget {
  const _MoreActivitiesButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      key: const ValueKey('more_activities_button'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      height: 54,
      alignment: Alignment.center,
      decoration: youMoreActivitiesDecoration,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('More Activities', style: YouTextStyles.moreActivities),
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
}

String _monthLabel(DateTime month) {
  return '${_monthNames[month.month - 1]} ${month.year}';
}

Set<int> _runDaysFor(DateTime month) {
  return youProgressSnapshot
          .runDayPlaceholders['${month.year}-${month.month}'] ??
      const {};
}
