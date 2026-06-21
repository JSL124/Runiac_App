import 'package:flutter/material.dart';

import 'advanced_analysis_score_ring.dart';
import 'advanced_analysis_shared_widgets.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisOverviewSection extends StatelessWidget {
  const AdvancedAnalysisOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvancedAnalysisSection(
      title: 'Performance Overview',
      useDividers: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AdvancedAnalysisScoreRing(
                value: 82,
                size: 112,
                stroke: 9,
                color: advancedAnalysisBlue,
              ),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good steady effort',
                      style: TextStyle(
                        color: advancedAnalysisInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You maintained a stable pace and kept your heart rate mostly in the right zone.',
                      style: TextStyle(
                        color: advancedAnalysisBlue75,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AdvancedAnalysisInsightBadge(
                icon: Icons.speed_rounded,
                label: 'Stable Pace',
              ),
              AdvancedAnalysisInsightBadge(
                icon: Icons.favorite_border_rounded,
                label: 'Controlled HR',
              ),
              AdvancedAnalysisInsightBadge(
                icon: Icons.emoji_events_outlined,
                label: 'Good Endurance',
                highlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
