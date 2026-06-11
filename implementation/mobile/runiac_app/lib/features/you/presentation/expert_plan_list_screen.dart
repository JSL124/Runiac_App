import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/runiac_back_header.dart';

const _expertPlanFilters = [
  'Recommended',
  '5K',
  '10K',
  'Consistency',
  'Healthy Running',
  'Half',
  'Full',
];

const _expertPlanSectionGap = 14.0;

const _expertPlans = [
  _ExpertPlanDisplay(
    icon: Icons.directions_run,
    title: 'First 5K Preparation',
    description: 'A gentle plan for building confidence toward your first 5K.',
    duration: '6 weeks',
    frequency: '3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Running Coach',
  ),
  _ExpertPlanDisplay(
    icon: Icons.repeat,
    title: 'Build Running Consistency',
    description:
        'Create a steady running habit with balanced, achievable workouts.',
    duration: '4 weeks',
    frequency: '2–3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Fitness Trainer',
  ),
  _ExpertPlanDisplay(
    icon: Icons.flag_outlined,
    title: '10K Preparation',
    description: 'Build endurance and confidence for a comfortable 10K.',
    duration: '8 weeks',
    frequency: '3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Running Coach',
  ),
  _ExpertPlanDisplay(
    icon: Icons.favorite_border,
    title: 'Healthy Running Starter Plan',
    description:
        'Build a healthier running routine with steady, low-pressure sessions.',
    duration: '3 weeks',
    frequency: '3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Health Advisor',
  ),
  _ExpertPlanDisplay(
    icon: Icons.terrain_outlined,
    title: 'Half Marathon Preparation',
    description: 'Step up gradually with a longer-distance plan.',
    duration: '12 weeks',
    frequency: '3–4 runs/week',
    level: 'Intermediate',
    reviewer: 'Reviewed by Running Coach',
  ),
  _ExpertPlanDisplay(
    icon: Icons.landscape_outlined,
    title: 'Full Marathon Preparation',
    description: 'A longer plan for experienced runners preparing for 42.2K.',
    duration: '18 weeks',
    frequency: '4–5 runs/week',
    level: 'Advanced',
    reviewer: 'Reviewed by Running Coach',
  ),
];

class ExpertPlanListScreen extends StatelessWidget {
  const ExpertPlanListScreen({
    required this.onBack,
    required this.onFirstPlanSelected,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onFirstPlanSelected;

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, headerHeight + 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PlanSearchShell(),
                  const SizedBox(height: _expertPlanSectionGap),
                  const _ScreenIntro(),
                  const SizedBox(height: _expertPlanSectionGap),
                  const _FilterRow(),
                  const SizedBox(height: _expertPlanSectionGap),
                  for (var index = 0; index < _expertPlans.length; index++) ...[
                    _ExpertPlanCard(
                      _expertPlans[index],
                      onViewPlan: index == 0
                          ? onFirstPlanSelected
                          : _handleNoOp,
                    ),
                    const SizedBox(height: 10),
                  ],
                  const _MedicalNote(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Material(
              color: RuniacColors.background,
              child: SafeArea(
                bottom: false,
                child: RuniacBackHeader(
                  title: 'Expert Plans',
                  tooltip: 'Back to Plans',
                  onBack: onBack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNoOp() {}
}

class _ExpertPlanDisplay {
  const _ExpertPlanDisplay({
    required this.icon,
    required this.title,
    required this.description,
    required this.duration,
    required this.frequency,
    required this.level,
    required this.reviewer,
  });

  final IconData icon;
  final String title;
  final String description;
  final String duration;
  final String frequency;
  final String level;
  final String reviewer;
}

class _PlanSearchShell extends StatelessWidget {
  const _PlanSearchShell();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      readOnly: true,
      label: 'Search plans',
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: RuniacColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RuniacColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 20, color: RuniacColors.textSecondary),
            SizedBox(width: 10),
            Expanded(
              child: Text('Search plans', style: _searchPlaceholderStyle),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenIntro extends StatelessWidget {
  const _ScreenIntro();

  @override
  Widget build(BuildContext context) {
    return const _AccentStrip();
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < _expertPlanFilters.length; index++) ...[
            _FilterChip(_expertPlanFilters[index], selected: index == 0),
            if (index < _expertPlanFilters.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, {required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: false,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: selected ? RuniacColors.primaryBlue : RuniacColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? RuniacColors.primaryBlue : RuniacColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? RuniacColors.white : RuniacColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ExpertPlanCard extends StatelessWidget {
  const _ExpertPlanCard(this.plan, {required this.onViewPlan});

  final _ExpertPlanDisplay plan;
  final VoidCallback onViewPlan;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlanThumbnail(plan.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CoachReviewedBadge(),
                    const SizedBox(height: 8),
                    Text(plan.title, style: _titleStyle),
                    const SizedBox(height: 6),
                    Text(plan.description, style: _bodyStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(Icons.calendar_month, plan.duration),
              _MetaPill(Icons.repeat, plan.frequency),
              _MetaPill(Icons.signal_cellular_alt, plan.level),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: RuniacColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(plan.reviewer, style: _smallBodyStyle)),
            ],
          ),
          const SizedBox(height: 14),
          _VisualOnlyViewPlanButton(onTap: onViewPlan),
        ],
      ),
    );
  }
}

class _PlanThumbnail extends StatelessWidget {
  const _PlanThumbnail(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 10,
            right: 10,
            bottom: 17,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: RuniacColors.accentOrange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Icon(icon, color: RuniacColors.primaryBlue, size: 32),
        ],
      ),
    );
  }
}

class _CoachReviewedBadge extends StatelessWidget {
  const _CoachReviewedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: _pillDecoration(const Color(0xFFF7FAFF)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: RuniacColors.primaryBlue,
          ),
          SizedBox(width: 6),
          Text('Coach reviewed', style: _smallStrongStyle),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: _pillDecoration(RuniacColors.background),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RuniacColors.textSecondary, size: 14),
          const SizedBox(width: 5),
          Text(label, style: _smallBodyStyle),
        ],
      ),
    );
  }
}

class _VisualOnlyViewPlanButton extends StatelessWidget {
  const _VisualOnlyViewPlanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RuniacColors.primaryBlue),
          ),
          child: const Text('View Plan', style: _buttonTextStyle),
        ),
      ),
    );
  }
}

class _MedicalNote extends StatelessWidget {
  const _MedicalNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE2D4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.health_and_safety_outlined,
            color: RuniacColors.accentOrange,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Plans are reviewed for beginner suitability. This is general fitness guidance, not medical advice.',
              style: _smallStrongStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentStrip extends StatelessWidget {
  const _AccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _pillDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: RuniacColors.border),
  );
}

const _searchPlaceholderStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 15,
  fontWeight: FontWeight.w700,
);

const _titleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w900,
);

const _bodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 13,
  height: 1.35,
  fontWeight: FontWeight.w600,
);

const _smallBodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

const _smallStrongStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 12,
  height: 1.25,
  fontWeight: FontWeight.w800,
);

const _buttonTextStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 13,
  fontWeight: FontWeight.w900,
);
