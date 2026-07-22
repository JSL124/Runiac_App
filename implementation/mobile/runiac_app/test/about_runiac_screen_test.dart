import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/profile/presentation/about_runiac_screen.dart';

void main() {
  testWidgets('renders app name, version, and licenses row', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutRuniacScreen(
          versionOverride: '1.0.0',
          buildNumberOverride: '1',
        ),
      ),
    );

    expect(find.text('Runiac'), findsOneWidget);
    expect(find.text('Version 1.0.0 (build 1)'), findsOneWidget);
    expect(find.text('Open-source licenses'), findsOneWidget);
  });
}
