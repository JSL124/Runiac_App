import '../../../onboarding/domain/models/local_onboarding_draft.dart';
import '../models/beginner_adaptive_plan_snapshot.dart';
import 'beginner_adaptive_plan_copy.dart';

class BeginnerAdaptivePlanGenerator {
  const BeginnerAdaptivePlanGenerator();

  BeginnerAdaptivePlanSnapshot generate(LocalOnboardingDraft draft) {
    final intensity = _intensityFor(draft);
    final sessionCount = _sessionCountFor(draft);
    final durationMinutes = _durationFor(draft, intensity);
    final dayLabels = _dayLabelsFor(draft, sessionCount);
    final workouts = <BeginnerAdaptiveWorkout>[
      for (var index = 0; index < sessionCount; index++)
        _workoutFor(
          draft: draft,
          dayLabel: dayLabels[index],
          sessionIndex: index,
          durationMinutes: durationMinutes,
          intensity: intensity,
        ),
    ];

    return BeginnerAdaptivePlanSnapshot(
      id: 'local-onboarding-beginner-plan',
      title: BeginnerAdaptivePlanCopy.titleFor(draft, intensity),
      subtitle: BeginnerAdaptivePlanCopy.subtitleFor(
        draft,
        durationMinutes,
        sessionCount,
      ),
      planKind: BeginnerAdaptivePlanKind.onboardingBased,
      sourceLabel: 'Onboarding based',
      supportStyleLabel: BeginnerAdaptivePlanCopy.supportStyleFor(draft),
      weeklyFrequencyLabel: '$sessionCount sessions / week',
      preferredScheduleLabel: dayLabels.join(' · '),
      sessionDurationLabel: BeginnerAdaptivePlanCopy.durationLabelFor(
        draft,
        durationMinutes,
      ),
      safetyNote: BeginnerAdaptivePlanCopy.safetyNoteFor(draft),
      weeks: [
        BeginnerAdaptivePlanWeek(
          weekNumber: 1,
          title: 'Week 1',
          focus: BeginnerAdaptivePlanCopy.focusFor(intensity),
          workouts: workouts,
        ),
      ],
    );
  }

  BeginnerPlanIntensity _intensityFor(LocalOnboardingDraft draft) {
    if (draft.planCautiousness == OnboardingPlanCautiousness.veryGentle ||
        draft.activitySymptoms.isEmpty ||
        draft.healthComfort != OnboardingHealthComfort.ready ||
        draft.activitySymptoms.any(
          (symptom) => symptom != OnboardingActivitySymptom.none,
        )) {
      return BeginnerPlanIntensity.veryGentle;
    }

    if (draft.planCautiousness == OnboardingPlanCautiousness.unsure ||
        draft.experience == OnboardingExperience.newRunner ||
        draft.experience == OnboardingExperience.walk) {
      return BeginnerPlanIntensity.gentle;
    }

    return switch (draft.planCautiousness) {
      OnboardingPlanCautiousness.standard => BeginnerPlanIntensity.balanced,
      OnboardingPlanCautiousness.balanced => BeginnerPlanIntensity.balanced,
      OnboardingPlanCautiousness.veryGentle => BeginnerPlanIntensity.veryGentle,
      OnboardingPlanCautiousness.unsure => BeginnerPlanIntensity.gentle,
    };
  }

  int _sessionCountFor(LocalOnboardingDraft draft) {
    if (draft.availability == OnboardingAvailability.unsure) {
      return 2;
    }

    if (draft.availability == OnboardingAvailability.four &&
        !_readyForFourSessions(draft)) {
      return 3;
    }

    return draft.requestedWeeklySessionCount;
  }

  bool _readyForFourSessions(LocalOnboardingDraft draft) {
    final experiencedEnough =
        draft.experience == OnboardingExperience.run10 ||
        draft.experience == OnboardingExperience.run30 ||
        draft.experience == OnboardingExperience.intervals;
    return experiencedEnough && !draft.hasCautionIntent;
  }

  int _durationFor(
    LocalOnboardingDraft draft,
    BeginnerPlanIntensity intensity,
  ) {
    final preferred = draft.preferredDurationMinutes;
    final cap = switch (intensity) {
      BeginnerPlanIntensity.veryGentle => 20,
      BeginnerPlanIntensity.gentle => 30,
      BeginnerPlanIntensity.balanced => 45,
    };
    if (draft.sessionLength == OnboardingSessionLength.unsure) {
      return 15;
    }
    return preferred > cap ? cap : preferred;
  }

