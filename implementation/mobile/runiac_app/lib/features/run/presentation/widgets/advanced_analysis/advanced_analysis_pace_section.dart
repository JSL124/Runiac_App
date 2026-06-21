import 'package:flutter/material.dart';

import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_charts.dart';
import 'advanced_analysis_shared_widgets.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisPaceSection extends StatelessWidget {
  const AdvancedAnalysisPaceSection({super.key, this.analysis});

  final AdvancedAnalysisPaceAnalysis? analysis;

  @override
  Widget build(BuildContext context) {
    return AdvancedAnalysisSection(
      title: 'Pace Analysis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdvancedAnalysisStatGrid(stats: _paceStats, plain: true),
          const SizedBox(height: 18),
          const _AdvancedAnalysisPaceGraphTitle(),
          const SizedBox(height: 8),
          const AdvancedAnalysisChartPanel(
            height: 170,
            painter: AdvancedAnalysisPaceChartPainter(),
            plain: true,
          ),
          const SizedBox(height: 16),
          const AdvancedAnalysisSubhead('Splits'),
          const SizedBox(height: 8),
          const _AdvancedAnalysisSplitRow(),
          const AdvancedAnalysisInterpretationRow(
            text:
                'Your pace slowed slightly in the middle section but recovered well in the final part.',
          ),
        ],
      ),
    );
  }

  List<AdvancedAnalysisStatData> get _paceStats {
    final analysis = this.analysis;
    if (analysis == null) {
      return advancedAnalysisPaceStats;
    }

    return [
      AdvancedAnalysisStatData(
        'Avg Pace',
        _metricValue(analysis.averagePace, stripPaceUnit: true),
        analysis.averagePace.isAvailable ? '/km' : '',
      ),
      AdvancedAnalysisStatData(
        'Fastest Pace',
        _metricValue(analysis.fastestPace, stripPaceUnit: true),
        analysis.fastestPace.isAvailable ? '/km' : '',
        hot: analysis.fastestPace.isAvailable,
      ),
      AdvancedAnalysisStatData(
        'Slowest Pace',
        _metricValue(analysis.slowestPace, stripPaceUnit: true),
        analysis.slowestPace.isAvailable ? '/km' : '',
      ),
      AdvancedAnalysisStatData(
        'Pace Stability',
        _metricValue(analysis.paceStability),
        analysis.paceStability.isAvailable ? '%' : '',
      ),
    ];
  }

  String _metricValue(
    AdvancedAnalysisMetric<String> metric, {
    bool stripPaceUnit = false,
  }) {
    if (!metric.isAvailable) {
      return '--';
    }

    final value = (metric.valueLabel ?? metric.value ?? '').trim();
    if (value.isEmpty) {
      return '--';
    }

    return stripPaceUnit ? _stripPaceUnit(value) : value;
  }

  String _stripPaceUnit(String value) {
    return value
        .replaceAll(RegExp(r'\s*/\s*km$', caseSensitive: false), '')
        .trim();
  }
}

class _AdvancedAnalysisPaceGraphTitle extends StatelessWidget {
  const _AdvancedAnalysisPaceGraphTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Pace Over Distance',
      style: TextStyle(
        color: advancedAnalysisBlue60,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _AdvancedAnalysisSplitRow extends StatelessWidget {
  const _AdvancedAnalysisSplitRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < advancedAnalysisSplits.length; i++) ...[
          Expanded(
            child: _AdvancedAnalysisSplitChip(split: advancedAnalysisSplits[i]),
          ),
          if (i != advancedAnalysisSplits.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _AdvancedAnalysisSplitChip extends StatelessWidget {
  const _AdvancedAnalysisSplitChip({required this.split});

  final AdvancedAnalysisSplitData split;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
      decoration: BoxDecoration(
        color: split.fastest
            ? advancedAnalysisOrange08
            : advancedAnalysisSurface,
        border: Border.all(
          color: split.partial
              ? advancedAnalysisBlue18
              : split.fastest
              ? advancedAnalysisOrange16
              : advancedAnalysisBlue10,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              split.km,
              style: const TextStyle(
                color: advancedAnalysisBlue45,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            child: Text(
              split.pace,
              style: TextStyle(
                color: split.fastest
                    ? advancedAnalysisOrange
                    : advancedAnalysisBlue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
