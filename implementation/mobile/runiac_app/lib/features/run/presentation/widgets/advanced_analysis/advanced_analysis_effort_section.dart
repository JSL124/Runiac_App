import 'package:flutter/material.dart';

import 'advanced_analysis_score_ring.dart';
import 'advanced_analysis_shared_widgets.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisEffortSection extends StatelessWidget {
  const AdvancedAnalysisEffortSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvancedAnalysisSection(
      title: 'Effort & Intensity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _AdvancedAnalysisIntensityTile(
                  label: 'Planned Intensity',
                  value: 'Low',
                  progress: 0.33,
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _AdvancedAnalysisIntensityTile(
                  label: 'Actual Intensity',
                  value: 'Low–Moderate',
                  progress: 0.46,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _AdvancedAnalysisMatchCard(),
          AdvancedAnalysisInterpretationRow(
            text:
                'This run matched your planned easy effort well. Try starting a little slower next time.',
          ),
        ],
      ),
    );
  }
}

class _AdvancedAnalysisIntensityTile extends StatelessWidget {
  const _AdvancedAnalysisIntensityTile({
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: advancedAnalysisSurface,
        border: Border.all(color: advancedAnalysisBlue10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: advancedAnalysisBlue45,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: advancedAnalysisInk,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: advancedAnalysisBlue07,
            valueColor: const AlwaysStoppedAnimation<Color>(
              advancedAnalysisBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedAnalysisMatchCard extends StatelessWidget {
  const _AdvancedAnalysisMatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: advancedAnalysisSurface,
        border: Border.all(color: advancedAnalysisBlue10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          AdvancedAnalysisScoreRing(
            value: 88,
            size: 64,
            stroke: 6,
            color: advancedAnalysisOrange,
            percentOnly: true,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Match',
                  style: TextStyle(
                    color: advancedAnalysisBlue45,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '88% · Good',
                  style: TextStyle(
                    color: advancedAnalysisInk,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your real effort closely tracked the easy plan.',
                  style: TextStyle(
                    color: advancedAnalysisBlue75,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
