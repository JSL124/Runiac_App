import 'dart:typed_data';

import '../domain/models/feed_display_models.dart';
import '../domain/repositories/feed_repository.dart';

/// Keeps server-authoritative timeline mutations separate from session fallback.
class CurrentSessionFeedTimeline {
  const CurrentSessionFeedTimeline(this.repository);

  final FeedRepository repository;

  FeedTimelineRepository? get _timeline => repository is FeedTimelineRepository
      ? repository as FeedTimelineRepository
      : null;

  FeedCommentsRepository? get comments => repository is FeedCommentsRepository
      ? repository as FeedCommentsRepository
      : null;

  bool get isProduction => _timeline != null;

  Future<FeedReadModel> load({
    required FeedViewerContext viewerContext,
    required bool hasLoaded,
  }) {
    final timeline = _timeline;
    return timeline == null
        ? repository.loadFeed(viewerContext)
        : hasLoaded
        ? timeline.refresh()
        : timeline.loadInitial(viewerContext);
  }

  Future<FeedTimelineState> loadMore() {
    final timeline = _timeline;
    return timeline == null
        ? Future<FeedTimelineState>.error(StateError('No Feed timeline.'))
        : timeline.loadMore();
  }

  Future<List<FeedPostReadModel>?> toggleLike({
    required List<FeedPostReadModel> posts,
    required String postId,
  }) async {
    final timeline = _timeline;
    if (timeline == null || !timeline.currentState.mutationsEnabled) {
      return null;
    }
    final post = posts.where((item) => item.postId == postId).firstOrNull;
    if (post == null) {
      return null;
    }
    try {
      await timeline.setLike(postId: postId, isLiked: !post.isLikedByViewer);
      return timeline.currentState.posts;
    } catch (_) {
      return null;
    }
  }

  Future<void> createComment(FeedCommentMutation mutation) async {
    final timeline = _timeline;
    if (timeline == null || !timeline.currentState.mutationsEnabled) {
      return;
    }
    try {
      await timeline.createComment(mutation);
    } catch (_) {
      // The next server-backed refresh remains authoritative.
    }
  }

  Future<List<FeedPostReadModel>?> deletePost(String postId) async {
    final timeline = _timeline;
    if (timeline == null || !timeline.currentState.mutationsEnabled) {
      return null;
    }
    try {
      await timeline.deletePost(postId);
      return timeline.currentState.posts;
    } catch (_) {
      return null;
    }
  }

  Future<List<FeedPostReadModel>?> reportPost(String postId) async {
    final timeline = _timeline;
    if (timeline == null || !timeline.currentState.mutationsEnabled) {
      return null;
    }
    try {
      await timeline.reportPost(postId);
      return timeline.currentState.posts;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> readThumbnail(String postId) async {
    final timeline = _timeline;
    if (timeline == null ||
        timeline.currentState.source != FeedTimelineSource.server) {
      return null;
    }
    try {
      return await timeline.readThumbnail(postId);
    } catch (_) {
      return null;
    }
  }
}
