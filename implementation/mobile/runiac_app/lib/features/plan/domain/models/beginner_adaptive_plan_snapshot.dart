enum BeginnerAdaptivePlanKind { onboardingBased }

enum BeginnerWorkoutKind {
  easyRun,
  runWalk,
  walkRun,
  recoveryWalk,
  restOrMobility,
}

enum BeginnerPlanIntensity { veryGentle, gentle, balanced }

class BeginnerAdaptivePlanSnapshot {
  BeginnerAdaptivePlanSnapshot({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.planKind,
    required this.sourceLabel,
    required this.supportStyleLabel,
    required this.weeklyFrequencyLabel,
    required this.preferredScheduleLabel,
    required this.sessionDurationLabel,
    required this.safetyNote,
    required List<BeginnerAdaptivePlanWeek> weeks,
  }) : weeks = List.unmodifiable(weeks);

  final String id;
  final String title;
  final String subtitle;
  final BeginnerAdaptivePlanKind planKind;
  final String sourceLabel;
  final String supportStyleLabel;
  final String weeklyFrequencyLabel;
  final String preferredScheduleLabel;
  final String sessionDurationLabel;
  final String safetyNote;
  final List<BeginnerAdaptivePlanWeek> weeks;
}

class BeginnerAdaptivePlanWeek {
  BeginnerAdaptivePlanWeek({
    required this.weekNumber,
    required this.title,
    required this.focus,
    required List<BeginnerAdaptiveWorkout> workouts,
  }) : workouts = List.unmodifiable(workouts);

  final int weekNumber;
  final String title;
  final String focus;
  final List<BeginnerAdaptiveWorkout> workouts;
}

class BeginnerAdaptiveWorkout {
  BeginnerAdaptiveWorkout({
    required this.dayLabel,
    required this.title,
    required this.durationMinutes,
    required this.kind,
    required this.intensity,
    required this.description,
    required List<String> steps,
    required this.supportiveNote,
  }) : steps = List.unmodifiable(steps);

  final String dayLabel;
  final String title;
  final int durationMinutes;
  final BeginnerWorkoutKind kind;
  final BeginnerPlanIntensity intensity;
  final String description;
  final List<String> steps;
  final String supportiveNote;
}
