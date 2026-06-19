import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/core/theme/runiac_colors.dart';
import 'package:runiac_app/features/run/domain/models/coaching_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/complete_run_result.dart';
import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/progression_display_model.dart';
import 'package:runiac_app/features/run/domain/models/run_activity_read_model.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/models/run_route_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_source_display.dart';
import 'package:runiac_app/features/run/presentation/advanced_analysis_screen.dart';
import 'package:runiac_app/features/run/presentation/cool_down_guide_screen.dart';
import 'package:runiac_app/features/run/presentation/cool_down_screen.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_read_model.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/xp_update_display_model.dart';
import 'package:runiac_app/features/run/domain/repositories/run_repository.dart';
import 'package:runiac_app/features/run/domain/services/completed_run_title_formatter.dart';
import 'package:runiac_app/features/run/presentation/active_run_session_coordinator.dart';
import 'package:runiac_app/features/run/presentation/data/pace_graph_demo_snapshots.dart';
import 'package:runiac_app/features/run/presentation/data/run_completion_demo_snapshots.dart';
import 'package:runiac_app/features/run/presentation/run_launch_screen.dart';
import 'package:runiac_app/features/run/presentation/view_summary_screen.dart';
import 'package:runiac_app/features/run/presentation/widgets/completed_route_map_surface.dart';
import 'package:runiac_app/features/run/presentation/widgets/share_achievement_sheet.dart';
import 'package:runiac_app/features/run/presentation/xp_update_screen.dart';

final _forbiddenRunCompletionCopy = RegExp(
  r'XP|streak|Leaderboard|Activity saved|Saved activity|activity saved|'
  r'saved activity|backend completion|backend-completion|completed run|'
  r'run completed',
  caseSensitive: false,
);

final _forbiddenRealActivitySaveCopy = RegExp(
  r'Activity saved|Saved activity|activity saved|saved activity|'
  r'backend completion|backend-completion|completed run|run completed|'
  r'synced|uploaded',
  caseSensitive: false,
);

final _forbiddenXpUpdateCompetitiveCopy = RegExp(
  r'leaderboard|rank|ranking|percentile|beat others|division',
  caseSensitive: false,
);

void _useCompactShareSheetSurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void _useTallSummarySurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(800, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _shareSheetHarness() {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return Center(
            child: FilledButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withValues(alpha: 0.48),
                  builder: (context) => const ShareAchievementSheet(),
                );
              },
              child: const Text('Open share sheet'),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _openPausedRun(WidgetTester tester) async {
  await tester.pumpWidget(
    const RuniacApp(showSplash: false, enableForegroundGps: false),
  );

  await tester.tap(find.byTooltip('Run'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start run'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pause'));
  await tester.pumpAndSettle();
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

Future<void> _finishPausedRun(WidgetTester tester) async {
  final endButton = find.byKey(const Key('hold_to_end_button'));
  final holdGesture = await tester.startGesture(tester.getCenter(endButton));
  await tester.pump(const Duration(milliseconds: 3100));
  await holdGesture.up();
  await tester.pumpAndSettle();
}

class _ResultRunRepository implements RunRepository {
  _ResultRunRepository(this.result);

  final CompleteRunResult result;
  int completeRunCalls = 0;
  LocalRunCompletionPayload? lastPayload;

  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    completeRunCalls += 1;
    lastPayload = payload;
    return result;
  }

  @override
  Future<CompleteRunResult> loadLatestCompletionResult() async {
    return result;
  }

  @override
  Future<RunActivityReadModel> loadLatestRunActivity() async {
    return const RunActivityReadModel(
      activityId: 'repo-activity',
      title: 'Repository Run',
      completedAtLabel: 'Today',
      distanceLabel: '5.40 km',
      durationLabel: '36:00',
      avgPaceLabel: '6’40”',
      routeLabel: 'Repository Route',
    );
  }

  @override
  Future<RunSummaryReadModel> loadLatestRunSummary() async {
    return const RunSummaryReadModel(
      summaryId: 'repo-summary',
      title: 'Repository Run',
      dateLabel: 'Today',
      timeLabel: '8:10 AM',
      distanceLabel: '5.40 km',
      avgPaceLabel: '6’40”',
      durationLabel: '36:00',
      avgHeartRateLabel: '138 bpm',
      caloriesLabel: '280 kcal',
      routeName: 'Repository Route',
    );
  }
}

class _FailingRunRepository extends _ResultRunRepository {
  _FailingRunRepository(super.result);

  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    completeRunCalls += 1;
    lastPayload = payload;
    throw StateError('repository unavailable');
  }
}

class _DelayedRunRepository extends _ResultRunRepository {
  _DelayedRunRepository(super.result);

  final Completer<CompleteRunResult> completer = Completer<CompleteRunResult>();

  @override
  Future<CompleteRunResult> completeRun(LocalRunCompletionPayload payload) {
    completeRunCalls += 1;
    lastPayload = payload;
    return completer.future;
  }
}

class _GeneratedTitleRunRepository extends _ResultRunRepository {
  _GeneratedTitleRunRepository() : super(_repositoryCompletionResult);

  String? generatedTitle;

  @override
  Future<CompleteRunResult> completeRun(LocalRunCompletionPayload payload) {
    completeRunCalls += 1;
    lastPayload = payload;
    final title = const CompletedRunTitleFormatter().format(
      completedAt: payload.completedAt,
    );
    generatedTitle = title;
    return Future<CompleteRunResult>.value(
      CompleteRunResult(
        activityId: result.activityId,
        summaryId: result.summaryId,
        progressionEventId: result.progressionEventId,
        validationStatus: result.validationStatus,
        summary: RunSummarySnapshot(
          title: title,
          dateLabel: result.summary.dateLabel,
          timeLabel: result.summary.timeLabel,
          distanceKm: result.summary.distanceKm,
          avgPace: result.summary.avgPace,
          duration: result.summary.duration,
          avgHeartRate: result.summary.avgHeartRate,
          calories: result.summary.calories,
          routeName: result.summary.routeName,
        ),
        progressionDisplay: result.progressionDisplay,
        xpUpdate: result.xpUpdate,
        message: result.message,
      ),
    );
  }
}

