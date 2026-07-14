import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/firebase/runiac_app_check_bootstrap.dart';

void main() {
  test('uses debug providers for debug and emulator launches', () async {
    AndroidAppCheckProvider? android;
    AppleAppCheckProvider? apple;

    await RuniacAppCheckBootstrap.activate(
      useDebugProviders: true,
      activator: ({required androidProvider, required appleProvider}) async {
        android = androidProvider;
        apple = appleProvider;
      },
    );

    expect(android, isA<AndroidDebugProvider>());
    expect(apple, isA<AppleDebugProvider>());
  });

  test('uses production attestation providers for release launches', () async {
    AndroidAppCheckProvider? android;
    AppleAppCheckProvider? apple;

    await RuniacAppCheckBootstrap.activate(
      useDebugProviders: false,
      activator: ({required androidProvider, required appleProvider}) async {
        android = androidProvider;
        apple = appleProvider;
      },
    );

    expect(android, isA<AndroidPlayIntegrityProvider>());
    expect(apple, isA<AppleAppAttestWithDeviceCheckFallbackProvider>());
  });
}
