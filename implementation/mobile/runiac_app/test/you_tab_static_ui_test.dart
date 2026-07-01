import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/cadence_graph_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/complete_run_result.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_activity_display_model.dart';
import 'package:runiac_app/features/run/domain/models/run_route_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/services/advanced_analysis_snapshot_builder.dart';
import 'package:runiac_app/features/run/presentation/advanced_analysis_screen.dart';
import 'package:runiac_app/features/run/presentation/active_run_session_coordinator.dart';
import 'package:runiac_app/features/run/presentation/data/pace_graph_demo_snapshots.dart';
import 'package:runiac_app/features/run/presentation/data/run_completion_demo_snapshots.dart';
import 'package:runiac_app/features/run/presentation/view_summary_screen.dart';
import 'package:runiac_app/features/run/presentation/widgets/advanced_analysis/advanced_analysis_charts.dart';
import 'package:runiac_app/features/you/data/static_activity_history_repository.dart';
import 'package:runiac_app/features/you/presentation/current_session_activity_history.dart';
import 'package:runiac_app/features/you/presentation/data/activity_history_demo_snapshots.dart';
import 'package:runiac_app/features/you/presentation/data/you_overview_demo_snapshots.dart';
import 'package:runiac_app/features/you/domain/models/activity_history_read_model.dart';
import 'package:runiac_app/features/you/domain/repositories/activity_history_repository.dart';
import 'package:runiac_app/features/you/presentation/widgets/activity_route_preview.dart';
import 'package:runiac_app/features/you/presentation/widgets/compact_run_activity_card.dart';
import 'package:runiac_app/features/you/presentation/widgets/monthly_distance_graph.dart';

final _progressToday = DateTime(2026, 6, 30);

Future<void> _openYouTab(
  WidgetTester tester, {
  ActiveRunSessionCoordinator? activeRunSessionCoordinator,
  CurrentSessionActivityHistoryStore? activityHistoryStore,
  ActivityHistoryRepository? activityHistoryRepository,
}) async {
  await tester.pumpWidget(
    RuniacApp(
      showSplash: false,
      enableForegroundGps: false,
      activeRunSessionCoordinator: activeRunSessionCoordinator,
      currentSessionActivityHistoryStore: activityHistoryStore,
      activityHistoryRepository:
          activityHistoryRepository ?? const StaticActivityHistoryRepository(),
      youProgressToday: _progressToday,
    ),
  );
  await tester.tap(find.byTooltip('You'));
  await tester.pumpAndSettle();
}

class _AggregateProgressRepository implements ActivityHistoryRepository {
  const _AggregateProgressRepository();

  @override
  Future<ActivityHistoryReadModel> loadActivityHistory() async {
    final activities = [
      _activity(
        id: 'aggregate-week',
        title: 'Aggregate Week Run',
        date: '30 Jun 2026',
        distance: 'label hidden',
        distanceMeters: 4250,
      ),
      _activity(
        id: 'aggregate-month',
        title: 'Aggregate Month Run',
        date: '2 Jun 2026',
        distance: 'label hidden',
        distanceMeters: 3500,
      ),
      _activity(
        id: 'aggregate-year',
        title: 'Aggregate Year Run',
        date: '4 May 2026',
        distance: 'label hidden',
        distanceMeters: 8100,
      ),
      _activity(
        id: 'aggregate-all',
        title: 'Aggregate All Run',
        date: '24 Dec 2025',
        distance: 'label hidden',
        distanceMeters: 1050,
      ),
      _activity(
        id: 'aggregate-invalid',
        title: 'Aggregate Invalid Distance',
        date: '30 Jun 2026',
        distance: 'distance pending',
        distanceMeters: 0,
      ),
    ];

    return ActivityHistoryReadModel(
      recentRuns: activities.take(3).toList(growable: false),
      months: [
        ActivityHistoryMonthReadModel(
          label: 'June 2026',
          activities: [activities[0], activities[1], activities[4]],
        ),
        ActivityHistoryMonthReadModel(
          label: 'May 2026',
          activities: [activities[2]],
        ),
        ActivityHistoryMonthReadModel(
          label: 'December 2025',
          activities: [activities[3]],
        ),
      ],
    );
  }

  ActivityHistoryItemReadModel _activity({
    required String id,
    required String title,
    required String date,
    required String distance,
    required int distanceMeters,
  }) {
    return ActivityHistoryItemReadModel(
      activityId: id,
      title: title,
      completedAtLabel: date,
      distanceLabel: distance,
      distanceMeters: distanceMeters,
      paceLabel: '7’10”',
      durationLabel: '22:56',
      timeLabel: '7:20 AM',
      routeNameLabel: 'Aggregate Test Route',
    );
  }
}

ActiveRunSessionCoordinator _testActiveRunSessionCoordinator(
  WidgetTester tester,
) {
  final activeRunSessionCoordinator = ActiveRunSessionCoordinator(
    clock: tester.binding.clock.now,
    foregroundTickStep: const Duration(seconds: 1),
  );
  addTearDown(activeRunSessionCoordinator.dispose);
  return activeRunSessionCoordinator;
}

Future<void> _openActivityHistoryFromYou(WidgetTester tester) async {
  await _openYouTab(tester);
  await _tapRecentRunningSeeAll(tester);
}

Future<void> _tapRecentRunningSeeAll(WidgetTester tester) async {
  final seeAll = find.byKey(const ValueKey('recent_running_see_all'));
  await Scrollable.ensureVisible(tester.element(seeAll), alignment: 0.55);
  await tester.pumpAndSettle();
  await tester.tap(seeAll);
  await tester.pumpAndSettle();
}

CompleteRunResult _sessionCompletion({
  required String activityId,
  required String title,
  required String distanceKm,
  String dateLabel = 'Today',
  bool hasSufficientData = true,
  RunRouteSnapshot route = RunRouteSnapshot.empty,
}) {
  return CompleteRunResult(
    activityId: activityId,
    summaryId: 'summary-$activityId',
    progressionEventId: 'progression-$activityId',
    summary: RunSummarySnapshot(
      title: title,
      dateLabel: dateLabel,
      timeLabel: '8:10 AM',
      distanceKm: distanceKm,
      avgPace: '6’15”',
      duration: '18:30',
      avgHeartRate: '--',
      calories: '--',
      routeName: 'Current Session Route',
      hasSufficientData: hasSufficientData,
      route: route,
    ),
    xpUpdate: defaultXpUpdateDisplayModel,
  );
}

RunActivityDisplayModel _displayRun({
  required String activityId,
  required String title,
}) {
  return RunActivityDisplayModel(
    activityId: activityId,
    title: title,
    timeAgoLabel: '12 Jun 2026',
    distanceLabel: '3.20 km',
    distanceMeters: 3200,
    paceLabel: '7’10”',
    durationLabel: '22:56',
    summary: RunSummarySnapshot(
      title: title,
      dateLabel: '12 Jun 2026',
      timeLabel: '7:20 AM',
      distanceKm: '3.20',
      avgPace: '7’10”',
      duration: '22:56',
      avgHeartRate: '--',
      calories: '--',
      routeName: 'Repository Route',
    ),
  );
}

RunRouteSnapshot _sessionRouteFixture() {
  final startedAt = DateTime.utc(2026, 6, 18, 8, 10);

  return RunRouteSnapshot(
    segments: [
      [
        RunLocationSample(
          recordedAt: startedAt,
          latitude: 1.301,
          longitude: 103.801,
        ),
        RunLocationSample(
          recordedAt: startedAt.add(const Duration(seconds: 90)),
          latitude: 1.3018,
          longitude: 103.8021,
        ),
        RunLocationSample(
          recordedAt: startedAt.add(const Duration(seconds: 180)),
          latitude: 1.3025,
          longitude: 103.8016,
        ),
      ],
    ],
    lastKnownLocation: RunLocationSample(
      recordedAt: startedAt.add(const Duration(seconds: 180)),
      latitude: 1.3025,
      longitude: 103.8016,
    ),
  );
}

RunRouteSnapshot _singlePointRouteFixture() {
  final startedAt = DateTime.utc(2026, 6, 18, 8, 10);

  return RunRouteSnapshot(
    segments: [
      [
        RunLocationSample(
          recordedAt: startedAt,
          latitude: 1.301,
          longitude: 103.801,
        ),
      ],
    ],
    lastKnownLocation: RunLocationSample(
      recordedAt: startedAt,
      latitude: 1.301,
      longitude: 103.801,
    ),
  );
}

RunRouteSnapshot _noLocationRouteFixture() {
  return const RunRouteSnapshot();
}

RunRouteSnapshot _stationaryRouteFixture() {
  final startedAt = DateTime.utc(2026, 6, 18, 8, 10);

  return RunRouteSnapshot(
    segments: [
      [
        RunLocationSample(
          recordedAt: startedAt,
          latitude: 1.301,
          longitude: 103.801,
        ),
        RunLocationSample(
          recordedAt: startedAt.add(const Duration(seconds: 1)),
          latitude: 1.30100001,
          longitude: 103.80100001,
        ),
      ],
    ],
    lastKnownLocation: RunLocationSample(
      recordedAt: startedAt.add(const Duration(seconds: 1)),
      latitude: 1.30100001,
      longitude: 103.80100001,
    ),
  );
}

const _transparentPixelPng = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class _FakeActivityRouteThumbnailProvider
    implements ActivityRouteThumbnailProvider {
  _FakeActivityRouteThumbnailProvider(this.result);

  final ActivityRouteThumbnailResult result;
  ActivityRouteThumbnailRequest? lastRequest;
  int requestCount = 0;

  @override
  Future<ActivityRouteThumbnailResult> resolve(
    ActivityRouteThumbnailRequest request,
  ) async {
    requestCount += 1;
    lastRequest = request;
    return result;
  }
}

class _CompletingActivityRouteThumbnailProvider
    implements ActivityRouteThumbnailProvider {
  _CompletingActivityRouteThumbnailProvider();

  final Completer<ActivityRouteThumbnailResult> completer =
      Completer<ActivityRouteThumbnailResult>();
  ActivityRouteThumbnailRequest? lastRequest;
  int requestCount = 0;

  @override
  Future<ActivityRouteThumbnailResult> resolve(
    ActivityRouteThumbnailRequest request,
  ) {
    requestCount += 1;
    lastRequest = request;
    return completer.future;
  }
}

