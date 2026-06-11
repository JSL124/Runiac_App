import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';

const weeklyWorkoutDetailSnapshot = WeeklyWorkoutDetailSnapshot(
  title: 'Workout detail',
  dayLabel: 'THURSDAY · EASY RUN',
  editScheduleCurrentLabel: 'Thu · 7:30 AM',
  editSchedulePreviewLabel: 'Fri · 7:30 AM',
  heroTitle: 'A gentle 20 minutes.',
  heroCopy: 'You should be able to chat the whole way through.',
  heroSupportCopy: 'No race — just rhythm.',
  metrics: [
    WorkoutMetricDisplay('Distance', '3.0 km'),
    WorkoutMetricDisplay('Time', '20 min'),
    WorkoutMetricDisplay('Suggested pace', '7:30 /km'),
    WorkoutMetricDisplay('Effort', 'Low'),
  ],
  breakdown: [
    WorkoutStepDisplay(Icons.directions_walk, 'Warm-up', '5 min · easy walk'),
    WorkoutStepDisplay(
      Icons.directions_run,
      'Easy run',
      '12 min · conversational pace',
    ),
    WorkoutStepDisplay(
      Icons.self_improvement,
      'Cool-down',
      '3 min · slow walk',
    ),
  ],
  effortGuide:
      'Aim for 2 out of 5 — you can speak full sentences without gasping.',
  coachNotes: [
    'Start slower than you think.',
    'If breathing feels sharp, walk briefly and reset.',
    'Easy runs should feel almost too slow at first. That is normal.',
  ],
  startActionLabel: 'Start This Run',
);

const saturdayWeeklyWorkoutDetailSnapshot = WeeklyWorkoutDetailSnapshot(
  title: 'Workout detail',
  dayLabel: 'SATURDAY · EASY RUN',
  editScheduleCurrentLabel: 'Saturday',
  editSchedulePreviewLabel: 'Preview only',
  heroTitle: 'A gentle 20 minutes.',
  heroCopy: 'You should be able to chat the whole way through.',
  heroSupportCopy: 'No race — just rhythm.',
  metrics: [
    WorkoutMetricDisplay('Distance', '3.0 km'),
    WorkoutMetricDisplay('Time', '20 min'),
    WorkoutMetricDisplay('Suggested pace', '7:30 /km'),
    WorkoutMetricDisplay('Effort', 'Low'),
  ],
  breakdown: [
    WorkoutStepDisplay(Icons.directions_walk, 'Warm-up', '5 min · easy walk'),
    WorkoutStepDisplay(
      Icons.directions_run,
      'Easy run',
      '12 min · conversational pace',
    ),
    WorkoutStepDisplay(
      Icons.self_improvement,
      'Cool-down',
      '3 min · slow walk',
    ),
  ],
  effortGuide:
      'Aim for 2 out of 5 — you can speak full sentences without gasping.',
  coachNotes: [
    'Start slower than you think.',
    'If breathing feels sharp, walk briefly and reset.',
    'Easy runs should feel almost too slow at first. That is normal.',
  ],
  startActionLabel: 'Start This Run',
);

class WeeklyWorkoutDetailSnapshot {
  const WeeklyWorkoutDetailSnapshot({
    required this.title,
    required this.dayLabel,
    required this.editScheduleCurrentLabel,
    required this.editSchedulePreviewLabel,
    required this.heroTitle,
    required this.heroCopy,
    required this.heroSupportCopy,
    required this.metrics,
    required this.breakdown,
    required this.effortGuide,
    required this.coachNotes,
    required this.startActionLabel,
  });

  final String title;
  final String dayLabel;
  final String editScheduleCurrentLabel;
  final String editSchedulePreviewLabel;
  final String heroTitle;
  final String heroCopy;
  final String heroSupportCopy;
  final List<WorkoutMetricDisplay> metrics;
  final List<WorkoutStepDisplay> breakdown;
  final String effortGuide;
  final List<String> coachNotes;
  final String startActionLabel;
}

class WorkoutMetricDisplay {
  const WorkoutMetricDisplay(this.label, this.value);

  final String label;
  final String value;
}

class WorkoutStepDisplay {
  const WorkoutStepDisplay(this.icon, this.title, this.copy);

  final IconData icon;
  final String title;
  final String copy;
}

class WeeklyWorkoutDetailScreen extends StatelessWidget {
  const WeeklyWorkoutDetailScreen({
    required this.onBack,
    this.snapshot = weeklyWorkoutDetailSnapshot,
    super.key,
  });