  List<String> _dayLabelsFor(LocalOnboardingDraft draft, int sessionCount) {
    if (draft.preferredDays.isEmpty) {
      return [
        for (var index = 0; index < sessionCount; index++) 'Day ${index + 1}',
      ];
    }

    return [
      for (var index = 0; index < sessionCount; index++)
        draft.preferredDays[index % draft.preferredDays.length].value,
    ];
  }

  BeginnerAdaptiveWorkout _workoutFor({
    required LocalOnboardingDraft draft,
    required String dayLabel,
    required int sessionIndex,
    required int durationMinutes,
    required BeginnerPlanIntensity intensity,
  }) {
    final kind = _workoutKindFor(draft, sessionIndex, intensity);
    final title = BeginnerAdaptivePlanCopy.workoutTitleFor(kind);
    final runMinutes = _mainEffortMinutes(durationMinutes, intensity, kind);

    return BeginnerAdaptiveWorkout(
      dayLabel: dayLabel,
      title: title,
      durationMinutes: durationMinutes,
      kind: kind,
      intensity: intensity,
      description: BeginnerAdaptivePlanCopy.descriptionFor(draft, kind),
      steps: _stepsFor(kind, durationMinutes, runMinutes),
      supportiveNote: BeginnerAdaptivePlanCopy.supportiveNoteFor(
        draft,
        intensity,
      ),
    );
  }

  BeginnerWorkoutKind _workoutKindFor(
    LocalOnboardingDraft draft,
    int sessionIndex,
    BeginnerPlanIntensity intensity,
  ) {
    if (sessionIndex == 3) {
      return BeginnerWorkoutKind.recoveryWalk;
    }

    if (intensity == BeginnerPlanIntensity.veryGentle) {
      return sessionIndex.isEven
          ? BeginnerWorkoutKind.walkRun
          : BeginnerWorkoutKind.recoveryWalk;
    }

    if (draft.experience == OnboardingExperience.newRunner ||
        draft.experience == OnboardingExperience.walk) {
      return BeginnerWorkoutKind.walkRun;
    }

    if (draft.experience == OnboardingExperience.intervals) {
      return BeginnerWorkoutKind.runWalk;
    }

    if (sessionIndex == 2 && intensity == BeginnerPlanIntensity.gentle) {
      return BeginnerWorkoutKind.recoveryWalk;
    }

    return intensity == BeginnerPlanIntensity.balanced
        ? BeginnerWorkoutKind.easyRun
        : BeginnerWorkoutKind.runWalk;
  }

  int _mainEffortMinutes(
    int durationMinutes,
    BeginnerPlanIntensity intensity,
    BeginnerWorkoutKind kind,
  ) {
    if (kind == BeginnerWorkoutKind.recoveryWalk) {
      return durationMinutes - 5;
    }

    final warmAndCool = intensity == BeginnerPlanIntensity.veryGentle ? 8 : 6;
    return durationMinutes - warmAndCool;
  }

  List<String> _stepsFor(
    BeginnerWorkoutKind kind,
    int durationMinutes,
    int mainEffortMinutes,
  ) {
    return switch (kind) {
      BeginnerWorkoutKind.recoveryWalk => [
        'Easy walk · $mainEffortMinutes min',
        'Slow finish · 5 min',
      ],
      BeginnerWorkoutKind.walkRun => [
        'Warm-up walk · 5 min',
        'Short walk-run repeats · $mainEffortMinutes min',
        'Cool-down walk · ${durationMinutes - mainEffortMinutes - 5} min',
      ],
      BeginnerWorkoutKind.runWalk => [
        'Warm-up walk · 4 min',
        'Easy run-walk repeats · $mainEffortMinutes min',
        'Cool-down walk · ${durationMinutes - mainEffortMinutes - 4} min',
      ],
      BeginnerWorkoutKind.easyRun => [
        'Warm-up walk · 4 min',
        'Easy run · $mainEffortMinutes min',
        'Cool-down walk · ${durationMinutes - mainEffortMinutes - 4} min',
      ],
      BeginnerWorkoutKind.restOrMobility => const ['Rest or light mobility'],
    };
  }
}
