import '../../../onboarding/domain/models/local_onboarding_draft.dart';
import '../models/beginner_adaptive_plan_snapshot.dart';

class BeginnerAdaptivePlanCopy {
  const BeginnerAdaptivePlanCopy._();

  static String titleFor(
    LocalOnboardingDraft draft,
    BeginnerPlanTemplateKind templateKind,
  ) {
    if (templateKind == BeginnerPlanTemplateKind.safetyFirstMovementStart) {
      return 'Gentle Movement Start';
    }

    return switch (draft.goal) {
      OnboardingGoal.first5k => 'Beginner 5K Start',
      OnboardingGoal.tenK => 'Endurance Foundation Start',
      OnboardingGoal.stamina => 'Stamina Starter Plan',
      OnboardingGoal.gentle => 'Gentle Running Starter Plan',
      OnboardingGoal.habit => 'Consistency Starter Plan',
    };
  }

  static String subtitleFor(
    LocalOnboardingDraft draft,
    BeginnerPlanPolicy policy,
  ) {
    final place = switch (draft.runningPlace) {
      OnboardingRunningPlace.park => 'outdoor park',
      OnboardingRunningPlace.road => 'neighbourhood',
      OnboardingRunningPlace.track => 'track',
      OnboardingRunningPlace.treadmill => 'treadmill',
      OnboardingRunningPlace.mixed => 'mixed-route',
    };
    final time = switch (draft.preferredTime) {
      OnboardingPreferredTime.morning => 'morning',
      OnboardingPreferredTime.afternoon => 'afternoon',
      OnboardingPreferredTime.evening => 'evening',
      OnboardingPreferredTime.night => 'night',
      OnboardingPreferredTime.flexible => 'flexible-time',
    };
    final emphasis = switch (draft.goal) {
      OnboardingGoal.habit => 'repeatable short sessions',
      OnboardingGoal.gentle => 'comfort and low pressure',
      OnboardingGoal.first5k => 'gradual running confidence',
      OnboardingGoal.tenK => 'base-building before longer goals',
      OnboardingGoal.stamina => 'comfortable time-on-feet',
    };
    return '${policy.durationWeeks}-week starter plan with '
        '${policy.requiredSessions} $time sessions for your $place routine, '
        'focused on $emphasis.';
  }

  static String supportStyleFor(LocalOnboardingDraft draft) {
    return switch (draft.motivationStyle) {
      OnboardingMotivationStyle.reminders => 'Gentle reminders',
      OnboardingMotivationStyle.plan => 'Clear weekly plan',
      OnboardingMotivationStyle.encourage => 'Progress encouragement',
      OnboardingMotivationStyle.challenge => 'Friendly challenge',
      OnboardingMotivationStyle.expert => 'Beginner guidance',
    };
  }

  static String durationLabelFor(Iterable<int> durationMinutes) {
    final ordered = durationMinutes.toSet().toList()..sort();
    if (ordered.length == 1) {
      return '${ordered.single} min';
    }

    return '${ordered.first}-${ordered.last} min';
  }

  static String safetyNoteFor(BeginnerPlanSafetyBand safetyBand) {
    if (safetyBand == BeginnerPlanSafetyBand.safetyFirst) {
      return 'Keep this very easy and comfortable, and consider professional '
          'guidance before increasing intensity.';
    }

    if (safetyBand == BeginnerPlanSafetyBand.highCaution ||
        safetyBand == BeginnerPlanSafetyBand.cautious) {
      return 'Start gently, keep the effort comfortable, and pause if '
          'something feels wrong.';
    }

    return 'Keep the first week easy and conversational. You can adjust the '
        'plan if a session feels like too much.';
  }

  static String focusFor(
    BeginnerPlanTemplateKind templateKind,
    int weekNumber,
  ) {
    if (weekNumber == 1) {
      return switch (templateKind) {
        BeginnerPlanTemplateKind.safetyFirstMovementStart =>
          'Keep movement easy and comfortable',
        BeginnerPlanTemplateKind.veryGentleStart =>
          'Gentle adaptation and confidence',
        BeginnerPlanTemplateKind.standardBeginnerStart =>
          'Easy run-walk consistency',
        BeginnerPlanTemplateKind.returningBeginnerStart =>
          'Comfortable running rhythm',
      };
    }

    return switch (weekNumber) {
      2 => 'Repeat the rhythm with a small build',
      3 => 'Add a little confidence without pressure',
      _ => 'Stabilize the routine',
    };
  }

  static String workoutTitleFor(
    BeginnerPlanTemplateKind templateKind,
    BeginnerWorkoutKind kind,
    bool isLastSession,
  ) {
    if (templateKind == BeginnerPlanTemplateKind.returningBeginnerStart &&
        kind == BeginnerWorkoutKind.easyRun) {
      return isLastSession ? 'Longer Easy Run' : 'Comfortable Run';
    }

    if (templateKind == BeginnerPlanTemplateKind.veryGentleStart &&
        kind == BeginnerWorkoutKind.runWalk) {
      return 'Confidence Builder';
    }

    return switch (kind) {
      BeginnerWorkoutKind.easyRun => 'Comfortable Run',
      BeginnerWorkoutKind.runWalk => 'Easy Run-Walk',
      BeginnerWorkoutKind.walkRun => 'Gentle Walk-Run',
      BeginnerWorkoutKind.recoveryWalk => 'Easy Walk',
      BeginnerWorkoutKind.restOrMobility => 'Rest or mobility',
    };
  }

  static String descriptionFor(
    LocalOnboardingDraft draft,
    BeginnerWorkoutKind kind,
  ) {
    final routeHint = switch (draft.runningPlace) {
      OnboardingRunningPlace.park => 'Choose a familiar park loop.',
      OnboardingRunningPlace.road => 'Choose a calm neighbourhood route.',
      OnboardingRunningPlace.track => 'Use an easy lane or short loop.',
      OnboardingRunningPlace.treadmill => 'Keep the treadmill pace relaxed.',
      OnboardingRunningPlace.mixed => 'Choose whichever route feels easiest.',
    };

    return switch (kind) {
      BeginnerWorkoutKind.easyRun =>
        '$routeHint Keep the effort relaxed enough to speak comfortably.',
      BeginnerWorkoutKind.runWalk =>
        '$routeHint Alternate short easy runs with walking breaks.',
      BeginnerWorkoutKind.walkRun =>
        '$routeHint Start with walking and add small running blocks.',
      BeginnerWorkoutKind.recoveryWalk =>
        '$routeHint Keep this one light and leave energy for the next session.',
      BeginnerWorkoutKind.restOrMobility =>
        'Keep this day open for rest or easy mobility.',
    };
  }

  static String supportiveNoteFor(
    LocalOnboardingDraft draft,
    BeginnerPlanIntensity intensity,
  ) {
    if (draft.motivationStyle == OnboardingMotivationStyle.challenge &&
        intensity == BeginnerPlanIntensity.balanced) {
      return 'Treat the challenge as optional. A calm finish is enough.';
    }

    if (intensity == BeginnerPlanIntensity.veryGentle) {
      return 'Walking more is a valid way to complete this session.';
    }

    return 'Finish feeling like you could do a little more.';
  }
}
