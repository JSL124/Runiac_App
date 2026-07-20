import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../features/profile/data/firestore_user_account_repository.dart';
import '../../features/profile/data/firestore_user_profile_persistence_repository.dart';
import '../../features/profile/data/firestore_user_profile_repository.dart';
import '../../features/profile/data/static_user_profile_repository.dart';
import '../../features/profile/domain/repositories/user_account_repository.dart';
import '../../features/profile/domain/repositories/user_profile_persistence_repository.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/auth/data/firebase_runiac_auth_repository.dart';
import '../../features/auth/data/non_production_auth_repository.dart';
import '../../features/auth/domain/runiac_auth_service.dart';
import '../../features/challenge/data/firebase_challenge_repository.dart';
import '../../features/challenge/data/firestore_challenge_read_store.dart';
import '../../features/challenge/data/shared_preferences_challenge_result_seen_store.dart';
import '../../features/challenge/data/static_challenge_repository.dart';
import '../../features/challenge/domain/repositories/challenge_repository.dart';
import '../../features/challenge/presentation/challenge_result_presentation_controller.dart';
import '../../features/feed/data/firebase_feed_repository/firebase_feed_data_port.dart';
import '../../features/feed/data/firebase_feed_repository/firebase_feed_repository.dart';
import '../../features/feed/data/static_feed_repository.dart';
import '../../features/feed/domain/repositories/feed_repository.dart';
import '../../features/friends/data/firebase_friends_repository.dart';
import '../../features/friends/data/static_friends_repository.dart';
import '../../features/friends/domain/repositories/friends_repository.dart';
import '../../features/home/data/home_guide_agent_factory.dart';
import '../../features/home/data/cloud_function_home_guide_consent_repository.dart';
import '../../features/home/domain/guide/home_guide_consent.dart';
import '../../features/home/domain/guide/home_guide_agent.dart';
import '../../features/leaderboard/data/firestore_leaderboard_repository.dart';
import '../../features/leaderboard/data/static_leaderboard_repository.dart';
import '../../features/leaderboard/domain/repositories/leaderboard_repository.dart';
import '../../features/notifications/data/cloud_firestore_notification_inbox_document_store.dart';
import '../../features/notifications/data/cloud_functions_notification_device_callable.dart';
import '../../features/notifications/data/firebase_messaging_push_notification_client.dart';
import '../../features/notifications/data/firestore_notification_inbox_repository.dart';
import '../../features/notifications/domain/repositories/notification_inbox_repository.dart';
import '../../features/notifications/domain/services/notification_registration_service.dart';
import '../../features/plan/data/firestore_adaptive_plan_estimate_repository.dart';
import '../../features/plan/data/firestore_generated_plan_persistence_repository.dart';
import '../../features/plan/data/firestore_plan_progress_repository.dart';
import '../../features/plan/domain/repositories/adaptive_plan_estimate_repository.dart';
import '../../features/plan/domain/repositories/generated_plan_persistence_repository.dart';
import '../../features/plan/domain/repositories/plan_progress_repository.dart';
import '../../features/run/data/run_repository_factory.dart';
import '../../features/run/domain/repositories/run_repository.dart';
import '../../features/you/data/firestore_activity_history_repository.dart';
import '../../features/you/data/firestore_user_progress_repository.dart';
import '../../features/you/data/user_streak_refresh_service.dart';
import '../../features/you/data/static_activity_history_repository.dart';
import '../../features/you/domain/repositories/activity_history_repository.dart';
import '../../features/you/domain/repositories/user_progress_repository.dart';
import 'runiac_firestore_gateway.dart';

class RuniacFirebaseBootstrap {
  const RuniacFirebaseBootstrap._();

