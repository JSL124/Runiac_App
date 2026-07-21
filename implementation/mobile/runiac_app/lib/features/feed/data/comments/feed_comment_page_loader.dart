import '../../domain/models/feed_display_models.dart';
import '../firebase_feed_repository/feed_author_level_resolver.dart';
import '../firebase_feed_repository/feed_data_port.dart';

/// Maps the constrained repository boundary into display-safe comment pages.
class FeedCommentPageLoader {
  const FeedCommentPageLoader._();

  static Future<FeedCommentPage> load({
    required FeedDataPort port,
    required String postId,
    required FeedAuthorLevelResolver levelResolver,
    FeedCommentCursor? startAfter,
  }) async {
    final page = await port.pageComments(
      postId: postId,
      startAfter: startAfter,
    );
    final authorUids = {
      for (final comment in page.comments) comment.authorUid,
    };
    await levelResolver.ensureResolved(authorUids);
    return FeedCommentPage(
      comments: page.comments
          .map((comment) {
            final resolved = levelResolver[comment.authorUid];
            final hasResolvedLabel =
                resolved != null && resolved.levelLabel.trim().isNotEmpty;
            return FeedCommentReadModel(
              commentId: comment.commentId,
              authorUserId: comment.authorUid,
              authorDisplayName: comment.authorDisplayName,
              authorAvatarInitials: comment.authorAvatarInitials,
              authorLevelLabel: hasResolvedLabel
                  ? resolved.levelLabel
                  : comment.authorLevelLabel,
              authorLevelProgressFraction: hasResolvedLabel
                  ? resolved.levelProgressFraction
                  : null,
              body: comment.body,
              createdAt: comment.createdAt,
            );
          })
          .toList(growable: false),
      source: page.fromCache
          ? FeedTimelineSource.cachedOffline
          : FeedTimelineSource.server,
      exhausted: page.nextCursor == null,
    );
  }
}
