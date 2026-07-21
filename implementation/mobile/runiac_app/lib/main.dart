import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/firebase/runiac_app_check_bootstrap.dart';
import 'core/firebase/runiac_firebase_bootstrap.dart';
import 'core/observability/error_screen_tracker.dart';
import 'core/observability/runiac_error_reporter.dart';
import 'features/feed/presentation/qa/feed_mvp_qa_launcher.dart';
import 'features/leaderboard/presentation/qa/leaderboard_ranking_qa_launcher.dart';
import 'features/run/data/run_repository_factory.dart';
import 'features/run/presentation/qa/xp_update_qa_launcher.dart';

Future<void> main() async {
  // `WidgetsFlutterBinding.ensureInitialized()` and the final `runApp` call
  // below must run in the same zone — Flutter requires this and treats a
  // mismatch as a fatal error when fatal zone errors are enabled. Wrapping
  // the whole body (including the binding init and the QA early-return
  // paths) in a single `runZonedGuarded` call satisfies that, while leaving
  // every early-return path's behaviour unchanged.
  RuniacErrorReporter? errorReporter;
  await runZonedGuarded(
    () async {
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

      errorReporter = RuniacErrorReporter();
      _installGlobalErrorReportingHooks(errorReporter!);
      unawaited(errorReporter!.flushPending());

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
          userAccountRepository: bootstrap.userAccountRepository,
          profilePersistenceRepository: bootstrap.profilePersistenceRepository,
          generatedPlanPersistenceRepository:
              bootstrap.generatedPlanPersistenceRepository,
          planProgressRepository: bootstrap.planProgressRepository,
          adaptivePlanEstimateRepository:
              bootstrap.adaptivePlanEstimateRepository,
          feedRepository: bootstrap.feedRepository,
          notificationInboxRepository: bootstrap.notificationInboxRepository,
          notificationRegistrationService:
              bootstrap.notificationRegistrationService,
          showAuth: true,
          showOnboarding: true,
        ),
      );
    },
    (error, stack) {
      // `errorReporter` may still be null if the error happened before it
      // was constructed (e.g. during Firebase bootstrap); nothing can be
      // reported yet in that case, so this is a no-op rather than a crash.
      unawaited(
        errorReporter?.reportError(
          error,
          stack,
          screen: runiacErrorScreenTracker.currentScreen,
          fatal: true,
        ),
      );
    },
  );
}

/// Installs the global Dart-level error hooks that feed
/// [RuniacErrorReporter]. `runZonedGuarded` (wrapped around the final
/// `runApp` above) covers uncaught async errors inside that zone;
/// `FlutterError.onError` and `PlatformDispatcher.instance.onError` cover
/// framework-reported and platform-reported errors respectively. None of
/// these hooks can throw without crashing the app, so every call into the
/// reporter here is fire-and-forget and the reporter itself never rethrows.
void _installGlobalErrorReportingHooks(RuniacErrorReporter reporter) {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    previousOnError?.call(details);
    unawaited(
      reporter.reportError(
        details.exception,
        details.stack,
        screen: runiacErrorScreenTracker.currentScreen,
        fatal: false,
      ),
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    unawaited(
      reporter.reportError(
        error,
        stack,
        screen: runiacErrorScreenTracker.currentScreen,
        fatal: true,
      ),
    );
    // Report it, but do not claim it as handled: returning `false` lets the
    // engine's default handler still print it, so installing the reporter
    // does not silently make local debugging worse.
    return false;
  };
}
