import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import 'home_placeholders.dart';

const _softBlue = Color(0xFFF8FAFF);
const _blueBorder = RuniacColors.border;

const _runnerProgressDisplaySnapshot = _RunnerProgressDisplaySnapshot(
  title: 'Runner Progress',
  message: 'Progress summaries will appear after verified runs.',
);

class RunnerProgressCard extends StatelessWidget {
  const RunnerProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    const snapshot = _runnerProgressDisplaySnapshot;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(icon: Icons.emoji_events_outlined, title: snapshot.title),
          const SizedBox(height: 12),
          Text(
            snapshot.message,
            style: const TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          const _RunnerProgressPreview(),
        ],
      ),
    );
  }
}

class _RunnerProgressDisplaySnapshot {
  const _RunnerProgressDisplaySnapshot({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
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
