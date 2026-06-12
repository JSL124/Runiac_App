import '../../domain/models/run_summary_snapshot.dart';
import '../../domain/models/xp_update_display_model.dart';

/// Display-only run summary snapshot for the static run completion surface.
const defaultRunSummarySnapshot = RunSummarySnapshot(
  title: 'Saturday Morning Run',
  dateLabel: 'Today',
  timeLabel: '7:06 AM',
  distanceKm: '4.03',
  avgPace: '6’30”',
  duration: '30:15',
  avgHeartRate: '145',
  calories: '145',
  routeName: 'East Coast Park Loop',
);

/// Display-only result labels for the static run completion surface.
///
/// Production progression values should be supplied by backend-owned results.
const defaultXpUpdateDisplayModel = XpUpdateDisplayModel(
  runnerName: 'Jinseo',
  earnedXpLabel: '+120 XP',
  totalXpLabel: '2,520 XP',
  levelLabel: '12',
  nextLevelLabel: '13',
  progressTargetLabel: 'Progress to Lv.13',
  xpRemainingLabel: '600 XP to go',
  previousProgressFraction: 0.52,
  currentProgressFraction: 0.60,
  streakChangeLabel: '5 → 6 days',
  streakNote: 'Great consistency!',
  didLevelUp: false,
);
