import '../models/feed_display_models.dart';
import 'dart:typed_data';

abstract interface class FeedRepository {
  /// Compatibility read used by the existing static Feed UI.
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext);
}

/// Stateful Feed contract used by the Firebase-backed production path.
abstract interface class FeedTimelineRepository implements FeedRepository {
  FeedTimelineState get currentState;
  Future<FeedTimelineState> loadInitial(FeedViewerContext viewerContext);
  Future<FeedTimelineState> loadMore();
  Future<FeedTimelineState> refresh();
  Future<FeedTimelineState> reconcileAccess();
  Future<void> setLike({required String postId, required bool isLiked});
  Future<void> createComment(FeedCommentMutation mutation);
  Future<void> updateComment(FeedCommentMutation mutation);
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
  Future<void> reportPost(String postId);
  Future<void> deletePost(String postId);
  Future<Uint8List> readThumbnail(String postId);
  void dispose();
}

/// Narrow read boundary for the paginated flat-comments sheet.
abstract interface class FeedCommentsRepository {
  Future<FeedCommentPage> loadComments({
    required String postId,
    FeedCommentCursor? startAfter,
  });
  Future<void> createComment(FeedCommentMutation mutation);
  Future<void> updateComment(FeedCommentMutation mutation);
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
}
