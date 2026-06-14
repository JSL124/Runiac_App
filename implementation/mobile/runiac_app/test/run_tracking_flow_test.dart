import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

void _useMobileRunSurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _openRunLaunch(WidgetTester tester) async {
  await tester.pumpWidget(const RuniacApp(showSplash: false));
  await tester.tap(find.text('Run'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Run launch starts deterministic active local tracking', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.text('Easy effort is enough.'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('0.00 km'), findsOneWidget);
    expect(find.text('--/km'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Finish'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('0.02 km'), findsOneWidget);
    expect(find.text('06:56/km'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run pause, resume, and finish keep local state untrusted', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    await _openRunLaunch(tester);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.text('You can pause anytime.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Finish'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('0.02 km'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.text('00:10'), findsNothing);
    expect(find.text('0.02 km'), findsNothing);
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsOneWidget);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.textContaining('Leaderboard'), findsNothing);
    expect(
      find.textContaining(
        'validation'
        'Status',
      ),
      findsNothing,
    );
    expect(
      find.textContaining(
        'countsToward'
        'Progression',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
