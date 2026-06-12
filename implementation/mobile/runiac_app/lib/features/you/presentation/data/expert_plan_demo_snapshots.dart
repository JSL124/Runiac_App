import 'package:flutter/material.dart';

// Display-only expert plan previews. These are not publication, approval,
// eligibility, enrollment, or subscription state.
const expertPlanFilters = [
  'Recommended',
  '5K',
  '10K',
  'Consistency',
  'Healthy Running',
  'Half',
  'Full',
];

const expertPlans = [
  ExpertPlanDisplay(
    icon: Icons.directions_run,
    title: 'First 5K Preparation',
    description: 'A gentle plan for building confidence toward your first 5K.',
    duration: '6 weeks',
    frequency: '3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Running Coach',
  ),
  ExpertPlanDisplay(
    icon: Icons.repeat,
    title: 'Build Running Consistency',
    description:
        'Create a steady running habit with balanced, achievable workouts.',
    duration: '4 weeks',
    frequency: '2–3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Fitness Trainer',
  ),
  ExpertPlanDisplay(
    icon: Icons.flag_outlined,
    title: '10K Preparation',
    description: 'Build endurance and confidence for a comfortable 10K.',
    duration: '8 weeks',
    frequency: '3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Running Coach',
  ),
  ExpertPlanDisplay(
    icon: Icons.favorite_border,
    title: 'Healthy Running Starter Plan',
    description:
        'Build a healthier running routine with steady, low-pressure sessions.',
    duration: '3 weeks',
    frequency: '3 runs/week',
    level: 'Beginner',
    reviewer: 'Reviewed by Health Advisor',
  ),
  ExpertPlanDisplay(
    icon: Icons.terrain_outlined,
    title: 'Half Marathon Preparation',
    description: 'Step up gradually with a longer-distance plan.',
    duration: '12 weeks',
    frequency: '3–4 runs/week',
    level: 'Intermediate',
    reviewer: 'Reviewed by Running Coach',
  ),
  ExpertPlanDisplay(
    icon: Icons.landscape_outlined,
    title: 'Full Marathon Preparation',
    description: 'A longer plan for experienced runners preparing for 42.2K.',
    duration: '18 weeks',
    frequency: '4–5 runs/week',
    level: 'Advanced',
    reviewer: 'Reviewed by Running Coach',
  ),
];

const expertPlanDetailSnapshot = ExpertPlanDetailSnapshot(
  title: 'First 5K Preparation',
  subtitle: 'A gentle plan for building confidence toward your first 5K.',
  duration: '6 weeks',
  frequency: '3 runs/week',
  level: 'Beginner',
  pressure: 'Low pressure',
  coachInsight:
      'This plan is designed to help beginners build consistency gradually. Take rest days seriously, keep the effort comfortable, and adjust if something does not feel right.',
  weeklyPreview: [
    ExpertPlanWeekPreview('Week 1', 'Walk-run basics', [
      '2 walk-run sessions',
      '1 easy recovery walk',
      'Rest between run days',
    ]),
    ExpertPlanWeekPreview('Week 2', 'Build easy intervals', [
      'Short easy intervals',
      'Comfortable walking breaks',
      'Focus on showing up consistently',
    ]),
    ExpertPlanWeekPreview('Week 3', 'Longer easy running', [
      'Slightly longer easy run blocks',
      'Gentle warm-up and cool-down',
      'Keep the effort conversational',
    ]),
    ExpertPlanWeekPreview('Week 4', 'Steady rhythm', [
      'Build a steady weekly rhythm',
      'Repeat familiar run-walk structure',
      'Use rest days to recover',
    ]),
    ExpertPlanWeekPreview('Week 5', 'Confidence week', [
      'Practice relaxed continuous effort',
      'Keep pace comfortable',
      'Notice progress without pressure',
    ]),
    ExpertPlanWeekPreview('Week 6', 'First 5K attempt', [
      'Easy preparation run',
      'Rest before your attempt',
      'Complete your first 5K at a comfortable effort',
    ]),
  ],
);

class ExpertPlanDisplay {
  const ExpertPlanDisplay({
    required this.icon,
    required this.title,
    required this.description,
    required this.duration,
    required this.frequency,
    required this.level,
    required this.reviewer,
  });

  final IconData icon;
  final String title;
  final String description;
  final String duration;
  final String frequency;
  final String level;
  final String reviewer;
}

class ExpertPlanDetailSnapshot {
  const ExpertPlanDetailSnapshot({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.frequency,
    required this.level,
    required this.pressure,
    required this.coachInsight,
    required this.weeklyPreview,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String frequency;
  final String level;
  final String pressure;
  final String coachInsight;
  final List<ExpertPlanWeekPreview> weeklyPreview;
}

class ExpertPlanWeekPreview {
  const ExpertPlanWeekPreview(this.weekLabel, this.title, this.bullets);

  final String weekLabel;
  final String title;
  final List<String> bullets;
}
