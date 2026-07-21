import 'dart:typed_data';

import '../../domain/models/feed_display_models.dart';

/// Raised only when a single author's query is no longer authorized.
class FeedAuthorPermissionDenied implements Exception {
  const FeedAuthorPermissionDenied(this.authorUid);

  final String authorUid;
}

/// A page of trusted documents with an opaque, stable document-id cursor.
class FeedIdPage {
  const FeedIdPage({
    required this.ids,
    required this.fromCache,
    this.nextDocumentId,
  });

  final List<String> ids;
  final bool fromCache;
  final String? nextDocumentId;
}

/// A minimal post projection. It excludes private profiles and route data.
class FeedPostDocument {
  const FeedPostDocument({
    required this.postId,
    required this.authorUid,
    required this.authorDisplayName,
    required this.authorAvatarInitials,
    required this.authorLevelLabel,
    required this.createdAt,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.averagePaceSecondsPerKm,
    required this.likeCount,
    required this.commentCount,
    required this.viewerLiked,
    required this.viewerCommented,
  });

  final String postId;
  final String authorUid;
  final String authorDisplayName;
  final String authorAvatarInitials;
  final String authorLevelLabel;
  final DateTime createdAt;
  final int distanceMeters;
  final int durationSeconds;
  final int averagePaceSecondsPerKm;
  final int likeCount;
  final int commentCount;
  final bool viewerLiked;
  final bool viewerCommented;
}

class FeedPostPage {
  const FeedPostPage({
    required this.posts,
    required this.fromCache,
    this.nextCursor,
  });

  final List<FeedPostDocument> posts;
  final bool fromCache;
  final FeedPostCursor? nextCursor;
}

/// Firestore projection for one flat comment. It contains no replies or
/// reaction state, intentionally keeping the social contract narrow.
class FeedCommentDocument {
  const FeedCommentDocument({
    required this.commentId,
    required this.authorUid,
    required this.authorDisplayName,
    required this.authorAvatarInitials,
    required this.authorLevelLabel,
    required this.body,
    required this.createdAt,
  });

  final String commentId;
  final String authorUid;
  final String authorDisplayName;
  final String authorAvatarInitials;
  final String authorLevelLabel;
  final String body;
  final DateTime createdAt;
}

class FeedCommentDocumentPage {
  const FeedCommentDocumentPage({
    required this.comments,
    required this.fromCache,
    this.nextCursor,
  });

  final List<FeedCommentDocument> comments;
  final bool fromCache;
  final FeedCommentCursor? nextCursor;
}

/// A live, backend-owned author level snapshot resolved at display time.
///
/// A post or comment's stored `authorLevelLabel` is frozen at publish time
/// and can go stale, or be entirely absent on older content. This type
/// carries the author's CURRENT level as returned by the backend so the
/// client can overlay it. The client only transports and renders these
/// values; it never computes them.
class FeedAuthorLevel {
  const FeedAuthorLevel({
    required this.levelLabel,
    required this.levelProgressFraction,
  });

  final String levelLabel;

  /// 0.0..1.0, already converted from the backend's 0..100 percent.
  final double levelProgressFraction;
}

/// Typed Firestore/Functions boundary. Tests replace it without Firebase.
abstract interface class FeedDataPort {
  Future<FeedIdPage> pageAcceptedFriends({
    required String viewerUid,
    String? afterDocumentId,
  });

  Future<FeedIdPage> pageHiddenPostIds({
    required String viewerUid,
    String? afterDocumentId,
  });

  Future<FeedPostPage> pagePublishedPosts({
    required String authorUid,
    required String viewerUid,
    FeedPostCursor? after,
  });

  Future<FeedCommentDocumentPage> pageComments({
    required String postId,
    FeedCommentCursor? startAfter,
  });

  Future<void> setViewerLike({
    required String viewerUid,
    required String postId,
    required bool isLiked,
  });

  Future<void> createComment({
    required String viewerUid,
    required FeedCommentMutation mutation,
  });

  Future<void> updateComment({
    required String viewerUid,
    required FeedCommentMutation mutation,
  });

  Future<void> deleteComment({
    required String viewerUid,
    required String postId,
    required String commentId,
  });

  Future<void> callPostAction({required String action, required String postId});

  Future<Uint8List> readThumbnail(String postId);

  /// Resolves live author levels for [uids]. A uid the viewer may not see,
  /// or that the backend has no snapshot for, is simply absent from the
  /// result — callers must fall back to their own stored label.
  Future<Map<String, FeedAuthorLevel>> fetchAuthorLevels(List<String> uids);
}
