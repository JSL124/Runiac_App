import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/firebase/runiac_app_check_bootstrap.dart';
import 'core/firebase/runiac_firebase_bootstrap.dart';
import 'features/feed/presentation/qa/feed_mvp_qa_launcher.dart';
import 'features/leaderboard/presentation/qa/leaderboard_ranking_qa_launcher.dart';
import 'features/run/data/run_repository_factory.dart';
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
  final leaderboardQaApp = buildLeaderboardRankingQaAppFromEnvironment();
  if (leaderboardQaApp != null) {
    runApp(leaderboardQaApp);
    return;
  }

  final runtimeConfig = RuniacFirebaseRuntimeConfig.fromEnvironment();
  final bootstrap = await RuniacFirebaseBootstrap.initialize(
    config: runtimeConfig,
    enableAnonymousEmulatorSignIn: false,
  );
  if (runtimeConfig.useFirebaseEmulator ||
      runtimeConfig.useProductionFirebase) {
    const appCheckDebugToken = String.fromEnvironment(
      'RUNIAC_APPCHECK_DEBUG_TOKEN',
    );
    // An explicitly supplied debug token opts this build into the App Check
    // debug providers even in release, so `run_runiac_release` on a dev device
    // still passes enforced callables. Store/TestFlight builds ship without the
    // dart-define, so they keep real Play Integrity / App Attest attestation.
    await RuniacAppCheckBootstrap.activate(
      useDebugProviders:
          kDebugMode ||
          runtimeConfig.useFirebaseEmulator ||
          appCheckDebugToken.isNotEmpty,
      debugToken: appCheckDebugToken.isEmpty ? null : appCheckDebugToken,
    );
  }

  runApp(
    RuniacApp(
      authRepository: bootstrap.authRepository,
      runRepository: bootstrap.runRepository,
      homeGuideAgent: bootstrap.homeGuideAgent,
      homeGuideConsentRepository: bootstrap.homeGuideConsentRepository,
      activityHistoryRepository: bootstrap.activityHistoryRepository,
      userProgressRepository: bootstrap.userProgressRepository,
      leaderboardRepository: bootstrap.leaderboardRepository,
      friendsRepository: bootstrap.friendsRepository,
      challengeRepository: bootstrap.challengeRepository,
      challengeResultPresenter: bootstrap.challengeResultPresenter,
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
