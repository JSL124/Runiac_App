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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in youPlansSnapshot.expertOptions)
                _ExpertPlanOption(option),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: display.featured
            ? RuniacColors.innerTileSurface
            : RuniacColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: display.featured
              ? RuniacColors.primaryBlue
              : RuniacColors.border,
        ),
      ),
      child: Text(
        display.label,
        textAlign: TextAlign.center,
        style: display.featured
            ? YouTextStyles.planAccentLabel
            : YouTextStyles.smallStrong,
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
      decoration: youPillDecoration(RuniacColors.innerTileSurface),
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
