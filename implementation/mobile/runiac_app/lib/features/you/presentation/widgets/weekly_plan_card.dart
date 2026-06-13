import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../data/weekly_workout_demo_snapshots.dart';
import '../data/you_overview_demo_snapshots.dart';
import 'you_surface_primitives.dart';

class WeeklyPlanCard extends StatelessWidget {
  const WeeklyPlanCard({required this.onViewWorkout, super.key});

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
                  youPlansSnapshot.weeklyTitle,
                  iconSize: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '2 of 3 done',
                style: YouTextStyles.weeklyPlanProgressLabel,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              value: 2 / 3,
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
          for (
            var index = 0;
            index < youPlansSnapshot.scheduleRows.length;
            index++
          )
            _WeeklyPlanDayRow(
              youPlansSnapshot.scheduleRows[index],
              showDivider: index > 0,
              onTap: _workoutDetailTap(
                youPlansSnapshot.scheduleRows[index],
                onViewWorkout,
              ),
            ),
        ],
      ),
    );
  }
}

VoidCallback? _workoutDetailTap(
  YouPlanScheduleRow row,
  ValueChanged<WeeklyWorkoutDetailSnapshot> onViewWorkout,
) {
  final detailSnapshot = row.detailSnapshot;
  if (!row.opensWorkoutDetail || detailSnapshot == null) {
    return null;
  }

  return () => onViewWorkout(detailSnapshot);
}

class _WeeklyPlanDayRow extends StatelessWidget {
  const _WeeklyPlanDayRow(
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
    final completed = display.status == 'Completed';
    final next = display.status == 'Upcoming · 7:30 AM';
    final upcoming = tappable && !next && !completed;
    final rest = display.title == 'Rest Day';
    final rowColor = next
        ? RuniacColors.accentOrange.withValues(alpha: 0.06)
        : upcoming
        ? RuniacColors.primaryBlue.withValues(alpha: 0.06)
        : null;
    final dayColor = next
        ? const Color(0xFFE8550A)
        : (completed || upcoming)
        ? RuniacColors.primaryBlue
        : RuniacColors.primaryBlue.withValues(alpha: 0.45);
    final subtitleColor = next
        ? const Color(0xFFE8550A)
        : RuniacColors.primaryBlue.withValues(alpha: 0.60);
    final status = display.status;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: rowColor,
        border: showDivider && !next && !upcoming
            ? Border(
                top: BorderSide(
                  color: RuniacColors.primaryBlue.withValues(alpha: 0.10),
                ),
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                display.day,
                style: TextStyle(
                  color: dayColor,
                  fontSize: 13,
                  fontWeight: (next || completed || upcoming)
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              child: _WeeklyPlanStatusNode(
                completed: completed,
                next: next,
                upcoming: upcoming,
                rest: rest,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    display.title,
                    style: TextStyle(
                      color: rest
                          ? RuniacColors.primaryBlue.withValues(alpha: 0.75)
                          : RuniacColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                        fontWeight: next ? FontWeight.w700 : FontWeight.w600,
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
                key: ValueKey('weekly_workout_detail_chevron'),
                color: next
                    ? RuniacColors.accentOrange
                    : RuniacColors.primaryBlue.withValues(alpha: 0.45),
                size: 20,
              ),
            ],
          ],
        ),
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

class _WeeklyPlanStatusNode extends StatelessWidget {
  const _WeeklyPlanStatusNode({
    required this.completed,
    required this.next,
    required this.upcoming,
    required this.rest,
  });

  final bool completed;
  final bool next;
  final bool upcoming;
  final bool rest;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: RuniacColors.primaryBlue,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: RuniacColors.primaryBlue.withValues(alpha: 0.24),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          color: RuniacColors.white,
          size: 17,
        ),
      );
    }

    if (next || upcoming) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: next
              ? RuniacColors.accentOrange.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            width: next ? 2.3 : 2,
            color: next
                ? RuniacColors.accentOrange
                : RuniacColors.primaryBlue.withValues(alpha: 0.30),
          ),
        ),
      );
    }

    if (rest) {
      return Icon(
        Icons.hotel_outlined,
        color: RuniacColors.primaryBlue.withValues(alpha: 0.45),
        size: 24,
      );
    }

    return const SizedBox(width: 28, height: 28);
  }
}
