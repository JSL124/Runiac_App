import 'package:flutter/material.dart';

import '../../domain/models/feed_display_models.dart';
import 'feed_post_section.dart';
import 'feed_status_message.dart';

class FeedPostList extends StatelessWidget {
  const FeedPostList({
    required this.hasLoaded,
    required this.loadErrorMessage,
    required this.posts,
    required this.onRetry,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onOptionsPressed,
    super.key,
  });

  final bool hasLoaded;
  final String? loadErrorMessage;
  final List<FeedPostReadModel> posts;
  final VoidCallback onRetry;
  final ValueChanged<String> onLikePressed;
  final ValueChanged<FeedPostReadModel> onCommentPressed;
  final ValueChanged<FeedPostReadModel> onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    if (!hasLoaded) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: const [
          SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    final errorMessage = loadErrorMessage;
    if (errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          FeedStatusMessage(
            title: errorMessage,
            body: 'Pull down or tap retry to load friends posts.',
            action: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: const [
          FeedStatusMessage(
            title: 'No shared runs yet.',
            body: 'Runs shared by you and accepted friends will appear here.',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return FeedPostSection(
          post: post,
          onLikePressed: () => onLikePressed(post.postId),
          onCommentPressed: () => onCommentPressed(post),
          onOptionsPressed: () => onOptionsPressed(post),
        );
      },
    );
  }
}
