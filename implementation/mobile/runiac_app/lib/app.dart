import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/characters/local_selected_runner_character_storage.dart';
import 'core/characters/runner_character.dart';
import 'core/theme/runiac_theme.dart';
import 'features/account/data/static_user_profile_repository.dart';
import 'features/account/domain/models/user_profile_read_model.dart';
import 'features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'features/account/domain/repositories/user_profile_repository.dart';
import 'features/account/presentation/personal_profile_collection_screen.dart';
import 'features/auth/data/non_production_auth_repository.dart';
import 'features/auth/domain/runiac_auth_service.dart';
import 'features/auth/presentation/runiac_auth_gate.dart';
import 'features/auth/presentation/runiac_profile_setup_gate.dart';
import 'features/feed/data/static_feed_repository.dart';
import 'features/feed/domain/repositories/feed_repository.dart';
import 'features/feed/presentation/current_session_feed.dart';
import 'features/home/domain/guide/home_guide_agent.dart';
import 'features/home/domain/guide/rule_based_home_guide_agent.dart';
import 'features/onboarding/domain/models/local_onboarding_draft.dart';
import 'features/notifications/domain/models/notification_inbox_item.dart';
import 'features/notifications/domain/repositories/notification_inbox_repository.dart';
import 'features/notifications/domain/services/notification_registration_service.dart';
import 'features/leaderboard/data/static_leaderboard_repository.dart';
import 'features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'features/plan/domain/models/adaptive_plan_estimate_read_model.dart';
import 'features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'features/plan/domain/models/plan_progress_read_model.dart';
import 'features/plan/domain/repositories/adaptive_plan_estimate_repository.dart';
import 'features/plan/domain/repositories/generated_plan_persistence_repository.dart';
import 'features/plan/domain/repositories/plan_progress_repository.dart';
import 'features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'features/plan/presentation/current_session_generated_plan.dart';
import 'features/run/data/static_run_repository.dart';
import 'features/run/domain/repositories/run_repository.dart';
import 'features/run/presentation/active_run_session_coordinator.dart';
import 'features/run/presentation/run_open_intent.dart';
import 'features/run/presentation/run_repository_scope.dart';
import 'features/you/data/static_activity_history_repository.dart';
import 'features/you/data/local_pending_run_activity_store.dart';
import 'features/you/domain/models/user_progress_read_model.dart';
import 'features/you/domain/repositories/activity_history_repository.dart';
import 'features/you/domain/repositories/user_progress_repository.dart';
import 'features/onboarding/presentation/runiac_character_selection_gate.dart';
import 'features/onboarding/presentation/runiac_onboarding_gate.dart';
import 'features/shell/runiac_shell.dart';
import 'features/splash/presentation/runiac_splash_tokens.dart';
import 'features/splash/presentation/runiac_startup_gate.dart';
import 'features/you/presentation/current_session_activity_history.dart';
import 'features/you/presentation/widgets/activity_route_snapshot_thumbnail_cache.dart';

export 'features/run/presentation/run_open_intent.dart';

class RuniacApp extends StatefulWidget {
  const RuniacApp({
    super.key,
    this.showSplash = true,
    this.showAuth = false,
    this.showOnboarding = false,
    this.splashDuration = RuniacSplashTokens.minVisibleDuration,
    this.authRepository = const NonProductionAuthRepository(),
    this.runRepository = const StaticRunRepository(),
    this.activityHistoryRepository = const StaticActivityHistoryRepository(),
    this.userProgressRepository = const StaticUserProgressRepository(),
    this.leaderboardRepository = const StaticLeaderboardRepository(),
    this.profileRepository = const StaticUserProfileRepository(),
    this.profilePersistenceRepository =
        const NoopUserProfilePersistenceRepository(),
    this.generatedPlanPersistenceRepository =
        const NoopGeneratedPlanPersistenceRepository(),
    this.planProgressRepository = const NoopPlanProgressRepository(),
    this.adaptivePlanEstimateRepository =
        const NoopAdaptivePlanEstimateRepository(),
    this.notificationInboxRepository =
        const StaticNotificationInboxRepository(),
    this.notificationRegistrationService,
    this.homeGuideAgent = const RuleBasedHomeGuideAgent(),
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.initialRunOpenIntent,
    this.currentSessionActivityHistoryStore,
    this.currentSessionFeedStore,
    this.feedRepository,
    this.currentSessionGeneratedPlanStore,
    this.initialPersonalProfileDraft,
    this.onOnboardingCompleted,
    this.youProgressToday,
  });

