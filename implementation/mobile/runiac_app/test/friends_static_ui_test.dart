import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/friends/presentation/friends_screen.dart';

Widget _harness({VoidCallback? onBack}) {
  return MaterialApp(home: FriendsScreen(onBack: onBack ?? () {}));
}

void main() {
  testWidgets('Friends screen renders the four segments', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // 'Friends' appears as both the screen title and the first segment.
    expect(find.text('Friends'), findsNWidgets(2));
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Suggested'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
  });

  testWidgets('Default tab lists the demo friends', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(find.text('Marcus Tan'), findsOneWidget);
    expect(find.text('Priya Nair'), findsOneWidget);
  });

  testWidgets('Search filters by name with match and no-match states', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Find runners'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'grace');
    await tester.pumpAndSettle();
    expect(find.text('Grace Teo'), findsOneWidget);
    expect(find.text('Alex Wong'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('No runners found'), findsOneWidget);
    expect(find.text('Grace Teo'), findsNothing);
  });

  testWidgets('Accept moves a request into the Friends tab', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(find.text('Jasmine Koh'), findsOneWidget);
    expect(find.text('Accept'), findsNWidgets(3));

    await tester.tap(find.text('Accept').first);
    await tester.pumpAndSettle();
    expect(find.text('Jasmine Koh'), findsNothing);
    expect(find.text('Accept'), findsNWidgets(2));

    await tester.tap(find.text('Friends').last);
    await tester.pumpAndSettle();
    expect(find.text('Jasmine Koh'), findsOneWidget);
    expect(find.text('Aisha Rahman'), findsOneWidget);
  });

  testWidgets('Decline removes the request without adding a friend', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(find.text('Jasmine Koh'), findsOneWidget);

    await tester.tap(find.text('Decline').first);
    await tester.pumpAndSettle();
    expect(find.text('Jasmine Koh'), findsNothing);
    expect(find.text('Accept'), findsNWidgets(2));

    await tester.tap(find.text('Friends').last);
    await tester.pumpAndSettle();
    expect(find.text('Jasmine Koh'), findsNothing);
    expect(find.text('Aisha Rahman'), findsOneWidget);
  });

  testWidgets(
    'No fabricated XP, rank, or streak content beyond supplied labels',
    (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('Rank'), findsNothing);
      expect(find.textContaining('rank'), findsNothing);
      expect(find.textContaining('Streak'), findsNothing);
      expect(find.textContaining('streak'), findsNothing);

      await tester.tap(find.text('Suggested'));
      await tester.pumpAndSettle();
      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('Rank'), findsNothing);
      expect(find.textContaining('Streak'), findsNothing);
    },
  );
}
