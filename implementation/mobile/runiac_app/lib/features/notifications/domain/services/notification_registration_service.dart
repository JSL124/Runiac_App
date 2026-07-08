import 'dart:async';

enum PushNotificationPlatform { android, apple, web }

enum PushNotificationPermissionStatus {
  authorized,
  denied,
  notDetermined,
  provisional,
}

class PushNotificationMessage {
  const PushNotificationMessage({
    required this.id,
    this.title,
    this.body,
    this.data = const {},
  });

  final String id;
  final String? title;
  final String? body;
  final Map<String, Object?> data;
}

abstract interface class PushNotificationClient {
  PushNotificationPlatform get platform;

  Future<PushNotificationPermissionStatus> requestPermission();

  Future<String?> getAppleApnsToken();

  Future<String?> getToken();

  Stream<String> get tokenRefreshes;

  Stream<PushNotificationMessage> get foregroundMessages;

  Stream<PushNotificationMessage> get openedMessages;

  Future<PushNotificationMessage?> getInitialMessage();
}

class RegisterNotificationDeviceRequest {
  const RegisterNotificationDeviceRequest({
    required this.uid,
    required this.token,
    required this.platform,
    this.appInstallationId,
  });

  final String uid;
  final String token;
  final PushNotificationPlatform platform;
  final String? appInstallationId;

  @override
  bool operator ==(Object other) {
    return other is RegisterNotificationDeviceRequest &&
        other.uid == uid &&
        other.token == token &&
        other.platform == platform &&
        other.appInstallationId == appInstallationId;
  }

  @override
  int get hashCode => Object.hash(uid, token, platform, appInstallationId);
}

class UnregisterNotificationDeviceRequest {
  const UnregisterNotificationDeviceRequest({
    required this.uid,
    required this.token,
  });

  final String uid;
  final String token;

  @override
  bool operator ==(Object other) {
    return other is UnregisterNotificationDeviceRequest &&
        other.uid == uid &&
        other.token == token;
  }

  @override
  int get hashCode => Object.hash(uid, token);
}

abstract interface class NotificationDeviceCallable {
  Future<void> registerDevice(RegisterNotificationDeviceRequest request);

  Future<void> unregisterDevice(UnregisterNotificationDeviceRequest request);
}

class NotificationRegistrationService {
  NotificationRegistrationService({
    required this.client,
    required this.callable,
    required this.ownerUidProvider,
  });

  final PushNotificationClient client;
  final NotificationDeviceCallable callable;
  final String? Function() ownerUidProvider;
  final _messageController =
      StreamController<PushNotificationMessage>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  String? _currentToken;
  String? _currentUid;
  bool _started = false;

  Stream<PushNotificationMessage> get messages => _messageController.stream;

  Future<void> start() async {
    if (_started) {
      return;
    }

    try {
      final registered = await registerCurrentDevice();
      if (!registered) {
        return;
      }

      _subscriptions
        ..add(
          client.tokenRefreshes.listen((token) {
            unawaited(_registerToken(token));
          }),
        )
        ..add(client.foregroundMessages.listen(_messageController.add))
        ..add(client.openedMessages.listen(_messageController.add));

      final initialMessage = await client.getInitialMessage();
      if (initialMessage != null) {
        _messageController.add(initialMessage);
      }
      _started = true;
    } catch (_) {
      await _cancelSubscriptions();
      _started = false;
      rethrow;
    }
  }

  Future<bool> registerCurrentDevice() async {
    final permission = await client.requestPermission();
    if (!_canRegister(permission)) {
      return false;
    }

    if (client.platform == PushNotificationPlatform.apple) {
      final apnsToken = await client.getAppleApnsToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        return false;
      }
    }

    final token = await client.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    await _registerToken(token);
    return _currentToken == token;
  }

  Future<void> unregisterCurrentDevice() async {
    final uid = _currentOwnerUid() ?? _currentUid;
    if (uid == null) {
      return;
    }
    final token = _currentToken ?? await client.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await callable.unregisterDevice(
      UnregisterNotificationDeviceRequest(uid: uid, token: token),
    );
    if (_currentToken == token) {
      _currentToken = null;
    }
    _currentUid = null;
    _started = false;
    await _cancelSubscriptions();
  }

  Future<void> dispose() async {
    await _cancelSubscriptions();
    await _messageController.close();
  }

  Future<void> _cancelSubscriptions() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  bool _canRegister(PushNotificationPermissionStatus permission) {
    return permission == PushNotificationPermissionStatus.authorized ||
        permission == PushNotificationPermissionStatus.provisional;
  }

  Future<void> _registerToken(String token) async {
    final uid = _currentOwnerUid();
    if (uid == null || token.isEmpty) {
      return;
    }

    await callable.registerDevice(
      RegisterNotificationDeviceRequest(
        uid: uid,
        token: token,
        platform: client.platform,
      ),
    );
    _currentToken = token;
    _currentUid = uid;
  }

  String? _currentOwnerUid() {
    final uid = ownerUidProvider();
    if (uid == null || uid.isEmpty) {
      return null;
    }
    return uid;
  }
}
