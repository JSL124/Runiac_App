import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/onboarding/domain/models/local_onboarding_draft.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';

void main() {
  const generator = BeginnerAdaptivePlanGenerator();

  group('BeginnerAdaptivePlanGenerator variation matrix', () {
    test('safe returning runner visibly differs from safety-first', () {
      final safetyFirst = generator.generate(
        _draft(
          goal: OnboardingGoal.tenK,
          experience: OnboardingExperience.run30,
          availability: OnboardingAvailability.four,
          days: const [
            OnboardingPreferredDay.mon,
            OnboardingPreferredDay.tue,
            OnboardingPreferredDay.wed,
            OnboardingPreferredDay.thu,
          ],
          length: OnboardingSessionLength.thirty,
          health: OnboardingHealthComfort.heart,
          symptoms: const [OnboardingActivitySymptom.chest],
          cautiousness: OnboardingPlanCautiousness.standard,
        ),
      );
      final safeReturning = generator.generate(
        _draft(
          goal: OnboardingGoal.tenK,
          experience: OnboardingExperience.run30,
          availability: OnboardingAvailability.four,
          days: const [
            OnboardingPreferredDay.mon,
            OnboardingPreferredDay.tue,
            OnboardingPreferredDay.wed,
            OnboardingPreferredDay.thu,
          ],
          length: OnboardingSessionLength.thirty,
          cautiousness: OnboardingPlanCautiousness.standard,
        ),
      );

      expect(
        safetyFirst.templateKind,
        BeginnerPlanTemplateKind.safetyFirstMovementStart,
      );
      expect(
        safeReturning.templateKind,
        BeginnerPlanTemplateKind.returningBeginnerStart,
      );
      expect(_firstWeekTitles(safetyFirst), everyElement('Easy Walk'));
      expect(_firstWeekTitles(safeReturning), contains('Comfortable Run'));
      expect(_firstWeekTitles(safeReturning), contains('Longer Easy Run'));
      expect(
        _firstWeekSignature(safeReturning),
        isNot(_firstWeekSignature(safetyFirst)),
      );
    });

    test(
      'safety-first overrides aggressive answers with conservative rows',
      () {
        final plan = generator.generate(
          _draft(
            experience: OnboardingExperience.run30,
            availability: OnboardingAvailability.four,
            days: const [
              OnboardingPreferredDay.mon,
              OnboardingPreferredDay.tue,
              OnboardingPreferredDay.wed,
              OnboardingPreferredDay.thu,
            ],
            length: OnboardingSessionLength.thirty,
            health: OnboardingHealthComfort.injury,
            symptoms: const [OnboardingActivitySymptom.breath],
            cautiousness: OnboardingPlanCautiousness.standard,
          ),
        );

        expect(
          plan.templateKind,
          BeginnerPlanTemplateKind.safetyFirstMovementStart,
        );
        expect(plan.weeklyFrequencyLabel, '2 sessions / week');
        expect(plan.sessionDurationLabel, '15 min');
        expect(
          _firstWeekKinds(plan),
          everyElement(BeginnerWorkoutKind.recoveryWalk),
        );
        expect(
          _firstWeekIntensities(plan),
          everyElement(BeginnerPlanIntensity.veryGentle),
        );
        expect(_firstWeekTitles(plan), everyElement('Easy Walk'));
      },
    );

    test('standard beginner differs from very gentle first-week rows', () {
      final standard = generator.generate(
        _draft(
          experience: OnboardingExperience.intervals,
          cautiousness: OnboardingPlanCautiousness.standard,
        ),
      );
      final veryGentle = generator.generate(
        _draft(
          experience: OnboardingExperience.newRunner,
          cautiousness: OnboardingPlanCautiousness.veryGentle,
        ),
      );

      expect(
        standard.templateKind,
        BeginnerPlanTemplateKind.standardBeginnerStart,
      );
      expect(veryGentle.templateKind, BeginnerPlanTemplateKind.veryGentleStart);
      expect(
        _firstWeekKinds(standard),
        everyElement(BeginnerWorkoutKind.runWalk),
      );
      expect(_firstWeekKinds(veryGentle), [
        BeginnerWorkoutKind.walkRun,
        BeginnerWorkoutKind.recoveryWalk,
        BeginnerWorkoutKind.runWalk,
      ]);
      expect(_firstWeekTitles(standard).toSet(), hasLength(greaterThan(1)));
      expect(
        _firstWeekSignature(standard),
        isNot(_firstWeekSignature(veryGentle)),
      );
    });

    test('preferred day changes affect rows without inventing days', () {
      final weekdayPlan = generator.generate(
        _draft(
          days: const [
            OnboardingPreferredDay.mon,
            OnboardingPreferredDay.wed,
            OnboardingPreferredDay.fri,
          ],
        ),
      );
      final weekendPlan = generator.generate(
        _draft(
          days: const [
            OnboardingPreferredDay.tue,
            OnboardingPreferredDay.thu,
            OnboardingPreferredDay.sun,
          ],
        ),
      );

      expect(_firstWeekDays(weekdayPlan), ['Mon', 'Wed', 'Fri']);
      expect(_firstWeekDays(weekendPlan), ['Tue', 'Thu', 'Sun']);
      expect(_firstWeekDays(weekdayPlan), isNot(_firstWeekDays(weekendPlan)));
      expect({
        ..._firstWeekDays(weekdayPlan),
        ..._firstWeekDays(weekendPlan),
      }, isNot(contains('Sat')));
    });
  });
}

