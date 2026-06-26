import 'package:flutter/material.dart';

import '../../../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../../../plan/domain/models/plan_family.dart';
import '../../../run/presentation/models/planned_run_context.dart';
import '../../../plan/presentation/current_session_generated_plan.dart';
import '../data/weekly_workout_demo_snapshots.dart';
import '../data/you_overview_demo_snapshots.dart';

const _weeklyDisplayDayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

class GeneratedYouPlanDisplay {
  const GeneratedYouPlanDisplay({
    required this.weeklyTitle,
    required this.subtitle,
    required this.progressLabel,
    required this.progressValue,
    required this.scheduleRows,
  });

  final String weeklyTitle;
  final String subtitle;
  final String progressLabel;
  final double progressValue;
  final List<YouPlanScheduleRow> scheduleRows;
}

GeneratedYouPlanDisplay? generatedYouPlanDisplayFromSnapshot(
  BeginnerAdaptivePlanSnapshot? snapshot, {
  DateTime? currentDate,
}) {
  if (snapshot == null || !isEligibleCurrentSessionGeneratedPlan(snapshot)) {
    return null;
  }

  final currentWeek = snapshot.weeks.first;
  final currentWeekdayIndex = (currentDate ?? DateTime.now()).weekday;
  final runningSessionCount = currentWeek.workouts
      .where(isGeneratedPlanSession)
      .length;

  return GeneratedYouPlanDisplay(
    weeklyTitle: snapshot.title,
    subtitle: snapshot.subtitle,
    progressLabel: '0 of $runningSessionCount done',
    progressValue: 0,
    scheduleRows: _weeklyScheduleRowsFor(
      currentWeek,
      snapshot,
      currentWeekdayIndex,
    ),
  );
}

List<YouPlanScheduleRow> _weeklyScheduleRowsFor(
  BeginnerAdaptivePlanWeek currentWeek,
  BeginnerAdaptivePlanSnapshot snapshot,
  int currentWeekdayIndex,
) {
  final workoutsByDay = {
    for (final workout in currentWeek.workouts) workout.dayLabel: workout,
  };

  return [
    for (final dayLabel in _weeklyDisplayDayLabels)
      _scheduleRowForDay(
        dayLabel,
        workoutsByDay[dayLabel],
        snapshot,
        currentWeekdayIndex,
      ),
  ];
}

YouPlanScheduleRow _scheduleRowForDay(
  String dayLabel,
  BeginnerAdaptiveWorkout? workout,
  BeginnerAdaptivePlanSnapshot snapshot,
  int currentWeekdayIndex,
) {
  final weekdayIndex = _weekdayIndexFor(dayLabel);
  final isToday = weekdayIndex == currentWeekdayIndex;
  final isPast = weekdayIndex < currentWeekdayIndex;
  final isFuture = weekdayIndex > currentWeekdayIndex;

  if (workout == null || !isGeneratedPlanSession(workout)) {
    return _restRow(
      dayLabel,
      weekdayIndex: weekdayIndex,
      isToday: isToday,
      isPast: isPast,
      isFuture: isFuture,
    );
  }

  final canStart = isToday;
  final canEditSchedule = !isToday;
  return YouPlanScheduleRow(
    dayLabel,
    workout.title,
    '${workout.durationMinutes} min',
    _iconForWorkout(workout.kind),
    active: true,
    opensWorkoutDetail: true,
    detailSnapshot: _workoutDetailFor(
      workout,
      snapshot,
      canStart: canStart,
      canEditSchedule: canEditSchedule,
    ),
    weekdayIndex: weekdayIndex,
    isToday: isToday,
    isPast: isPast,
    isFuture: isFuture,
    isRunningSession: true,
    canOpenDetail: true,
    canStart: canStart,
    canEditSchedule: canEditSchedule,
  );
}

YouPlanScheduleRow _restRow(
  String dayLabel, {
  required int weekdayIndex,
  required bool isToday,
  required bool isPast,
  required bool isFuture,
}) {
  return YouPlanScheduleRow(
    dayLabel,
    'Rest',
    'Recovery day',
    Icons.self_improvement,
    weekdayIndex: weekdayIndex,
    isToday: isToday,
    isPast: isPast,
    isFuture: isFuture,
  );
}

