import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/friends/domain/models/friends_read_model.dart';
import 'package:runiac_app/features/friends/presentation/friends_screen.dart';
import 'package:runiac_app/features/friends/presentation/widgets/friends_rows.dart';

Widget _harness({VoidCallback? onBack}) {
  return MaterialApp(home: FriendsScreen(onBack: onBack ?? () {}));
}

const _longName = 'Alexandria Catherine Montgomery-Wellington the Third';

const _longNameUser = FriendUserReadModel(
  userId: 'long-name-user',
  displayName: _longName,
  avatarInitials: 'AM',
  levelLabel: 'Lv.12',
  subtitleLabel: 'Unused in compact row',
);

Widget _rowHarness({required bool isPending}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FriendUserRow(
          user: _longNameUser,
          isPending: isPending,
          onAdd: isPending ? null : () {},
        ),
      ),
    ),
  );
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

  testWidgets(
    'Friends Aisha row omits location copy and add-or-pending actions',
    (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Aisha Rahman'), findsOneWidget);
      expect(find.text('Runs around Bishan Park'), findsNothing);
      expect(find.bySemanticsLabel('Add Aisha Rahman'), findsNothing);
      expect(find.bySemanticsLabel('Pending Aisha Rahman'), findsNothing);
    },
  );

  testWidgets(
    'A 360px row keeps a long name and 44px Add action without overflow',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(360, 800));
      try {
        await tester.pumpWidget(_rowHarness(isPending: false));
        await tester.pumpAndSettle();

        final addAction = find.byKey(
          const ValueKey('friends-add-action-long-name-user'),
        );
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Add $_longName'), findsOneWidget);
        expect(tester.getSize(addAction), const Size(44, 44));
      } finally {
        semantics.dispose();
        await tester.binding.setSurfaceSize(null);
      }
    },
  );

  testWidgets(
    'A 360px row keeps a long name and Pending semantics without overflow',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(360, 800));
      try {
        await tester.pumpWidget(_rowHarness(isPending: true));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Pending $_longName'), findsOneWidget);
      } finally {
        semantics.dispose();
        await tester.binding.setSurfaceSize(null);
      }
    },
  );

  testWidgets(
    'Suggested Clara changes from Add to Pending without changing Ryan',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Suggested'));
      await tester.pumpAndSettle();

      expect(find.text('Clara Goh'), findsOneWidget);
      expect(find.bySemanticsLabel('Add Clara Goh'), findsOneWidget);
      expect(find.text('Runs a similar weekly plan'), findsNothing);
      expect(find.bySemanticsLabel('Add Ryan Chua'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Add Clara Goh'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Pending Clara Goh'), findsOneWidget);
      expect(find.bySemanticsLabel('Add Clara Goh'), findsNothing);
      expect(find.bySemanticsLabel('Add Ryan Chua'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets(
    'Pending state resets when a new Friends screen instance is created',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: FriendsScreen(key: UniqueKey(), onBack: () {}),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Suggested'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Add Clara Goh'));
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Pending Clara Goh'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(
            home: FriendsScreen(key: UniqueKey(), onBack: () {}),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Suggested'));
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Add Clara Goh'), findsOneWidget);
        expect(find.bySemanticsLabel('Pending Clara Goh'), findsNothing);
      } finally {
        semantics.dispose();
      }
    },
  );

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

  testWidgets(
    'Search Grace changes from Add to Pending and keeps it across query and tab changes',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'grace');
      await tester.pumpAndSettle();

      expect(find.text('Grace Teo'), findsOneWidget);
      expect(find.bySemanticsLabel('Add Grace Teo'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Add Grace Teo'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Pending Grace Teo'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'alex');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'grace');
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Pending Grace Teo'), findsOneWidget);

      await tester.tap(find.text('Suggested'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Pending Grace Teo'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets(
    'Requests Jasmine keeps its invitation copy and accept-or-decline actions',
    (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('Jasmine Koh'), findsOneWidget);
      expect(find.text('Wants to run together'), findsOneWidget);
      expect(find.text('Accept'), findsNWidgets(3));
      expect(find.text('Decline'), findsNWidgets(3));
    },
  );

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
