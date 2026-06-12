import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/home/presentation/data/home_dashboard_demo_snapshots.dart';
import 'package:runiac_app/features/home/presentation/widgets/home_progress_insight_section.dart';
import 'package:runiac_app/features/home/presentation/widgets/today_plan_card.dart';

const _todayPlanHeroAssetPath = 'assets/images/home/todays_plan_runner.png';

final _forbiddenTrustedStateCopy = RegExp(
  r'leaderboard score|saved count|popularity|owned|territory owned|'
  r'route completed|activity saved|synced|premium|subscription|'
  r'validated|eligible|enrolled|official',
  caseSensitive: false,
);

TextStyle? _effectiveTextStyle(Finder textFinder, WidgetTester tester) {
  final richText = tester.widget<RichText>(
    find.descendant(of: textFinder, matching: find.byType(RichText)).first,
  );
  return richText.text.style;
}

Finder _nearestDecoratedBoxContaining(String text) {
  return find
      .ancestor(of: find.text(text), matching: find.byType(DecoratedBox))
      .last;
}

const _longXpHomeSnapshot = HomeDashboardDemoSnapshot(
  goal: HomeGoalProgressDemoSnapshot(
    title: 'First 10K Preparation',
    weekLabel: 'Week 3 of 8',
    progressLabel: '43%',
    milestoneLabel: 'Next Milestone',
    milestoneValue: 'Complete 6 km comfortably',
  ),
  streak: HomeMetricDemoSnapshot(
    title: 'Streak',
    value: '6 days',
    caption: 'Keep it going!',
  ),
  xp: HomeMetricDemoSnapshot(
    title: 'XP',
    value: '100,000 xp',
    caption: '360 XP to Lv.13',
  ),
  insight: HomeInsightDemoSnapshot(
    title: 'Advanced Insight',
    rows: [
      HomeInsightRowDemoSnapshot(
        icon: Icons.show_chart_rounded,
        label: 'Pace consistency',
        value: 'Improved',
      ),
      HomeInsightRowDemoSnapshot(
        icon: Icons.bar_chart_rounded,
        label: 'Training load',
        value: 'Balanced',
      ),
      HomeInsightRowDemoSnapshot(
        icon: Icons.track_changes_rounded,
        label: 'Goal forecast',
        value: 'On track',
      ),
    ],
    chartLabels: ['May 6', 'May 13', 'May 20', 'May 27', 'Jun 3'],
    chartValues: [0.42, 0.33, 0.18, 0.36, 0.55, 0.62, 0.72],
  ),
);

void main() {
  testWidgets('Home dashboard keeps a calm primary quick start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    expect(find.text('First 10K Preparation'), findsOneWidget);
    expect(find.text('Week 3 of 8'), findsOneWidget);
    expect(find.text('43%'), findsWidgets);
    expect(find.text('Next Milestone'), findsOneWidget);
    expect(find.text('Complete 6 km comfortably'), findsOneWidget);
    expect(find.text('Readiness'), findsNothing);
    expect(find.text('+5% vs last week'), findsNothing);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('6 days'), findsOneWidget);
    expect(find.text('Keep it going!'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('1,240 xp'), findsOneWidget);
    expect(find.text('360 XP to Lv.13'), findsOneWidget);
    expect(find.text('Advanced Insight'), findsOneWidget);
    expect(find.text('Pace consistency'), findsOneWidget);
    expect(find.text('Improved'), findsOneWidget);
    expect(find.text('Training load'), findsOneWidget);
    expect(find.text('Balanced'), findsOneWidget);
    expect(find.text('Goal forecast'), findsOneWidget);
    expect(find.text('On track'), findsOneWidget);
    expect(
      find.text('Your training preparation will appear here.'),
      findsNothing,
    );
    expect(
      find.text('Progress summaries will appear after verified runs.'),
      findsNothing,
    );
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

    await tester.scrollUntilVisible(
      find.text('This Week\'s Plan'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('This Week\'s Plan'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Last Run'),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Last Run'), findsOneWidget);
    expect(find.text('View Details'), findsNothing);
    expect(find.text('Ready for an easy run?'), findsNothing);
    expect(find.text('Start small and keep it comfortable.'), findsNothing);
    expect(find.textContaining(_forbiddenTrustedStateCopy), findsNothing);
  });

  testWidgets('Home progress insight section fits a narrow mobile surface', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RuniacApp(showSplash: false));

    expect(find.text('First 10K Preparation'), findsOneWidget);
    expect(find.text('Readiness'), findsNothing);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('6 days'), findsOneWidget);
    expect(find.text('Keep it going!'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('1,240 xp'), findsOneWidget);
    expect(find.text('360 XP to Lv.13'), findsOneWidget);
    expect(find.text('Advanced Insight'), findsOneWidget);

    final streakTitleRect = tester.getRect(find.text('Streak'));
    final xpTitleRect = tester.getRect(find.text('XP'));
    final streakValueRect = tester.getRect(find.text('6 days'));
    final xpValueRect = tester.getRect(find.text('1,240 xp'));
    final streakCaptionRect = tester.getRect(find.text('Keep it going!'));
    final xpCaptionRect = tester.getRect(find.text('360 XP to Lv.13'));
    final streakCardHeight = tester
        .getSize(_nearestDecoratedBoxContaining('Streak'))
        .height;
    final xpCardHeight = tester
        .getSize(_nearestDecoratedBoxContaining('XP'))
        .height;

    expect(streakTitleRect.center.dx, lessThan(xpTitleRect.center.dx));
    expect(
      (streakTitleRect.center.dy - xpTitleRect.center.dy).abs(),
      lessThan(1),
    );
    expect(
      (streakValueRect.center.dy - xpValueRect.center.dy).abs(),
      lessThan(1),
    );
    expect(
      (streakCaptionRect.center.dy - xpCaptionRect.center.dy).abs(),
      lessThan(1),
    );
    expect((streakCardHeight - xpCardHeight).abs(), lessThan(1));
    expect(streakCardHeight, lessThan(102));
    expect(xpCardHeight, lessThan(102));
    expect(
      tester
          .widget<Icon>(find.byIcon(Icons.local_fire_department_rounded))
          .size,
      lessThanOrEqualTo(27),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.star_rounded)).size,
      lessThanOrEqualTo(27),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home XP mini card fits a long display value', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: HomeProgressInsightSection(snapshot: _longXpHomeSnapshot),
          ),
        ),
      ),
    );

    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('6 days'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('100,000 xp'), findsOneWidget);
    expect(find.text('360 XP to Lv.13'), findsOneWidget);

    final streakTitleRect = tester.getRect(find.text('Streak'));
    final xpTitleRect = tester.getRect(find.text('XP'));
    final longXpValueRect = tester.getRect(find.text('100,000 xp'));
    final xpCardRect = tester.getRect(_nearestDecoratedBoxContaining('XP'));

    expect(streakTitleRect.center.dx, lessThan(xpTitleRect.center.dx));
    expect(longXpValueRect.left, greaterThanOrEqualTo(xpCardRect.left));
    expect(longXpValueRect.right, lessThanOrEqualTo(xpCardRect.right));
    expect(tester.takeException(), isNull);
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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
