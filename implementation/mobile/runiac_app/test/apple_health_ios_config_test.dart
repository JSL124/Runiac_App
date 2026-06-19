import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Apple Health iOS config', () {
    test('requests read-only Health sharing', () {
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(infoPlist, contains('NSHealthShareUsageDescription'));
      expect(
        infoPlist,
        contains('Runiac reads Apple Health workouts you choose to share'),
      );
      expect(infoPlist, isNot(contains('NSHealthUpdateUsageDescription')));
    });

    test('enables HealthKit only on the Runner app target', () {
      final entitlements = File(
        'ios/Runner/Runner.entitlements',
      ).readAsStringSync();
      final project = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();

      expect(entitlements, contains('com.apple.developer.healthkit'));
      expect(entitlements, contains('<true/>'));
      expect(
        RegExp(
          r'CODE_SIGN_ENTITLEMENTS = Runner/Runner\.entitlements;',
        ).allMatches(project),
        hasLength(3),
      );
      expect(project, isNot(contains('RunnerTests/Runner.entitlements')));
      expect(
        project,
        isNot(contains('RunnerLiveActivity/Runner.entitlements')),
      );
    });
  });
}