  final VoidCallback onBack;
  final WeeklyWorkoutDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: _NoOverscroll(
          key: const ValueKey('workout_detail_no_overscroll'),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              _WorkoutDetailHeader(
                title: snapshot.title,
                onBack: onBack,
                onEditSchedule: () => _showEditScheduleSheet(context, snapshot),
              ),
              const SizedBox(height: 16),
              _WorkoutHero(snapshot),
              const SizedBox(height: 12),
              _MetricSummaryCard(snapshot.metrics),
              const SizedBox(height: 12),
              _WorkoutBreakdownCard(snapshot.breakdown),
              const SizedBox(height: 12),
              _EffortGuideCard(snapshot.effortGuide),
              const SizedBox(height: 12),
              _CoachNoteCard(snapshot.coachNotes),
              const SizedBox(height: 16),
              _StartRunAction(snapshot.startActionLabel),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoOverscroll extends StatelessWidget {
  const _NoOverscroll({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: child,
    );
  }
}

class _WorkoutDetailHeader extends StatelessWidget {
  const _WorkoutDetailHeader({
    required this.title,
    required this.onBack,
    required this.onEditSchedule,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onEditSchedule;

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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onEditSchedule,
              style: TextButton.styleFrom(
                foregroundColor: RuniacColors.primaryBlue,
                textStyle: _editActionStyle,
              ),
              child: const Text('Edit schedule'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero(this.snapshot);

  final WeeklyWorkoutDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(snapshot.dayLabel, style: _heroLabelStyle),
          const SizedBox(height: 8),
          Text(snapshot.heroTitle, style: _heroTitleStyle),
          const SizedBox(height: 10),
          Text(snapshot.heroCopy, style: _heroCopyStyle),
          const SizedBox(height: 4),
          Text(snapshot.heroSupportCopy, style: _heroCopyStyle),
        ],
      ),
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard(this.metrics);

  final List<WorkoutMetricDisplay> metrics;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            Expanded(
              flex: metrics[index].label == 'Suggested pace' ? 13 : 10,
              child: _MetricTile(metrics[index]),
            ),
            if (index < metrics.length - 1)
              const SizedBox(
                height: 72,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: RuniacColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(this.metric);

  final WorkoutMetricDisplay metric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              metric.label,
              key: metric.label == 'Suggested pace'
                  ? const ValueKey('suggested_pace_metric_label')
                  : null,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: _metricLabel,
            ),
          ),
          const SizedBox(height: 6),
          Text(metric.value, textAlign: TextAlign.center, style: _metricValue),
        ],
      ),
    );
  }
}

class _WorkoutBreakdownCard extends StatelessWidget {
  const _WorkoutBreakdownCard(this.steps);

  final List<WorkoutStepDisplay> steps;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session breakdown', style: _sectionTitleStyle),
          const SizedBox(height: 12),
          for (var index = 0; index < steps.length; index++) ...[
            _WorkoutStepRow(steps[index]),
            if (index < steps.length - 1)
              const Divider(height: 20, color: RuniacColors.border),
          ],
        ],
      ),
    );
  }
}

class _WorkoutStepRow extends StatelessWidget {
  const _WorkoutStepRow(this.step);

  final WorkoutStepDisplay step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: _softIconDecoration,
          child: Icon(step.icon, color: RuniacColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: _bodyStrongStyle),
              const SizedBox(height: 3),
              Text(step.copy, style: _bodyStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _EffortGuideCard extends StatelessWidget {
  const _EffortGuideCard(this.copy);

  final String copy;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Effort guide', style: _sectionTitleStyle),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var index = 0; index < 5; index++) ...[
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: index < 2
                          ? RuniacColors.primaryBlue
                          : const Color(0xFFE8EEF8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                if (index < 4) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(copy, style: _bodyStyle),
        ],
      ),
    );
  }
}

class _CoachNoteCard extends StatelessWidget {
  const _CoachNoteCard(this.notes);

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: RuniacColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Text('R', style: _coachInitialStyle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coach note', style: _sectionTitleStyle),
                  const SizedBox(height: 8),
                  for (final note in notes) ...[
                    Text(note, style: _bodyStyle),
                    if (note != notes.last) const SizedBox(height: 5),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartRunAction extends StatelessWidget {
  const _StartRunAction(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: RuniacColors.accentOrange,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: _startActionStyle),
      ),
    );
  }
}

void _showEditScheduleSheet(
  BuildContext context,
  WeeklyWorkoutDetailSnapshot snapshot,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: RuniacColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => _EditScheduleSheet(snapshot),
  );
}

class _EditScheduleSheet extends StatelessWidget {
  const _EditScheduleSheet(this.snapshot);

