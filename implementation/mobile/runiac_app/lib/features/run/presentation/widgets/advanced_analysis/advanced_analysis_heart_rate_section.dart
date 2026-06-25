import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_shared_widgets.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisHeartRateSection extends StatelessWidget {
  const AdvancedAnalysisHeartRateSection({super.key, this.analysis});

  final AdvancedAnalysisHeartRateAnalysis? analysis;

  @override
  Widget build(BuildContext context) {
    final heartRate = analysis;
    final zones =
        heartRate?.zones.value ?? const <AdvancedAnalysisHeartRateZone>[];
    final hasZoneDistribution =
        heartRate?.isZoneReady == true && heartRate?.zones.isAvailable == true;
    final hasAnyHeartRateMetric =
        heartRate?.averageHeartRate.isAvailable == true ||
        heartRate?.maxHeartRate.isAvailable == true;
    final fullUnavailable = !hasAnyHeartRateMetric && !hasZoneDistribution;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdvancedAnalysisStatGrid(
          stats: _heartRateStats(heartRate),
          plain: true,
        ),
        const SizedBox(height: 18),
        if (hasZoneDistribution) ...[
          const AdvancedAnalysisSubhead('Zone Distribution'),
          const SizedBox(height: 10),
          _AdvancedAnalysisZoneBars(zones: zones),
        ] else
          _AdvancedAnalysisHeartRateStatusPanel(
            message: _statusMessage(heartRate),
            showMessage: !fullUnavailable,
          ),
        if (hasZoneDistribution)
          const AdvancedAnalysisInterpretationRow(
            text:
                'Heart-rate zones are calculated from available wearable samples for this run.',
          ),
      ],
    );

    return AdvancedAnalysisSection(
      title: 'Heart Rate Analysis',
      child: Stack(
        children: [
          content,
          if (fullUnavailable)
            const Positioned.fill(child: _AdvancedAnalysisHeartRateGuard()),
        ],
      ),
    );
  }

  List<AdvancedAnalysisStatData> _heartRateStats(
    AdvancedAnalysisHeartRateAnalysis? heartRate,
  ) {
    final stats = [
      _heartRateStat('Avg Heart Rate', heartRate?.averageHeartRate, 'bpm'),
      _heartRateStat('Max Heart Rate', heartRate?.maxHeartRate, 'bpm'),
    ];
    if (heartRate?.isZoneReady == true) {
      stats.addAll([
        _heartRateStat('Target Zone', heartRate?.targetZone, 'bpm'),
        _heartRateStat('Time in Zone', heartRate?.timeInZone, '%'),
      ]);
    }
    return stats;
  }

  String _statusMessage(AdvancedAnalysisHeartRateAnalysis? heartRate) {
    if (heartRate?.averageHeartRate.isAvailable == true ||
        heartRate?.maxHeartRate.isAvailable == true) {
      return 'Heart rate was recorded, but zone analysis is not enabled for this run.';
    }
    return 'Heart rate was not recorded for this run.';
  }

  AdvancedAnalysisStatData _heartRateStat(
    String label,
    AdvancedAnalysisMetric<String>? metric,
    String unit,
  ) {
    final value = metric?.valueLabel;
    if (value == null || value.trim().isEmpty) {
      return AdvancedAnalysisStatData(label, '--', '');
    }
    final normalizedValue = value
        .replaceAll(' bpm', '')
        .replaceAll('bpm', '')
        .replaceAll('%', '')
        .trim();
    return AdvancedAnalysisStatData(label, normalizedValue, unit);
  }
}

class _AdvancedAnalysisZoneBars extends StatelessWidget {
  const _AdvancedAnalysisZoneBars({required this.zones});

  final List<AdvancedAnalysisHeartRateZone> zones;

  @override
  Widget build(BuildContext context) {
    final max = zones
        .map((zone) => zone.percent)
        .fold<int>(
          0,
          (largest, percent) => percent > largest ? percent : largest,
        )
        .clamp(1, 100);
    return Column(
      children: [
        for (var index = 0; index < zones.length; index += 1) ...[
          _AdvancedAnalysisZoneRow(
            label: zones[index].label,
            percent: zones[index].percent,
            color: _zoneColor(index),
            max: max,
          ),
          if (index + 1 < zones.length) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Color _zoneColor(int index) {
    return switch (index) {
      0 => advancedAnalysisBlue22,
      1 => advancedAnalysisBlue,
      2 => advancedAnalysisBlue60,
      3 => advancedAnalysisOrange,
      _ => advancedAnalysisOrange16,
    };
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

class _AdvancedAnalysisHeartRateStatusPanel extends StatelessWidget {
  const _AdvancedAnalysisHeartRateStatusPanel({
    required this.message,
    required this.showMessage,
  });

  final String message;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: advancedAnalysisSurface,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
          if (showMessage) _AdvancedAnalysisHeartRateGuard(message: message),
        ],
      ),
    );
  }
}

class _AdvancedAnalysisHeartRateGuard extends StatelessWidget {
  const _AdvancedAnalysisHeartRateGuard({
    this.message = 'Heart rate was not recorded for this run.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.2, sigmaY: 3.2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.44),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: advancedAnalysisOrange,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    shadows: [
                      Shadow(color: Colors.white, blurRadius: 10),
                      Shadow(
                        color: Colors.white,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
