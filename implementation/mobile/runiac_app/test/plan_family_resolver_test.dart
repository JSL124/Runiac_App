import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/onboarding/domain/services/onboarding_plan_style_resolver.dart';
import 'package:runiac_app/features/onboarding/domain/services/runner_level_resolver.dart';
import 'package:runiac_app/features/onboarding/domain/services/safety_gate_resolver.dart';
import 'package:runiac_app/features/plan/domain/models/plan_family.dart';
import 'package:runiac_app/features/plan/domain/services/plan_family_resolver.dart';

import 'support/plan_family_test_drafts.dart';

void main() {
  group('PlanFamilyResolver', () {
    const resolver = PlanFamilyResolver();
    const safetyResolver = SafetyGateResolver();
    const levelResolver = RunnerLevelResolver();
    const styleResolver = PlanStyleResolver();

    ResolvedPlanFamily resolve(LocalOnboardingDraft draft) {
      final safetyGate = safetyResolver.resolve(draft);
      final runnerLevel = levelResolver.resolve(draft);
      final resolvedStyle = styleResolver.resolve(
        draft: draft,
        safetyGate: safetyGate,
        runnerLevel: runnerLevel,
      );
      return resolver.resolve(
        draft: draft,
        safetyGate: safetyGate,
        runnerLevel: runnerLevel,
        resolvedStyle: resolvedStyle,
      );
    }

    test('keeps starter users in starter families', () {
      expect(
        resolve(planFamilyStarterDraft()).family,
        PlanFamily.returnToMovement,
      );
      expect(
        resolve(
          planFamilyStarterDraft(
            goal: OnboardingGoal.gentle,
            capacity: ContinuousRunCapacity.runWalk,
            availability: OnboardingAvailability.three,
          ),
        ).family,
        PlanFamily.runWalkFoundation,
      );
      expect(
        resolve(
          planFamilyStarterDraft(
            goal: OnboardingGoal.first5k,
            capacity: ContinuousRunCapacity.twentyToThirtyMinutes,
            consistency: RecentRunningConsistency.underFourWeeks,
            frequency: CurrentWeeklyRunFrequency.three,
            availability: OnboardingAvailability.three,
            style: OnboardingPlanStyle.performanceFocused,
          ),
        ).family,
        PlanFamily.firstContinuousRunningStart,
      );
    });

    test(
      'developing families follow goal and conservative downgrade policy',
      () {
        expect(
          resolve(
            planFamilyDevelopingDraft(goal: OnboardingGoal.first5k),
          ).family,
          PlanFamily.fiveKBaseBuilder,
        );
        expect(
          resolve(planFamilyDevelopingDraft(goal: OnboardingGoal.tenK)).family,
          PlanFamily.tenKFoundation,
        );
        expect(
          resolve(
            planFamilyDevelopingDraft(
              goal: OnboardingGoal.first5k,
              style: OnboardingPlanStyle.conservativeBase,
            ),
          ).family,
          PlanFamily.consistencyBase,
        );
      },
    );

    test(
      'performance and advanced users resolve to supported performance families only',
      () {
        expect(
          resolve(
            planFamilyPerformanceDraft(
              goal: OnboardingGoal.first5k,
              style: OnboardingPlanStyle.performanceFocused,
            ),
          ).family,
          PlanFamily.fiveKPerformanceBuild,
        );
        expect(
          resolve(
            planFamilyPerformanceDraft(
              goal: OnboardingGoal.tenK,
              style: OnboardingPlanStyle.performanceFocused,
            ),
          ).family,
          PlanFamily.tenKPerformanceBuild,
        );
        expect(
          resolve(
            planFamilyAdvancedDraft(
              goal: OnboardingGoal.tenK,
              style: OnboardingPlanStyle.performanceFocused,
            ),
          ).family,
          PlanFamily.tenKPerformanceBuild,
        );
      },
    );

    test('safety and missing data only block or downgrade', () {
      expect(
        resolve(
          planFamilyStarterDraft(health: OnboardingHealthComfort.heart),
        ).family,
        isNull,
      );
      expect(
        resolve(
          planFamilyPerformanceDraft(
            goal: OnboardingGoal.tenK,
            health: OnboardingHealthComfort.joint,
            style: OnboardingPlanStyle.performanceFocused,
          ),
        ).family,
        PlanFamily.returnToMovement,
      );
      expect(
        resolve(
          planFamilyDevelopingDraft(
            goal: OnboardingGoal.tenK,
            availability: OnboardingAvailability.two,
          ),
        ).family,
        PlanFamily.consistencyBase,
      );
    });

    test('goal and style cannot promote objective eligibility', () {
      expect(
        resolve(
          planFamilyStarterDraft(
            goal: OnboardingGoal.tenK,
            style: OnboardingPlanStyle.performanceFocused,
          ),
        ).category,
        PlanFamilyCategory.starter,
      );
      expect(
        resolve(
          planFamilyDevelopingDraft(
            goal: OnboardingGoal.tenK,
            style: OnboardingPlanStyle.performanceFocused,
          ),
        ).category,
        PlanFamilyCategory.developing,
      );
      expect(
        levelResolver.resolve(
          planFamilyStarterDraft(
            goal: OnboardingGoal.tenK,
            style: OnboardingPlanStyle.performanceFocused,
          ),
        ),
        RunnerLevel.starter,
      );
    });
  });
}
