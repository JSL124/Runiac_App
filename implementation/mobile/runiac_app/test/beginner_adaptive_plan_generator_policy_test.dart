import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/onboarding/domain/models/local_onboarding_draft.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';

void main() {
  const generator = BeginnerAdaptivePlanGenerator();

  group('BeginnerAdaptivePlanGenerator policy', () {
    test('maps safety, experience, and caution into templates', () {
      final cases = [
        (
          draft: _draft(experience: OnboardingExperience.newRunner),
          template: BeginnerPlanTemplateKind.veryGentleStart,
          safety: BeginnerPlanSafetyBand.clear,
        ),
        (
          draft: _draft(experience: OnboardingExperience.walk),
          template: BeginnerPlanTemplateKind.veryGentleStart,
          safety: BeginnerPlanSafetyBand.clear,
        ),
        (
          draft: _draft(experience: OnboardingExperience.intervals),
          template: BeginnerPlanTemplateKind.standardBeginnerStart,
          safety: BeginnerPlanSafetyBand.clear,
        ),
        (
          draft: _draft(experience: OnboardingExperience.run10),
          template: BeginnerPlanTemplateKind.standardBeginnerStart,
          safety: BeginnerPlanSafetyBand.clear,
        ),
        (
          draft: _draft(
            experience: OnboardingExperience.run30,
            cautiousness: OnboardingPlanCautiousness.standard,
          ),
          template: BeginnerPlanTemplateKind.returningBeginnerStart,
          safety: BeginnerPlanSafetyBand.clear,
        ),
        (
          draft: _draft(
            experience: OnboardingExperience.run30,
            cautiousness: OnboardingPlanCautiousness.veryGentle,
          ),
          template: BeginnerPlanTemplateKind.veryGentleStart,
          safety: BeginnerPlanSafetyBand.clear,
        ),
        (
          draft: _draft(
            health: OnboardingHealthComfort.injury,
            symptoms: [OnboardingActivitySymptom.none],
          ),
          template: BeginnerPlanTemplateKind.veryGentleStart,
          safety: BeginnerPlanSafetyBand.highCaution,
        ),
        (
          draft: _draft(
            experience: OnboardingExperience.run30,
            health: OnboardingHealthComfort.heart,
            symptoms: [OnboardingActivitySymptom.chest],
            cautiousness: OnboardingPlanCautiousness.standard,
          ),
          template: BeginnerPlanTemplateKind.safetyFirstMovementStart,
          safety: BeginnerPlanSafetyBand.safetyFirst,
        ),
      ];

      for (final item in cases) {
        final plan = generator.generate(item.draft);

        expect(plan.templateKind, item.template);
        expect(plan.safetyBand, item.safety);
      }
    });

    test('applies weekly session caps from safety and caution policy', () {
      expect(
        generator
            .generate(
              _draft(
                availability: OnboardingAvailability.two,
                days: [OnboardingPreferredDay.mon, OnboardingPreferredDay.wed],
              ),
            )
            .weeks
            .first
            .workouts,
        hasLength(2),
      );
      expect(
        generator
            .generate(
              _draft(
                availability: OnboardingAvailability.three,
                days: [
                  OnboardingPreferredDay.mon,
                  OnboardingPreferredDay.wed,
                  OnboardingPreferredDay.fri,
                ],
              ),
            )
            .weeks
            .first
            .workouts,
        hasLength(3),
      );
      expect(
        generator
            .generate(
              _draft(
                experience: OnboardingExperience.run30,
                availability: OnboardingAvailability.four,
                days: [
                  OnboardingPreferredDay.mon,
                  OnboardingPreferredDay.tue,
                  OnboardingPreferredDay.thu,
                  OnboardingPreferredDay.sat,
                ],
                cautiousness: OnboardingPlanCautiousness.standard,
              ),
            )
            .weeks
            .first
            .workouts,
        hasLength(4),
      );
      expect(
        generator
            .generate(
              _draft(
                availability: OnboardingAvailability.four,
                days: [
                  OnboardingPreferredDay.mon,
                  OnboardingPreferredDay.tue,
                  OnboardingPreferredDay.thu,
                  OnboardingPreferredDay.sat,
                ],
                cautiousness: OnboardingPlanCautiousness.veryGentle,
              ),
            )
            .weeks
            .first
            .workouts,
        hasLength(3),
      );
      expect(
        generator
            .generate(
              _draft(
                availability: OnboardingAvailability.four,
                days: [
                  OnboardingPreferredDay.mon,
                  OnboardingPreferredDay.tue,
                  OnboardingPreferredDay.thu,
                  OnboardingPreferredDay.sat,
                ],
                health: OnboardingHealthComfort.heart,
                symptoms: [OnboardingActivitySymptom.heartbeat],
              ),
            )
            .weeks
            .first
            .workouts,
        hasLength(2),
      );
    });

    test('uses only selected preferred days and best-spaced subset', () {
      final plan = generator.generate(
        _draft(
          experience: OnboardingExperience.intervals,
          availability: OnboardingAvailability.three,
          days: [
            OnboardingPreferredDay.mon,
            OnboardingPreferredDay.tue,
            OnboardingPreferredDay.fri,
            OnboardingPreferredDay.sun,
          ],
          cautiousness: OnboardingPlanCautiousness.standard,
        ),
      );

      expect(plan.preferredScheduleLabel, 'Tue · Fri · Sun');
      expect(plan.weeks.first.workouts.map((workout) => workout.dayLabel), [
        'Tue',
        'Fri',
        'Sun',
      ]);
    });
  });
}

LocalOnboardingDraft _draft({
  OnboardingGoal goal = OnboardingGoal.habit,
  OnboardingExperience experience = OnboardingExperience.newRunner,
  OnboardingAvailability availability = OnboardingAvailability.three,
  List<OnboardingPreferredDay> days = const [OnboardingPreferredDay.mon],
  OnboardingPreferredTime time = OnboardingPreferredTime.morning,
  OnboardingSessionLength length = OnboardingSessionLength.twenty,
  OnboardingRunningPlace place = OnboardingRunningPlace.mixed,
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
