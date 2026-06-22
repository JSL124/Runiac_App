import 'package:flutter/material.dart';

import '../../../domain/models/advanced_analysis_snapshot.dart';
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
            plain: true,
          ),
          SizedBox(height: 16),
          AdvancedAnalysisStatGrid(
            stats: advancedAnalysisElevationStats,
            plain: true,
          ),
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
  const AdvancedAnalysisCadenceSection({super.key, this.analysis});

  final AdvancedAnalysisFormCadenceAnalysis? analysis;

  @override
  Widget build(BuildContext context) {
    return AdvancedAnalysisSection(
      title: 'Running Form / Cadence',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdvancedAnalysisStatGrid(stats: _cadenceStats(analysis), plain: true),
          const SizedBox(height: 16),
          const AdvancedAnalysisChartPanel(
            height: 150,
            painter: AdvancedAnalysisCadenceChartPainter(),
            plain: true,
          ),
          AdvancedAnalysisInterpretationRow(
            text: _cadenceInterpretation(analysis),
          ),
        ],
      ),
    );
  }

  List<AdvancedAnalysisStatData> _cadenceStats(
    AdvancedAnalysisFormCadenceAnalysis? analysis,
  ) {
    return [
      AdvancedAnalysisStatData(
        'Average Cadence',
        _cadenceValue(analysis?.averageCadence),
        _cadenceUnit(analysis?.averageCadence),
      ),
      AdvancedAnalysisStatData(
        'Lowest',
        _cadenceGraphValue(analysis, 0),
        _cadenceGraphUnit(analysis, 0),
      ),
      AdvancedAnalysisStatData(
        'Highest',
        _cadenceGraphValue(analysis, 2),
        _cadenceGraphUnit(analysis, 2),
      ),
      AdvancedAnalysisStatData(
        'Trend',
        _displayLabel(analysis?.cadenceStatus.valueLabel),
        '',
      ),
    ];
  }

  String _cadenceValue(AdvancedAnalysisMetric<String>? metric) {
    final valueLabel = metric?.valueLabel;
    if (valueLabel == null) {
      return 'Unavailable';
    }
    return valueLabel.split(' ').first;
  }

  String _cadenceUnit(AdvancedAnalysisMetric<String>? metric) {
    final valueLabel = metric?.valueLabel;
    if (valueLabel == null) {
      return '';
    }
    final parts = valueLabel.split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  String _cadenceGraphValue(
    AdvancedAnalysisFormCadenceAnalysis? analysis,
    int index,
  ) {
    final label = _cadenceGraphLabel(analysis, index);
    if (label == null) {
      return 'Unavailable';
    }
    return label.split(' ').first;
  }

  String _cadenceGraphUnit(
    AdvancedAnalysisFormCadenceAnalysis? analysis,
    int index,
  ) {
    final label = _cadenceGraphLabel(analysis, index);
    if (label == null) {
      return '';
    }
    final parts = label.split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  String? _cadenceGraphLabel(
    AdvancedAnalysisFormCadenceAnalysis? analysis,
    int index,
  ) {
    final graphValues = analysis?.cadenceGraph.value;
    if (graphValues == null || graphValues.length <= index) {
      return null;
    }
    return graphValues[index];
  }

  String _displayLabel(String? valueLabel) {
    if (valueLabel == null || valueLabel.isEmpty) {
      return 'Unavailable';
    }
    return '${valueLabel[0].toUpperCase()}${valueLabel.substring(1)}';
  }

  String _cadenceInterpretation(AdvancedAnalysisFormCadenceAnalysis? analysis) {
    final consistency = _displayLabel(analysis?.strideConsistency.valueLabel);
    if (consistency == 'Unavailable') {
      return 'Cadence is unavailable for this run.';
    }
    return 'Cadence consistency is $consistency for this run.';
  }
}
