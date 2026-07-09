import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

void main() {
  Future<void> openNotificationCenter(WidgetTester tester) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    final notificationsRow = find.text('Notifications');
    await tester.ensureVisible(notificationsRow);
    await tester.tap(notificationsRow);
    await tester.pumpAndSettle();
  }

  testWidgets('Runiac app shell shows static tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    expect(find.text('Your journey map is waiting'), findsOneWidget);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Maps'), findsOneWidget);
    expect(find.byTooltip('Run'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('You'), findsOneWidget);
  });

  testWidgets('bottom navigation uses icon-only tabs and preserves routing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    final bottomNavigation = find.byType(BottomNavigationBar);
    expect(bottomNavigation, findsOneWidget);

    final bottomNavigationBar = tester.widget<BottomNavigationBar>(
      bottomNavigation,
    );

    expect(bottomNavigationBar.showSelectedLabels, isFalse);
    expect(bottomNavigationBar.showUnselectedLabels, isFalse);
    expect(bottomNavigationBar.selectedIconTheme?.size, 32);
    expect(bottomNavigationBar.unselectedIconTheme?.size, 30);
    expect(
      bottomNavigationBar.items.map((item) => item.label),
      everyElement(isEmpty),
    );

    for (final label in ['Home', 'Maps', 'Run', 'Leaderboard', 'You']) {
      expect(
        find.descendant(of: bottomNavigation, matching: find.text(label)),
        findsNothing,
      );
      expect(find.byTooltip(label), findsOneWidget);
    }

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Your ranked area'), findsOneWidget);
  });

  testWidgets(
    'bottom navigation remains full width with evenly spaced tabs on narrow width',
    (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(360, 760)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      final bottomNavigation = find.byType(BottomNavigationBar);
      expect(bottomNavigation, findsOneWidget);

      final navRect = tester.getRect(bottomNavigation);
      final firstItemRect = tester.getRect(find.byTooltip('Home'));
      final lastItemRect = tester.getRect(find.byTooltip('You'));

      expect(navRect.left, closeTo(0, 0.5));
      expect(navRect.right, closeTo(360, 0.5));
      expect(navRect.height, greaterThanOrEqualTo(56));
      expect(firstItemRect.width, closeTo(lastItemRect.width, 0.5));
      expect(firstItemRect.center.dy, closeTo(lastItemRect.center.dy, 0.5));
      expect(firstItemRect.center.dy, closeTo(navRect.center.dy, 4));
    },
  );

  testWidgets(
    'Account notifications row opens Notification Center with default notification settings',
    (WidgetTester tester) async {
      await openNotificationCenter(tester);

      expect(find.text('Notification Center'), findsOneWidget);
      expect(find.text('4 of 4 reminders on'), findsOneWidget);
      expect(find.text('BEFORE YOUR RUN'), findsOneWidget);
      expect(find.text('AFTER YOUR RUN'), findsOneWidget);
      expect(find.text('Plan-start reminder'), findsOneWidget);
      expect(
        find.text('Notifies you 2 hours, 1 hour, and 10 min before your run.'),
        findsOneWidget,
      );
      expect(find.text("Today's plan reminder"), findsOneWidget);
      expect(
        find.text('Notifies you at 12:00 AM if a plan is scheduled for today.'),
        findsOneWidget,
      );
      expect(find.text('Missed run nudge'), findsOneWidget);
      expect(
        find.text(
          "Notifies you 1 hour and 2 hours after today's plan time if you haven't run.",
        ),
        findsOneWidget,
      );
      expect(find.text('Plan updates'), findsOneWidget);
      expect(
        find.text('Know when your coach adjusts an upcoming plan.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Notification Center master toggle disables child notification controls',
    (WidgetTester tester) async {
      await openNotificationCenter(tester);

      expect(find.text('Notification Center'), findsOneWidget);

      final masterNotificationsSwitch = find.byType(Switch).first;

      await tester.tap(masterNotificationsSwitch);
      await tester.pump();

      expect(
        find.text('Turn Notifications on to edit reminder controls.'),
        findsOneWidget,
      );
      expect(find.text('All reminders paused'), findsOneWidget);
      expect(find.text('Plan-start reminder'), findsOneWidget);
      expect(find.text("Today's plan reminder"), findsOneWidget);
      expect(find.text('Missed run nudge'), findsOneWidget);
      expect(find.text('Plan updates'), findsOneWidget);

      for (
        var index = 1;
        index < find.byType(Switch).evaluate().length;
        index++
      ) {
        final childSwitch = tester.widget<Switch>(
          find.byType(Switch).at(index),
        );
        expect(childSwitch.value, isFalse);
        expect(childSwitch.onChanged, isNull);
      }
    },
  );

  testWidgets('Notification Center child toggle updates only that reminder', (
    WidgetTester tester,
  ) async {
    await openNotificationCenter(tester);

    expect(find.text('Notification Center'), findsOneWidget);
    expect(find.text('4 of 4 reminders on'), findsOneWidget);

    await tester.tap(find.byType(Switch).at(1));
    await tester.pump();

    expect(find.text('3 of 4 reminders on'), findsOneWidget);
    expect(find.text('Plan-start reminder'), findsOneWidget);
    expect(find.text("Today's plan reminder"), findsOneWidget);
    expect(find.text('Missed run nudge'), findsOneWidget);
    expect(find.text('Plan updates'), findsOneWidget);

    final disabledPlanStartSwitch = tester.widget<Switch>(
      find.byType(Switch).at(1),
    );
    final todayReminderSwitch = tester.widget<Switch>(
      find.byType(Switch).at(2),
    );
    expect(disabledPlanStartSwitch.value, isFalse);
    expect(todayReminderSwitch.value, isTrue);
  });

  testWidgets('Notification Center exposes concrete reminder delivery copy', (
    WidgetTester tester,
  ) async {
    await openNotificationCenter(tester);

    expect(find.text('Notification Center'), findsOneWidget);
    expect(find.text('Plan-start reminder'), findsOneWidget);
    expect(find.text("Today's plan reminder"), findsOneWidget);
    expect(find.text('Missed run nudge'), findsOneWidget);
    expect(
      find.text('Notifies you 2 hours, 1 hour, and 10 min before your run.'),
      findsOneWidget,
    );
    expect(
      find.text('Notifies you at 12:00 AM if a plan is scheduled for today.'),
      findsOneWidget,
    );
    expect(
      find.text(
        "Notifies you 1 hour and 2 hours after today's plan time if you haven't run.",
      ),
      findsOneWidget,
    );
    expect(
      find.text('Know when your coach adjusts an upcoming plan.'),
      findsOneWidget,
    );
  });
}
