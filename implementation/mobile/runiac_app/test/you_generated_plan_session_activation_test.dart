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
      expect(find.text('0 of 7 done'), findsNothing);
      expect(find.text('2 of 3 done'), findsNothing);
      expect(find.text('Week 3 of 8'), findsNothing);
      expect(find.text('43% completed'), findsNothing);
      expect(find.text('15 min walk-run'), findsNothing);
      expect(find.text('Upcoming · 7:30 AM'), findsWidgets);

      for (final text in [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
        '25 min Comfortable Run',
        '25 min Controlled Steady Run',
        '25 min Longer Easy Run',
        '30 min Recovery Run',
      ]) {
        expect(find.text(text), findsWidgets);
      }
      expect(find.text('Rest Day'), findsNWidgets(3));
      expect(find.text('Rest'), findsNothing);
      expect(find.text('Recovery day'), findsNothing);
    },
  );

  testWidgets('generated weekly rest rows do not open workout detail', (
    WidgetTester tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();
    expect(generatedPlanStore.setActivePlan(_tenKPerformancePlan()), isTrue);

    await _openYouPlansTab(tester, generatedPlanStore);

    expect(find.text('Rest Day'), findsNWidgets(3));
    expect(find.text('Rest'), findsNothing);
    expect(find.text('Recovery day'), findsNothing);
    await tester.ensureVisible(find.text('Rest Day').first);
    await tester.tap(find.text('Rest Day').first);
    await tester.pumpAndSettle();

    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('10K Performance Build'), findsOneWidget);
    expect(find.text('0 of 4 done'), findsOneWidget);
  });

  testWidgets('You Plans keeps static fallback when no generated plan exists', (
    WidgetTester tester,
  ) async {
    await _openYouPlansTab(tester, CurrentSessionGeneratedPlanStore());

    expect(find.text('Current Goal'), findsOneWidget);
    expect(find.text('10K Preparation'), findsOneWidget);
    expect(find.text('2 of 3 done'), findsOneWidget);
    expect(find.text('10K Performance Build'), findsNothing);
    expect(find.text('Recovery day'), findsNothing);
  });

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
    expect(find.textContaining('min Easy Walk'), findsNWidgets(3));
    expect(find.text('30 min Easy Walk'), findsOneWidget);
    expect(find.text('10K Base Builder'), findsNothing);
    expect(find.text('15 min walk-run'), findsNothing);
  });

  testWidgets(
    'You Plans shows restricted recovery plan before static fallback',
    (WidgetTester tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();
      final recoveryPlan = const BeginnerAdaptivePlanGenerator().generate(
        planFamilyPerformanceDraft(
          goal: OnboardingGoal.tenK,
          health: OnboardingHealthComfort.injury,
          style: OnboardingPlanStyle.performanceFocused,
        ),
      );
      expect(generatedPlanStore.setActivePlan(recoveryPlan), isTrue);

      await _openYouPlansTab(tester, generatedPlanStore);

      expect(find.text('Current Goal'), findsNothing);
      expect(find.text('Return to Movement'), findsOneWidget);
      expect(
        find.text('A gentle restart plan focused on comfort and consistency.'),
        findsOneWidget,
      );
      expect(find.text('0 of 3 done'), findsOneWidget);
      expect(find.text('20 min Easy Walk'), findsNWidgets(3));
      expect(find.text('10K Performance Build'), findsNothing);
    },
  );

  testWidgets('generated weekly row opens generated workout detail', (
    WidgetTester tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();
    expect(generatedPlanStore.setActivePlan(_tenKPerformancePlan()), isTrue);

    await _openYouPlansTab(tester, generatedPlanStore);

    await tester.ensureVisible(find.text('25 min Controlled Steady Run'));
    await tester.tap(find.text('25 min Controlled Steady Run'));
    await tester.pumpAndSettle();

    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Tue · Controlled Steady Run'), findsOneWidget);
    expect(find.text('10K Performance Build'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('25 min'), findsWidgets);
    expect(find.text('Generated'), findsOneWidget);
    expect(find.text('Suggested pace'), findsNothing);
    expect(find.text('7:30 /km'), findsNothing);
    expect(find.text('Edit schedule'), findsOneWidget);
    expect(find.text('Start this run'), findsNothing);
  });
}
