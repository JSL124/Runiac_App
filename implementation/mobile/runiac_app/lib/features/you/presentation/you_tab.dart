import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../run/domain/models/run_activity_display_model.dart';
import '../../run/presentation/view_summary_screen.dart';
import 'activity_history_screen.dart';
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
  const YouTab({super.key});

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
  var _workoutDetailSnapshot = weeklyWorkoutDetailSnapshot;
  var _visibleCalendarMonth = DateTime(2026, 5);

  @override
  Widget build(BuildContext context) {
    if (_activityHistoryVisible) {
      return ActivityHistoryScreen(
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
                    onViewGoalPlan: _showGoalPlanDetail,
                    onViewWorkout: _showWorkoutDetail,
                    onViewExpertPlans: _showExpertPlanList,
                  )
                else
                  YouProgressSurface(
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
        builder: (context) =>
            ViewSummaryScreen(summary: run.summary, showXpUpdateAction: false),
      ),
    );
  }
}