const _repositoryCompletionResult = CompleteRunResult(
  activityId: 'repo-activity',
  summaryId: 'repo-summary',
  progressionEventId: 'repo-progression',
  validationStatus: 'validated',
  summary: RunSummarySnapshot(
    title: 'Repository Result Run',
    dateLabel: 'Today',
    timeLabel: '8:10 AM',
    distanceKm: '5.40',
    avgPace: '6’40”',
    duration: '36:00',
    avgHeartRate: '138',
    calories: '280',
    routeName: 'Repository Route',
  ),
  progressionDisplay: ProgressionDisplayModel(
    xpDelta: 0,
    countsTowardLeaderboard: false,
    status: 'deferred',
    reason: 'progression_formula_deferred',
  ),
  xpUpdate: XpUpdateDisplayModel(
    runnerName: 'Maya',
    earnedXpLabel: '+0 XP',
    totalXpLabel: '0 XP',
    levelLabel: '0',
    nextLevelLabel: '1',
    progressTargetLabel: 'Progress deferred',
    xpRemainingLabel: 'Pending',
    previousProgressFraction: 0,
    currentProgressFraction: 0,
    streakChangeLabel: 'Deferred',
    streakNote: 'Accepted.',
    didLevelUp: false,
  ),
  message: 'Static repository completion accepted.',
);

