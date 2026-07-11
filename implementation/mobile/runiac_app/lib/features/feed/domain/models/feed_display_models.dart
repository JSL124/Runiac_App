import 'dart:typed_data';

/// Read-only viewer context used to scope a Feed read.
class FeedViewerContext {
  const FeedViewerContext({
    required this.currentUserId,
    required this.acceptedFriendUserIds,
  });

  final String currentUserId;
  final Set<String> acceptedFriendUserIds;
}

/// Read-only collection returned by a Feed repository.
class FeedReadModel {
  FeedReadModel({required List<FeedPostReadModel> posts})
    : posts = List.unmodifiable(posts);

  final List<FeedPostReadModel> posts;
}

/// The source of the currently displayed Feed snapshot.
enum FeedTimelineSource { server, cachedOffline }

/// Typed state for a stable, paginated Feed timeline.
///
/// [posts] only contains display-safe post snapshots. It deliberately has no
/// profile, route geometry, entitlement, or competitive data.
class FeedTimelineState extends FeedReadModel {
  FeedTimelineState({
    required super.posts,
    required this.source,
    required this.refreshing,
    required this.exhausted,
    this.recoverableError,
  });

  final FeedTimelineSource source;
  final bool refreshing;
  final bool exhausted;
  final FeedRecoverableError? recoverableError;

  bool get mutationsEnabled => source == FeedTimelineSource.server;
}

/// Non-sensitive error payload suitable for an inline retry affordance.
class FeedRecoverableError {
  const FeedRecoverableError({required this.code, required this.message});

  final String code;
  final String message;
}

/// Display-only Feed post details loaded into a local Feed session.
class FeedPostReadModel {
  const FeedPostReadModel({
    required this.postId,
    required this.authorUserId,
    required this.authorDisplayName,
    required this.authorAvatarInitials,
    required this.relativeTimeLabel,
    required this.distanceLabel,
    required this.paceLabel,
    required this.durationLabel,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByViewer,
    required this.hasViewerCommented,
    required this.canComment,
    required this.showsOwnerMenu,
    required this.routeThumbnail,
    this.activityTitle,
    this.routeName,
  });

  final String postId;
  final String authorUserId;
  final String authorDisplayName;
  final String authorAvatarInitials;
  final String relativeTimeLabel;
  final String distanceLabel;
  final String paceLabel;
  final String durationLabel;
  final int likeCount;
  final int commentCount;
  final bool isLikedByViewer;
  final bool hasViewerCommented;
  final bool canComment;
  final bool showsOwnerMenu;
  final FeedRouteThumbnailReadModel routeThumbnail;
  final String? activityTitle;
  final String? routeName;

  String get likeCountLabel =>
      '$likeCount ${likeCount == 1 ? 'like' : 'likes'}';

  String get commentCountLabel {
    if (commentCount == 0) {
      return 'No comments';
    }
    return '$commentCount ${commentCount == 1 ? 'comment' : 'comments'}';
  }

  FeedPostReadModel copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLikedByViewer,
    bool? hasViewerCommented,
    FeedRouteThumbnailReadModel? routeThumbnail,
  }) {
    return FeedPostReadModel(
      postId: postId,
      authorUserId: authorUserId,
      authorDisplayName: authorDisplayName,
      authorAvatarInitials: authorAvatarInitials,
      relativeTimeLabel: relativeTimeLabel,
      distanceLabel: distanceLabel,
      paceLabel: paceLabel,
      durationLabel: durationLabel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByViewer: isLikedByViewer ?? this.isLikedByViewer,
      hasViewerCommented: hasViewerCommented ?? this.hasViewerCommented,
      canComment: canComment,
      showsOwnerMenu: showsOwnerMenu,
      routeThumbnail: routeThumbnail ?? this.routeThumbnail,
      activityTitle: activityTitle,
      routeName: routeName,
    );
  }
}

/// Cursor used only for deterministic Feed post ordering.
class FeedPostCursor {
  const FeedPostCursor({required this.createdAt, required this.postId});

  final DateTime createdAt;
  final String postId;
}

/// Client-owned comment fields; aggregate counts remain server-owned.
class FeedCommentMutation {
  const FeedCommentMutation({
    required this.postId,
    required this.commentId,
    required this.body,
  });

  final String postId;
  final String? commentId;
  final String body;
}

/// A display-safe, flat Feed comment returned by a trusted comment query.
class FeedCommentReadModel {
  const FeedCommentReadModel({
    required this.commentId,
    required this.authorUserId,
    required this.authorDisplayName,
    required this.authorAvatarInitials,
    required this.body,
    required this.createdAt,
  });

  final String commentId;
  final String authorUserId;
  final String authorDisplayName;
  final String authorAvatarInitials;
  final String body;
  final DateTime createdAt;

  FeedCommentReadModel copyWith({String? body}) => FeedCommentReadModel(
    commentId: commentId,
    authorUserId: authorUserId,
    authorDisplayName: authorDisplayName,
    authorAvatarInitials: authorAvatarInitials,
    body: body ?? this.body,
    createdAt: createdAt,
  );
}

/// Stable newest-first comment cursor: `(createdAt, commentId)` descending.
class FeedCommentCursor {
  const FeedCommentCursor({required this.createdAt, required this.commentId});

  final DateTime createdAt;
  final String commentId;
}

/// One bounded comment page. Counts remain authoritative on the post stream.
class FeedCommentPage {
  FeedCommentPage({
    required List<FeedCommentReadModel> comments,
    required this.source,
    required this.exhausted,
  }) : comments = List.unmodifiable(comments);

  final List<FeedCommentReadModel> comments;
  final FeedTimelineSource source;
  final bool exhausted;

  bool get mutationsEnabled => source == FeedTimelineSource.server;
}

/// Privacy-safe route preview data for a Feed post.
///
/// This model identifies a pre-rendered preview only. It intentionally keeps
/// route geometry and precise location data outside the client display model.
class FeedRouteThumbnailReadModel {
  const FeedRouteThumbnailReadModel({
    required this.thumbnailKey,
    required this.accessibilityLabel,
    this.pngBytes,
  });

  final String thumbnailKey;
  final String accessibilityLabel;
  final Uint8List? pngBytes;

  FeedRouteThumbnailReadModel copyWith({Uint8List? pngBytes}) =>
      FeedRouteThumbnailReadModel(
        thumbnailKey: thumbnailKey,
        accessibilityLabel: accessibilityLabel,
        pngBytes: pngBytes ?? this.pngBytes,
      );
}