LocalOnboardingDraft _draft({
  OnboardingGoal goal = OnboardingGoal.habit,
  OnboardingExperience experience = OnboardingExperience.newRunner,
  OnboardingAvailability availability = OnboardingAvailability.three,
  List<OnboardingPreferredDay> days = const [
    OnboardingPreferredDay.mon,
    OnboardingPreferredDay.wed,
    OnboardingPreferredDay.fri,
  ],
  OnboardingPreferredTime time = OnboardingPreferredTime.morning,
  OnboardingSessionLength length = OnboardingSessionLength.twenty,
  OnboardingRunningPlace place = OnboardingRunningPlace.park,
  OnboardingMotivationStyle motivation = OnboardingMotivationStyle.plan,
  OnboardingHealthComfort health = OnboardingHealthComfort.ready,
  List<OnboardingActivitySymptom> symptoms = const [
    OnboardingActivitySymptom.none,
  ],
  OnboardingPlanCautiousness cautiousness = OnboardingPlanCautiousness.balanced,
}) {
  return LocalOnboardingDraft(
    goal: goal,
    experience: experience,
    availability: availability,
    preferredDays: days,
    preferredTime: time,
    sessionLength: length,
    runningPlace: place,
    motivationStyle: motivation,
    healthComfort: health,
    activitySymptoms: symptoms,
    planCautiousness: cautiousness,
  );
}

List<String> _firstWeekDays(BeginnerAdaptivePlanSnapshot plan) {
  return plan.weeks.first.workouts.map((workout) => workout.dayLabel).toList();
}

List<BeginnerPlanIntensity> _firstWeekIntensities(
  BeginnerAdaptivePlanSnapshot plan,
) {
  return plan.weeks.first.workouts.map((workout) => workout.intensity).toList();
}

List<BeginnerWorkoutKind> _firstWeekKinds(BeginnerAdaptivePlanSnapshot plan) {
  return plan.weeks.first.workouts.map((workout) => workout.kind).toList();
}

List<String> _firstWeekTitles(BeginnerAdaptivePlanSnapshot plan) {
  return plan.weeks.first.workouts.map((workout) => workout.title).toList();
}

String _firstWeekSignature(BeginnerAdaptivePlanSnapshot plan) {
  return plan.weeks.first.workouts
      .map(
        (workout) =>
            '${workout.dayLabel}|${workout.title}|${workout.durationMinutes}|'
            '${workout.kind.name}|${workout.intensity.name}',
      )
      .join('\n');
}
