part of 'feed_comment_sheet.dart';

/// Renders the state-owned comment page with the sheet scroll controller.
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
                    TextButton(onPressed: _loadInitial, child: const Text('Try again')),
                  ],
                ),
              )
            : _comments.isEmpty
            ? Center(
                child: Text(
                  widget._source.repository != null
                      ? 'No comments yet.'
                      : 'No new comments yet.',
                  style: YouTextStyles.smallBody,
                ),
              )
            : ListView.builder(
                key: ValueKey('feed-comment-list-${widget._source.post.postId}'),
                controller: controller,
                itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _comments.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final comment = _comments[index];
                  final ownsComment =
                      comment.authorUserId == widget._source.viewerUserId;
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    key: ValueKey('feed-comment-${comment.commentId}'),
                    title: Text(
                      comment.authorDisplayName,
                      style: YouTextStyles.smallStrong,
                    ),
                    subtitle: Text(comment.body, style: YouTextStyles.smallBody),
                    trailing: ownsComment && !_isOffline && !_isSubmitting
                        ? Wrap(
                            children: [
                              IconButton(
                                key: ValueKey('feed-comment-edit-${comment.commentId}'),
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _beginEdit(comment),
                              ),
                              IconButton(
                                key: ValueKey('feed-comment-delete-${comment.commentId}'),
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(comment),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              ),
      );
}