  final bool showSplash;
  final bool showAuth;
  final bool showOnboarding;
  final Duration splashDuration;
  final RuniacAuthRepository authRepository;
  final RunRepository runRepository;
  final ActivityHistoryRepository activityHistoryRepository;
  final UserProgressRepository userProgressRepository;
  final LeaderboardRepository leaderboardRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final GeneratedPlanPersistenceRepository generatedPlanPersistenceRepository;
  final PlanProgressRepository planProgressRepository;
  final AdaptivePlanEstimateRepository adaptivePlanEstimateRepository;
  final NotificationInboxRepository notificationInboxRepository;
  final NotificationRegistrationService? notificationRegistrationService;

  /// Guide seam forwarded down to `HomeTab`'s stage-map speech bubble.
  final HomeGuideAgent homeGuideAgent;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final RunOpenIntent? initialRunOpenIntent;
  final CurrentSessionActivityHistoryStore? currentSessionActivityHistoryStore;
  final CurrentSessionFeedStore? currentSessionFeedStore;
  final FeedRepository? feedRepository;
  final CurrentSessionGeneratedPlanStore? currentSessionGeneratedPlanStore;
  final PersonalProfileDraft? initialPersonalProfileDraft;
  final ValueChanged<LocalOnboardingDraft>? onOnboardingCompleted;
  final DateTime? youProgressToday;

  @override
  State<RuniacApp> createState() => _RuniacAppState();
}

class _RuniacAppState extends State<RuniacApp> {
  late final CurrentSessionActivityHistoryStore _activityHistoryStore;
  late final bool _ownsActivityHistoryStore;
  late final CurrentSessionFeedStore _feedStore;
  late final bool _ownsFeedStore;
  late FeedRepository _feedRepository;
  var _ownsFeedRepository = false;
  late final CurrentSessionGeneratedPlanStore _generatedPlanStore;
  late final bool _ownsGeneratedPlanStore;
  RuniacAuthCompletion? _authCompletion;
  PersonalProfileDraft? _personalProfileDraft;
  String? _generatedPlanOwnerUid;
  String? _generatedPlanHydrationProbeUid;
  PlanProgressReadModel? _planProgress;
  var _planProgressLoadSerial = 0;
  AdaptivePlanEstimateReadModel? _adaptivePlanEstimate;
  var _adaptivePlanEstimateLoadSerial = 0;
  String? _authStateError;
  bool _showMissingProfileSignupPrompt = false;
  StreamSubscription<PushNotificationMessage>? _pushNotificationSubscription;
  final SelectedRunnerCharacterStore _selectedCharacterStore =
      SelectedRunnerCharacterStore();
  final LocalSelectedRunnerCharacterStorage _selectedCharacterStorage =
      const SharedPreferencesSelectedRunnerCharacterStorage();
  late final ActivityRouteSnapshotThumbnailArtifactLifecycle
  _thumbnailArtifactLifecycle;

  @override
  void initState() {
    super.initState();
    _ownsActivityHistoryStore =
        widget.currentSessionActivityHistoryStore == null;
    _activityHistoryStore =
        widget.currentSessionActivityHistoryStore ??
        CurrentSessionActivityHistoryStore(
          ownerUid: widget.authRepository.currentUser?.uid,
          persistence: const SharedPreferencesLocalPendingRunActivityStore(),
          onRemoteRunSynced: _refreshUserProgressAfterRunSync,
        );
    final initialOwnerUid = widget.authRepository.currentUser?.uid;
    _thumbnailArtifactLifecycle =
        ActivityRouteSnapshotThumbnailArtifactLifecycle(
          initialOwnerUid: initialOwnerUid,
        );
    _ownsFeedStore = widget.currentSessionFeedStore == null;
    _feedStore =
        widget.currentSessionFeedStore ??
        CurrentSessionFeedStore(ownerUid: initialOwnerUid);
    if (!_ownsFeedStore) {
      _feedStore.syncOwner(initialOwnerUid);
    }
    _configureFeedRepository(widget.feedRepository);
    if (initialOwnerUid != null) {
      unawaited(_restoreAndSyncPendingRuns(ownerUid: initialOwnerUid));
    }
    _ownsGeneratedPlanStore = widget.currentSessionGeneratedPlanStore == null;
    _generatedPlanStore =
        widget.currentSessionGeneratedPlanStore ??
        CurrentSessionGeneratedPlanStore();
    _personalProfileDraft = widget.initialPersonalProfileDraft;
    _startPushNotificationsForCurrentUser();
    unawaited(
      _restoreSelectedCharacter(widget.authRepository.currentUser?.uid),
    );
  }