  static const emulatorFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyA00000000000000000000000000000000',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-runiac-feed',
    storageBucket: 'demo-runiac-feed.appspot.com',
  );

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
          homeGuideAgent: HomeGuideAgentFactory.create(config: runtimeConfig),
          homeGuideConsentRepository:
              const AlwaysGrantedHomeGuideConsentRepository(),
          authRepository: const NonProductionAuthRepository(),
          activityHistoryRepository: const StaticActivityHistoryRepository(),
          userProgressRepository: const StaticUserProgressRepository(),
          leaderboardRepository: const StaticLeaderboardRepository(),
          friendsRepository: const StaticFriendsRepository(),
          profileRepository: const StaticUserProfileRepository(),
          userAccountRepository: const StaticUserAccountRepository(),
          profilePersistenceRepository:
              const NoopUserProfilePersistenceRepository(),
          generatedPlanPersistenceRepository:
              const NoopGeneratedPlanPersistenceRepository(),
          planProgressRepository: const NoopPlanProgressRepository(),
          adaptivePlanEstimateRepository:
              const NoopAdaptivePlanEstimateRepository(),
          feedRepository: const StaticFeedRepository(),
          notificationInboxRepository:
              const StaticNotificationInboxRepository(),
          notificationRegistrationService: null,
          challengeRepository: const StaticChallengeRepository(),
          challengeResultPresenter: null,
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
      final challengeRepository = _firebaseChallengeRepository(authRepository);
      return RuniacFirebaseBootstrapResult(
        runRepository: RunRepositoryFactory.create(config: runtimeConfig),
        homeGuideAgent: HomeGuideAgentFactory.create(config: runtimeConfig),
        homeGuideConsentRepository: CloudFunctionHomeGuideConsentRepository(),
        authRepository: authRepository,
        challengeRepository: challengeRepository,
        challengeResultPresenter: _challengeResultPresenter(
          challengeRepository,
          authRepository,
        ),
        activityHistoryRepository: FirestoreActivityHistoryRepository(
          authRepository: authRepository,
        ),
        userProgressRepository: FirestoreUserProgressRepository(
          authRepository: authRepository,
          streakRefreshService: CloudFunctionUserStreakRefreshService(),
        ),
        leaderboardRepository: FirestoreLeaderboardRepository(
          authRepository: authRepository,
        ),
        friendsRepository: FirebaseFriendsRepository(
          authRepository: authRepository,
        ),
        profileRepository: FirestoreUserProfileRepository(
          authRepository: authRepository,
        ),
        userAccountRepository: FirestoreUserAccountRepository(
          authRepository: authRepository,
        ),
        profilePersistenceRepository:
            FirestoreUserProfilePersistenceRepository(),
        generatedPlanPersistenceRepository:
            FirestoreGeneratedPlanPersistenceRepository(),
        planProgressRepository: FirestorePlanProgressRepository(),
        adaptivePlanEstimateRepository:
            FirestoreAdaptivePlanEstimateRepository(),
        feedRepository: FirebaseFeedRepository(port: FirebaseFeedDataPort()),
        notificationInboxRepository: FirestoreNotificationInboxRepository(
          ownerUidProvider: () => authRepository.currentUser?.uid,
          documentStore: CloudFirestoreNotificationInboxDocumentStore(),
        ),
        notificationRegistrationService: NotificationRegistrationService(
          client: FirebaseMessagingPushNotificationClient(),
          callable: CloudFunctionsNotificationDeviceCallable(),
          ownerUidProvider: () => authRepository.currentUser?.uid,
          applePushRegistrationEnabled:
              runtimeConfig.enableIosPushNotifications,
        ),
        firestoreGateway: firestoreGateway,
      );
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: emulatorFirebaseOptions);
    }

    final firebaseAuth = FirebaseAuth.instance;
    await _useAuthEmulator(firebaseAuth, runtimeConfig);
    FirebaseFunctions.instanceFor(
      region: 'asia-southeast1',
    ).useFunctionsEmulator(runtimeConfig.emulatorHost, 5001);
    FirebaseStorage.instance.useStorageEmulator(
      runtimeConfig.emulatorHost,
      9199,
    );
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
    final challengeRepository = _firebaseChallengeRepository(authRepository);

    return RuniacFirebaseBootstrapResult(
      runRepository: RunRepositoryFactory.create(config: runtimeConfig),
      homeGuideAgent: HomeGuideAgentFactory.create(config: runtimeConfig),
      homeGuideConsentRepository: CloudFunctionHomeGuideConsentRepository(),
      authRepository: authRepository,
      challengeRepository: challengeRepository,
      challengeResultPresenter: _challengeResultPresenter(
        challengeRepository,
        authRepository,
      ),
      activityHistoryRepository: FirestoreActivityHistoryRepository(
        authRepository: authRepository,
      ),
      userProgressRepository: FirestoreUserProgressRepository(
        authRepository: authRepository,
        streakRefreshService: CloudFunctionUserStreakRefreshService(),
      ),
      leaderboardRepository: FirestoreLeaderboardRepository(
        authRepository: authRepository,
      ),
      friendsRepository: FirebaseFriendsRepository(
        authRepository: authRepository,
      ),
      profileRepository: FirestoreUserProfileRepository(
        authRepository: authRepository,
      ),
      userAccountRepository: FirestoreUserAccountRepository(
        authRepository: authRepository,
      ),
      profilePersistenceRepository: FirestoreUserProfilePersistenceRepository(),
      generatedPlanPersistenceRepository:
          FirestoreGeneratedPlanPersistenceRepository(),
      planProgressRepository: FirestorePlanProgressRepository(),
      adaptivePlanEstimateRepository: FirestoreAdaptivePlanEstimateRepository(),
      feedRepository: FirebaseFeedRepository(port: FirebaseFeedDataPort()),
      notificationInboxRepository: FirestoreNotificationInboxRepository(
        ownerUidProvider: () => authRepository.currentUser?.uid,
        documentStore: CloudFirestoreNotificationInboxDocumentStore(),
      ),
      notificationRegistrationService: NotificationRegistrationService(
        client: FirebaseMessagingPushNotificationClient(),
        callable: CloudFunctionsNotificationDeviceCallable(),
        ownerUidProvider: () => authRepository.currentUser?.uid,
        applePushRegistrationEnabled: runtimeConfig.enableIosPushNotifications,
      ),
      firestoreGateway: firestoreGateway,
    );
  }

  /// Callable-backed Challenge repository with the member-scoped Firestore read
  /// store for the two read paths (history, badges) that have no callable.
  static ChallengeRepository _firebaseChallengeRepository(
    RuniacAuthRepository authRepository,
  ) {
    return FirebaseChallengeRepository(
      currentUid: () => authRepository.currentUser?.uid,
      readStore: FirestoreChallengeReadStore(),
    );
  }

  /// One-shot foreground Result presenter with a durable, uid-scoped local
  /// seen-marker.
  static ChallengeResultPresentationController _challengeResultPresenter(
    ChallengeRepository challengeRepository,
    RuniacAuthRepository authRepository,
  ) {
    return ChallengeResultPresentationController(
      repository: challengeRepository,
      seenStore: SharedPreferencesChallengeResultSeenStore(
        uidProvider: () => authRepository.currentUser?.uid,
      ),
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
      storageBucket: runtimeConfig.productionStorageBucket.isEmpty
          ? null
          : runtimeConfig.productionStorageBucket,
    );
  }
}

