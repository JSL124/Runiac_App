class NotificationInboxItem {
  const NotificationInboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.deletedAt,
    this.data = const <String, Object?>{},
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? deletedAt;
  final Map<String, Object?> data;

  bool get isRead => readAt != null;

  bool get isDeleted => deletedAt != null;

  NotificationInboxItem copyWith({DateTime? readAt, DateTime? deletedAt}) {
    return NotificationInboxItem(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      deletedAt: deletedAt ?? this.deletedAt,
      data: data,
    );
  }
}
