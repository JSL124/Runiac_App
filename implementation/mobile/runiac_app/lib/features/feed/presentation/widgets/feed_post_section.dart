import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../you/presentation/widgets/you_surface_primitives.dart';
import '../../domain/models/feed_display_models.dart';
import 'feed_engagement_action.dart';
import 'feed_route_thumbnail.dart';

class FeedPostSection extends StatelessWidget {
  const FeedPostSection({
    required this.post,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onOptionsPressed,
    super.key,
  });

  final FeedPostReadModel post;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 10, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: RuniacColors.sectionSurfaceStrong,
                foregroundColor: RuniacColors.primaryBlue,
                child: Text(
                  post.authorAvatarInitials,
                  style: YouTextStyles.smallStrong.copyWith(
                    color: RuniacColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorDisplayName,
                      style: YouTextStyles.bodyStrong,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.relativeTimeLabel,
                      style: YouTextStyles.smallBody,
                    ),
                  ],
                ),
              ),
              _FeedPostOptions(onPressed: onOptionsPressed),
            ],
          ),
        ),
        if (post.activityTitle != null || post.routeName != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.activityTitle != null)
                  Text(post.activityTitle!, style: YouTextStyles.bodyStrong),
                if (post.routeName != null) ...[
                  const SizedBox(height: 2),
                  Text(post.routeName!, style: YouTextStyles.smallBody),
                ],
              ],
            ),
          ),
        FeedRouteThumbnail(thumbnail: post.routeThumbnail),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _FeedMetricsRow(post: post),
        ),
        const Divider(
          height: 28,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: RuniacColors.border,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FeedEngagementAction(
                label: 'Like ${post.likeCountLabel}',
                icon: post.isLikedByViewer
                    ? Icons.favorite
                    : Icons.favorite_border,
                value: post.likeCountLabel,
                highlighted: post.isLikedByViewer,
                enabled: true,
                onPressed: onLikePressed,
                actionKey: ValueKey('feed-like-action-${post.postId}'),
              ),
              const SizedBox(width: 22),
              FeedEngagementAction(
                label: 'Comment ${post.commentCountLabel}',
                icon: post.hasViewerCommented
                    ? Icons.mode_comment
                    : Icons.mode_comment_outlined,
                value: post.commentCountLabel,
                highlighted: post.hasViewerCommented,
                enabled: post.canComment,
                onPressed: onCommentPressed,
                actionKey: ValueKey('feed-comment-action-${post.postId}'),
              ),
            ],
          ),
        ),
        Container(
          key: ValueKey('feed-post-divider-${post.postId}'),
          height: 1,
          color: RuniacColors.border,
        ),
      ],
    );
  }
}

class _FeedPostOptions extends StatelessWidget {
  const _FeedPostOptions({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Post options',
      button: true,
      container: true,
      child: ExcludeSemantics(
        child: IconButton(
          icon: const Icon(Icons.more_horiz),
          tooltip: 'Post options',
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _FeedMetricsRow extends StatelessWidget {
  const _FeedMetricsRow({required this.post});

  final FeedPostReadModel post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FeedMetric(label: 'Distance', value: post.distanceLabel),
        const _FeedMetricDivider(),
        _FeedMetric(label: 'Pace', value: post.paceLabel),
        const _FeedMetricDivider(),
        _FeedMetric(label: 'Time', value: post.durationLabel),
      ],
    );
  }
}

class _FeedMetric extends StatelessWidget {
  const _FeedMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: YouTextStyles.smallBody),
          const SizedBox(height: 3),
          Text(value, style: YouTextStyles.bodyStrong),
        ],
      ),
    );
  }
}

class _FeedMetricDivider extends StatelessWidget {
  const _FeedMetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: RuniacColors.border,
    );
  }
}
