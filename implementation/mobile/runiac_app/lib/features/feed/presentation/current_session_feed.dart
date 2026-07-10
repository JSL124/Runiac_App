import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../data/static_feed_repository.dart';
import '../domain/models/feed_display_models.dart';
import '../domain/repositories/feed_repository.dart';
import 'current_session_feed_store.dart';
import 'widgets/feed_header.dart';
import 'widgets/feed_post_list.dart';
import 'widgets/feed_sheets.dart';

export 'current_session_feed_store.dart';

class CurrentSessionFeed extends StatefulWidget {
  const CurrentSessionFeed({
    this.repository = const StaticFeedRepository(),
    super.key,
  });

  final FeedRepository repository;

  @override
  State<CurrentSessionFeed> createState() => _CurrentSessionFeedState();
}

class _CurrentSessionFeedState extends State<CurrentSessionFeed> {
  static const _viewerContext = FeedViewerContext(
    currentUserId: 'runner-current',
    acceptedFriendUserIds: <String>{'runner-friend'},
  );

  List<FeedPostReadModel> _posts = const [];
  final Map<String, List<String>> _sessionComments = {};
  CurrentSessionFeedStore? _sessionFeedStore;
  bool _isCommentSheetOpen = false;
  var _sessionFeedOwnerRevision = 0;
  var _hasLoaded = false;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextStore = CurrentSessionFeedScope.maybeOf(context);
    if (_sessionFeedStore == nextStore) {
      return;
    }
    _sessionFeedStore?.removeListener(_clearSessionComments);
    _sessionFeedStore = nextStore;
    _sessionFeedOwnerRevision = nextStore?.ownerRevision ?? 0;
    _sessionFeedStore?.addListener(_clearSessionComments);
  }

  @override
  void dispose() {
    _sessionFeedStore?.removeListener(_clearSessionComments);
    super.dispose();
  }

  void _clearSessionComments() {
    final ownerRevision = _sessionFeedStore?.ownerRevision ?? 0;
    if (_sessionFeedOwnerRevision == ownerRevision) {
      return;
    }
    _sessionFeedOwnerRevision = ownerRevision;
    if (_isCommentSheetOpen) {
      Navigator.of(context).pop();
      _isCommentSheetOpen = false;
    }
    if (_sessionComments.isEmpty || !mounted) {
      return;
    }
    setState(_sessionComments.clear);
  }

  Future<void> _refresh() async {
    try {
      final feed = await widget.repository.loadFeed(_viewerContext);
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = feed.posts;
        for (final post in feed.posts) {
          _sessionComments.remove(post.postId);
        }
        _loadErrorMessage = null;
        _hasLoaded = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadErrorMessage = 'Feed could not refresh.';
        _hasLoaded = true;
      });
    }
  }

  void _toggleLike(String postId) {
    final sessionFeedStore = CurrentSessionFeedScope.maybeRead(context);
    if (sessionFeedStore?.toggleLike(postId) ?? false) {
      return;
    }
    setState(() {
      _posts = _posts
          .map((post) {
            if (post.postId != postId) {
              return post;
            }
            final isLiked = !post.isLikedByViewer;
            return post.copyWith(
              isLikedByViewer: isLiked,
              likeCount: post.likeCount + (isLiked ? 1 : -1),
            );
          })
          .toList(growable: false);
    });
  }

  void _addComment(String postId, String comment, int ownerRevision) {
    final currentOwnerRevision =
        CurrentSessionFeedScope.maybeRead(context)?.ownerRevision ?? 0;
    if (ownerRevision != currentOwnerRevision ||
        _sessionFeedOwnerRevision != currentOwnerRevision) {
      return;
    }
    setState(() {
      _sessionComments[postId] = [
        ...(_sessionComments[postId] ?? const []),
        comment,
      ];
      final sessionFeedStore = CurrentSessionFeedScope.maybeRead(context);
      if (sessionFeedStore?.addComment(postId) ?? false) {
        return;
      }
      _posts = _posts
          .map((post) {
            if (post.postId != postId) {
              return post;
            }
            return post.copyWith(
              commentCount: post.commentCount + 1,
              hasViewerCommented: true,
            );
          })
          .toList(growable: false);
    });
  }

  void _removePost(String postId) {
    final sessionFeedStore = CurrentSessionFeedScope.maybeRead(context);
    if (sessionFeedStore?.removePost(postId) ?? false) {
      setState(() {
        _sessionComments.remove(postId);
      });
      return;
    }
    setState(() {
      _posts = _posts
          .where((post) => post.postId != postId)
          .toList(growable: false);
      _sessionComments.remove(postId);
    });
  }

  Future<void> _openComments(FeedPostReadModel post) {
    if (!post.canComment) {
      return Future<void>.value();
    }
    final ownerRevision =
        CurrentSessionFeedScope.maybeRead(context)?.ownerRevision ?? 0;
    _isCommentSheetOpen = true;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FeedCommentSheet(
        post: post,
        sessionComments: _sessionComments[post.postId] ?? const [],
        onSubmitted: (comment) =>
            _addComment(post.postId, comment, ownerRevision),
      ),
    ).whenComplete(() => _isCommentSheetOpen = false);
  }

  Future<void> _openPostOptions(FeedPostReadModel post) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => FeedPostOptionsSheet(
        showsOwnerMenu: post.showsOwnerMenu,
        onDelete: () {
          Navigator.of(sheetContext).pop();
          _removePost(post.postId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionPosts =
        CurrentSessionFeedScope.maybeOf(context)?.sessionPosts ??
        const <FeedPostReadModel>[];
    final posts = <FeedPostReadModel>[...sessionPosts, ..._posts];

    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FeedHeader(),
            ),
            Expanded(
              child: RefreshIndicator(
                semanticsLabel: 'Pull to refresh feed',
                onRefresh: _refresh,
                child: FeedPostList(
                  hasLoaded: _hasLoaded,
                  loadErrorMessage: _loadErrorMessage,
                  posts: posts,
                  onRetry: _refresh,
                  onLikePressed: _toggleLike,
                  onCommentPressed: _openComments,
                  onOptionsPressed: _openPostOptions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
