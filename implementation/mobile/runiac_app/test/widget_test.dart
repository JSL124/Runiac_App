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

    expect(find.text('Good to see you'), findsOneWidget);
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
      expect(
        find.widgetWithText(SwitchListTile, 'Notifications'),
        findsOneWidget,
      );
      expect(find.text('Plan-start reminder'), findsOneWidget);
      expect(find.text('30 min before'), findsOneWidget);
      expect(find.text("Today's plan reminder"), findsOneWidget);
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('Missed run nudge'), findsOneWidget);
      expect(find.text('2 hours after'), findsOneWidget);
      expect(find.text('Plan updates'), findsOneWidget);
    },
  );

  testWidgets(
    'Notification Center master toggle disables child notification controls',
    (WidgetTester tester) async {
      await openNotificationCenter(tester);

      expect(find.text('Notification Center'), findsOneWidget);

      final masterNotificationsSwitch = find.widgetWithText(
        SwitchListTile,
        'Notifications',
      );
      expect(masterNotificationsSwitch, findsOneWidget);

      await tester.tap(masterNotificationsSwitch);
      await tester.pump();

      expect(
        find.text('Turn Notifications on to edit reminder controls.'),
        findsOneWidget,
      );
      expect(find.text('Plan-start reminder'), findsOneWidget);
      expect(find.text('30 min before'), findsNothing);
      expect(find.text("Today's plan reminder"), findsOneWidget);
      expect(find.text('8:00 AM'), findsNothing);
      expect(find.text('Missed run nudge'), findsOneWidget);
      expect(find.text('2 hours after'), findsNothing);
      expect(find.text('Plan updates'), findsOneWidget);
    },
  );

  testWidgets('Notification Center child toggle hides only its timing option', (
    WidgetTester tester,
  ) async {
    await openNotificationCenter(tester);

    expect(find.text('Notification Center'), findsOneWidget);
    expect(find.text('30 min before'), findsOneWidget);
    expect(find.text('8:00 AM'), findsOneWidget);

    await tester.tap(find.byType(Switch).at(1));
    await tester.pump();

    expect(find.text('Plan-start reminder'), findsOneWidget);
    expect(find.text('30 min before'), findsNothing);
    expect(find.text("Today's plan reminder"), findsOneWidget);
    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('Missed run nudge'), findsOneWidget);
    expect(find.text('2 hours after'), findsOneWidget);
    expect(find.text('Plan updates'), findsOneWidget);
  });

  testWidgets(
    'Notification Center exposes timing options when reminder controls are on',
    (WidgetTester tester) async {
      await openNotificationCenter(tester);

      expect(find.text('Notification Center'), findsOneWidget);
      expect(find.text('Plan-start reminder'), findsOneWidget);
      expect(find.text("Today's plan reminder"), findsOneWidget);
      expect(find.text('Missed run nudge'), findsOneWidget);

      for (final option in [
        '10 min before',
        '30 min before',
        '1 hour before',
        '2 hours before',
        '7:00 AM',
        '8:00 AM',
        '9:00 AM',
        'Custom',
        '1 hour after',
        '2 hours after',
        'Evening reminder',
      ]) {
        expect(find.text(option), findsOneWidget);
      }
    },
  );
}
