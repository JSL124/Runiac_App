import 'package:flutter/material.dart';

import '../../run/domain/models/run_summary_snapshot.dart';
import '../domain/models/feed_display_models.dart';

class CurrentSessionFeedStore extends ChangeNotifier {
  CurrentSessionFeedStore({String? ownerUid}) : this._withOwner(ownerUid);

  CurrentSessionFeedStore._withOwner(this._ownerUid);

  final List<FeedPostReadModel> _sessionPosts = <FeedPostReadModel>[];
  var _nextPostSequence = 1;
  var _ownerRevision = 0;
  String? _ownerUid;

  List<FeedPostReadModel> get sessionPosts => List.unmodifiable(_sessionPosts);
  int get ownerRevision => _ownerRevision;

  void syncOwner(String? ownerUid) {
    if (_ownerUid == ownerUid) {
      return;
    }
    _ownerUid = ownerUid;
    _ownerRevision += 1;
    _sessionPosts.clear();
    _nextPostSequence = 1;
    notifyListeners();
  }

  void shareRunSummary(RunSummarySnapshot summary) {
    _sessionPosts.insert(
      0,
      FeedPostReadModel(
        postId: 'feed-session-${_nextPostSequence++}',
        authorUserId: 'runner-current',
        authorDisplayName: 'Runiac Runner',
        authorAvatarInitials: 'RR',
        relativeTimeLabel: summary.dateTimeLabel,
        activityTitle: summary.title,
        routeName: summary.routeName,
        distanceLabel: '${summary.distanceKm} km',
        paceLabel: '${summary.avgPace} / km',
        durationLabel: summary.duration,
        likeCount: 0,
        commentCount: 0,
        isLikedByViewer: false,
        hasViewerCommented: false,
        canComment: true,
        showsOwnerMenu: true,
        routeThumbnail: const FeedRouteThumbnailReadModel(
          thumbnailKey: 'session-shared-route',
          accessibilityLabel: 'A simplified shared route preview',
        ),
      ),
    );
    notifyListeners();
  }

  bool toggleLike(String postId) {
    final index = _sessionPosts.indexWhere((post) => post.postId == postId);
    if (index == -1) {
      return false;
    }
    final post = _sessionPosts[index];
    final isLiked = !post.isLikedByViewer;
    _sessionPosts[index] = post.copyWith(
      isLikedByViewer: isLiked,
      likeCount: post.likeCount + (isLiked ? 1 : -1),
    );
    notifyListeners();
    return true;
  }

  bool addComment(String postId) {
    final index = _sessionPosts.indexWhere((post) => post.postId == postId);
    if (index == -1) {
      return false;
    }
    final post = _sessionPosts[index];
    _sessionPosts[index] = post.copyWith(
      commentCount: post.commentCount + 1,
      hasViewerCommented: true,
    );
    notifyListeners();
    return true;
  }

  bool removePost(String postId) {
    final beforeCount = _sessionPosts.length;
    _sessionPosts.removeWhere((post) => post.postId == postId);
    if (_sessionPosts.length == beforeCount) {
      return false;
    }
    notifyListeners();
    return true;
  }
}

class CurrentSessionFeedScope
    extends InheritedNotifier<CurrentSessionFeedStore> {
  const CurrentSessionFeedScope({
    required CurrentSessionFeedStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static CurrentSessionFeedStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CurrentSessionFeedScope>()
        ?.notifier;
  }

  static CurrentSessionFeedStore? maybeRead(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<CurrentSessionFeedScope>()
        ?.notifier;
  }
}