void main() {
  testWidgets('Run item opens and protects local active finish controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        enableForegroundGps: false,
        activeRunSessionCoordinator: _testActiveRunSessionCoordinator(tester),
      ),
    );

    await tester.tap(find.byTooltip('Run'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Run settings'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('km easy run'), findsOneWidget);
    expect(find.text('Pace 7:10-7:40 / km · ~32 min'), findsOneWidget);
    expect(find.text('Switch route'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('Waiting for GPS'), findsNothing);
    expect(find.text('DISTANCE'), findsNothing);
    expect(find.text('TIME'), findsNothing);
    expect(find.text('AVG PACE'), findsNothing);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsNothing);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Maps'), findsNothing);
    expect(find.text('Leaderboard'), findsNothing);
    expect(find.text('You'), findsNothing);

    await tester.tap(find.text('Switch route'));
    await tester.pumpAndSettle();

    expect(
      find.text('Route switching preview is coming soon.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Run settings'));
    await tester.pumpAndSettle();

    expect(find.text('Run settings preview is coming soon.'), findsOneWidget);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsNothing);
    expect(find.text('RUNNING'), findsNothing);
    expect(find.text('0.00 of 4.50 km'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.byKey(const Key('run_plan_progress_bar')), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.text('--:--/km'), findsOneWidget);
    expect(find.text('HEART'), findsNothing);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsNothing);
    expect(find.byTooltip('Close'), findsNothing);
    expect(find.byTooltip('Run settings'), findsNothing);
    expect(find.text('Waiting for GPS'), findsNothing);
    expect(find.text('Start run'), findsNothing);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.textContaining('of 4.50 km'), findsOneWidget);
    expect(find.text('1%'), findsOneWidget);
    expect(find.text('--:--/km'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('Hold to end'), findsNothing);
    expect(find.text('Keep holding...'), findsNothing);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.textContaining('of 4.50 km'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.text('--:--/km'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('00:10'), findsOneWidget);
    expect(find.textContaining('of 4.50 km'), findsOneWidget);
    expect(find.text('Run summary'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.text('Leaderboard'), findsNothing);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Finish'), findsNothing);
    expect(find.text('Hold to end'), findsNothing);
    expect(find.text('Keep holding...'), findsNothing);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('00:10'), findsNothing);
    expect(find.text('0.02 of 4.50 km'), findsNothing);
  });

  testWidgets('Run finish opens Cool down page with placeholder actions', (
    WidgetTester tester,
  ) async {
    await _openPausedRun(tester);

    await _finishPausedRun(tester);

    expect(find.text('Cool down'), findsOneWidget);
    expect(
      find.text('Great job! Now let’s cool down and stretch.'),
      findsOneWidget,
    );
    expect(find.text('Why cool-down?'), findsOneWidget);
    expect(
      find.text(
        'A gentle cool-down helps your heart rate settle and can reduce muscle soreness.',
      ),
      findsOneWidget,
    );
    expect(find.text('Slow Walk'), findsOneWidget);
    expect(find.text('3-5 min'), findsOneWidget);
    expect(find.text('Stretching'), findsOneWidget);
    expect(find.text('5-8 min · 5 exercises'), findsOneWidget);
    expect(find.text('Start Cool-down'), findsOneWidget);
    expect(find.text('Skip to Summary'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.textContaining(_forbiddenRunCompletionCopy), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Skip to Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Easy local route'), findsNothing);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(3));
    expect(find.text('0:00'), findsWidgets);
    expect(find.text('Saturday Morning Run'), findsNothing);
    expect(find.text('East Coast Park Loop'), findsNothing);
    expect(find.text('4.03'), findsNothing);
    expect(find.text('6’30”'), findsNothing);
    expect(find.text('30:15'), findsNothing);
    expect(find.text('Pace Over Time'), findsOneWidget);
    expect(find.text('Advanced Analysis'), findsOneWidget);
    expect(find.text('Coaching Summary'), findsOneWidget);
    expect(find.text('AI Coaching Summary'), findsNothing);
    expect(
      find.text(
        'This run has limited run data, so the summary stays simple. Your effort still counts.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('steady pace'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Share Route'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);
    expect(find.text('XP & Streak Update'), findsNothing);
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);
  });

  testWidgets(
    'Run finish uses repository completion result through summary and XP update',
    (WidgetTester tester) async {
      final repository = _ResultRunRepository(_repositoryCompletionResult);

      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            repository: repository,
            enableForegroundGps: false,
          ),
        ),
      );

      await tester.tap(find.text('Start run'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      await _finishPausedRun(tester);

      expect(repository.completeRunCalls, 1);
      expect(repository.lastPayload, isNotNull);
      expect(repository.lastPayload!.clientRunSessionId, 'local-run-1');
      expect(repository.lastPayload!.routePrivacy, 'private');
      expect(repository.lastPayload!.routeLabel, 'Easy local route');
      expect(repository.lastPayload!.source, 'local_simulation');
      expect(find.text('Cool down'), findsOneWidget);
      expect(find.text('Repository Result Run'), findsNothing);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Skip to Summary'));
      await tester.pumpAndSettle();

      expect(find.text('Repository Result Run'), findsOneWidget);
      expect(find.text('Today · 8:10 AM'), findsOneWidget);
      expect(find.text('Repository Route'), findsNothing);
      expect(find.text('5.40'), findsOneWidget);
      expect(find.text('36:00'), findsOneWidget);
      expect(find.text('138 bpm'), findsOneWidget);
      expect(find.text('Saturday Morning Run'), findsNothing);

      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'View XP Update'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'View XP Update'));
      await tester.pumpAndSettle();

      expect(find.text('XP & Streak Update'), findsOneWidget);
      expect(find.text('Nice work, Maya!'), findsOneWidget);
      expect(find.text('+0 XP'), findsOneWidget);
      expect(find.text('0 XP'), findsOneWidget);
      expect(find.text('Accepted.'), findsOneWidget);
      expect(find.text('Nice work, Jinseo!'), findsNothing);
      expect(
        find.textContaining(_forbiddenXpUpdateCompetitiveCopy),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Run finish displays generated completion title in summary', (
    WidgetTester tester,
  ) async {
    final repository = _GeneratedTitleRunRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          repository: repository,
          enableForegroundGps: false,
        ),
      ),
    );

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    await _finishPausedRun(tester);

    expect(repository.completeRunCalls, 1);
    expect(repository.lastPayload, isNotNull);
    expect(repository.generatedTitle, isNotNull);
    final generatedTitle = repository.generatedTitle!;
    expect(find.text(generatedTitle), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Skip to Summary'));
    await tester.pumpAndSettle();

    expect(find.text(generatedTitle), findsOneWidget);
    expect(find.text('Repository Route'), findsNothing);
    expect(find.text('Saturday Morning Run'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Immediate Run finish shows zero summary instead of demo fallback',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RunLaunchScreen(enableForegroundGps: false)),
      );

      await tester.tap(find.text('Start run'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      await _finishPausedRun(tester);

      expect(find.text('Cool down'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Skip to Summary'));
      await tester.pumpAndSettle();

      expect(find.text('Easy local route'), findsNothing);
      expect(find.text('0.00'), findsOneWidget);
      expect(find.text('0:00'), findsWidgets);
      expect(find.text('--'), findsNWidgets(3));
      expect(find.text('-- bpm'), findsNothing);
      expect(find.text('-- kcal'), findsNothing);
      expect(find.text('Saturday Morning Run'), findsNothing);
      expect(find.text('East Coast Park Loop'), findsNothing);
      expect(find.text('4.03'), findsNothing);
      expect(find.text('6’30”'), findsNothing);
      expect(find.text('30:15'), findsNothing);
      expect(find.text('145 bpm'), findsNothing);
      expect(find.text('145 kcal'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Run finish keeps retry path when repository completion fails', (
    WidgetTester tester,
  ) async {
    final repository = _FailingRunRepository(_repositoryCompletionResult);

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          repository: repository,
          enableForegroundGps: false,
        ),
      ),
    );

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    await _finishPausedRun(tester);

    expect(repository.completeRunCalls, 1);
    expect(repository.lastPayload, isNotNull);
    expect(find.text('Cool down'), findsNothing);
    expect(
      find.text('Run completion is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('End'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run finish guards duplicate completion while repository waits', (
    WidgetTester tester,
  ) async {
    final repository = _DelayedRunRepository(_repositoryCompletionResult);

    await tester.pumpWidget(
      MaterialApp(
        home: RunLaunchScreen(
          repository: repository,
          enableForegroundGps: false,
        ),
      ),
    );

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    await _finishPausedRun(tester);
    await tester.pump();

    expect(repository.completeRunCalls, 1);
    expect(repository.lastPayload, isNotNull);
    expect(find.text('Saving'), findsOneWidget);
    expect(find.text('End'), findsNothing);
    expect(find.text('Resume'), findsOneWidget);

    await tester.longPress(find.byKey(const Key('hold_to_end_button')));
    await tester.pump(const Duration(milliseconds: 50));

    expect(repository.completeRunCalls, 1);
    expect(find.text('Cool down'), findsNothing);

    repository.completer.complete(_repositoryCompletionResult);
    await tester.pumpAndSettle();

    expect(repository.completeRunCalls, 1);
    expect(find.text('Cool down'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('View summary static content and actions match design', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);
    await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

    final summaryScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(summaryScaffold.backgroundColor, RuniacColors.white);
    expect(find.text('Saturday Morning Run'), findsOneWidget);
    expect(find.text('Today · 7:06 AM'), findsOneWidget);
    expect(find.byTooltip('Back to cool down'), findsOneWidget);
    expect(find.byTooltip('Share summary'), findsOneWidget);
    expect(find.text('East Coast Park Loop'), findsNothing);
    expect(find.text('Run complete'), findsNothing);
    expect(find.text('4.03'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('6’30”'), findsOneWidget);
    expect(find.text('Avg Pace'), findsOneWidget);
    expect(find.text('30:15'), findsWidgets);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('145 bpm'), findsOneWidget);
    expect(find.text('145 kcal'), findsOneWidget);
    expect(find.text('Avg Heart Rate'), findsOneWidget);
    expect(find.text('Est. calories'), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(find.byIcon(Icons.speed_rounded), findsNothing);
    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    expect(find.byIcon(Icons.local_fire_department_outlined), findsNothing);
    expect(find.text('Pace Over Time'), findsOneWidget);
    expect(find.text('4:00'), findsNothing);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('13:00'), findsNothing);
    expect(find.text('6:00'), findsOneWidget);
    expect(find.text('6:40'), findsOneWidget);
    expect(find.text('7:20'), findsOneWidget);
    expect(find.text('More run data needed'), findsNothing);
    expect(find.text('Advanced Analysis'), findsOneWidget);
    expect(find.text('Heart rate zones, cadence & elevation'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
    expect(find.text('Steady'), findsOneWidget);
    expect(find.text('22%'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(find.text('More Details'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    expect(find.text('Coaching Summary'), findsOneWidget);
    expect(find.text('AI Coaching Summary'), findsNothing);
    expect(
      find.text('This summary uses the run data available on this device.'),
      findsOneWidget,
    );
    expect(find.text('Good work finishing this run'), findsOneWidget);
    expect(find.text('Next Run Tip'), findsNothing);
    expect(find.text('Next Action'), findsOneWidget);
    expect(find.text('Next Run Tip:'), findsNothing);
    expect(
      find.text('Keep your next run easy and comfortable.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Share Route'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsOneWidget);
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);

    await tester.tap(find.byTooltip('Share summary'));
    await tester.pumpAndSettle();

    expect(find.text('Share Your Achievement'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(OutlinedButton, 'More Details'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'More Details'));
    await tester.pumpAndSettle();

    expect(find.text('Performance Overview'), findsOneWidget);
    expect(find.text('Good steady effort'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to summary'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(OutlinedButton, 'Share Route'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Share Route'));
    await tester.pumpAndSettle();

    expect(find.text('Route sharing will be available soon.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'View XP Update'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'View XP Update'));
    await tester.pumpAndSettle();

    expect(find.text('XP & Streak Update'), findsOneWidget);
    expect(find.text('Nice work, Jinseo!'), findsOneWidget);
    expect(find.text('+120 XP'), findsOneWidget);
    expect(find.text('Earned from this run'), findsOneWidget);
  });

  testWidgets('View summary accepts selected static run summary data', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: ViewSummaryScreen(
          summary: RunSummarySnapshot(
            title: 'Recovery Jog',
            dateLabel: '4/11/26',
            timeLabel: '8:10 PM',
            distanceKm: '5.17',
            avgPace: '7’40”',
            duration: '39:38',
            avgHeartRate: '132',
            calories: '286',
            routeName: 'Park Connector Recovery Loop',
          ),
        ),
      ),
    );

    expect(find.text('Recovery Jog'), findsOneWidget);
    expect(find.text('4/11/26 · 8:10 PM'), findsOneWidget);
    expect(find.text('Park Connector Recovery Loop'), findsNothing);
    expect(find.text('5.17'), findsOneWidget);
    expect(find.text('7’40”'), findsOneWidget);
    expect(find.text('39:38'), findsOneWidget);
    expect(find.text('132 bpm'), findsOneWidget);
    expect(find.text('286 kcal'), findsOneWidget);
    expect(find.text('Saturday Morning Run'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Share Route'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsOneWidget);
  });

  testWidgets(
    'View summary renders deterministic coaching summary without AI label by default',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);

      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      expect(find.text('Coaching Summary'), findsOneWidget);
      expect(find.text('AI Coaching Summary'), findsNothing);
      expect(find.text('Good work finishing this run'), findsOneWidget);
      expect(
        find.text('This summary uses the run data available on this device.'),
        findsOneWidget,
      );
      expect(find.text('Next Action'), findsOneWidget);
      expect(
        find.text('Keep your next run easy and comfortable.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'View summary maps AI source to AI Coaching Summary only when explicitly returned',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: ViewSummaryScreen(
            summary: defaultRunSummarySnapshot.copyWith(
              coachingSummary: const CoachingSummarySnapshot(
                source: CoachingSummarySource.aiGenerated,
                headline: 'AI source summary headline',
                message:
                    'This synthetic summary is supplied only by an explicit AI source.',
                bullets: ['Synthetic AI bullet from returned model.'],
                nextAction: 'Use returned model copy only.',
              ),
            ),
          ),
        ),
      );

      expect(find.text('AI Coaching Summary'), findsOneWidget);
      expect(find.text('Coaching Summary'), findsNothing);
      expect(find.text('AI source summary headline'), findsOneWidget);
      expect(
        find.text(
          'This synthetic summary is supplied only by an explicit AI source.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Synthetic AI bullet from returned model.'),
        findsOneWidget,
      );
      expect(find.text('Use returned model copy only.'), findsOneWidget);
    },
  );

  testWidgets(
    'View summary renders completed route preview when route exists',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);
      final startedAt = DateTime.utc(2026, 6, 14, 7);

      await tester.pumpWidget(
        MaterialApp(
          home: ViewSummaryScreen(
            summary: RunSummarySnapshot(
              title: 'Completed Route Run',
              dateLabel: 'Today',
              timeLabel: '8:10 AM',
              distanceKm: '0.30',
              avgPace: '6’40”',
              duration: '2:00',
              avgHeartRate: '--',
              calories: '27',
              routeName: 'Actual Local Route',
              route: RunRouteSnapshot(
                segments: [
                  [
                    RunLocationSample(
                      recordedAt: startedAt,
                      latitude: 1.300000,
                      longitude: 103.800000,
                    ),
                    RunLocationSample(
                      recordedAt: startedAt.add(const Duration(seconds: 60)),
                      latitude: 1.300899,
                      longitude: 103.800000,
                    ),
                  ],
                ],
                lastKnownLocation: RunLocationSample(
                  recordedAt: startedAt.add(const Duration(seconds: 60)),
                  latitude: 1.300899,
                  longitude: 103.800000,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('summary_route_preview_route')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('summary_route_preview_dot')), findsNothing);
      expect(
        find.byKey(const Key('summary_route_preview_placeholder')),
        findsNothing,
      );
      expect(find.text('Actual Local Route'), findsNothing);
    },
  );

  testWidgets('View summary map preview removes route label pill overlay', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);
    final startedAt = DateTime.utc(2026, 6, 14, 7);

    await tester.pumpWidget(
      MaterialApp(
        home: ViewSummaryScreen(
          summary: RunSummarySnapshot(
            title: 'Completed Route Run',
            dateLabel: 'Today',
            timeLabel: '8:10 AM',
            distanceKm: '0.30',
            avgPace: '6’40”',
            duration: '2:00',
            avgHeartRate: '--',
            calories: '27',
            routeName: 'Easy local route',
            route: RunRouteSnapshot(
              segments: [
                [
                  RunLocationSample(
                    recordedAt: startedAt,
                    latitude: 1.300000,
                    longitude: 103.800000,
                  ),
                  RunLocationSample(
                    recordedAt: startedAt.add(const Duration(seconds: 60)),
                    latitude: 1.300899,
                    longitude: 103.800000,
                  ),
                ],
              ],
              lastKnownLocation: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 60)),
                latitude: 1.300899,
                longitude: 103.800000,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Easy local route'), findsNothing);
  });

  testWidgets(
    'View summary uses Mapbox completed route preview when token is available',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      CompletedRouteMapboxSurfaceConfig? capturedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewSummaryScreen(
            mapboxAccessToken: 'pk.summary-test-token',
            mapboxBuilder: (context, config) {
              capturedConfig = config;
              return const ColoredBox(
                key: Key('fake_summary_mapbox_preview'),
                color: Colors.black,
              );
            },
            summary: RunSummarySnapshot(
              title: 'Mapbox Route Run',
              dateLabel: 'Today',
              timeLabel: '8:10 AM',
              distanceKm: '0.30',
              avgPace: '6’40”',
              duration: '2:00',
              avgHeartRate: '--',
              calories: '27',
              routeName: 'Actual Local Route',
              route: RunRouteSnapshot(
                segments: [
                  [
                    RunLocationSample(
                      recordedAt: startedAt,
                      latitude: 1.300000,
                      longitude: 103.800000,
                    ),
                    RunLocationSample(
                      recordedAt: startedAt.add(const Duration(seconds: 60)),
                      latitude: 1.300899,
                      longitude: 103.800000,
                    ),
                  ],
                ],
                lastKnownLocation: RunLocationSample(
                  recordedAt: startedAt.add(const Duration(seconds: 60)),
                  latitude: 1.300899,
                  longitude: 103.800000,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('summary_route_mapbox_preview_selected')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('fake_summary_mapbox_preview')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('summary_route_preview_route')),
        findsNothing,
      );
      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.isExpanded, isFalse);
      expect(capturedConfig!.route.hasRoute, isTrue);
      expect(capturedConfig!.accessToken, 'pk.summary-test-token');
    },
  );

  testWidgets(
    'View summary renders last-location dot when completed route is unavailable',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);
      final recordedAt = DateTime.utc(2026, 6, 14, 7, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: ViewSummaryScreen(
            summary: RunSummarySnapshot(
              title: 'Location Only Run',
              dateLabel: 'Today',
              timeLabel: '8:11 AM',
              distanceKm: '0.00',
              avgPace: '--',
              duration: '0:30',
              avgHeartRate: '--',
              calories: '--',
              routeName: 'Private route',
              route: RunRouteSnapshot(
                lastKnownLocation: RunLocationSample(
                  recordedAt: recordedAt,
                  latitude: 1.300100,
                  longitude: 103.800000,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('summary_route_preview_dot')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('summary_route_preview_route')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('summary_route_preview_placeholder')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'View summary keeps neutral placeholder when no route or location exists',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: ViewSummaryScreen(
            summary: RunSummarySnapshot(
              title: 'No Location Run',
              dateLabel: 'Today',
              timeLabel: '8:12 AM',
              distanceKm: '0.00',
              avgPace: '--',
              duration: '0:00',
              avgHeartRate: '--',
              calories: '--',
              routeName: 'Private route',
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('summary_route_preview_placeholder')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('summary_route_preview_route')),
        findsNothing,
      );
      expect(find.byKey(const Key('summary_route_preview_dot')), findsNothing);
    },
  );

  testWidgets('Tapping route preview opens and closes expanded map', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);
    final startedAt = DateTime.utc(2026, 6, 14, 7);

    await tester.pumpWidget(
      MaterialApp(
        home: ViewSummaryScreen(
          mapboxAccessToken: 'pk.summary-test-token',
          mapboxBuilder: (context, config) {
            return ColoredBox(
              key: Key(
                config.isExpanded
                    ? 'fake_summary_mapbox_expanded'
                    : 'fake_summary_mapbox_preview',
              ),
              color: Colors.black,
            );
          },
          summary: RunSummarySnapshot(
            title: 'Expanded Route Run',
            dateLabel: 'Today',
            timeLabel: '8:10 AM',
            distanceKm: '0.30',
            avgPace: '6’40”',
            duration: '2:00',
            avgHeartRate: '--',
            calories: '27',
            routeName: 'Actual Local Route',
            route: RunRouteSnapshot(
              segments: [
                [
                  RunLocationSample(
                    recordedAt: startedAt,
                    latitude: 1.300000,
                    longitude: 103.800000,
                  ),
                  RunLocationSample(
                    recordedAt: startedAt.add(const Duration(seconds: 60)),
                    latitude: 1.300899,
                    longitude: 103.800000,
                  ),
                ],
              ],
              lastKnownLocation: RunLocationSample(
                recordedAt: startedAt.add(const Duration(seconds: 60)),
                latitude: 1.300899,
                longitude: 103.800000,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('summary_route_preview_tap_target')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('summary_route_expanded_screen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('fake_summary_mapbox_expanded')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('summary_route_expanded_close')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('summary_route_expanded_screen')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('fake_summary_mapbox_preview')),
      findsOneWidget,
    );
  });

  testWidgets(
    'View summary shows unavailable completion metrics without fake units',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: ViewSummaryScreen(
            completionResult: CompleteRunResult(
              activityId: 'unavailable-metrics-activity',
              summaryId: 'unavailable-metrics-summary',
              progressionEventId: 'unavailable-metrics-progression',
              validationStatus: 'validated',
              summary: RunSummarySnapshot(
                title: 'Tracked Completion Run',
                dateLabel: 'Today',
                timeLabel: '8:10 AM',
                distanceKm: '3.20',
                avgPace: '7’49”',
                duration: '25:00',
                avgHeartRate: '--',
                calories: '--',
                routeName: 'Tracked Private Route',
              ),
              progressionDisplay: ProgressionDisplayModel(
                xpDelta: 0,
                countsTowardLeaderboard: false,
                status: 'deferred',
                reason: 'progression_formula_deferred',
              ),
              xpUpdate: XpUpdateDisplayModel(
                runnerName: 'Runiac Runner',
                earnedXpLabel: '+0 XP',
                totalXpLabel: 'Deferred by backend',
                levelLabel: 'Pending',
                nextLevelLabel: 'Pending',
                progressTargetLabel: 'Progression deferred',
                xpRemainingLabel: 'Backend formula pending',
                previousProgressFraction: 0,
                currentProgressFraction: 0,
                streakChangeLabel: 'Deferred',
                streakNote: 'Backend validation accepted the run.',
                didLevelUp: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tracked Completion Run'), findsOneWidget);
      expect(find.text('Tracked Private Route'), findsNothing);
      expect(find.text('3.20'), findsOneWidget);
      expect(find.text('7’49”'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Est. calories'), findsOneWidget);
      expect(find.text('--'), findsNWidgets(2));
      expect(find.text('-- bpm'), findsNothing);
      expect(find.text('-- kcal'), findsNothing);
      expect(find.text('145 bpm'), findsNothing);
      expect(find.text('145 kcal'), findsNothing);
    },
  );

  testWidgets('Summary shows truthful heart rate source states', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ViewSummaryScreen(
          summary: RunSummarySnapshot(
            title: 'Local GPS Run',
            dateLabel: 'Today',
            timeLabel: '8:10 AM',
            distanceKm: '3.20',
            avgPace: '7’49”',
            duration: '25:00',
            avgHeartRate: '--',
            calories: '270',
            routeName: 'Private route',
          ),
        ),
      ),
    );

    expect(find.text('Runiac GPS'), findsOneWidget);
    expect(find.text('Avg Heart Rate'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);
    expect(find.text('-- bpm'), findsNothing);
    expect(
      find.text('Heart rate unavailable for Runiac GPS runs.'),
      findsNothing,
    );
    expect(
      find.text('Heart rate was not shared by this source.'),
      findsNothing,
    );
    expect(find.text('Pace Over Time'), findsOneWidget);
    expect(find.text('Advanced Analysis'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: ViewSummaryScreen(
          summary: RunSummarySnapshot(
            title: 'Imported Watch Run',
            dateLabel: 'Today',
            timeLabel: '8:10 AM',
            distanceKm: '5.12',
            avgPace: '6’45”',
            duration: '34:32',
            avgHeartRate: '145',
            calories: '312',
            routeName: 'Imported route',
            sourceType: RunSourceType.appleHealth,
            heartRateAvailability: HeartRateAvailability.available,
          ),
        ),
      ),
    );

    expect(find.text('Apple Health'), findsOneWidget);
    expect(find.text('145 bpm'), findsOneWidget);
    expect(
      find.text('Heart rate unavailable for Runiac GPS runs.'),
      findsNothing,
    );
    expect(
      find.text('Heart rate was not shared by this source.'),
      findsNothing,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ViewSummaryScreen(
          summary: RunSummarySnapshot(
            title: 'Imported No HR Run',
            dateLabel: 'Today',
            timeLabel: '8:10 AM',
            distanceKm: '4.03',
            avgPace: '6’30”',
            duration: '30:15',
            avgHeartRate: '--',
            calories: '242',
            routeName: 'Imported route',
            sourceType: RunSourceType.healthConnect,
            heartRateAvailability: HeartRateAvailability.unavailableNotShared,
          ),
        ),
      ),
    );

    expect(find.text('Health Connect'), findsOneWidget);
    expect(find.text('Avg Heart Rate'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);
    expect(find.text('-- bpm'), findsNothing);
    expect(
      find.text('Heart rate was not shared by this source.'),
      findsNothing,
    );
    expect(
      find.text('Heart rate unavailable for Runiac GPS runs.'),
      findsNothing,
    );
  });

  testWidgets('Low-data view summary softens copy and hides bottom actions', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ViewSummaryScreen(
          completionResult: CompleteRunResult(
            activityId: 'low-data-activity',
            summaryId: 'low-data-summary',
            progressionEventId: 'low-data-progression',
            validationStatus: 'validated',
            summary: RunSummarySnapshot(
              title: 'Short Start',
              dateLabel: 'Today',
              timeLabel: '8:10 AM',
              distanceKm: '0.02',
              avgPace: '--',
              duration: '0:35',
              avgHeartRate: '--',
              calories: '--',
              routeName: 'Easy local route',
              hasSufficientData: false,
              coachingSummary: CoachingSummarySnapshot(
                source: CoachingSummarySource.ruleBased,
                headline: 'Thanks for getting out there',
                message:
                    'This run has limited run data, so the summary stays simple. Your effort still counts.',
                bullets: [
                  'Use it as a gentle check-in, not a full run analysis.',
                ],
                nextAction: 'Try one short easy run with GPS ready.',
              ),
            ),
            progressionDisplay: ProgressionDisplayModel(
              xpDelta: 0,
              countsTowardLeaderboard: false,
              status: 'deferred',
              reason: 'progression_formula_deferred',
            ),
            xpUpdate: XpUpdateDisplayModel(
              runnerName: 'Runiac Runner',
              earnedXpLabel: '+0 XP',
              totalXpLabel: 'Deferred by backend',
              levelLabel: 'Pending',
              nextLevelLabel: 'Pending',
              progressTargetLabel: 'Progression deferred',
              xpRemainingLabel: 'Backend formula pending',
              previousProgressFraction: 0,
              currentProgressFraction: 0,
              streakChangeLabel: 'Deferred',
              streakNote: 'Backend validation accepted the run.',
              didLevelUp: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Short Start'), findsOneWidget);
    expect(find.text('0.02'), findsOneWidget);
    expect(find.text('0:35'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(3));
    expect(find.text('Coaching Summary'), findsOneWidget);
    expect(find.text('AI Coaching Summary'), findsNothing);
    expect(
      find.text(
        'This run has limited run data, so the summary stays simple. Your effort still counts.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('steady pace'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Share Route'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsNothing);
  });

  testWidgets('low-data Summary guards hardcoded analysis graphs', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ViewSummaryScreen(
          completionResult: CompleteRunResult(
            activityId: 'low-data-analysis-activity',
            summaryId: 'low-data-analysis-summary',
            progressionEventId: 'low-data-analysis-progression',
            validationStatus: 'validated',
            summary: RunSummarySnapshot(
              title: 'Short Start',
              dateLabel: 'Today',
              timeLabel: '8:10 AM',
              distanceKm: '0.02',
              avgPace: '--',
              duration: '0:35',
              avgHeartRate: '--',
              calories: '--',
              routeName: 'Easy local route',
              hasSufficientData: false,
            ),
            progressionDisplay: ProgressionDisplayModel(
              xpDelta: 0,
              countsTowardLeaderboard: false,
              status: 'deferred',
              reason: 'progression_formula_deferred',
            ),
            xpUpdate: XpUpdateDisplayModel(
              runnerName: 'Runiac Runner',
              earnedXpLabel: '+0 XP',
              totalXpLabel: 'Deferred by backend',
              levelLabel: 'Pending',
              nextLevelLabel: 'Pending',
              progressTargetLabel: 'Progression deferred',
              xpRemainingLabel: 'Backend formula pending',
              previousProgressFraction: 0,
              currentProgressFraction: 0,
              streakChangeLabel: 'Deferred',
              streakNote: 'Backend validation accepted the run.',
              didLevelUp: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Pace Over Time'), findsOneWidget);
    expect(find.text('Advanced Analysis'), findsOneWidget);
    expect(find.text('More run data needed'), findsNWidgets(2));
    expect(
      find.text('Pace insights will appear after a longer run.'),
      findsNWidgets(2),
    );
    expect(find.text('Performance Overview'), findsNothing);

    await tester.ensureVisible(
      find.widgetWithText(OutlinedButton, 'More Details'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'More Details'));
    await tester.pumpAndSettle();

    expect(
      find.text('Run a little longer to unlock analysis.'),
      findsOneWidget,
    );
    expect(find.text('Performance Overview'), findsNothing);
    expect(find.byType(AdvancedAnalysisScreen), findsNothing);
  });

  testWidgets(
    'fixture-backed pace graph can render filtered spike run labels',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: ViewSummaryScreen(
            summary: defaultRunSummarySnapshot.copyWith(
              paceGraph: gpsSpikeRunPaceGraph,
            ),
          ),
        ),
      );

      expect(find.text('Pace Over Time'), findsOneWidget);
      expect(find.text('0:00'), findsOneWidget);
      expect(find.text('8:00'), findsOneWidget);
      expect(find.text('16:00'), findsOneWidget);
      expect(find.text('24:10'), findsOneWidget);
      expect(find.text('1:20'), findsNothing);
      expect(find.text('45:00'), findsNothing);
      expect(find.text('More run data needed'), findsNothing);
    },
  );

  testWidgets(
    'View summary share icon opens Share Your Achievement bottom sheet',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);
      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      expect(find.byTooltip('Share summary'), findsOneWidget);
      expect(find.text('Share Your Achievement'), findsNothing);

      await tester.tap(find.byTooltip('Share summary'));
      await tester.pumpAndSettle();

      expect(find.text('Saturday Morning Run'), findsWidgets);
      expect(find.text('Share Your Achievement'), findsOneWidget);
    },
  );

  testWidgets(
    'Share achievement sheet renders static preview metrics and actions',
    (WidgetTester tester) async {
      _useCompactShareSheetSurface(tester);
      await tester.pumpWidget(_shareSheetHarness());

      await tester.tap(find.text('Open share sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Share Your Achievement'), findsOneWidget);
      expect(find.text('4.03'), findsWidgets);
      expect(find.text('km'), findsWidgets);
      expect(find.text('6\'30"'), findsOneWidget);
      expect(find.text('Avg pace'), findsOneWidget);
      expect(find.text('30:15'), findsWidgets);
      expect(find.text('Time'), findsWidgets);
      expect(find.text('Avg HR'), findsOneWidget);
      expect(find.text('145'), findsWidgets);
      expect(find.text('Calories'), findsWidgets);
      expect(find.text('Edit card'), findsOneWidget);
      expect(find.text('Change theme'), findsOneWidget);
      expect(find.text('Instagram Stories'), findsOneWidget);
      expect(find.text('Copy Image'), findsOneWidget);
      expect(find.text('Save Image'), findsOneWidget);
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('More'), findsWidgets);
      expect(
        find.image(const AssetImage('assets/icons/instagram_stories.png')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ShareAchievementSheet),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Copy Image'));
      await tester.pump();

      expect(
        find.text('Preview only. Image copying is not connected yet.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Share achievement sheet close dismisses without leaving summary',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);
      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      await tester.tap(find.byTooltip('Share summary'));
      await tester.pumpAndSettle();

      expect(find.text('Share Your Achievement'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();

      expect(find.text('Share Your Achievement'), findsNothing);
      expect(find.text('Saturday Morning Run'), findsOneWidget);
      expect(find.text('Run saved'), findsNothing);
    },
  );

  testWidgets('Advanced Analysis renders handoff sections and sample values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdvancedAnalysisScreen()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, RuniacColors.background);

    expect(find.text('Saturday Morning Run'), findsOneWidget);
    expect(find.text('Today · 7:06 AM'), findsOneWidget);
    expect(find.text('Performance Overview'), findsOneWidget);
    expect(find.text('82'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);
    expect(find.text('Good steady effort'), findsOneWidget);
    expect(find.text('Stable Pace'), findsOneWidget);
    expect(find.text('Controlled HR'), findsOneWidget);
    expect(find.text('Good Endurance'), findsOneWidget);

    expect(find.text('Pace Analysis'), findsOneWidget);
    expect(find.text('6’30”'), findsOneWidget);
    expect(find.text('5’58”'), findsOneWidget);
    expect(find.text('7’05”'), findsOneWidget);
    expect(find.text('86'), findsOneWidget);
    expect(find.text('1 km'), findsOneWidget);
    expect(find.text('4.03 km'), findsOneWidget);

    await tester.ensureVisible(find.text('Heart Rate Analysis'));

    expect(find.text('Heart Rate Analysis'), findsOneWidget);
    expect(find.text('145'), findsOneWidget);
    expect(find.text('158'), findsOneWidget);
    expect(find.text('130–150'), findsOneWidget);
    expect(find.text('72'), findsOneWidget);
    expect(find.text('Zone 2 Aerobic'), findsOneWidget);

    await tester.ensureVisible(find.text('Recovery Recommendation'));

    expect(find.text('Effort & Intensity'), findsOneWidget);
    expect(find.text('88% · Good'), findsOneWidget);
    expect(find.text('Elevation Analysis'), findsOneWidget);
    expect(find.text('+12'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('Mostly Flat'), findsOneWidget);
    expect(find.text('Running Form / Cadence'), findsOneWidget);
    expect(find.text('164'), findsOneWidget);
    expect(find.text('160–175'), findsOneWidget);
    expect(find.text('Recovery Recommendation'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('5–8 min'), findsOneWidget);
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('Ready in 24 hours'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'View Recommended Stretches'),
      findsOneWidget,
    );
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);
  });

  testWidgets(
    'View summary removes run complete banner while keeping summary content visible',
    (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      expect(find.text('Run complete'), findsNothing);
      expect(find.text('4.03'), findsOneWidget);
      expect(find.text('Pace Over Time'), findsOneWidget);
      expect(find.text('East Coast Park Loop'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('View XP Update opens reward screen and Go Home exits it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'View XP Update'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'View XP Update'));
    await tester.pumpAndSettle();

    expect(find.text('XP & Streak Update'), findsOneWidget);
    expect(find.text('Nice work, Jinseo!'), findsOneWidget);
    expect(find.text('+120 XP'), findsOneWidget);
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('2,520 XP'), findsOneWidget);
    expect(find.text('5 \u2192 6 days'), findsOneWidget);
    expect(find.text('Great consistency!'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Go Home'), findsOneWidget);
    expect(
      find.textContaining(_forbiddenXpUpdateCompetitiveCopy),
      findsNothing,
    );

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Go Home'));
    await tester.tap(find.widgetWithText(FilledButton, 'Go Home'));
    await tester.pumpAndSettle();

    expect(find.text('XP & Streak Update'), findsNothing);
    expect(find.text('Saturday Morning Run'), findsOneWidget);
  });

  testWidgets('XP Update renders supplied backend-ready display model values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: XpUpdateScreen(
          model: XpUpdateDisplayModel(
            runnerName: 'Maya',
            earnedXpLabel: '+80 XP',
            totalXpLabel: '1,840 XP',
            levelLabel: '9',
            nextLevelLabel: '10',
            progressTargetLabel: 'Progress to Lv.10',
            xpRemainingLabel: '220 XP to go',
            previousProgressFraction: 0.41,
            currentProgressFraction: 0.49,
            streakChangeLabel: '2 \u2192 3 days',
            streakNote: 'Steady return!',
            didLevelUp: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nice work, Maya!'), findsOneWidget);
    expect(find.text('+80 XP'), findsOneWidget);
    expect(find.text('1,840 XP'), findsOneWidget);
    expect(find.text('Lv.9'), findsOneWidget);
    expect(find.text('Progress to Lv.10'), findsOneWidget);
    expect(find.text('220 XP to go'), findsOneWidget);
    expect(find.text('2 \u2192 3 days'), findsOneWidget);
    expect(find.text('Steady return!'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Go Home'), findsOneWidget);
    expect(find.text('Nice work, Jinseo!'), findsNothing);
    expect(find.text('+120 XP'), findsNothing);
    expect(
      find.textContaining(_forbiddenXpUpdateCompetitiveCopy),
      findsNothing,
    );
  });

  testWidgets('XP Update source stays display-only and backend free', (
    WidgetTester tester,
  ) async {
    final screenSource = File(
      'lib/features/run/presentation/xp_update_screen.dart',
    ).readAsStringSync();
    final modelSource = File(
      'lib/features/run/domain/models/xp_update_display_model.dart',
    ).readAsStringSync();

    expect(modelSource, contains('class XpUpdateDisplayModel'));
    expect(
      screenSource,
      contains('../domain/models/xp_update_display_model.dart'),
    );
    expect(screenSource, isNot(contains('class RunReward')));
    expect(modelSource, isNot(contains('class RunReward')));
    expect(screenSource, isNot(contains('_demoReward')));
    expect(modelSource, isNot(contains('_demoReward')));
    for (final forbidden in [
      'calculateXP',
      'calculateXp',
      'calculateLevel',
      'calculateStreak',
      'Firebase',
      'firebase',
      'Firestore',
      'Auth',
      'SharedPreferences',
    ]) {
      expect(screenSource, isNot(contains(forbidden)));
      expect(modelSource, isNot(contains(forbidden)));
    }
    for (final forbiddenCall in [
      RegExp(r'\bcollection\s*\('),
      RegExp(r'\bdoc\s*\('),
      RegExp(r'\bset\s*\('),
      RegExp(r'\bupdate\s*\('),
    ]) {
      expect(screenSource, isNot(contains(forbiddenCall)));
      expect(modelSource, isNot(contains(forbiddenCall)));
    }
  });

  testWidgets(
    'View summary scrolls with local clamping no-overscroll behavior',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      final localNoOverscrollConfiguration = find.byWidgetPredicate(
        (widget) =>
            widget is ScrollConfiguration &&
            widget.behavior.runtimeType.toString() == '_NoOverscrollBehavior',
      );

      expect(scrollView.physics, isA<ClampingScrollPhysics>());
      expect(localNoOverscrollConfiguration, findsOneWidget);

      final scrollConfiguration = tester.widget<ScrollConfiguration>(
        localNoOverscrollConfiguration,
      );
      expect(
        scrollConfiguration.behavior.getScrollPhysics(
          tester.element(find.byType(SingleChildScrollView)),
        ),
        isA<ClampingScrollPhysics>(),
      );

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(find.text('View XP Update'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Cool down page fits compact screens without scroll containers', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 667);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CoolDownScreen()));

    expect(find.text('Cool down'), findsOneWidget);
    expect(find.text('Start Cool-down'), findsOneWidget);
    expect(find.text('Skip to Summary'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Cool-down'));
    await tester.pumpAndSettle();

    expect(find.text('Cool down guide'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Slow Walk'), findsOneWidget);
    expect(find.text('Walk slowly to lower your heart rate.'), findsOneWidget);
    expect(find.text('Keep your breathing relaxed.'), findsOneWidget);
    expect(find.text('Walk at an easy pace.'), findsOneWidget);
    expect(
      find.text('Let your heart rate come down gradually.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);
  });

  testWidgets('Cool down guide supports walk pause stretch and finish states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CoolDownGuideScreen(timerEnabled: false)),
    );

    expect(find.text('Cool down guide'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('REMAINING'), findsOneWidget);
    expect(find.text('Slow Walk'), findsOneWidget);
    expect(find.text('Walk slowly to lower your heart rate.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Tips'), findsOneWidget);
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Stretch'));
    await tester.pumpAndSettle();

    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('Slow Walk'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('Slow Walk'), findsNothing);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);
    expect(find.byTooltip('Resume'), findsOneWidget);

    await tester.tap(find.text('Walk'));
    await tester.pumpAndSettle();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: CoolDownGuideScreen(timerEnabled: true, initialSecondsLeft: 1),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Walk complete'), findsOneWidget);
    expect(find.byTooltip('Pause'), findsNothing);
    expect(find.text('Gentle Stretch'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: CoolDownGuideScreen(timerEnabled: false, initialSecondsLeft: 0),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Walk complete'), findsOneWidget);
    expect(
      find.text('Nicely done. Let’s move into some gentle stretching.'),
      findsOneWidget,
    );
    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('5 min · gentle recovery'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Stretch'));
    await tester.pumpAndSettle();

    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Walk complete'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('Ease through each stretch and breathe.'), findsOneWidget);
    expect(find.text('Stretch slowly — never bounce.'), findsOneWidget);
    expect(find.text('Keep your breathing steady.'), findsOneWidget);
    expect(find.text('Stop if anything feels sharp.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('Saturday Morning Run'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: CoolDownGuideScreen(
          timerEnabled: false,
          initialPhase: CoolDownPhase.stretch,
          initialSecondsLeft: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cool-down complete'), findsOneWidget);
    expect(
      find.text('That’s your recovery done. Great work today.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Finish'), findsOneWidget);
    expect(find.text('UP NEXT'), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Saturday Morning Run'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsOneWidget);
    expect(find.text('XP & Streak Update'), findsNothing);
  });

  test('Run launch source isolates static display snapshots', () {
    final source = File(
      'lib/features/run/presentation/run_launch_screen.dart',
    ).readAsStringSync();
    final activeSource = File(
      'lib/features/run/presentation/run_active_screen.dart',
    ).readAsStringSync();
    final trackingSheetSource = File(
      'lib/features/run/presentation/widgets/run_tracking_sheet_content.dart',
    ).readAsStringSync();
    final snapshotSource = File(
      'lib/features/run/presentation/data/run_launch_demo_snapshots.dart',
    ).readAsStringSync();

    expect(source, contains('data/run_launch_demo_snapshots.dart'));
    expect(source, contains('runLaunchDemoSnapshot'));
    expect(source, contains('RunTrackingController'));
    expect(source, contains('RunSheetMode'));
    expect(source, isNot(contains('RunActiveScreen')));
    expect(
      source,
      isNot(
        contains(
          'MaterialPageRoute<void>(builder: (context) => const RunActiveScreen())',
        ),
      ),
    );
    expect(activeSource, contains('RunTrackingController'));
    expect(activeSource, contains('RunTrackingSheetContent'));
    expect(trackingSheetSource, contains('RunTrackingSnapshot'));
    expect(trackingSheetSource, contains('run_plan_progress_bar'));
    expect(source, isNot(contains('class _RunLaunchDisplaySnapshot')));
    expect(source, isNot(contains('class _RunLiveDisplaySnapshot')));
    expect(snapshotSource, contains('class RunLaunchDemoSnapshot'));
    expect(snapshotSource, contains('class RunLiveDemoSnapshot'));
    expect(snapshotSource, contains('const runLaunchDemoSnapshot'));
    expect(snapshotSource, contains('const runLiveDemoSnapshot'));
    expect(source, isNot(contains(RegExp(r'\bonCompleted\b'))));
    expect(source, isNot(contains('bool _completed')));
    expect(source, isNot(contains('completedRun')));
    expect(source, isNot(contains('calculateRunCompletion')));
    expect(source, isNot(contains('saveActivity')));
  });

  testWidgets('Android back dismisses static Run launch surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Maps'));
    await tester.pumpAndSettle();
    expect(find.text('Shared Routes'), findsOneWidget);

    await tester.tap(find.byTooltip('Run'));
    await tester.pumpAndSettle();
    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('Maps'), findsNothing);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.text('Demo mode'), findsNothing);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Maps'), findsOneWidget);
    expect(find.byTooltip('Run'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('You'), findsOneWidget);
  });
}
