import '../domain/repositories/run_repository.dart';
import 'firebase_run_repository.dart';
import 'flutterfire_complete_run_callable.dart';
import 'static_run_repository.dart';

typedef CompleteRunCallableFactory = CompleteRunCallable Function();

class RuniacFirebaseRuntimeConfig {
  const RuniacFirebaseRuntimeConfig({
    required this.useFirebaseEmulator,
    this.emulatorHost = defaultEmulatorHost,
    this.useProductionFirebase = false,
    this.productionApiKey = '',
    this.productionAppId = '',
    this.productionMessagingSenderId = '',
    this.productionProjectId = '',
  });

  factory RuniacFirebaseRuntimeConfig.fromEnvironment() {
    return const RuniacFirebaseRuntimeConfig(
      useFirebaseEmulator: bool.fromEnvironment('RUNIAC_FIREBASE_EMULATOR'),
      emulatorHost: String.fromEnvironment(
        'RUNIAC_FIREBASE_EMULATOR_HOST',
        defaultValue: defaultEmulatorHost,
      ),
      useProductionFirebase: bool.fromEnvironment('RUNIAC_FIREBASE_PRODUCTION'),
      productionApiKey: String.fromEnvironment('RUNIAC_FIREBASE_API_KEY'),
      productionAppId: String.fromEnvironment('RUNIAC_FIREBASE_APP_ID'),
      productionMessagingSenderId: String.fromEnvironment(
        'RUNIAC_FIREBASE_MESSAGING_SENDER_ID',
      ),
      productionProjectId: String.fromEnvironment('RUNIAC_FIREBASE_PROJECT_ID'),
    );
  }

  static const defaultEmulatorHost = '127.0.0.1';

  final bool useFirebaseEmulator;
  final String emulatorHost;
  final bool useProductionFirebase;
  final String productionApiKey;
  final String productionAppId;
  final String productionMessagingSenderId;
  final String productionProjectId;
}

class RunRepositoryFactory {
  const RunRepositoryFactory._();

  static RunRepository create({
    RuniacFirebaseRuntimeConfig? config,
    CompleteRunCallableFactory completeRunCallableFactory =
        _defaultCompleteRunCallableFactory,
  }) {
    final runtimeConfig =
        config ?? RuniacFirebaseRuntimeConfig.fromEnvironment();
    if (!runtimeConfig.useFirebaseEmulator) {
      return const StaticRunRepository();
    }

    return FirebaseRunRepository(callable: completeRunCallableFactory());
  }

  static CompleteRunCallable _defaultCompleteRunCallableFactory() {
    return FlutterFireCompleteRunCallable();
  }
}
