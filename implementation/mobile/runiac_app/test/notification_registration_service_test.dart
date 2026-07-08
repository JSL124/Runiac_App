import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/notifications/domain/services/notification_registration_service.dart';

import 'support/fake_notification_services.dart';

void main() {
  group('NotificationRegistrationService', () {
    test(
      'requests permission and waits for Apple APNs token before registering FCM token',
      () async {
        final client = FakePushNotificationClient(
          platform: PushNotificationPlatform.apple,
          permissionStatus: PushNotificationPermissionStatus.authorized,
          apnsToken: 'apns-token',
          token: 'fcm-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
        );

        await service.registerCurrentDevice();

        expect(client.permissionRequests, 1);
        expect(client.apnsTokenRequests, 1);
        expect(client.tokenRequests, 1);
        expect(callable.registerCalls, [
          const RegisterNotificationDeviceRequest(
            uid: 'runner-1',
            token: 'fcm-token',
            platform: PushNotificationPlatform.apple,
          ),
        ]);
      },
    );

    test(
      'does not request FCM token when Apple APNs token is unavailable',
      () async {
        final client = FakePushNotificationClient(
          platform: PushNotificationPlatform.apple,
          permissionStatus: PushNotificationPermissionStatus.authorized,
          apnsToken: null,
          token: 'fcm-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
        );

        await service.registerCurrentDevice();

        expect(client.apnsTokenRequests, 1);
        expect(client.tokenRequests, 0);
        expect(callable.registerCalls, isEmpty);
      },
    );

    test(
      'does not mark start complete when registration returns before token registration',
      () async {
        final client = FakePushNotificationClient(
          platform: PushNotificationPlatform.apple,
          permissionStatus: PushNotificationPermissionStatus.authorized,
          apnsToken: null,
          token: 'fcm-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
        );

        await service.start();
        client.apnsToken = 'apns-token';
        await service.start();

        expect(client.apnsTokenRequests, 2);
        expect(client.tokenRequests, 1);
        expect(callable.registerCalls, [
          const RegisterNotificationDeviceRequest(
            uid: 'runner-1',
            token: 'fcm-token',
            platform: PushNotificationPlatform.apple,
          ),
        ]);
        await service.dispose();
      },
    );

    test(
      'registers refreshed tokens and unregisters the current token',
      () async {
        final client = FakePushNotificationClient(
          permissionStatus: PushNotificationPermissionStatus.authorized,
          token: 'initial-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
        );

        await service.start();
        client.emitTokenRefresh('refreshed-token');
        await pumpEventQueue();
        await service.unregisterCurrentDevice();

        expect(callable.registerCalls.map((call) => call.token), [
          'initial-token',
          'refreshed-token',
        ]);
        expect(callable.unregisterCalls, [
          const UnregisterNotificationDeviceRequest(
            uid: 'runner-1',
            token: 'refreshed-token',
          ),
        ]);
        await service.dispose();
      },
    );

    test('can register again after unregistering current device', () async {
      final client = FakePushNotificationClient(
        permissionStatus: PushNotificationPermissionStatus.authorized,
        token: 'initial-token',
      );
      final callable = FakeNotificationDeviceCallable();
      var uid = 'runner-1';
      final service = NotificationRegistrationService(
        client: client,
        callable: callable,
        ownerUidProvider: () => uid,
      );

      await service.start();
      await service.unregisterCurrentDevice();
      uid = 'runner-2';
      client.token = 'next-token';
      await service.start();

      expect(
        callable.registerCalls.map((call) => '${call.uid}:${call.token}'),
        ['runner-1:initial-token', 'runner-2:next-token'],
      );
      expect(callable.unregisterCalls, [
        const UnregisterNotificationDeviceRequest(
          uid: 'runner-1',
          token: 'initial-token',
        ),
      ]);
      await service.dispose();
    });

    test(
      'forwards foreground, opened, and initial messages through stream seam',
      () async {
        final client = FakePushNotificationClient(
          permissionStatus: PushNotificationPermissionStatus.authorized,
          token: 'initial-token',
          initialMessage: const PushNotificationMessage(
            id: 'initial',
            title: 'Initial',
            body: 'Opened from terminated state',
            data: {'itemId': 'initial'},
          ),
        );
        final service = NotificationRegistrationService(
          client: client,
          callable: FakeNotificationDeviceCallable(),
          ownerUidProvider: () => 'runner-1',
        );
        final messages = <PushNotificationMessage>[];
        final subscription = service.messages.listen(messages.add);

        await service.start();
        client.emitForegroundMessage(
          const PushNotificationMessage(id: 'foreground', title: 'Foreground'),
        );
        client.emitOpenedMessage(
          const PushNotificationMessage(id: 'opened', title: 'Opened'),
        );
        await pumpEventQueue();

        expect(messages.map((message) => message.id), [
          'initial',
          'foreground',
          'opened',
        ]);
        await subscription.cancel();
        await service.dispose();
      },
    );
  });
}