WeeklyWorkoutDetailSnapshot _workoutDetailFor(
  BeginnerAdaptiveWorkout workout,
  BeginnerAdaptivePlanSnapshot snapshot, {
  required bool canStart,
  required bool canEditSchedule,
}) {
  return WeeklyWorkoutDetailSnapshot(
    title: 'Workout detail',
    dayLabel: '${workout.dayLabel} · ${workout.title}',
    planTitle: snapshot.title,
    editScheduleCurrentLabel: workout.dayLabel,
    editSchedulePreviewLabel: 'Preview only',
    metrics: [
      WorkoutMetricDisplay('Duration', '${workout.durationMinutes} min'),
      WorkoutMetricDisplay('Type', _kindLabel(workout.kind)),
      WorkoutMetricDisplay('Effort', _intensityLabel(workout.intensity)),
      const WorkoutMetricDisplay('Source', 'Generated'),
    ],
    breakdown: [
      for (final step in workout.steps) _stepDisplayFor(step, workout.kind),
    ],
    effortGuide: workout.description,
    coachNotes: [workout.supportiveNote, snapshot.safetyNote],
    startActionLabel: canStart ? 'Start this run' : null,
    canEditSchedule: canEditSchedule,
    plannedRunContext: canStart
        ? _plannedRunContextFor(workout, snapshot)
        : null,
  );
}

PlannedRunContext _plannedRunContextFor(
  BeginnerAdaptiveWorkout workout,
  BeginnerAdaptivePlanSnapshot snapshot,
) {
  return PlannedRunContext(
    title: workout.title,
    durationMinutes: workout.durationMinutes,
    planTitle: snapshot.title,
    planFamilyLabel: snapshot.family?.title ?? snapshot.sourceLabel,
    workoutKindLabel: _kindLabel(workout.kind),
    intensityLabel: _intensityLabel(workout.intensity),
    steps: workout.steps,
    supportiveNote: workout.supportiveNote,
    sourceLabel: 'Generated onboarding plan',
  );
}

int _weekdayIndexFor(String dayLabel) {
  final index = _weeklyDisplayDayLabels.indexOf(dayLabel);
  if (index == -1) {
    return 0;
  }
  return index + DateTime.monday;
}

WorkoutStepDisplay _stepDisplayFor(String step, BeginnerWorkoutKind kind) {
  final parts = step.split(' · ');
  return WorkoutStepDisplay(
    _iconForStep(parts.first, kind),
    parts.first,
    parts.length > 1 ? parts.sublist(1).join(' · ') : step,
  );
}

IconData _iconForStep(String title, BeginnerWorkoutKind kind) {
  final normalized = title.toLowerCase();
  if (normalized.contains('warm') || normalized.contains('walk')) {
    return Icons.directions_walk;
  }
  if (normalized.contains('cool') || normalized.contains('mobility')) {
    return Icons.self_improvement;
  }
  return _iconForWorkout(kind);
}

IconData _iconForWorkout(BeginnerWorkoutKind kind) {
  return switch (kind) {
    BeginnerWorkoutKind.recoveryWalk => Icons.directions_walk,
    BeginnerWorkoutKind.restOrMobility => Icons.self_improvement,
    _ => Icons.directions_run,
  };
}

String _kindLabel(BeginnerWorkoutKind kind) {
  return switch (kind) {
    BeginnerWorkoutKind.easyRun => 'Easy run',
    BeginnerWorkoutKind.runWalk => 'Run-walk',
    BeginnerWorkoutKind.walkRun => 'Walk-run',
    BeginnerWorkoutKind.recoveryWalk => 'Recovery walk',
    BeginnerWorkoutKind.steadyRun => 'Steady run',
    BeginnerWorkoutKind.controlledSteadyRun => 'Controlled steady run',
    BeginnerWorkoutKind.longerEasyRun => 'Longer easy run',
    BeginnerWorkoutKind.recoveryRun => 'Recovery run',
    BeginnerWorkoutKind.restOrMobility => 'Rest or mobility',
  };
}

String _intensityLabel(BeginnerPlanIntensity intensity) {
  return switch (intensity) {
    BeginnerPlanIntensity.veryGentle => 'Very gentle',
    BeginnerPlanIntensity.gentle => 'Gentle',
    BeginnerPlanIntensity.balanced => 'Balanced',
  };
}
