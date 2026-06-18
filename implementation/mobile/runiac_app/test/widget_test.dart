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
    'floating island bottom navigation removes visible labels and preserves semantic tabs',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(
        find.byKey(const ValueKey('runiac-floating-bottom-navigation')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('runiac-floating-bottom-navigation-active-pill'),
        ),
        findsOneWidget,
      );

      for (final label in ['Home', 'Maps', 'Run', 'Leaderboard', 'You']) {
        expect(find.text(label), findsNothing);
        expect(find.byTooltip(label), findsOneWidget);
        expect(find.bySemanticsLabel('$label tab'), findsOneWidget);
      }

      await tester.tap(find.byTooltip('Leaderboard'));
      await tester.pumpAndSettle();

      expect(find.text('Your ranked area'), findsOneWidget);
    },
  );

  testWidgets(
    'floating island bottom navigation stays centered on narrow width',
    (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(360, 760)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      final island = find.byKey(
        const ValueKey('runiac-floating-bottom-navigation'),
      );
      expect(island, findsOneWidget);

      final islandRect = tester.getRect(island);
      final screenCenter =
          tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;

      expect(islandRect.center.dx, closeTo(screenCenter, 0.5));
      expect(islandRect.left, greaterThan(0));
      expect(islandRect.right, lessThan(360));
      expect(islandRect.height, greaterThanOrEqualTo(64));
      expect(islandRect.height, lessThanOrEqualTo(76));
    },
  );
}
