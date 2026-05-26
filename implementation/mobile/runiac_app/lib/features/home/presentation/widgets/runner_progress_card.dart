import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import 'home_placeholders.dart';

const _softBlue = Color(0xFFEEF3FF);
const _blueBorder = Color(0xFFDCE6FF);

class RunnerProgressCard extends StatelessWidget {
  const RunnerProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CardTitle(
            icon: Icons.emoji_events_outlined,
            title: 'Runner Progress',
          ),
          SizedBox(height: 12),
          Text(
            'Progress summaries will appear after verified runs.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          SizedBox(height: 14),
          _RunnerProgressPreview(),
        ],
      ),
    );
  }
}

class _RunnerProgressPreview extends StatelessWidget {
  const _RunnerProgressPreview();

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
