/// Display-only friends read contracts.
///
/// Friend relationships, request state, and level labels are backend-owned.
/// The client renders pre-formatted display strings only; it never derives
/// levels, XP, rank, or streak values and never writes friend relationship
/// state. The static shell serves demo snapshots until a trusted backend
/// read model replaces them.
class FriendUserReadModel {
  const FriendUserReadModel({
    required this.userId,
    required this.displayName,
    required this.avatarInitials,
    required this.levelLabel,
    required this.subtitleLabel,
  });

  final String userId;
  final String displayName;
  final String avatarInitials;

  /// Pre-formatted backend-owned display string, e.g. `'Lv.12'`.
  /// Never computed on the client.
  final String levelLabel;

  /// Short supporting display copy, e.g. a favourite running area.
  final String subtitleLabel;
}

/// One display snapshot covering all Friends screen tabs.
class FriendsOverviewReadModel {
  const FriendsOverviewReadModel({
    required this.friends,
    required this.recommended,
    required this.incomingRequests,
    required this.searchableUsers,
  });

  /// Accepted friends, display order supplied by the source.
  final List<FriendUserReadModel> friends;

  /// Suggested runners the user may want to add.
  final List<FriendUserReadModel> recommended;

  /// Incoming friend requests awaiting a local accept/decline gesture.
  final List<FriendUserReadModel> incomingRequests;

  /// Users discoverable through the Search tab.
  final List<FriendUserReadModel> searchableUsers;
}
