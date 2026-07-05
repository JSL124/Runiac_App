import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_bottom_sheet_handle.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../../run/presentation/active_run_session_coordinator.dart';
import '../../run/presentation/run_launch_screen.dart';
import 'data/weekly_workout_demo_snapshots.dart';

class WeeklyWorkoutDetailScreen extends StatelessWidget {
  const WeeklyWorkoutDetailScreen({
    required this.onBack,
    this.snapshot = weeklyWorkoutDetailSnapshot,
    this.showEditScheduleAction = true,
    this.enableForegroundGps = true,
    this.onStartRun,
    this.onScheduleChanged,
    this.activeRunSessionCoordinator,
    super.key,
  });

  final VoidCallback onBack;
  final WeeklyWorkoutDetailSnapshot snapshot;
  final bool showEditScheduleAction;
  final bool enableForegroundGps;
  final VoidCallback? onStartRun;
  final ValueChanged<WorkoutScheduleEditSelection>? onScheduleChanged;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;

  Future<void> _openRunLaunch(BuildContext context) async {
    final initialPreviewCurrentPosition =
        await prewarmRunLaunchPreviewCurrentPosition(
          enableForegroundGps: enableForegroundGps,
        );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RunLaunchScreen(
          enableForegroundGps: enableForegroundGps,
          initialPreviewCurrentPosition: initialPreviewCurrentPosition,
          activeRunSessionCoordinator: activeRunSessionCoordinator,
          plannedWorkout: snapshot.plannedRunContext,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startActionLabel = snapshot.startActionLabel;
    return Material(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: RuniacBackHeader(
                title: snapshot.title,
                titleKey: const ValueKey('workout_detail_header_title'),
                titleStyle: _headerTitleStyle,
                titleMaxLines: 2,
                titleOverflow: TextOverflow.visible,
                height: 64,
                tooltip: 'Back to Plans',
                onBack: onBack,
                trailing: showEditScheduleAction && snapshot.canEditSchedule
                    ? IconButton(
                        key: const ValueKey('edit_schedule_icon_action'),
                        tooltip: 'Edit schedule',
                        onPressed: () => _showEditScheduleSheet(
                          context,
                          snapshot,
                          onScheduleChanged,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 44,
                          height: 44,
                        ),
                        icon: const _EditScheduleActionIcon(),
                      )
                    : null,
                trailingWidth: 48,
              ),
            ),
            Expanded(
              child: _NoOverscroll(
                key: const ValueKey('workout_detail_no_overscroll'),
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    _WorkoutPlanIdentity(snapshot),
                    const SizedBox(height: 10),
                    _MetricSummaryCard(snapshot.metrics),
                    const SizedBox(height: 12),
                    _WorkoutBreakdownCard(snapshot.breakdown),
                    const SizedBox(height: 12),
                    _EffortGuideCard(snapshot.effortGuide),
                    const SizedBox(height: 12),
                    _CoachNoteCard(snapshot.coachNotes),
                    if (startActionLabel != null) ...[
                      const SizedBox(height: 16),
                      _StartRunAction(
                        startActionLabel,
                        onTap: onStartRun ?? () => _openRunLaunch(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditScheduleActionIcon extends StatelessWidget {
  const _EditScheduleActionIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 34,
      child: CustomPaint(painter: _EditScheduleActionIconPainter()),
    );
  }
}

class _EditScheduleActionIconPainter extends CustomPainter {
  const _EditScheduleActionIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 34;
    final scaleY = size.height / 34;
    canvas.scale(scaleX, scaleY);

    final framePaint = Paint()
      ..color = const Color(0xFFBDD3F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final framePath = Path()
      ..moveTo(11.2, 7.6)
      ..cubicTo(6.6, 7.6, 4.2, 10.6, 4.2, 14.6)
      ..lineTo(4.2, 25.2)
      ..cubicTo(4.2, 29.1, 7.2, 31.5, 11.2, 31.5)
      ..lineTo(25.4, 31.5)
      ..cubicTo(29.3, 31.5, 31.6, 28.7, 31.6, 24.9)
      ..lineTo(31.6, 20.5);
    canvas.drawPath(framePath, framePaint);

    final pencilPaint = Paint()
      ..color = RuniacColors.primaryBlue
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(13.4, 18.3)
      ..lineTo(23.6, 9.4)
      ..lineTo(28.8, 15.3)
      ..lineTo(18.4, 24.3)
      ..close();
    canvas.drawPath(bodyPath, pencilPaint);

    final capPath = Path()
      ..moveTo(24.7, 8.4)
      ..lineTo(27.3, 6.2)
      ..cubicTo(28.4, 5.2, 30, 5.4, 30.9, 6.5)
      ..lineTo(33.1, 9)
      ..cubicTo(34.1, 10.1, 34, 11.7, 32.9, 12.7)
      ..lineTo(30.2, 15)
      ..close();
    canvas.drawPath(capPath, pencilPaint);

    final tipPath = Path()
      ..moveTo(8.8, 28.3)
      ..lineTo(12.3, 19)
      ..lineTo(17.1, 24.7)
      ..close();
    canvas.drawPath(tipPath, pencilPaint);
  }

  @override
  bool shouldRepaint(covariant _EditScheduleActionIconPainter oldDelegate) {
    return false;
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

class _WorkoutPlanIdentity extends StatelessWidget {
  const _WorkoutPlanIdentity(this.snapshot);

  final WeeklyWorkoutDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_planIdentityLabel(snapshot.dayLabel), style: _heroLabelStyle),
          const SizedBox(height: 6),
          Text(snapshot.planTitle, style: _planTitleStyle),
        ],
      ),
    );
  }
}

String _planIdentityLabel(String label) {
  return switch (label) {
    'THURSDAY · EASY RUN' => 'Thursday · Easy Run',
    'SATURDAY · EASY RUN' => 'Saturday · Easy Run',
    _ => label,
  };
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
  const _StartRunAction(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RuniacColors.accentOrange,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _startActionStyle),
    );
  }
}

void _showEditScheduleSheet(
  BuildContext context,
  WeeklyWorkoutDetailSnapshot snapshot,
  ValueChanged<WorkoutScheduleEditSelection>? onScheduleChanged,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: RuniacColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => _EditScheduleSheet(
      snapshot: snapshot,
      onScheduleChanged: onScheduleChanged,
    ),
  );
}

