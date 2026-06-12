import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/crossed_placeholder.dart';
import '../../../../core/widgets/dashboard_card.dart';
import '../../../../core/widgets/runiac_buttons.dart';

const _primaryBlue = RuniacColors.primaryBlue;
const _blueBorder = RuniacColors.border;
const _orangeStrong = RuniacColors.accentOrange;

const _todayPlanDisplaySnapshot = _TodayPlanDisplaySnapshot(
  title: 'Today\'s Plan',
  headline: 'Ready for an easy run?',
  message: 'Start small and keep it comfortable.',
  secondaryActionLabel: 'View Plan',
  primaryActionLabel: 'Quick Start',
);

class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({
    required this.onViewPlan,
    required this.onQuickStart,
    super.key,
  });

  final VoidCallback onViewPlan;
  final VoidCallback onQuickStart;

  @override
  Widget build(BuildContext context) {
    const snapshot = _todayPlanDisplaySnapshot;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TodayAccentStrip(),
          const SizedBox(height: 14),
          CardTitle(icon: Icons.calendar_today, title: snapshot.title),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.headline,
                      style: const TextStyle(
                        color: RuniacColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.message,
                      style: const TextStyle(
                        color: RuniacColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const _PlanImagePlaceholder(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewPlan,
                  style: RuniacButtonStyles.secondary(
                    foregroundColor: _primaryBlue,
                    side: const BorderSide(color: _blueBorder),
                    minimumSize: const Size.fromHeight(44),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(snapshot.secondaryActionLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onQuickStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(snapshot.primaryActionLabel),
                  style: RuniacButtonStyles.primary(
                    tone: RuniacButtonTone.orange,
                    minimumSize: const Size.fromHeight(44),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayPlanDisplaySnapshot {
  const _TodayPlanDisplaySnapshot({
    required this.title,
    required this.headline,
    required this.message,
    required this.secondaryActionLabel,
    required this.primaryActionLabel,
  });

  final String title;
  final String headline;
  final String message;
  final String secondaryActionLabel;
  final String primaryActionLabel;
}

class _TodayAccentStrip extends StatelessWidget {
  const _TodayAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: _orangeStrong,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _PlanImagePlaceholder extends StatelessWidget {
  const _PlanImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const CrossedPlaceholder(width: 96, height: 96);
  }
}
