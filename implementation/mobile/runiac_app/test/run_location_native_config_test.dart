import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('M4-B foreground location native config', () {
    test('pubspec uses approved geolocator dependency', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('geolocator: ^14.0.3'));
    });

    test(
      'Android declares background tracking V1-B foreground permissions only',
      () {
        final manifest = File(
          'android/app/src/main/AndroidManifest.xml',
        ).readAsStringSync();

        expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
        expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
        expect(manifest, contains('android.permission.FOREGROUND_SERVICE'));
        expect(
          manifest,
          contains('android.permission.FOREGROUND_SERVICE_LOCATION'),
        );
        expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
        expect(
          manifest,
          isNot(contains('android.permission.ACCESS_BACKGROUND_LOCATION')),
        );
      },
    );

    test('Android declares Runiac-owned location foreground service', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('.RuniacRunTrackingService'));
      expect(manifest, contains('android:exported="false"'));
      expect(manifest, contains('android:foregroundServiceType="location"'));
    });

    test(
      'Android requests notification runtime permission through MainActivity',
      () {
        final activity = File(
          'android/app/src/main/kotlin/com/runiac/runiac_app/MainActivity.kt',
        ).readAsStringSync();

        expect(activity, contains('Manifest.permission.POST_NOTIFICATIONS'));
        expect(activity, contains('requestPostNotificationsPermission'));
        expect(activity, contains('requestPermissions('));
        expect(activity, contains('Build.VERSION_CODES.TIRAMISU'));
      },
    );

    test('Android foreground service bridge avoids Geolocator private IDs', () {
      final activity = File(
        'android/app/src/main/kotlin/com/runiac/runiac_app/MainActivity.kt',
      ).readAsStringSync();
      final service = File(
        'android/app/src/main/kotlin/com/runiac/runiac_app/RuniacRunTrackingService.kt',
      ).readAsStringSync();

      expect(activity, contains('runiac/run_foreground_service'));
      expect(activity, contains('RuniacRunTrackingService::class.java'));
      expect(service, contains('runiac_run_tracking'));
      expect(service, contains('Runiac Run Tracking'));
      expect(service, contains('runiac_run_open_intent'));
      expect(service, contains('RUN_OPEN_INTENT_NOTIFICATION'));
      expect(service, isNot(contains('75415')));
      expect(service, isNot(contains('geolocator_channel_01')));
    });

    test(
      'Android app module explicitly declares NotificationCompat support',
      () {
        final gradle = File('android/app/build.gradle.kts').readAsStringSync();

        expect(gradle, contains('androidx.core:core:1.16.0'));
      },
    );

    test('iOS declares when-in-use location usage only', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(plist, contains('NSLocationWhenInUseUsageDescription'));
      expect(
        plist,
        isNot(contains('NSLocationAlwaysAndWhenInUseUsageDescription')),
      );
      expect(plist, isNot(contains('UIBackgroundModes')));
      expect(plist, isNot(contains('location</string>')));
    });
  });
}
