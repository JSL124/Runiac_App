import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';

const _runs = [
  ('Saturday Night Run', '4.03 km', '6\'30"', '30:15'),
  ('Morning Easy Run', '3.20 km', '7\'05"', '24:10'),
  ('Recovery Jog', '5.17 km', '7\'40"', '39:38'),
];
const _runDayPlaceholders = {
  '2026-5': {1, 3, 5, 8, 10, 12, 15, 17, 20},
};
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
  var _visibleCalendarMonth = DateTime(2026, 5);
  OverlayEntry? _headerOverlay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _headerOverlay != null) {
        return;
      }

      _headerOverlay = OverlayEntry(
        builder: (context) {
          final topPadding = MediaQuery.paddingOf(context).top;
          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + kToolbarHeight,
            child: const _YouHeaderOverlay(),
          );
        },
      );
      Overlay.of(context, rootOverlay: true).insert(_headerOverlay!);
    });
  }

  @override
  void dispose() {
    _headerOverlay?.remove();
    _headerOverlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _segments(['Progress', 'Plans'], _plans ? 1 : 0, (index) {
              setState(() => _plans = index == 1);
            }),
            const SizedBox(height: 12),
            if (_plans)
              _plansEmpty()
            else
              _progress(
                _visibleCalendarMonth,
                _showPreviousCalendarMonth,
                _showNextCalendarMonth,
              ),
          ],
        ),
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
      for (final run in _runs) ...[_runCard(run), const SizedBox(height: 10)],
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

Widget _plansEmpty() {
  return DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _CardHeader(Icons.event_note, 'Plans'),
        SizedBox(height: 12),
        Text('Build your next running habit here.', style: _largeValueStyle),
        SizedBox(height: 6),
        Text(
          'A simple plan space will stay ready without adding pressure.',
          style: _bodyStyle,
        ),
      ],
    ),
  );
}

Widget _thisWeek() {
  return DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _CardHeader(Icons.directions_run, 'This Week'),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('12.4', style: _heroNumberStyle),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('km', style: _labelStrongStyle),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text('3 runs this week', style: _bodyStyle),
        SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          child: LinearProgressIndicator(
            value: 0.82,
            minHeight: 7,
            backgroundColor: RuniacColors.border,
            valueColor: AlwaysStoppedAnimation(RuniacColors.primaryBlue),
          ),
        ),
        SizedBox(height: 8),
        Text('82% of weekly goal', style: _smallBodyStyle),
      ],
    ),
  );
}

Widget _streak() {
  return DashboardCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _CardHeader(Icons.local_fire_department, 'Consistency Streak'),
        SizedBox(height: 10),
        Text('6 days', style: _heroNumberStyle),
        SizedBox(height: 8),
        Text(
          'Planned rest days keep your streak protected.',
          style: _bodyStyle,
        ),
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
  return _runDayPlaceholders['${month.year}-${month.month}'] ?? const {};
}

Widget _runCard((String, String, String, String) run) {
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
              const Text('4/11/26', style: _smallStrongStyle),
              Text(run.$1, style: _runTitleStyle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _metric(run.$2, 'Distance'),
                  _metric(run.$3, 'Avg Pace'),
                  _metric(run.$4, 'Time'),
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
      children: const [
        _CardHeader(Icons.star_border, 'Run Level', accent: true),
        SizedBox(height: 12),
        Text('Level 12 Runner', style: _largeValueStyle),
        SizedBox(height: 6),
        Text('Keep showing up at a comfortable pace.', style: _bodyStyle),
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
