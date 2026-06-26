import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../adapters/generated_plan_you_display_adapter.dart';
import '../data/weekly_workout_demo_snapshots.dart';
import '../data/you_overview_demo_snapshots.dart';
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
            _GeneratedPlanDayRow(
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
    if (!row.opensWorkoutDetail || detailSnapshot == null) {
      return null;
    }

    return () => onViewWorkout(detailSnapshot);
  }
}

class _GeneratedPlanDayRow extends StatelessWidget {
  const _GeneratedPlanDayRow(
    this.display, {
    required this.showDivider,
    this.onTap,
  });

  final YouPlanScheduleRow display;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: tappable
            ? RuniacColors.primaryBlue.withValues(alpha: 0.06)
            : null,
        border: showDivider && !tappable
            ? Border(
                top: BorderSide(
                  color: RuniacColors.primaryBlue.withValues(alpha: 0.10),
                ),
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              display.day,
              style: TextStyle(
                color: tappable
                    ? RuniacColors.primaryBlue
                    : RuniacColors.primaryBlue.withValues(alpha: 0.45),
                fontSize: 13,
                fontWeight: tappable ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tappable
                    ? RuniacColors.primaryBlue.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                display.icon,
                color: tappable
                    ? RuniacColors.primaryBlue
                    : RuniacColors.primaryBlue.withValues(alpha: 0.35),
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display.title,
                  style: const TextStyle(
                    color: RuniacColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (display.status.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    display.status,
                    style: TextStyle(
                      color: RuniacColors.primaryBlue.withValues(alpha: 0.60),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (tappable) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: RuniacColors.primaryBlue.withValues(alpha: 0.45),
              size: 20,
            ),
          ],
        ],
      ),
    );

    if (!tappable) {
      return row;
    }

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: row,
        ),
      ),
    );
  }
}
