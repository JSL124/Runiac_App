/// Backend-produced user progress display contract.
///
/// XP, streak, level, rank, leaderboard score, and subscription privilege
/// state are backend-owned outputs, not client-side trusted state.
class UserProgressReadModel {
  const UserProgressReadModel({
    required this.userId,
    required this.officialStreakLabel,
    required this.levelLabel,
    required this.totalXpLabel,
    required this.weeklyXpLabel,
    required this.monthlyXpLabel,
    required this.weeklyDistanceLabel,
    required this.goalProgressLabel,
    this.level = 0,
    this.levelProgressFraction = 0,
    this.officialStreakCount,
    this.lastStreakRunDate,
  });

  final String userId;
  final String officialStreakLabel;
  final String levelLabel;
  final String totalXpLabel;
  final String weeklyXpLabel;
  final String monthlyXpLabel;
  final String weeklyDistanceLabel;
  final String goalProgressLabel;
  final int level;
  final double levelProgressFraction;
  final int? officialStreakCount;
  final String? lastStreakRunDate;

  String get levelBadgeLabel => 'Lv.$level';
}
