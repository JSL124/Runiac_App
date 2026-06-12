import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/you/presentation/widgets/compact_run_activity_card.dart';

Future<void> _openYouTab(WidgetTester tester) async {
  await tester.pumpWidget(const RuniacApp());
  await tester.tap(find.text('You'));
  await tester.pumpAndSettle();
}

void main() {
  test('You static demo snapshots live outside presentation widgets', () {
    // Given: the You feature keeps demo/read-only data behind a data boundary.
    final dataFiles = [
      'lib/features/you/presentation/data/you_overview_demo_snapshots.dart',
      'lib/features/you/presentation/data/activity_history_demo_snapshots.dart',
      'lib/features/you/presentation/data/goal_plan_demo_snapshots.dart',
      'lib/features/you/presentation/data/weekly_workout_demo_snapshots.dart',
      'lib/features/you/presentation/data/expert_plan_demo_snapshots.dart',
    ];

    // Then: each expected snapshot file exists for backend-readiness.
    for (final path in dataFiles) {
      expect(File(path).existsSync(), isTrue, reason: '$path must exist');
    }

    final presentationFiles = {
      'lib/features/you/presentation/you_tab.dart': [
        'const _progressSnapshot =',
        'const _plansSnapshot =',
        'class _YouProgressSnapshot',
        'class _YouPlansSnapshot',
      ],
      'lib/features/you/presentation/activity_history_screen.dart': [
        'const activityHistoryDisplayData =',
        'class _ActivityHistoryMonth',
      ],
      'lib/features/you/presentation/goal_plan_detail_screen.dart': [
        'const goalPlanDisplaySnapshot =',
        'const _sampleDailyPlan =',
      ],
      'lib/features/you/presentation/weekly_workout_detail_screen.dart': [
        'const weeklyWorkoutDetailSnapshot =',
        'const saturdayWeeklyWorkoutDetailSnapshot =',
      ],
      'lib/features/you/presentation/expert_plan_list_screen.dart': [
        'const _expertPlanFilters =',
        'const _expertPlans =',
        'class _ExpertPlanDisplay',
      ],
      'lib/features/you/presentation/expert_plan_detail_screen.dart': [
        'const expertPlanDetailSnapshot =',
      ],
    };

    // Then: large presentation widgets no longer own static/demo snapshots.
    for (final entry in presentationFiles.entries) {
      final source = File(entry.key).readAsStringSync();
      for (final forbiddenSnippet in entry.value) {
        expect(
          source,
          isNot(contains(forbiddenSnippet)),
          reason: '${entry.key} still contains $forbiddenSnippet',
        );
      }
    }
  });

  testWidgets('You page shows progress overview sections when selected', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    expect(find.text('You'), findsWidgets);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Plans'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('12.4'), findsOneWidget);
    expect(find.text('3 runs this week'), findsOneWidget);
    expect(find.text('Consistency Streak'), findsOneWidget);
    expect(find.text('6 days'), findsOneWidget);
    expect(find.text('Running Calendar'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Recent Running'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Recent Running')).dx,
      lessThan(tester.getTopLeft(find.text('See all')).dx),
    );
    expect(find.text('Saturday Night Run'), findsOneWidget);
    expect(find.text('Morning Easy Run'), findsOneWidget);
    expect(find.text('Recovery Jog'), findsOneWidget);
    final recentRunCards = find.byType(CompactRunActivityCard);
    expect(recentRunCards, findsNWidgets(3));
    expect(
      find.descendant(
        of: recentRunCards,
        matching: find.byIcon(Icons.chevron_right_rounded),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(of: recentRunCards, matching: find.text('DISTANCE')),
      findsNWidgets(3),
    );
    expect(
      find.descendant(of: recentRunCards, matching: find.text('AVG PACE')),
      findsNWidgets(3),
    );
    expect(
      find.descendant(of: recentRunCards, matching: find.text('TIME')),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: recentRunCards,
        matching: find.byType(VerticalDivider),
      ),
      findsNWidgets(6),
    );
    expect(find.text('More Activities'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('more_activities_chevron')),
      findsOneWidget,
    );
    expect(find.text('Run Level'), findsOneWidget);
    expect(find.text('Level 12 Runner'), findsOneWidget);
  });

  testWidgets('Recent Running card opens selected summary with matching data', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    const runs = [
      (
        title: 'Saturday Night Run',
        dateTime: '4/11/26 · 9:18 PM',
        distance: '4.03',
        pace: '6’30”',
        duration: '30:15',
        route: 'East Coast Park Night Loop',
      ),
      (
        title: 'Morning Easy Run',
        dateTime: '4/11/26 · 6:45 AM',
        distance: '3.20',
        pace: '7’05”',
        duration: '24:10',
        route: 'Neighbourhood Easy Loop',
      ),
      (
        title: 'Recovery Jog',
        dateTime: '4/11/26 · 8:10 PM',
        distance: '5.17',
        pace: '7’40”',
        duration: '39:38',
        route: 'Park Connector Recovery Loop',
      ),
    ];

    for (final run in runs) {
      final cardButton = find.byKey(
        ValueKey('recent_running_card_${run.title}'),
      );
      expect(cardButton, findsOneWidget);

      await Scrollable.ensureVisible(
        tester.element(cardButton),
        alignment: 0.55,
      );
      await tester.pumpAndSettle();

      await tester.tap(cardButton);
      await tester.pumpAndSettle();

      expect(find.text(run.title), findsOneWidget);
      expect(find.text(run.dateTime), findsOneWidget);
      expect(find.text(run.route), findsOneWidget);
      expect(find.text(run.distance), findsOneWidget);
      expect(find.text(run.pace), findsOneWidget);
      expect(find.text(run.duration), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Share Route'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);

      await tester.tap(find.byTooltip('Back to cool down'));
      await tester.pumpAndSettle();
      expect(find.text('Recent Running'), findsOneWidget);
    }
  });

  testWidgets('Recent Running See all opens Activity History', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    final seeAll = find.byKey(const ValueKey('recent_running_see_all'));
    await Scrollable.ensureVisible(tester.element(seeAll), alignment: 0.55);
    await tester.pumpAndSettle();
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    expect(find.text('Activity History'), findsOneWidget);
    expect(find.text('All years'), findsOneWidget);
    expect(find.text('All months'), findsOneWidget);
  });

  testWidgets(
    'More Activities opens Activity History with shell navigation preserved',
    (WidgetTester tester) async {
      await _openYouTab(tester);

      await tester.ensureVisible(find.text('More Activities'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('More Activities'));
      await tester.pumpAndSettle();

      expect(find.text('Activity History'), findsOneWidget);
      expect(find.text('Review your runs at your own pace.'), findsNothing);
      expect(find.text('All years'), findsOneWidget);
      expect(find.text('All months'), findsOneWidget);
      expect(find.text('Showing your recent activities'), findsOneWidget);

      for (final label in const ['Home', 'Maps', 'Run', 'Leaderboard', 'You']) {
        expect(find.text(label), findsWidgets);
      }
    },
  );

  testWidgets('Activity History groups mock activities by month', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.ensureVisible(find.text('More Activities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More Activities'));
    await tester.pumpAndSettle();

    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('April 2026'), findsOneWidget);

    for (final title in const [
      'Saturday Night Run',
      'Easy Morning Jog',
      'Riverside Recovery',
      'Sunset Loop',
      'Tuesday Tempo',
      'Park Walk + Run',
      'First 5K Attempt',
      'Gentle Start',
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    expect(find.byType(CompactRunActivityCard), findsNWidgets(8));
    expect(find.byType(VerticalDivider), findsNWidgets(16));
  });

  testWidgets('Activity History opens run summary without XP update action', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.ensureVisible(find.text('More Activities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More Activities'));
    await tester.pumpAndSettle();

    final saturdayCard = find.byKey(
      const ValueKey('activity_history_card_Saturday Night Run'),
    );
    expect(saturdayCard, findsOneWidget);

    await tester.tap(saturdayCard);
    await tester.pumpAndSettle();

    expect(find.text('Saturday Night Run'), findsOneWidget);
    expect(find.text('6 Jun 2026 · 9:18 PM'), findsOneWidget);
    expect(find.text('5.12'), findsOneWidget);
    expect(find.text('6\'45"'), findsOneWidget);
    expect(find.text('34:32'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);
  });

  testWidgets('You page shows static plans overview when Plans is selected', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    expect(find.text('10K Preparation'), findsOneWidget);
    expect(find.text('Week 3 of 8'), findsOneWidget);
    expect(find.text('43% completed'), findsOneWidget);
    expect(find.text('43%'), findsOneWidget);
    expect(find.text('Next Milestone'), findsOneWidget);
    expect(find.text('Complete 6 km comfortably'), findsOneWidget);
    expect(find.text('View Goal Plan'), findsOneWidget);
    expect(find.text("This Week's Plan"), findsOneWidget);
    expect(find.text("This Week's 10K Preparation Plan"), findsNothing);
    expect(find.text('Week 3 of 8 · 10K Plan'), findsNothing);
    expect(find.text('2 of 3 done'), findsOneWidget);
    expect(find.text('Planned Runs'), findsNothing);
    expect(find.text('Remaining'), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'3\s+Planned Runs')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'2\s+Completed')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'1\s+Remaining')), findsNothing);
    expect(
      find.text('Take each easy run as a steady step forward.'),
      findsNothing,
    );
    expect(find.text('Running Calendar'), findsNothing);
    expect(find.text('Recent Running'), findsNothing);

    for (final text in [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
      'Rest Day',
      '15 min walk-run',
      '20 min easy run',
      'Upcoming · 7:30 AM',
    ]) {
      expect(find.text(text), findsWidgets);
    }
    expect(find.text('Rest Day'), findsNWidgets(4));
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Upcoming · 7:30 AM'), findsOneWidget);
    expect(find.text('Scheduled · 8:00 AM'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Explore expert plans'), findsOneWidget);
    expect(
      find.text('Browse coach-reviewed plans at your own pace.'),
      findsOneWidget,
    );
    expect(find.text('Coach-created'), findsOneWidget);
    expect(find.text('First 5K'), findsOneWidget);
    expect(find.text('10K'), findsOneWidget);
    expect(find.text('Half Marathon'), findsOneWidget);
    expect(find.text('Full Marathon'), findsOneWidget);
    expect(find.text('Explore Expert Plans'), findsOneWidget);
  });

  testWidgets(
    'expert plan list opens from You Plans and renders approved static content',
    (WidgetTester tester) async {
      await _openYouTab(tester);

      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Explore Expert Plans'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Explore Expert Plans'));
      await tester.pumpAndSettle();

      expect(find.text('Expert Plans'), findsOneWidget);
      expect(
        find.text('Browse coach-reviewed plans at your own pace.'),
        findsNothing,
      );
      expect(find.text('Search plans'), findsOneWidget);

      for (final filter in const [
        'Recommended',
        '5K',
        '10K',
        'Consistency',
        'Healthy Running',
        'Half',
        'Full',
      ]) {
        expect(find.text(filter), findsOneWidget);
      }

      for (final title in const [
        'First 5K Preparation',
        'Build Running Consistency',
        '10K Preparation',
        'Healthy Running Starter Plan',
        'Half Marathon Preparation',
        'Full Marathon Preparation',
      ]) {
        expect(find.text(title), findsOneWidget);
      }

      expect(find.text('Coach-created'), findsNothing);
      expect(find.text('Coach Verified'), findsNothing);
      expect(find.text('Weight Loss Starter Plan'), findsNothing);
      expect(
        find.text(
          'Plans are reviewed for beginner suitability. This is general fitness guidance, not medical advice.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('You page keeps plans controls visual only and backend safe', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    for (final forbidden in <Pattern>[
      RegExp('premium', caseSensitive: false),
      RegExp('locked', caseSensitive: false),
      RegExp(r'\bXP\b', caseSensitive: false),
      RegExp('rank', caseSensitive: false),
      RegExp('leaderboard', caseSensitive: false),
      RegExp('published', caseSensitive: false),
      RegExp('approved', caseSensitive: false),
      RegExp('missed', caseSensitive: false),
      RegExp('subscription', caseSensitive: false),
      RegExp('entitlement', caseSensitive: false),
      RegExp('eligible', caseSensitive: false),
      RegExp('publication', caseSensitive: false),
      RegExp('approval', caseSensitive: false),
      RegExp('admin review', caseSensitive: false),
    ]) {
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.textContaining(forbidden),
        ),
        findsNothing,
      );
    }

    await tester.tap(find.text('View Goal Plan'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('10K Goal Plan'), findsOneWidget);
    expect(find.text('10K Preparation'), findsWidgets);

    await tester.tap(find.byTooltip('Back to Plans'));
    await tester.pumpAndSettle();
    expect(find.text("This Week's Plan"), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('15 min walk-run')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 min walk-run'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('15 min walk-run'), findsOneWidget);

    await tester.ensureVisible(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Activity History'), findsNothing);
    expect(find.text('Expert Plans'), findsOneWidget);
    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(find.text('Explore Expert Plans'), findsNothing);

    await tester.tap(find.byTooltip('Back to Plans'));
    await tester.pumpAndSettle();
    expect(find.text("This Week's Plan"), findsOneWidget);
  });

  testWidgets(
    'goal plan detail matches Plan Preview header and timeline alignment',
    (WidgetTester tester) async {
      // Given: the static Goal Plan Detail screen is open from You > Plans.
      await _openYouTab(tester);
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Goal Plan'));
      await tester.pumpAndSettle();

      // Then: the header follows the Plan Preview fixed-header pattern.
      final backButton = find.byTooltip('Back to Plans');
      expect(backButton, findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('10K Goal Plan'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('10K Goal Plan')).dx,
        greaterThan(
          tester.getTopLeft(find.byIcon(Icons.chevron_left_rounded)).dx,
        ),
      );

      // Then: a long blue/orange content accent strip starts the scroll body.
      final accentStrip = find.byKey(
        const ValueKey('goal_plan_detail_header_accent_strip'),
      );
      expect(accentStrip, findsOneWidget);
      expect(tester.getSize(accentStrip).width, greaterThan(650));
      expect(
        tester.getTopLeft(accentStrip).dy,
        greaterThan(tester.getBottomLeft(backButton).dy),
      );
      expect(
        tester.getTopLeft(accentStrip).dy,
        lessThan(tester.getTopLeft(find.text('10K Preparation').first).dy),
      );

      // Then: timeline markers align with each Week label row.
      for (final week in const ['Week 1', 'Week 3', 'Week 8']) {
        final marker = find.byKey(ValueKey('goal_plan_detail_marker_$week'));
        expect(marker, findsOneWidget);

        final markerCenter = tester.getCenter(marker).dy;
        final weekCenter = tester.getCenter(find.text(week)).dy;
        expect((markerCenter - weekCenter).abs(), lessThanOrEqualTo(1.0));
      }

      // Then: progress state is visual-only on week rows.
      expect(find.text('Completed'), findsNothing);
      expect(find.text('Current'), findsNothing);
      expect(find.text('Upcoming'), findsNothing);
      expect(find.byIcon(Icons.check), findsWidgets);
      for (final summary in const [
        '4 days · 8 km',
        '4 days · 10 km',
        '4 days · 12 km',
        '4 days · 14 km',
        '4 days · 16 km',
        '4 days · 18 km',
        '4 days · 20 km',
        '4 days · 10K',
      ]) {
        expect(find.text(summary), findsNothing);
      }
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('goal_plan_detail_marker_Week 3')),
          matching: find.byIcon(Icons.directions_run),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('goal_plan_detail_marker_Week 4')),
        findsOneWidget,
      );
      expect(
        tester
            .getTopRight(
              find.byKey(
                const ValueKey('goal_plan_detail_chevron_Week 3_collapsed'),
              ),
            )
            .dx,
        greaterThan(tester.getTopRight(find.text('Base Endurance').first).dx),
      );

      // Then: the current week highlight spans the whole row surface.
      final currentHighlight = find.byKey(
        const ValueKey('goal_plan_detail_current_week_highlight'),
      );
      expect(currentHighlight, findsOneWidget);
      expect(tester.getSize(currentHighlight).width, greaterThan(650));

      // Then: all weekly dropdown plans are initially collapsed.
      expect(
        find.byKey(const ValueKey('goal_plan_detail_daily_plan_Week 3')),
        findsNothing,
      );
      for (final day in const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ]) {
        expect(find.text(day), findsNothing);
      }

      // When: the current week is expanded.
      await tester.tap(
        find.byKey(const ValueKey('goal_plan_detail_week_toggle_Week 3')),
      );
      await tester.pumpAndSettle();

      // Then: the sample onboarding run/rest mapping is visible in order.
      final weekThreePlan = find.byKey(
        const ValueKey('goal_plan_detail_daily_plan_Week 3'),
      );
      expect(weekThreePlan, findsOneWidget);
      for (final day in const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ]) {
        expect(
          find.byKey(ValueKey('goal_plan_detail_day_Week 3_$day')),
          findsOneWidget,
        );
      }
      expect(find.text('Easy Run'), findsNWidgets(2));
      expect(find.text('Tempo Run'), findsOneWidget);
      expect(find.text('Long Run'), findsOneWidget);
      expect(find.text('Rest'), findsNWidgets(3));
      expect(find.text('3 km'), findsOneWidget);
      expect(find.text('25 min'), findsOneWidget);
      expect(find.text('4 km'), findsOneWidget);
      expect(find.text('5 km'), findsOneWidget);
      expect(find.text('0 min'), findsNWidgets(3));
      expect(find.text('4 days · 12 km'), findsNothing);
      expect(
        find.byKey(const ValueKey('goal_plan_detail_chevron_Week 3_expanded')),
        findsOneWidget,
      );

      // When: the same week is tapped again.
      await tester.tap(
        find.byKey(const ValueKey('goal_plan_detail_week_toggle_Week 3')),
      );
      await tester.pumpAndSettle();

      // Then: it collapses back to the static week-list state.
      expect(weekThreePlan, findsNothing);
      expect(find.text('Monday'), findsNothing);
      expect(
        find.byKey(const ValueKey('goal_plan_detail_chevron_Week 3_collapsed')),
        findsOneWidget,
      );

      // When: the detail content scrolls.
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -700));
      await tester.pumpAndSettle();

      // Then: the header remains available, while the accent strip is not sticky.
      expect(find.text('10K Goal Plan'), findsOneWidget);
      expect(backButton, findsOneWidget);
      expect(
        tester.getTopLeft(accentStrip).dy,
        lessThan(tester.getTopLeft(backButton).dy),
      );
    },
  );

  testWidgets('first expert plan opens static preview detail only', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Search plans'), findsOneWidget);
    expect(find.text('View Plan'), findsNWidgets(6));

    await Scrollable.ensureVisible(
      tester.element(find.text('Build Running Consistency')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Plan').at(1));
    await tester.pumpAndSettle();

    expect(find.text('Plan preview is coming soon.'), findsOneWidget);
    expect(find.text('Expert Plans'), findsOneWidget);
    expect(find.text('Plan Preview'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);

    await Scrollable.ensureVisible(
      tester.element(find.text('Search plans')),
      alignment: 0.1,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search plans'));
    await tester.pumpAndSettle();

    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(find.text('Full Marathon Preparation'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('5K'));
    await tester.pumpAndSettle();

    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(find.text('Full Marathon Preparation'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);

    await tester.tap(find.text('View Plan').first);
    await tester.pumpAndSettle();

    expect(find.text('Plan Preview'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(
      find.byKey(const ValueKey('expert_plan_detail_header_accent_strip')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('expert_plan_detail_header_accent_strip'),
            ),
          )
          .width,
      greaterThan(650),
    );
    expect(
      tester.getTopLeft(find.text('Plan Preview')).dx,
      greaterThan(
        tester.getTopLeft(find.byIcon(Icons.chevron_left_rounded)).dx,
      ),
    );
    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(
      find.text('A gentle plan for building confidence toward your first 5K.'),
      findsOneWidget,
    );
    expect(find.text('Coach Insight'), findsOneWidget);
    expect(find.text('Coach Verified'), findsOneWidget);
    expect(find.text('6 weeks'), findsOneWidget);
    expect(find.text('3 runs/week'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Low pressure'), findsOneWidget);
    expect(find.text('Who this is for'), findsNothing);
    expect(find.text('Week 6'), findsOneWidget);
    expect(find.text('First 5K attempt'), findsOneWidget);
    expect(find.text("What you'll do"), findsNothing);
    expect(find.text('2 walk-run sessions'), findsNothing);
    expect(find.text('1 easy recovery walk'), findsNothing);
    expect(find.text('Rest between run days'), findsNothing);
    expect(find.text('Short easy intervals'), findsNothing);

    await tester.ensureVisible(find.text('Week 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week 1'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsOneWidget);
    expect(find.text('1 easy recovery walk'), findsOneWidget);
    expect(find.text('Rest between run days'), findsOneWidget);

    await tester.ensureVisible(find.text('Week 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week 2'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsOneWidget);
    expect(find.text('Short easy intervals'), findsOneWidget);
    expect(find.text('Comfortable walking breaks'), findsOneWidget);
    expect(find.text('Focus on showing up consistently'), findsOneWidget);

    await tester.tap(find.text('Week 2'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsOneWidget);
    expect(find.text('Short easy intervals'), findsNothing);

    await tester.ensureVisible(find.text('Week 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week 1'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsNothing);

    expect(find.text('Select This Plan'), findsOneWidget);
    expect(
      find.text('Plan selection is not available in this preview.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'This preview does not enroll you in a plan or update your progress.',
      ),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Expert Plans'), findsNothing);
    expect(find.text('10K Goal Plan'), findsNothing);
    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('Enroll'), findsNothing);
    expect(find.text('Unlock Premium'), findsNothing);
    expect(find.text('Activate Plan'), findsNothing);

    await tester.ensureVisible(find.text('Select This Plan'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Plan Preview')).dy, greaterThan(0));
    expect(
      tester.getTopLeft(find.byTooltip('Back to Expert Plans')).dy,
      greaterThan(0),
    );

    await tester.tap(find.text('Select This Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Preview'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Enrolled'), findsNothing);

    await tester.tap(find.byTooltip('Back to Expert Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Expert Plans'), findsOneWidget);

    await tester.tap(find.text('View Plan').first);
    await tester.pumpAndSettle();

    expect(find.text('Plan Preview'), findsOneWidget);
    expect(find.text('2 walk-run sessions'), findsNothing);
    expect(find.text('Short easy intervals'), findsNothing);
  });

  testWidgets('Upcoming weekly workout opens static workout detail only', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // When: the upcoming Thu workout row is tapped.
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // Then: the static workout instruction detail is shown.
    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Thursday · Easy Run'), findsOneWidget);
    expect(find.text('20 min easy run'), findsOneWidget);
    expect(find.text('A gentle 20 minutes.'), findsNothing);
    expect(
      find.text('You should be able to chat the whole way through.'),
      findsNothing,
    );
    expect(find.text('No race — just rhythm.'), findsNothing);
    expect(find.text('Suggested pace'), findsOneWidget);
    expect(find.text('Warm-up'), findsOneWidget);
    expect(find.text('Easy run'), findsOneWidget);
    expect(find.text('Cool-down'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Start This Run'), findsOneWidget);
  });

  testWidgets('Saturday weekly workout opens matching instruction preview', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // When: the Saturday easy-run row is tapped.
    await Scrollable.ensureVisible(
      tester.element(find.text('Sat')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sat'));
    await tester.pumpAndSettle();

    // Then: the same static instruction sheet opens with Saturday labeling.
    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Saturday · Easy Run'), findsOneWidget);
    expect(find.text('Thursday · Easy Run'), findsNothing);
    expect(find.text('20 min easy run'), findsOneWidget);
    expect(find.text('A gentle 20 minutes.'), findsNothing);
    expect(find.text('Suggested pace'), findsOneWidget);
    expect(find.text('Warm-up'), findsOneWidget);
    expect(find.text('Easy run'), findsOneWidget);
    expect(find.text('Cool-down'), findsOneWidget);

    await tester.tap(find.text('Edit schedule'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Current schedule'), findsOneWidget);
    expect(find.text('Saturday'), findsOneWidget);
    expect(find.text('Sat · 7:30 AM'), findsNothing);
    expect(find.text('Saturday · 7:30 AM'), findsNothing);
  });

  testWidgets('Only available workout instruction rows show tap affordance', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // Then: Thu and Sat expose detail chevrons, while completed and rest rows do not.
    expect(
      find.byKey(const ValueKey('weekly_workout_detail_chevron')),
      findsNWidgets(2),
    );
  });

  testWidgets(
    'Weekly plan rows keep day column aligned across affordance states',
    (WidgetTester tester) async {
      // Given: the static Plans weekly schedule is visible.
      await _openYouTab(tester);
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();

      // Then: tappable workout rows use the same day-column grid as rest/completed rows.
      final monLeft = tester.getTopLeft(find.text('Mon')).dx;
      final tueLeft = tester.getTopLeft(find.text('Tue')).dx;
      final thuLeft = tester.getTopLeft(find.text('Thu')).dx;
      final satLeft = tester.getTopLeft(find.text('Sat')).dx;

      expect(tueLeft, monLeft);
      expect(thuLeft, monLeft);
      expect(satLeft, monLeft);
    },
  );

  testWidgets('Rest and completed weekly rows do not open workout detail', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // Then: only available instruction previews expose detail chevrons.
    expect(
      find.byKey(const ValueKey('weekly_workout_detail_chevron')),
      findsNWidgets(2),
    );

    // When: a completed workout row is tapped.
    await Scrollable.ensureVisible(
      tester.element(find.text('15 min walk-run')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 min walk-run'));
    await tester.pumpAndSettle();

    // Then: no completed-workout detail flow is introduced.
    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('15 min walk-run'), findsOneWidget);

    // When: a Rest Day row is tapped.
    await tester.tap(find.text('Mon'));
    await tester.pumpAndSettle();

    // Then: no Rest Day detail flow is introduced.
    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('Rest Day'), findsWidgets);
  });

  testWidgets('Workout detail edit schedule is preview only', (
    WidgetTester tester,
  ) async {
    // Given: the static Workout detail screen is open.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // When: the preview-only Edit schedule action is opened.
    await tester.tap(find.text('Edit schedule'));
    await tester.pumpAndSettle();

    // Then: the bottom sheet presents a richer static preview without mutation.
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_schedule_drag_handle')),
      findsOneWidget,
    );
    expect(find.text('Edit schedule'), findsWidgets);
    final handleBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('edit_schedule_drag_handle')))
        .dy;
    final titleTop = tester.getTopLeft(find.text('Edit schedule').last).dy;
    expect(handleBottom, lessThan(titleTop));
    expect(
      find.byKey(const ValueKey('edit_schedule_brand_accent')),
      findsOneWidget,
    );
    expect(
      find.text('Preview only — changes are not saved yet.'),
      findsOneWidget,
    );
    final titleBottom = tester
        .getBottomLeft(find.text('Edit schedule').last)
        .dy;
    final accentTop = tester
        .getTopLeft(find.byKey(const ValueKey('edit_schedule_brand_accent')))
        .dy;
    final accentBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('edit_schedule_brand_accent')))
        .dy;
    final previewTop = tester
        .getTopLeft(find.text('Preview only — changes are not saved yet.'))
        .dy;
    expect(accentTop, greaterThan(titleBottom));
    expect(accentBottom, lessThan(previewTop));
    expect(find.text('Current schedule'), findsOneWidget);
    expect(find.text('Thu · 7:30 AM'), findsOneWidget);
    expect(find.text('Preview example'), findsOneWidget);
    expect(find.text('Fri · 7:30 AM'), findsOneWidget);
    expect(find.text('Suggested time previews'), findsNothing);
    expect(
      find.byKey(const ValueKey('edit_schedule_suggested_preview_row')),
      findsNothing,
    );
    expect(find.text('Tonight · 6:30 PM'), findsNothing);
    expect(find.text('Tomorrow morning · 7:30 AM'), findsNothing);
    expect(find.text('Weekend morning · 8:00 AM'), findsNothing);
    expect(find.text('Advanced preview'), findsOneWidget);
    expect(find.text('These options are examples only.'), findsOneWidget);
    expect(find.text('Select day'), findsOneWidget);
    for (final text in [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
      '07:00 AM',
      '08:00 AM',
      '06:30 PM',
      '07:30 PM',
    ]) {
      expect(find.text(text), findsWidgets);
    }
    expect(find.text('Select time'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_schedule_time_preview_grid')),
      findsOneWidget,
    );
    expect(find.text('Choose custom time'), findsOneWidget);
    expect(find.text('Why might you move it later?'), findsNothing);
    for (final reason in [
      'Busy at original time',
      'Feeling tired',
      'Bad weather',
      'Injury / discomfort',
      'Prefer another time',
      'Other',
    ]) {
      expect(find.text(reason), findsNothing);
    }
    expect(
      find.text(
        'You’ll be able to add a reason when schedule changes are enabled.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Saving schedule changes will be available later.'),
      findsOneWidget,
    );
    final saveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Save New Schedule'),
    );
    expect(saveButton.onPressed, isNull);
    expect(find.text('Close'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('Save New Schedule')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save New Schedule'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Saved'), findsNothing);

    await Scrollable.ensureVisible(tester.element(find.text('Close')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('Workout detail disables overscroll stretch locally', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Given: the static Workout detail screen is open on a constrained viewport.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // Then: the detail scroll surface disables overscroll stretch locally.
    expect(
      find.byKey(const ValueKey('workout_detail_no_overscroll')),
      findsOneWidget,
    );

    await tester.tap(find.text('Edit schedule'));
    await tester.pumpAndSettle();

    // And: the preview-only sheet uses the same no-stretch boundary locally.
    expect(
      find.byKey(const ValueKey('edit_schedule_no_overscroll')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Workout detail keeps Suggested pace metric compact', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Given: the static Workout detail screen is open on a narrow viewport.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    final headerTitle = tester.widget<Text>(
      find.byKey(const ValueKey('workout_detail_header_title')),
    );
    final headerTitleSize = tester.getSize(
      find.byKey(const ValueKey('workout_detail_header_title')),
    );
    final suggestedPaceLabel = tester.widget<Text>(
      find.byKey(const ValueKey('suggested_pace_metric_label')),
    );

    // Then: the centered header title has room before ellipsis is needed.
    expect(headerTitle.data, 'Workout detail');
    expect(headerTitle.maxLines, 1);
    expect(headerTitle.overflow, TextOverflow.ellipsis);
    expect(headerTitle.style?.fontFamily, isNull);
    expect(headerTitle.style?.decoration, isNot(TextDecoration.underline));
    expect(headerTitleSize.width, greaterThan(120));

    final dayLabel = tester.widget<Text>(find.text('Thursday · Easy Run'));
    final planTitle = tester.widget<Text>(find.text('20 min easy run'));
    expect(dayLabel.style?.fontFamily, isNull);
    expect(dayLabel.style?.decoration, isNot(TextDecoration.underline));
    expect(planTitle.style?.fontFamily, isNull);
    expect(planTitle.style?.decoration, isNot(TextDecoration.underline));

    // Then: the long metric label remains a compact single-line label.
    expect(suggestedPaceLabel.data, 'Suggested pace');
    expect(suggestedPaceLabel.maxLines, 1);
    expect(suggestedPaceLabel.softWrap, isFalse);
    expect(find.text('7:30 /km'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Workout detail start action opens run launch screen', (
    WidgetTester tester,
  ) async {
    // Given: the static Workout detail screen is open.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // When: Start This Run is tapped.
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start This Run'));
    await tester.pumpAndSettle();

    // Then: it routes only to the existing frontend run launch screen.
    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('Start This Run'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);

    for (final forbidden in <Pattern>[
      RegExp(r'\bXP\b', caseSensitive: false),
      RegExp('streak', caseSensitive: false),
      RegExp('rank', caseSensitive: false),
      RegExp('leaderboard', caseSensitive: false),
      RegExp('completed', caseSensitive: false),
      RegExp('saved', caseSensitive: false),
    ]) {
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.textContaining(forbidden),
        ),
        findsNothing,
      );
    }
  });

  testWidgets(
    'View Goal Plan opens static goal detail with bottom nav visible',
    (WidgetTester tester) async {
      // Given: the user is viewing the static Plans section in the You tab.
      await _openYouTab(tester);
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();

      // When: the user opens the current goal plan detail.
      await tester.tap(find.text('View Goal Plan'));
      await tester.pumpAndSettle();

      // Then: the static detail snapshot is shown without leaving the app shell.
      expect(find.text('10K Goal Plan'), findsOneWidget);
      expect(find.text('10K Preparation'), findsWidgets);
      expect(find.text('Week 3 of 8'), findsOneWidget);
      expect(find.text('43% completed'), findsOneWidget);
      expect(find.text('Current Phase'), findsOneWidget);
      expect(find.text('Base Endurance'), findsWidgets);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Maps'), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
    },
  );

  testWidgets('Goal Plan Detail renders static timeline rows only', (
    WidgetTester tester,
  ) async {
    // Given: the static Goal Plan Detail screen is open.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Goal Plan'));
    await tester.pumpAndSettle();

    // Then: every accepted static week row is rendered from the snapshot.
    for (final text in [
      'Week 1',
      'Build Routine',
      'Week 2',
      'Easy Distance',
      'Week 3',
      'Base Endurance',
      'Week 4',
      '6 km Milestone',
      'Week 5',
      'Longer Effort',
      'Week 6',
      '8 km Progression',
      'Week 7',
      '10K Preparation',
      'Week 8',
      '10K Attempt',
    ]) {
      expect(find.text(text), findsWidgets);
    }
    for (final label in ['Completed', 'Current', 'Upcoming', 'Goal Week']) {
      expect(find.text(label), findsNothing);
    }
    for (final summary in const [
      '4 days · 8 km',
      '4 days · 10 km',
      '4 days · 12 km',
      '4 days · 14 km',
      '4 days · 16 km',
      '4 days · 18 km',
      '4 days · 20 km',
      '4 days · 10K',
    ]) {
      expect(find.text(summary), findsNothing);
    }
    expect(find.byIcon(Icons.check), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('goal_plan_detail_marker_Week 3')),
        matching: find.byIcon(Icons.directions_run),
      ),
      findsOneWidget,
    );
    expect(find.text('Monday'), findsNothing);

    // When: a week row is tapped.
    await tester.tap(
      find.byKey(const ValueKey('goal_plan_detail_week_toggle_Week 4')),
    );
    await tester.pumpAndSettle();

    // Then: only the static preview dropdown opens; no modal behavior appears.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('10K Goal Plan'), findsOneWidget);
    expect(find.text('6 km Milestone'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Sunday'), findsOneWidget);
    expect(find.text('Rest'), findsNWidgets(3));
    expect(find.text('0 min'), findsNWidgets(3));
    expect(find.text('4 days · 14 km'), findsNothing);
  });

  testWidgets(
    'Goal Plan Detail back returns to Plans without Home entry point',
    (WidgetTester tester) async {
      // Given: Home does not expose the Goal Plan Detail entry point.
      await tester.pumpWidget(const RuniacApp());
      expect(find.text('View Goal Plan'), findsNothing);

      // And: the user opens the detail from the You tab Plans section.
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Goal Plan'));
      await tester.pumpAndSettle();
      expect(find.text('10K Goal Plan'), findsOneWidget);

      // When: the detail back button is tapped.
      await tester.tap(find.byTooltip('Back to Plans'));
      await tester.pumpAndSettle();

      // Then: the previous Plans screen is restored.
      expect(find.text('10K Goal Plan'), findsNothing);
      expect(find.text('View Goal Plan'), findsOneWidget);
      expect(find.text("This Week's Plan"), findsOneWidget);
    },
  );

  testWidgets('You page preserves shell navigation around adjacent tabs', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsWidgets);
    expect(find.text('This Week'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);
    expect(find.text('This Week'), findsNothing);
  });

  testWidgets('Run launch from You hides the You header once settled', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    expect(find.text('You'), findsWidgets);
    expect(find.text('This Week'), findsOneWidget);

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('You').hitTestable(), findsNothing);
    expect(find.text('This Week').hitTestable(), findsNothing);
  });

  testWidgets('Run close from You reveals the You page during transition', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('You').hitTestable(), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byKey(const ValueKey('run_launch_transition_cover')),
      findsNothing,
    );
    expect(find.text('You', skipOffstage: false), findsWidgets);

    await tester.pump(const Duration(milliseconds: 100));
  });
}
