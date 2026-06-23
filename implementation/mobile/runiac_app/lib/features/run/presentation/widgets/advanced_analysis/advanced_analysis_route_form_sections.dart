import 'package:flutter/material.dart';

import '../../../domain/models/advanced_analysis_snapshot.dart';
import '../../../domain/models/cadence_graph_snapshot.dart';
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
          AdvancedAnalysisChartPanel(
            height: 150,
            painter: AdvancedAnalysisCadenceChartPainter(
              graph: analysis?.cadenceGraph.value,
              showDemoFallback: _showDemoCadenceFallback(
                analysis?.cadenceGraph,
              ),
            ),
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
        _cadencePointValue(analysis?.cadenceGraph.value?.lowestCadencePoint),
        _cadencePointUnit(analysis?.cadenceGraph.value?.lowestCadencePoint),
      ),
      AdvancedAnalysisStatData(
        'Highest',
        _cadencePointValue(analysis?.cadenceGraph.value?.highestCadencePoint),
        _cadencePointUnit(analysis?.cadenceGraph.value?.highestCadencePoint),
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
      return '--';
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

  String _cadencePointValue(CadenceGraphPoint? point) {
    final label = point?.displayLabel;
    if (label == null || label.isEmpty) {
      return '--';
    }
    return label.split(' ').first;
  }

  String _cadencePointUnit(CadenceGraphPoint? point) {
    final label = point?.displayLabel;
    if (label == null || label.isEmpty) {
      return '';
    }
    final parts = label.split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  bool _showDemoCadenceFallback(
    AdvancedAnalysisMetric<CadenceGraphSnapshot>? metric,
  ) {
    if (metric == null) {
      return true;
    }
    return metric.availability == AdvancedAnalysisMetricAvailability.demoOnly &&
        metric.source == AdvancedAnalysisMetricSource.staticDemo;
  }

  String _displayLabel(String? valueLabel) {
    if (valueLabel == null || valueLabel.isEmpty) {
      return '--';
    }
    return '${valueLabel[0].toUpperCase()}${valueLabel.substring(1)}';
  }

  String _cadenceInterpretation(AdvancedAnalysisFormCadenceAnalysis? analysis) {
    final consistency = analysis?.strideConsistency.valueLabel;
    if (consistency == null || consistency.isEmpty) {
      return 'Cadence is unavailable for this run.';
    }
    return 'Cadence consistency is ${_displayLabel(consistency)} for this run.';
  }
}
