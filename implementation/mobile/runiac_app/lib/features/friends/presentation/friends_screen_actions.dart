part of 'friends_screen.dart';

extension _FriendsScreenActions on _FriendsScreenState {
  void _sendRequest(FriendUserReadModel user) {
    _runMutation(
      actionKey: 'send:${user.userId}',
      action: (ownerUid) => _controller.repository.sendFriendRequest(
        ownerUid: ownerUid,
        targetUid: user.userId,
      ),
    );
  }

  void _respondToRequest(
    FriendUserReadModel user,
    FriendRequestResponseAction response,
  ) {
    _runMutation(
      actionKey: 'request:${user.userId}',
      action: (ownerUid) => _controller.repository.respondToFriendRequest(
        ownerUid: ownerUid,
        senderUid: user.userId,
        action: response,
      ),
    );
  }

  void _cancelRequest(FriendUserReadModel user) {
    _runMutation(
      actionKey: 'request:${user.userId}',
      action: (ownerUid) => _controller.repository.cancelFriendRequest(
        ownerUid: ownerUid,
        targetUid: user.userId,
      ),
    );
  }

  Future<void> _showFriendActions(FriendUserReadModel user) async {
    final action = await showFriendActionsSheet(context, user);
    if (!mounted || action == null) return;
    final isRemove = action == FriendAction.remove;
    final confirmed = await showFriendActionConfirmation(
      context,
      title: isRemove
          ? 'Remove ${user.displayName}?'
          : 'Block ${user.displayName}?',
      body: friendActionConfirmationBody(action),
      confirmLabel: isRemove ? 'Remove Friend' : 'Block',
    );
    if (!confirmed || !mounted) return;
    await _runMutation(
      actionKey: 'social:${user.userId}',
      action: (ownerUid) => isRemove
          ? _controller.repository.removeFriend(
              ownerUid: ownerUid,
              friendUid: user.userId,
            )
          : _controller.repository.blockUser(
              ownerUid: ownerUid,
              targetUid: user.userId,
            ),
    );
  }

  Future<void> _confirmUnblock(FriendUserReadModel user) async {
    final confirmed = await showFriendActionConfirmation(
      context,
      title: 'Unblock ${user.displayName}?',
      body: 'Unblocking does not restore a friendship or request.',
      confirmLabel: 'Unblock',
      isDestructive: false,
    );
    if (!confirmed || !mounted) return;
    await _runMutation(
      actionKey: 'unblock:${user.userId}',
      action: (ownerUid) => _controller.repository.unblockUser(
        ownerUid: ownerUid,
        targetUid: user.userId,
      ),
    );
  }
}
