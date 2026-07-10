import 'package:flutter/material.dart';

import '../../../you/presentation/widgets/you_surface_primitives.dart';
import '../../domain/models/feed_display_models.dart';

class FeedCommentSheet extends StatefulWidget {
  const FeedCommentSheet({
    required this.post,
    required this.sessionComments,
    required this.onSubmitted,
    super.key,
  });

  final FeedPostReadModel post;
  final List<String> sessionComments;
  final ValueChanged<String> onSubmitted;

  @override
  State<FeedCommentSheet> createState() => _FeedCommentSheetState();
}

class _FeedCommentSheetState extends State<FeedCommentSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _comments = List.of(widget.sessionComments);

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!mounted) {
      return;
    }
    final comment = _controller.text.trim();
    if (comment.isEmpty) {
      return;
    }
    widget.onSubmitted(comment);
    setState(() {
      _comments = [..._comments, comment];
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Comments', style: YouTextStyles.bodyStrong),
            const SizedBox(height: 12),
            if (_comments.isEmpty)
              const Text('No new comments yet.', style: YouTextStyles.smallBody)
            else
              ..._comments.map(
                (comment) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(comment, style: YouTextStyles.smallStrong),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              key: ValueKey('feed-comment-input-${widget.post.postId}'),
              controller: _controller,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Add a comment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: ValueKey('feed-comment-submit-${widget.post.postId}'),
              onPressed: _canSubmit ? _submit : null,
              child: const Text('Comment'),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedPostOptionsSheet extends StatefulWidget {
  const FeedPostOptionsSheet({
    required this.showsOwnerMenu,
    required this.onDelete,
    super.key,
  });

  final bool showsOwnerMenu;
  final VoidCallback onDelete;

  @override
  State<FeedPostOptionsSheet> createState() => _FeedPostOptionsSheetState();
}

class _FeedPostOptionsSheetState extends State<FeedPostOptionsSheet> {
  var _reportSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _reportSubmitted
            ? const Text('Report submitted', style: YouTextStyles.bodyStrong)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Post options', style: YouTextStyles.bodyStrong),
                  const SizedBox(height: 8),
                  if (widget.showsOwnerMenu)
                    TextButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => setState(() => _reportSubmitted = true),
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Report'),
                    ),
                ],
              ),
      ),
    );
  }
}
