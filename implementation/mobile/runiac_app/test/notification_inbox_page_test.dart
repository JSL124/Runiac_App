import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/notifications/domain/models/notification_inbox_item.dart';
import 'package:runiac_app/features/notifications/domain/repositories/notification_inbox_repository.dart';
import 'package:runiac_app/features/notifications/presentation/notification_inbox_page.dart';

void main() {
  testWidgets('renders inbox items with read state and relative time', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryNotificationInboxRepository(
      items: [
        NotificationInboxItem(
          id: 'unread',
          title: 'Tomorrow run reminder',
          body: 'Your 20 min easy run is ready for 7:00 AM.',
          createdAt: DateTime.utc(2026, 7, 8, 5),
        ),
        NotificationInboxItem(
          id: 'read',
          title: 'Plan updated',
          body: 'Your week 3 plan has been adjusted.',
          createdAt: DateTime.utc(2026, 7, 7, 6),
          readAt: DateTime.utc(2026, 7, 7, 7),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationInboxPage(
          repository: repository,
          now: () => DateTime.utc(2026, 7, 8, 8),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Tomorrow run reminder'), findsOneWidget);
    expect(
      find.text('Your 20 min easy run is ready for 7:00 AM.'),
      findsOneWidget,
    );
    expect(find.text('3h ago'), findsOneWidget);
    expect(find.text('Plan updated'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.bySemanticsLabel('Unread notification'), findsOneWidget);
  });

  testWidgets('renders calm empty state when inbox has no items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationInboxPage(
          repository: InMemoryNotificationInboxRepository(),
          now: () => DateTime.utc(2026, 7, 8, 8),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No notifications yet'), findsOneWidget);
    expect(
      find.text('Plan reminders and app updates will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'partial swipe reveals delete affordance and full swipe soft deletes',
    (WidgetTester tester) async {
      final repository = InMemoryNotificationInboxRepository(
        items: [
          NotificationInboxItem(
            id: 'item-1',
            title: 'Run reminder',
            body: 'Your easy run is ready.',
            createdAt: DateTime.utc(2026, 7, 8, 5),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationInboxPage(
            repository: repository,
            now: () => DateTime.utc(2026, 7, 8, 8),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.text('Run reminder'), const Offset(-80, 0));
      await tester.pump();

      expect(find.bySemanticsLabel('Delete notification'), findsOneWidget);

      await tester.drag(find.text('Run reminder'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(repository.deletedItemIds, ['item-1']);
      expect(find.text('Run reminder'), findsNothing);
    },
  );
}
