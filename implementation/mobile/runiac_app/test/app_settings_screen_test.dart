import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/profile/presentation/app_settings_screen.dart';
import 'package:runiac_app/features/settings/domain/models/app_settings.dart';
import 'package:runiac_app/features/settings/domain/repositories/app_settings_repository.dart';

class _FakeAppSettingsRepository implements AppSettingsRepository {
  _FakeAppSettingsRepository({AppSettings initial = AppSettings.defaults})
    : _current = initial;

  AppSettings _current;
  AppSettings? lastSaved;

  @override
  Future<AppSettings> loadSettings() async => _current;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _current = settings;
    lastSaved = settings;
  }
}

void main() {
  testWidgets('tapping Mi selector saves miles as the distance unit', (
    tester,
  ) async {
    final fake = _FakeAppSettingsRepository();

    await tester.pumpWidget(
      MaterialApp(home: AppSettingsScreen(settingsRepository: fake)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings-distance-unit-mi')));
    await tester.pumpAndSettle();

    expect(fake.lastSaved, isNotNull);
    expect(fake.lastSaved!.distanceUnit, DistanceUnit.miles);
  });

  testWidgets('toggling haptic switch saves hapticFeedbackEnabled as false', (
    tester,
  ) async {
    final fake = _FakeAppSettingsRepository();

    await tester.pumpWidget(
      MaterialApp(home: AppSettingsScreen(settingsRepository: fake)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings-haptic-switch')));
    await tester.pumpAndSettle();

    expect(fake.lastSaved, isNotNull);
    expect(fake.lastSaved!.hapticFeedbackEnabled, isFalse);
  });
}
