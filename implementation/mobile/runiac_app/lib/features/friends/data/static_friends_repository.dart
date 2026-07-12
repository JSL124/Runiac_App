import '../domain/models/friends_read_model.dart';
import '../domain/repositories/friends_repository.dart';
import '../presentation/data/friends_demo_snapshots.dart';

/// Static display-only friends source for the Safe Visible Product
/// Acceleration shell. Serves const demo snapshots; a future backend-owned
/// repository replaces this seam without changing the presentation layer.
class StaticFriendsRepository implements FriendsRepository {
  const StaticFriendsRepository();

  @override
  Future<FriendsOverviewReadModel> loadFriendsOverview() async {
    return friendsOverviewDemoSnapshot;
  }
}
