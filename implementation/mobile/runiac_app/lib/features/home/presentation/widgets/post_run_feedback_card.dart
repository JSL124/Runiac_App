import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import '../../../../core/widgets/soft_notice.dart';

const _postRunFeedbackDisplaySnapshot = _PostRunFeedbackDisplaySnapshot(
  title: 'Post-run Feedback',
  message: 'Feedback will appear after a completed run.',
  notice: 'Helpful guidance will appear here after a run.',
);

class PostRunFeedbackCard extends StatelessWidget {
  const PostRunFeedbackCard({super.key});

  @override
  Widget build(BuildContext context) {
    const snapshot = _postRunFeedbackDisplaySnapshot;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            icon: Icons.tips_and_updates_outlined,
            title: snapshot.title,
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.message,
            style: const TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SoftNotice(text: snapshot.notice),
        ],
      ),
    );
  }
}

class _PostRunFeedbackDisplaySnapshot {
  const _PostRunFeedbackDisplaySnapshot({
    required this.title,
    required this.message,
    required this.notice,
  });

  final String title;
  final String message;
  final String notice;
}
