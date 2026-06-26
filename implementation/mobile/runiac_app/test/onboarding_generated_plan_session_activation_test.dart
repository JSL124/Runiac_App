import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';

import 'support/onboarding_flow_test_helpers.dart';
import 'support/plan_family_test_drafts.dart';

void main() {
  testWidgets(
    'eligible onboarding completion activates generated running plan session',
    (tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showOnboarding: true,
          enableForegroundGps: false,
          currentSessionGeneratedPlanStore: generatedPlanStore,
        ),
      );

      await completeOnboardingToFourSessionPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsOneWidget);
      expect(generatedPlanStore.activePlan, isNotNull);
      expect(generatedPlanStore.activePlan!.title, '10K Performance Build');
      expect(generatedPlanStore.currentWeekRunningSessionCount, 4);
    },
  );

  testWidgets(
    'starter onboarding completion activates generated movement plan session',
    (tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showOnboarding: true,
          enableForegroundGps: false,
          currentSessionGeneratedPlanStore: generatedPlanStore,
        ),
      );

      await completeOnboardingToPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsOneWidget);
      expect(generatedPlanStore.activePlan, isNotNull);
      expect(generatedPlanStore.activePlan!.title, 'Return to Movement');
      expect(generatedPlanStore.currentWeekRunningSessionCount, 3);
    },
  );

  testWidgets(
    'body concern onboarding completion activates recovery plan session',
    (tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showOnboarding: true,
          enableForegroundGps: false,
          currentSessionGeneratedPlanStore: generatedPlanStore,
        ),
      );

      await completeOnboardingToBodyConcernPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsOneWidget);
      expect(generatedPlanStore.activePlan, isNotNull);
      expect(generatedPlanStore.activePlan!.title, 'Return to Movement');
      expect(generatedPlanStore.currentWeekRunningSessionCount, 3);
    },
  );

  testWidgets('needs clearance completion does not activate generated plan', (
    tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
        currentSessionGeneratedPlanStore: generatedPlanStore,
      ),
    );

    await completeOnboardingToNeedsClearancePreview(tester);
    await tapText(tester, 'Finish for now');

    expect(find.text('Good to see you'), findsOneWidget);
    expect(generatedPlanStore.activePlan, isNull);
    expect(generatedPlanStore.currentWeekRunningSessionCount, 0);
  });

  testWidgets('blocked onboarding completion clears stale generated plan', (
    tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();
    final stalePlan = const BeginnerAdaptivePlanGenerator().generate(
      planFamilyPerformanceDraft(
        goal: OnboardingGoal.tenK,
        style: OnboardingPlanStyle.performanceFocused,
        days: const [
          OnboardingPreferredDay.mon,
          OnboardingPreferredDay.tue,
          OnboardingPreferredDay.wed,
          OnboardingPreferredDay.thu,
        ],
      ),
    );
    expect(generatedPlanStore.setActivePlan(stalePlan), isTrue);

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
        currentSessionGeneratedPlanStore: generatedPlanStore,
      ),
    );

    await completeOnboardingToNeedsClearancePreview(tester);
    await tapText(tester, 'Finish for now');

    expect(find.text('Good to see you'), findsOneWidget);
    expect(generatedPlanStore.activePlan, isNull);
    expect(generatedPlanStore.currentWeekRunningSessionCount, 0);
  });
}
