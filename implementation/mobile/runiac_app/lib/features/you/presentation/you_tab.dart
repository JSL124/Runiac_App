import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../run/domain/models/run_activity_display_model.dart';
import '../../run/presentation/active_run_session_coordinator.dart';
import '../../run/presentation/view_summary_screen.dart';
import '../data/static_activity_history_repository.dart';
import '../domain/repositories/activity_history_repository.dart';
import '../../plan/presentation/current_session_generated_plan.dart';
import 'activity_history_display_controller.dart';
import 'activity_history_screen.dart';
import 'current_session_activity_history.dart';
import 'adapters/generated_plan_you_display_adapter.dart';
import 'data/weekly_workout_demo_snapshots.dart';
import 'expert_plan_detail_screen.dart';
import 'expert_plan_list_screen.dart';
import 'goal_plan_detail_screen.dart';
import 'weekly_workout_detail_screen.dart';
import 'widgets/you_header_overlay.dart';
import 'widgets/you_plans_surface.dart';
import 'widgets/you_progress_surface.dart';
import 'widgets/you_segmented_control.dart';

class YouTab extends StatefulWidget {
  const YouTab({
    super.key,
    this.activityHistoryRepository = const StaticActivityHistoryRepository(),
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
  });

  final ActivityHistoryRepository activityHistoryRepository;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;

  @override
  State<YouTab> createState() => _YouTabState();
}

class _YouTabState extends State<YouTab> {
  var _plans = false;
  var _expertPlanListVisible = false;
  var _expertPlanDetailVisible = false;
  var _goalPlanDetailVisible = false;
  var _workoutDetailVisible = false;
  var _activityHistoryVisible = false;
  late ActivityHistoryDisplayController _activityHistoryController;
  var _workoutDetailSnapshot = weeklyWorkoutDetailSnapshot;
  var _visibleCalendarMonth = DateTime(2026, 5);

  @override
  void initState() {
    super.initState();
    _activityHistoryController = ActivityHistoryDisplayController(
      repository: widget.activityHistoryRepository,
    )..addListener(_handleActivityHistoryChanged);
    _activityHistoryController.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activityHistoryController.attachActivityHistoryStore(
      CurrentSessionActivityHistoryScope.of(context),
    );
  }

  @override
  void didUpdateWidget(covariant YouTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activityHistoryRepository !=
        widget.activityHistoryRepository) {
      _activityHistoryController
        ..removeListener(_handleActivityHistoryChanged)
        ..dispose();
      _activityHistoryController = ActivityHistoryDisplayController(
        repository: widget.activityHistoryRepository,
      )..addListener(_handleActivityHistoryChanged);
      _activityHistoryController.attachActivityHistoryStore(
        CurrentSessionActivityHistoryScope.of(context),
      );
      _activityHistoryController.load();
    }
  }

  @override
  void dispose() {
    _activityHistoryController
      ..removeListener(_handleActivityHistoryChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityHistoryStore = CurrentSessionActivityHistoryScope.of(context);
    final recentRuns = _activityHistoryController.recentRuns(
      activityHistoryStore,
    );
    final activityHistoryMonths = _activityHistoryController.months(
      activityHistoryStore,
    );
    final generatedPlanStore = CurrentSessionGeneratedPlanScope.of(context);
    final generatedPlanDisplay = generatedYouPlanDisplayFromSnapshot(
      generatedPlanStore.activePlan,
    );
    final safetyReadinessDisplay = safetyReadinessYouPlanDisplayFromSnapshot(
      generatedPlanStore.activePlan,
    );

    if (_activityHistoryVisible) {
      return ActivityHistoryScreen(
        activityHistoryMonths: activityHistoryMonths,
        loadFailed: _activityHistoryController.loadFailed,
        onRetryLoad: () {
          _activityHistoryController.load();
        },
        onBack: () {
          setState(() => _activityHistoryVisible = false);
        },
        onActivitySelected: _showRunSummary,
      );
    }

    if (_workoutDetailVisible) {
      return WeeklyWorkoutDetailScreen(
        snapshot: _workoutDetailSnapshot,
        onBack: () {
          setState(() => _workoutDetailVisible = false);
        },
        enableForegroundGps: widget.enableForegroundGps,
        activeRunSessionCoordinator: widget.activeRunSessionCoordinator,
      );
    }

    if (_goalPlanDetailVisible) {
      return GoalPlanDetailScreen(
        onBack: () {
          setState(() => _goalPlanDetailVisible = false);
        },
      );
    }

    if (_expertPlanDetailVisible) {
      return ExpertPlanDetailScreen(
        onBack: () {
          setState(() => _expertPlanDetailVisible = false);
        },
      );
    }

    if (_expertPlanListVisible) {
      return ExpertPlanListScreen(
        onBack: () {
          setState(() => _expertPlanListVisible = false);
        },
        onFirstPlanSelected: _showExpertPlanDetail,
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top;
    final headerHeight = topPadding + kToolbarHeight;

    return ColoredBox(
      color: RuniacColors.background,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(overscroll: false),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, headerHeight + 8, 16, 28),
              children: [
                YouSegmentedControl(
                  labels: const ['Progress', 'Plans'],
                  selected: _plans ? 1 : 0,
                  onTap: (index) {
                    setState(() => _plans = index == 1);
                  },
                ),
                const SizedBox(height: 12),
                if (_plans)
                  YouPlansSurface(
                    generatedPlan: generatedPlanDisplay,
                    safetyReadinessPlan: safetyReadinessDisplay,
                    onViewGoalPlan: _showGoalPlanDetail,
                    onViewWorkout: _showWorkoutDetail,
                    onViewExpertPlans: _showExpertPlanList,
                  )
                else
                  YouProgressSurface(
                    runs: recentRuns,
                    visibleCalendarMonth: _visibleCalendarMonth,
                    onPreviousMonth: _showPreviousCalendarMonth,
                    onNextMonth: _showNextCalendarMonth,
                    onRunSelected: _showRunSummary,
                    onMoreActivities: _showActivityHistory,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: const YouHeaderOverlay(),
          ),
        ],
      ),
    );
  }

  void _showPreviousCalendarMonth() {
    setState(() {
      _visibleCalendarMonth = DateTime(
        _visibleCalendarMonth.year,
        _visibleCalendarMonth.month - 1,
      );
    });
  }

  void _showNextCalendarMonth() {
    setState(() {
      _visibleCalendarMonth = DateTime(
        _visibleCalendarMonth.year,
        _visibleCalendarMonth.month + 1,
      );
    });
  }

  void _showGoalPlanDetail() {
    setState(() => _goalPlanDetailVisible = true);
  }

  void _showWorkoutDetail(WeeklyWorkoutDetailSnapshot snapshot) {
    setState(() {
      _workoutDetailSnapshot = snapshot;
      _workoutDetailVisible = true;
    });
  }

  void _showExpertPlanList() {
    setState(() => _expertPlanListVisible = true);
  }

  void _showExpertPlanDetail() {
    setState(() => _expertPlanDetailVisible = true);
  }

  void _showActivityHistory() {
    setState(() => _activityHistoryVisible = true);
  }

  void _showRunSummary(RunActivityDisplayModel run) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ViewSummaryScreen(
          completionResult: run.completionResult,
          summary: run.summary,
          showXpUpdateAction: false,
        ),
      ),
    );
  }

  void _handleActivityHistoryChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
