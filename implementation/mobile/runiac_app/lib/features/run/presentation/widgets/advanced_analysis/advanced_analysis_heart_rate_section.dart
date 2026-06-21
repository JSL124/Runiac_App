import 'package:flutter/material.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_shared_widgets.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisHeartRateSection extends StatelessWidget {
  const AdvancedAnalysisHeartRateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvancedAnalysisSection(
      title: 'Heart Rate Analysis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdvancedAnalysisStatGrid(
            stats: advancedAnalysisHeartRateStats,
            plain: true,
          ),
          SizedBox(height: 18),
          AdvancedAnalysisSubhead('Zone Distribution'),
          SizedBox(height: 10),
          _AdvancedAnalysisZoneBars(),
          AdvancedAnalysisInterpretationRow(
            text:
                'You spent most of the run in the aerobic zone, which is ideal for building endurance.',
          ),
        ],
      ),
    );
  }
}

class _AdvancedAnalysisZoneBars extends StatelessWidget {
  const _AdvancedAnalysisZoneBars();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _AdvancedAnalysisZoneRow(
          label: 'Zone 1',
          percent: 18,
          color: advancedAnalysisBlue22,
          max: 54,
        ),
        SizedBox(height: 10),
        _AdvancedAnalysisZoneRow(
          label: 'Zone 2',
          percent: 54,
          color: advancedAnalysisBlue,
          max: 54,
        ),
        SizedBox(height: 10),
        _AdvancedAnalysisZoneRow(
          label: 'Zone 3',
          percent: 22,
          color: advancedAnalysisBlue60,
          max: 54,
        ),
        SizedBox(height: 10),
        _AdvancedAnalysisZoneRow(
          label: 'Zone 4',
          percent: 6,
          color: advancedAnalysisOrange,
          max: 54,
        ),
        SizedBox(height: 10),
        _AdvancedAnalysisZoneRow(
          label: 'Zone 5',
          percent: 0,
          color: advancedAnalysisOrange16,
          max: 54,
        ),
      ],
    );
  }
}

class _AdvancedAnalysisZoneRow extends StatelessWidget {
  const _AdvancedAnalysisZoneRow({
    required this.label,
    required this.percent,
    required this.color,
    required this.max,
  });

  final String label;
  final int percent;
  final Color color;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: const TextStyle(
              color: advancedAnalysisBlue75,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percent / max,
              minHeight: 12,
              backgroundColor: advancedAnalysisSurface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: advancedAnalysisInk,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