  Future<void> _restoreSelectedCharacter(String? uid) async {
    final stored = await _selectedCharacterStorage.readSelectedCharacter(
      uid: uid,
    );
    if (!mounted) {
      return;
    }
    if (stored != null) {
      _selectedCharacterStore.select(stored);
    } else {
      _selectedCharacterStore.clear();
    }
  }

  void _persistSelectedCharacter(RunnerCharacter character) {
    unawaited(
      _selectedCharacterStorage.writeSelectedCharacter(
        uid: widget.authRepository.currentUser?.uid,
        character: character,
      ),
    );
  }

  bool get _shouldShowCharacterSelection =>
      widget.showAuth && _shouldShowOnboarding;

  @override
  void didUpdateWidget(covariant RuniacApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authRepository != widget.authRepository ||
        oldWidget.profileRepository != widget.profileRepository) {
      _authCompletion = null;
      _personalProfileDraft = widget.initialPersonalProfileDraft;
      final nextOwnerUid = widget.authRepository.currentUser?.uid;
      _thumbnailArtifactLifecycle.syncOwner(nextOwnerUid);
      _scheduleActivityHistoryOwnerSync(nextOwnerUid);
      _feedStore.syncOwner(nextOwnerUid);
    }
    if (oldWidget.feedRepository != widget.feedRepository) {
      _configureFeedRepository(widget.feedRepository);
    }
    if (oldWidget.planProgressRepository != widget.planProgressRepository) {
      final ownerUid = _generatedPlanOwnerUid;
      final activePlan = _generatedPlanStore.activePlan;
      if (ownerUid != null && activePlan != null) {
        unawaited(_loadPlanProgress(ownerUid, activePlan.id));
      }
    }
    if (oldWidget.adaptivePlanEstimateRepository !=
        widget.adaptivePlanEstimateRepository) {
      final ownerUid = _generatedPlanOwnerUid;
      final activePlan = _generatedPlanStore.activePlan;
      if (ownerUid != null && activePlan != null) {
        unawaited(_loadAdaptivePlanEstimate(ownerUid, activePlan.id));
      }
    }
    if (oldWidget.notificationRegistrationService !=
        widget.notificationRegistrationService) {
      unawaited(_cancelPushNotificationSubscription());
      _startPushNotificationsForCurrentUser();
    }
  }

  @override
  void dispose() {
    if (_ownsActivityHistoryStore) {
      _activityHistoryStore.dispose();
    }
    if (_ownsFeedStore) {
      _feedStore.dispose();
    }
    _disposeOwnedFeedRepository();
    if (_ownsGeneratedPlanStore) {
      _generatedPlanStore.dispose();
    }
    unawaited(_cancelPushNotificationSubscription());
    unawaited(widget.notificationRegistrationService?.dispose());
    _selectedCharacterStore.dispose();
    super.dispose();
  }

  void _configureFeedRepository(FeedRepository? repository) {
    _disposeOwnedFeedRepository();
    _ownsFeedRepository = repository == null;
    _feedRepository = repository ?? const StaticFeedRepository();
  }

  void _disposeOwnedFeedRepository() {
    if (_ownsFeedRepository && _feedRepository is FeedTimelineRepository) {
      (_feedRepository as FeedTimelineRepository).dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CurrentSessionFeedScope(
      store: _feedStore,
      child: SelectedRunnerCharacterScope(
        store: _selectedCharacterStore,
        child: CurrentSessionActivityHistoryScope(
          store: _activityHistoryStore,
          child: CurrentSessionGeneratedPlanScope(
            store: _generatedPlanStore,
            child: RunRepositoryScope(
              repository: widget.runRepository,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Runiac',
                theme: buildRuniacTheme(),
                home: RuniacStartupGate(
                  showSplash: widget.showSplash,
                  splashDuration: widget.splashDuration,
                  child: RuniacAuthGate(
                    authRepository: widget.authRepository,
                    showAuth: widget.showAuth,
                    onAuthenticated: (completion) {
                      setState(() {
                        _authCompletion = completion;
                        _authStateError = null;
                        _showMissingProfileSignupPrompt = false;
                      });
                      _startPushNotificationsForCurrentUser();
                      unawaited(
                        _restoreSelectedCharacter(
                          widget.authRepository.currentUser?.uid,
                        ),
                      );
                    },
                    onAuthStateChanged: (user) {
                      _thumbnailArtifactLifecycle.syncOwner(user?.uid);
                      if (user == null) {
                        unawaited(_cancelPushNotificationSubscription());
                        unawaited(
                          widget.notificationRegistrationService
                              ?.unregisterCurrentDevice(),
                        );
                      }
                      _scheduleActivityHistoryOwnerSync(user?.uid);
                      _feedStore.syncOwner(user?.uid);
                      _clearGeneratedPlanForAuthChange(user?.uid);
                      unawaited(_restoreSelectedCharacter(user?.uid));
                    },
                    recoveryPrompt: _showMissingProfileSignupPrompt
                        ? const RuniacAuthRecoveryPrompt.signup(
                            message:
                                'No Runiac account setup exists for this account. Sign up to create your profile and start onboarding.',
                          )
                        : null,
                    childBuilder: (_) => _buildPostAuthFlow(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearGeneratedPlanForAuthChange(String? nextOwnerUid) {
    final currentPlanOwnerUid = _generatedPlanOwnerUid;
    final probeUid = _generatedPlanHydrationProbeUid;
    if (currentPlanOwnerUid == nextOwnerUid &&
        (probeUid == null || probeUid == nextOwnerUid)) {
      return;
    }
    _generatedPlanOwnerUid = null;
    _generatedPlanHydrationProbeUid = null;
    _planProgress = null;
    _planProgressLoadSerial += 1;
    _adaptivePlanEstimate = null;
    _adaptivePlanEstimateLoadSerial += 1;
    _generatedPlanStore.clear();
  }

  void _startPushNotificationsForCurrentUser() {
    final service = widget.notificationRegistrationService;
    if (widget.authRepository.currentUser == null || service == null) {
      return;
    }
    _pushNotificationSubscription ??= service.messages.listen(
      _saveReceivedPushNotification,
    );
    unawaited(service.start());
  }

  Future<void> _cancelPushNotificationSubscription() async {
    final subscription = _pushNotificationSubscription;
    _pushNotificationSubscription = null;
    await subscription?.cancel();
  }

  void _saveReceivedPushNotification(PushNotificationMessage message) {
    final title = message.title?.trim();
    final body = message.body?.trim();
    if (message.id.isEmpty || title == null || title.isEmpty) {
      return;
    }

    unawaited(
      widget.notificationInboxRepository
          .saveInboxItem(
            NotificationInboxItem(
              id: message.id,
              title: title,
              body: body == null || body.isEmpty ? title : body,
              createdAt: DateTime.now(),
              data: message.data,
            ),
          )
          .catchError((Object error, StackTrace stackTrace) {
            FlutterError.reportError(
              FlutterErrorDetails(
                exception: error,
                stack: stackTrace,
                library: 'runiac app',
                context: ErrorDescription(
                  'saving received push notification to inbox',
                ),
              ),
            );
          }),
    );
  }

  Future<void> _restoreAndSyncPendingRuns({required String ownerUid}) async {
    try {
      if (_activityHistoryStore.ownerUid != ownerUid) {
        return;
      }
      await _activityHistoryStore.restoreSavedActivities();
      if (_activityHistoryStore.ownerUid != ownerUid) {
        return;
      }
      await _activityHistoryStore.syncPendingRuns(widget.runRepository);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac app',
          context: ErrorDescription('restoring and syncing pending runs'),
        ),
      );
    }
  }

  Future<UserProgressReadModel> _refreshUserProgressAfterRunSync() async {
    try {
      return widget.userProgressRepository.refreshUserProgress();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac app',
          context: ErrorDescription('refreshing user progress after run sync'),
        ),
      );
      rethrow;
    }
  }

  Widget _buildPostAuthFlow() {
    final currentUser = widget.authRepository.currentUser;
    _scheduleActivityHistoryOwnerSync(currentUser?.uid);

    if (_shouldShowPersonalProfile) {
      if (currentUser == null) {
        return _AuthStateErrorScreen(
          message:
              _authStateError ??
              'We could not confirm your account. Please try signing in again.',
        );
      }
      return _buildPersonalProfileCollection(currentUser);
    }

    if (_shouldProbeSignedInProfileSetup(currentUser)) {
      return RuniacProfileSetupGate(
        authRepository: widget.authRepository,
        profileRepository: widget.profileRepository,
        currentUser: currentUser!,
        onLoadedProfile: (profile) {
          unawaited(_hydrateGeneratedPlanFromProfile(profile));
        },
        onRecoverableProfileMissing: () {
          if (!mounted) {
            return;
          }
          setState(() {
            _authCompletion = null;
            _personalProfileDraft = null;
            _showMissingProfileSignupPrompt = true;
          });
        },
        child: _buildOnboardingAndShell(),
      );
    }

    if (currentUser != null) {
      _scheduleGeneratedPlanRepositoryHydration(currentUser.uid);
    }

    return _buildOnboardingAndShell();
  }

  void _scheduleGeneratedPlanRepositoryHydration(String ownerUid) {
    if (_generatedPlanHydrationProbeUid == ownerUid ||
        _generatedPlanOwnerUid == ownerUid) {
      return;
    }
    _generatedPlanHydrationProbeUid = ownerUid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_restoreGeneratedPlanForOwner(ownerUid));
      }
    });
  }

  Future<void> _restoreGeneratedPlanForOwner(String ownerUid) async {
    BeginnerAdaptivePlanSnapshot? persistedPlan;
    try {
      persistedPlan = await widget.generatedPlanPersistenceRepository
          .loadGeneratedPlan(uid: ownerUid);
    } catch (_) {
      persistedPlan = null;
    }
    final stillCurrentUser = widget.authRepository.currentUser;
    if (!mounted ||
        stillCurrentUser?.uid != ownerUid ||
        persistedPlan == null) {
      return;
    }
    _setActiveGeneratedPlan(persistedPlan, ownerUid: ownerUid);
  }

  void _scheduleActivityHistoryOwnerSync(String? ownerUid) {
    if (_activityHistoryStore.ownerUid == ownerUid) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_activityHistoryStore.ownerUid == ownerUid) {
        return;
      }
      _activityHistoryStore.updateOwnerUid(ownerUid);
      if (ownerUid != null) {
        unawaited(_restoreAndSyncPendingRuns(ownerUid: ownerUid));
      }
    });
  }

  Widget _buildOnboardingAndShell() {
    return RuniacCharacterSelectionGate(
      active: _shouldShowCharacterSelection,
      store: _selectedCharacterStore,
      onCharacterConfirmed: _persistSelectedCharacter,
      child: RuniacOnboardingGate(
        showOnboarding: _shouldShowOnboarding,
        onCompletedDraft: _completeOnboarding,
        child: RuniacShell(
          authRepository: widget.authRepository,
          activityHistoryRepository: widget.activityHistoryRepository,
          feedRepository: _feedRepository,
          userProgressRepository: widget.userProgressRepository,
          leaderboardRepository: widget.leaderboardRepository,
          profileRepository: widget.profileRepository,
          profilePersistenceRepository: widget.profilePersistenceRepository,
          generatedPlanPersistenceRepository:
              widget.generatedPlanPersistenceRepository,
          notificationInboxRepository: widget.notificationInboxRepository,
          planProgress: _planProgress,
          adaptivePlanEstimate: _adaptivePlanEstimate,
          homeGuideAgent: widget.homeGuideAgent,
          enableForegroundGps: widget.enableForegroundGps,
          activeRunSessionCoordinator: widget.activeRunSessionCoordinator,
          initialRunOpenIntent: widget.initialRunOpenIntent,
          youProgressToday: widget.youProgressToday,
          enableLocalPlanNotifications:
              defaultTargetPlatform == TargetPlatform.iOS,
        ),
      ),
    );
  }

  Widget _buildPersonalProfileCollection(RuniacAuthUser currentUser) {
    return PersonalProfileCollectionScreen(
      uid: currentUser.uid,
      emailLabel: currentUser.email ?? 'Email unavailable',
      persistenceRepository: widget.profilePersistenceRepository,
      onComplete: (draft) {
        setState(() {
          _personalProfileDraft = draft;
        });
      },
    );
  }

  Future<void> _hydrateGeneratedPlanFromProfile(
    UserProfileReadModel profile,
  ) async {
    final currentUser = widget.authRepository.currentUser;
    if (currentUser != null) {
      final hydratedUid = currentUser.uid;
      BeginnerAdaptivePlanSnapshot? persistedPlan;
      try {
        persistedPlan = await widget.generatedPlanPersistenceRepository
            .loadGeneratedPlan(uid: hydratedUid);
      } catch (_) {
        persistedPlan = null;
      }
      final stillCurrentUser = widget.authRepository.currentUser;
      if (!mounted || stillCurrentUser?.uid != hydratedUid) {
        return;
      }
      if (persistedPlan != null) {
        _setActiveGeneratedPlan(persistedPlan, ownerUid: hydratedUid);
        return;
      }
    }

    final draft = profile.onboardingDraft;
    if (draft == null) {
      return;
    }
    final snapshot = const BeginnerAdaptivePlanGenerator()
        .generate(draft)
        .withStartsOnDate(generatedPlanDateLabel(DateTime.now()));
    _setActiveGeneratedPlan(snapshot, ownerUid: currentUser?.uid);
  }

  Future<bool> _completeOnboarding(LocalOnboardingDraft draft) async {
    final snapshot = const BeginnerAdaptivePlanGenerator().generate(draft);
    final currentUser = widget.authRepository.currentUser;
    if (currentUser != null) {
      final saved = await _saveOnboardingProfile(currentUser.uid, draft);
      if (!saved) {
        return false;
      }
      final savedPlan = await _saveGeneratedPlan(currentUser.uid, snapshot);
      if (!savedPlan) {
        return false;
      }
    }
    _setActiveGeneratedPlan(snapshot, ownerUid: currentUser?.uid);
    widget.onOnboardingCompleted?.call(draft);
    return true;
  }

  void _setActiveGeneratedPlan(
    BeginnerAdaptivePlanSnapshot snapshot, {
    required String? ownerUid,
  }) {
    _generatedPlanOwnerUid = ownerUid;
    if (!_generatedPlanStore.setActivePlan(snapshot)) {
      _generatedPlanOwnerUid = null;
      _planProgress = null;
      _planProgressLoadSerial += 1;
      _adaptivePlanEstimate = null;
      _adaptivePlanEstimateLoadSerial += 1;
      _generatedPlanStore.clear();
      return;
    }
    if (ownerUid == null) {
      _planProgress = null;
      _planProgressLoadSerial += 1;
      _adaptivePlanEstimate = null;
      _adaptivePlanEstimateLoadSerial += 1;
      return;
    }
    unawaited(_loadPlanProgress(ownerUid, snapshot.id));
    unawaited(_loadAdaptivePlanEstimate(ownerUid, snapshot.id));
  }

  Future<void> _loadPlanProgress(
    String ownerUid,
    String activeGeneratedPlanId,
  ) async {
    final loadSerial = _planProgressLoadSerial + 1;
    _planProgressLoadSerial = loadSerial;
    final progress = await widget.planProgressRepository.loadPlanProgress(
      uid: ownerUid,
      activeGeneratedPlanId: activeGeneratedPlanId,
    );
    if (!mounted ||
        loadSerial != _planProgressLoadSerial ||
        _generatedPlanOwnerUid != ownerUid ||
        _generatedPlanStore.activePlan?.id != activeGeneratedPlanId) {
      return;
    }
    setState(() {
      _planProgress = progress.completedScheduledWorkoutIds.isEmpty
          ? null
          : progress;
    });
  }

  Future<void> _loadAdaptivePlanEstimate(
    String ownerUid,
    String activeGeneratedPlanId,
  ) async {
    final loadSerial = _adaptivePlanEstimateLoadSerial + 1;
    _adaptivePlanEstimateLoadSerial = loadSerial;
    final estimate = await widget.adaptivePlanEstimateRepository
        .loadAdaptivePlanEstimate(uid: ownerUid);
    if (!mounted ||
        loadSerial != _adaptivePlanEstimateLoadSerial ||
        _generatedPlanOwnerUid != ownerUid ||
        _generatedPlanStore.activePlan?.id != activeGeneratedPlanId) {
      return;
    }
    setState(() {
      _adaptivePlanEstimate = estimate.isUsableForPlannedRun ? estimate : null;
    });
  }

  Future<bool> _saveOnboardingProfile(
    String uid,
    LocalOnboardingDraft draft,
  ) async {
    try {
      await widget.profilePersistenceRepository.saveOnboardingProfile(
        uid: uid,
        profile: _profileSnapshotFromDraft(draft),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _saveGeneratedPlan(
    String uid,
    BeginnerAdaptivePlanSnapshot snapshot,
  ) async {
    try {
      await widget.generatedPlanPersistenceRepository.saveGeneratedPlan(
        uid: uid,
        plan: snapshot,
        resetCreatedAt: true,
      );
      return true;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac app',
          context: ErrorDescription('saving generated onboarding plan'),
        ),
      );
      return false;
    }
  }

  UserProfileOnboardingSnapshot _profileSnapshotFromDraft(
    LocalOnboardingDraft draft,
  ) {
    final personalProfile = _personalProfileDraft;
    final displayName = personalProfile?.displayName ?? 'Runiac Runner';
    final fullName = personalProfile?.fullName ?? 'Runiac Runner';
    final nickname = personalProfile?.nickname ?? 'Runiac Runner';
    final avatarInitials = personalProfile?.avatarInitials ?? 'RR';
    final nicknameKey = personalProfile?.nicknameKey ?? 'runiac-runner';
    final dateOfBirthIso = personalProfile?.dateOfBirthIso ?? '2008-01-01';
    final ageYears = personalProfile?.ageYears ?? 18;
    final weightKg = personalProfile?.weightKg ?? 60;
    final locationLabel = personalProfile?.locationLabel ?? 'Not set yet';
    return UserProfileOnboardingSnapshot(
      displayName: displayName,
      fullName: fullName,
      nickname: nickname,
      avatarInitials: avatarInitials,
      nicknameKey: nicknameKey,
      dateOfBirthIso: dateOfBirthIso,
      ageYears: ageYears,
      weightKg: weightKg,
      locationLabel: locationLabel,
      fitnessLevel: draft.experience.value,
      goals: <String>[draft.goal.value],
      availability: <String, Object>{
        'weeklySessions': draft.availability.value,
        'preferredDays': draft.preferredDays
            .map((day) => day.value)
            .toList(growable: false),
        'preferredTime': draft.preferredTime.value,
        'sessionLengthMinutes': draft.sessionLength.value,
      },
      planCautiousness: draft.planStyle.value,
      healthSafetyReadiness: <String, Object>{
        'comfort': draft.healthComfort.value,
        'activitySymptoms': draft.activitySymptoms
            .map((symptom) => symptom.value)
            .toList(growable: false),
        'recentRunningConsistency': draft.recentRunningConsistency.value,
        'currentWeeklyRunFrequency': draft.currentWeeklyRunFrequency.value,
        'continuousRunCapacity': draft.continuousRunCapacity.value,
        'runningPlace': draft.runningPlace.value,
        'motivationStyle': draft.motivationStyle.value,
      },
    );
  }

  bool get _shouldShowOnboarding {
    if (!widget.showOnboarding) {
      return false;
    }
    if (!widget.showAuth) {
      return true;
    }
    return _authCompletion == RuniacAuthCompletion.signup &&
        _personalProfileDraft != null;
  }

  bool get _shouldShowPersonalProfile {
    return widget.showAuth &&
        widget.showOnboarding &&
        _authCompletion == RuniacAuthCompletion.signup &&
        _personalProfileDraft == null;
  }

  bool _shouldProbeSignedInProfileSetup(RuniacAuthUser? currentUser) {
    return widget.showAuth &&
        widget.showOnboarding &&
        currentUser != null &&
        _authCompletion != RuniacAuthCompletion.signup &&
        _personalProfileDraft == null;
  }
}

class _AuthStateErrorScreen extends StatelessWidget {
  const _AuthStateErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
