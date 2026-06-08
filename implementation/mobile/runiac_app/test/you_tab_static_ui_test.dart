import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

Future<void> _openYouTab(WidgetTester tester) async {
  await tester.pumpWidget(const RuniacApp());
  await tester.tap(find.text('You'));
  await tester.pumpAndSettle();
}

void main() {
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
    expect(find.text('Saturday Night Run'), findsOneWidget);
    expect(find.text('Morning Easy Run'), findsOneWidget);
    expect(find.text('Recovery Jog'), findsOneWidget);
    expect(find.text('More Activities'), findsOneWidget);
    expect(find.text('Run Level'), findsOneWidget);
    expect(find.text('Level 12 Runner'), findsOneWidget);
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
    expect(find.text("This Week's 10K Preparation Plan"), findsOneWidget);
    expect(find.text('Planned Runs'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'3\s+Planned Runs')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'2\s+Completed')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'1\s+Remaining')), findsOneWidget);
    expect(
      find.text('Take each easy run as a steady step forward.'),
      findsOneWidget,
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

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Explore expert goal plan'), findsOneWidget);
    expect(
      find.text(
        'Browse coach-created plans and apply one to your current goal plan.',
      ),
      findsOneWidget,
    );
    expect(find.text('Coach-created'), findsOneWidget);
    expect(find.text('First 5K'), findsOneWidget);
    expect(find.text('10K'), findsOneWidget);
    expect(find.text('Half Marathon'), findsOneWidget);
    expect(find.text('Full Marathon'), findsOneWidget);
    expect(find.text('Explore Expert Plans'), findsOneWidget);
  });

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
    expect(find.text("This Week's 10K Preparation Plan"), findsOneWidget);

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
    expect(find.text('Explore Expert Plans'), findsOneWidget);
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
    expect(find.text('THURSDAY · EASY RUN'), findsOneWidget);
    expect(find.text('A gentle 20 minutes.'), findsOneWidget);
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
    expect(find.text('SATURDAY · EASY RUN'), findsOneWidget);
    expect(find.text('THURSDAY · EASY RUN'), findsNothing);
    expect(find.text('A gentle 20 minutes.'), findsOneWidget);
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

    final suggestedPaceLabel = tester.widget<Text>(
      find.byKey(const ValueKey('suggested_pace_metric_label')),
    );

    // Then: the long metric label remains a compact single-line label.
    expect(suggestedPaceLabel.data, 'Suggested pace');
    expect(suggestedPaceLabel.maxLines, 1);
    expect(suggestedPaceLabel.softWrap, isFalse);
    expect(find.text('7:30 /km'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Workout detail start action stays visual only', (
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

    // Then: it does not navigate to Run launch, complete anything, or show mutation UI.
    expect(find.text('Start This Run'), findsOneWidget);
    expect(find.text('GPS ready'), findsNothing);
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
      'Completed',
      'Current',
      'Upcoming',
      'Goal Week',
    ]) {
      expect(find.text(text), findsWidgets);
    }

    // When: a week row is tapped.
    await tester.tap(find.text('6 km Milestone'));
    await tester.pumpAndSettle();

    // Then: no week detail or modal behavior is introduced.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('10K Goal Plan'), findsOneWidget);
    expect(find.text('6 km Milestone'), findsOneWidget);
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
      expect(find.text("This Week's 10K Preparation Plan"), findsOneWidget);
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
