import 'package:flutter/material.dart';

import 'app.dart';
import 'core/firebase/runiac_firebase_bootstrap.dart';
import 'features/feed/presentation/qa/feed_mvp_qa_launcher.dart';
import 'features/run/presentation/qa/xp_update_qa_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final qaApp = buildXpUpdateQaAppFromEnvironment();
  if (qaApp != null) {
    runApp(qaApp);
    return;
  }
  final feedQaApp = buildFeedMvpQaAppFromEnvironment();
  if (feedQaApp != null) {
    runApp(feedQaApp);
    return;
  }

  final bootstrap = await RuniacFirebaseBootstrap.initialize(
    enableAnonymousEmulatorSignIn: false,
  );

  runApp(
    RuniacApp(
      authRepository: bootstrap.authRepository,
      runRepository: bootstrap.runRepository,
      homeGuideAgent: bootstrap.homeGuideAgent,
      activityHistoryRepository: bootstrap.activityHistoryRepository,
      userProgressRepository: bootstrap.userProgressRepository,
      leaderboardRepository: bootstrap.leaderboardRepository,
      profileRepository: bootstrap.profileRepository,
      profilePersistenceRepository: bootstrap.profilePersistenceRepository,
      generatedPlanPersistenceRepository:
          bootstrap.generatedPlanPersistenceRepository,
      planProgressRepository: bootstrap.planProgressRepository,
      adaptivePlanEstimateRepository: bootstrap.adaptivePlanEstimateRepository,
      feedRepository: bootstrap.feedRepository,
      notificationInboxRepository: bootstrap.notificationInboxRepository,
      notificationRegistrationService:
          bootstrap.notificationRegistrationService,
      showAuth: true,
      showOnboarding: true,
    ),
  );
}