class _EditScheduleSheet extends StatefulWidget {
  const _EditScheduleSheet({
    required this.snapshot,
    required this.onScheduleChanged,
  });

  final WeeklyWorkoutDetailSnapshot snapshot;
  final ValueChanged<WorkoutScheduleEditSelection>? onScheduleChanged;

  @override
  State<_EditScheduleSheet> createState() => _EditScheduleSheetState();
}

class _EditScheduleSheetState extends State<_EditScheduleSheet> {
  int? _selectedWeekdayIndex;
  String? _selectedDayLabel;
  String? _selectedTimeLabel;

  WeeklyWorkoutDetailSnapshot get snapshot => widget.snapshot;

  bool get _canSave {
    final selectedWeekdayIndex = _selectedWeekdayIndex;
    return selectedWeekdayIndex != null &&
        selectedWeekdayIndex != snapshot.scheduleWeekdayIndex &&
        !snapshot.occupiedScheduleWeekdays.contains(selectedWeekdayIndex) &&
        _selectedTimeLabel != null;
  }

  String get _newScheduleLabel {
    final day = _selectedDayLabel;
    final time = _selectedTimeLabel;
    if (day == null || time == null) {
      return 'Select a day and time';
    }
    return '$day · $time';
  }

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
                  const SizedBox(height: 16),
                  _ScheduleComparisonCard(
                    currentLabel: snapshot.editScheduleCurrentLabel,
                    newLabel: _newScheduleLabel,
                  ),
                  const SizedBox(height: 16),
                  _ScheduleEditorCard(
                    snapshot: snapshot,
                    selectedWeekdayIndex: _selectedWeekdayIndex,
                    selectedTimeLabel: _selectedTimeLabel,
                    onDaySelected: (day) {
                      if (snapshot.occupiedScheduleWeekdays.contains(
                            day.weekdayIndex,
                          ) ||
                          day.weekdayIndex == snapshot.scheduleWeekdayIndex) {
                        return;
                      }
                      setState(() {
                        _selectedWeekdayIndex = day.weekdayIndex;
                        _selectedDayLabel = day.label;
                      });
                    },
                    onTimePickerRequested: _showTimePicker,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _canSave
                        ? 'This change updates the plan shown in this session.'
                        : 'Choose an open day and a time to save this schedule.',
                    style: _smallBodyStyle,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _canSave
                          ? () {
                              widget.onScheduleChanged?.call(
                                WorkoutScheduleEditSelection(
                                  weekdayIndex: _selectedWeekdayIndex!,
                                  dayLabel: _selectedDayLabel!,
                                  timeLabel: _selectedTimeLabel!,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor:
                            RuniacColors.disabledButtonBackground,
                        disabledForegroundColor:
                            RuniacColors.disabledButtonForeground,
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

  Future<void> _showTimePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: RuniacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _TimePickerSheet(
        selectedTimeLabel: _selectedTimeLabel,
        onTimeChanged: (time) {
          if (!mounted) {
            return;
          }
          setState(() => _selectedTimeLabel = time);
        },
      ),
    );
  }
}

class _EditScheduleDragHandle extends StatelessWidget {
  const _EditScheduleDragHandle();

  @override
  Widget build(BuildContext context) {
    return const RuniacBottomSheetHandle(
      key: ValueKey('edit_schedule_drag_handle'),
      width: 44,
      height: 4,
      color: Color(0xFFD7DCE3),
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
  const _ScheduleComparisonCard({
    required this.currentLabel,
    required this.newLabel,
  });

  final String currentLabel;
  final String newLabel;

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
              value: currentLabel,
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
              label: 'New schedule',
              value: newLabel,
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

class _ScheduleEditorCard extends StatelessWidget {
  const _ScheduleEditorCard({
    required this.snapshot,
    required this.selectedWeekdayIndex,
    required this.selectedTimeLabel,
    required this.onDaySelected,
    required this.onTimePickerRequested,
  });

  final WeeklyWorkoutDetailSnapshot snapshot;
  final int? selectedWeekdayIndex;
  final String? selectedTimeLabel;
  final ValueChanged<_ScheduleDayOption> onDaySelected;
  final VoidCallback onTimePickerRequested;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select day', style: _sheetMutedLabelStyle),
          const SizedBox(height: 8),
          _DaySelectionRow(
            snapshot: snapshot,
            selectedWeekdayIndex: selectedWeekdayIndex,
            onDaySelected: onDaySelected,
          ),
          const SizedBox(height: 12),
          const Text('Select time', style: _sheetMutedLabelStyle),
          const SizedBox(height: 8),
          _CustomTimeSelectionRow(
            selectedTimeLabel: selectedTimeLabel,
            onTimePickerRequested: onTimePickerRequested,
          ),
        ],
      ),
    );
  }
}

class _DaySelectionRow extends StatelessWidget {
  const _DaySelectionRow({
    required this.snapshot,
    required this.selectedWeekdayIndex,
    required this.onDaySelected,
  });

