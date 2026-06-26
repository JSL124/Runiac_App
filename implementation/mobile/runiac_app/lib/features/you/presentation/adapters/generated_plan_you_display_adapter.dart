import 'package:flutter/material.dart';

import '../../../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../../../plan/presentation/current_session_generated_plan.dart';
import '../data/weekly_workout_demo_snapshots.dart';
import '../data/you_overview_demo_snapshots.dart';

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
  BeginnerAdaptivePlanSnapshot? snapshot,
) {
  if (snapshot == null || !isEligibleCurrentSessionGeneratedPlan(snapshot)) {
    return null;
  }

  final currentWeek = snapshot.weeks.first;
  final runningSessionCount = currentWeek.workouts
      .where(isGeneratedPlanSession)
      .length;

  return GeneratedYouPlanDisplay(
    weeklyTitle: snapshot.title,
    subtitle: snapshot.subtitle,
    progressLabel: '0 of $runningSessionCount done',
    progressValue: 0,
    scheduleRows: [
      for (final workout in currentWeek.workouts)
        YouPlanScheduleRow(
          workout.dayLabel,
          workout.title,
          '${workout.durationMinutes} min',
          _iconForWorkout(workout.kind),
          active: isGeneratedPlanSession(workout),
          opensWorkoutDetail: isGeneratedPlanSession(workout),
          detailSnapshot: isGeneratedPlanSession(workout)
              ? _workoutDetailFor(workout, snapshot)
              : null,
        ),
    ],
  );
}

WeeklyWorkoutDetailSnapshot _workoutDetailFor(
  BeginnerAdaptiveWorkout workout,
  BeginnerAdaptivePlanSnapshot snapshot,
) {
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
    startActionLabel: 'Start This Run',
  );
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
