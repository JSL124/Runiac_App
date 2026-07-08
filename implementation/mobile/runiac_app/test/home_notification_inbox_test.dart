import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/data/static_user_profile_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'package:runiac_app/features/auth/data/non_production_auth_repository.dart';
import 'package:runiac_app/features/home/presentation/home_tab.dart';
import 'package:runiac_app/features/home/presentation/widgets/home_header.dart';
import 'package:runiac_app/features/notifications/domain/models/notification_inbox_item.dart';
import 'package:runiac_app/features/notifications/domain/repositories/notification_inbox_repository.dart';
import 'package:runiac_app/features/notifications/presentation/notification_inbox_page.dart';

void main() {
  testWidgets(
    'Home notification bell hides badge at zero and caps unread count',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HomeHeader(
                  unreadNotificationCount: 0,
                  onNotifications: () {},
                  onProfile: () {},
                ),
                HomeHeader(
                  unreadNotificationCount: 120,
                  onNotifications: () {},
                  onProfile: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
      expect(find.text('99+'), findsOneWidget);
      final badgeText = tester.widget<Text>(find.text('99+'));
      expect(badgeText.style?.color, Colors.white);
    },
  );

  testWidgets(
    'Home bell opens notification inbox instead of account settings',
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
          home: HomeTab(
            authRepository: const NonProductionAuthRepository(),
            profileRepository: const StaticUserProfileRepository(),
            profilePersistenceRepository:
                const NoopUserProfilePersistenceRepository(),
            notificationInboxRepository: repository,
            enableForegroundGps: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification Center'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationInboxPage), findsOneWidget);
      expect(find.text('Run reminder'), findsOneWidget);
      expect(find.text('Notification Center'), findsNothing);
    },
  );
}
