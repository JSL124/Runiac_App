import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/friends/data/static_friends_repository.dart';
import 'package:runiac_app/features/friends/domain/models/friends_read_model.dart';
import 'package:runiac_app/features/friends/presentation/friends_screen.dart';
import 'package:runiac_app/features/friends/presentation/widgets/friends_rows.dart';
import 'support/fake_runiac_auth_repository.dart';

final _authRepository = FakeRuniacAuthRepository()
  ..emitSignedIn(uid: 'static-test-user');

Widget _harness({VoidCallback? onBack}) {
  return MaterialApp(
    home: FriendsScreen(
      authRepository: _authRepository,
      repository: const StaticFriendsRepository(),
      onBack: onBack ?? () {},
    ),
  );
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
  tearDownAll(_authRepository.dispose);
  testWidgets('Friends screen renders the four backed segments', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // 'Friends' appears as both the screen title and the first segment.
    expect(find.text('Friends'), findsNWidgets(2));
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
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

  testWidgets('Legacy suggested tab is absent from the backed screen', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Suggested'), findsNothing);
    } finally {
      semantics.dispose();
    }
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

      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('Rank'), findsNothing);
      expect(find.textContaining('Streak'), findsNothing);
    },
  );
}
