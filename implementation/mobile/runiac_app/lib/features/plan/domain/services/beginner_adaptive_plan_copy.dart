import '../../../onboarding/domain/models/local_onboarding_draft.dart';
import '../models/beginner_adaptive_plan_snapshot.dart';

class BeginnerAdaptivePlanCopy {
  const BeginnerAdaptivePlanCopy._();

  static String titleFor(
    LocalOnboardingDraft draft,
    BeginnerPlanIntensity intensity,
  ) {
    if (intensity == BeginnerPlanIntensity.veryGentle) {
      return 'Very Gentle Beginner Plan';
    }

    return switch (draft.goal) {
      OnboardingGoal.first5k => 'First 5K Beginner Plan',
      OnboardingGoal.tenK => 'Gentle 10K Starter Plan',
      OnboardingGoal.stamina => 'Beginner Stamina Plan',
      OnboardingGoal.gentle => 'Gentle Running Starter Plan',
      OnboardingGoal.habit => 'Running Habit Starter Plan',
    };
  }

  static String subtitleFor(
    LocalOnboardingDraft draft,
    int durationMinutes,
    int sessionCount,
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
    return '$sessionCount short $time sessions for your $place routine, '
        'starting around $durationMinutes minutes.';
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

  static String durationLabelFor(
    LocalOnboardingDraft draft,
    int durationMinutes,
  ) {
    if (draft.sessionLength == OnboardingSessionLength.unsure) {
      return '15-20 min';
    }
    return '$durationMinutes min';
  }

  static String safetyNoteFor(LocalOnboardingDraft draft) {
    if (draft.hasCautionIntent) {
      return 'Start gently, pause if something feels wrong, and follow '
          'professional guidance if you have symptoms or health concerns.';
    }

    return 'Keep the first week easy and conversational. You can adjust the '
        'plan if a session feels like too much.';
  }

  static String focusFor(BeginnerPlanIntensity intensity) {
    return switch (intensity) {
      BeginnerPlanIntensity.veryGentle => 'Comfortable movement and recovery',
      BeginnerPlanIntensity.gentle => 'Easy consistency',
      BeginnerPlanIntensity.balanced => 'Steady beginner rhythm',
    };
  }

  static String workoutTitleFor(BeginnerWorkoutKind kind) {
    return switch (kind) {
      BeginnerWorkoutKind.easyRun => 'Easy run',
      BeginnerWorkoutKind.runWalk => 'Run-walk intervals',
      BeginnerWorkoutKind.walkRun => 'Walk-run session',
      BeginnerWorkoutKind.recoveryWalk => 'Recovery walk',
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
