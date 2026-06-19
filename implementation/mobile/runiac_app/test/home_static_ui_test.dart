import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/core/assets/runiac_assets.dart';
import 'package:runiac_app/features/home/presentation/data/home_dashboard_demo_snapshots.dart';
import 'package:runiac_app/features/home/presentation/widgets/home_progress_insight_section.dart';
import 'package:runiac_app/features/home/presentation/widgets/today_plan_card.dart';

const _todayPlanHeroAssetPath = RuniacAssets.homeTodayPlanRunner;

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
  todayPlan: homeTodayPlanDemoSnapshot,
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
        label: 'Pace rhythm',
        value: 'Improved',
      ),
      HomeInsightRowDemoSnapshot(
        icon: Icons.bar_chart_rounded,
        label: 'Effort balance',
        value: 'Balanced',
      ),
      HomeInsightRowDemoSnapshot(
        icon: Icons.track_changes_rounded,
        label: 'Goal progress',
        value: 'On track',
      ),
    ],
    chartLabels: ['May 6', 'May 13', 'May 20', 'May 27', 'Jun 3'],
    chartValues: [0.42, 0.33, 0.18, 0.36, 0.55, 0.62, 0.72],
  ),
  exploreRoutes: homeExploreRouteDemoSnapshots,
);

void main() {
  testWidgets('Home dashboard keeps a calm primary quick start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    expect(
      RuniacAssets.homeTodayPlanRunner,
      'assets/images/home/todays_plan_runner.png',
    );
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
    expect(find.text('Pace rhythm'), findsOneWidget);
    expect(find.text('Improved'), findsOneWidget);
    expect(find.text('Effort balance'), findsOneWidget);
    expect(find.text('Balanced'), findsOneWidget);
    expect(find.text('Goal progress'), findsOneWidget);
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

    final todayPlanRect = tester.getRect(find.byType(TodayPlanCard));
    final progressSectionRect = tester.getRect(
      find.byType(HomeProgressInsightSection),
    );
    expect(todayPlanRect.left, lessThan(progressSectionRect.left));
    expect(todayPlanRect.right, greaterThan(progressSectionRect.right));

    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications preview is coming soon.'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Runiac'), findsNothing);
    expect(find.text('Runiac Runner'), findsOneWidget);
    final displayName = tester.widget<Text>(find.text('Runiac Runner'));
    expect(displayName.maxLines, 2);
    expect(displayName.overflow, TextOverflow.ellipsis);
    expect(find.text('Jurong East, Singapore'), findsOneWidget);
    expect(find.text('Lv. 12'), findsOneWidget);
    expect(find.text('Preview only'), findsNothing);
    expect(find.text('Goal'), findsNothing);
    expect(find.text('Lv. 1'), findsNothing);
    expect(find.text('Beginner 10K preparation'), findsNothing);
    expect(find.text('Building consistency'), findsNothing);
    expect(
      find.text('Account changes are not saved in this prototype.'),
      findsOneWidget,
    );
    expect(find.text('RUNNING SETUP'), findsOneWidget);
    expect(find.text('Current goal'), findsOneWidget);
    expect(find.text('Build a consistent 10K habit'), findsOneWidget);
    expect(find.text('Preferred unit'), findsOneWidget);
    expect(find.text('Kilometers'), findsOneWidget);
    expect(find.text('Weekly rhythm'), findsOneWidget);
    expect(find.text('3 gentle sessions / week'), findsOneWidget);
    expect(find.text('Experience'), findsOneWidget);
    expect(find.text('Beginner runner'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Privacy & Safety'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('About Runiac'), findsOneWidget);
    expect(find.text('Watch & Health Apps'), findsNothing);
    expect(find.text('Connect watch runs later'), findsNothing);
    expect(find.text('Profile settings preview is coming soon.'), findsNothing);
    for (final forbiddenCopy in <String>[
      'Synced',
      'HealthKit',
      'Health Connect',
      'Garmin',
      'Connected',
      'logout',
      'delete account',
      'Firebase',
      'Auth',
      'Signed in',
      'signed in',
      'verified account',
      'location permission',
      'GPS',
      'subscription',
      'entitlement',
      'XP',
      'streak',
      'level',
      'Level',
      'rank',
      'leaderboard',
      'published',
      'approved',
      'expert publication',
      'admin review',
    ]) {
      expect(find.textContaining(forbiddenCopy), findsNothing);
    }

    await tester.tap(find.bySemanticsLabel('Back to Home'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Account'), findsNothing);

    expect(find.text('This Week\'s Plan'), findsNothing);
    expect(find.text('Last Run'), findsNothing);
    expect(find.text('Post-run Feedback'), findsNothing);
    expect(find.text('Complete a run to see your summary.'), findsNothing);
    expect(
      find.text('Feedback will appear after a completed run.'),
      findsNothing,
    );
    expect(find.text('View Details'), findsNothing);
    expect(find.text('Ready for an easy run?'), findsNothing);
    expect(find.text('Start small and keep it comfortable.'), findsNothing);
    expect(find.textContaining(_forbiddenTrustedStateCopy), findsNothing);
  });

  testWidgets('Account profile preview rows stay preview-only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);

    for (final row in <(String, String)>[
      ('Settings', 'Settings preview is coming soon.'),
      ('Privacy & Safety', 'Privacy & Safety preview is coming soon.'),
      ('Notifications', 'Notification preferences preview is coming soon.'),
      ('About Runiac', 'About Runiac preview is coming soon.'),
    ]) {
      await tester.scrollUntilVisible(
        find.text(row.$1),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(row.$1));
      await tester.pumpAndSettle();

      expect(find.text(row.$2), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    }
  });

  testWidgets('Account profile preview fits a narrow mobile surface', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Runiac'), findsNothing);
    expect(find.text('Runiac Runner'), findsOneWidget);
    expect(find.text('Jurong East, Singapore'), findsOneWidget);
    expect(find.text('Lv. 12'), findsOneWidget);
    expect(find.text('Preview only'), findsNothing);
    expect(find.text('Goal'), findsNothing);
    expect(find.text('Lv. 1'), findsNothing);
    expect(find.text('Beginner 10K preparation'), findsNothing);
    expect(find.text('Building consistency'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Privacy & Safety'), findsOneWidget);
    expect(find.bySemanticsLabel('Back to Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home progress insight section fits a narrow mobile surface', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

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

  testWidgets('Home goal progress percentage is vertically centered', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: HomeProgressInsightSection(),
          ),
        ),
      ),
    );

    final progressLabelRect = tester.getRect(find.text('43%'));
    final progressBarRect = tester.getRect(
      find.ancestor(of: find.text('43%'), matching: find.byType(Stack)).last,
    );

    expect(
      (progressLabelRect.center.dy - progressBarRect.center.dy).abs(),
      lessThanOrEqualTo(0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home Explore Routes replaces the old routes empty state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    expect(find.text('Recommended Routes'), findsNothing);
    expect(find.text('Community routes will appear here.'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Explore Routes'),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore Routes'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
    expect(find.text('Haneul Park Trail'), findsOneWidget);
    expect(find.text('3.2 km · 25 min · Easy'), findsOneWidget);
    expect(find.text('Flat • Popular for Sunset'), findsNothing);
    expect(find.text('3.2 km'), findsWidgets);

    await tester.tap(find.text('View All'));
    await tester.pumpAndSettle();

    expect(find.text('Route explorer preview'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('home_explore_routes_carousel')),
      const Offset(-220, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olympic Park Loop'), findsOneWidget);
    expect(find.text('5.0 km · 40 min · Moderate'), findsOneWidget);
    expect(find.text('Moderate • Wide Paths'), findsNothing);
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

  testWidgets(
    'Home today plan hero keeps runner image and fills a narrow mobile surface',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayPlanCard(onViewPlan: () {}, onQuickStart: () {}),
          ),
        ),
      );

      expect(find.text('Today\'s Plan'), findsOneWidget);
      expect(find.text('20 min easy run'), findsOneWidget);
      expect(find.text('Goal Mode: First 5K'), findsOneWidget);
      expect(
        find.text('Build consistency with an easy, comfortable effort.'),
        findsOneWidget,
      );
      expect(find.text('View Plan'), findsOneWidget);
      expect(find.text('Quick Start'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('today_plan_hero_image')),
        findsOneWidget,
      );
      final heroClipFinder = find.ancestor(
        of: find.text('Today\'s Plan'),
        matching: find.byType(ClipRRect),
      );
      expect(heroClipFinder, findsNothing);
      final heroRect = tester.getRect(find.byType(TodayPlanCard));
      expect(heroRect.left, equals(0));
      expect(heroRect.right, equals(tester.view.physicalSize.width));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home Quick Start opens the existing run launch screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.text('Quick Start'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('Waiting for GPS'), findsNothing);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('Good to see you'), findsNothing);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('Home View Plan opens today workout detail without editing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

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

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('Waiting for GPS'), findsNothing);
    expect(find.text('Start run'), findsOneWidget);
  });
}
