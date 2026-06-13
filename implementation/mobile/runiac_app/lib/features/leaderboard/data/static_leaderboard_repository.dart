import '../domain/models/leaderboard_read_model.dart';
import '../domain/repositories/leaderboard_repository.dart';
import '../presentation/data/leaderboard_demo_snapshots.dart';
import '../presentation/models/leaderboard_display_models.dart';

class StaticLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardReadModel> loadLeaderboard() async {
    return LeaderboardReadModel(
      regionLabel: leaderboardDetailDemoSnapshot.regionName,
      currentRunnerRankLabel:
          leaderboardDetailDemoSnapshot.currentUser.rankLabel,
      entries: [
        ..._rowsFromDisplaySnapshots(leaderboardDetailDemoSnapshot.topRanks),
        ..._rowsFromDisplaySnapshots(leaderboardDetailDemoSnapshot.nearbyRanks),
      ],
    );
  }
}

List<LeaderboardRowReadModel> _rowsFromDisplaySnapshots(
  List<LeaderboardRankRowDisplaySnapshot> snapshots,
) {
  return [
    for (final snapshot in snapshots)
      LeaderboardRowReadModel(
        userId: _userIdFromDisplayName(snapshot.name),
        displayName: snapshot.name,
        rankLabel: snapshot.rankLabel,
        scoreLabel: snapshot.xpLabel,
        levelLabel: snapshot.levelLabel,
        divisionLabel: leaderboardDetailDemoSnapshot.divisionLabel,
        regionLabel: leaderboardDetailDemoSnapshot.regionName,
      ),
  ];
}

String _userIdFromDisplayName(String displayName) {
  final normalized = displayName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return 'leaderboard-$normalized';
}
