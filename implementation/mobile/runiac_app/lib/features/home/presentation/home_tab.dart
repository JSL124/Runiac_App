import 'package:flutter/material.dart';

import 'widgets/goal_preparation_card.dart';
import 'widgets/home_header.dart';
import 'widgets/last_run_card.dart';
import 'widgets/post_run_feedback_card.dart';
import 'widgets/recommended_routes_card.dart';
import 'widgets/runner_progress_card.dart';
import 'widgets/today_plan_card.dart';
import 'widgets/weekly_plan_card.dart';

const _homeScreenBackground = Color(0xFFF7F9FD);

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

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
            children: const [
              HomeHeader(),
              SizedBox(height: 12),
              TodayPlanCard(),
              SizedBox(height: 10),
              GoalPreparationCard(),
              SizedBox(height: 10),
              RunnerProgressCard(),
              SizedBox(height: 10),
              WeeklyPlanCard(),
              SizedBox(height: 10),
              LastRunCard(),
              SizedBox(height: 10),
              PostRunFeedbackCard(),
              SizedBox(height: 10),
              RecommendedRoutesCard(),
            ],
          ),
        ),
      ),
    );
  }
}
