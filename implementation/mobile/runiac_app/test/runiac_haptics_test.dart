import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/haptics/runiac_haptics.dart';

/// A [RuniacHaptics] fake that records invoked method names instead of
/// dispatching real platform haptics. Reusable by other feature tests that
/// need to assert a haptic was (or was not) requested for a given action.
class RecordingRuniacHaptics implements RuniacHaptics {
  final List<String> calls = <String>[];
  bool enabled = true;

  @override
  void selection() => calls.add('selection');

  @override
  void impactLight() => calls.add('impactLight');

  @override
  void impactMedium() => calls.add('impactMedium');

  @override
  void impactHeavy() => calls.add('impactHeavy');

  @override
  void error() => calls.add('error');

  @override
  void setEnabled(bool enabled) {
    this.enabled = enabled;
    calls.add('setEnabled($enabled)');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemRuniacHaptics', () {
    final platformCalls = <MethodCall>[];

    setUp(() {
      platformCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            platformCalls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test(
      'enabled fires the mapped platform haptic call for each method',
      () async {
        final haptics = SystemRuniacHaptics();

        haptics.selection();
        await Future<void>.delayed(Duration.zero);
        expect(platformCalls, hasLength(1));
        expect(platformCalls.single.method, 'HapticFeedback.vibrate');
        expect(
          platformCalls.single.arguments,
          'HapticFeedbackType.selectionClick',
        );
        platformCalls.clear();

        haptics.impactLight();
        await Future<void>.delayed(Duration.zero);
        expect(
          platformCalls.single.arguments,
          'HapticFeedbackType.lightImpact',
        );
        platformCalls.clear();

        haptics.impactMedium();
        await Future<void>.delayed(Duration.zero);
        expect(
          platformCalls.single.arguments,
          'HapticFeedbackType.mediumImpact',
        );
        platformCalls.clear();

        haptics.impactHeavy();
        await Future<void>.delayed(Duration.zero);
        expect(
          platformCalls.single.arguments,
          'HapticFeedbackType.heavyImpact',
        );
        platformCalls.clear();

        haptics.error();
        await Future<void>.delayed(Duration.zero);
        expect(platformCalls.single.method, 'HapticFeedback.vibrate');
        expect(platformCalls.single.arguments, isNull);
      },
    );

    test('disabled fires no platform calls', () async {
      final haptics = SystemRuniacHaptics(enabled: false);
      expect(haptics.enabled, isFalse);

      haptics.selection();
      haptics.impactLight();
      haptics.impactMedium();
      haptics.impactHeavy();
      haptics.error();
      await Future<void>.delayed(Duration.zero);

      expect(platformCalls, isEmpty);
    });

    test(
      'setEnabled(false) then setEnabled(true) flips behavior live',
      () async {
        final haptics = SystemRuniacHaptics();
        expect(haptics.enabled, isTrue);

        haptics.setEnabled(false);
        expect(haptics.enabled, isFalse);
        haptics.selection();
        await Future<void>.delayed(Duration.zero);
        expect(platformCalls, isEmpty);

        haptics.setEnabled(true);
        expect(haptics.enabled, isTrue);
        haptics.selection();
        await Future<void>.delayed(Duration.zero);
        expect(platformCalls, hasLength(1));
        expect(platformCalls.single.method, 'HapticFeedback.vibrate');
      },
    );

    test('calls never throw when the platform channel fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            throw PlatformException(code: 'boom');
          });
      final haptics = SystemRuniacHaptics();

      expect(() => haptics.selection(), returnsNormally);
      expect(() => haptics.impactLight(), returnsNormally);
      expect(() => haptics.impactMedium(), returnsNormally);
      expect(() => haptics.impactHeavy(), returnsNormally);
      expect(() => haptics.error(), returnsNormally);

      // Flush the rejected futures so the failure is observed (and
      // swallowed) here rather than surfacing as an unhandled error later.
      await Future<void>.delayed(Duration.zero);
    });

    test('calls never throw when no platform handler is registered', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      final haptics = SystemRuniacHaptics();

      expect(() => haptics.selection(), returnsNormally);
      expect(() => haptics.error(), returnsNormally);
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('RecordingRuniacHaptics', () {
    test('records each semantic call and setEnabled by name', () {
      final recorder = RecordingRuniacHaptics();

      recorder.selection();
      recorder.impactLight();
      recorder.impactMedium();
      recorder.impactHeavy();
      recorder.error();
      recorder.setEnabled(false);

      expect(recorder.calls, [
        'selection',
        'impactLight',
        'impactMedium',
        'impactHeavy',
        'error',
        'setEnabled(false)',
      ]);
      expect(recorder.enabled, isFalse);
    });
  });
}
