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
  streakChangeLabel: '5 \u2192 6 days',
  streakNote: 'Great consistency!',
  didLevelUp: false,
);

class XpUpdateDisplayModel {
  const XpUpdateDisplayModel({
    required this.runnerName,
    required this.earnedXpLabel,
    required this.totalXpLabel,
    required this.levelLabel,
    required this.nextLevelLabel,
    required this.progressTargetLabel,
    required this.xpRemainingLabel,
    required this.previousProgressFraction,
    required this.currentProgressFraction,
    required this.streakChangeLabel,
    required this.streakNote,
    required this.didLevelUp,
  });

  final String runnerName;
  final String earnedXpLabel;
  final String totalXpLabel;
  final String levelLabel;
  final String nextLevelLabel;
  final String progressTargetLabel;
  final String xpRemainingLabel;
  final double previousProgressFraction;
  final double currentProgressFraction;
  final String streakChangeLabel;
  final String streakNote;
  final bool didLevelUp;
}
