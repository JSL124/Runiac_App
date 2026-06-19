import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Health import scope guards', () {
    test('Apple Health adapter has no backend or progression hooks', () {
      final adapter = File(
        'lib/features/run/data/apple_health_workout_import_repository.dart',
      ).readAsStringSync();

      const forbiddenTerms = <String>[
        'firebase',
        'cloud_functions',
        'Firestore',
        'xp',
        'streak',
        'level',
        'rank',
        'leaderboard',
        'subscriptionStatus',
        'validated',
        'writeHealthData',
        'writeWorkout',
        'WORKOUT_ROUTE',
      ];

      for (final term in forbiddenTerms) {
        expect(adapter, isNot(contains(term)), reason: 'Unexpected $term');
      }
    });

    test('iOS config does not request Health write or route access', () {
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
      final entitlements = File(
        'ios/Runner/Runner.entitlements',
      ).readAsStringSync();

      expect(infoPlist, isNot(contains('NSHealthUpdateUsageDescription')));
      expect(entitlements, isNot(contains('workout-route')));
      expect(entitlements, isNot(contains('background')));
    });
  });
}
