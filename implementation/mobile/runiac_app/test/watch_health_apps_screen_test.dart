import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/core/widgets/runiac_buttons.dart';
import 'package:runiac_app/features/account/presentation/watch_health_apps_screen.dart';

Future<void> _pumpWatchHealthAppsScreen(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: WatchHealthAppsScreen()));
  await tester.pumpAndSettle();
}

Finder _rowForTitle(String title) {
  return find.ancestor(
    of: find.text(title),
    matching: find.byType(RuniacTappableSurface),
  );
}

void main() {
  testWidgets('Watch and Health Apps rows stay compact with equal heights', (
    WidgetTester tester,
  ) async {
    await _pumpWatchHealthAppsScreen(tester);

    final rows = [
      _rowForTitle('Connect a new device to Runiac'),
      _rowForTitle('Apple Watch'),
      _rowForTitle('Garmin'),
      _rowForTitle('Apple Health'),
      _rowForTitle('Health Connect'),
      _rowForTitle('Garmin via Health'),
    ];

    for (final row in rows) {
      expect(row, findsOneWidget);
      expect(tester.getRect(row).height, closeTo(80, 0.5));
    }
  });

  testWidgets('Watch and Health Apps rows press as full-width rectangles', (
    WidgetTester tester,
  ) async {
    await _pumpWatchHealthAppsScreen(tester);

    final appleWatchRow = _rowForTitle('Apple Watch');
    final rowRect = tester.getRect(appleWatchRow);
    final tappableSurface = tester.widget<RuniacTappableSurface>(appleWatchRow);

    expect(rowRect.left, closeTo(0, 0.5));
    expect(rowRect.right, closeTo(390, 0.5));
    expect(tappableSurface.borderRadius, BorderRadius.zero);
  });

  testWidgets('Three-line option text block aligns with icon center', (
    WidgetTester tester,
  ) async {
    await _pumpWatchHealthAppsScreen(tester);

    final connectRow = _rowForTitle('Connect a new device to Runiac');
    final icon = find.descendant(
      of: connectRow,
      matching: find.byIcon(Icons.add_circle_outline_rounded),
    );
    final title = find.text('Connect a new device to Runiac');
    final description = find.text(
      'Use your watch or health app to bring in completed runs later.',
    );

    final iconCenterY = tester.getRect(icon).center.dy;
    final textBlockCenterY =
        (tester.getRect(title).top + tester.getRect(description).bottom) / 2;

    expect(icon, findsOneWidget);
    expect(iconCenterY, closeTo(textBlockCenterY, 0.75));
  });
}
