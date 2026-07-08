import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../domain/models/notification_inbox_item.dart';
import '../domain/repositories/notification_inbox_repository.dart';

class NotificationInboxPage extends StatelessWidget {
  const NotificationInboxPage({required this.repository, this.now, super.key});

  final NotificationInboxRepository repository;
  final DateTime Function()? now;

  DateTime get _currentTime => (now ?? DateTime.now)();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const RuniacBackHeader(title: 'Notifications'),
            Expanded(
              child: StreamBuilder<List<NotificationInboxItem>>(
                stream: repository.watchInboxItems(),
                builder: (context, snapshot) {
                  final items =
                      snapshot.data ?? const <NotificationInboxItem>[];
                  if (items.isEmpty) {
                    return const _NotificationInboxEmptyState();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _NotificationInboxTile(
                        item: items[index],
                        relativeTime: _formatRelativeTime(
                          items[index].createdAt,
                          _currentTime,
                        ),
                        onRead: () => repository.markRead(items[index].id),
                        onDelete: () => repository.softDelete(items[index].id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationInboxTile extends StatelessWidget {
  const _NotificationInboxTile({
    required this.item,
    required this.relativeTime,
    required this.onRead,
    required this.onDelete,
  });

  final NotificationInboxItem item;
  final String relativeTime;
  final Future<void> Function() onRead;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<String>('notification-${item.id}'),
      direction: DismissDirection.endToStart,
      background: const _DeleteBackground(),
      onDismissed: (_) {
        onDelete();
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRead,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.isRead
                  ? RuniacColors.white
                  : RuniacColors.sectionSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: item.isRead
                    ? RuniacColors.border
                    : RuniacColors.cardBorder,
              ),
              boxShadow: const [
                BoxShadow(
                  color: RuniacColors.softCardShadow,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 16,
                  child: item.isRead
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Semantics(
                            container: true,
                            label: 'Unread notification',
                            child: ExcludeSemantics(
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: RuniacColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(width: 8, height: 8),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: RuniacColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            relativeTime,
                            style: const TextStyle(
                              color: RuniacColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.body,
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: RuniacColors.errorRed,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Semantics(
        container: true,
        label: 'Delete notification',
        button: true,
        child: const ExcludeSemantics(
          child: Icon(Icons.close, color: RuniacColors.white, size: 24),
        ),
      ),
    );
  }
}

class _NotificationInboxEmptyState extends StatelessWidget {
  const _NotificationInboxEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              color: RuniacColors.primaryBlue,
              size: 44,
            ),
            SizedBox(height: 14),
            Text(
              'No notifications yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Plan reminders and app updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRelativeTime(DateTime createdAt, DateTime now) {
  final difference = now.difference(createdAt);
  if (difference.inMinutes < 1) {
    return 'Now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  if (difference.inHours < 48) {
    return 'Yesterday';
  }
  return '${difference.inDays}d ago';
}
