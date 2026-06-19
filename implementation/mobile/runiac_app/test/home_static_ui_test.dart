import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/core/assets/runiac_assets.dart';
import 'package:runiac_app/features/account/presentation/watch_health_apps_screen.dart';
import 'package:runiac_app/features/home/presentation/data/home_dashboard_demo_snapshots.dart';
import 'package:runiac_app/features/home/presentation/widgets/home_progress_insight_section.dart';
import 'package:runiac_app/features/home/presentation/widgets/today_plan_card.dart';
import 'package:runiac_app/features/run/domain/models/imported_workout_candidate.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';
import 'package:runiac_app/features/run/domain/repositories/health_workout_import_repository.dart';

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

Future<void> _pumpWatchHealthAppsScreen(
  WidgetTester tester, {
  required HealthWorkoutImportRepository appleHealthRepository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WatchHealthAppsScreen(appleHealthRepository: appleHealthRepository),
    ),
  );
  await tester.pumpAndSettle();
}

ImportedWorkoutCandidate _appleHealthCandidate(String externalId) {
  return ImportedWorkoutCandidate(
    externalId: externalId,
    sourceType: RunSourceType.appleHealth,
    activityType: ImportedWorkoutActivityType.running,
    startedAt: DateTime.utc(2026, 6, 18, 6),
    endedAt: DateTime.utc(2026, 6, 18, 6, 30),
    durationSeconds: 1800,
    distanceMeters: 4200,
    avgPaceSecondsPerKm: 429,
    calories: 260,
    heartRateAvailability: HeartRateAvailability.unavailableNotShared,
    importedAt: DateTime.utc(2026, 6, 18, 7),
  );
}

class _FakeHealthWorkoutImportRepository
    implements HealthWorkoutImportRepository {
  _FakeHealthWorkoutImportRepository({
    this.candidates = const <ImportedWorkoutCandidate>[],
    this.error,
    this.resultSequence,
    this.errorSequence,
  });

  final List<ImportedWorkoutCandidate> candidates;
  final Object? error;
  final List<List<ImportedWorkoutCandidate>>? resultSequence;
  final List<Object?>? errorSequence;
  int listCalls = 0;

  @override
  Future<List<ImportedWorkoutCandidate>> listRecentRunningWorkouts() async {
    listCalls += 1;
    final errorIndex = listCalls - 1;
    if (errorSequence != null && errorIndex < errorSequence!.length) {
      final sequenceError = errorSequence![errorIndex];
      if (sequenceError != null) {
        throw sequenceError;
      }
    }
    final resultIndex = listCalls - 1;
    if (resultSequence != null && resultIndex < resultSequence!.length) {
      return List<ImportedWorkoutCandidate>.unmodifiable(
        resultSequence![resultIndex],
      );
    }
    if (error != null) {
      throw error!;
    }
    return List<ImportedWorkoutCandidate>.unmodifiable(candidates);
  }

  @override
  Future<ImportedWorkoutCandidate?> findByExternalId(String externalId) async {
    final candidates = await listRecentRunningWorkouts();
    for (final candidate in candidates) {
      if (candidate.externalId == externalId) {
        return candidate;
      }
    }
    return null;
  }
}

