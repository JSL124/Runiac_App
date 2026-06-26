import 'package:flutter/material.dart';

import '../adapters/generated_plan_you_display_adapter.dart';
import '../data/weekly_workout_demo_snapshots.dart';
import 'current_goal_plan_card.dart';
import 'expert_plans_entry_card.dart';
import 'generated_weekly_plan_card.dart';
import 'weekly_plan_card.dart';
import 'you_surface_primitives.dart';

class YouPlansSurface extends StatelessWidget {
  const YouPlansSurface({
    required this.onViewGoalPlan,
    required this.onViewWorkout,
    required this.onViewExpertPlans,
    this.generatedPlan,
    super.key,
  });

  final VoidCallback onViewGoalPlan;
  final ValueChanged<WeeklyWorkoutDetailSnapshot> onViewWorkout;
  final VoidCallback onViewExpertPlans;
  final GeneratedYouPlanDisplay? generatedPlan;

  @override
  Widget build(BuildContext context) {
    final plan = generatedPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RuniacAccentStrip(),
        const SizedBox(height: 12),
        if (plan == null) ...[
          CurrentGoalPlanCard(onViewGoalPlan: onViewGoalPlan),
          const SizedBox(height: 12),
          WeeklyPlanCard(onViewWorkout: onViewWorkout),
        ] else
          GeneratedWeeklyPlanCard(plan: plan, onViewWorkout: onViewWorkout),
        const SizedBox(height: 12),
        ExpertPlansEntryCard(onViewExpertPlans: onViewExpertPlans),
      ],
    );
  }
}
