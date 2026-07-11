import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed_data_port.dart';

class FirebaseFeedPostMapper {
  const FirebaseFeedPostMapper._();

  static Future<FeedPostDocument> map(
    QueryDocumentSnapshot<Map<String, Object?>> document,
    String viewerUid,
  ) async {
    final post = _from(document.id, document.data());
    final reference = document.reference;
    final liked = await reference.collection('likes').doc(viewerUid).get();
    final comments = await reference
        .collection('comments')
        .where('authorUid', isEqualTo: viewerUid)
        .limit(1)
        .get();
    return FeedPostDocument(
      postId: post.postId,
      authorUid: post.authorUid,
      authorDisplayName: post.authorDisplayName,
      authorAvatarInitials: post.authorAvatarInitials,
      createdAt: post.createdAt,
      distanceMeters: post.distanceMeters,
      durationSeconds: post.durationSeconds,
      averagePaceSecondsPerKm: post.averagePaceSecondsPerKm,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      viewerLiked: liked.exists,
      viewerCommented: comments.docs.isNotEmpty,
    );
  }

  static FeedPostDocument _from(String id, Map<String, Object?> data) =>
      FeedPostDocument(
        postId: id,
        authorUid: _string(data, 'authorUid'),
        authorDisplayName: _string(data, 'authorDisplayName'),
        authorAvatarInitials: _string(data, 'authorAvatarInitials'),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        distanceMeters: _int(data, 'distanceMeters'),
        durationSeconds: _int(data, 'durationSeconds'),
        averagePaceSecondsPerKm: _int(data, 'averagePaceSecondsPerKm'),
        likeCount: _int(data, 'likeCount'),
        commentCount: _int(data, 'commentCount'),
        viewerLiked: false,
        viewerCommented: false,
      );

  static String _string(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Feed post field $key is invalid.');
  }

  static int _int(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is int && value >= 0) return value;
    throw FormatException('Feed post field $key is invalid.');
  }
}
