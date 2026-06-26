import 'package:flutter/material.dart';

import '../../../run/presentation/models/planned_run_context.dart';

// Display-only workout previews used by the static You prototype.
const weeklyWorkoutDetailSnapshot = WeeklyWorkoutDetailSnapshot(
  title: 'Workout detail',
  dayLabel: 'Thursday · Easy Run',
  planTitle: '20 min easy run',
  editScheduleCurrentLabel: 'Thu · 7:30 AM',
  editSchedulePreviewLabel: 'Fri · 7:30 AM',
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
  dayLabel: 'Saturday · Easy Run',
  planTitle: '20 min easy run',
  editScheduleCurrentLabel: 'Saturday',
  editSchedulePreviewLabel: 'Preview only',
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
    String? planTitle,
    String? heroTitle,
    required this.editScheduleCurrentLabel,
    required this.editSchedulePreviewLabel,
    String? heroCopy,
    String? heroSupportCopy,
    required this.metrics,
    required this.breakdown,
    required this.effortGuide,
    required this.coachNotes,
    this.startActionLabel,
    this.canEditSchedule = true,
    this.plannedRunContext,
  }) : planTitle = planTitle ?? heroTitle ?? '';

  final String title;
  final String dayLabel;
  final String planTitle;
  final String editScheduleCurrentLabel;
  final String editSchedulePreviewLabel;
  final List<WorkoutMetricDisplay> metrics;
  final List<WorkoutStepDisplay> breakdown;
  final String effortGuide;
  final List<String> coachNotes;
  final String? startActionLabel;
  final bool canEditSchedule;
  final PlannedRunContext? plannedRunContext;
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
