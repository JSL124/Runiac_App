import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/home/domain/guide/home_guide_agent.dart';
import 'package:runiac_app/features/home/domain/guide/rule_based_home_guide_agent.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_background_sequence.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_map.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_map_model.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';

import 'support/plan_family_test_drafts.dart';

const HomeGuideRequest _guideRequest = HomeGuideRequest(
  planTitle: 'First 10K Preparation',
  weekNumber: 1,
  weekFocus: 'Build a steady habit',
  dayLabel: 'Mon',
  workoutTitle: 'Easy Run',
  durationMinutes: 20,
  intensityLabel: 'Gentle',
  description: 'A relaxed run to build your habit.',
  supportiveNote: 'Keep the pace conversational.',
);

BeginnerAdaptivePlanSnapshot _plan() {
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

HomeStageMapModel _model(BeginnerAdaptivePlanSnapshot plan) {
  return buildHomeStageMapModel(
    plan: plan,
    completedScheduledWorkoutIds: const <String>{},
    activeWeekNumber: plan.weeks.first.weekNumber,
    backgroundSequence: homeStageBackgroundSequence(
      planId: plan.id,
      weekCount: plan.weeks.length,
    ),
  );
}

int _assetImageCount(WidgetTester tester, String assetName) {
  return tester
      .widgetList<Image>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == assetName,
        ),
      )
      .length;
}

void main() {
  testWidgets('empty state keeps a working header with the streak number', (
    WidgetTester tester,
  ) async {
    var notifications = 0;
    var profile = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeStageMap(
            model: null,
            streakCount: 4,
            unreadNotificationCount: 2,
            levelBadgeLabel: 'Lv.3',
            levelProgressFraction: 0.5,
            onNotifications: () => notifications++,
            onProfile: () => profile++,
            onTapTodayStage: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your journey map is waiting'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // streak number only, no "days"
    expect(find.textContaining('days'), findsNothing);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.tap(find.bySemanticsLabel('Profile'));
    expect(notifications, 1);
    expect(profile, 1);
  });

  testWidgets('active plan renders stage stones and a tappable today stage', (
    WidgetTester tester,
  ) async {
    final plan = _plan();
    final model = _model(plan);
    var todayTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeStageMap(
            model: model,
            streakCount: 0,
            onNotifications: () {},
            onProfile: () {},
            onTapTodayStage: () => todayTaps++,
          ),
        ),
      ),
    );
    // Do not settle: today's stage runs a gentle repeating pulse.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      _assetImageCount(
        tester,
        'assets/images/home/stages/dashboard_stage_run.png',
      ),
      greaterThan(0),
    );
    expect(
      _assetImageCount(
        tester,
        'assets/images/home/stages/dashboard_stage_rest.png',
      ),
      greaterThan(0),
    );

    final todayStage = find.bySemanticsLabel("Today's stage");
    expect(todayStage, findsOneWidget);
    await tester.tap(todayStage);
    await tester.pump();
    expect(todayTaps, 1);

    // At least one weekday caption (e.g. MON) renders near the stones.
    expect(find.text('MON'), findsWidgets);
  });

  testWidgets('tapping today stage in the app opens the workout detail', (
    WidgetTester tester,
  ) async {
    final monday = DateTime(2026, 6, 22); // a Monday
    final plan = _plan().withStartsOnDate(generatedPlanDateLabel(monday));
    final store = CurrentSessionGeneratedPlanStore();
    expect(store.setActivePlan(plan), isTrue);
    addTearDown(store.dispose);

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        enableForegroundGps: false,
        youProgressToday: monday,
        currentSessionGeneratedPlanStore: store,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final todayStage = find.bySemanticsLabel("Today's stage");
    expect(todayStage, findsOneWidget);

    await tester.tap(todayStage);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Workout detail'), findsOneWidget);
  });

  group('guide speech bubble', () {
    const characterTapTarget = ValueKey<String>('homeGuideCharacterTapTarget');

    testWidgets(
      'auto-appears with the rule-based message when there is a today stage',
      (WidgetTester tester) async {
        final plan = _plan();
        final model = _model(plan);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeStageMap(
                model: model,
                onNotifications: () {},
                onProfile: () {},
                onTapTodayStage: () {},
                guideAgent: const RuleBasedHomeGuideAgent(),
                guideRequest: _guideRequest,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(); // resolve the guide agent future
        await tester.pump(const Duration(milliseconds: 50));

        // The bubble auto-opens once the guide message resolves, and the
        // character's tap target only exists while a bubble can be shown.
        expect(find.byKey(characterTapTarget), findsOneWidget);
        expect(find.textContaining('Easy Run'), findsWidgets);
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      },
    );

    testWidgets('dismissing hides it, tapping the character re-opens it', (
      WidgetTester tester,
    ) async {
      final plan = _plan();
      final model = _model(plan);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeStageMap(
              model: model,
              onNotifications: () {},
              onProfile: () {},
              onTapTodayStage: () {},
              guideAgent: const RuleBasedHomeGuideAgent(),
              guideRequest: _guideRequest,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.ensureVisible(find.byIcon(Icons.close_rounded));
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await tester.ensureVisible(find.byKey(characterTapTarget));
      await tester.tap(find.byKey(characterTapTarget));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.textContaining('Easy Run'), findsWidgets);
    });

    testWidgets('never shows without an active plan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeStageMap(
              model: null,
              onNotifications: () {},
              onProfile: () {},
              onTapTodayStage: () {},
              guideAgent: const RuleBasedHomeGuideAgent(),
              guideRequest: _guideRequest,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(characterTapTarget), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.textContaining('Easy Run'), findsNothing);
    });
  });
}
