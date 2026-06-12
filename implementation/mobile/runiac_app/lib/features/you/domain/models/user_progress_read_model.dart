/// Backend-produced user progress display contract.
///
/// XP, streak, level, rank, leaderboard score, and subscription privilege
/// state are backend-owned outputs, not client-side trusted state.
class UserProgressReadModel {
  const UserProgressReadModel({
    required this.userId,
    required this.streakLabel,
    required this.levelLabel,
    required this.totalXpLabel,
    required this.weeklyXpLabel,
    required this.monthlyXpLabel,
    required this.weeklyDistanceLabel,
    required this.goalProgressLabel,
  });

  final String userId;
  final String streakLabel;
  final String levelLabel;
  final String totalXpLabel;
  final String weeklyXpLabel;
  final String monthlyXpLabel;
  final String weeklyDistanceLabel;
  final String goalProgressLabel;
}
