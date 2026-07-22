import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:runiac_app/features/profile/domain/models/user_profile_read_model.dart';
import 'package:runiac_app/features/profile/presentation/about_runiac_screen.dart';
import 'package:runiac_app/features/profile/presentation/app_settings_screen.dart';
import 'package:runiac_app/features/profile/presentation/data/account_profile_demo_snapshots.dart';
import 'package:runiac_app/features/profile/presentation/widgets/account_profile_sections.dart';
import 'package:runiac_app/features/settings/domain/models/app_settings.dart';
import 'package:runiac_app/features/settings/domain/repositories/app_settings_repository.dart';

import 'support/fake_runiac_auth_repository.dart';

class _FakeAppSettingsRepository implements AppSettingsRepository {
  AppSettings _settings = AppSettings.defaults;

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}

void main() {
  setUpAll(() {
    // Avoids a real platform channel round-trip when AboutRuniacScreen is
    // pushed without version overrides, matching how the real routing code
    // constructs it (`const AboutRuniacScreen()`).
    PackageInfo.setMockInitialValues(
      appName: 'Runiac',
      packageName: 'app.runiac',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Widget buildManageSection() {
    return MaterialApp(
      home: Scaffold(
        body: AccountManageSection(
          rows: accountProfileDemoSnapshot.manageRows,
          authRepository: FakeRuniacAuthRepository(),
          appSettingsRepository: _FakeAppSettingsRepository(),
        ),
      ),
    );
  }

  testWidgets('tapping Settings pushes AppSettingsScreen, no snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(buildManageSection());

    expect(find.byType(AppSettingsScreen), findsNothing);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(AppSettingsScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Settings preview is coming soon.'), findsNothing);
  });

  testWidgets('tapping About Runiac pushes AboutRuniacScreen, no snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(buildManageSection());

    expect(find.byType(AboutRuniacScreen), findsNothing);

    await tester.tap(find.text('About Runiac'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutRuniacScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('About Runiac preview is coming soon.'), findsNothing);
  });

  testWidgets('Settings and About Runiac rows carry non-snackBar actions', (
    tester,
  ) async {
    final rows = accountProfileDemoSnapshot.manageRows;
    final settingsRow = rows.firstWhere((row) => row.title == 'Settings');
    final aboutRow = rows.firstWhere((row) => row.title == 'About Runiac');

    expect(settingsRow.action, UserProfileManageAction.settings);
    expect(settingsRow.snackBarMessage, isEmpty);
    expect(aboutRow.action, UserProfileManageAction.about);
    expect(aboutRow.snackBarMessage, isEmpty);
  });
}
