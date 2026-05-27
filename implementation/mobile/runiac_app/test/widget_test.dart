import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

void main() {
  testWidgets('Runiac app shell shows static tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('Home dashboard keeps a calm primary quick start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    expect(find.text('Good to see you'), findsOneWidget);
    expect(
      find.text('Your Home dashboard is ready for a calm start.'),
      findsOneWidget,
    );
    expect(find.text('Ready for an easy run?'), findsOneWidget);
    expect(find.text('Start small and keep it comfortable.'), findsOneWidget);
    expect(find.text('View Plan'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);

    await tester.tap(find.text('Quick Start'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('This Week\'s Plan'), findsOneWidget);
    expect(find.text('Last Run'), findsOneWidget);
    expect(find.text('View Details'), findsNothing);
  });

  testWidgets('Maps tab shows static route discovery placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Search routes or parks'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('Beginner-friendly route ideas'), findsNothing);
    expect(find.text('Preview'), findsNothing);
    expect(
      find.text(
        'Start with a gentle preview. Routes stay as placeholders until setup is ready.',
      ),
      findsNothing,
    );
    expect(find.text('Route preview'), findsOneWidget);
    expect(
      find.text('A calm route card can guide the next step later.'),
      findsOneWidget,
    );

    await tester.drag(find.text('Shared Routes'), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('Beginner-friendly route ideas'), findsNothing);
    expect(find.text('Preview'), findsNothing);
    expect(find.text('Shared routes'), findsOneWidget);
    expect(
      find.text('Community route ideas remain review-only for now.'),
      findsOneWidget,
    );

    await tester.drag(find.text('Shared routes'), const Offset(0, -160));
    await tester.pumpAndSettle();

    expect(find.text('Saved routes'), findsOneWidget);
    expect(
      find.text('Saved route slots stay visible without saving data.'),
      findsOneWidget,
    );
  });

  testWidgets('Leaderboard tab shows static map-first landing shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Runiac'), findsNothing);
    expect(find.text('Weekly XP'), findsOneWidget);
    expect(find.text('Monthly XP'), findsOneWidget);
    expect(find.text('Rising Runner Division'), findsOneWidget);
    expect(find.text('Lv.11 - Lv.20'), findsOneWidget);
    expect(find.text('Your ranked area'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Jurong East'), findsOneWidget);
    expect(find.text('Weekly XP · Rising Runner Division'), findsOneWidget);
    expect(find.text('Region Preview'), findsOneWidget);
    expect(find.text('Ranking preview pending'), findsOneWidget);
    expect(find.text('My Rank Preview'), findsOneWidget);
    expect(
      find.text('Your position will appear after leaderboard data is ready.'),
      findsOneWidget,
    );
    expect(find.text('View More Ranking'), findsOneWidget);
    expect(find.text('Share My Rank'), findsOneWidget);
    expect(find.byKey(const Key('leaderboard_sheet_handle')), findsOneWidget);
    expect(find.bySemanticsLabel('Leaderboard information'), findsOneWidget);
    expect(find.text('Tips'), findsNothing);

    await tester.drag(
      find.byKey(const Key('leaderboard_sheet_handle')),
      const Offset(0, 420),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('leaderboard_sheet_handle')), findsOneWidget);

    await tester.tap(find.text('Your ranked area'));
    await tester.pumpAndSettle();

    expect(find.text('Region Preview'), findsOneWidget);
    expect(find.text('View More Ranking'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Leaderboard information'));
    await tester.pumpAndSettle();

    expect(find.text('Tips'), findsOneWidget);
    expect(find.text('Leagues'), findsOneWidget);
    expect(find.text('Weekly vs Monthly'), findsOneWidget);
    expect(find.text('Ranking readiness'), findsOneWidget);
    expect(
      find.text(
        'Leagues group runners by broad progress bands so the board feels fair and beginner-friendly.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Weekly and monthly views will help compare progress once leaderboard data is ready.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Real rankings will be calculated safely by Runiac later.'),
      findsOneWidget,
    );

    expect(find.text('Community motivation'), findsNothing);
    expect(find.text('No live ranking data yet'), findsNothing);
    expect(find.text('Top 3 Runners'), findsNothing);
    expect(find.textContaining('Alex'), findsNothing);
    expect(find.textContaining('Maya'), findsNothing);
    expect(find.textContaining('Ryan'), findsNothing);
    expect(find.text('520 XP'), findsNothing);
    expect(find.textContaining('#1'), findsNothing);
    expect(find.textContaining('#18'), findsNothing);
    expect(find.textContaining('Lv.18'), findsNothing);
    expect(find.textContaining('1,240 XP'), findsNothing);
    expect(find.textContaining('1,180 XP'), findsNothing);
    expect(find.textContaining('1,050 XP'), findsNothing);
    expect(find.textContaining('520'), findsNothing);

    await tester.tap(find.byTooltip('Close tips'));
    await tester.pumpAndSettle();

    expect(find.text('Tips'), findsNothing);
    expect(find.text('Leagues'), findsNothing);
    expect(find.text('Rising Runner Division'), findsOneWidget);
    expect(find.text('Region Preview'), findsOneWidget);

    await tester.tap(find.text('Rising Runner Division'));
    await tester.pumpAndSettle();

    expect(find.text('Leagues'), findsOneWidget);
    expect(find.text('Apex Runner League (Lv.81 - Lv.90)'), findsOneWidget);
    expect(find.text('Summitborn League (Lv.71 - Lv.80)'), findsOneWidget);
    expect(find.text('Roadrunner League (Lv.51 - Lv.60)'), findsOneWidget);
    expect(find.text('Endurancer League (Lv.41 - Lv.50)'), findsOneWidget);
    expect(find.text('Milehunter League (Lv.31 - Lv.40)'), findsOneWidget);
    expect(find.text('Pacebreaker League (Lv.21 - Lv.30)'), findsOneWidget);
    expect(find.text('Strideforge League (Lv.11 - Lv.20)'), findsOneWidget);
    expect(find.text('Trailborn League (Lv.1 - Lv.10)'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.textContaining('Current'), findsNothing);
    expect(find.textContaining('current'), findsNothing);
    expect(find.textContaining('Selected'), findsNothing);
    expect(find.textContaining('selected'), findsNothing);
    expect(find.textContaining('Unlocked'), findsNothing);
    expect(find.textContaining('unlocked'), findsNothing);
    expect(find.textContaining('Earned'), findsNothing);
    expect(find.textContaining('earned'), findsNothing);
    expect(find.textContaining('Alex'), findsNothing);
    expect(find.textContaining('Maya'), findsNothing);
    expect(find.textContaining('Ryan'), findsNothing);
    expect(find.text('520 XP'), findsNothing);
    expect(find.textContaining('#18'), findsNothing);
    expect(find.textContaining('Lv.18'), findsNothing);

    await tester.tap(find.byTooltip('Close leagues'));
    await tester.pumpAndSettle();

    expect(find.text('Leagues'), findsNothing);
    expect(find.text('Rising Runner Division'), findsOneWidget);
    expect(find.text('Lv.11 - Lv.20'), findsOneWidget);
    expect(find.text('Region Preview'), findsOneWidget);
  });

  testWidgets('Run item opens and closes static full-screen launch surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Plan'), findsOneWidget);
    expect(find.text('Ready for an easy run?'), findsOneWidget);
    expect(find.text('Route details will appear after setup.'), findsOneWidget);
    expect(find.text('Recommended effort will appear here.'), findsOneWidget);
    expect(find.text('Route setup'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Maps'), findsNothing);
    expect(find.text('Leaderboard'), findsNothing);
    expect(find.text('You'), findsNothing);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Ready for an easy run?'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Route setup'), findsNothing);
    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('Android back dismisses static Run launch surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    expect(find.text('Shared Routes'), findsOneWidget);

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for an easy run?'), findsOneWidget);
    expect(find.text('Maps'), findsNothing);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.text('Route setup'), findsNothing);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });
}
