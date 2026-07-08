import 'dart:async';

import '../models/notification_inbox_item.dart';

abstract class NotificationInboxRepository {
  const NotificationInboxRepository();

  Stream<List<NotificationInboxItem>> watchInboxItems();

  Future<List<NotificationInboxItem>> listInboxItems();

  Stream<int> watchUnreadCount();

  Future<void> saveInboxItem(NotificationInboxItem item);

  Future<void> markRead(String itemId);

  Future<void> softDelete(String itemId);
}

class StaticNotificationInboxRepository implements NotificationInboxRepository {
  const StaticNotificationInboxRepository({
    this.items = const <NotificationInboxItem>[],
  });

  final List<NotificationInboxItem> items;

  List<NotificationInboxItem> get _visibleItems {
    final visible = items.where((item) => !item.isDeleted).toList();
    visible.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<NotificationInboxItem>.unmodifiable(visible);
  }

  @override
  Future<List<NotificationInboxItem>> listInboxItems() async => _visibleItems;

  @override
  Future<void> saveInboxItem(NotificationInboxItem item) async {}

  @override
  Future<void> markRead(String itemId) async {}

  @override
  Future<void> softDelete(String itemId) async {}

  @override
  Stream<List<NotificationInboxItem>> watchInboxItems() {
    return Stream<List<NotificationInboxItem>>.value(_visibleItems);
  }

  @override
  Stream<int> watchUnreadCount() {
    return Stream<int>.value(
      _visibleItems.where((item) => !item.isRead).length,
    );
  }
}

class InMemoryNotificationInboxRepository
    implements NotificationInboxRepository {
  InMemoryNotificationInboxRepository({
    List<NotificationInboxItem> items = const <NotificationInboxItem>[],
    DateTime Function()? clock,
  }) : _items = List<NotificationInboxItem>.of(items),
       _clock = clock ?? DateTime.now {
    _emit();
  }

  final List<NotificationInboxItem> _items;
  final DateTime Function() _clock;
  final _itemsController =
      StreamController<List<NotificationInboxItem>>.broadcast();
  final List<String> deletedItemIds = <String>[];

  List<NotificationInboxItem> get _visibleItems {
    final visible = _items.where((item) => !item.isDeleted).toList();
    visible.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<NotificationInboxItem>.unmodifiable(visible);
  }

  void _emit() {
    scheduleMicrotask(() {
      if (!_itemsController.isClosed) {
        _itemsController.add(_visibleItems);
      }
    });
  }

  @override
  Future<List<NotificationInboxItem>> listInboxItems() async => _visibleItems;

  @override
  Future<void> saveInboxItem(NotificationInboxItem item) async {
    final index = _items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    _emit();
  }

  @override
  Future<void> markRead(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1 || _items[index].isRead) {
      return;
    }
    _items[index] = _items[index].copyWith(readAt: _clock());
    _emit();
  }

  @override
  Future<void> softDelete(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1 || _items[index].isDeleted) {
      return;
    }
    deletedItemIds.add(itemId);
    _items[index] = _items[index].copyWith(deletedAt: _clock());
    _emit();
  }

  @override
  Stream<List<NotificationInboxItem>> watchInboxItems() {
    return Stream<List<NotificationInboxItem>>.multi((controller) {
      controller.add(_visibleItems);
      final subscription = _itemsController.stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<int> watchUnreadCount() {
    return watchInboxItems().map(
      (items) => items.where((item) => !item.isRead).length,
    );
  }

  Future<void> dispose() async {
    await _itemsController.close();
  }
}
