import '../domain/repositories/run_repository.dart';
import 'firebase_run_repository.dart';
import 'flutterfire_complete_run_callable.dart';
import 'static_run_repository.dart';

typedef CompleteRunCallableFactory = CompleteRunCallable Function();

class RuniacFirebaseRuntimeConfig {
  const RuniacFirebaseRuntimeConfig({
    required this.useFirebaseEmulator,
    this.emulatorHost = defaultEmulatorHost,
  });

  factory RuniacFirebaseRuntimeConfig.fromEnvironment() {
    return const RuniacFirebaseRuntimeConfig(
      useFirebaseEmulator: bool.fromEnvironment('RUNIAC_FIREBASE_EMULATOR'),
      emulatorHost: String.fromEnvironment(
        'RUNIAC_FIREBASE_EMULATOR_HOST',
        defaultValue: defaultEmulatorHost,
      ),
    );
  }

  static const defaultEmulatorHost = '127.0.0.1';

  final bool useFirebaseEmulator;
  final String emulatorHost;
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
