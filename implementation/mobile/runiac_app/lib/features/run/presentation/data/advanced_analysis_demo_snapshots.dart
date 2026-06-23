import 'package:flutter/material.dart';

/// Display-only demo values for the static Advanced Analysis surface.
///
/// Trusted production analysis values must come from approved backend/read-model
/// integration later; the Flutter client must not calculate trusted progression,
/// leaderboard, subscription, or expert-publication state.
const advancedAnalysisPacePoints = [
  AdvancedAnalysisPoint(0.00, 392),
  AdvancedAnalysisPoint(0.25, 384),
  AdvancedAnalysisPoint(0.50, 372),
  AdvancedAnalysisPoint(0.80, 360),
  AdvancedAnalysisPoint(1.00, 384),
  AdvancedAnalysisPoint(1.40, 396),
  AdvancedAnalysisPoint(1.80, 404),
  AdvancedAnalysisPoint(2.20, 412),
  AdvancedAnalysisPoint(2.60, 420),
  AdvancedAnalysisPoint(3.00, 425),
  AdvancedAnalysisPoint(3.30, 410),
  AdvancedAnalysisPoint(3.60, 392),
  AdvancedAnalysisPoint(3.90, 372),
  AdvancedAnalysisPoint(4.03, 366),
];

const advancedAnalysisCadencePoints = [
  AdvancedAnalysisPoint(0.0, 158),
  AdvancedAnalysisPoint(0.1, 162),
  AdvancedAnalysisPoint(0.2, 165),
  AdvancedAnalysisPoint(0.3, 163),
  AdvancedAnalysisPoint(0.4, 166),
  AdvancedAnalysisPoint(0.5, 164),
  AdvancedAnalysisPoint(0.6, 167),
  AdvancedAnalysisPoint(0.7, 163),
  AdvancedAnalysisPoint(0.8, 165),
  AdvancedAnalysisPoint(0.9, 168),
  AdvancedAnalysisPoint(1.0, 166),
];

const advancedAnalysisPaceStats = [
  AdvancedAnalysisStatData('Avg Pace', '6’30”', '/km'),
  AdvancedAnalysisStatData('Fastest Pace', '5’58”', '/km', hot: true),
  AdvancedAnalysisStatData('Slowest Pace', '7’05”', '/km'),
  AdvancedAnalysisStatData('Pace Stability', '86', '%'),
];

const advancedAnalysisHeartRateStats = [
  AdvancedAnalysisStatData('Avg Heart Rate', '145', 'bpm'),
  AdvancedAnalysisStatData('Max Heart Rate', '158', 'bpm'),
  AdvancedAnalysisStatData('Target Zone', '130–150', 'bpm'),
  AdvancedAnalysisStatData('Time in Zone', '72', '%'),
];

const advancedAnalysisCadenceStats = [
  AdvancedAnalysisStatData('Avg Cadence', '164', 'spm'),
  AdvancedAnalysisStatData('Target Range', '160–175', 'spm'),
  AdvancedAnalysisStatData('Stride Consistency', 'Stable', ''),
  AdvancedAnalysisStatData('Cadence Status', 'Good', ''),
];

const advancedAnalysisSplits = [
  AdvancedAnalysisSplitData('1 km', '6’24”'),
  AdvancedAnalysisSplitData('2 km', '6’33”'),
  AdvancedAnalysisSplitData('3 km', '6’41”'),
  AdvancedAnalysisSplitData('4 km', '6’21”', fastest: true),
  AdvancedAnalysisSplitData('4.03 km', '0’16”', partial: true),
];

const advancedAnalysisRecoveryFacts = [
  AdvancedAnalysisRecoveryFactData(
    icon: Icons.access_time_rounded,
    label: 'Recovery Level',
    value: 'Light',
  ),
  AdvancedAnalysisRecoveryFactData(
    icon: Icons.directions_run_rounded,
    label: 'Stretching',
    value: '5–8 min',
  ),
  AdvancedAnalysisRecoveryFactData(
    icon: Icons.water_drop_outlined,
    label: 'Hydration',
    value: 'Drink water',
  ),
  AdvancedAnalysisRecoveryFactData(
    icon: Icons.schedule_rounded,
    label: 'Next Run Readiness',
    value: 'Ready in 24 hours',
  ),
];

class AdvancedAnalysisPoint {
  const AdvancedAnalysisPoint(this.x, this.y);

  final double x;
  final double y;
}

class AdvancedAnalysisStatData {
  const AdvancedAnalysisStatData(
    this.label,
    this.value,
    this.unit, {
    this.hot = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool hot;
}

class AdvancedAnalysisSplitData {
  const AdvancedAnalysisSplitData(
    this.km,
    this.pace, {
    this.fastest = false,
    this.partial = false,
  });

  final String km;
  final String pace;
  final bool fastest;
  final bool partial;
}

class AdvancedAnalysisRecoveryFactData {
  const AdvancedAnalysisRecoveryFactData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
