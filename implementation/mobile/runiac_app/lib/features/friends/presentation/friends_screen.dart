import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../you/presentation/widgets/you_segmented_control.dart';
import '../data/static_friends_repository.dart';
import '../domain/models/friends_read_model.dart';
import '../domain/repositories/friends_repository.dart';
import 'widgets/friends_rows.dart';

const List<String> _kFriendsTabLabels = [
  'Friends',
  'Search',
  'Suggested',
  'Requests',
];

/// Static Friends shell with Friends / Search / Suggested / Requests tabs.
///
/// Display-only: friend relationships, request state, and level labels are
/// backend-owned. Accept/Decline gestures only rearrange the local
/// session-scoped display lists; nothing is calculated or persisted, and the
/// client never writes `users/{uid}/friends`.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    required this.onBack,
    this.repository = const StaticFriendsRepository(),
    super.key,
  });

  final VoidCallback onBack;
  final FriendsRepository repository;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late Future<FriendsOverviewReadModel> _overviewFuture;
  final TextEditingController _searchController = TextEditingController();

  int _tabIndex = 0;

  // Session-local mutable copies for the accept/decline display gesture.
  List<FriendUserReadModel>? _friends;
  List<FriendUserReadModel>? _requests;

  @override
  void initState() {
    super.initState();
    _overviewFuture = widget.repository.loadFriendsOverview();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _ensureMutableLists(FriendsOverviewReadModel overview) {
    _friends ??= List<FriendUserReadModel>.of(overview.friends);
    _requests ??= List<FriendUserReadModel>.of(overview.incomingRequests);
  }

  void _acceptRequest(FriendUserReadModel user) {
    setState(() {
      _requests?.remove(user);
      _friends?.insert(0, user);
    });
  }

  void _declineRequest(FriendUserReadModel user) {
    setState(() {
      _requests?.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        child: Column(
          children: [
            RuniacBackHeader(title: 'Friends', onBack: widget.onBack),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: YouSegmentedControl(
                labels: _kFriendsTabLabels,
                selected: _tabIndex,
                compact: true,
                onTap: (index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<FriendsOverviewReadModel>(
                future: _overviewFuture,
                builder: (context, snapshot) {
                  final overview = snapshot.data;
                  if (overview == null) {
                    return const Center(
                      child: Text(
                        'Loading friends...',
                        style: TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }
                  _ensureMutableLists(overview);
                  return _buildTabBody(overview);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(FriendsOverviewReadModel overview) {
    switch (_tabIndex) {
      case 1:
        return _buildSearchTab(overview);
      case 2:
        return _buildUserList(
          users: overview.recommended,
          emptyTitle: 'No suggestions yet',
          emptyBody: 'Suggested runners will appear here as you keep running.',
        );
      case 3:
        return _buildRequestsTab();
      default:
        return _buildUserList(
          users: _friends ?? overview.friends,
          emptyTitle: 'No friends yet',
          emptyBody: 'Runners you connect with will appear here.',
        );
    }
  }

  Widget _buildUserList({
    required List<FriendUserReadModel> users,
    required String emptyTitle,
    required String emptyBody,
  }) {
    if (users.isEmpty) {
      return FriendsEmptyState(title: emptyTitle, body: emptyBody);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => FriendUserRow(user: users[index]),
    );
  }

  Widget _buildSearchTab(FriendsOverviewReadModel overview) {
    final query = _searchController.text.trim().toLowerCase();
    final results = query.isEmpty
        ? const <FriendUserReadModel>[]
        : [
            for (final user in overview.searchableUsers)
              if (user.displayName.toLowerCase().contains(query)) user,
          ];

    Widget body;
    if (query.isEmpty) {
      body = const FriendsEmptyState(
        title: 'Find runners',
        body: 'Search runners by name to connect with them.',
      );
    } else if (results.isEmpty) {
      body = const FriendsEmptyState(
        title: 'No runners found',
        body: 'Try a different name or check the spelling.',
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => FriendUserRow(user: results[index]),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Semantics(
            label: 'Search runners',
            textField: true,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search runners',
                hintText: 'Type a runner name',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: RuniacColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }

  Widget _buildRequestsTab() {
    final requests = _requests ?? const <FriendUserReadModel>[];
    if (requests.isEmpty) {
      return const FriendsEmptyState(
        title: 'No pending requests',
        body: 'New friend requests will appear here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = requests[index];
        return FriendRequestRow(
          user: user,
          onAccept: () => _acceptRequest(user),
          onDecline: () => _declineRequest(user),
        );
      },
    );
  }
}
