import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_notification_inbox_repository.dart';

class CloudFirestoreNotificationInboxDocumentStore
    implements NotificationInboxDocumentStore {
  CloudFirestoreNotificationInboxDocumentStore({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _items(String uid) {
    return _firestore
        .collection('notificationInbox')
        .doc(uid)
        .collection('items');
  }

  @override
  Stream<List<NotificationInboxDocument>> watchInboxItems({
    required String uid,
  }) {
    return _items(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => _fromSnapshot(document))
              .where((document) => document != null)
              .cast<NotificationInboxDocument>()
              .toList(growable: false),
        );
  }

  @override
  Future<void> markRead({
    required String uid,
    required String itemId,
    required DateTime readAt,
  }) {
    return _items(uid).doc(itemId).update({
      'readAt': Timestamp.fromDate(readAt.toUtc()),
      'updatedAt': Timestamp.fromDate(DateTime.now().toUtc()),
    });
  }

  @override
  Future<void> softDelete({
    required String uid,
    required String itemId,
    required DateTime deletedAt,
  }) {
    return _items(uid).doc(itemId).update({
      'deletedAt': Timestamp.fromDate(deletedAt.toUtc()),
      'updatedAt': Timestamp.fromDate(DateTime.now().toUtc()),
    });
  }

  NotificationInboxDocument? _fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final createdAt = _readTimestamp(data['createdAt']);
    final title = data['title'];
    final body = data['body'];
    if (createdAt == null || title is! String || body is! String) {
      return null;
    }

    return NotificationInboxDocument(
      id: snapshot.id,
      title: title,
      body: body,
      createdAt: createdAt,
      readAt: _readTimestamp(data['readAt']),
      deletedAt: _readTimestamp(data['deletedAt']),
      data: _readMap(data['data']),
    );
  }

  DateTime? _readTimestamp(Object? value) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime dateTime => dateTime,
      _ => null,
    };
  }

  Map<String, Object?> _readMap(Object? value) {
    if (value is! Map) {
      return const <String, Object?>{};
    }
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
}
