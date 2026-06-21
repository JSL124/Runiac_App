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
          _paceGraph,
          const SizedBox(height: 16),
          const _AdvancedAnalysisSplitsTitle(),
          const SizedBox(height: 10),
          const _AdvancedAnalysisSplitTable(),
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

  Widget get _paceGraph {
    final analysis = this.analysis;
    if (analysis == null) {
      return const AdvancedAnalysisChartPanel(
        height: 170,
        painter: AdvancedAnalysisPaceChartPainter(),
        plain: true,
      );
    }

    final graph = analysis.paceGraph.value;
    if (analysis.paceGraph.isAvailable &&
        graph != null &&
        graph.isAvailable &&
        graph.hasDistanceAxis) {
      return AdvancedAnalysisChartPanel(
        height: 170,
        painter: AdvancedAnalysisPaceChartPainter(graph: graph),
        plain: true,
      );
    }

    return const _AdvancedAnalysisUnavailablePaceGraph();
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

class _AdvancedAnalysisUnavailablePaceGraph extends StatelessWidget {
  const _AdvancedAnalysisUnavailablePaceGraph();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: ValueKey('advanced_analysis_pace_graph_unavailable'),
      height: 170,
      child: Center(
        child: Text(
          '--',
          style: TextStyle(
            color: advancedAnalysisInk,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
      ),
    );
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

class _AdvancedAnalysisSplitsTitle extends StatelessWidget {
  const _AdvancedAnalysisSplitsTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Splits',
      style: TextStyle(
        color: advancedAnalysisBlue,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _AdvancedAnalysisSplitTable extends StatelessWidget {
  const _AdvancedAnalysisSplitTable();

  static const double _minFill = 0.32;
  static const double _partialFill = 0.4;

  @override
  Widget build(BuildContext context) {
    final fullSplitPaces = [
      for (final split in advancedAnalysisSplits)
        if (!split.partial) _paceSeconds(split.pace),
    ].whereType<int>().toList();
    final fastest = fullSplitPaces.isEmpty
        ? null
        : fullSplitPaces.reduce((a, b) => a < b ? a : b);
    final slowest = fullSplitPaces.isEmpty
        ? null
        : fullSplitPaces.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        const _AdvancedAnalysisSplitHeader(),
        const Divider(color: advancedAnalysisBlue12, height: 17, thickness: 1),
        for (var i = 0; i < advancedAnalysisSplits.length; i++) ...[
          _AdvancedAnalysisSplitTableRow(
            split: advancedAnalysisSplits[i],
            displayDistance: _displayDistance(advancedAnalysisSplits[i]),
            fillFraction: _fillFor(
              advancedAnalysisSplits[i],
              fastest: fastest,
              slowest: slowest,
            ),
          ),
          if (i != advancedAnalysisSplits.length - 1)
            const Divider(
              color: advancedAnalysisBlue07,
              height: 15,
              thickness: 1,
            ),
        ],
      ],
    );
  }

  static String _displayDistance(AdvancedAnalysisSplitData split) {
    if (!split.partial) {
      return _distanceLabelWithoutUnit(split.km);
    }

    final totalDistance = _distanceKm(split.km);
    if (totalDistance == null) {
      return _distanceLabelWithoutUnit(split.km);
    }

    final completedWholeKm = totalDistance.floorToDouble();
    final remainingKm = totalDistance - completedWholeKm;
    if (remainingKm <= 0) {
      return _distanceLabelWithoutUnit(split.km);
    }

    return remainingKm.toStringAsFixed(2);
  }

  static double? _distanceKm(String label) {
    final match = RegExp(r'^(\d+(?:\.\d+)?)\s*km$').firstMatch(label.trim());
    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(1)!);
  }

  static String _distanceLabelWithoutUnit(String label) {
    return label.trim().replaceFirst(RegExp(r'\s*km$'), '');
  }

  static double _fillFor(
    AdvancedAnalysisSplitData split, {
    required int? fastest,
    required int? slowest,
  }) {
    if (split.partial) {
      return _partialFill;
    }

    final seconds = _paceSeconds(split.pace);
    if (seconds == null || fastest == null || slowest == null) {
      return _minFill;
    }

    if (fastest == slowest) {
      return 1;
    }

    final ratio = (slowest - seconds) / (slowest - fastest);
    return (_minFill + ratio.clamp(0, 1) * (1 - _minFill)).toDouble();
  }

  static int? _paceSeconds(String pace) {
    final match = RegExp(r"^(\d+)[’'](\d{1,2})").firstMatch(pace.trim());
    if (match == null) {
      return null;
    }

    final minutes = int.tryParse(match.group(1)!);
    final seconds = int.tryParse(match.group(2)!);
    if (minutes == null || seconds == null) {
      return null;
    }

    return minutes * 60 + seconds;
  }
}

class _AdvancedAnalysisSplitHeader extends StatelessWidget {
  const _AdvancedAnalysisSplitHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 50, child: _AdvancedAnalysisSplitHeaderText('Km')),
        SizedBox(width: 64, child: _AdvancedAnalysisSplitHeaderText('Pace')),
        Expanded(child: SizedBox.shrink()),
        SizedBox(
          width: 46,
          child: _AdvancedAnalysisSplitHeaderText('Elev', alignRight: true),
        ),
        SizedBox(
          width: 38,
          child: _AdvancedAnalysisSplitHeaderText('HR', alignRight: true),
        ),
      ],
    );
  }
}

class _AdvancedAnalysisSplitHeaderText extends StatelessWidget {
  const _AdvancedAnalysisSplitHeaderText(this.text, {this.alignRight = false});

  final String text;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        color: advancedAnalysisBlue60,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _AdvancedAnalysisSplitTableRow extends StatelessWidget {
  const _AdvancedAnalysisSplitTableRow({
    required this.split,
    required this.displayDistance,
    required this.fillFraction,
  });

  final AdvancedAnalysisSplitData split;
  final String displayDistance;
  final double fillFraction;

  @override
  Widget build(BuildContext context) {
    final paceColor = split.fastest
        ? advancedAnalysisOrange
        : advancedAnalysisInk;

    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            displayDistance,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: advancedAnalysisBlue75,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: 64,
          child: Text(
            split.pace,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: paceColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Expanded(
          child: _AdvancedAnalysisSplitBar(
            fillFraction: fillFraction,
            highlighted: split.fastest,
            partial: split.partial,
          ),
        ),
        const SizedBox(
          width: 46,
          child: _AdvancedAnalysisUnavailableSplitValue(),
        ),
        const SizedBox(
          width: 38,
          child: _AdvancedAnalysisUnavailableSplitValue(),
        ),
      ],
    );
  }
}

class _AdvancedAnalysisSplitBar extends StatelessWidget {
  const _AdvancedAnalysisSplitBar({
    required this.fillFraction,
    required this.highlighted,
    required this.partial,
  });

  final double fillFraction;
  final bool highlighted;
  final bool partial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 13,
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: advancedAnalysisBlue07,
          borderRadius: BorderRadius.circular(999),
        ),
        child: FractionallySizedBox(
          widthFactor: fillFraction.clamp(0, 1),
          heightFactor: 1,
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: partial
                  ? advancedAnalysisBlue60
                  : highlighted
                  ? advancedAnalysisOrange
                  : advancedAnalysisBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancedAnalysisUnavailableSplitValue extends StatelessWidget {
  const _AdvancedAnalysisUnavailableSplitValue();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '--',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: advancedAnalysisBlue45,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.1,
      ),
    );
  }
}
