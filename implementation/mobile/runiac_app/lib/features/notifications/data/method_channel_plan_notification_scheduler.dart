import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/models/plan_notification_schedule.dart';
import '../domain/repositories/plan_notification_scheduler.dart';

class MethodChannelPlanNotificationScheduler
    implements PlanNotificationScheduler {
  const MethodChannelPlanNotificationScheduler({
    this.channel = const MethodChannel(_channelName),
  });

  static const _channelName = 'runiac/plan_notifications';

  final MethodChannel channel;

  @override
  Future<PlanNotificationPermissionStatus> requestPermission() async {
    if (!_supportsNativeNotifications) {
      return PlanNotificationPermissionStatus.notRequired;
    }
    final status = await channel.invokeMethod<String>('requestPermission');
    return switch (status) {
      'granted' => PlanNotificationPermissionStatus.granted,
      'denied' => PlanNotificationPermissionStatus.denied,
      'notRequired' => PlanNotificationPermissionStatus.notRequired,
      _ => PlanNotificationPermissionStatus.denied,
    };
  }

  @override
  Future<void> syncPlanNotifications(
    List<ScheduledPlanNotification> notifications,
  ) async {
    if (!_supportsNativeNotifications) {
      return;
    }
    await channel.invokeMethod<void>('syncPlanNotifications', {
      'notifications': [
        for (final notification in notifications) notification.toChannelMap(),
      ],
    });
  }

  @override
  Future<void> cancelPlanNotifications() async {
    if (!_supportsNativeNotifications) {
      return;
    }
    await channel.invokeMethod<void>('cancelPlanNotifications');
  }

  bool get _supportsNativeNotifications {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
