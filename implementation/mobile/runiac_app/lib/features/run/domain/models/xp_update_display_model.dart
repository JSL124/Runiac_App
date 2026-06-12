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
