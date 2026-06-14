import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/run_location_permission_status.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_permission_service.dart';
import 'package:runiac_app/features/run/presentation/run_launch_screen.dart';

class _FakePermissionService implements RunLocationPermissionService {
  _FakePermissionService(this.status);

  RunLocationPermissionStatus status;

  @override
  Future<RunLocationPermissionStatus> checkStatus() async => status;

  @override
  Future<RunLocationPermissionStatus> requestPermission() async => status;
}

void main() {
  group('Run location permission UX', () {
    testWidgets('denied location shows supportive retry message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            permissionService: _FakePermissionService(
              RunLocationPermissionStatus.denied,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start run'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Try again'), findsOneWidget);
      expect(find.textContaining('GPS'), findsWidgets);
    });

    testWidgets('denied forever shows settings guidance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            permissionService: _FakePermissionService(
              RunLocationPermissionStatus.deniedForever,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start run'));
      await tester.pumpAndSettle();

      expect(find.textContaining('settings'), findsOneWidget);
    });

    testWidgets('service disabled shows GPS enable guidance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RunLaunchScreen(
            permissionService: _FakePermissionService(
              RunLocationPermissionStatus.serviceDisabled,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start run'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Turn on GPS'), findsOneWidget);
    });
  });
}
