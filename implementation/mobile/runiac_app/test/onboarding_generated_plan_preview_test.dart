import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/onboarding/domain/models/local_onboarding_draft.dart';
import 'package:runiac_app/features/onboarding/presentation/widgets/onboarding_preview_body.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';

void main() {
  testWidgets(
    'final preview renders summary and rows from one generated plan',
    (tester) async {
      final draft = LocalOnboardingDraft(
        goal: OnboardingGoal.first5k,
        experience: OnboardingExperience.intervals,
        availability: OnboardingAvailability.three,
        preferredDays: const [
          OnboardingPreferredDay.mon,
          OnboardingPreferredDay.wed,
          OnboardingPreferredDay.fri,
        ],
        preferredTime: OnboardingPreferredTime.morning,
        sessionLength: OnboardingSessionLength.twenty,
        runningPlace: OnboardingRunningPlace.park,
        motivationStyle: OnboardingMotivationStyle.plan,
        healthComfort: OnboardingHealthComfort.ready,
        activitySymptoms: const [OnboardingActivitySymptom.none],
        planCautiousness: OnboardingPlanCautiousness.standard,
      );
      final plan = const BeginnerAdaptivePlanGenerator().generate(draft);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OnboardingPreviewBody(answers: _answersFor(draft)),
            ),
          ),
        ),
      );

      expect(find.text(plan.title), findsOneWidget);
      expect(find.text(plan.subtitle), findsOneWidget);
      expect(find.text('${plan.durationWeeks} weeks'), findsOneWidget);
      expect(find.text(plan.weeklyFrequencyLabel), findsOneWidget);
      expect(find.text(plan.sessionDurationLabel), findsOneWidget);
      expect(find.text(plan.preferredScheduleLabel), findsWidgets);

      for (final workout in plan.weeks.first.workouts) {
        expect(
          find.text(
            '${workout.dayLabel} · ${workout.title} · '
            '${workout.durationMinutes} min',
          ),
          findsOneWidget,
        );
      }
    },
  );
}

Map<String, Object> _answersFor(LocalOnboardingDraft draft) {
  return {
    'goal': draft.goal.value,
    'experience': draft.experience.value,
    'availability': draft.availability.value,
    'days': draft.preferredDays.map((day) => day.value).toSet(),
    'time': draft.preferredTime.value,
    'length': draft.sessionLength.value,
    'place': draft.runningPlace.value,
    'motivation': draft.motivationStyle.value,
    'health': draft.healthComfort.value,
    'symptoms': draft.activitySymptoms.map((symptom) => symptom.value).toSet(),
    'cautious': draft.planCautiousness.value,
  };
}
