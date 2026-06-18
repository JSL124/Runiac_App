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
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets(
    'bottom navigation keeps full Leaderboard label on narrow width',
    (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(360, 760)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      final initialNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(initialNav.unselectedFontSize, lessThan(12));
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Leaderbo...'), findsNothing);

      await tester.tap(find.text('Leaderboard'));
      await tester.pumpAndSettle();

      final selectedNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(selectedNav.selectedFontSize, lessThan(14));
      expect(selectedNav.selectedFontSize, greaterThanOrEqualTo(10.5));
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Leaderbo...'), findsNothing);
      expect(find.text('Your ranked area'), findsOneWidget);
    },
  );
}
