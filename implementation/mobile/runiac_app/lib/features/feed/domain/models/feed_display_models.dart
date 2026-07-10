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
      routeThumbnail: routeThumbnail,
      activityTitle: activityTitle,
      routeName: routeName,
    );
  }
}

/// Privacy-safe route preview data for a Feed post.
///
/// This model identifies a pre-rendered preview only. It intentionally keeps
/// route geometry and precise location data outside the client display model.
class FeedRouteThumbnailReadModel {
  const FeedRouteThumbnailReadModel({
    required this.thumbnailKey,
    required this.accessibilityLabel,
  });

  final String thumbnailKey;
  final String accessibilityLabel;
}
