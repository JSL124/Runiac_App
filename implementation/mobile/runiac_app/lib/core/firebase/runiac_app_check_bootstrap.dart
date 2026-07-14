import 'package:firebase_app_check/firebase_app_check.dart';

typedef RuniacAppCheckActivator =
    Future<void> Function({
      required AndroidAppCheckProvider androidProvider,
      required AppleAppCheckProvider appleProvider,
    });

class RuniacAppCheckBootstrap {
  const RuniacAppCheckBootstrap._();

  static Future<void> activate({
    required bool useDebugProviders,
    RuniacAppCheckActivator? activator,
  }) {
    final androidProvider = useDebugProviders
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider();
    final appleProvider = useDebugProviders
        ? const AppleDebugProvider()
        : const AppleAppAttestWithDeviceCheckFallbackProvider();
    return (activator ?? _activateFirebase)(
      androidProvider: androidProvider,
      appleProvider: appleProvider,
    );
  }

  static Future<void> _activateFirebase({
    required AndroidAppCheckProvider androidProvider,
    required AppleAppCheckProvider appleProvider,
  }) {
    return FirebaseAppCheck.instance.activate(
      providerAndroid: androidProvider,
      providerApple: appleProvider,
    );
  }
}
