import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/notifications/data/firestore_notification_inbox_repository.dart';

void main() {
  group('FirestoreNotificationInboxRepository', () {
    test('streams non-deleted inbox items newest first', () async {
      final store = _FakeNotificationInboxDocumentStore(
        items: [
          _document(
            id: 'deleted',
            title: 'Deleted',
            createdAt: DateTime.utc(2026, 7, 8, 9),
            deletedAt: DateTime.utc(2026, 7, 8, 10),
          ),
          _document(
            id: 'older',
            title: 'Older plan update',
            createdAt: DateTime.utc(2026, 7, 7, 9),
          ),
          _document(
            id: 'newer',
            title: 'Tomorrow run reminder',
            createdAt: DateTime.utc(2026, 7, 8, 8),
          ),
        ],
      );
      final repository = FirestoreNotificationInboxRepository(
        ownerUid: 'runner-1',
        documentStore: store,
      );

      final items = await repository.watchInboxItems().first;

      expect(store.watchedUids, ['runner-1']);
      expect(items.map((item) => item.id), ['newer', 'older']);
      expect(items.first.title, 'Tomorrow run reminder');
    });

    test('streams unread count from non-deleted unread items only', () async {
      final repository = FirestoreNotificationInboxRepository(
        ownerUid: 'runner-1',
        documentStore: _FakeNotificationInboxDocumentStore(
          items: [
            _document(id: 'unread-1'),
            _document(id: 'read', readAt: DateTime.utc(2026, 7, 8, 8)),
            _document(id: 'unread-2'),
            _document(id: 'deleted', deletedAt: DateTime.utc(2026, 7, 8, 9)),
          ],
        ),
      );

      await expectLater(repository.watchUnreadCount(), emits(2));
    });

    test('marks an inbox item read through the owner-scoped store', () async {
      final store = _FakeNotificationInboxDocumentStore();
      final repository = FirestoreNotificationInboxRepository(
        ownerUid: 'runner-1',
        documentStore: store,
        clock: () => DateTime.utc(2026, 7, 8, 12),
      );

      await repository.markRead('item-1');

      expect(store.markReadCalls, [
        _WriteCall('runner-1', 'item-1', DateTime.utc(2026, 7, 8, 12)),
      ]);
    });

    test('soft deletes an inbox item by writing deletedAt', () async {
      final store = _FakeNotificationInboxDocumentStore();
      final repository = FirestoreNotificationInboxRepository(
        ownerUid: 'runner-1',
        documentStore: store,
        clock: () => DateTime.utc(2026, 7, 8, 12, 30),
      );

      await repository.softDelete('item-2');

      expect(store.softDeleteCalls, [
        _WriteCall('runner-1', 'item-2', DateTime.utc(2026, 7, 8, 12, 30)),
      ]);
    });
  });
}

NotificationInboxDocument _document({
  String id = 'item',
  String title = 'Plan reminder',
  String body = 'Your easy run is ready.',
  DateTime? createdAt,
  DateTime? readAt,
  DateTime? deletedAt,
}) {
  return NotificationInboxDocument(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt ?? DateTime.utc(2026, 7, 8, 7),
    readAt: readAt,
    deletedAt: deletedAt,
    data: const {'route': '/run'},
  );
}

class _FakeNotificationInboxDocumentStore
    implements NotificationInboxDocumentStore {
  _FakeNotificationInboxDocumentStore({this.items = const []});

  final List<NotificationInboxDocument> items;
  final watchedUids = <String>[];
  final markReadCalls = <_WriteCall>[];
  final softDeleteCalls = <_WriteCall>[];

  @override
  Stream<List<NotificationInboxDocument>> watchInboxItems({
    required String uid,
  }) {
    watchedUids.add(uid);
    return Stream.value(items);
  }

  @override
  Future<void> markRead({
    required String uid,
    required String itemId,
    required DateTime readAt,
  }) async {
    markReadCalls.add(_WriteCall(uid, itemId, readAt));
  }

  @override
  Future<void> softDelete({
    required String uid,
    required String itemId,
    required DateTime deletedAt,
  }) async {
    softDeleteCalls.add(_WriteCall(uid, itemId, deletedAt));
  }
}

class _WriteCall {
  const _WriteCall(this.uid, this.itemId, this.at);

  final String uid;
  final String itemId;
  final DateTime at;

  @override
  bool operator ==(Object other) {
    return other is _WriteCall &&
        other.uid == uid &&
        other.itemId == itemId &&
        other.at == at;
  }

  @override
  int get hashCode => Object.hash(uid, itemId, at);

  @override
  String toString() => '_WriteCall($uid, $itemId, $at)';
}