class RuniacFirebaseBootstrapResult {
  const RuniacFirebaseBootstrapResult({
    required this.runRepository,
    required this.homeGuideAgent,
    required this.homeGuideConsentRepository,
    required this.authRepository,
    required this.activityHistoryRepository,
    required this.userProgressRepository,
    required this.leaderboardRepository,
    required this.friendsRepository,
    required this.profileRepository,
    required this.userAccountRepository,
    required this.profilePersistenceRepository,
    required this.generatedPlanPersistenceRepository,
    required this.planProgressRepository,
    required this.adaptivePlanEstimateRepository,
    required this.feedRepository,
    required this.notificationInboxRepository,
    required this.notificationRegistrationService,
    required this.challengeRepository,
    required this.challengeResultPresenter,
    required this.firestoreGateway,
  });

  final RunRepository runRepository;
  final HomeGuideAgent homeGuideAgent;
  final HomeGuideConsentRepository homeGuideConsentRepository;
  final RuniacAuthRepository authRepository;
  final ActivityHistoryRepository activityHistoryRepository;
  final UserProgressRepository userProgressRepository;
  final LeaderboardRepository leaderboardRepository;
  final FriendsRepository friendsRepository;
  final UserProfileRepository profileRepository;

  /// Read-only trusted `users/{uid}` account seam backing the app-level
  /// subscription-status stream.
  final UserAccountRepository userAccountRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final GeneratedPlanPersistenceRepository generatedPlanPersistenceRepository;
  final PlanProgressRepository planProgressRepository;
  final AdaptivePlanEstimateRepository adaptivePlanEstimateRepository;
  final FeedRepository feedRepository;
  final NotificationInboxRepository notificationInboxRepository;
  final NotificationRegistrationService? notificationRegistrationService;

  /// Server-owned Challenge distance-system source. Firebase-active paths supply
  /// the callable-backed repository with a member-scoped Firestore read store;
  /// the no-Firebase path keeps the deterministic static source.
  final ChallengeRepository challengeRepository;

  /// One-shot foreground Result presenter; non-null only on Firebase-active
  /// paths (durable local seen-marker), null for the static/no-config path.
  final ChallengeResultPresentationController? challengeResultPresenter;
  final RuniacFirestoreGateway firestoreGateway;
}
