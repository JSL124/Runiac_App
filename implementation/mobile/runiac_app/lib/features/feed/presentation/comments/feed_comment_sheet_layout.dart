part of 'feed_comment_sheet.dart';

/// Renders the state-owned draggable comment surface without a parameter bag.
extension _FeedCommentSheetLayout on _FeedCommentSheetState {
  Widget buildCommentSheetLayout(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height,
    child: AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        controller: widget.sheetController,
        expand: false,
        minChildSize: .32,
        initialChildSize: .62,
        maxChildSize: .92,
        shouldCloseOnMinExtent: false,
        builder: (context, scrollController) => _body(scrollController),
      ),
    ),
  );

  Widget _body(ScrollController scrollController) => SafeArea(
    top: false,
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Comments', style: YouTextStyles.bodyStrong),
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Comments are read-only while offline.',
                style: YouTextStyles.smallBody,
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: buildCommentList(scrollController),
          ),
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_validationError!, style: YouTextStyles.smallBody),
            ),
          const SizedBox(height: 4),
          TextField(
            key: ValueKey('feed-comment-input-${widget._source.post.postId}'),
            controller: _controller,
            enabled: !_isOffline && !_isSubmitting,
            onChanged: (_) => _clearValidationError(),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: 'Add a comment',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: ValueKey('feed-comment-submit-${widget._source.post.postId}'),
            onPressed: _canSubmit ? _submit : null,
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size.fromHeight(36)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(_editingCommentId == null ? 'Comment' : 'Save edit'),
          ),
        ],
      ),
    ),
  );
}

Future<bool> confirmFeedCommentDelete(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This comment will be removed from this post.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
    false;