void main() {
  void expectDistanceGraph(
    WidgetTester tester, {
    List<double> expectedValues = const [
      2.5,
      5,
      0,
      0,
      3.8,
      5,
      4.5,
      4.09,
      0,
      0,
      0,
      1.1,
    ],
    String axisLabelPattern = r'0 km.*2 km.*5 km',
  }) {
    final graphFinder = find.byKey(
      const ValueKey('you_monthly_distance_graph'),
    );
    expect(graphFinder, findsOneWidget);

    final graph = tester.widget<PastTwelveWeeksDistanceGraph>(graphFinder);
    expect(graph.labels, ['APR', 'MAY', 'JUN']);
    expect(graph.values, hasLength(expectedValues.length));
    for (var index = 0; index < expectedValues.length; index += 1) {
      expect(graph.values[index], closeTo(expectedValues[index], 0.001));
    }
    expect(
      find.bySemanticsLabel(
        RegExp(
          'Past 12 weeks distance graph.*APR.*MAY.*JUN.*$axisLabelPattern',
        ),
      ),
      findsOneWidget,
    );
  }

  testWidgets(
    'current-session single-point route renders snapshot with orange dot only',
    (WidgetTester tester) async {
      final provider = _FakeActivityRouteThumbnailProvider(
        ActivityRouteThumbnailResult.readyImage(
          MemoryImage(Uint8List.fromList(_transparentPixelPng)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityRoutePreview(
              route: _singlePointRouteFixture(),
              thumbnailProvider: provider,
              allowExternalStaticMap: true,
              isCurrentSessionRoute: true,
              activityId: 'low-data-one-point',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(provider.requestCount, 1);
      expect(provider.lastRequest!.allowExternalStaticMap, isTrue);
      expect(provider.lastRequest!.isCurrentSessionRoute, isTrue);
      expect(provider.lastRequest!.isDemoRoute, isFalse);
      expect(
        provider.lastRequest!.route.lastKnownLocation?.latitude,
        closeTo(1.301, 0.000001),
      );
      expect(
        find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey(
            'activity_route_preview_static_thumbnail_location_dot',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey(
            'activity_route_preview_static_thumbnail_route_overlay',
          ),
        ),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('activity_route_preview_polyline')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('activity_route_preview_fallback')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'current-session single-point route replaces local grid with ready image',
    (WidgetTester tester) async {
      final provider = _CompletingActivityRouteThumbnailProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityRoutePreview(
              route: _singlePointRouteFixture(),
              thumbnailProvider: provider,
              allowExternalStaticMap: true,
              isCurrentSessionRoute: true,
              activityId: 'low-data-one-point',
            ),
          ),
        ),
      );

      expect(provider.requestCount, 1);
      expect(
        find.byKey(const ValueKey('activity_route_preview_tiny_route')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
        findsNothing,
      );

      provider.completer.complete(
        ActivityRouteThumbnailResult.readyImage(
          MemoryImage(Uint8List.fromList(_transparentPixelPng)),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey(
            'activity_route_preview_static_thumbnail_location_dot',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('activity_route_preview_tiny_route')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('activity_route_preview_fallback')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'current-session no-location route keeps fallback without provider request',
    (WidgetTester tester) async {
      final provider = _FakeActivityRouteThumbnailProvider(
        ActivityRouteThumbnailResult.readyImage(
          MemoryImage(Uint8List.fromList(_transparentPixelPng)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityRoutePreview(
              route: _noLocationRouteFixture(),
              thumbnailProvider: provider,
              allowExternalStaticMap: true,
              isCurrentSessionRoute: true,
              activityId: 'low-data-no-location',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(provider.requestCount, 0);
      expect(
        find.byKey(const ValueKey('activity_route_preview_fallback')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey(
            'activity_route_preview_static_thumbnail_location_dot',
          ),
        ),
        findsNothing,
      );
    },
  );

  test(
    'pace chart display anchors sufficient graph endpoints to final slot',
    () {
      for (final graph in [
        normalEasyRunPaceGraph,
        gpsSpikeRunPaceGraph,
        recoveryJogPaceGraph,
      ]) {
        expect(graph.isAvailable, isTrue);
        expect(graph.points.length, greaterThanOrEqualTo(3));
        expect(
          paceChartDisplayProgressForPoint(
            index: 0,
            pointCount: graph.points.length,
            rawProgressFraction: graph.points.first.progressFraction,
          ),
          0,
        );
        expect(
          paceChartDisplayProgressForPoint(
            index: graph.points.length - 1,
            pointCount: graph.points.length,
            rawProgressFraction: graph.points.last.progressFraction,
          ),
          1,
        );
        expect(
          paceChartDisplayProgressForPoint(
            index: 1,
            pointCount: graph.points.length,
            rawProgressFraction: graph.points[1].progressFraction,
          ),
          graph.points[1].progressFraction,
        );
      }
    },
  );

  test('You static demo snapshots live outside presentation widgets', () {
    // Given: the You feature keeps demo/read-only data behind a data boundary.
    final dataFiles = [
      'lib/features/you/presentation/data/you_overview_demo_snapshots.dart',
      'lib/features/you/presentation/data/activity_history_demo_snapshots.dart',
      'lib/features/you/presentation/data/goal_plan_demo_snapshots.dart',
      'lib/features/you/presentation/data/weekly_workout_demo_snapshots.dart',
      'lib/features/you/presentation/data/expert_plan_demo_snapshots.dart',
    ];

    // Then: each expected snapshot file exists for backend-readiness.
    for (final path in dataFiles) {
      expect(File(path).existsSync(), isTrue, reason: '$path must exist');
    }

    final presentationFiles = {
      'lib/features/you/presentation/you_tab.dart': [
        'const _progressSnapshot =',
        'const _plansSnapshot =',
        'class _YouProgressSnapshot',
        'class _YouPlansSnapshot',
      ],
      'lib/features/you/presentation/activity_history_screen.dart': [
        'const activityHistoryDisplayData =',
        'class _ActivityHistoryMonth',
      ],
      'lib/features/you/presentation/goal_plan_detail_screen.dart': [
        'const goalPlanDisplaySnapshot =',
        'const _sampleDailyPlan =',
      ],
      'lib/features/you/presentation/weekly_workout_detail_screen.dart': [
        'const weeklyWorkoutDetailSnapshot =',
        'const saturdayWeeklyWorkoutDetailSnapshot =',
      ],
      'lib/features/you/presentation/expert_plan_list_screen.dart': [
        'const _expertPlanFilters =',
        'const _expertPlans =',
        'class _ExpertPlanDisplay',
      ],
      'lib/features/you/presentation/expert_plan_detail_screen.dart': [
        'const expertPlanDetailSnapshot =',
      ],
    };

    // Then: large presentation widgets no longer own static/demo snapshots.
    for (final entry in presentationFiles.entries) {
      final source = File(entry.key).readAsStringSync();
      for (final forbiddenSnippet in entry.value) {
        expect(
          source,
          isNot(contains(forbiddenSnippet)),
          reason: '${entry.key} still contains $forbiddenSnippet',
        );
      }
    }
  });

  test(
    'Activity History cadence QA fixture carries local cadence analysis',
    () {
      final qaRun = activityHistoryDisplayData
          .expand((month) => month.activities)
          .singleWhere((activity) => activity.title == 'Pace Graph QA Run');

      final cadence = const AdvancedAnalysisSnapshotBuilder()
          .fromRunSummary(qaRun.summary)
          .formCadence;
      final cadenceGraph = cadence.cadenceGraph.value!;

      expect(cadence.averageCadence.valueLabel, '173 spm');
      expect(
        cadence.cadenceGraph.availability,
        AdvancedAnalysisMetricAvailability.available,
      );
      expect(
        cadence.cadenceGraph.source,
        AdvancedAnalysisMetricSource.localGpsDerived,
      );
      expect(cadenceGraph.isAvailable, isTrue);
      expect(cadenceGraph.points.map((point) => point.cadenceSpm), [
        173,
        170,
        172,
        174,
        176,
      ]);
      expect(cadenceGraph.points.map((point) => point.elapsedSeconds), [
        0,
        120,
        240,
        360,
        480,
      ]);
      expect(cadenceGraph.lowestCadencePoint?.cadenceSpm, 170);
      expect(cadenceGraph.highestCadencePoint?.cadenceSpm, 176);
      expect(cadenceGraph.targetLabel, demoCadenceGraphTargetLabel);
      expect(cadenceGraph.targetMinCadenceSpm, demoCadenceGraphTargetMinSpm);
      expect(cadenceGraph.targetMaxCadenceSpm, demoCadenceGraphTargetMaxSpm);
      expect(cadenceGraph.targetKind, CadenceGraphTargetKind.demo);
      expect(cadence.strideConsistency.valueLabel, 'stable');
      expect(cadence.cadenceStatus.valueLabel, 'stable');
      expect(
        cadence.averageCadence.source,
        AdvancedAnalysisMetricSource.localGpsDerived,
      );
    },
  );

  test(
    'Recent Running demo route fixtures expose route previews for every capped card',
    () {
      // Given: Recent Running shows the three newest static/demo activities.
      final recentRuns = youProgressSnapshot.runs.take(3).toList();

      // Then: each capped demo card carries enough route geometry for a
      // route-specific preview instead of the generic fallback drawing.
      expect(recentRuns, hasLength(3));
      expect(recentRuns.map((activity) => activity.title), [
        'Saturday Night Run',
        'Morning Easy Run',
        'Recovery Jog',
      ]);
      for (final activity in recentRuns) {
        expect(
          activity.summary.route.hasRoute,
          isTrue,
          reason: '${activity.title} should render a route-backed preview',
        );
      }
    },
  );

  test(
    'Activity History demo route fixtures distinguish route-backed and fallback previews',
    () {
      final activities = {
        for (final activity in activityHistoryDisplayData.expand(
          (month) => month.activities,
        ))
          activity.title: activity,
      };

      for (final title in const [
        'Pace Graph QA Run',
        'Easy Morning Jog',
        'Sunset Loop',
        'Tuesday Tempo',
        'Park Walk + Run',
        'First 5K Attempt',
        'Gentle Start',
      ]) {
        expect(
          activities[title]?.summary.route.hasRoute,
          isTrue,
          reason: '$title should render a route-backed preview',
        );
      }
      expect(
        activities['Riverside Recovery']?.summary.route.hasRoute,
        isFalse,
        reason: 'Low-data activity should keep the fallback preview',
      );
    },
  );

  testWidgets('You page shows progress overview sections when selected', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    expect(find.text('You'), findsWidgets);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Plans'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Weekly Distance'), findsOneWidget);
    expect(find.text('Monthly Distance'), findsNothing);
    expect(find.text('Past 12 weeks'), findsOneWidget);
    expect(find.text('1.10'), findsOneWidget);
    expectDistanceGraph(tester);
    expect(find.text('3 runs this week'), findsNothing);
    expect(find.text('82% of weekly goal'), findsNothing);
    expect(find.text('This Week'), findsNothing);
    expect(find.text('Consistency Streak'), findsOneWidget);
    expect(find.text('6 days'), findsOneWidget);
    expect(find.text('Running Calendar'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Recent Running'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Recent Running')).dx,
      lessThan(tester.getTopLeft(find.text('See all')).dx),
    );
    expect(find.text('Saturday Night Run'), findsOneWidget);
    expect(find.text('Morning Easy Run'), findsOneWidget);
    expect(find.text('Recovery Jog'), findsOneWidget);
    final recentRunCards = find.byType(CompactRunActivityCard);
    expect(recentRunCards, findsNWidgets(3));
    expect(
      find.descendant(
        of: recentRunCards,
        matching: find.byIcon(Icons.chevron_right_rounded),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: recentRunCards,
        matching: find.byKey(const ValueKey('activity_route_preview_slot')),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: recentRunCards,
        matching: find.byKey(const ValueKey('activity_route_preview_polyline')),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: recentRunCards,
        matching: find.byKey(const ValueKey('activity_route_preview_fallback')),
      ),
      findsNothing,
    );
    final firstRecentCard = find.byKey(
      const ValueKey('recent_running_card_Saturday Night Run'),
    );
    expect(
      tester
          .getTopLeft(
            find.descendant(
              of: firstRecentCard,
              matching: find.byKey(const ValueKey('activity_card_content')),
            ),
          )
          .dx,
      greaterThan(
        tester
            .getRect(
              find.descendant(
                of: firstRecentCard,
                matching: find.byKey(
                  const ValueKey('activity_route_preview_slot'),
                ),
              ),
            )
            .right,
      ),
    );
    expect(
      find.descendant(of: recentRunCards, matching: find.text('DISTANCE')),
      findsNWidgets(3),
    );
    expect(
      find.descendant(of: recentRunCards, matching: find.text('AVG PACE')),
      findsNWidgets(3),
    );
    expect(
      find.descendant(of: recentRunCards, matching: find.text('TIME')),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: recentRunCards,
        matching: find.byType(VerticalDivider),
      ),
      findsNWidgets(6),
    );
    expect(find.text('More Activities'), findsNothing);
    expect(find.byKey(const ValueKey('more_activities_button')), findsNothing);
    expect(find.byKey(const ValueKey('more_activities_chevron')), findsNothing);
    expect(find.text('Run Level'), findsNothing);
    expect(find.text('Level 12 Runner'), findsNothing);
    expect(find.text('Keep showing up at a comfortable pace.'), findsNothing);
  });

  testWidgets(
    'current-session history keeps fallback cap and dedupes by activity id',
    (WidgetTester tester) async {
      final historyStore = CurrentSessionActivityHistoryStore(
        now: () => DateTime(2026, 6, 18),
      );
      addTearDown(historyStore.dispose);

      await _openYouTab(tester, activityHistoryStore: historyStore);

      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();

      expect(find.byType(CompactRunActivityCard), findsNWidgets(3));
      expect(find.text('Saturday Night Run'), findsOneWidget);
      expect(find.text('Morning Easy Run'), findsOneWidget);
      expect(find.text('Recovery Jog'), findsOneWidget);

      historyStore.registerCompletedRun(
        _sessionCompletion(
          activityId: 'session-duplicate',
          title: 'Session First Run',
          distanceKm: '2.40',
        ),
      );
      historyStore.registerCompletedRun(
        _sessionCompletion(
          activityId: 'session-second',
          title: 'Session Second Run',
          distanceKm: '3.10',
          route: _sessionRouteFixture(),
        ),
      );
      historyStore.registerCompletedRun(
        _sessionCompletion(
          activityId: 'session-duplicate',
          title: 'Session Replacement Run',
          distanceKm: '4.20',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CompactRunActivityCard), findsNWidgets(3));
      expect(find.text('Session Replacement Run'), findsOneWidget);
      expect(find.text('Session Second Run'), findsOneWidget);
      expect(find.text('Saturday Night Run'), findsOneWidget);
      expect(find.text('Session First Run'), findsNothing);
      expect(find.text('Morning Easy Run'), findsNothing);
      expect(find.text('Recovery Jog'), findsNothing);

      final replacementCard = find.byKey(
        const ValueKey('recent_running_card_session-duplicate'),
      );
      final secondCard = find.byKey(
        const ValueKey('recent_running_card_session-second'),
      );
      final retainedStaticCard = find.byKey(
        const ValueKey('recent_running_card_Saturday Night Run'),
      );
      expect(replacementCard, findsOneWidget);
      expect(secondCard, findsOneWidget);
      expect(retainedStaticCard, findsOneWidget);
      expect(
        find.descendant(
          of: secondCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: retainedStaticCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(replacementCard).dy,
        lessThan(tester.getTopLeft(secondCard).dy),
      );
      expect(
        tester.getTopLeft(secondCard).dy,
        lessThan(tester.getTopLeft(retainedStaticCard).dy),
      );

      await _tapRecentRunningSeeAll(tester);

      expect(find.text('Current Session'), findsNothing);
      expect(find.text('June 2026'), findsOneWidget);
      final replacementHistoryCard = find.byKey(
        const ValueKey('activity_history_card_session-duplicate'),
      );
      final retainedHistoryCard = find.byKey(
        const ValueKey('activity_history_card_Pace Graph QA Run'),
      );
      expect(replacementHistoryCard, findsOneWidget);
      expect(retainedHistoryCard, findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(
            const ValueKey('activity_history_card_session-second'),
          ),
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: retainedHistoryCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(replacementHistoryCard).dy,
        lessThan(tester.getTopLeft(retainedHistoryCard).dy),
      );

      await tester.tap(replacementHistoryCard);
      await tester.pumpAndSettle();

      expect(find.text('Session Replacement Run'), findsOneWidget);
      expect(find.text('Today · 8:10 AM'), findsOneWidget);
      expect(find.text('4.20'), findsOneWidget);
    },
  );

  test('current-session recent fallback fills limit after dedupe', () {
    final historyStore = CurrentSessionActivityHistoryStore(
      now: () => DateTime(2026, 6, 18),
    );
    addTearDown(historyStore.dispose);
    historyStore.registerCompletedRun(
      _sessionCompletion(
        activityId: 'shared-activity',
        title: 'Session Replacement Run',
        distanceKm: '4.20',
      ),
    );

    final recentRuns = historyStore.recentRunsWithFallback(<
      RunActivityDisplayModel
    >[
      _displayRun(activityId: 'shared-activity', title: 'Repository Match'),
      _displayRun(activityId: 'repository-second', title: 'Repository Second'),
      _displayRun(activityId: 'repository-third', title: 'Repository Third'),
    ]);

    expect(recentRuns.map((run) => run.activityId), <String?>[
      'shared-activity',
      'repository-second',
      'repository-third',
    ]);
    expect(recentRuns.map((run) => run.title), <String>[
      'Session Replacement Run',
      'Repository Second',
      'Repository Third',
    ]);
  });

  testWidgets(
    'low-data current-session route previews distinguish route movement',
    (WidgetTester tester) async {
      final historyStore = CurrentSessionActivityHistoryStore(
        now: () => DateTime(2026, 6, 18),
      );
      addTearDown(historyStore.dispose);

      await _openYouTab(tester, activityHistoryStore: historyStore);

      historyStore.registerCompletedRun(
        _sessionCompletion(
          activityId: 'low-data-route',
          title: 'Low Data Route Run',
          distanceKm: '0.08',
          hasSufficientData: false,
          route: _sessionRouteFixture(),
        ),
      );
      historyStore.registerCompletedRun(
        _sessionCompletion(
          activityId: 'low-data-stationary',
          title: 'Low Data Stationary Run',
          distanceKm: '0.00',
          hasSufficientData: false,
          route: _stationaryRouteFixture(),
        ),
      );
      historyStore.registerCompletedRun(
        _sessionCompletion(
          activityId: 'low-data-no-location',
          title: 'Low Data No Location Run',
          distanceKm: '0.03',
          hasSufficientData: false,
          route: _noLocationRouteFixture(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();

      final routeBackedRecentCard = find.byKey(
        const ValueKey('recent_running_card_low-data-route'),
      );
      final stationaryRecentCard = find.byKey(
        const ValueKey('recent_running_card_low-data-stationary'),
      );
      final fallbackRecentCard = find.byKey(
        const ValueKey('recent_running_card_low-data-no-location'),
      );
      expect(routeBackedRecentCard, findsOneWidget);
      expect(stationaryRecentCard, findsOneWidget);
      expect(fallbackRecentCard, findsOneWidget);
      expect(
        find.descendant(
          of: routeBackedRecentCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: routeBackedRecentCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_fallback'),
          ),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: stationaryRecentCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_tiny_route'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: stationaryRecentCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: stationaryRecentCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_fallback'),
          ),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: fallbackRecentCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_fallback'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: fallbackRecentCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsNothing,
      );

      await _tapRecentRunningSeeAll(tester);

      final routeBackedHistoryCard = find.byKey(
        const ValueKey('activity_history_card_low-data-route'),
      );
      final stationaryHistoryCard = find.byKey(
        const ValueKey('activity_history_card_low-data-stationary'),
      );
      final fallbackHistoryCard = find.byKey(
        const ValueKey('activity_history_card_low-data-no-location'),
      );
      expect(routeBackedHistoryCard, findsOneWidget);
      expect(stationaryHistoryCard, findsOneWidget);
      expect(fallbackHistoryCard, findsOneWidget);
      expect(
        find.descendant(
          of: routeBackedHistoryCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: stationaryHistoryCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_tiny_route'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: stationaryHistoryCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: fallbackHistoryCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_fallback'),
          ),
        ),
        findsOneWidget,
      );

      await Scrollable.ensureVisible(
        tester.element(routeBackedHistoryCard),
        alignment: 0.3,
      );
      await tester.pumpAndSettle();
      await tester.tap(routeBackedHistoryCard);
      await tester.pumpAndSettle();

      expect(find.text('Low Data Route Run'), findsOneWidget);
      expect(find.text('More run data needed'), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'Go to Home'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);
    },
  );

  testWidgets(
    'You page shows Runiac-styled weekly distance graph in progress overview',
    (WidgetTester tester) async {
      await _openYouTab(tester);

      expect(find.text('Weekly Distance'), findsOneWidget);
      expect(find.text('Monthly Distance'), findsNothing);
      expect(find.text('Past 12 weeks'), findsOneWidget);
      expect(find.text('1.10'), findsOneWidget);
      expect(find.text('km'), findsWidgets);
      expectDistanceGraph(tester);
      expect(find.text('This Week'), findsNothing);
      expect(find.text('3 runs this week'), findsNothing);
      expect(find.text('82% of weekly goal'), findsNothing);
    },
  );

  testWidgets('weekly distance graph exposes floored half-max axis labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PastTwelveWeeksDistanceGraph(
            labels: ['APR', 'MAY', 'JUN'],
            values: [0, 8, 15, 25, 30, 45, 50, 62, 70, 81, 92, 100],
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        RegExp(
          r'Past 12 weeks distance graph.*APR.*MAY.*JUN.*0 km.*50 km.*100 km',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'\bmiddle\b|\bmax\b', caseSensitive: false),
      ),
      findsNothing,
    );
  });

  testWidgets('weekly distance graph floors odd half-max labels with km', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PastTwelveWeeksDistanceGraph(
            labels: ['APR', 'MAY', 'JUN'],
            values: [0, 3, 5, 6, 7, 9, 11, 12, 13, 14, 15, 0],
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        RegExp(
          r'Past 12 weeks distance graph.*APR.*MAY.*JUN.*0 km.*7 km.*15 km',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('weekly distance graph aligns y-axis labels by km right edge', (
    WidgetTester tester,
  ) async {
    const style = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
    const rightEdge = 50.0;
    const top = 0.0;
    const maxWidth = 56.0;

    double labelRightEdge(String value) {
      final offset = axisLabelOffsetFor(
        value: value,
        style: style,
        rightEdge: rightEdge,
        top: top,
        maxWidth: maxWidth,
      );
      final painter = TextPainter(
        text: const TextSpan(style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      painter.text = TextSpan(text: value, style: style);
      painter.layout(maxWidth: maxWidth);
      return offset.dx + painter.width;
    }

    expect(labelRightEdge('0 km'), closeTo(rightEdge, 0.001));
    expect(labelRightEdge('7 km'), closeTo(rightEdge, 0.001));
    expect(labelRightEdge('15 km'), closeTo(rightEdge, 0.001));
    expect(labelRightEdge('100 km'), closeTo(rightEdge, 0.001));
  });

  testWidgets(
    'weekly distance graph month labels sit between week boundaries',
    (WidgetTester tester) async {
      final fractions = monthLabelFractionsForGraph(
        labelCount: 3,
        pointCount: 12,
      );

      expect(fractions, hasLength(3));
      expect(fractions[0], closeTo(2.5 / 12, 0.0001));
      expect(fractions[1], closeTo(6.5 / 12, 0.0001));
      expect(fractions[2], closeTo(10.5 / 12, 0.0001));
      for (final fraction in fractions) {
        expect(fraction * 12, isNot(closeTo((fraction * 12).round(), 0.0001)));
      }
    },
  );

  testWidgets('You progress period buttons update only distance summary', (
    WidgetTester tester,
  ) async {
    await _openYouTab(
      tester,
      activityHistoryRepository: const _AggregateProgressRepository(),
    );

    void expectFixedGraphContext() {
      expect(find.text('Past 12 weeks'), findsOneWidget);
      expectDistanceGraph(
        tester,
        expectedValues: const [0, 0, 0, 8.1, 0, 0, 0, 3.5, 0, 0, 0, 4.25],
        axisLabelPattern: r'0 km.*4 km.*8.1 km',
      );
      expect(find.text('This Week'), findsNothing);
      expect(find.text('3 runs this week'), findsNothing);
      expect(find.text('82% of weekly goal'), findsNothing);
    }

    expect(find.text('Weekly Distance'), findsOneWidget);
    expect(find.text('4.25'), findsOneWidget);
    expectFixedGraphContext();

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly Distance'), findsOneWidget);
    expect(find.text('7.75'), findsOneWidget);
    expect(find.text('Weekly Distance'), findsNothing);
    expectFixedGraphContext();

    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();

    expect(find.text('Yearly Distance'), findsOneWidget);
    expect(find.text('15.85'), findsOneWidget);
    expect(find.text('Monthly Distance'), findsNothing);
    expectFixedGraphContext();

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('Total Distance'), findsOneWidget);
    expect(find.text('16.90'), findsOneWidget);
    expect(find.text('Yearly Distance'), findsNothing);
    expectFixedGraphContext();
  });

  testWidgets('Recent Running card opens selected summary with matching data', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    const runs = [
      (
        title: 'Saturday Night Run',
        dateTime: '4/11/26 · 9:18 PM',
        distance: '4.03',
        pace: '6’30”',
        duration: '30:15',
        route: 'East Coast Park Night Loop',
        hasSpikeFilteredGraph: false,
        expectedAxisLabels: ['0:00', '10:00', '20:00', '30:15'],
        forbiddenAxisLabels: ['13:00'],
      ),
      (
        title: 'Morning Easy Run',
        dateTime: '4/11/26 · 6:45 AM',
        distance: '3.20',
        pace: '7’05”',
        duration: '24:10',
        route: 'Neighbourhood Easy Loop',
        hasSpikeFilteredGraph: true,
        expectedAxisLabels: ['0:00', '8:00', '16:00', '24:10'],
        forbiddenAxisLabels: <String>[],
      ),
      (
        title: 'Recovery Jog',
        dateTime: '4/11/26 · 8:10 PM',
        distance: '5.17',
        pace: '7’40”',
        duration: '39:38',
        route: 'Park Connector Recovery Loop',
        hasSpikeFilteredGraph: false,
        expectedAxisLabels: ['0:00', '13:00', '26:00', '39:38'],
        forbiddenAxisLabels: <String>[],
      ),
    ];

    for (final run in runs) {
      final cardButton = find.byKey(
        ValueKey('recent_running_card_${run.title}'),
      );
      expect(cardButton, findsOneWidget);

      await Scrollable.ensureVisible(
        tester.element(cardButton),
        alignment: 0.55,
      );
      await tester.pumpAndSettle();

      await tester.tap(cardButton);
      await tester.pumpAndSettle();

      expect(find.text(run.title), findsOneWidget);
      expect(find.text(run.dateTime), findsOneWidget);
      expect(find.text(run.route), findsNothing);
      expect(find.text(run.distance), findsOneWidget);
      expect(find.text(run.pace), findsOneWidget);
      expect(find.text(run.duration), findsWidgets);
      expect(find.text('Pace Over Time'), findsOneWidget);
      for (final label in run.expectedAxisLabels) {
        expect(find.text(label), findsWidgets);
      }
      final axisLabelCenters = [
        for (var index = 0; index < run.expectedAxisLabels.length; index += 1)
          tester.getCenter(find.byKey(ValueKey('pace_x_axis_label_$index'))).dx,
      ];
      final axisGaps = [
        for (var index = 1; index < axisLabelCenters.length; index += 1)
          axisLabelCenters[index] - axisLabelCenters[index - 1],
      ];
      for (final gap in axisGaps.skip(1)) {
        expect((gap - axisGaps.first).abs(), lessThanOrEqualTo(1));
      }
      for (final label in run.forbiddenAxisLabels) {
        expect(find.text(label), findsNothing);
      }
      expect(find.text('More run data needed'), findsNothing);
      expect(
        find.text('Pace insights will appear after a longer run.'),
        findsNothing,
      );
      if (run.hasSpikeFilteredGraph) {
        expect(find.text('1:20'), findsNothing);
        expect(find.text('45:00'), findsNothing);
      }
      expect(
        find.widgetWithText(OutlinedButton, 'Share Route'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);

      await tester.tap(find.byTooltip('Back to cool down'));
      await tester.pumpAndSettle();
      expect(find.text('Recent Running'), findsOneWidget);
    }
  });

  testWidgets('Recent Running See all opens Activity History', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    final seeAll = find.byKey(const ValueKey('recent_running_see_all'));
    await Scrollable.ensureVisible(tester.element(seeAll), alignment: 0.55);
    await tester.pumpAndSettle();
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    expect(find.text('Activity History'), findsOneWidget);
    expect(find.text('All years'), findsOneWidget);
    expect(find.text('All months'), findsOneWidget);
  });

  testWidgets(
    'Recent Running See all opens Activity History with shell navigation preserved',
    (WidgetTester tester) async {
      await _openYouTab(tester);

      await _tapRecentRunningSeeAll(tester);

      expect(find.text('Activity History'), findsOneWidget);
      expect(find.text('Review your runs at your own pace.'), findsNothing);
      expect(find.text('All years'), findsOneWidget);
      expect(find.text('All months'), findsOneWidget);
      expect(find.text('Showing your recent activities'), findsOneWidget);

      for (final label in const ['Home', 'Maps', 'Run', 'Leaderboard', 'You']) {
        expect(find.byTooltip(label), findsOneWidget);
      }
    },
  );

  testWidgets('Activity History groups mock activities by month', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await _tapRecentRunningSeeAll(tester);

    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('April 2026'), findsOneWidget);

    for (final title in const [
      'Pace Graph QA Run',
      'Easy Morning Jog',
      'Riverside Recovery',
      'Sunset Loop',
      'Tuesday Tempo',
      'Park Walk + Run',
      'First 5K Attempt',
      'Gentle Start',
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    expect(find.byType(CompactRunActivityCard), findsNWidgets(8));
    expect(find.byType(VerticalDivider), findsNWidgets(16));
    expect(
      find.descendant(
        of: find.byType(CompactRunActivityCard),
        matching: find.byIcon(Icons.chevron_right_rounded),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(CompactRunActivityCard),
        matching: find.byKey(const ValueKey('activity_route_preview_slot')),
      ),
      findsNWidgets(8),
    );
  });

  testWidgets(
    'Activity History route previews render polylines for route-backed demos and fallback for low-data demos',
    (WidgetTester tester) async {
      await _openActivityHistoryFromYou(tester);

      for (final title in const [
        'Pace Graph QA Run',
        'Easy Morning Jog',
        'Sunset Loop',
        'Tuesday Tempo',
        'Park Walk + Run',
        'First 5K Attempt',
        'Gentle Start',
      ]) {
        final card = find.byKey(ValueKey('activity_history_card_$title'));
        await Scrollable.ensureVisible(tester.element(card), alignment: 0.55);
        await tester.pumpAndSettle();

        expect(card, findsOneWidget);
        expect(
          find.descendant(
            of: card,
            matching: find.byKey(
              const ValueKey('activity_route_preview_polyline'),
            ),
          ),
          findsOneWidget,
          reason: '$title should render the route polyline preview',
        );
        expect(
          find.descendant(
            of: card,
            matching: find.byKey(
              const ValueKey('activity_route_preview_fallback'),
            ),
          ),
          findsNothing,
          reason: '$title should not use the fallback preview',
        );
      }

      final fallbackCard = find.byKey(
        const ValueKey('activity_history_card_Riverside Recovery'),
      );
      await Scrollable.ensureVisible(
        tester.element(fallbackCard),
        alignment: 0.55,
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: fallbackCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_fallback'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: fallbackCard,
          matching: find.byKey(
            const ValueKey('activity_route_preview_polyline'),
          ),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('Activity route preview renders injected ready image thumbnail', (
    WidgetTester tester,
  ) async {
    // Given: a provider that has already resolved a static route thumbnail.
    final provider = _FakeActivityRouteThumbnailProvider(
      ActivityRouteThumbnailResult.readyImage(
        MemoryImage(Uint8List.fromList(_transparentPixelPng)),
      ),
    );

    // When: a meaningful route preview is rendered with explicit demo/static
    // thumbnail permission.
    await tester.pumpWidget(
      MaterialApp(
        home: ActivityRoutePreview(
          route: _sessionRouteFixture(),
          thumbnailProvider: provider,
          allowExternalStaticMap: true,
          isDemoRoute: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Then: the non-interactive image thumbnail is used as a background while
    // the exact route remains a local overlay.
    expect(
      find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('activity_route_preview_static_thumbnail_route_overlay'),
      ),
      findsOneWidget,
    );
    expect(
      tester.getRect(
        find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
      ),
      tester.getRect(find.byKey(const ValueKey('activity_route_preview_slot'))),
    );
    expect(provider.requestCount, 1);
    expect(provider.lastRequest!.allowExternalStaticMap, isTrue);
    expect(provider.lastRequest!.isDemoRoute, isTrue);
  });

  testWidgets('Activity route preview area uses the card tap target', (
    WidgetTester tester,
  ) async {
    // Given: an activity card with a route-backed preview.
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompactRunActivityCard(
            activity: activityHistoryDisplayData.first.activities.first,
            onTap: () {
              tapCount += 1;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // When: the user taps inside the route preview slot.
    await tester.tap(find.byKey(const ValueKey('activity_route_preview_slot')));
    await tester.pumpAndSettle();

    // Then: the card onTap fires; the preview has no independent tap action.
    expect(tapCount, 1);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('activity_route_preview_slot')),
        matching: find.byType(GestureDetector),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'Current-session activity card requests a guarded Mapbox thumbnail',
    (WidgetTester tester) async {
      // Given: a current-session completion card with a meaningful route.
      final provider = _FakeActivityRouteThumbnailProvider(
        const ActivityRouteThumbnailResult.unavailable(),
      );
      final completion = _sessionCompletion(
        activityId: 'current-session-mapbox-card',
        title: 'Current Session Mapbox Card',
        distanceKm: '1.20',
        route: _sessionRouteFixture(),
      );
      final activity = RunActivityDisplayModel(
        activityId: completion.activityId,
        title: completion.summary.title,
        timeAgoLabel: 'Just now',
        distanceLabel: '${completion.summary.distanceKm} km',
        distanceMeters: 1200,
        paceLabel: completion.summary.avgPace,
        durationLabel: completion.summary.duration,
        summary: completion.summary,
        completionResult: completion,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactRunActivityCard(
              activity: activity,
              routeThumbnailProvider: provider,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then: the card keeps the preview non-interactive while only the
      // current-session route is allowed through the provider boundary.
      expect(provider.requestCount, 1);
      expect(provider.lastRequest!.activityId, 'current-session-mapbox-card');
      expect(provider.lastRequest!.allowExternalStaticMap, isTrue);
      expect(provider.lastRequest!.isCurrentSessionRoute, isTrue);
      expect(provider.lastRequest!.isDemoRoute, isFalse);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('activity_route_preview_slot')),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Activity route preview falls back when provider has no ready image',
    (WidgetTester tester) async {
      for (final result in const [
        ActivityRouteThumbnailResult.privacyDisabled(),
        ActivityRouteThumbnailResult.tokenMissing(),
        ActivityRouteThumbnailResult.requestFailed(),
        ActivityRouteThumbnailResult.timedOut(),
        ActivityRouteThumbnailResult.unavailable(),
      ]) {
        // Given: a provider state that cannot supply a safe ready image.
        final provider = _FakeActivityRouteThumbnailProvider(result);

        // When: a meaningful route preview is rendered.
        await tester.pumpWidget(
          MaterialApp(
            home: ActivityRoutePreview(
              route: _sessionRouteFixture(),
              thumbnailProvider: provider,
              allowExternalStaticMap: true,
              isDemoRoute: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Then: the existing CustomPaint route preview remains the fallback.
        expect(
          find.byKey(const ValueKey('activity_route_preview_polyline')),
          findsOneWidget,
          reason: '${result.state} should preserve the polyline fallback',
        );
        expect(
          find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
          findsNothing,
        );
      }
    },
  );

  testWidgets('Activity route preview handles stationary and missing routes', (
    WidgetTester tester,
  ) async {
    // Given: a provider that could render an image for meaningful routes.
    final provider = _FakeActivityRouteThumbnailProvider(
      ActivityRouteThumbnailResult.readyImage(
        MemoryImage(Uint8List.fromList(_transparentPixelPng)),
      ),
    );

    // When: a stationary route is rendered.
    await tester.pumpWidget(
      MaterialApp(
        home: ActivityRoutePreview(
          route: _stationaryRouteFixture(),
          thumbnailProvider: provider,
          allowExternalStaticMap: true,
          isDemoRoute: false,
          isCurrentSessionRoute: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Then: stationary current-session routes can use a map background with a
    // single local marker, not a fake route line.
    expect(
      find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('activity_route_preview_static_thumbnail_location_dot'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('activity_route_preview_static_thumbnail_route_overlay'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('activity_route_preview_polyline')),
      findsNothing,
    );
    expect(provider.requestCount, 1);

    // When: a missing route is rendered.
    await tester.pumpWidget(
      MaterialApp(
        home: ActivityRoutePreview(
          route: RunRouteSnapshot.empty,
          thumbnailProvider: provider,
          allowExternalStaticMap: true,
          isDemoRoute: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Then: the no-route fallback remains available.
    expect(
      find.byKey(const ValueKey('activity_route_preview_fallback')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('activity_route_preview_static_thumbnail')),
      findsNothing,
    );
    expect(provider.requestCount, 1);
  });

  testWidgets('Activity History shows source labels', (
    WidgetTester tester,
  ) async {
    await _openActivityHistoryFromYou(tester);

    expect(find.text('Pace Graph QA Run'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('activity_history_card_Pace Graph QA Run'),
        ),
        matching: find.text('Runiac GPS'),
      ),
      findsOneWidget,
    );
    expect(find.text('Easy Morning Jog'), findsOneWidget);
    expect(find.text('Garmin via Health'), findsOneWidget);

    await tester.ensureVisible(find.text('Riverside Recovery'));
    await tester.pumpAndSettle();

    expect(find.text('Riverside Recovery'), findsOneWidget);
    expect(find.text('Health Connect'), findsOneWidget);
  });

  testWidgets(
    'Activity History summaries cover normal, spike-filtered, and low-data pace graph states',
    (WidgetTester tester) async {
      await _openActivityHistoryFromYou(tester);

      expect(find.byType(CompactRunActivityCard), findsNWidgets(8));

      Future<void> openHistorySummary(String title) async {
        final card = find.byKey(ValueKey('activity_history_card_$title'));
        expect(card, findsOneWidget);

        await Scrollable.ensureVisible(tester.element(card), alignment: 0.55);
        await tester.pumpAndSettle();
        await tester.tap(card);
        await tester.pumpAndSettle();
      }

      await openHistorySummary('Pace Graph QA Run');

      expect(find.text('Pace Graph QA Run'), findsOneWidget);
      expect(find.text('Today · Manual QA'), findsOneWidget);
      expect(find.text('1.10'), findsOneWidget);
      expect(find.text('7\'16"'), findsOneWidget);
      expect(find.text('8:00'), findsWidgets);
      expect(find.text('Pace Over Time'), findsOneWidget);
      expect(find.text('7:00'), findsOneWidget);
      expect(find.text('7:30'), findsOneWidget);
      expect(find.text('8:00'), findsWidgets);
      expect(find.text('More run data needed'), findsNothing);
      expect(
        find.text('Pace insights will appear after a longer run.'),
        findsNothing,
      );
      expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);

      await tester.tap(find.byTooltip('Back to cool down'));
      await tester.pumpAndSettle();

      await openHistorySummary('Easy Morning Jog');

      expect(find.text('Easy Morning Jog'), findsOneWidget);
      expect(find.text('4 Jun 2026 · 6:45 AM'), findsOneWidget);
      expect(find.text('Pace Over Time'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('30:15'), findsWidgets);
      expect(find.text('More run data needed'), findsNothing);
      expect(find.text('1:20'), findsNothing);
      expect(find.text('45:00'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);

      await tester.tap(find.byTooltip('Back to cool down'));
      await tester.pumpAndSettle();

      await openHistorySummary('Riverside Recovery');

      expect(find.text('Riverside Recovery'), findsOneWidget);
      expect(find.text('1 Jun 2026 · 7:05 PM'), findsOneWidget);
      expect(find.text('0.06'), findsOneWidget);
      expect(find.text('--'), findsWidgets);
      expect(find.text('00:38'), findsOneWidget);
      expect(find.text('Pace Over Time'), findsOneWidget);
      expect(find.text('More run data needed'), findsWidgets);
      expect(
        find.text('Pace insights will appear after a longer run.'),
        findsWidgets,
      );
      expect(find.widgetWithText(FilledButton, 'Go to Home'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);
    },
  );

  testWidgets(
    'Pace Graph QA run opens Advanced Analysis with local GPS pace graph',
    (WidgetTester tester) async {
      await _openActivityHistoryFromYou(tester);

      final card = find.byKey(
        const ValueKey('activity_history_card_Pace Graph QA Run'),
      );
      expect(card, findsOneWidget);

      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.text('Pace Graph QA Run'), findsOneWidget);
      expect(find.text('Runiac GPS'), findsOneWidget);

      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'More Details'),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'More Details'));
      await tester.pumpAndSettle();

      final advancedAnalysis = tester.widget<AdvancedAnalysisScreen>(
        find.byType(AdvancedAnalysisScreen),
      );
      final snapshot = advancedAnalysis.analysisSnapshot;
      final paceGraph = snapshot!.pace.paceGraph;
      final cadence = snapshot.formCadence;
      final elevation = snapshot.elevation;
      final heartRate = snapshot.heartRate;

      expect(snapshot, isNotNull);
      expect(
        paceGraph.availability,
        AdvancedAnalysisMetricAvailability.available,
      );
      expect(paceGraph.source, AdvancedAnalysisMetricSource.localGpsDerived);
      expect(paceGraph.value, isNotNull);
      expect(paceGraph.value!.isAvailable, isTrue);
      expect(paceGraph.value!.points.length, greaterThanOrEqualTo(8));
      expect(paceGraph.value!.distanceAxisLabels, ['0 km', '0.5 km', '1.1 km']);
      expect(paceGraph.value!.xAxisLabels, contains('0:00'));
      expect(
        find.byKey(const ValueKey('advanced_analysis_pace_graph_unavailable')),
        findsNothing,
      );
      expect(find.text('Pace Over Distance'), findsOneWidget);
      expect(
        snapshot.performance.scoreMode,
        AdvancedAnalysisScoreSourceMode.mobileOnly,
      );
      expect(snapshot.performance.scoreConfidenceLabel, 'Phone data');
      final hiddenBadgeCount = snapshot.performance.badges.length - 4;
      expect(hiddenBadgeCount, greaterThan(0));
      expect(find.text('Controlled HR'), findsNothing);
      expect(find.text('Easy Effort'), findsNothing);
      expect(find.text('More +$hiddenBadgeCount'), findsOneWidget);

      final moreBadges = find.text('More +$hiddenBadgeCount');
      await Scrollable.ensureVisible(
        tester.element(moreBadges),
        alignment: 0.5,
      );
      await tester.pump();
      await tester.tap(moreBadges);
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.text('Show less'), findsOneWidget);
      expect(find.text('Controlled HR'), findsNothing);
      expect(find.text('Easy Effort'), findsNothing);
      expect(heartRate.averageHeartRate.valueLabel, '135');
      expect(heartRate.maxHeartRate.valueLabel, '152');
      expect(heartRate.targetZone.valueLabel, isNull);
      expect(heartRate.timeInZone.valueLabel, isNull);
      expect(
        heartRate.averageHeartRate.source,
        AdvancedAnalysisMetricSource.healthConnect,
      );
      expect(heartRate.zones.isAvailable, isFalse);
      await tester.ensureVisible(find.text('Heart Rate Analysis'));
      expect(find.text('135'), findsOneWidget);
      expect(find.text('152'), findsOneWidget);
      expect(find.text('Target Zone'), findsNothing);
      expect(find.text('Time in Zone'), findsNothing);
      expect(find.text('120-169'), findsNothing);
      expect(find.text('75'), findsNothing);
      expect(find.text('Zone 2'), findsNothing);
      expect(find.text('50%'), findsNothing);
      expect(
        find.text(
          'Heart rate was recorded, but zone analysis is not enabled for this run.',
        ),
        findsOneWidget,
      );
      expect(elevation.elevationGraph.isAvailable, isTrue);
      expect(
        elevation.elevationGraph.source,
        AdvancedAnalysisMetricSource.localGpsDerived,
      );
      expect(elevation.elevationGraph.value!.points.length, 5);
      expect(elevation.totalGain.valueLabel, '+2 m');
      expect(elevation.highestPoint.valueLabel, '8 m');
      expect(elevation.lowestPoint.valueLabel, '4 m');
      expect(elevation.routeDifficulty.valueLabel, 'Mostly Flat');
      expect(find.text('+2'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('+12'), findsNothing);
      expect(find.text('11'), findsNothing);
      expect(
        find.byKey(
          const ValueKey('advanced_analysis_elevation_graph_unavailable'),
        ),
        findsNothing,
      );

      final pacePainters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<AdvancedAnalysisPaceChartPainter>();
      final elevationPainters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<AdvancedAnalysisElevationChartPainter>();

      expect(
        pacePainters.any(
          (painter) => identical(painter.graph, paceGraph.value),
        ),
        isTrue,
      );
      final pacePainter = pacePainters.singleWhere(
        (painter) => identical(painter.graph, paceGraph.value),
      );
      expect(pacePainters.any((painter) => painter.graph == null), isFalse);
      expect(pacePainter.snapshotXAxisLabels, ['0 km', '0.5 km', '1.1 km']);
      expect(
        elevationPainters.single.graph,
        same(elevation.elevationGraph.value),
      );
      for (final elapsedLabel in const [
        '0:00',
        '2:00',
        '4:00',
        '6:00',
        '8:00',
      ]) {
        expect(pacePainter.snapshotXAxisLabels, isNot(contains(elapsedLabel)));
      }
      expect(pacePainter.snapshotXProgressFractions.first, 0);
      expect(pacePainter.snapshotXProgressFractions.last, 1);
      expect(
        pacePainter.snapshotXProgressFractions,
        isNot(
          equals(
            paceGraph.value!.points
                .map((point) => point.progressFraction)
                .toList(),
          ),
        ),
      );

      expect(cadence.averageCadence.valueLabel, '173 spm');
      expect(
        cadence.cadenceGraph.value!.points.map((point) => point.cadenceSpm),
        [173, 170, 172, 174, 176],
      );
      expect(cadence.cadenceGraph.value!.points.first.elapsedSeconds, 0);
      expect(cadence.cadenceGraph.value!.points.first.progressFraction, 0);
      expect(cadence.cadenceGraph.value!.lowestCadencePoint?.cadenceSpm, 170);
      expect(cadence.cadenceGraph.value!.highestCadencePoint?.cadenceSpm, 176);
      expect(
        cadence.cadenceGraph.value!.targetLabel,
        demoCadenceGraphTargetLabel,
      );
      expect(
        cadence.cadenceGraph.value!.targetMinCadenceSpm,
        demoCadenceGraphTargetMinSpm,
      );
      expect(
        cadence.cadenceGraph.value!.targetMaxCadenceSpm,
        demoCadenceGraphTargetMaxSpm,
      );
      expect(
        cadence.cadenceGraph.value!.targetKind,
        CadenceGraphTargetKind.demo,
      );
      expect(cadence.strideConsistency.valueLabel, 'stable');
      expect(cadence.cadenceStatus.valueLabel, 'stable');
      await tester.ensureVisible(find.text('Running Form / Cadence'));
      expect(find.text('AVERAGE CADENCE'), findsOneWidget);
      expect(find.text('LOWEST'), findsOneWidget);
      expect(find.text('HIGHEST'), findsOneWidget);
      expect(find.text('TREND'), findsOneWidget);
      expect(find.text('173'), findsOneWidget);
      expect(find.text('170'), findsOneWidget);
      expect(find.text('176'), findsOneWidget);
      expect(find.text('Stable'), findsWidgets);

      final cadencePainters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<AdvancedAnalysisCadenceChartPainter>();
      expect(
        cadencePainters.any(
          (painter) => identical(painter.graph, cadence.cadenceGraph.value),
        ),
        isTrue,
      );
      expect(cadencePainters.any((painter) => painter.graph == null), isFalse);
    },
  );

  testWidgets('You page shows static plans overview when Plans is selected', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Current Goal'), findsOneWidget);
    expect(find.text('10K Preparation'), findsOneWidget);
    expect(find.text('Week 3 of 8'), findsOneWidget);
    expect(find.text('43% completed'), findsOneWidget);
    expect(find.text('43%'), findsOneWidget);
    expect(find.text('Next Milestone'), findsOneWidget);
    expect(find.text('Complete 6 km comfortably'), findsOneWidget);
    expect(find.text('View Goal Plan'), findsOneWidget);
    expect(find.text("This Week's Plan"), findsOneWidget);
    expect(find.text("This Week's 10K Preparation Plan"), findsNothing);
    expect(find.text('Week 3 of 8 · 10K Plan'), findsNothing);
    expect(find.text('2 of 3 done'), findsOneWidget);
    expect(find.text('Planned Runs'), findsNothing);
    expect(find.text('Remaining'), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'3\s+Planned Runs')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'2\s+Completed')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'1\s+Remaining')), findsNothing);
    expect(
      find.text('Take each easy run as a steady step forward.'),
      findsNothing,
    );
    expect(find.text('Running Calendar'), findsNothing);
    expect(find.text('Recent Running'), findsNothing);

    for (final text in [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
      'Rest Day',
      '15 min walk-run',
      '20 min easy run',
      'Upcoming · 7:30 AM',
    ]) {
      expect(find.text(text), findsWidgets);
    }
    expect(find.text('Rest Day'), findsNWidgets(4));
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Upcoming · 7:30 AM'), findsOneWidget);
    expect(find.text('Scheduled · 8:00 AM'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Explore expert plans'), findsOneWidget);
    expect(
      find.text('Browse coach-reviewed plans at your own pace.'),
      findsOneWidget,
    );
    expect(find.text('Coach-created'), findsOneWidget);
    expect(find.text('First 5K'), findsOneWidget);
    expect(find.text('10K'), findsOneWidget);
    expect(find.text('Half Marathon'), findsOneWidget);
    expect(find.text('Full Marathon'), findsOneWidget);
    expect(find.text('Explore Expert Plans'), findsOneWidget);
  });

  testWidgets(
    'expert plan list opens from You Plans and renders approved static content',
    (WidgetTester tester) async {
      await _openYouTab(tester);

      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Explore Expert Plans'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Explore Expert Plans'));
      await tester.pumpAndSettle();

      expect(find.text('Expert Plans'), findsOneWidget);
      expect(
        find.text('Browse coach-reviewed plans at your own pace.'),
        findsNothing,
      );
      expect(find.text('Search plans'), findsOneWidget);

      for (final filter in const [
        'Recommended',
        '5K',
        '10K',
        'Consistency',
        'Healthy Running',
        'Half',
        'Full',
      ]) {
        expect(find.text(filter), findsOneWidget);
      }

      for (final title in const [
        'First 5K Preparation',
        'Build Running Consistency',
        '10K Preparation',
        'Healthy Running Starter Plan',
        'Half Marathon Preparation',
        'Full Marathon Preparation',
      ]) {
        expect(find.text(title), findsOneWidget);
      }

      expect(find.text('Coach-created'), findsNothing);
      expect(find.text('Coach Verified'), findsNothing);
      expect(find.text('Weight Loss Starter Plan'), findsNothing);
      expect(
        find.text(
          'Plans are reviewed for beginner suitability. This is general fitness guidance, not medical advice.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('You page keeps plans controls visual only and backend safe', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    for (final forbidden in <Pattern>[
      RegExp('premium', caseSensitive: false),
      RegExp('locked', caseSensitive: false),
      RegExp(r'\bXP\b', caseSensitive: false),
      RegExp('rank', caseSensitive: false),
      RegExp('leaderboard', caseSensitive: false),
      RegExp('published', caseSensitive: false),
      RegExp('approved', caseSensitive: false),
      RegExp('missed', caseSensitive: false),
      RegExp('subscription', caseSensitive: false),
      RegExp('entitlement', caseSensitive: false),
      RegExp('eligible', caseSensitive: false),
      RegExp('publication', caseSensitive: false),
      RegExp('approval', caseSensitive: false),
      RegExp('admin review', caseSensitive: false),
    ]) {
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.textContaining(forbidden),
        ),
        findsNothing,
      );
    }

    await tester.tap(find.text('View Goal Plan'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('10K Goal Plan'), findsOneWidget);
    expect(find.text('10K Preparation'), findsWidgets);

    await tester.tap(find.byTooltip('Back to Plans'));
    await tester.pumpAndSettle();
    expect(find.text("This Week's Plan"), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('15 min walk-run')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 min walk-run'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('15 min walk-run'), findsOneWidget);

    await tester.ensureVisible(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Activity History'), findsNothing);
    expect(find.text('Expert Plans'), findsOneWidget);
    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(find.text('Explore Expert Plans'), findsNothing);

    await tester.tap(find.byTooltip('Back to Plans'));
    await tester.pumpAndSettle();
    expect(find.text("This Week's Plan"), findsOneWidget);
  });

  testWidgets(
    'goal plan detail matches Plan Preview header and timeline alignment',
    (WidgetTester tester) async {
      // Given: the static Goal Plan Detail screen is open from You > Plans.
      await _openYouTab(tester);
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Goal Plan'));
      await tester.pumpAndSettle();

      // Then: the header follows the Plan Preview fixed-header pattern.
      final backButton = find.byTooltip('Back to Plans');
      expect(backButton, findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('10K Goal Plan'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('10K Goal Plan')).dx,
        greaterThan(
          tester.getTopLeft(find.byIcon(Icons.chevron_left_rounded)).dx,
        ),
      );

      // Then: a long blue/orange content accent strip starts the scroll body.
      final accentStrip = find.byKey(
        const ValueKey('goal_plan_detail_header_accent_strip'),
      );
      expect(accentStrip, findsOneWidget);
      expect(tester.getSize(accentStrip).width, greaterThan(650));
      expect(
        tester.getTopLeft(accentStrip).dy,
        greaterThan(tester.getBottomLeft(backButton).dy),
      );
      expect(
        tester.getTopLeft(accentStrip).dy,
        lessThan(tester.getTopLeft(find.text('10K Preparation').first).dy),
      );

      // Then: timeline markers align with each Week label row.
      for (final week in const ['Week 1', 'Week 3', 'Week 8']) {
        final marker = find.byKey(ValueKey('goal_plan_detail_marker_$week'));
        expect(marker, findsOneWidget);

        final markerCenter = tester.getCenter(marker).dy;
        final weekCenter = tester.getCenter(find.text(week)).dy;
        expect((markerCenter - weekCenter).abs(), lessThanOrEqualTo(1.0));
      }

      // Then: progress state is visual-only on week rows.
      expect(find.text('Completed'), findsNothing);
      expect(find.text('Current'), findsNothing);
      expect(find.text('Upcoming'), findsNothing);
      expect(find.byIcon(Icons.check), findsWidgets);
      for (final summary in const [
        '4 days · 8 km',
        '4 days · 10 km',
        '4 days · 12 km',
        '4 days · 14 km',
        '4 days · 16 km',
        '4 days · 18 km',
        '4 days · 20 km',
        '4 days · 10K',
      ]) {
        expect(find.text(summary), findsNothing);
      }
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('goal_plan_detail_marker_Week 3')),
          matching: find.byIcon(Icons.directions_run),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('goal_plan_detail_marker_Week 4')),
        findsOneWidget,
      );
      expect(
        tester
            .getTopRight(
              find.byKey(
                const ValueKey('goal_plan_detail_chevron_Week 3_collapsed'),
              ),
            )
            .dx,
        greaterThan(tester.getTopRight(find.text('Base Endurance').first).dx),
      );

      // Then: the current week highlight spans the whole row surface.
      final currentHighlight = find.byKey(
        const ValueKey('goal_plan_detail_current_week_highlight'),
      );
      expect(currentHighlight, findsOneWidget);
      expect(tester.getSize(currentHighlight).width, greaterThan(650));

      // Then: all weekly dropdown plans are initially collapsed.
      expect(
        find.byKey(const ValueKey('goal_plan_detail_daily_plan_Week 3')),
        findsNothing,
      );
      for (final day in const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ]) {
        expect(find.text(day), findsNothing);
      }

      // When: the current week is expanded.
      await tester.tap(
        find.byKey(const ValueKey('goal_plan_detail_week_toggle_Week 3')),
      );
      await tester.pumpAndSettle();

      // Then: the sample onboarding run/rest mapping is visible in order.
      final weekThreePlan = find.byKey(
        const ValueKey('goal_plan_detail_daily_plan_Week 3'),
      );
      expect(weekThreePlan, findsOneWidget);
      for (final day in const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ]) {
        expect(
          find.byKey(ValueKey('goal_plan_detail_day_Week 3_$day')),
          findsOneWidget,
        );
      }
      expect(find.text('Easy Run'), findsNWidgets(2));
      expect(find.text('Tempo Run'), findsOneWidget);
      expect(find.text('Long Run'), findsOneWidget);
      expect(find.text('Rest'), findsNWidgets(3));
      expect(find.text('3 km'), findsOneWidget);
      expect(find.text('25 min'), findsOneWidget);
      expect(find.text('4 km'), findsOneWidget);
      expect(find.text('5 km'), findsOneWidget);
      expect(find.text('0 min'), findsNWidgets(3));
      expect(find.text('4 days · 12 km'), findsNothing);
      expect(
        find.byKey(const ValueKey('goal_plan_detail_chevron_Week 3_expanded')),
        findsOneWidget,
      );

      // When: the same week is tapped again.
      await tester.tap(
        find.byKey(const ValueKey('goal_plan_detail_week_toggle_Week 3')),
      );
      await tester.pumpAndSettle();

      // Then: it collapses back to the static week-list state.
      expect(weekThreePlan, findsNothing);
      expect(find.text('Monday'), findsNothing);
      expect(
        find.byKey(const ValueKey('goal_plan_detail_chevron_Week 3_collapsed')),
        findsOneWidget,
      );

      // When: the detail content scrolls.
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -700));
      await tester.pumpAndSettle();

      // Then: the header remains available, while the accent strip is not sticky.
      expect(find.text('10K Goal Plan'), findsOneWidget);
      expect(backButton, findsOneWidget);
      expect(
        tester.getTopLeft(accentStrip).dy,
        lessThan(tester.getTopLeft(backButton).dy),
      );
    },
  );

  testWidgets('first expert plan opens static preview detail only', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore Expert Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Search plans'), findsOneWidget);
    expect(find.text('View Plan'), findsNWidgets(6));

    await Scrollable.ensureVisible(
      tester.element(find.text('Build Running Consistency')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Plan').at(1));
    await tester.pumpAndSettle();

    expect(find.text('Plan preview is coming soon.'), findsOneWidget);
    expect(find.text('Expert Plans'), findsOneWidget);
    expect(find.text('Plan Preview'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);

    await Scrollable.ensureVisible(
      tester.element(find.text('Search plans')),
      alignment: 0.1,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search plans'));
    await tester.pumpAndSettle();

    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(find.text('Full Marathon Preparation'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('5K'));
    await tester.pumpAndSettle();

    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(find.text('Full Marathon Preparation'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);

    await tester.tap(find.text('View Plan').first);
    await tester.pumpAndSettle();

    expect(find.text('Plan Preview'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(
      find.byKey(const ValueKey('expert_plan_detail_header_accent_strip')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('expert_plan_detail_header_accent_strip'),
            ),
          )
          .width,
      greaterThan(650),
    );
    expect(
      tester.getTopLeft(find.text('Plan Preview')).dx,
      greaterThan(
        tester.getTopLeft(find.byIcon(Icons.chevron_left_rounded)).dx,
      ),
    );
    expect(find.text('First 5K Preparation'), findsOneWidget);
    expect(
      find.text('A gentle plan for building confidence toward your first 5K.'),
      findsOneWidget,
    );
    expect(find.text('Coach Insight'), findsOneWidget);
    expect(find.text('Coach Verified'), findsOneWidget);
    expect(find.text('6 weeks'), findsOneWidget);
    expect(find.text('3 runs/week'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Low pressure'), findsOneWidget);
    expect(find.text('Who this is for'), findsNothing);
    expect(find.text('Week 6'), findsOneWidget);
    expect(find.text('First 5K attempt'), findsOneWidget);
    expect(find.text("What you'll do"), findsNothing);
    expect(find.text('2 walk-run sessions'), findsNothing);
    expect(find.text('1 easy recovery walk'), findsNothing);
    expect(find.text('Rest between run days'), findsNothing);
    expect(find.text('Short easy intervals'), findsNothing);

    await tester.ensureVisible(find.text('Week 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week 1'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsOneWidget);
    expect(find.text('1 easy recovery walk'), findsOneWidget);
    expect(find.text('Rest between run days'), findsOneWidget);

    await tester.ensureVisible(find.text('Week 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week 2'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsOneWidget);
    expect(find.text('Short easy intervals'), findsOneWidget);
    expect(find.text('Comfortable walking breaks'), findsOneWidget);
    expect(find.text('Focus on showing up consistently'), findsOneWidget);

    await tester.tap(find.text('Week 2'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsOneWidget);
    expect(find.text('Short easy intervals'), findsNothing);

    await tester.ensureVisible(find.text('Week 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week 1'));
    await tester.pumpAndSettle();

    expect(find.text('2 walk-run sessions'), findsNothing);

    expect(find.text('Select This Plan'), findsOneWidget);
    expect(
      find.text('Plan selection is not available in this preview.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'This preview does not enroll you in a plan or update your progress.',
      ),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Expert Plans'), findsNothing);
    expect(find.text('10K Goal Plan'), findsNothing);
    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('Enroll'), findsNothing);
    expect(find.text('Unlock Premium'), findsNothing);
    expect(find.text('Activate Plan'), findsNothing);

    await tester.ensureVisible(find.text('Select This Plan'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Plan Preview')).dy, greaterThan(0));
    expect(
      tester.getTopLeft(find.byTooltip('Back to Expert Plans')).dy,
      greaterThan(0),
    );

    await tester.tap(find.text('Select This Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Preview'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Enrolled'), findsNothing);

    await tester.tap(find.byTooltip('Back to Expert Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Expert Plans'), findsOneWidget);

    await tester.tap(find.text('View Plan').first);
    await tester.pumpAndSettle();

    expect(find.text('Plan Preview'), findsOneWidget);
    expect(find.text('2 walk-run sessions'), findsNothing);
    expect(find.text('Short easy intervals'), findsNothing);
  });

  testWidgets('Upcoming weekly workout opens static workout detail only', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // When: the upcoming Thu workout row is tapped.
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // Then: the static workout instruction detail is shown.
    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Thursday · Easy Run'), findsOneWidget);
    expect(find.text('20 min easy run'), findsOneWidget);
    expect(find.text('A gentle 20 minutes.'), findsNothing);
    expect(
      find.text('You should be able to chat the whole way through.'),
      findsNothing,
    );
    expect(find.text('No race — just rhythm.'), findsNothing);
    expect(find.text('Suggested pace'), findsOneWidget);
    expect(find.text('Warm-up'), findsOneWidget);
    expect(find.text('Easy run'), findsOneWidget);
    expect(find.text('Cool-down'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.byTooltip('Edit schedule'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_schedule_icon_action')),
      findsOneWidget,
    );
    expect(find.text('Edit schedule'), findsNothing);
    expect(find.byTooltip('Back to Plans'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Workout detail')).dy, greaterThan(0));
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('edit_schedule_icon_action')))
          .dy,
      greaterThan(0),
    );
    expect(find.text('Start This Run'), findsOneWidget);
  });

  testWidgets('Saturday weekly workout opens matching instruction preview', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // When: the Saturday easy-run row is tapped.
    await Scrollable.ensureVisible(
      tester.element(find.text('Sat')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sat'));
    await tester.pumpAndSettle();

    // Then: the same static instruction sheet opens with Saturday labeling.
    expect(find.text('Workout detail'), findsOneWidget);
    expect(find.text('Saturday · Easy Run'), findsOneWidget);
    expect(find.text('Thursday · Easy Run'), findsNothing);
    expect(find.text('20 min easy run'), findsOneWidget);
    expect(find.text('A gentle 20 minutes.'), findsNothing);
    expect(find.text('Suggested pace'), findsOneWidget);
    expect(find.text('Warm-up'), findsOneWidget);
    expect(find.text('Easy run'), findsOneWidget);
    expect(find.text('Cool-down'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit schedule'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Current schedule'), findsOneWidget);
    expect(find.text('Saturday'), findsOneWidget);
    expect(find.text('Sat · 7:30 AM'), findsNothing);
    expect(find.text('Saturday · 7:30 AM'), findsNothing);
  });

  testWidgets('Only available workout instruction rows show tap affordance', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // Then: Thu and Sat expose detail chevrons, while completed and rest rows do not.
    expect(
      find.byKey(const ValueKey('weekly_workout_detail_chevron')),
      findsNWidgets(2),
    );
  });

  testWidgets(
    'Weekly plan rows keep day column aligned across affordance states',
    (WidgetTester tester) async {
      // Given: the static Plans weekly schedule is visible.
      await _openYouTab(tester);
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();

      // Then: tappable workout rows use the same day-column grid as rest/completed rows.
      final monLeft = tester.getTopLeft(find.text('Mon')).dx;
      final tueLeft = tester.getTopLeft(find.text('Tue')).dx;
      final thuLeft = tester.getTopLeft(find.text('Thu')).dx;
      final satLeft = tester.getTopLeft(find.text('Sat')).dx;

      expect(tueLeft, monLeft);
      expect(thuLeft, monLeft);
      expect(satLeft, monLeft);
    },
  );

  testWidgets('Rest and completed weekly rows do not open workout detail', (
    WidgetTester tester,
  ) async {
    // Given: the static Plans weekly schedule is visible.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    // Then: only available instruction previews expose detail chevrons.
    expect(
      find.byKey(const ValueKey('weekly_workout_detail_chevron')),
      findsNWidgets(2),
    );

    // When: a completed workout row is tapped.
    await Scrollable.ensureVisible(
      tester.element(find.text('15 min walk-run')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 min walk-run'));
    await tester.pumpAndSettle();

    // Then: no completed-workout detail flow is introduced.
    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('15 min walk-run'), findsOneWidget);

    // When: a Rest Day row is tapped.
    await tester.tap(find.text('Mon'));
    await tester.pumpAndSettle();

    // Then: no Rest Day detail flow is introduced.
    expect(find.text('Workout detail'), findsNothing);
    expect(find.text('Rest Day'), findsWidgets);
  });

  testWidgets('Workout detail edit schedule is preview only', (
    WidgetTester tester,
  ) async {
    // Given: the static Workout detail screen is open.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // When: the preview-only Edit schedule action is opened.
    await tester.tap(find.byTooltip('Edit schedule'));
    await tester.pumpAndSettle();

    // Then: the bottom sheet presents a richer static preview without mutation.
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_schedule_drag_handle')),
      findsOneWidget,
    );
    expect(find.text('Edit schedule'), findsWidgets);
    final handleBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('edit_schedule_drag_handle')))
        .dy;
    final titleTop = tester.getTopLeft(find.text('Edit schedule').last).dy;
    expect(handleBottom, lessThan(titleTop));
    expect(
      find.byKey(const ValueKey('edit_schedule_brand_accent')),
      findsOneWidget,
    );
    expect(
      find.text('Preview only — changes are not saved yet.'),
      findsOneWidget,
    );
    final titleBottom = tester
        .getBottomLeft(find.text('Edit schedule').last)
        .dy;
    final accentTop = tester
        .getTopLeft(find.byKey(const ValueKey('edit_schedule_brand_accent')))
        .dy;
    final accentBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('edit_schedule_brand_accent')))
        .dy;
    final previewTop = tester
        .getTopLeft(find.text('Preview only — changes are not saved yet.'))
        .dy;
    expect(accentTop, greaterThan(titleBottom));
    expect(accentBottom, lessThan(previewTop));
    expect(find.text('Current schedule'), findsOneWidget);
    expect(find.text('Thu · 7:30 AM'), findsOneWidget);
    expect(find.text('Preview example'), findsOneWidget);
    expect(find.text('Fri · 7:30 AM'), findsOneWidget);
    expect(find.text('Suggested time previews'), findsNothing);
    expect(
      find.byKey(const ValueKey('edit_schedule_suggested_preview_row')),
      findsNothing,
    );
    expect(find.text('Tonight · 6:30 PM'), findsNothing);
    expect(find.text('Tomorrow morning · 7:30 AM'), findsNothing);
    expect(find.text('Weekend morning · 8:00 AM'), findsNothing);
    expect(find.text('Advanced preview'), findsOneWidget);
    expect(find.text('These options are examples only.'), findsOneWidget);
    expect(find.text('Select day'), findsOneWidget);
    for (final text in [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
      '07:00 AM',
      '08:00 AM',
      '06:30 PM',
      '07:30 PM',
    ]) {
      expect(find.text(text), findsWidgets);
    }
    expect(find.text('Select time'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_schedule_time_preview_grid')),
      findsOneWidget,
    );
    expect(find.text('Choose custom time'), findsOneWidget);
    expect(find.text('Why might you move it later?'), findsNothing);
    for (final reason in [
      'Busy at original time',
      'Feeling tired',
      'Bad weather',
      'Injury / discomfort',
      'Prefer another time',
      'Other',
    ]) {
      expect(find.text(reason), findsNothing);
    }
    expect(
      find.text(
        'You’ll be able to add a reason when schedule changes are enabled.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Saving schedule changes will be available later.'),
      findsOneWidget,
    );
    final saveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Save New Schedule'),
    );
    expect(saveButton.onPressed, isNull);
    expect(find.text('Close'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('Save New Schedule')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save New Schedule'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Saved'), findsNothing);

    await Scrollable.ensureVisible(tester.element(find.text('Close')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('Workout detail disables overscroll stretch locally', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Given: the static Workout detail screen is open on a constrained viewport.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // Then: the detail scroll surface disables overscroll stretch locally.
    expect(
      find.byKey(const ValueKey('workout_detail_no_overscroll')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Edit schedule'));
    await tester.pumpAndSettle();

    // And: the preview-only sheet uses the same no-stretch boundary locally.
    expect(
      find.byKey(const ValueKey('edit_schedule_no_overscroll')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Workout detail keeps Suggested pace metric compact', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Given: the static Workout detail screen is open on a narrow viewport.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    final headerTitle = tester.widget<Text>(
      find.byKey(const ValueKey('workout_detail_header_title')),
    );
    final headerTitleSize = tester.getSize(
      find.byKey(const ValueKey('workout_detail_header_title')),
    );
    final suggestedPaceLabel = tester.widget<Text>(
      find.byKey(const ValueKey('suggested_pace_metric_label')),
    );

    // Then: the centered header title renders without ellipsis, and the
    // schedule action is icon-only while remaining accessible.
    expect(headerTitle.data, 'Workout detail');
    expect(headerTitle.maxLines, 2);
    expect(headerTitle.overflow, TextOverflow.visible);
    expect(headerTitle.style?.fontFamily, isNull);
    expect(headerTitle.style?.decoration, isNot(TextDecoration.underline));
    expect(headerTitleSize.width, greaterThan(92));
    expect(find.byTooltip('Edit schedule'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_schedule_icon_action')),
      findsOneWidget,
    );
    expect(find.text('Edit schedule'), findsNothing);

    final dayLabel = tester.widget<Text>(find.text('Thursday · Easy Run'));
    final planTitle = tester.widget<Text>(find.text('20 min easy run'));
    expect(dayLabel.style?.fontFamily, isNull);
    expect(dayLabel.style?.decoration, isNot(TextDecoration.underline));
    expect(planTitle.style?.fontFamily, isNull);
    expect(planTitle.style?.decoration, isNot(TextDecoration.underline));

    // Then: the long metric label remains a compact single-line label.
    expect(suggestedPaceLabel.data, 'Suggested pace');
    expect(suggestedPaceLabel.maxLines, 1);
    expect(suggestedPaceLabel.softWrap, isFalse);
    expect(find.text('7:30 /km'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Workout detail start action opens run launch screen', (
    WidgetTester tester,
  ) async {
    // Given: the static Workout detail screen is open.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();

    // When: Start This Run is tapped.
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start This Run'));
    await tester.pumpAndSettle();

    // Then: it routes only to the existing frontend run launch screen.
    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('Waiting for GPS'), findsNothing);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('Start This Run'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);

    for (final forbidden in <Pattern>[
      RegExp(r'\bXP\b', caseSensitive: false),
      RegExp('streak', caseSensitive: false),
      RegExp('rank', caseSensitive: false),
      RegExp('leaderboard', caseSensitive: false),
      RegExp('completed', caseSensitive: false),
      RegExp('saved', caseSensitive: false),
    ]) {
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.textContaining(forbidden),
        ),
        findsNothing,
      );
    }
  });

  testWidgets('Workout detail run uses app-level active session coordinator', (
    WidgetTester tester,
  ) async {
    final activeRunSessionCoordinator = _testActiveRunSessionCoordinator(
      tester,
    );
    await _openYouTab(
      tester,
      activeRunSessionCoordinator: activeRunSessionCoordinator,
    );
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Upcoming · 7:30 AM')),
      alignment: 0.45,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming · 7:30 AM'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start This Run'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Start run'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    expect(handled, isTrue);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Run'));
    await tester.pumpAndSettle();

    expect(find.text('Start run'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'View Goal Plan opens static goal detail with bottom nav visible',
    (WidgetTester tester) async {
      // Given: the user is viewing the static Plans section in the You tab.
      await _openYouTab(tester);
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();

      // When: the user opens the current goal plan detail.
      await tester.tap(find.text('View Goal Plan'));
      await tester.pumpAndSettle();

      // Then: the static detail snapshot is shown without leaving the app shell.
      expect(find.text('10K Goal Plan'), findsOneWidget);
      expect(find.text('10K Preparation'), findsWidgets);
      expect(find.text('Week 3 of 8'), findsOneWidget);
      expect(find.text('43% completed'), findsOneWidget);
      expect(find.text('Current Phase'), findsOneWidget);
      expect(find.text('Base Endurance'), findsWidgets);
      expect(find.byTooltip('Home'), findsOneWidget);
      expect(find.byTooltip('Maps'), findsOneWidget);
      expect(find.byTooltip('Run'), findsOneWidget);
      expect(find.byTooltip('Leaderboard'), findsOneWidget);
      expect(find.byTooltip('You'), findsOneWidget);
    },
  );

  testWidgets('Goal Plan Detail renders static timeline rows only', (
    WidgetTester tester,
  ) async {
    // Given: the static Goal Plan Detail screen is open.
    await _openYouTab(tester);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Goal Plan'));
    await tester.pumpAndSettle();

    // Then: every accepted static week row is rendered from the snapshot.
    for (final text in [
      'Week 1',
      'Build Routine',
      'Week 2',
      'Easy Distance',
      'Week 3',
      'Base Endurance',
      'Week 4',
      '6 km Milestone',
      'Week 5',
      'Longer Effort',
      'Week 6',
      '8 km Progression',
      'Week 7',
      '10K Preparation',
      'Week 8',
      '10K Attempt',
    ]) {
      expect(find.text(text), findsWidgets);
    }
    for (final label in ['Completed', 'Current', 'Upcoming', 'Goal Week']) {
      expect(find.text(label), findsNothing);
    }
    for (final summary in const [
      '4 days · 8 km',
      '4 days · 10 km',
      '4 days · 12 km',
      '4 days · 14 km',
      '4 days · 16 km',
      '4 days · 18 km',
      '4 days · 20 km',
      '4 days · 10K',
    ]) {
      expect(find.text(summary), findsNothing);
    }
    expect(find.byIcon(Icons.check), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('goal_plan_detail_marker_Week 3')),
        matching: find.byIcon(Icons.directions_run),
      ),
      findsOneWidget,
    );
    expect(find.text('Monday'), findsNothing);

    // When: a week row is tapped.
    await tester.tap(
      find.byKey(const ValueKey('goal_plan_detail_week_toggle_Week 4')),
    );
    await tester.pumpAndSettle();

    // Then: only the static preview dropdown opens; no modal behavior appears.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('10K Goal Plan'), findsOneWidget);
    expect(find.text('6 km Milestone'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Sunday'), findsOneWidget);
    expect(find.text('Rest'), findsNWidgets(3));
    expect(find.text('0 min'), findsNWidgets(3));
    expect(find.text('4 days · 14 km'), findsNothing);
  });

  testWidgets(
    'Goal Plan Detail back returns to Plans without Home entry point',
    (WidgetTester tester) async {
      // Given: Home does not expose the Goal Plan Detail entry point.
      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );
      expect(find.text('View Goal Plan'), findsNothing);

      // And: the user opens the detail from the You tab Plans section.
      await tester.tap(find.byTooltip('You'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Goal Plan'));
      await tester.pumpAndSettle();
      expect(find.text('10K Goal Plan'), findsOneWidget);

      // When: the detail back button is tapped.
      await tester.tap(find.byTooltip('Back to Plans'));
      await tester.pumpAndSettle();

      // Then: the previous Plans screen is restored.
      expect(find.text('10K Goal Plan'), findsNothing);
      expect(find.text('View Goal Plan'), findsOneWidget);
      expect(find.text("This Week's Plan"), findsOneWidget);
    },
  );

  testWidgets('You page preserves shell navigation around adjacent tabs', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Maps'), findsOneWidget);
    expect(find.byTooltip('Run'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('You'), findsOneWidget);
    expect(find.text('You'), findsWidgets);
    expect(find.text('Weekly Distance'), findsOneWidget);

    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);
    expect(find.text('Weekly Distance'), findsNothing);
  });

  testWidgets('Run launch from You hides the You header once settled', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    expect(find.text('You'), findsWidgets);
    expect(find.text('Weekly Distance'), findsOneWidget);

    await tester.tap(find.byTooltip('Run'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('You').hitTestable(), findsNothing);
    expect(find.text('Weekly Distance').hitTestable(), findsNothing);
  });

  testWidgets('Run close from You reveals the You page during transition', (
    WidgetTester tester,
  ) async {
    await _openYouTab(tester);

    await tester.tap(find.byTooltip('Run'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('You').hitTestable(), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byKey(const ValueKey('run_launch_transition_cover')),
      findsNothing,
    );
    expect(find.text('You', skipOffstage: false), findsWidgets);

    await tester.pump(const Duration(milliseconds: 100));
  });
}
