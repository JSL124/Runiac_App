import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/account/data/firestore_user_profile_persistence_repository.dart';
import '../../features/account/data/firestore_user_profile_repository.dart';
import '../../features/account/data/static_user_profile_repository.dart';
import '../../features/account/domain/repositories/user_profile_persistence_repository.dart';
import '../../features/account/domain/repositories/user_profile_repository.dart';
import '../../features/auth/data/firebase_runiac_auth_repository.dart';
import '../../features/auth/data/non_production_auth_repository.dart';
import '../../features/auth/domain/runiac_auth_service.dart';
import '../../features/plan/data/firestore_generated_plan_persistence_repository.dart';
import '../../features/plan/domain/repositories/generated_plan_persistence_repository.dart';
import '../../features/run/data/run_repository_factory.dart';
import '../../features/run/domain/repositories/run_repository.dart';
import '../../features/you/data/firestore_activity_history_repository.dart';
import '../../features/you/data/firestore_user_progress_repository.dart';
import '../../features/you/data/static_activity_history_repository.dart';
import '../../features/you/domain/repositories/activity_history_repository.dart';
import '../../features/you/domain/repositories/user_progress_repository.dart';
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
      final productionOptions = _productionOptionsFor(runtimeConfig);
      if (productionOptions == null) {
        return RuniacFirebaseBootstrapResult(
          runRepository: RunRepositoryFactory.create(config: runtimeConfig),
          authRepository: const NonProductionAuthRepository(),
          activityHistoryRepository: const StaticActivityHistoryRepository(),
          userProgressRepository: const StaticUserProgressRepository(),
          profileRepository: const StaticUserProfileRepository(),
          profilePersistenceRepository:
              const NoopUserProfilePersistenceRepository(),
          generatedPlanPersistenceRepository:
              const NoopGeneratedPlanPersistenceRepository(),
          firestoreGateway: RuniacFirestoreGateway.configure(
            useFirebaseEmulator: runtimeConfig.useFirebaseEmulator,
            emulatorHost: runtimeConfig.emulatorHost,
            connector: firestoreConnector,
          ),
        );
      }
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: productionOptions);
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
        activityHistoryRepository: FirestoreActivityHistoryRepository(
          authRepository: authRepository,
        ),
        userProgressRepository: FirestoreUserProgressRepository(
          authRepository: authRepository,
        ),
        profileRepository: FirestoreUserProfileRepository(
          authRepository: authRepository,
        ),
        profilePersistenceRepository:
            FirestoreUserProfilePersistenceRepository(),
        generatedPlanPersistenceRepository:
            FirestoreGeneratedPlanPersistenceRepository(),
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
      activityHistoryRepository: FirestoreActivityHistoryRepository(
        authRepository: authRepository,
      ),
      userProgressRepository: FirestoreUserProgressRepository(
        authRepository: authRepository,
      ),
      profileRepository: FirestoreUserProfileRepository(
        authRepository: authRepository,
      ),
      profilePersistenceRepository: FirestoreUserProfilePersistenceRepository(),
      generatedPlanPersistenceRepository:
          FirestoreGeneratedPlanPersistenceRepository(),
      firestoreGateway: firestoreGateway,
    );
  }

  static Future<void> _useAuthEmulator(
    FirebaseAuth firebaseAuth,
    RuniacFirebaseRuntimeConfig runtimeConfig,
  ) {
    return firebaseAuth.useAuthEmulator(runtimeConfig.emulatorHost, 9099);
  }

  static FirebaseOptions? _productionOptionsFor(
    RuniacFirebaseRuntimeConfig runtimeConfig,
  ) {
    if (!runtimeConfig.useProductionFirebase) {
      return null;
    }

    if (runtimeConfig.productionApiKey.isEmpty ||
        runtimeConfig.productionAppId.isEmpty ||
        runtimeConfig.productionMessagingSenderId.isEmpty ||
        runtimeConfig.productionProjectId.isEmpty) {
      throw StateError(
        'Production Firebase requires RUNIAC_FIREBASE_API_KEY, '
        'RUNIAC_FIREBASE_APP_ID, RUNIAC_FIREBASE_MESSAGING_SENDER_ID, and '
        'RUNIAC_FIREBASE_PROJECT_ID dart-defines.',
      );
    }

    return FirebaseOptions(
      apiKey: runtimeConfig.productionApiKey,
      appId: runtimeConfig.productionAppId,
      messagingSenderId: runtimeConfig.productionMessagingSenderId,
      projectId: runtimeConfig.productionProjectId,
    );
  }
}

class RuniacFirebaseBootstrapResult {
  const RuniacFirebaseBootstrapResult({
    required this.runRepository,
    required this.authRepository,
    required this.activityHistoryRepository,
    required this.userProgressRepository,
    required this.profileRepository,
    required this.profilePersistenceRepository,
    required this.generatedPlanPersistenceRepository,
    required this.firestoreGateway,
  });

  final RunRepository runRepository;
  final RuniacAuthRepository authRepository;
  final ActivityHistoryRepository activityHistoryRepository;
  final UserProgressRepository userProgressRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final GeneratedPlanPersistenceRepository generatedPlanPersistenceRepository;
  final RuniacFirestoreGateway firestoreGateway;
}
