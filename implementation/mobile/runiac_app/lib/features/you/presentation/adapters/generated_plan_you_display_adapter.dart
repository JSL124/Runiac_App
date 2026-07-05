import 'package:flutter/material.dart';

import '../../../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../../../plan/domain/models/plan_family.dart';
import '../../../run/presentation/models/planned_run_context.dart';
import '../../../plan/presentation/current_session_generated_plan.dart';
import '../data/goal_plan_demo_snapshots.dart';
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
const _generatedPlanFallbackTime = '7:30 AM';

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

class SafetyReadinessYouPlanDisplay {
  const SafetyReadinessYouPlanDisplay({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.readinessRows,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final List<SafetyReadinessYouPlanRow> readinessRows;
}

class SafetyReadinessYouPlanRow {
  const SafetyReadinessYouPlanRow({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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

SafetyReadinessYouPlanDisplay? safetyReadinessYouPlanDisplayFromSnapshot(
  BeginnerAdaptivePlanSnapshot? snapshot,
) {
  if (snapshot == null || !snapshot.isSafetyReadinessDisplay) {
    return null;
  }

  return SafetyReadinessYouPlanDisplay(
    title: snapshot.title,
    subtitle: snapshot.subtitle,
    statusLabel: 'Read-only safety display',
    readinessRows: const [
      SafetyReadinessYouPlanRow(
        title: 'Review answers',
        subtitle:
            'Check the onboarding health and symptom answers stored for this session.',
        icon: Icons.fact_check_outlined,
      ),
      SafetyReadinessYouPlanRow(
        title: 'Update answers',
        subtitle: 'Change any answer that is incomplete or no longer accurate.',
        icon: Icons.edit_note_outlined,
      ),
      SafetyReadinessYouPlanRow(
        title: 'Read non-prescriptive safety information',
        subtitle:
            'Use general safety information that avoids workout instructions.',
        icon: Icons.menu_book_outlined,
      ),
      SafetyReadinessYouPlanRow(
        title: 'Seek qualified professional guidance',
        subtitle:
            'Ask a qualified professional before choosing a running plan.',
        icon: Icons.health_and_safety_outlined,
      ),
    ],
  );
}

GoalPlanDisplaySnapshot? generatedGoalPlanDisplayFromSnapshot(
  BeginnerAdaptivePlanSnapshot? snapshot, {
  DateTime? currentDate,
}) {
  if (snapshot == null || !isEligibleCurrentSessionGeneratedPlan(snapshot)) {
    return null;
  }

  final currentWeekdayIndex = (currentDate ?? DateTime.now()).weekday;
  return GoalPlanDisplaySnapshot(
    title: snapshot.title,
    planName: snapshot.title,
    weekSummary:
        '${snapshot.durationWeeks} weeks · ${snapshot.weeklyFrequencyLabel}',
    progressValue: 0,
    progressPercentLabel: '',
    progressLabel: 'Generated onboarding plan',
    currentPhaseLabel: 'Preferred days',
    currentPhase: snapshot.preferredScheduleLabel,
    showProgress: false,
    weeks: [
      for (final week in snapshot.weeks)
        GoalPlanWeekDisplaySnapshot(
          weekLabel: 'Week ${week.weekNumber}',
          title: week.title,
          status: _goalPlanWeekStatusFor(week, snapshot.weeks.length),
          dailyPlan: _goalPlanDailyRowsFor(
            week,
            snapshot,
            currentWeekdayIndex: currentWeekdayIndex,
          ),
        ),
    ],
  );
}

GoalPlanWeekStatus _goalPlanWeekStatusFor(
  BeginnerAdaptivePlanWeek week,
  int totalWeeks,
) {
  if (week.weekNumber == 1) {
    return GoalPlanWeekStatus.current;
  }
  if (week.weekNumber == totalWeeks) {
    return GoalPlanWeekStatus.goalWeek;
  }
  return GoalPlanWeekStatus.upcoming;
}

List<GoalPlanDayDisplaySnapshot> _goalPlanDailyRowsFor(
  BeginnerAdaptivePlanWeek week,
  BeginnerAdaptivePlanSnapshot snapshot, {
  required int currentWeekdayIndex,
}) {
  final workoutsByDay = {
    for (final workout in week.workouts) workout.dayLabel: workout,
  };

  return [
    for (final dayLabel in _weeklyDisplayDayLabels)
      _goalPlanDailyRowFor(
        dayLabel,
        workoutsByDay[dayLabel],
        week,
        snapshot,
        currentWeekdayIndex: currentWeekdayIndex,
      ),
  ];
}

GoalPlanDayDisplaySnapshot _goalPlanDailyRowFor(
  String dayLabel,
  BeginnerAdaptiveWorkout? workout,
  BeginnerAdaptivePlanWeek week,
  BeginnerAdaptivePlanSnapshot snapshot, {
  required int currentWeekdayIndex,
}) {
  if (workout == null || !isGeneratedPlanSession(workout)) {
    return GoalPlanDayDisplaySnapshot(
      weekday: _fullWeekdayLabelFor(dayLabel),
      workoutType: 'Rest Day',
      distanceOrTime: 'Recovery',
    );
  }

  final weekdayIndex = _weekdayIndexFor(dayLabel);
  final isCurrentWeekToday =
      week.weekNumber == 1 && weekdayIndex == currentWeekdayIndex;
  return GoalPlanDayDisplaySnapshot(
    weekday: _fullWeekdayLabelFor(dayLabel),
    workoutType: workout.title,
    distanceOrTime: '${workout.durationMinutes} min',
    workoutDetail: _workoutDetailFor(
      workout,
      snapshot,
      canStart: isCurrentWeekToday,
      canEditSchedule: !isCurrentWeekToday,
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
    '${workout.durationMinutes} min ${workout.title}',
    'Upcoming · $_generatedPlanFallbackTime',
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
    'Rest Day',
    '',
    Icons.hotel_outlined,
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
  final canStartPlannedRun = canStart && snapshot.canStartPlannedRun;
  final canEditGeneratedSchedule =
      canEditSchedule && snapshot.canStartPlannedRun;

  return WeeklyWorkoutDetailSnapshot(
    title: 'Workout detail',
    dayLabel: '${workout.dayLabel} · ${workout.title}',
    planTitle: snapshot.title,
    editScheduleCurrentLabel: workout.dayLabel,
    editSchedulePreviewLabel: 'Preview only',
    metrics: [
      for (final metric in workout.detail.metrics)
        WorkoutMetricDisplay(metric.label, metric.value),
    ],
    breakdown: [
      for (final step in workout.detail.breakdown) _stepDisplayFor(step),
    ],
    effortGuide: workout.detail.effortGuide,
    coachNotes: [...workout.detail.coachNotes, snapshot.safetyNote],
    startActionLabel: canStartPlannedRun ? 'Start this run' : null,
    canEditSchedule: canEditGeneratedSchedule,
    plannedRunContext: canStartPlannedRun
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

String _fullWeekdayLabelFor(String dayLabel) {
  return switch (dayLabel) {
    'Mon' => 'Monday',
    'Tue' => 'Tuesday',
    'Wed' => 'Wednesday',
    'Thu' => 'Thursday',
    'Fri' => 'Friday',
    'Sat' => 'Saturday',
    'Sun' => 'Sunday',
    _ => dayLabel,
  };
}

WorkoutStepDisplay _stepDisplayFor(BeginnerAdaptiveWorkoutBreakdownStep step) {
  return WorkoutStepDisplay(_iconForStep(step.kind), step.title, step.detail);
}

IconData _iconForStep(BeginnerAdaptiveWorkoutBreakdownStepKind kind) {
  return switch (kind) {
    BeginnerAdaptiveWorkoutBreakdownStepKind.walk => Icons.directions_walk,
    BeginnerAdaptiveWorkoutBreakdownStepKind.run => Icons.directions_run,
    BeginnerAdaptiveWorkoutBreakdownStepKind.mobility => Icons.self_improvement,
  };
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
