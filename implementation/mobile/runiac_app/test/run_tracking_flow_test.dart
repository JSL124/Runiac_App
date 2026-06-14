import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/run/presentation/run_active_screen.dart';
import 'package:runiac_app/features/run/presentation/run_launch_screen.dart';

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

class _RoutePushRecorder extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  testWidgets('Run launch Start run updates sheet without pushing a route', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final observer = _RoutePushRecorder();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const RunLaunchScreen(),
      ),
    );
    await tester.pumpAndSettle();
    observer.pushedRoutes.clear();

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Run settings'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('Running · easy'), findsNothing);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsNothing);
    expect(find.text('DISTANCE'), findsNothing);
    expect(find.text('TIME'), findsNothing);
    expect(find.text('AVG PACE'), findsNothing);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    expect(observer.pushedRoutes, isEmpty);
    expect(find.byType(RunLaunchScreen), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
    expect(find.byTooltip('Run settings'), findsNothing);
    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsNothing);
    expect(find.text('Start run'), findsNothing);
    expect(find.text('0.00 of 4.50 km'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);
    expect(tester.takeException(), isNull);
  });

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
    expect(find.text('0.00 of 4.50 km'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('--/km'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('0.02 of 4.50 km'), findsOneWidget);
    expect(find.text('1%'), findsOneWidget);
    expect(find.text('06:56/km'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run pause, resume, and hold End keep local state untrusted', (
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
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.byKey(const Key('hold_to_end_button')), findsOneWidget);
    expect(find.text('Pause'), findsNothing);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('0.02 of 4.50 km'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.text('00:10'), findsNothing);
    expect(find.text('0.02 of 4.50 km'), findsNothing);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('End'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('hold_to_end_button')));
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    final endButton = find.byKey(const Key('hold_to_end_button'));
    final endCenter = tester.getCenter(endButton);
    final gesture = await tester.startGesture(endCenter);
    await tester.pump(const Duration(milliseconds: 1200));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    final holdGesture = await tester.startGesture(endCenter);
    await tester.pump(const Duration(milliseconds: 3100));
    await holdGesture.up();
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

  testWidgets('Paused End exposes accessible long press and hold progress', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);
    final semantics = tester.ensureSemantics();

    await _openRunLaunch(tester);
    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    final endSemantics = find.bySemanticsLabel('Hold to end run');
    expect(endSemantics, findsOneWidget);
    expect(find.text('Hold for 3 seconds to finish your run'), findsNothing);
    final endNode = tester.getSemantics(endSemantics);
    final endData = endNode.getSemanticsData();
    expect(endData.hint, 'Hold for 3 seconds to finish your run');
    expect(endData.hasAction(SemanticsAction.longPress), isTrue);
    expect(find.byKey(const Key('hold_to_end_progress_gauge')), findsNothing);

    final endButton = find.byKey(const Key('hold_to_end_button'));
    final gesture = await tester.startGesture(tester.getCenter(endButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    final gauge = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('hold_to_end_progress_gauge')),
    );
    expect(gauge.value, greaterThan(0));
    expect(gauge.value, lessThan(1));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hold_to_end_progress_gauge')), findsNothing);
    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('RunActiveScreen keeps shared Pause Resume and End behavior', (
    WidgetTester tester,
  ) async {
    _useMobileRunSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: RunActiveScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.byKey(const Key('hold_to_end_button')), findsOneWidget);
    expect(find.text('Pause'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('End'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pumpAndSettle();

    final endButton = find.byKey(const Key('hold_to_end_button'));
    await tester.tap(endButton);
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsNothing);
    expect(find.text('Paused · easy'), findsOneWidget);

    final holdGesture = await tester.startGesture(tester.getCenter(endButton));
    await tester.pump(const Duration(milliseconds: 3100));
    await holdGesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Cool down'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
