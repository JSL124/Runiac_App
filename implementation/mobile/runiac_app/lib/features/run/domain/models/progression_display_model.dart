class ProgressionDisplayModel {
  const ProgressionDisplayModel({
    required this.xpDelta,
    required this.countsTowardLeaderboard,
    required this.status,
    required this.reason,
  });

  final int xpDelta;
  final bool countsTowardLeaderboard;
  final String status;
  final String reason;
}
