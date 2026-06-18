import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

void main() {
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

  testWidgets(
    'bottom navigation shows screenshot-style labeled tabs and preserves routing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);

      for (final label in ['Home', 'Maps', 'Run', 'Leaderboard', 'You']) {
        expect(find.text(label), findsOneWidget);
        expect(find.byTooltip(label), findsOneWidget);
      }

      await tester.tap(find.byTooltip('Leaderboard'));
      await tester.pumpAndSettle();

      expect(find.text('Your ranked area'), findsOneWidget);
    },
  );

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
    },
  );
}
