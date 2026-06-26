import '../../../onboarding/domain/models/local_onboarding_draft.dart';
import '../models/beginner_adaptive_plan_snapshot.dart';
import 'beginner_adaptive_plan_copy.dart';
import 'beginner_plan_policy_resolver.dart';

class BeginnerAdaptivePlanGenerator {
  const BeginnerAdaptivePlanGenerator([
    this._policyResolver = const BeginnerPlanPolicyResolver(),
  ]);

  final BeginnerPlanPolicyResolver _policyResolver;

  BeginnerAdaptivePlanSnapshot generate(LocalOnboardingDraft draft) {
    final policy = _policyResolver.resolve(draft);
    final weekOneDurations = [
      for (var index = 0; index < policy.requiredSessions; index++)
        policy.durationFor(
          weekNumber: 1,
          isLastSession: index == policy.requiredSessions - 1,
        ),
    ];

    return BeginnerAdaptivePlanSnapshot(
      id: 'local-onboarding-beginner-plan',
      title: BeginnerAdaptivePlanCopy.titleFor(
        draft,
        policy.profile.templateKind,
      ),
      subtitle: BeginnerAdaptivePlanCopy.subtitleFor(draft, policy),
      planKind: BeginnerAdaptivePlanKind.onboardingBased,
      sourceLabel: 'Onboarding based',
      durationWeeks: policy.durationWeeks,
      safetyBand: policy.profile.safetyBand,
      templateKind: policy.profile.templateKind,
      supportStyleLabel: BeginnerAdaptivePlanCopy.supportStyleFor(draft),
      weeklyFrequencyLabel: '${policy.requiredSessions} sessions / week',
      preferredScheduleLabel: _dayLabelsFor(policy).join(' · '),
      sessionDurationLabel: BeginnerAdaptivePlanCopy.durationLabelFor(
        weekOneDurations,
      ),
      safetyNote: BeginnerAdaptivePlanCopy.safetyNoteFor(
        policy.profile.safetyBand,
      ),
      weeks: [
        for (
          var weekNumber = 1;
          weekNumber <= policy.durationWeeks;
          weekNumber++
        )
          _weekFor(draft: draft, policy: policy, weekNumber: weekNumber),
      ],
    );
  }

  BeginnerAdaptivePlanWeek _weekFor({
    required LocalOnboardingDraft draft,
    required BeginnerPlanPolicy policy,
    required int weekNumber,
  }) {
    final dayLabels = _dayLabelsFor(policy);
    final workouts = <BeginnerAdaptiveWorkout>[
      for (var index = 0; index < policy.requiredSessions; index++)
        _workoutFor(
          draft: draft,
          policy: policy,
          dayLabel: dayLabels[index],
          sessionIndex: index,
          weekNumber: weekNumber,
        ),
    ];

    return BeginnerAdaptivePlanWeek(
      weekNumber: weekNumber,
      title: 'Week $weekNumber',
      focus: BeginnerAdaptivePlanCopy.focusFor(
        policy.profile.templateKind,
        weekNumber,
      ),
      workouts: workouts,
    );
  }

  List<String> _dayLabelsFor(BeginnerPlanPolicy policy) {
    if (policy.selectedDays.isEmpty) {
      return [
        for (var index = 0; index < policy.requiredSessions; index++)
          'Day ${index + 1}',
      ];
    }

    return [
      for (var index = 0; index < policy.requiredSessions; index++)
        policy.selectedDays[index % policy.selectedDays.length].value,
    ];
  }

  BeginnerAdaptiveWorkout _workoutFor({
    required LocalOnboardingDraft draft,
    required BeginnerPlanPolicy policy,
    required String dayLabel,
    required int sessionIndex,
    required int weekNumber,
  }) {
    final isLastSession = sessionIndex == policy.requiredSessions - 1;
    final kind = _workoutKindFor(policy, sessionIndex);
    final durationMinutes = policy.durationFor(
      weekNumber: weekNumber,
      isLastSession: isLastSession,
    );
    final intensity = _intensityFor(policy);
    final title = BeginnerAdaptivePlanCopy.workoutTitleFor(
      policy.profile.templateKind,
      kind,
      isLastSession,
    );
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

  BeginnerPlanIntensity _intensityFor(BeginnerPlanPolicy policy) {
    return switch (policy.profile.templateKind) {
      BeginnerPlanTemplateKind.safetyFirstMovementStart ||
      BeginnerPlanTemplateKind.veryGentleStart =>
        BeginnerPlanIntensity.veryGentle,
      BeginnerPlanTemplateKind.standardBeginnerStart ||
      BeginnerPlanTemplateKind.returningBeginnerStart =>
        BeginnerPlanIntensity.balanced,
    };
  }

  BeginnerWorkoutKind _workoutKindFor(
    BeginnerPlanPolicy policy,
    int sessionIndex,
  ) {
    return switch (policy.profile.templateKind) {
      BeginnerPlanTemplateKind.safetyFirstMovementStart =>
        BeginnerWorkoutKind.recoveryWalk,
      BeginnerPlanTemplateKind.veryGentleStart =>
        sessionIndex == 1
            ? BeginnerWorkoutKind.recoveryWalk
            : _gentleKind(sessionIndex),
      BeginnerPlanTemplateKind.standardBeginnerStart =>
        BeginnerWorkoutKind.runWalk,
      BeginnerPlanTemplateKind.returningBeginnerStart =>
        BeginnerWorkoutKind.easyRun,
    };
  }

  BeginnerWorkoutKind _gentleKind(int sessionIndex) {
    if (sessionIndex == 2) {
      return BeginnerWorkoutKind.runWalk;
    }
    return BeginnerWorkoutKind.walkRun;
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