  final WeeklyWorkoutDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.86;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: _NoOverscroll(
          key: const ValueKey('edit_schedule_no_overscroll'),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: _EditScheduleDragHandle()),
                  const SizedBox(height: 12),
                  Text('Edit schedule', style: _sheetTitleStyle),
                  const SizedBox(height: 10),
                  const _EditScheduleBrandAccent(),
                  const SizedBox(height: 6),
                  Text(
                    'Preview only — changes are not saved yet.',
                    style: _smallBodyStyle,
                  ),
                  const SizedBox(height: 16),
                  _ScheduleComparisonCard(snapshot),
                  const SizedBox(height: 16),
                  const _AdvancedSchedulePreview(),
                  const SizedBox(height: 16),
                  Text(
                    'You’ll be able to add a reason when schedule changes are enabled.',
                    style: _smallBodyStyle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saving schedule changes will be available later.',
                    style: _smallBodyStyle,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: const Color(0xFFE4E8EF),
                        disabledForegroundColor: RuniacColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: _disabledSaveActionStyle,
                      ),
                      child: const Text('Save New Schedule'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RuniacColors.textPrimary,
                        side: const BorderSide(color: RuniacColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: _closeActionStyle,
                      ),
                      child: const Text('Close'),
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

class _EditScheduleDragHandle extends StatelessWidget {
  const _EditScheduleDragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('edit_schedule_drag_handle'),
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFD7DCE3),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _EditScheduleBrandAccent extends StatelessWidget {
  const _EditScheduleBrandAccent();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('edit_schedule_brand_accent'),
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

class _ScheduleComparisonCard extends StatelessWidget {
  const _ScheduleComparisonCard(this.snapshot);

  final WeeklyWorkoutDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScheduleComparisonItem(
              label: 'Current schedule',
              value: snapshot.editScheduleCurrentLabel,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.arrow_forward_rounded,
            color: RuniacColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ScheduleComparisonItem(
              label: 'Preview example',
              value: snapshot.editSchedulePreviewLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleComparisonItem extends StatelessWidget {
  const _ScheduleComparisonItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _sheetMutedLabelStyle),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, maxLines: 1, style: _bodyStrongStyle),
        ),
      ],
    );
  }
}

class _AdvancedSchedulePreview extends StatelessWidget {
  const _AdvancedSchedulePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Advanced preview', style: _sheetLabelStyle),
          SizedBox(height: 4),
          Text('These options are examples only.', style: _smallBodyStyle),
          SizedBox(height: 12),
          Text('Select day', style: _sheetMutedLabelStyle),
          SizedBox(height: 8),
          _DayPreviewRow(),
          SizedBox(height: 12),
          Text('Select time', style: _sheetMutedLabelStyle),
          SizedBox(height: 8),
          _TimePreviewGrid(),
          SizedBox(height: 12),
          _CustomTimePreviewRow(),
        ],
      ),
    );
  }
}

class _DayPreviewRow extends StatelessWidget {
  const _DayPreviewRow();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _days.length; index++) ...[
          Expanded(child: _PreviewChip(_days[index], compact: true)),
          if (index < _days.length - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

class _TimePreviewGrid extends StatelessWidget {
  const _TimePreviewGrid();

  static const _times = ['07:00 AM', '08:00 AM', '06:30 PM', '07:30 PM'];

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('edit_schedule_time_preview_grid'),
      children: [
        for (var row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (var column = 0; column < 2; column++) ...[
                Expanded(child: _PreviewChip(_times[row * 2 + column])),
                if (column == 0) const SizedBox(width: 8),
              ],
            ],
          ),
          if (row == 0) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip(this.label, {this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 10,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RuniacColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, maxLines: 1, style: _previewChipStyle),
      ),
    );
  }
}

class _CustomTimePreviewRow extends StatelessWidget {
  const _CustomTimePreviewRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: RuniacColors.textSecondary,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(child: Text('Choose custom time', style: _disabledRowStyle)),
          Icon(
            Icons.chevron_right_rounded,
            color: RuniacColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

const _screenTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 20,
  fontWeight: FontWeight.w800,
);

const _editActionStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w800);

const _heroLabelStyle = TextStyle(
  color: RuniacColors.accentOrange,
  fontSize: 12,
  fontWeight: FontWeight.w900,
  letterSpacing: 0,
);

const _heroTitleStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 30,
  fontWeight: FontWeight.w900,
  letterSpacing: 0,
);

const _heroCopyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 15,
  height: 1.35,
  fontWeight: FontWeight.w600,
);

const _sectionTitleStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 18,
  fontWeight: FontWeight.w800,
);

const _bodyStrongStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 14,
  fontWeight: FontWeight.w800,
);

const _bodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 14,
  height: 1.35,
  fontWeight: FontWeight.w600,
);

const _smallBodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 12,
  height: 1.35,
  fontWeight: FontWeight.w600,
);

const _metricLabel = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 10,
  fontWeight: FontWeight.w700,
);

const _metricValue = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 15,
  fontWeight: FontWeight.w900,
);

const _coachInitialStyle = TextStyle(
  color: RuniacColors.white,
  fontSize: 15,
  fontWeight: FontWeight.w900,
);

const _startActionStyle = TextStyle(
  color: RuniacColors.white,
  fontSize: 16,
  fontWeight: FontWeight.w900,
);

const _sheetTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 20,
  fontWeight: FontWeight.w900,
);

const _sheetLabelStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 12,
  fontWeight: FontWeight.w800,
);

const _sheetMutedLabelStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 11,
  fontWeight: FontWeight.w800,
);

const _previewChipStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

const _disabledRowStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 13,
  fontWeight: FontWeight.w800,
);

const _disabledSaveActionStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w900,
);

const _closeActionStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w900);

final _softIconDecoration = BoxDecoration(
  color: const Color(0xFFF7FAFF),
  borderRadius: BorderRadius.circular(999),
  border: Border.all(color: RuniacColors.border),
);
