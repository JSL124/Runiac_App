import '../models/friends_read_model.dart';

abstract interface class FriendsRepository {
  Future<FriendsOverviewReadModel> loadFriendsOverview();
}
