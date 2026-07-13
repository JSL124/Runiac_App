import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_map.dart';

Widget _harness({VoidCallback? onOpenFriends, VoidCallback? onOpenChallenge}) {
  return MaterialApp(
    home: Scaffold(
      body: HomeStageMap(
        onNotifications: () {},
        onProfile: () {},
        onTapTodayStage: () {},
        onOpenFriends: onOpenFriends,
        onOpenChallenge: onOpenChallenge,
      ),
    ),
  );
}

final Finder _trigger = find.byKey(const ValueKey('homeSocialMenuTrigger'));
final Finder _panel = find.byKey(const ValueKey('homeSocialMenuPanel'));
final Finder _barrier = find.byKey(const ValueKey('homeSocialMenuBarrier'));

void main() {
  testWidgets('Social trigger is visible and menu panel starts hidden', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(onOpenFriends: () {}));
    await tester.pumpAndSettle();

    expect(_trigger, findsOneWidget);
    expect(find.text('Social'), findsOneWidget);
    expect(_panel, findsNothing);
    expect(_barrier, findsNothing);
    expect(find.text('Friends'), findsNothing);
    expect(find.text('Challenge'), findsNothing);

    final triggerSize = tester.getSize(_trigger);
    expect(triggerSize.width, greaterThanOrEqualTo(71));
    expect(triggerSize.height, greaterThanOrEqualTo(31));
  });

  testWidgets('Tapping the trigger opens Friends and Challenge items', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(onOpenFriends: () {}));
    await tester.pumpAndSettle();

    await tester.tap(_trigger);
    await tester.pumpAndSettle();

    expect(_panel, findsOneWidget);
    expect(_barrier, findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Challenge'), findsOneWidget);
  });

  testWidgets('Friends item fires the callback once and closes the menu', (
    tester,
  ) async {
    var openFriendsCount = 0;
    await tester.pumpWidget(_harness(onOpenFriends: () => openFriendsCount++));
    await tester.pumpAndSettle();

    await tester.tap(_trigger);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();

    expect(openFriendsCount, 1);
    expect(_panel, findsNothing);
    expect(_barrier, findsNothing);
  });

  testWidgets('Challenge item fires the callback once and closes the menu', (
    tester,
  ) async {
    var openFriendsCount = 0;
    var openChallengeCount = 0;
    await tester.pumpWidget(
      _harness(
        onOpenFriends: () => openFriendsCount++,
        onOpenChallenge: () => openChallengeCount++,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_trigger);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Challenge'));
    await tester.pumpAndSettle();

    expect(openChallengeCount, 1);
    expect(openFriendsCount, 0);
    // No coming-soon SnackBar is shown anymore.
    expect(find.text('Challenge is coming soon!'), findsNothing);
    expect(_panel, findsNothing);
    expect(_barrier, findsNothing);
  });

  testWidgets('Tapping outside the open menu dismisses it', (tester) async {
    await tester.pumpWidget(_harness(onOpenFriends: () {}));
    await tester.pumpAndSettle();

    await tester.tap(_trigger);
    await tester.pumpAndSettle();
    expect(_panel, findsOneWidget);

    await tester.tap(_barrier);
    await tester.pumpAndSettle();

    expect(_panel, findsNothing);
    expect(_barrier, findsNothing);
  });

  testWidgets('Omitted onOpenFriends does not throw when Friends is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(_trigger);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(_panel, findsNothing);
  });
}
