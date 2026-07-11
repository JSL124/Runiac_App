import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/models/feed_display_models.dart';
import '../comments/firebase_feed_comment_page_port.dart';
import 'feed_data_port.dart';
import 'firebase_feed_post_mapper.dart';

class FeedAuthorQueryShape {
  const FeedAuthorQueryShape({
    required this.authorUid,
    required this.status,
    required this.limit,
  });

  final String authorUid;
  final String status;
  final int limit;
}

abstract interface class FeedQueryObserver {
  void onAuthorQuery(FeedAuthorQueryShape shape);
}

/// FlutterFire adapter that makes only per-author Feed reads.
class FirebaseFeedDataPort implements FeedDataPort {
  FirebaseFeedDataPort({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    this.queryObserver,
  }) : _firestoreOverride = firestore,
       _functionsOverride = functions;

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseFunctions? _functionsOverride;
  final FeedQueryObserver? queryObserver;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;
  FirebaseFunctions get _functions =>
      _functionsOverride ??
      FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  @override
  Future<FeedIdPage> pageAcceptedFriends({
    required String viewerUid,
    String? afterDocumentId,
  }) => _pageIds(
    _firestore.collection('users').doc(viewerUid).collection('friends'),
    afterDocumentId,
  );

  @override
  Future<FeedIdPage> pageHiddenPostIds({
    required String viewerUid,
    String? afterDocumentId,
  }) => _pageIds(
    _firestore.collection('users').doc(viewerUid).collection('hiddenFeedPosts'),
    afterDocumentId,
  );

  @override
  Future<FeedPostPage> pagePublishedPosts({
    required String authorUid,
    required String viewerUid,
    FeedPostCursor? after,
  }) => guardAuthorPage(authorUid, () async {
    queryObserver?.onAuthorQuery(
      FeedAuthorQueryShape(
        authorUid: authorUid,
        status: 'published',
        limit: 20,
      ),
    );
    Query<Map<String, Object?>> query = _firestore
        .collection('feedPosts')
        .where('authorUid', isEqualTo: authorUid)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(20);
    if (after != null) {
      query = query.startAfter(<Object>[
        after.createdAt.toUtc().toIso8601String(),
        after.postId,
      ]);
    }
    final snapshot = await query.get();
    final posts = await Future.wait(
      snapshot.docs.map(
        (document) => FirebaseFeedPostMapper.map(document, viewerUid),
      ),
    );
    final last = snapshot.docs.isEmpty ? null : posts.last;
    return FeedPostPage(
      posts: posts,
      fromCache: snapshot.metadata.isFromCache,
      nextCursor: last == null
          ? null
          : FeedPostCursor(createdAt: last.createdAt, postId: last.postId),
    );
  });

  @override
  Future<FeedCommentDocumentPage> pageComments({
    required String postId,
    FeedCommentCursor? startAfter,
  }) => FirebaseFeedCommentPagePort.load(
    firestore: _firestore,
    postId: postId,
    startAfter: startAfter,
  );

  static Future<T> guardAuthorPage<T>(
    String authorUid,
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw FeedAuthorPermissionDenied(authorUid);
      }
      rethrow;
    }
  }

  @override
  Future<void> setViewerLike({
    required String viewerUid,
    required String postId,
    required bool isLiked,
  }) {
    final reference = _firestore
        .collection('feedPosts')
        .doc(postId)
        .collection('likes')
        .doc(viewerUid);
    return isLiked
        ? reference.set(<String, Object>{
            'userUid': viewerUid,
            'createdAt': FieldValue.serverTimestamp(),
          })
        : reference.delete();
  }

  @override
  Future<void> createComment({
    required String viewerUid,
    required FeedCommentMutation mutation,
  }) async {
    final profile = await _firestore
        .collection('userProfiles')
        .doc(viewerUid)
        .get();
    final profileData = profile.data();
    final displayName = profileData?['displayName'];
    final avatarInitials = profileData?['avatarInitials'];
    if (displayName is! String ||
        displayName.isEmpty ||
        avatarInitials is! String ||
        avatarInitials.isEmpty) {
      throw const FormatException('Comment author profile is invalid.');
    }
    final reference = _firestore
        .collection('feedPosts')
        .doc(mutation.postId)
        .collection('comments')
        .doc();
    await reference.set(<String, Object>{
      'authorUid': viewerUid,
      'authorDisplayName': displayName,
      'authorAvatarInitials': avatarInitials,
      'body': mutation.body,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateComment({
    required String viewerUid,
    required FeedCommentMutation mutation,
  }) {
    final commentId = mutation.commentId;
    if (commentId == null) throw ArgumentError.value(commentId, 'commentId');
    return _firestore
        .collection('feedPosts')
        .doc(mutation.postId)
        .collection('comments')
        .doc(commentId)
        .update(<String, Object>{
          'body': mutation.body,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> deleteComment({
    required String viewerUid,
    required String postId,
    required String commentId,
  }) => _firestore
      .collection('feedPosts')
      .doc(postId)
      .collection('comments')
      .doc(commentId)
      .delete();

  @override
  Future<void> callPostAction({
    required String action,
    required String postId,
  }) {
    return _functions.httpsCallable(action).call(<String, Object>{
      'postId': postId,
    });
  }

  @override
  Future<Uint8List> readThumbnail(String postId) async {
    final result = await _functions.httpsCallable('readFeedThumbnail').call(
      <String, Object>{'postId': postId},
    );
    final raw = result.data;
    if (raw is! Map<Object?, Object?> || raw['base64Png'] is! String) {
      throw const FormatException('Feed thumbnail response is invalid.');
    }
    return Uint8List.fromList(base64Decode(raw['base64Png']! as String));
  }

  Future<FeedIdPage> _pageIds(
    CollectionReference<Map<String, Object?>> collection,
    String? afterDocumentId,
  ) async {
    Query<Map<String, Object?>> query = collection
        .orderBy(FieldPath.documentId)
        .limit(30);
    if (afterDocumentId != null) {
      query = query.startAfter(<Object>[afterDocumentId]);
    }
    final snapshot = await query.get();
    return FeedIdPage(
      ids: snapshot.docs.map((document) => document.id).toList(growable: false),
      fromCache: snapshot.metadata.isFromCache,
      nextDocumentId: snapshot.docs.length == 30 ? snapshot.docs.last.id : null,
    );
  }
}
