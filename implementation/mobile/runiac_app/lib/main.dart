import 'package:flutter/material.dart';

import 'app.dart';
import 'core/firebase/runiac_firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrap = await RuniacFirebaseBootstrap.initialize(
    enableAnonymousEmulatorSignIn: false,
  );

  runApp(
    RuniacApp(
      authRepository: bootstrap.authRepository,
      runRepository: bootstrap.runRepository,
      activityHistoryRepository: bootstrap.activityHistoryRepository,
      userProgressRepository: bootstrap.userProgressRepository,
      profileRepository: bootstrap.profileRepository,
      profilePersistenceRepository: bootstrap.profilePersistenceRepository,
      generatedPlanPersistenceRepository:
          bootstrap.generatedPlanPersistenceRepository,
      showAuth: true,
      showOnboarding: true,
    ),
  );
}