class _CompleterHealthWorkoutImportRepository
    implements HealthWorkoutImportRepository {
  final Completer<List<ImportedWorkoutCandidate>> completer =
      Completer<List<ImportedWorkoutCandidate>>();
  int listCalls = 0;

  @override
  Future<List<ImportedWorkoutCandidate>> listRecentRunningWorkouts() {
    listCalls += 1;
    return completer.future;
  }

  @override
  Future<ImportedWorkoutCandidate?> findByExternalId(String externalId) async {
    final candidates = await listRecentRunningWorkouts();
    for (final candidate in candidates) {
      if (candidate.externalId == externalId) {
        return candidate;
      }
    }
    return null;
  }
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
    expect(find.text('Watch & Health Apps'), findsOneWidget);
    expect(find.text('Connect watch runs and health apps'), findsOneWidget);
    expect(find.text('About Runiac'), findsOneWidget);
    expect(find.text('Connect watch runs later'), findsNothing);
    expect(find.text('Profile settings preview is coming soon.'), findsNothing);
    for (final forbiddenCopy in <String>[
      'Synced',
      'HealthKit',
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

  testWidgets('Account opens Watch and Health Apps preview from Manage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Watch & Health Apps'), findsOneWidget);
    expect(find.text('Connect watch runs and health apps'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Watch & Health Apps'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch & Health Apps'));
    await tester.pumpAndSettle();

    expect(find.text('Watch & Health Apps'), findsOneWidget);
    expect(find.text('MANAGE DEVICES'), findsOneWidget);
    expect(find.text('SERVICES'), findsOneWidget);

    for (final row in <(String, String)>[
      (
        'Connect a new device to Runiac',
        'Use your watch or health app to bring in completed runs later.',
      ),
      ('Apple Watch', 'Set up Apple Health permissions later.'),
      ('Garmin', 'Available later through health app sync.'),
      ('Apple Health', 'Bring in completed runs from Apple Health later.'),
      ('Health Connect', 'Bring in completed runs from Health Connect later.'),
      ('Garmin via Health', 'Use health app sync for Garmin runs later.'),
    ]) {
      expect(find.text(row.$1), findsOneWidget);
      expect(find.text(row.$2), findsOneWidget);
    }

    for (final removedCopy in <String>[
      'Connect your watch runs',
      'Bring in completed runs from Apple Health, Garmin, or Health Connect.',
      'Runs found from your health apps',
      'Preview ready',
      'Later',
      'Available through health sync',
      'Heart rate was not shared',
    ]) {
      expect(find.text(removedCopy), findsNothing);
    }

    for (final removedMetric in <String>[
      '5.00 km',
      '35 min',
      '7:00 /km',
      '154 bpm',
      'Avg HR --',
    ]) {
      expect(find.textContaining(removedMetric), findsNothing);
    }

    for (final forbiddenCopy in <String>[
      'Connected',
      'Synced',
      'Permission granted',
      'Live',
      'Authorize',
      'Upload directly',
      'HealthKit connected',
      'Garmin connected',
      'XP',
      'leaderboard',
      'rank',
      'Level',
    ]) {
      expect(find.textContaining(forbiddenCopy), findsNothing);
    }

    for (final rowTitle in <String>[
      'Connect a new device to Runiac',
      'Apple Watch',
      'Garmin',
      'Health Connect',
      'Garmin via Health',
    ]) {
      await tester.scrollUntilVisible(
        find.text(rowTitle),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(rowTitle));
      await tester.pumpAndSettle();

      expect(find.text('Health connections come next.'), findsOneWidget);
    }
    expect(find.text('Activity History'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Back to Account'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Runiac Runner'), findsOneWidget);
    expect(find.text('Lv. 12'), findsOneWidget);
  });

  testWidgets('Apple Health row checks repository and reports found runs', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthWorkoutImportRepository(
      candidates: [
        _appleHealthCandidate('apple-health-1'),
        _appleHealthCandidate('apple-health-2'),
      ],
    );
    await _pumpWatchHealthAppsScreen(tester, appleHealthRepository: repository);

    await tester.tap(find.text('Apple Health'));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 1);
    expect(find.text('Found 2 Apple Health runs.'), findsOneWidget);
  });

  testWidgets('Apple Health row reports empty runtime result safely', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthWorkoutImportRepository();
    await _pumpWatchHealthAppsScreen(tester, appleHealthRepository: repository);

    await tester.tap(find.text('Apple Health'));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 1);
    expect(find.text('No Apple Health runs found yet.'), findsOneWidget);
  });

  testWidgets('Apple Health row checks again after an empty result', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthWorkoutImportRepository(
      resultSequence: [
        const <ImportedWorkoutCandidate>[],
        [_appleHealthCandidate('apple-health-1')],
      ],
    );
    await _pumpWatchHealthAppsScreen(tester, appleHealthRepository: repository);

    await tester.tap(find.text('Apple Health'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple Health'));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 2);
    expect(find.text('Found 1 Apple Health runs.'), findsOneWidget);
  });

  testWidgets('Apple Health row reports unavailable runtime errors safely', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthWorkoutImportRepository(
      error: StateError('HealthKit unavailable'),
    );
    await _pumpWatchHealthAppsScreen(tester, appleHealthRepository: repository);

    await tester.tap(find.text('Apple Health'));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 1);
    expect(
      find.text('Apple Health is not available right now.'),
      findsOneWidget,
    );
  });

  testWidgets('Apple Health row checks again after a runtime error', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthWorkoutImportRepository(
      resultSequence: [
        const <ImportedWorkoutCandidate>[],
        [_appleHealthCandidate('apple-health-1')],
      ],
      errorSequence: [StateError('HealthKit unavailable'), null],
    );
    await _pumpWatchHealthAppsScreen(tester, appleHealthRepository: repository);

    await tester.tap(find.text('Apple Health'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple Health'));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 2);
    expect(find.text('Found 1 Apple Health runs.'), findsOneWidget);
  });

  testWidgets('Apple Health row ignores overlapping runtime checks safely', (
    WidgetTester tester,
  ) async {
    final repository = _CompleterHealthWorkoutImportRepository();
    await _pumpWatchHealthAppsScreen(tester, appleHealthRepository: repository);

    await tester.tap(find.text('Apple Health'));
    await tester.pump();
    await tester.tap(find.text('Apple Health'));
    await tester.pump();

    expect(repository.listCalls, 1);

    repository.completer.complete([_appleHealthCandidate('apple-health-1')]);
    await tester.pumpAndSettle();

    expect(find.text('Found 1 Apple Health runs.'), findsOneWidget);
  });

  testWidgets('Non Apple Health rows remain preview-only', (
    WidgetTester tester,
  ) async {
    final repository = _FakeHealthWorkoutImportRepository(
      candidates: [_appleHealthCandidate('apple-health-1')],
    );
    await _pumpWatchHealthAppsScreen(tester, appleHealthRepository: repository);

    await tester.tap(find.text('Health Connect'));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 0);
    expect(find.text('Health connections come next.'), findsOneWidget);
    for (final forbiddenCopy in <String>[
      'Connected',
      'Synced',
      'Permission granted',
      'Live',
      'Imported',
      'Added',
    ]) {
      expect(find.textContaining(forbiddenCopy), findsNothing);
    }
  });

  testWidgets('Watch and Health Apps rows align to one list rhythm', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Watch & Health Apps'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch & Health Apps'));
    await tester.pumpAndSettle();

    final rowTitles = <String>[
      'Connect a new device to Runiac',
      'Apple Watch',
      'Garmin',
      'Apple Health',
      'Health Connect',
      'Garmin via Health',
    ];

    for (final rowTitle in rowTitles) {
      await tester.scrollUntilVisible(
        find.text(rowTitle),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
    }

    final rowHeights = rowTitles.map((rowTitle) {
      final rowSurface = find.byWidgetPredicate((widget) {
        return widget is Semantics && widget.properties.label == rowTitle;
      });
      return tester.getSize(rowSurface).height;
    }).toSet();

    expect(rowHeights, hasLength(1));
    expect(rowHeights.single, 80);

    expect(find.byType(Divider), findsNothing);
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
