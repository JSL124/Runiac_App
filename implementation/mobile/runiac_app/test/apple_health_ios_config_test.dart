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

    test('registers read-only HealthKit workout import channel', () {
      final appDelegate = File(
        'ios/Runner/AppDelegate.swift',
      ).readAsStringSync();
      final runnerSwiftSources = Directory('ios/Runner')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.swift'))
          .map((file) => file.readAsStringSync())
          .join('\n');

      expect(appDelegate, contains('RuniacHealthKitImportChannel.register'));
      expect(runnerSwiftSources, contains('runiac/healthkit_import'));
      expect(runnerSwiftSources, contains('listRunningWorkouts'));
      expect(
        runnerSwiftSources,
        contains('HKHealthStore.isHealthDataAvailable()'),
      );
      expect(runnerSwiftSources, contains('HKObjectType.workoutType()'));
      expect(runnerSwiftSources, contains('.heartRate'));
      expect(runnerSwiftSources, contains('requestAuthorization(toShare: []'));
      expect(runnerSwiftSources, contains('HKSampleQuery'));
      expect(
        runnerSwiftSources,
        contains('workout.workoutActivityType == .running'),
      );
      expect(runnerSwiftSources, contains('averageHeartRateBpm'));
      expect(runnerSwiftSources, contains('maxHeartRateBpm'));
      expect(runnerSwiftSources, isNot(contains('HKWorkoutRoute')));
      expect(runnerSwiftSources, isNot(contains('WatchConnectivity')));
      expect(runnerSwiftSources, isNot(contains('heartRateSamples')));
    });
  });
}
