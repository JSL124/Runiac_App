import 'package:flutter/material.dart';

import '../../run/presentation/run_launch_screen.dart';
import '../../you/presentation/weekly_workout_detail_screen.dart';
import 'widgets/goal_preparation_card.dart';
import 'widgets/home_header.dart';
import 'widgets/last_run_card.dart';
import 'widgets/post_run_feedback_card.dart';
import 'widgets/recommended_routes_card.dart';
import 'widgets/runner_progress_card.dart';
import 'widgets/today_plan_card.dart';
import 'widgets/weekly_plan_card.dart';

const _homeScreenBackground = Colors.white;

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _showPreviewMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTodayWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return WeeklyWorkoutDetailScreen(
            onBack: () => Navigator.of(context).pop(),
            showEditScheduleAction: false,
          );
        },
      ),
    );
  }

  void _openQuickStart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const RunLaunchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: _homeScreenBackground,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              HomeHeader(
                onNotifications: () => _showPreviewMessage(
                  context,
                  'Notifications preview is coming soon.',
                ),
                onProfile: () => _showPreviewMessage(
                  context,
                  'Profile settings preview is coming soon.',
                ),
              ),
              const SizedBox(height: 12),
              TodayPlanCard(
                onViewPlan: () => _openTodayWorkout(context),
                onQuickStart: () => _openQuickStart(context),
              ),
              const SizedBox(height: 10),
              const GoalPreparationCard(),
              const SizedBox(height: 10),
              const RunnerProgressCard(),
              const SizedBox(height: 10),
              const WeeklyPlanCard(),
              const SizedBox(height: 10),
              const LastRunCard(),
              const SizedBox(height: 10),
              const PostRunFeedbackCard(),
              const SizedBox(height: 10),
              const RecommendedRoutesCard(),
            ],
          ),
        ),
      ),
    );
  }
}
