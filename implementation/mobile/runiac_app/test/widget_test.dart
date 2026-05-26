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

  testWidgets('Maps tab shows static route discovery placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Search routes or area'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(
      find.text('Nearby route suggestions will appear after location setup.'),
      findsOneWidget,
    );
    expect(find.text('Route preview'), findsOneWidget);
    expect(find.text('Details will appear after setup.'), findsOneWidget);
    expect(find.text('Community routes'), findsOneWidget);
    expect(find.text('Shared route details will appear here.'), findsOneWidget);

    await tester.drag(find.text('Shared Routes'), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('Saved routes'), findsOneWidget);
    expect(find.text('Saved routes will be available later.'), findsOneWidget);
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
