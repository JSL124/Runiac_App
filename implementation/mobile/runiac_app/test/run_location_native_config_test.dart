import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('M4-B foreground location native config', () {
    test('pubspec uses approved geolocator dependency', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('geolocator: ^14.0.3'));
    });

    test('Android declares foreground location permissions only', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
      expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
      expect(
        manifest,
        isNot(contains('android.permission.ACCESS_BACKGROUND_LOCATION')),
      );
      expect(
        manifest,
        isNot(contains('android.permission.FOREGROUND_SERVICE_LOCATION')),
      );
    });

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
