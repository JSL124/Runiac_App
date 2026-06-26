import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';

import 'support/plan_family_test_drafts.dart';

Future<void> _openYouPlansTab(
  WidgetTester tester,
  CurrentSessionGeneratedPlanStore generatedPlanStore,
) async {
  await tester.pumpWidget(
    RuniacApp(
      showSplash: false,
      enableForegroundGps: false,
      currentSessionGeneratedPlanStore: generatedPlanStore,
    ),
  );
  await tester.tap(find.byTooltip('You'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Plans'));
  await tester.pumpAndSettle();
}

BeginnerAdaptivePlanSnapshot _tenKPerformancePlan() {
  return const BeginnerAdaptivePlanGenerator().generate(
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
}

void main() {
  testWidgets(
    'You Plans shows generated onboarding plan before static fallback',
    (WidgetTester tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();
      expect(generatedPlanStore.setActivePlan(_tenKPerformancePlan()), isTrue);

      await _openYouPlansTab(tester, generatedPlanStore);

      expect(find.text('Current Goal'), findsNothing);
      expect(find.text('View Goal Plan'), findsNothing);
      expect(find.text('10K Performance Build'), findsOneWidget);
      expect(
        find.text(
          '8-week structured plan with 4 morning sessions for your outdoor '
          'park routine, focused on base-building before longer goals.',
        ),
        findsOneWidget,
      );
      expect(find.text('0 of 4 done'), findsOneWidget);
      expect(find.text('2 of 3 done'), findsNothing);
      expect(find.text('Week 3 of 8'), findsNothing);
      expect(find.text('43% completed'), findsNothing);
      expect(find.text('15 min walk-run'), findsNothing);
      expect(find.text('Upcoming · 7:30 AM'), findsNothing);

      for (final text in [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Comfortable Run',
        'Controlled Steady Run',
        'Longer Easy Run',
        'Recovery Run',
        '25 min',
        '30 min',
      ]) {
        expect(find.text(text), findsWidgets);
      }
    },
  );

  testWidgets('You Plans shows starter movement plan before static fallback', (
    WidgetTester tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();
    final starterPlan = const BeginnerAdaptivePlanGenerator().generate(
      planFamilyStarterDraft(availability: OnboardingAvailability.three),
    );
    expect(generatedPlanStore.setActivePlan(starterPlan), isTrue);

    await _openYouPlansTab(tester, generatedPlanStore);

    expect(find.text('Current Goal'), findsNothing);
    expect(find.text('Return to Movement'), findsOneWidget);
    expect(find.text('0 of 3 done'), findsOneWidget);
    expect(find.text('Easy Walk'), findsNWidgets(3));
    expect(find.text('30 min'), findsWidgets);
    expect(find.text('10K Base Builder'), findsNothing);
    expect(find.text('15 min walk-run'), findsNothing);
  });

  testWidgets('generated weekly row opens generated workout detail', (
    WidgetTester tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();
    expect(generatedPlanStore.setActivePlan(_tenKPerformancePlan()), isTrue);

    await _openYouPlansTab(tester, generatedPlanStore);

    await tester.ensureVisible(find.text('Controlled Steady Run'));
    await tester.tap(find.text('Controlled Steady Run'));
    await tester.pumpAndSettle();

    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Tue · Controlled Steady Run'), findsOneWidget);
    expect(find.text('10K Performance Build'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('25 min'), findsWidgets);
    expect(find.text('Generated'), findsOneWidget);
    expect(find.text('Suggested pace'), findsNothing);
    expect(find.text('7:30 /km'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Start This Run'), findsOneWidget);
  });
}
