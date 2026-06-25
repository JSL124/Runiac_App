import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/onboarding/domain/models/local_onboarding_draft.dart';
import 'package:runiac_app/features/onboarding/presentation/widgets/onboarding_preview_body.dart';

import 'support/onboarding_flow_test_helpers.dart';

void main() {
  testWidgets('onboarding renders before Home when enabled', (tester) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    expect(find.text('Welcome to Runiac'), findsOneWidget);
    expect(find.text('Step 1 of 13'), findsOneWidget);
    expect(find.text('Start setup'), findsOneWidget);
    expect(find.text('Set up later'), findsNothing);
    expect(find.text('Good to see you'), findsNothing);
  });

  testWidgets('onboarding advances, backs up, and keeps local selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    await tapText(tester, 'Start setup');
    expect(find.text('Step 2 of 13'), findsOneWidget);
    expect(find.text('What would you like to work toward?'), findsOneWidget);

    await tapText(tester, 'Build a running habit');
    await tapText(tester, 'Continue');
    expect(find.text('Step 3 of 13'), findsOneWidget);
    expect(find.text('Where are you starting from?'), findsOneWidget);

    await tapTooltip(tester, 'Back');
    expect(find.text('Step 2 of 13'), findsOneWidget);
    expect(find.text('Build a running habit'), findsOneWidget);

    await tapText(tester, 'Continue');
    expect(find.text('Step 3 of 13'), findsOneWidget);
  });

  testWidgets('onboarding remains mandatory before the preview is created', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    await tapText(tester, 'Start setup');

    expect(find.text('Step 2 of 13'), findsOneWidget);
    expect(find.text('What would you like to work toward?'), findsOneWidget);
    expect(find.text('Set up later'), findsNothing);
    expect(find.text('Setup paused'), findsNothing);
    expect(find.text('Go to Home'), findsNothing);
    expect(find.text('Good to see you'), findsNothing);
  });

  testWidgets('final preview completes into the Home dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    await completeOnboardingToPreview(tester);

    expect(find.text('Step 13 of 13'), findsOneWidget);
    expect(find.text('Your beginner plan preview is ready'), findsOneWidget);
    expect(find.text('Suggested starting plan'), findsOneWidget);
    expect(find.text('First week preview'), findsOneWidget);
    expect(find.text('Create my preview plan'), findsOneWidget);
    expect(find.text('Edit answers'), findsOneWidget);

    await tapText(tester, 'Create my preview plan');
    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.byTooltip('Home'), findsOneWidget);
  });

  testWidgets('final preview rows follow the generated local plan', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    await completeOnboardingToFourSessionPreview(tester);

    expect(find.text('4 sessions / week'), findsOneWidget);
    expect(find.text('Mon · Easy run'), findsOneWidget);
    expect(find.text('Tue · Easy run'), findsOneWidget);
    expect(find.text('Wed · Easy run'), findsOneWidget);
    expect(find.text('Thu · Recovery walk'), findsOneWidget);
  });

  testWidgets('final preview emits a typed local onboarding draft', (
    tester,
  ) async {
    LocalOnboardingDraft? completedDraft;

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
        onOnboardingCompleted: (draft) {
          completedDraft = draft;
        },
      ),
    );

    await completeOnboardingToPreview(tester);
    await tapText(tester, 'Create my preview plan');

    expect(completedDraft, isNotNull);
    expect(completedDraft!.goal, OnboardingGoal.habit);
    expect(completedDraft!.experience, OnboardingExperience.newRunner);
    expect(completedDraft!.availability, OnboardingAvailability.three);
    expect(completedDraft!.activitySymptoms, [OnboardingActivitySymptom.none]);
    expect(find.text('Good to see you'), findsOneWidget);
  });

  testWidgets('symptom none option clears other local selections', (
    tester,
  ) async {
    LocalOnboardingDraft? completedDraft;

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
        onOnboardingCompleted: (draft) {
          completedDraft = draft;
        },
      ),
    );

    await advanceToSymptoms(tester);

    await tapText(tester, 'Chest pain or discomfort');
    await tapText(tester, 'None of these');
    await tapText(tester, 'Continue');

    expect(find.text('Step 12 of 13'), findsOneWidget);
    await tapTooltip(tester, 'Back');
    expect(find.text('Step 11 of 13'), findsOneWidget);

    await tapText(tester, 'Continue');
    expect(find.text('Step 12 of 13'), findsOneWidget);

    await answerSingle(tester, 'Balanced beginner plan');
    await tapText(tester, 'Create my preview plan');

    expect(completedDraft, isNotNull);
    expect(completedDraft!.activitySymptoms, [OnboardingActivitySymptom.none]);
  });

  testWidgets('onboarding avoids forbidden backend-owned and medical claims', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    for (final forbidden in [
      'safe to run',
      'medically cleared',
      'diagnosed',
      'risk score',
      'approved',
      'published',
      'official plan',
      'Level',
      'XP',
      'rank',
      'leaderboard',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }
  });

  testWidgets('incomplete preview uses the generator fallback path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OnboardingPreviewBody(answers: <String, Object>{}),
          ),
        ),
      ),
    );

    expect(find.text('2 sessions / week'), findsOneWidget);
    expect(find.text('Day 1 · Walk-run session'), findsOneWidget);
    expect(find.text('Day 2 · Walk-run session'), findsOneWidget);
    expect(find.text('First week preview'), findsOneWidget);
  });
}
