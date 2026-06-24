import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/phone_motion_run_cadence_provider.dart';
import 'package:runiac_app/features/run/domain/models/run_cadence_sample.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhoneMotionRunCadenceProvider', () {
    const channel = MethodChannel('test/phone_motion_cadence');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('unavailable path returns no fake cadence', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'isAvailable') {
              return false;
            }
            return 'denied';
          });
      final nativeEvents = StreamController<Object?>.broadcast();
      final provider = PhoneMotionRunCadenceProvider(
        methodChannel: channel,
        nativeEvents: nativeEvents.stream,
      );
      final samples = <RunCadenceSample>[];
      final subscription = provider.cadenceStream.listen(samples.add);

      await provider.start();
      nativeEvents.add({
        'recordedAtMillis': 1782284400000,
        'stepsPerMinute': 170,
        'confidence': 'estimated',
      });
      await Future<void>.delayed(Duration.zero);

      expect(await provider.isAvailable(), isFalse);
      expect(samples, isEmpty);

      await subscription.cancel();
      await provider.dispose();
      nativeEvents.close();
    });

    test('emits phoneMotion provenance from native samples', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'isAvailable') {
              return true;
            }
            if (call.method == 'requestPermission') {
              return 'granted';
            }
            return null;
          });
      final nativeEvents = StreamController<Object?>.broadcast();
      final provider = PhoneMotionRunCadenceProvider(
        methodChannel: channel,
        nativeEvents: nativeEvents.stream,
      );
      final samples = <RunCadenceSample>[];
      final subscription = provider.cadenceStream.listen(samples.add);

      await provider.start();
      nativeEvents.add({
        'recordedAtMillis': 1782284400000,
        'stepsPerMinute': 172,
        'confidence': 'estimated',
      });
      nativeEvents.add({'stepsPerMinute': double.nan});
      await Future<void>.delayed(Duration.zero);

      expect(samples, hasLength(1));
      expect(samples.single.source, CadenceSource.phoneMotion);
      expect(samples.single.confidence, CadenceConfidence.estimated);
      expect(samples.single.stepsPerMinute, 172);

      await provider.pause();
      nativeEvents.add({
        'recordedAtMillis': 1782284410000,
        'stepsPerMinute': 174,
      });
      await Future<void>.delayed(Duration.zero);
      expect(samples, hasLength(1));

      await subscription.cancel();
      await provider.dispose();
      nativeEvents.close();
    });

    test(
      'requests first-run permission before native availability gate',
      () async {
        var permissionRequested = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'isAvailable') {
                return permissionRequested;
              }
              if (call.method == 'requestPermission') {
                permissionRequested = true;
                return 'granted';
              }
              return null;
            });
        final nativeEvents = StreamController<Object?>.broadcast();
        final provider = PhoneMotionRunCadenceProvider(
          methodChannel: channel,
          nativeEvents: nativeEvents.stream,
        );
        final samples = <RunCadenceSample>[];
        final subscription = provider.cadenceStream.listen(samples.add);

        await provider.start();
        nativeEvents.add({
          'recordedAtMillis': 1782284400000,
          'stepsPerMinute': 176,
          'confidence': 'estimated',
        });
        await Future<void>.delayed(Duration.zero);

        expect(permissionRequested, isTrue);
        expect(samples.single.stepsPerMinute, 176);

        await subscription.cancel();
        await provider.dispose();
        nativeEvents.close();
      },
    );
  });
}
