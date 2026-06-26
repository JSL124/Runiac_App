import '../../../onboarding/domain/models/local_onboarding_draft.dart';
import '../models/beginner_adaptive_plan_snapshot.dart';
import '../models/plan_family.dart';
import 'beginner_adaptive_plan_copy.dart';

class PlanFamilyWorkoutBuilder {
  const PlanFamilyWorkoutBuilder();

  int requiredSessionsFor(PlanFamily family, BeginnerPlanPolicy policy) {
    final capped = switch (family.category) {
      PlanFamilyCategory.starter =>
        policy.requiredSessions > 3 ? 3 : policy.requiredSessions,
      PlanFamilyCategory.developing =>
        policy.requiredSessions > 4 ? 4 : policy.requiredSessions,
      PlanFamilyCategory.performance =>
        policy.requiredSessions < 4 ? 4 : policy.requiredSessions,
    };

    if (family == PlanFamily.returnToMovement && capped > 3) {
      return 3;
    }

    return capped;
  }

  BeginnerAdaptiveWorkout workoutFor({
    required LocalOnboardingDraft draft,
    required BeginnerPlanPolicy policy,
    required PlanFamily family,
    required String dayLabel,
    required int sessionIndex,
    required int requiredSessions,
    required int weekNumber,
  }) {
    final isLastSession = sessionIndex == requiredSessions - 1;
    final kind = _workoutKindFor(family, sessionIndex, isLastSession);
    final durationMinutes = policy.durationFor(
      weekNumber: weekNumber,
      isLastSession: isLastSession,
    );
    final intensity = _intensityFor(family, policy);
    final runMinutes = _mainEffortMinutes(durationMinutes, intensity, kind);

    return BeginnerAdaptiveWorkout(
      dayLabel: dayLabel,
      title: BeginnerAdaptivePlanCopy.workoutTitleFor(
        family,
        kind,
        sessionIndex,
        isLastSession,
      ),
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

  BeginnerPlanIntensity _intensityFor(
    PlanFamily family,
    BeginnerPlanPolicy policy,
  ) {
    if (family == PlanFamily.returnToMovement) {
      return BeginnerPlanIntensity.veryGentle;
    }

    if (family.category == PlanFamilyCategory.performance) {
      return BeginnerPlanIntensity.balanced;
    }

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
    PlanFamily family,
    int sessionIndex,
    bool isLastSession,
  ) {
    return switch (family) {
      PlanFamily.returnToMovement => BeginnerWorkoutKind.recoveryWalk,
      PlanFamily.runWalkFoundation =>
        sessionIndex == 1
            ? BeginnerWorkoutKind.recoveryWalk
            : BeginnerWorkoutKind.runWalk,
      PlanFamily.firstContinuousRunningStart ||
      PlanFamily.consistencyBase ||
      PlanFamily.tenKFoundation =>
        isLastSession
            ? BeginnerWorkoutKind.longerEasyRun
            : BeginnerWorkoutKind.easyRun,
      PlanFamily.fiveKBaseBuilder =>
        sessionIndex == 1
            ? BeginnerWorkoutKind.steadyRun
            : isLastSession
            ? BeginnerWorkoutKind.longerEasyRun
            : BeginnerWorkoutKind.easyRun,
      PlanFamily.fiveKPerformanceBuild ||
      PlanFamily.tenKPerformanceBuild => switch (sessionIndex) {
        1 => BeginnerWorkoutKind.controlledSteadyRun,
        2 => BeginnerWorkoutKind.longerEasyRun,
        3 => BeginnerWorkoutKind.recoveryRun,
        _ => BeginnerWorkoutKind.easyRun,
      },
    };
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
      BeginnerWorkoutKind.steadyRun => [
        'Warm-up walk · 4 min',
        'Steady comfortable run · $mainEffortMinutes min',
        'Cool-down walk · ${durationMinutes - mainEffortMinutes - 4} min',
      ],
      BeginnerWorkoutKind.controlledSteadyRun => [
        'Warm-up walk · 5 min',
        'Controlled steady effort · $mainEffortMinutes min',
        'Cool-down walk · ${durationMinutes - mainEffortMinutes - 5} min',
      ],
      BeginnerWorkoutKind.longerEasyRun => [
        'Warm-up walk · 4 min',
        'Longer easy run · $mainEffortMinutes min',
        'Cool-down walk · ${durationMinutes - mainEffortMinutes - 4} min',
      ],
      BeginnerWorkoutKind.recoveryRun => [
        'Warm-up walk · 4 min',
        'Short easy run · $mainEffortMinutes min',
        'Cool-down walk · ${durationMinutes - mainEffortMinutes - 4} min',
      ],
      BeginnerWorkoutKind.restOrMobility => const ['Rest or light mobility'],
    };
  }
}
