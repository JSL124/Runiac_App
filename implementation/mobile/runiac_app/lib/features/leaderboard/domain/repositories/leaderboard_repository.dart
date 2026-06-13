import '../models/leaderboard_read_model.dart';

abstract interface class LeaderboardRepository {
  Future<LeaderboardReadModel> loadLeaderboard();
}
