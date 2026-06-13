import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../data/you_overview_demo_snapshots.dart';
import 'you_surface_primitives.dart';

class ExpertPlansEntryCard extends StatelessWidget {
  const ExpertPlansEntryCard({required this.onViewExpertPlans, super.key});

  final VoidCallback onViewExpertPlans;

  @override
  Widget build(BuildContext context) {
    return YouDividerSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YouCardHeader(Icons.school_outlined, youPlansSnapshot.expertTitle),
          const SizedBox(height: 8),
          Text(youPlansSnapshot.expertCopy, style: YouTextStyles.body),
          const SizedBox(height: 14),
          Row(
            children: [
              _ExpertPlanOption(youPlansSnapshot.expertOptions[0]),
              const SizedBox(width: 10),
              _ExpertPlanOption(youPlansSnapshot.expertOptions[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ExpertPlanOption(youPlansSnapshot.expertOptions[2]),
              const SizedBox(width: 10),
              _ExpertPlanOption(youPlansSnapshot.expertOptions[3]),
            ],
          ),
          const SizedBox(height: 12),
          const _CoachCreatedBadge(),
          const SizedBox(height: 16),
          StaticPlanAction(
            youPlansSnapshot.expertActionLabel,
            onTap: onViewExpertPlans,
          ),
        ],
      ),
    );
  }
}

class _ExpertPlanOption extends StatelessWidget {
  const _ExpertPlanOption(this.display);

  final YouExpertPlanOptionDisplay display;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 74),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: display.featured
              ? const Color(0xFFF7FAFF)
              : RuniacColors.white,
          borderRadius: BorderRadius.circular(youInnerRadius),
          border: Border.all(
            color: display.featured
                ? RuniacColors.primaryBlue
                : RuniacColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              display.icon,
              color: display.featured
                  ? RuniacColors.primaryBlue
                  : RuniacColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 7),
            Text(
              display.label,
              textAlign: TextAlign.center,
              style: YouTextStyles.bodyStrong,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCreatedBadge extends StatelessWidget {
  const _CoachCreatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: youPillDecoration(const Color(0xFFF7FAFF)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user,
            size: 14,
            color: RuniacColors.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            youPlansSnapshot.expertBadgeLabel,
            style: YouTextStyles.smallStrong,
          ),
        ],
      ),
    );
  }
}
