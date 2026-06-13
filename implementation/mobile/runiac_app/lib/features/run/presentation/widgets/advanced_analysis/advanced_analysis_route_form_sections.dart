import 'package:flutter/material.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_charts.dart';
import 'advanced_analysis_shared_widgets.dart';

class AdvancedAnalysisElevationSection extends StatelessWidget {
  const AdvancedAnalysisElevationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvancedAnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdvancedAnalysisSectionHeader(
            title: 'Elevation Analysis',
            icon: Icons.terrain_rounded,
            badge: 'Mostly flat',
          ),
          SizedBox(height: 16),
          AdvancedAnalysisChartPanel(
            height: 150,
            painter: AdvancedAnalysisElevationChartPainter(),
          ),
          SizedBox(height: 16),
          AdvancedAnalysisStatGrid(stats: advancedAnalysisElevationStats),
          AdvancedAnalysisInterpretationRow(
            text:
                'The route was mostly flat, which helped you maintain a stable pace and steady heart rate.',
          ),
        ],
      ),
    );
  }
}

class AdvancedAnalysisCadenceSection extends StatelessWidget {
  const AdvancedAnalysisCadenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvancedAnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdvancedAnalysisSectionHeader(
            title: 'Running Form / Cadence',
            icon: Icons.access_time_rounded,
            badge: 'Good',
            hotBadge: true,
          ),
          SizedBox(height: 16),
          AdvancedAnalysisStatGrid(stats: advancedAnalysisCadenceStats),
          SizedBox(height: 16),
          AdvancedAnalysisChartPanel(
            height: 150,
            painter: AdvancedAnalysisCadenceChartPainter(),
          ),
          AdvancedAnalysisInterpretationRow(
            text:
                'Your cadence stayed within a comfortable range with a consistent running rhythm.',
          ),
        ],
      ),
    );
  }
}
