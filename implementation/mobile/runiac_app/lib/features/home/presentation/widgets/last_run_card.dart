import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';

const _softOrange = Color(0xFFFFF1E7);
const _sportOrange = Color(0xFFFF7A1A);
const _orangeBorder = Color(0xFFFFD8BD);

class LastRunCard extends StatelessWidget {
  const LastRunCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(icon: Icons.history, title: 'Last Run'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _InitialTile(),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete a run to see your summary.',
                      style: TextStyle(
                        color: RuniacColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your first run summary will appear here.',
                      style: TextStyle(
                        color: RuniacColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InitialTile extends StatelessWidget {
  const _InitialTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _softOrange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _orangeBorder),
      ),
      child: const Icon(Icons.directions_run, color: _sportOrange, size: 20),
    );
  }
}
