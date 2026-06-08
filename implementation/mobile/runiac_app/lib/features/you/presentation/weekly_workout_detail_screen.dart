import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';

const weeklyWorkoutDetailSnapshot = WeeklyWorkoutDetailSnapshot(
  title: 'Workout detail',
  dayLabel: 'THURSDAY · EASY RUN',
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
                onEditSchedule: () => _showEditScheduleSheet(context),
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
          borderRadius: BorderRadius.circular(8),
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

void _showEditScheduleSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: RuniacColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => const _EditScheduleSheet(),
  );
}

class _EditScheduleSheet extends StatelessWidget {
  const _EditScheduleSheet();

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.72;

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
                  Text('Edit schedule', style: _sheetTitleStyle),
                  const SizedBox(height: 16),
                  Text('Current plan', style: _sheetLabelStyle),
                  const SizedBox(height: 4),
                  Text('Thursday · 7:30 AM', style: _bodyStrongStyle),
                  const SizedBox(height: 18),
                  Text('Suggested options', style: _sheetLabelStyle),
                  const SizedBox(height: 10),
                  const _SchedulePreviewOption('Morning · 7:30 AM'),
                  const SizedBox(height: 8),
                  const _SchedulePreviewOption('Lunch · 12:30 PM'),
                  const SizedBox(height: 8),
                  const _SchedulePreviewOption('Evening · 6:30 PM'),
                  const SizedBox(height: 16),
                  Text(
                    'Preview only. Schedule changes will be connected later through backend-controlled plan updates.',
                    style: _smallBodyStyle,
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

class _SchedulePreviewOption extends StatelessWidget {
  const _SchedulePreviewOption(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Text(label, style: _bodyStrongStyle),
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

final _softIconDecoration = BoxDecoration(
  color: const Color(0xFFF7FAFF),
  borderRadius: BorderRadius.circular(999),
  border: Border.all(color: RuniacColors.border),
);
