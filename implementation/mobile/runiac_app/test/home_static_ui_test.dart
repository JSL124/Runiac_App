import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/home/presentation/widgets/today_plan_card.dart';

const _todayPlanHeroAssetPath = 'assets/images/home/todays_plan_runner.png';

final _forbiddenBackendOwnedCopy = RegExp(
  r'\bXP\b|streak|level|rank|score|saved count|popularity|owned|'
  r'territory owned|route completed|activity saved|synced|premium|'
  r'subscription',
  caseSensitive: false,
);

TextStyle? _effectiveTextStyle(Finder textFinder, WidgetTester tester) {
  final richText = tester.widget<RichText>(
    find.descendant(of: textFinder, matching: find.byType(RichText)).first,
  );
  return richText.text.style;
}

void main() {
  testWidgets('Home dashboard keeps a calm primary quick start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    expect(find.text('Good to see you'), findsOneWidget);
    expect(
      find.text('Your Home dashboard is ready for a calm start.'),
      findsOneWidget,
    );
    expect(find.text('Today\'s Plan'), findsOneWidget);
    expect(find.text('20 min easy run'), findsOneWidget);
    expect(find.text('Goal Mode: First 5K'), findsOneWidget);
    expect(
      find.text('Build consistency with an easy, comfortable effort.'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! Image || widget.image is! AssetImage) {
          return false;
        }
        final image = widget.image as AssetImage;
        return image.assetName == _todayPlanHeroAssetPath;
      }),
      findsOneWidget,
    );
    expect(find.text('View Plan'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications preview is coming soon.'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);
    expect(
      find.text('Profile settings preview is coming soon.'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('This Week\'s Plan'), findsOneWidget);
    expect(find.text('Last Run'), findsOneWidget);
    expect(find.text('View Details'), findsNothing);
    expect(find.text('Ready for an easy run?'), findsNothing);
    expect(find.text('Start small and keep it comfortable.'), findsNothing);
    expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);
  });

  testWidgets('Home today plan hero fits a narrow mobile surface', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: TodayPlanCard(onViewPlan: () {}, onQuickStart: () {}),
          ),
        ),
      ),
    );

    expect(find.text('20 min easy run'), findsOneWidget);
    expect(find.text('Goal Mode: First 5K'), findsOneWidget);
    expect(
      find.text('Build consistency with an easy, comfortable effort.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home Quick Start opens the existing run launch screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Quick Start'));
    await tester.pumpAndSettle();

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('Good to see you'), findsNothing);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('Home View Plan opens today workout detail without editing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('View Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Thursday · Easy Run'), findsOneWidget);
    expect(find.text('20 min easy run'), findsOneWidget);
    expect(find.text('Edit schedule'), findsNothing);
    expect(find.text('10K Goal Plan'), findsNothing);

    final headerTitle = tester.widget<Text>(
      find.byKey(const ValueKey('workout_detail_header_title')),
    );

    expect(headerTitle.style?.fontSize, 20);
    expect(headerTitle.style?.fontFamily, isNull);
    expect(headerTitle.style?.decoration, isNot(TextDecoration.underline));

    final effectiveHeaderTitleStyle = _effectiveTextStyle(
      find.byKey(const ValueKey('workout_detail_header_title')),
      tester,
    );
    final effectiveDayLabelStyle = _effectiveTextStyle(
      find.text('Thursday · Easy Run'),
      tester,
    );
    final effectivePlanTitleStyle = _effectiveTextStyle(
      find.text('20 min easy run'),
      tester,
    );
    expect(effectiveHeaderTitleStyle?.fontFamily, isNot('monospace'));
    expect(
      effectiveHeaderTitleStyle?.decoration,
      isNot(TextDecoration.underline),
    );
    expect(effectiveDayLabelStyle?.fontFamily, isNot('monospace'));
    expect(effectiveDayLabelStyle?.decoration, isNot(TextDecoration.underline));
    expect(effectivePlanTitleStyle?.fontFamily, isNot('monospace'));
    expect(
      effectivePlanTitleStyle?.decoration,
      isNot(TextDecoration.underline),
    );

    await tester.scrollUntilVisible(
      find.text('Start This Run'),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start This Run'));
    await tester.pumpAndSettle();

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
  });
}
