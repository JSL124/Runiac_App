import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../adapters/generated_plan_you_display_adapter.dart';
import '../data/weekly_workout_demo_snapshots.dart';
import '../data/you_overview_demo_snapshots.dart';
import 'weekly_plan_day_row.dart';
import 'you_surface_primitives.dart';

class GeneratedWeeklyPlanCard extends StatelessWidget {
  const GeneratedWeeklyPlanCard({
    required this.plan,
    required this.onViewWorkout,
    super.key,
  });

  final GeneratedYouPlanDisplay plan;
  final ValueChanged<WeeklyWorkoutDetailSnapshot> onViewWorkout;

  @override
  Widget build(BuildContext context) {
    return YouDividerSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: YouCardHeader(
                  Icons.calendar_today_outlined,
                  plan.weeklyTitle,
                  iconSize: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                plan.progressLabel,
                style: YouTextStyles.weeklyPlanProgressLabel,
              ),
            ],
          ),
          if (plan.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(plan.subtitle, style: YouTextStyles.body),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              value: plan.progressValue,
              minHeight: 7,
              backgroundColor: RuniacColors.primaryBlue.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation(
                RuniacColors.accentOrange,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: RuniacColors.primaryBlue.withValues(alpha: 0.10),
          ),
          const SizedBox(height: 4),
          for (var index = 0; index < plan.scheduleRows.length; index++)
            WeeklyPlanDayRow(
              plan.scheduleRows[index],
              showDivider: index > 0,
              onTap: _workoutDetailTap(plan.scheduleRows[index]),
            ),
        ],
      ),
    );
  }

  VoidCallback? _workoutDetailTap(YouPlanScheduleRow row) {
    final detailSnapshot = row.detailSnapshot;
    if (!row.canOpenDetail ||
        !row.opensWorkoutDetail ||
        detailSnapshot == null) {
      return null;
    }

    return () => onViewWorkout(detailSnapshot);
  }
}
