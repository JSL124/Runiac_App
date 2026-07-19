import '../../domain/models/feed_display_models.dart';
import '../firebase_feed_repository/feed_data_port.dart';

/// Maps the constrained repository boundary into display-safe comment pages.
class FeedCommentPageLoader {
  const FeedCommentPageLoader._();

  static Future<FeedCommentPage> load({
    required FeedDataPort port,
    required String postId,
    FeedCommentCursor? startAfter,
  }) async {
    final page = await port.pageComments(
      postId: postId,
      startAfter: startAfter,
    );
    return FeedCommentPage(
      comments: page.comments
          .map(
            (comment) => FeedCommentReadModel(
              commentId: comment.commentId,
              authorUserId: comment.authorUid,
              authorDisplayName: comment.authorDisplayName,
              authorAvatarInitials: comment.authorAvatarInitials,
              authorLevelLabel: comment.authorLevelLabel,
              body: comment.body,
              createdAt: comment.createdAt,
            ),
          )
          .toList(growable: false),
      source: page.fromCache
          ? FeedTimelineSource.cachedOffline
          : FeedTimelineSource.server,
      exhausted: page.nextCursor == null,
    );
  }
}
