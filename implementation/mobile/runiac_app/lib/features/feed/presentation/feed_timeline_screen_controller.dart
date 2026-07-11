import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../domain/models/feed_display_models.dart';
import '../domain/repositories/feed_repository.dart';
import 'current_session_feed_fallback.dart';
import 'current_session_feed_store.dart';
import 'current_session_feed_timeline.dart';
import 'widgets/feed_sheets.dart';

class FeedTimelineScreenController extends ChangeNotifier {
  FeedTimelineScreenController(this._repository, this._viewerContext) {
    scrollController.addListener(_loadMoreNearEnd);
  }

  final FeedRepository _repository;
  final FeedViewerContext? _viewerContext;
  final ScrollController scrollController = ScrollController();
  final _fallback = CurrentSessionFeedFallback();
  final Set<String> _requestedThumbnails = <String>{};
  List<FeedPostReadModel> _posts = const [];
  CurrentSessionFeedStore? _sessionStore;
  FeedTimelineState? _state;
  int _ownerRevision = 0, _refreshGeneration = 0;
  bool _hasLoaded = false, _loadingMore = false, _commentSheetOpen = false;
  bool _disposed = false;
  String? _loadError;
  CurrentSessionFeedTimeline get _timeline =>
      CurrentSessionFeedTimeline(_repository);
  bool get isProduction => _timeline.isProduction;
  bool get hasLoaded => _hasLoaded;
  FeedTimelineState? get timelineState => _state;
  String? get loadError => _loadError;
  bool get commentSheetOpen => _commentSheetOpen;
  List<FeedPostReadModel> get posts => <FeedPostReadModel>[
    if (!isProduction) ...?_sessionStore?.sessionPosts,
    ..._posts,
  ];

  void attachSession(CurrentSessionFeedStore? store) {
    _sessionStore = store;
    _ownerRevision = store?.ownerRevision ?? 0;
  }

  bool clearForOwnerChange() {
    if (_disposed) return false;
    final nextRevision = _sessionStore?.ownerRevision ?? 0;
    if (nextRevision == _ownerRevision) return false;
    _ownerRevision = nextRevision;
    _fallback.clear();
    _notify();
    return true;
  }

  Future<void> refresh() async {
    final generation = ++_refreshGeneration;
    final viewer =
        _viewerContext ??
        (!isProduction
            ? const FeedViewerContext(
                currentUserId: 'runner-current',
                acceptedFriendUserIds: <String>{'runner-friend'},
              )
            : null);
    if (viewer == null) return _showEmpty();
    try {
      final feed = await _timeline.load(
        viewerContext: viewer,
        hasLoaded: _hasLoaded,
      );
      if (!_disposed && generation == _refreshGeneration) _apply(feed);
    } catch (_) {
      if (!_disposed && generation == _refreshGeneration) _showError();
    }
  }

  Future<void> loadMore() async {
    final state = _state;
    if (!isProduction ||
        state == null ||
        state.exhausted ||
        state.refreshing ||
        _loadingMore) {
      return;
    }
    _loadingMore = true;
    try {
      _apply(await _timeline.loadMore());
    } catch (_) {
      _showError();
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    if (isProduction) {
      final next = await _timeline.toggleLike(posts: _posts, postId: postId);
      if (next != null && !_disposed) {
        _posts = next;
        _notify();
      }
      return;
    }
    if (_sessionStore?.toggleLike(postId) ?? false) return;
    _posts = _fallback.toggleLike(posts: _posts, postId: postId);
    _notify();
  }

  Future<void> openComments(BuildContext context, FeedPostReadModel post) {
    if (!post.canComment || !mutationsEnabled) return Future<void>.value();
    _commentSheetOpen = true;
    final comments = _timeline.comments;
    return showFeedCommentSheet(
      context: context,
      sheet: comments == null
          ? FeedCommentSheet.fromFallback(
              post,
              _viewerContext?.currentUserId,
              FeedCommentFallback(
                comments: _fallback.commentsFor(post.postId),
                onSubmitted: (body) => _addComment(post.postId, body),
              ),
            )
          : FeedCommentSheet.fromRepository(
              post,
              comments,
              _viewerContext?.currentUserId,
            ),
    ).whenComplete(() => _commentSheetOpen = false);
  }

  bool get mutationsEnabled => _state?.mutationsEnabled ?? true;

  Future<void> showOptions(BuildContext context, FeedPostReadModel post) =>
      showCurrentSessionFeedPostOptions(
        context,
        post.showsOwnerMenu
            ? FeedPostOptionsSheet.owner(() => deletePost(post.postId))
            : FeedPostOptionsSheet.reporter(
                isProduction ? () => reportPost(post.postId) : null,
              ),
      );

  Future<void> _addComment(String postId, String body) async {
    if (isProduction) {
      await _timeline.createComment(
        FeedCommentMutation(postId: postId, commentId: null, body: body),
      );
      return;
    }
    _fallback.addComment(postId, body);
    if (!(_sessionStore?.addComment(postId) ?? false)) {
      _posts = _fallback.addCommentCount(posts: _posts, postId: postId);
    }
    _notify();
  }

  Future<bool> deletePost(String postId) async {
    if (isProduction) return _applyMutation(await _timeline.deletePost(postId));
    if (_sessionStore?.removePost(postId) ?? false) {
      _fallback.removePost(postId);
    } else {
      _posts = _fallback.removeFrom(_posts, postId);
      _fallback.removePost(postId);
    }
    notifyListeners();
    return true;
  }

  Future<bool> reportPost(String postId) async =>
      _applyMutation(await _timeline.reportPost(postId));

  bool _applyMutation(List<FeedPostReadModel>? next) {
    if (_disposed || next == null) return false;
    _posts = next;
    _notify();
    return true;
  }

  void _apply(FeedReadModel feed) {
    if (_disposed) return;
    _posts = feed.posts;
    _state = feed is FeedTimelineState ? feed : null;
    _fallback.clearForPosts(feed.posts);
    _loadError = null;
    _hasLoaded = true;
    _notify();
    if (_state?.source == FeedTimelineSource.server) {
      for (final post in _posts) {
        _requestThumbnail(post);
      }
    }
  }

  void _showEmpty() {
    if (_disposed) return;
    _posts = const [];
    _state = null;
    _hasLoaded = true;
    _notify();
  }

  void _showError() {
    if (_disposed) return;
    _loadError = 'Feed could not refresh.';
    _hasLoaded = true;
    _notify();
  }

  void _loadMoreNearEnd() {
    if (scrollController.hasClients &&
        scrollController.position.extentAfter < 240) {
      unawaited(loadMore());
    }
  }

  void _requestThumbnail(FeedPostReadModel post) {
    if (post.routeThumbnail.pngBytes == null &&
        _requestedThumbnails.add(post.postId)) {
      unawaited(_readThumbnail(post.postId));
    }
  }

  Future<void> _readThumbnail(String postId) async {
    final Uint8List? bytes = await _timeline.readThumbnail(postId);
    if (_disposed || bytes == null || bytes.lengthInBytes < 8) return;
    _posts = _posts
        .map(
          (post) => post.postId == postId
              ? post.copyWith(
                  routeThumbnail: post.routeThumbnail.copyWith(pngBytes: bytes),
                )
              : post,
        )
        .toList(growable: false);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
  @override
  void dispose() {
    _disposed = true;
    scrollController.removeListener(_loadMoreNearEnd);
    scrollController.dispose();
    super.dispose();
  }
}