  final WeeklyWorkoutDetailSnapshot snapshot;
  final int? selectedWeekdayIndex;
  final ValueChanged<_ScheduleDayOption> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _scheduleDayOptions.length; index++) ...[
          Expanded(
            child: _ScheduleDayChip(
              option: _scheduleDayOptions[index],
              selected:
                  selectedWeekdayIndex ==
                  _scheduleDayOptions[index].weekdayIndex,
              current:
                  snapshot.scheduleWeekdayIndex ==
                  _scheduleDayOptions[index].weekdayIndex,
              disabled: snapshot.occupiedScheduleWeekdays.contains(
                _scheduleDayOptions[index].weekdayIndex,
              ),
              onSelected: onDaySelected,
            ),
          ),
          if (index < _scheduleDayOptions.length - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

class _ScheduleDayChip extends StatelessWidget {
  const _ScheduleDayChip({
    required this.option,
    required this.selected,
    required this.current,
    required this.disabled,
    required this.onSelected,
  });

  final _ScheduleDayOption option;
  final bool selected;
  final bool current;
  final bool disabled;
  final ValueChanged<_ScheduleDayOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = disabled
        ? RuniacColors.textSecondary.withValues(alpha: 0.48)
        : selected
        ? RuniacColors.white
        : RuniacColors.textPrimary;
    final backgroundColor = selected
        ? RuniacColors.primaryBlue
        : disabled
        ? const Color(0xFFEFF3F8)
        : RuniacColors.white;

    return Semantics(
      key: ValueKey('edit_schedule_day_${option.label}'),
      button: true,
      enabled: !disabled,
      selected: selected || current,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: disabled ? null : () => onSelected(option),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? RuniacColors.primaryBlue
                    : RuniacColors.border,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                option.label,
                maxLines: 1,
                style: _previewChipStyle.copyWith(color: foregroundColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTimeSelectionRow extends StatelessWidget {
  const _CustomTimeSelectionRow({
    required this.selectedTimeLabel,
    required this.onTimePickerRequested,
  });

  final String? selectedTimeLabel;
  final VoidCallback onTimePickerRequested;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('edit_schedule_time_selector'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTimePickerRequested,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF3F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: RuniacColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedTimeLabel ?? 'Choose time',
                  style: _disabledRowStyle,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RuniacColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({
    required this.selectedTimeLabel,
    required this.onTimeChanged,
  });

  final String? selectedTimeLabel;
  final ValueChanged<String> onTimeChanged;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  static const _hours = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  static const _periods = ['AM', 'PM'];
  static const _itemExtent = 38.0;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _periodController;
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    final initialTime = _WheelTimeSelection.fromLabel(widget.selectedTimeLabel);
    _selectedHour = initialTime.hour;
    _selectedMinute = initialTime.minute;
    _selectedPeriod = initialTime.period;
    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
    _periodController = FixedExtentScrollController(
      initialItem: _periods.indexOf(_selectedPeriod),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onTimeChanged(_formattedSelection);
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  String get _formattedSelection {
    final minute = _selectedMinute.toString().padLeft(2, '0');
    return '$_selectedHour:$minute $_selectedPeriod';
  }

  void _notifySelectionChanged() {
    widget.onTimeChanged(_formattedSelection);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.62,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _EditScheduleDragHandle()),
                const SizedBox(height: 12),
                Text('Select time', style: _sheetTitleStyle),
                const SizedBox(height: 12),
                SizedBox(
                  key: const ValueKey('edit_schedule_time_wheel_picker'),
                  height: 196,
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeWheelPicker(
                          key: const ValueKey('edit_schedule_time_hour_picker'),
                          controller: _hourController,
                          itemExtent: _itemExtent,
                          children: [
                            for (final hour in _hours)
                              Center(
                                child: Text(
                                  hour.toString(),
                                  style: _timeWheelTextStyle,
                                ),
                              ),
                          ],
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedHour = _hours[index]);
                            _notifySelectionChanged();
                          },
                        ),
                      ),
                      Expanded(
                        child: _TimeWheelPicker(
                          key: const ValueKey(
                            'edit_schedule_time_minute_picker',
                          ),
                          controller: _minuteController,
                          itemExtent: _itemExtent,
                          children: [
                            for (var minute = 0; minute < 60; minute++)
                              Center(
                                child: Text(
                                  minute.toString().padLeft(2, '0'),
                                  style: _timeWheelTextStyle,
                                ),
                              ),
                          ],
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedMinute = index);
                            _notifySelectionChanged();
                          },
                        ),
                      ),
                      Expanded(
                        child: _TimeWheelPicker(
                          key: const ValueKey(
                            'edit_schedule_time_period_picker',
                          ),
                          controller: _periodController,
                          itemExtent: _itemExtent,
                          children: [
                            for (final period in _periods)
                              Center(
                                child: Text(period, style: _timeWheelTextStyle),
                              ),
                          ],
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedPeriod = _periods[index]);
                            _notifySelectionChanged();
                          },
                        ),
                      ),
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

class _TimeWheelPicker extends StatelessWidget {
  const _TimeWheelPicker({
    required this.controller,
    required this.itemExtent,
    required this.children,
    required this.onSelectedItemChanged,
    super.key,
  });

  final FixedExtentScrollController controller;
  final double itemExtent;
  final List<Widget> children;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: itemExtent,
      magnification: 1.08,
      squeeze: 1.08,
      useMagnifier: true,
      selectionOverlay: const _TimePickerSelectionOverlay(),
      onSelectedItemChanged: onSelectedItemChanged,
      children: children,
    );
  }
}

class _TimePickerSelectionOverlay extends StatelessWidget {
  const _TimePickerSelectionOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Container(height: 1, color: RuniacColors.border),
          const Spacer(),
          Container(height: 1, color: RuniacColors.border),
        ],
      ),
    );
  }
}

