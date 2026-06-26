import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/core/theme/runiac_colors.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'package:runiac_app/features/you/presentation/adapters/generated_plan_you_display_adapter.dart';
import 'package:runiac_app/features/you/presentation/data/weekly_workout_demo_snapshots.dart';
import 'package:runiac_app/features/you/presentation/weekly_workout_detail_screen.dart';
import 'package:runiac_app/features/you/presentation/widgets/you_plans_surface.dart';

import 'support/plan_family_test_drafts.dart';

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

DateTime _weekdayDate(int weekday) {
  return DateTime(2026, 6, 21 + weekday);
}

Future<void> _pumpGeneratedPlans(
  WidgetTester tester, {
  required DateTime currentDate,
}) async {
  final generatedPlan = generatedYouPlanDisplayFromSnapshot(
    _tenKPerformancePlan(),
    currentDate: currentDate,
  );
  await tester.pumpWidget(
    MaterialApp(home: _GeneratedPlansHarness(generatedPlan: generatedPlan!)),
  );
}

Future<void> _openWorkoutDetail(WidgetTester tester, String rowText) async {
  await tester.ensureVisible(find.text(rowText));
  await tester.tap(find.text(rowText));
  await tester.pumpAndSettle();
}

bool _rowWithTextHasColor(
  WidgetTester tester,
  String rowText,
  Color expectedColor,
) {
  final rowFinder = find.ancestor(
    of: find.text(rowText),
    matching: find.byType(Container),
  );

  for (final container in tester.widgetList<Container>(rowFinder)) {
    final decoration = container.decoration;
    if (decoration is BoxDecoration && decoration.color == expectedColor) {
      return true;
    }
  }

  return false;
}

class _GeneratedPlansHarness extends StatefulWidget {
  const _GeneratedPlansHarness({required this.generatedPlan});

  final GeneratedYouPlanDisplay generatedPlan;

  @override
  State<_GeneratedPlansHarness> createState() => _GeneratedPlansHarnessState();
}

class _GeneratedPlansHarnessState extends State<_GeneratedPlansHarness> {
  WeeklyWorkoutDetailSnapshot? _detail;

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    if (detail != null) {
      return WeeklyWorkoutDetailScreen(
        snapshot: detail,
        onBack: () => setState(() => _detail = null),
        enableForegroundGps: false,
        showEditScheduleAction: detail.canEditSchedule,
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: YouPlansSurface(
          generatedPlan: widget.generatedPlan,
          onViewGoalPlan: () {},
          onViewWorkout: (snapshot) => setState(() => _detail = snapshot),
          onViewExpertPlans: () {},
        ),
      ),
    );
  }
}

void main() {
  testWidgets('today generated running row is orange and shows Start only', (
    tester,
  ) async {
    // Given: Tuesday is the injected current day for the generated plan.
    await _pumpGeneratedPlans(
      tester,
      currentDate: _weekdayDate(DateTime.tuesday),
    );

    // Then: today's generated running row is visually highlighted.
    expect(
      _rowWithTextHasColor(
        tester,
        'Controlled Steady Run',
        RuniacColors.accentOrange.withValues(alpha: 0.10),
      ),
      isTrue,
    );

    // When: the matching generated running row is opened.
    await _openWorkoutDetail(tester, 'Controlled Steady Run');

    // Then: today's generated detail can start, but cannot edit schedule.
    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Tue · Controlled Steady Run'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Start this run'), findsOneWidget);
    expect(find.text('Edit schedule'), findsNothing);
  });

  testWidgets(
    'future generated running row opens with Edit but without Start',
    (tester) async {
      // Given: Tuesday is today and Thursday is a future generated workout.
      await _pumpGeneratedPlans(
        tester,
        currentDate: _weekdayDate(DateTime.tuesday),
      );

      // When: a future generated running row is opened.
      await _openWorkoutDetail(tester, 'Recovery Run');

      // Then: the future detail can be rescheduled, but cannot start today.
      expect(find.text('Workout detail'), findsOneWidget);
      expect(find.text('Thu · Recovery Run'), findsOneWidget);
      expect(find.text('Edit schedule'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('Start this run'), findsNothing);
    },
  );

  testWidgets('past generated running row opens with Edit but without Start', (
    tester,
  ) async {
    // Given: Thursday is today and Monday is a past generated workout.
    await _pumpGeneratedPlans(
      tester,
      currentDate: _weekdayDate(DateTime.thursday),
    );

    // When: a past generated running row is opened.
    await _openWorkoutDetail(tester, 'Comfortable Run');

    // Then: the past detail can be rescheduled, but cannot start today.
    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Mon · Comfortable Run'), findsOneWidget);
    expect(find.text('Edit schedule'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Start this run'), findsNothing);
  });

  testWidgets('rest generated row remains non-tappable', (tester) async {
    // Given: a generated weekly plan includes rest rows.
    await _pumpGeneratedPlans(
      tester,
      currentDate: _weekdayDate(DateTime.tuesday),
    );

    // When: a rest row is tapped.
    await tester.ensureVisible(find.text('Rest').first);
    await tester.tap(find.text('Rest').first);
    await tester.pumpAndSettle();

    // Then: no detail, Start CTA, or edit action appears.
    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('Start this run'), findsNothing);
    expect(find.text('Edit schedule'), findsNothing);
  });

  testWidgets('today Start opens Run launch with planned workout context', (
    tester,
  ) async {
    // Given: the user is viewing today's generated workout detail.
    await _pumpGeneratedPlans(
      tester,
      currentDate: _weekdayDate(DateTime.tuesday),
    );
    await _openWorkoutDetail(tester, 'Controlled Steady Run');
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    // When: the planned Start CTA is pressed.
    await tester.tap(find.text('Start this run'));
    await tester.pumpAndSettle();

    // Then: Run launch opens with planned context and progress is unchanged.
    expect(find.text('CONTROLLED STEADY RUN'), findsOneWidget);
    expect(find.text('25 min'), findsOneWidget);
    expect(find.text('10K Performance Build'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('0 of 4 done'), findsNothing);
    expect(find.textContaining('completed', findRichText: true), findsNothing);
  });

  testWidgets('normal Run tab launch keeps static fallback context', (
    tester,
  ) async {
    // Given: the app opens without a planned workout launch context.
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    // When: the normal Run tab is opened.
    await tester.tap(find.byTooltip('Run'));
    await tester.pumpAndSettle();

    // Then: the existing static Run launch fallback is unchanged.
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('km easy run'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('CONTROLLED STEADY RUN'), findsNothing);
  });
}
