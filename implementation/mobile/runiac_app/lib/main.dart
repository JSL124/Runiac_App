import 'package:flutter/material.dart';

import 'app.dart';
import 'core/firebase/runiac_firebase_bootstrap.dart';
import 'features/run/presentation/qa/xp_update_qa_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final qaApp = buildXpUpdateQaAppFromEnvironment();
  if (qaApp != null) {
    runApp(qaApp);
    return;
  }

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
      planProgressRepository: bootstrap.planProgressRepository,
      adaptivePlanEstimateRepository: bootstrap.adaptivePlanEstimateRepository,
      notificationInboxRepository: bootstrap.notificationInboxRepository,
      notificationRegistrationService:
          bootstrap.notificationRegistrationService,
      showAuth: true,
      showOnboarding: true,
    ),
  );
}
