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
      profileRepository: bootstrap.profileRepository,
      profilePersistenceRepository: bootstrap.profilePersistenceRepository,
      showAuth: true,
      showOnboarding: true,
    ),
  );
}
