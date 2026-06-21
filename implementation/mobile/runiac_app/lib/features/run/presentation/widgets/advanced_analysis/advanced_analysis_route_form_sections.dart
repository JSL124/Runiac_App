import 'package:flutter/material.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_charts.dart';
import 'advanced_analysis_shared_widgets.dart';

class AdvancedAnalysisElevationSection extends StatelessWidget {
  const AdvancedAnalysisElevationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvancedAnalysisSection(
      title: 'Elevation Analysis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
    return const AdvancedAnalysisSection(
      title: 'Running Form / Cadence',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
