part of 'feed_comment_sheet.dart';

extension _FeedCommentList on _FeedCommentSheetState {
  Widget buildCommentList(ScrollController controller) =>
      NotificationListener<ScrollNotification>(
        onNotification: (notice) {
          if (notice.metrics.extentAfter < 160) _loadMore();
          return false;
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!, style: YouTextStyles.smallBody),
                    TextButton(
                      onPressed: _loadInitial,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            : _comments.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 32,
                      color: RuniacColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget._source.repository != null
                          ? 'No comments yet.'
                          : 'No new comments yet.',
                      style: YouTextStyles.smallStrong,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Start the conversation after this run.',
                      style: YouTextStyles.smallBody,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                key: ValueKey(
                  'feed-comment-list-${widget._source.post.postId}',
                ),
                controller: controller,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == _comments.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final comment = _comments[index];
                  final ownsComment =
                      widget._source.repository != null &&
                      comment.authorUserId == widget._source.viewerUserId;
                  return _CommentRow(
                    key: ValueKey('feed-comment-${comment.commentId}'),
                    comment: comment,
                    currentAuthorProfile: widget._source.currentAuthorProfile,
                    ownsComment: ownsComment,
                    actionsEnabled: !_isOffline && !_isSubmitting,
                    onOwnerActions: () => _showOwnerActions(comment),
                  );
                },
              ),
      );
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.comment,
    required this.currentAuthorProfile,
    required this.ownsComment,
    required this.actionsEnabled,
    required this.onOwnerActions,
    super.key,
  });

  final FeedCommentReadModel comment;
  final FeedAuthorProfileSnapshot? currentAuthorProfile;
  final bool ownsComment;
  final bool actionsEnabled;
  final VoidCallback onOwnerActions;

  @override
  Widget build(BuildContext context) {
    final authorProfile = comment.authorProfileFor(currentAuthorProfile);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: RuniacLevelProfileBadge(
            key: ValueKey('feed-comment-author-profile-${comment.commentId}'),
            initials: authorProfile.avatarInitials,
            levelLabel: authorProfile.compactLevelLabel,
            progressFraction: authorProfile.levelProgressFraction,
            size: 42,
            badgeHeight: 16,
            badgeMinWidth: 42,
            badgeHorizontalPadding: 6,
            badgeFontSize: 9,
            ringStrokeWidth: 4,
            discColor: RuniacColors.primaryBlue,
            discBorderColor: RuniacColors.white,
            initialsColor: RuniacColors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      comment.authorDisplayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: YouTextStyles.smallStrong,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    feedCommentAgeLabel(comment.createdAt, DateTime.now()),
                    style: YouTextStyles.smallBody,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.body,
                style: const TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (ownsComment)
          IconButton(
            key: ValueKey('feed-comment-menu-${comment.commentId}'),
            tooltip: 'Comment options',
            onPressed: actionsEnabled ? onOwnerActions : null,
            icon: const Icon(Icons.more_horiz),
            color: RuniacColors.textSecondary,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
