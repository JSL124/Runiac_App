import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/account/data/firestore_user_profile_persistence_repository.dart';
import '../../features/account/data/firestore_user_profile_repository.dart';
import '../../features/account/domain/repositories/user_profile_persistence_repository.dart';
import '../../features/account/domain/repositories/user_profile_repository.dart';
import '../../features/auth/data/firebase_runiac_auth_repository.dart';
import '../../features/auth/domain/runiac_auth_service.dart';
import '../../features/run/data/run_repository_factory.dart';
import '../../features/run/domain/repositories/run_repository.dart';
import '../../firebase_options.dart';
import 'runiac_firestore_gateway.dart';

class RuniacFirebaseBootstrap {
  const RuniacFirebaseBootstrap._();

  static Future<RuniacFirebaseBootstrapResult> initialize({
    RuniacFirebaseRuntimeConfig? config,
    bool enableAnonymousEmulatorSignIn = true,
    RuniacFirestoreConnector? firestoreConnector,
  }) async {
    final runtimeConfig =
        config ?? RuniacFirebaseRuntimeConfig.fromEnvironment();
    if (!runtimeConfig.useFirebaseEmulator) {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final firebaseAuth = FirebaseAuth.instance;
      final authRepository = FirebaseRuniacAuthRepository(
        firebaseAuth: firebaseAuth,
      );
      final firestoreGateway = RuniacFirestoreGateway.configure(
        useFirebaseEmulator: runtimeConfig.useFirebaseEmulator,
        emulatorHost: runtimeConfig.emulatorHost,
        connector: firestoreConnector,
      );
      return RuniacFirebaseBootstrapResult(
        runRepository: RunRepositoryFactory.create(config: runtimeConfig),
        authRepository: authRepository,
        profileRepository: FirestoreUserProfileRepository(
          authRepository: authRepository,
        ),
        profilePersistenceRepository:
            FirestoreUserProfilePersistenceRepository(),
        firestoreGateway: firestoreGateway,
      );
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-runiac-functions-test',
          appId: '1:000000000000:ios:runiacfunctionstest',
          messagingSenderId: '000000000000',
          projectId: 'runiac-functions-test',
        ),
      );
    }

    final firebaseAuth = FirebaseAuth.instance;
    await _useAuthEmulator(firebaseAuth, runtimeConfig);
    FirebaseFunctions.instanceFor(
      region: 'asia-southeast1',
    ).useFunctionsEmulator(runtimeConfig.emulatorHost, 5001);
    final firestoreGateway = RuniacFirestoreGateway.configure(
      useFirebaseEmulator: runtimeConfig.useFirebaseEmulator,
      emulatorHost: runtimeConfig.emulatorHost,
      connector: firestoreConnector,
    );

    if (enableAnonymousEmulatorSignIn && firebaseAuth.currentUser == null) {
      await firebaseAuth.signInAnonymously();
    }

    final authRepository = FirebaseRuniacAuthRepository(
      firebaseAuth: firebaseAuth,
    );

    return RuniacFirebaseBootstrapResult(
      runRepository: RunRepositoryFactory.create(config: runtimeConfig),
      authRepository: authRepository,
      profileRepository: FirestoreUserProfileRepository(
        authRepository: authRepository,
      ),
      profilePersistenceRepository: FirestoreUserProfilePersistenceRepository(),
      firestoreGateway: firestoreGateway,
    );
  }

  static Future<void> _useAuthEmulator(
    FirebaseAuth firebaseAuth,
    RuniacFirebaseRuntimeConfig runtimeConfig,
  ) {
    return firebaseAuth.useAuthEmulator(runtimeConfig.emulatorHost, 9099);
  }
}

class RuniacFirebaseBootstrapResult {
  const RuniacFirebaseBootstrapResult({
    required this.runRepository,
    required this.authRepository,
    required this.profileRepository,
    required this.profilePersistenceRepository,
    required this.firestoreGateway,
  });

  final RunRepository runRepository;
  final RuniacAuthRepository authRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final RuniacFirestoreGateway firestoreGateway;
}
