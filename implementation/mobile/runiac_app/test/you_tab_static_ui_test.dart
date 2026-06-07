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

  testWidgets('You page keeps backend owned values display only', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Run Level'), findsOneWidget);
    expect(find.text('Level 12 Runner'), findsOneWidget);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('rank'), findsNothing);
    expect(find.textContaining('leaderboard score'), findsNothing);

    await tester.tap(find.text('More Activities'));
    await tester.pumpAndSettle();

    expect(find.text('Activity History'), findsNothing);
    expect(find.text('More Activities'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Build your next running habit here.'), findsOneWidget);
    expect(find.text('This Week'), findsNothing);
  });

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
}
