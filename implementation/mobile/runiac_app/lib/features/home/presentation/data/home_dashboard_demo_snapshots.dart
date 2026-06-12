import 'package:flutter/material.dart';

const homeDashboardDemoSnapshot = HomeDashboardDemoSnapshot(
  goal: HomeGoalProgressDemoSnapshot(
    title: 'First 10K Preparation',
    weekLabel: 'Week 3 of 8',
    progressLabel: '43%',
    milestoneLabel: 'Next Milestone',
    milestoneValue: 'Complete 6 km comfortably',
  ),
  streak: HomeMetricDemoSnapshot(
    title: 'Streak',
    value: '6 days',
    caption: 'Keep it going!',
  ),
  xp: HomeMetricDemoSnapshot(
    title: 'XP',
    value: '1,240 xp',
    caption: '360 XP to Lv.13',
  ),
  insight: HomeInsightDemoSnapshot(
    title: 'Advanced Insight',
    rows: [
      HomeInsightRowDemoSnapshot(
        icon: Icons.show_chart_rounded,
        label: 'Pace consistency',
        value: 'Improved',
      ),
      HomeInsightRowDemoSnapshot(
        icon: Icons.bar_chart_rounded,
        label: 'Training load',
        value: 'Balanced',
      ),
      HomeInsightRowDemoSnapshot(
        icon: Icons.track_changes_rounded,
        label: 'Goal forecast',
        value: 'On track',
      ),
    ],
    chartLabels: ['May 6', 'May 13', 'May 20', 'May 27', 'Jun 3'],
    chartValues: [0.42, 0.33, 0.18, 0.36, 0.55, 0.62, 0.72],
  ),
);

class HomeDashboardDemoSnapshot {
  const HomeDashboardDemoSnapshot({
    required this.goal,
    required this.streak,
    required this.xp,
    required this.insight,
  });

  final HomeGoalProgressDemoSnapshot goal;
  final HomeMetricDemoSnapshot streak;
  final HomeMetricDemoSnapshot xp;
  final HomeInsightDemoSnapshot insight;
}

class HomeGoalProgressDemoSnapshot {
  const HomeGoalProgressDemoSnapshot({
    required this.title,
    required this.weekLabel,
    required this.progressLabel,
    required this.milestoneLabel,
    required this.milestoneValue,
  });

  final String title;
  final String weekLabel;
  final String progressLabel;
  final String milestoneLabel;
  final String milestoneValue;
}

class HomeMetricDemoSnapshot {
  const HomeMetricDemoSnapshot({
    required this.title,
    required this.value,
    required this.caption,
  });

  final String title;
  final String value;
  final String caption;
}

class HomeInsightDemoSnapshot {
  const HomeInsightDemoSnapshot({
    required this.title,
    required this.rows,
    required this.chartLabels,
    required this.chartValues,
  });

  final String title;
  final List<HomeInsightRowDemoSnapshot> rows;
  final List<String> chartLabels;

  // Static display-only sample points for the preview chart.
  final List<double> chartValues;
}

class HomeInsightRowDemoSnapshot {
  const HomeInsightRowDemoSnapshot({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
