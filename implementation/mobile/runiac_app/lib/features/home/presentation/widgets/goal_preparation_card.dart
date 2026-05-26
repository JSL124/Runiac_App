import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import 'home_placeholders.dart';

const _softBlue = Color(0xFFEEF3FF);
const _blueBorder = Color(0xFFDCE6FF);

class GoalPreparationCard extends StatelessWidget {
  const GoalPreparationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CardTitle(icon: Icons.flag_outlined, title: 'Training Goal'),
          SizedBox(height: 12),
          Text(
            'Your training preparation will appear here.',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Next milestone appears after your plan starts.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14),
          _GoalProgressPreview(),
        ],
      ),
    );
  }
}

class _GoalProgressPreview extends StatelessWidget {
  const _GoalProgressPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _softBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _blueBorder),
      ),
      child: const ProgressPlaceholder(),
    );
  }
}