class _WheelTimeSelection {
  const _WheelTimeSelection({
    required this.hour,
    required this.minute,
    required this.period,
  });

  factory _WheelTimeSelection.fromLabel(String? label) {
    if (label == null) {
      return const _WheelTimeSelection(hour: 7, minute: 0, period: 'PM');
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$').firstMatch(label);
    if (match == null) {
      return const _WheelTimeSelection(hour: 7, minute: 0, period: 'PM');
    }
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    final period = match.group(3)!;
    if (hour == null ||
        hour < 1 ||
        hour > 12 ||
        minute == null ||
        minute > 59) {
      return const _WheelTimeSelection(hour: 7, minute: 0, period: 'PM');
    }
    return _WheelTimeSelection(hour: hour, minute: minute, period: period);
  }

  final int hour;
  final int minute;
  final String period;
}

class _ScheduleDayOption {
  const _ScheduleDayOption(this.label, this.weekdayIndex);

  final String label;
  final int weekdayIndex;
}

const _scheduleDayOptions = [
  _ScheduleDayOption('Mon', DateTime.monday),
  _ScheduleDayOption('Tue', DateTime.tuesday),
  _ScheduleDayOption('Wed', DateTime.wednesday),
  _ScheduleDayOption('Thu', DateTime.thursday),
  _ScheduleDayOption('Fri', DateTime.friday),
  _ScheduleDayOption('Sat', DateTime.saturday),
  _ScheduleDayOption('Sun', DateTime.sunday),
];

const _headerTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 20,
  fontWeight: FontWeight.w800,
);

const _heroLabelStyle = TextStyle(
  color: RuniacColors.accentOrange,
  fontSize: 12,
  fontWeight: FontWeight.w900,
  letterSpacing: 0,
);

const _planTitleStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 26,
  fontWeight: FontWeight.w900,
  letterSpacing: 0,
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

const _timeWheelTextStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 24,
  fontWeight: FontWeight.w500,
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
