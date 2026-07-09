/// Backend-produced leaderboard display contract.
///
/// Rank, score, XP, weekly/monthly XP, level, division, and region values are
/// read-only backend outputs for the Flutter client.
class LeaderboardReadModel {
  LeaderboardReadModel({
    required this.regionLabel,
    required this.currentRunnerRankLabel,
    required List<LeaderboardRowReadModel> entries,
    this.periodEndsAt,
    this.periodLabel,
  }) : entries = List.unmodifiable(entries);

  final String regionLabel;
  final String currentRunnerRankLabel;
  final List<LeaderboardRowReadModel> entries;
  final DateTime? periodEndsAt;
  final String? periodLabel;
}

/// Backend-produced leaderboard row display contract.
class LeaderboardRowReadModel {
  const LeaderboardRowReadModel({
    required this.userId,
    required this.displayName,
    required this.rankLabel,
    required this.scoreLabel,
    this.levelLabel = '',
    this.divisionLabel = '',
    this.regionLabel = '',
  });

  final String userId;
  final String displayName;
  final String rankLabel;
  final String scoreLabel;
  final String levelLabel;
  final String divisionLabel;
  final String regionLabel;
}
