import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';
import '../../../run/domain/models/run_activity_display_model.dart';
import '../data/activity_history_demo_snapshots.dart';
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
    required this.activityHistoryMonths,
    required this.runs,
    required this.visibleCalendarMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onRunSelected,
    required this.onMoreActivities,
    this.today,
    super.key,
  });

  final List<ActivityHistoryMonth> activityHistoryMonths;
  final List<RunActivityDisplayModel> runs;
  final DateTime visibleCalendarMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<RunActivityDisplayModel> onRunSelected;
  final VoidCallback onMoreActivities;
  final DateTime? today;

  @override
  State<YouProgressSurface> createState() => _YouProgressSurfaceState();
}

class _YouProgressSurfaceState extends State<YouProgressSurface> {
  var _selectedDistancePeriod = 0;

  @override
  Widget build(BuildContext context) {
    final summaries = _distancePeriodSummariesFor(
      widget.activityHistoryMonths,
      widget.today ?? DateTime.now(),
    );
    final selectedSummary = summaries[_selectedDistancePeriod];
    final graphData = _weeklyDistanceGraphDataFor(
      widget.activityHistoryMonths,
      widget.today ?? DateTime.now(),
    );

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
        _MonthlyDistanceSection(summary: selectedSummary, graphData: graphData),
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
        if (widget.runs.isEmpty)
          const _RecentRunningEmptyState()
        else
          for (final run in widget.runs) ...[
            CompactRunActivityCard(
              key: ValueKey('recent_running_card_${run.identityKey}'),
              activity: run,
              onTap: () => widget.onRunSelected(run),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _WeeklyDistanceGraphData {
  const _WeeklyDistanceGraphData({
    required this.labels,
    required this.values,
    required this.labelWeekIndices,
  });

  final List<String> labels;
  final List<double> values;
  final List<int> labelWeekIndices;
}

List<YouDistancePeriodSummary> _distancePeriodSummariesFor(
  List<ActivityHistoryMonth> months,
  DateTime today,
) {
  final activities = [for (final month in months) ...month.activities];
  final weekStart = _startOfWeek(today);
  final weekEnd = weekStart.add(const Duration(days: 7));
  final monthStart = DateTime(today.year, today.month);
  final nextMonthStart = DateTime(today.year, today.month + 1);
  final yearStart = DateTime(today.year);
  final nextYearStart = DateTime(today.year + 1);

  final weekTotal = _sumDistanceFor(
    activities,
    today,
    (date) => !date.isBefore(weekStart) && date.isBefore(weekEnd),
  );
  final monthTotal = _sumDistanceFor(
    activities,
    today,
    (date) => !date.isBefore(monthStart) && date.isBefore(nextMonthStart),
  );
  final yearTotal = _sumDistanceFor(
    activities,
    today,
    (date) => !date.isBefore(yearStart) && date.isBefore(nextYearStart),
  );
  final allTotal = activities.fold<double>(
    0,
    (total, activity) => total + _distanceKmFor(activity),
  );

  return [
    YouDistancePeriodSummary(
      'Week',
      'Weekly Distance',
      _formatKm(weekTotal),
      'km',
    ),
    YouDistancePeriodSummary(
      'Month',
      'Monthly Distance',
      _formatKm(monthTotal),
      'km',
    ),
    YouDistancePeriodSummary(
      'Year',
      'Yearly Distance',
      _formatKm(yearTotal),
      'km',
    ),
    YouDistancePeriodSummary(
      'All',
      'Total Distance',
      _formatKm(allTotal),
      'km',
    ),
  ];
}

_WeeklyDistanceGraphData _weeklyDistanceGraphDataFor(
  List<ActivityHistoryMonth> months,
  DateTime today,
) {
  const weekCount = 12;
  final activities = [for (final month in months) ...month.activities];
  final currentWeekStart = _startOfWeek(today);
  final firstWeekStart = currentWeekStart.subtract(
    const Duration(days: 7 * (weekCount - 1)),
  );
  final graphEnd = currentWeekStart.add(const Duration(days: 7));
  final values = List<double>.filled(weekCount, 0);

  for (final activity in activities) {
    final date = _dateFor(activity.summary.dateLabel, today);
    if (date == null ||
        date.isBefore(firstWeekStart) ||
        !date.isBefore(graphEnd)) {
      continue;
    }
    final weekIndex = date.difference(firstWeekStart).inDays ~/ 7;
    values[weekIndex] += _distanceKmFor(activity);
  }

  final markers = _monthMarkersForWeeklyGraph(firstWeekStart, weekCount, today);
  return _WeeklyDistanceGraphData(
    labels: markers.labels,
    values: values,
    labelWeekIndices: markers.weekIndices,
  );
}

/// Places one month label at the first week bucket belonging to each calendar
/// month the 12-week window spans, guaranteeing the current month is the
/// rightmost label. The current (last) week is attributed to [today]'s month so
/// a week that starts in the previous month but reaches into the current month
/// still surfaces the current month.
({List<String> labels, List<int> weekIndices}) _monthMarkersForWeeklyGraph(
  DateTime firstWeekStart,
  int weekCount,
  DateTime today,
) {
  final labels = <String>[];
  final weekIndices = <int>[];
  int? lastMonthKey;
  for (var week = 0; week < weekCount; week += 1) {
    final isCurrentWeek = week == weekCount - 1;
    final markerMonth = isCurrentWeek
        ? DateTime(today.year, today.month)
        : () {
            final weekStart = firstWeekStart.add(Duration(days: 7 * week));
            return DateTime(weekStart.year, weekStart.month);
          }();
    final monthKey = markerMonth.year * 12 + markerMonth.month;
    if (monthKey == lastMonthKey) {
      continue;
    }
    lastMonthKey = monthKey;
    labels.add(
      _monthNames[markerMonth.month - 1].substring(0, 3).toUpperCase(),
    );
    weekIndices.add(week);
  }
  return (labels: labels, weekIndices: weekIndices);
}

/// Test-visible wrapper computing the month markers for the past-12-weeks graph
/// window ending at [today].
@visibleForTesting
({List<String> labels, List<int> weekIndices}) weeklyDistanceGraphMonthMarkers(
  DateTime today, {
  int weekCount = 12,
}) {
  final currentWeekStart = _startOfWeek(today);
  final firstWeekStart = currentWeekStart.subtract(
    Duration(days: 7 * (weekCount - 1)),
  );
  return _monthMarkersForWeeklyGraph(firstWeekStart, weekCount, today);
}

double _sumDistanceFor(
  List<RunActivityDisplayModel> activities,
  DateTime today,
  bool Function(DateTime date) includes,
) {
  return activities.fold<double>(0, (total, activity) {
    final date = _dateFor(activity.summary.dateLabel, today);
    if (date == null || !includes(date)) {
      return total;
    }
    return total + _distanceKmFor(activity);
  });
}

DateTime _startOfWeek(DateTime date) {
  final localDate = DateTime(date.year, date.month, date.day);
  return localDate.subtract(
    Duration(days: localDate.weekday - DateTime.monday),
  );
}

DateTime? _dateFor(String label, DateTime today) {
  final trimmed = label.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.toLowerCase() == 'today') {
    return DateTime(today.year, today.month, today.day);
  }
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) {
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
  final slashDayMonthYear = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{2}|\d{4})$',
  ).firstMatch(trimmed);
  if (slashDayMonthYear != null) {
    final day = int.tryParse(slashDayMonthYear.group(1)!);
    final month = int.tryParse(slashDayMonthYear.group(2)!);
    final rawYear = int.tryParse(slashDayMonthYear.group(3)!);
    if (day != null && month != null && rawYear != null) {
      final year = rawYear < 100 ? 2000 + rawYear : rawYear;
      final date = DateTime(year, month, day);
      if (date.year == year && date.month == month && date.day == day) {
        return date;
      }
    }
  }
  final dayMonthYear = RegExp(
    r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$',
  ).firstMatch(trimmed);
  if (dayMonthYear != null) {
    final day = int.tryParse(dayMonthYear.group(1)!);
    final month = _monthNumber(dayMonthYear.group(2)!);
    final year = int.tryParse(dayMonthYear.group(3)!);
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }
  final monthYear = RegExp(r'^([A-Za-z]+)\s+(\d{4})$').firstMatch(trimmed);
  if (monthYear != null) {
    final month = _monthNumber(monthYear.group(1)!);
    final year = int.tryParse(monthYear.group(2)!);
    if (month != null && year != null) {
      return DateTime(year, month);
    }
  }
  return null;
}

int? _monthNumber(String label) {
  final normalized = label.toLowerCase();
  for (var index = 0; index < _monthNames.length; index += 1) {
    final month = _monthNames[index].toLowerCase();
    if (month.startsWith(normalized) || normalized.startsWith(month)) {
      return index + 1;
    }
  }
  return null;
}

double _distanceKmFor(RunActivityDisplayModel activity) {
  return activity.distanceMeters / 1000;
}

String _formatKm(double value) {
  return value.toStringAsFixed(2);
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

class _RecentRunningEmptyState extends StatelessWidget {
  const _RecentRunningEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('recent_running_empty_state'),
      padding: const EdgeInsets.all(16),
      decoration: youCardLikeDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YouCardHeader(Icons.directions_run, 'Start your first run'),
          SizedBox(height: 8),
          Text(
            "Start a run when you're ready. Your recent activities will appear here.",
            style: YouTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _MonthlyDistanceSection extends StatelessWidget {
  const _MonthlyDistanceSection({
    required this.summary,
    required this.graphData,
  });

  final YouDistancePeriodSummary summary;
  final _WeeklyDistanceGraphData graphData;

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
              PastTwelveWeeksDistanceGraph(
                key: ValueKey('you_monthly_distance_graph'),
                labels: graphData.labels,
                values: graphData.values,
                labelWeekIndices: graphData.labelWeekIndices,
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

String _monthLabel(DateTime month) {
  return '${_monthNames[month.month - 1]} ${month.year}';
}

Set<int> _runDaysFor(DateTime month) {
  return youProgressSnapshot
          .runDayPlaceholders['${month.year}-${month.month}'] ??
      const {};
}
