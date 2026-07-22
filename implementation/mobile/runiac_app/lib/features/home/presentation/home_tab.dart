import 'package:flutter/material.dart';

import '../../profile/presentation/account_profile_screen.dart';
import '../../profile/domain/models/user_profile_read_model.dart';
import '../../profile/domain/repositories/user_profile_persistence_repository.dart';
import '../../profile/domain/repositories/user_profile_repository.dart';
import '../../auth/domain/runiac_auth_service.dart';
import '../../challenge/data/static_challenge_repository.dart';
import '../../challenge/domain/challenge_notification_routing.dart';
import '../../challenge/domain/models/challenge_enums.dart';
import '../../challenge/domain/models/challenge_history.dart';
import '../../challenge/domain/repositories/challenge_repository.dart';
import '../../challenge/presentation/challenge_badge_flight.dart';
import '../../challenge/presentation/challenge_ceremony_route.dart';
import '../../challenge/presentation/challenge_explore_screen.dart';
import '../../challenge/presentation/challenge_friend_picker_screen.dart';
import '../../challenge/presentation/challenge_history_screen.dart';
import '../../challenge/presentation/challenge_invitations_screen.dart';
import '../../challenge/presentation/challenge_progress_screen.dart';
import '../../challenge/presentation/challenge_result_presentation_controller.dart';
import '../../challenge/presentation/challenge_result_screen.dart';
import '../../challenge/presentation/home_active_challenge_display.dart';
import '../../notifications/domain/models/notification_inbox_item.dart';
import '../../plan/domain/plan_completion_seen_store.dart';
import '../../friends/data/static_friends_repository.dart';
import '../../friends/domain/repositories/friends_repository.dart';
import '../../friends/presentation/friends_screen.dart';
import '../../leaderboard/data/static_leaderboard_repository.dart';
import '../../leaderboard/domain/repositories/leaderboard_repository.dart';
import '../../notifications/domain/repositories/notification_inbox_repository.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import '../../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../../plan/domain/repositories/generated_plan_persistence_repository.dart';
import '../../plan/presentation/current_session_generated_plan.dart';
import '../../run/presentation/active_run_session_coordinator.dart';
import '../../run/presentation/models/planned_run_context.dart';
import '../../you/domain/models/user_progress_read_model.dart';
import '../../you/domain/repositories/user_progress_repository.dart';
import '../../you/presentation/current_session_activity_history.dart';
import '../../you/presentation/current_session_user_progress.dart';
import '../../you/presentation/adapters/generated_plan_you_display_adapter.dart';
import '../../you/presentation/data/weekly_workout_demo_snapshots.dart';
import '../../you/presentation/weekly_workout_detail_screen.dart';
import '../data/local_home_guide_consent_prompt_store.dart';
import '../domain/guide/home_guide_agent.dart';
import '../domain/guide/home_guide_consent.dart';
import '../domain/guide/rule_based_home_guide_agent.dart';
import 'guide/home_guide_consent_sheet.dart';
import 'plan_completion_ceremony.dart';
import 'stage_map/home_stage_background_sequence.dart';
import 'stage_map/home_stage_map.dart';
import 'stage_map/home_stage_map_model.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    required this.authRepository,
    required this.profileRepository,
    required this.profilePersistenceRepository,
    this.generatedPlanPersistenceRepository =
        const NoopGeneratedPlanPersistenceRepository(),
    this.notificationInboxRepository =
        const StaticNotificationInboxRepository(),
    this.userProgressRepository = const StaticUserProgressRepository(),
    this.leaderboardRepository = const StaticLeaderboardRepository(),
    this.friendsRepository = const StaticFriendsRepository(),
    this.challengeRepository = const StaticChallengeRepository(),
    this.challengeResultPresenter,
    this.todayWorkoutDetailSnapshot,
    this.todayPlannedRunContext,
    this.generatedPlanProgress,
    this.planCompletedAt,
    this.planCompletionSeenStore,
    this.currentDate,
    this.homeGuideAgent = const RuleBasedHomeGuideAgent(),
    this.homeGuideConsentRepository =
        const AlwaysGrantedHomeGuideConsentRepository(),
    this.consentPromptStore =
        const SharedPreferencesHomeGuideConsentPromptStore(),
    super.key,
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.onNotificationSettingsChanged,
  });

  final RuniacAuthRepository authRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final GeneratedPlanPersistenceRepository generatedPlanPersistenceRepository;
  final NotificationInboxRepository notificationInboxRepository;
  final UserProgressRepository userProgressRepository;
  final LeaderboardRepository leaderboardRepository;

  /// Auth-scoped Friends source reached from the Home Social menu. The
  /// composition root supplies the Firebase implementation in production;
  /// the static source remains a deterministic fallback for local previews.
  final FriendsRepository friendsRepository;

  /// Challenge distance-system source reached from the Home Social menu's
  /// Challenge item. Defaults to the deterministic static source for previews
  /// and tests; the composition root threads the Firebase-backed repository the
  /// same way [friendsRepository] is threaded.
  final ChallengeRepository challengeRepository;

  /// One-shot foreground Result presenter. When non-null (Firebase-active
  /// composition), a newly-settled challenge result is auto-presented once on
  /// load/resume. `null` (previews/tests) disables auto-presentation entirely.
  final ChallengeResultPresentationController? challengeResultPresenter;
  final WeeklyWorkoutDetailSnapshot? todayWorkoutDetailSnapshot;
  final PlannedRunContext? todayPlannedRunContext;

  /// Guide seam that explains today's plan in the stage-map speech bubble.
  /// Defaults to the offline rule-based agent; the composition root
  /// (`main.dart` via `RuniacFirebaseBootstrap`) wires a Cloud Function-backed
  /// agent when Firebase is active. Display-only: never computes or writes
  /// XP, level, rank, streak, or leaderboard values.
  final HomeGuideAgent homeGuideAgent;
  final HomeGuideConsentRepository homeGuideConsentRepository;

  /// Local, device-only "consent sheet already shown" flag. Decides whether the
  /// one-time data-use consent sheet auto-presents on first Home entry. Never
  /// grants consent or influences any backend-owned value.
  final HomeGuideConsentPromptStore consentPromptStore;

  /// Backend-owned generated-plan progress (completed scheduled-workout ids),
  /// forwarded from the shell. Display-only.
  final GeneratedPlanProgressDisplay? generatedPlanProgress;

  /// Backend-recorded completion time of the active generated plan, forwarded
  /// from the shell. Computed and written entirely by the `completeRun` Cloud
  /// Function into `planProgress/{uid}`; the client only reads it to decide
  /// whether to celebrate. `null` while the plan is still in progress.
  final DateTime? planCompletedAt;

  /// Local one-shot marker for the plan-completion ceremony. When non-null
  /// (Firebase-active composition), a newly-recorded completion is celebrated
  /// exactly once. `null` (previews/tests) disables the celebration entirely,
  /// matching how [challengeResultPresenter] gates the Result presentation.
  final PlanCompletionSeenStore? planCompletionSeenStore;

  /// Injected "today" for deterministic active-week resolution in tests.
  final DateTime? currentDate;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final VoidCallback? onNotificationSettingsChanged;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  late Future<UserProgressReadModel> _userProgressFuture;
  late Future<UserProfileReadModel?> _userProfileFuture;
  var _userProgressFutureInitialized = false;
  String? _userProgressOwnerUid;
  String? _userProfileOwnerUid;
  UserProgressReadModel? _lastUserProgress;
  UserProfileReadModel? _lastUserProfile;
  int? _observedUserProgressRefreshRevision;

  /// The caller's live ACTIVE/SETTLING challenge projected for the Home control,
  /// or null when no control should render. Loaded one-shot on init and
  /// refreshed on return from Challenge navigation.
  HomeActiveChallengeDisplay? _activeChallengeDisplay;
  String? _activeChallengeId;

  /// Guards the one-shot Result presentation against re-entrancy (a resume
  /// while a result route is already open must not stack a second one).
  bool _presentingResult = false;

  /// Guards the one-shot plan-completion ceremony against re-entrancy (a
  /// resume or a widget update while the overlay is already open must not
  /// stack a second one).
  bool _celebratingPlanCompletion = false;
  HomeGuideConsentStatus _homeGuideConsentStatus =
      HomeGuideConsentStatus.unknown;
  String? _homeGuideConsentOwnerUid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserProfileFuture(refresh: false);
    _loadHomeGuideConsent();
    _loadActiveChallenge();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePresentUnseenResult();
      _maybeCelebratePlanCompletion();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadActiveChallenge();
      _maybePresentUnseenResult();
      _maybeCelebratePlanCompletion();
    }
  }

  /// Presents the newest unseen terminal result exactly once. The presenter
  /// itself is idempotent (it advances a local seen-marker), so a resume/replay
  /// yields nothing to present.
  Future<void> _maybePresentUnseenResult() async {
    final presenter = widget.challengeResultPresenter;
    if (presenter == null || !mounted || _presentingResult) {
      return;
    }
    final ChallengeResult? result = await presenter.takeUnseenResult();
    if (result == null || !mounted) {
      return;
    }
    await _presentResult(result);
  }

  /// Celebrates a backend-recorded plan completion exactly once. The seen
  /// marker is advanced *before* the ceremony opens so a crash or a force-quit
  /// mid-animation cannot leave the celebration re-firing on every launch.
  Future<void> _maybeCelebratePlanCompletion() async {
    final seenStore = widget.planCompletionSeenStore;
    final completedAt = widget.planCompletedAt;
    if (seenStore == null ||
        completedAt == null ||
        !mounted ||
        _celebratingPlanCompletion) {
      return;
    }

    final completedAtMs = completedAt.millisecondsSinceEpoch;
    final lastSeenMs = await seenStore.lastSeenPlanCompletedAtMs();
    if (lastSeenMs != null && completedAtMs <= lastSeenMs) {
      return;
    }
    if (!mounted || _celebratingPlanCompletion) {
      return;
    }

    _celebratingPlanCompletion = true;
    try {
      await seenStore.recordSeenPlanCompletion(completedAtMs);
      if (!mounted) {
        return;
      }
      await showPlanCompletionCeremony(context);
    } finally {
      _celebratingPlanCompletion = false;
    }
  }

  Future<void> _presentResult(ChallengeResult result) async {
    if (_presentingResult || !mounted) {
      return;
    }
    _presentingResult = true;
    try {
      await Navigator.of(context).push(
        challengeCeremonyRoute<void>(
          fullscreenDialog: true,
          builder: (context) => ChallengeResultScreen(
            result: result,
            onClose: () => Navigator.of(context).pop(),
            onViewBadgeCollection: result.earnedBadge
                ? () =>
                      _openAccountProfileWithBadgeFlight(context, result.tierId)
                : null,
          ),
        ),
      );
    } finally {
      _presentingResult = false;
    }
    if (mounted) {
      await _loadActiveChallenge();
    }
  }

  /// One-shot read of the caller's active challenge. Failures are non-fatal: the
  /// control simply keeps its current (or absent) state rather than surfacing an
  /// error, since it is a secondary Home affordance.
  Future<void> _loadActiveChallenge() async {
    try {
      final active = await widget.challengeRepository.activeChallenge();
      if (!mounted) {
        return;
      }
      final display = HomeActiveChallengeDisplay.fromActiveChallenge(active);
      setState(() {
        _activeChallengeDisplay = display;
        _activeChallengeId = display == null ? null : active!.challengeId;
      });
    } catch (_) {
      // Leave the existing control state untouched on a transient failure.
    }
  }

  /// Loads the caller's reciprocal friends for the challenge invite picker.
  /// Failures (including no signed-in user) are non-fatal: the picker simply
  /// shows its empty state rather than surfacing an error.
  Future<List<ChallengeInvitableFriend>> _loadInvitableFriends() async {
    final ownerUid = _currentOwnerUid;
    if (ownerUid == null) {
      return const <ChallengeInvitableFriend>[];
    }
    try {
      final overview = await widget.friendsRepository.loadFriendsOverview(
        ownerUid: ownerUid,
      );
      return overview.friends
          .map(
            (friend) => ChallengeInvitableFriend(
              uid: friend.userId,
              displayName: friend.displayName,
              initials: friend.avatarInitials,
              levelLabel: friend.levelLabel,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <ChallengeInvitableFriend>[];
    }
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (CurrentSessionUserProgressScope.maybeRead(context) == null &&
        (oldWidget.userProgressRepository != widget.userProgressRepository ||
            !_userProgressFutureInitialized ||
            _currentOwnerUid != _userProgressOwnerUid)) {
      _setUserProgressFuture(refresh: false);
    }
    if (oldWidget.profileRepository != widget.profileRepository ||
        _currentOwnerUid != _userProfileOwnerUid) {
      _setUserProfileFuture(refresh: false);
    }
    if (oldWidget.homeGuideConsentRepository !=
            widget.homeGuideConsentRepository ||
        _currentOwnerUid != _homeGuideConsentOwnerUid) {
      _loadHomeGuideConsent();
    }
    // Plan progress is loaded asynchronously, so the completion usually
    // arrives after the first frame rather than being present in `initState`.
    if (oldWidget.planCompletedAt != widget.planCompletedAt) {
      _maybeCelebratePlanCompletion();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncLatestUserProgressRefresh();
    if (CurrentSessionUserProgressScope.maybeRead(context) == null &&
        !_userProgressFutureInitialized) {
      _setUserProgressFuture(refresh: false);
    }
  }

  String? get _currentOwnerUid => widget.authRepository.currentUser?.uid;

  Future<void> _loadHomeGuideConsent() async {
    final ownerUid = _currentOwnerUid;
    _homeGuideConsentOwnerUid = ownerUid;
    _homeGuideConsentStatus = HomeGuideConsentStatus.unknown;
    final status = await widget.homeGuideConsentRepository.read();
    if (!mounted || ownerUid != _currentOwnerUid) {
      return;
    }
    setState(() {
      _homeGuideConsentStatus = status;
    });
    if (status != HomeGuideConsentStatus.granted) {
      await _maybePromptHomeGuideConsent(ownerUid);
    }
  }

  /// Presents the one-time consent sheet on the first Home entry for [ownerUid]
  /// when consent has not been granted. The decision is written server-side;
  /// declining hides the guide (consent can be revisited in Account →
  /// Privacy & Safety).
  Future<void> _maybePromptHomeGuideConsent(String? ownerUid) async {
    if (await widget.consentPromptStore.hasPrompted(uid: ownerUid)) {
      return;
    }
    if (!mounted || ownerUid != _currentOwnerUid) {
      return;
    }
    final granted = await showHomeGuideConsentSheet(context);
    if (granted == null) {
      // No explicit decision (defensive): re-ask on the next Home entry.
      return;
    }
    await widget.consentPromptStore.markPrompted(uid: ownerUid);
    if (!mounted || ownerUid != _currentOwnerUid) {
      return;
    }
    await _applyHomeGuideConsentDecision(granted);
  }

  Future<void> _applyHomeGuideConsentDecision(bool granted) async {
    try {
      final status = await widget.homeGuideConsentRepository.update(
        granted: granted,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _homeGuideConsentStatus = status;
      });
    } catch (_) {
      if (!mounted || !context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update guide data use. Please try again.'),
        ),
      );
    }
  }

  void _ensureUserProgressFutureForCurrentOwner() {
    if (!_userProgressFutureInitialized ||
        _currentOwnerUid != _userProgressOwnerUid) {
      _setUserProgressFuture(refresh: false);
    }
  }

  void _ensureUserProfileFutureForCurrentOwner() {
    if (_currentOwnerUid != _userProfileOwnerUid) {
      _setUserProfileFuture(refresh: false);
    }
  }

  void _syncLatestUserProgressRefresh() {
    final activityHistoryStore = CurrentSessionActivityHistoryScope.maybeOf(
      context,
    );
    final revision = activityHistoryStore?.userProgressRefreshRevision;
    if (revision == null || revision == _observedUserProgressRefreshRevision) {
      return;
    }
    _observedUserProgressRefreshRevision = revision;
    final latestProgress = activityHistoryStore?.latestUserProgressRefresh;
    if (latestProgress == null || latestProgress.userId != _currentOwnerUid) {
      return;
    }
    _lastUserProgress = latestProgress;
  }

  void _setUserProgressFuture({required bool refresh}) {
    final ownerUid = _currentOwnerUid;
    if (ownerUid != _userProgressOwnerUid) {
      _lastUserProgress = null;
    }
    _userProgressOwnerUid = ownerUid;
    _userProgressFutureInitialized = true;
    final source = refresh
        ? widget.userProgressRepository.refreshUserProgress()
        : widget.userProgressRepository.loadUserProgress();
    _userProgressFuture = _progressFutureForOwner(
      ownerUid: ownerUid,
      source: source,
      keepLastOnError: refresh,
    );
  }

  void _setUserProfileFuture({required bool refresh}) {
    final ownerUid = _currentOwnerUid;
    if (ownerUid != _userProfileOwnerUid) {
      _lastUserProfile = null;
    }
    _userProfileOwnerUid = ownerUid;
    _userProfileFuture = _profileFutureForOwner(
      ownerUid: ownerUid,
      keepLastOnError: refresh,
    );
  }

  Future<UserProgressReadModel> _progressFutureForOwner({
    required String? ownerUid,
    required Future<UserProgressReadModel> source,
    required bool keepLastOnError,
  }) async {
    try {
      final progress = await source;
      if (_userProgressOwnerUid == ownerUid) {
        _lastUserProgress = progress;
      }
      return progress;
    } catch (_) {
      final fallback = _lastUserProgress;
      if (keepLastOnError &&
          fallback != null &&
          _userProgressOwnerUid == ownerUid) {
        return fallback;
      }
      rethrow;
    }
  }

  Future<UserProfileReadModel?> _profileFutureForOwner({
    required String? ownerUid,
    required bool keepLastOnError,
  }) async {
    try {
      final profile = await widget.profileRepository.loadUserProfile();
      if (_userProfileOwnerUid == ownerUid) {
        _lastUserProfile = profile;
      }
      return profile;
    } catch (_) {
      final fallback = _lastUserProfile;
      if (keepLastOnError &&
          fallback != null &&
          _userProfileOwnerUid == ownerUid) {
        return fallback;
      }
      return null;
    }
  }

  void _openTodayWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return WeeklyWorkoutDetailScreen(
            onBack: () => Navigator.of(context).pop(),
            snapshot:
                widget.todayWorkoutDetailSnapshot ??
                weeklyWorkoutDetailSnapshot,
            showEditScheduleAction: false,
            enableForegroundGps: widget.enableForegroundGps,
            activeRunSessionCoordinator: widget.activeRunSessionCoordinator,
          );
        },
      ),
    );
  }

  AccountProfileScreen _accountProfileScreen(BuildContext routeContext) {
    return AccountProfileScreen(
      authRepository: widget.authRepository,
      profileRepository: widget.profileRepository,
      profilePersistenceRepository: widget.profilePersistenceRepository,
      generatedPlanPersistenceRepository:
          widget.generatedPlanPersistenceRepository,
      userProgressRepository: widget.userProgressRepository,
      leaderboardRepository: widget.leaderboardRepository,
      challengeRepository: widget.challengeRepository,
      onNotificationSettingsChanged: widget.onNotificationSettingsChanged,
      homeGuideConsentRepository: widget.homeGuideConsentRepository,
      onBack: () => Navigator.of(routeContext).pop(),
    );
  }

  void _refreshAfterAccountProfile() {
    if (!mounted) {
      return;
    }
    setState(() {
      _setUserProgressFuture(refresh: true);
      _setUserProfileFuture(refresh: true);
    });
    // Consent may have changed in Account → Privacy & Safety; re-read it so the
    // guide reappears or hides to match. Does not re-prompt (the sheet is
    // one-time and its flag is already set once shown).
    _loadHomeGuideConsent();
  }

  Future<void> _openAccountProfile(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _accountProfileScreen(context),
      ),
    );
    _refreshAfterAccountProfile();
  }

  /// Opens the Account badge collection with the "badge shrinks into the
  /// Account page" flourish: the earned badge flies from the result screen into
  /// the collection while the Account page fades/scales in. Replaces the result
  /// route so backing out of Account returns Home. Falls back to a plain open
  /// under reduced motion or when no root overlay is available.
  Future<void> _openAccountProfileWithBadgeFlight(
    BuildContext resultContext,
    ChallengeTierId tierId,
  ) async {
    final mediaQuery = MediaQuery.maybeOf(resultContext);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;
    final overlay = Navigator.of(resultContext, rootNavigator: true).overlay;

    if (reduceMotion || mediaQuery == null || overlay == null) {
      Navigator.of(resultContext).pop();
      await _openAccountProfile(resultContext);
      return;
    }

    final Size size = mediaQuery.size;
    const double sourceSize = 176;
    const double targetSize = 48;
    final Rect source = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.4),
      width: sourceSize,
      height: sourceSize,
    );
    final Rect target = Rect.fromCenter(
      center: Offset(size.width / 2, mediaQuery.padding.top + 150),
      width: targetSize,
      height: targetSize,
    );

    flyChallengeBadgeToAccount(
      overlay: overlay,
      tierId: tierId,
      source: source,
      target: target,
    );

    await Navigator.of(resultContext).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 460),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (routeContext, _, _) =>
            _accountProfileScreen(routeContext),
        transitionsBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    _refreshAfterAccountProfile();
  }

  void _openFriends(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return FriendsScreen(
            authRepository: widget.authRepository,
            repository: widget.friendsRepository,
            onBack: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }

  Future<void> _openChallenge(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ChallengeExploreScreen(
            repository: widget.challengeRepository,
            onBack: () => Navigator.of(context).pop(),
            onOpenHistory: () => _openChallengeHistory(context),
            invitableFriendsLoader: _loadInvitableFriends,
          );
        },
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadActiveChallenge();
  }

  void _openChallengeHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ChallengeHistoryScreen(
            repository: widget.challengeRepository,
            onBack: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }

  Future<void> _openChallengeProgress(BuildContext context) async {
    final challengeId = _activeChallengeId;
    if (challengeId == null) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ChallengeProgressScreen(
            challengeId: challengeId,
            repository: widget.challengeRepository,
            onBack: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadActiveChallenge();
  }

  void _openNotificationInbox(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return NotificationInboxPage(
            repository: widget.notificationInboxRepository,
            onOpenItem: (item) => _openChallengeNotification(context, item),
          );
        },
      ),
    );
  }

  /// Routes a tapped challenge inbox item to its destination. Non-challenge
  /// items resolve to `null` and keep their mark-read-only behaviour.
  Future<void> _openChallengeNotification(
    BuildContext context,
    NotificationInboxItem item,
  ) async {
    final target = challengeNotificationTargetFor(item.data);
    if (target == null) {
      return;
    }
    switch (target.destination) {
      case ChallengeNotificationDestination.invitations:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ChallengeInvitationsScreen(
              repository: widget.challengeRepository,
              slotHeld: _activeChallengeId != null,
              onBack: () => Navigator.of(context).pop(),
              invitableFriendsLoader: _loadInvitableFriends,
            ),
          ),
        );
      case ChallengeNotificationDestination.progress:
        if (target.challengeId.isEmpty) {
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ChallengeProgressScreen(
              challengeId: target.challengeId,
              repository: widget.challengeRepository,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
        );
      case ChallengeNotificationDestination.result:
        await _openResultForChallenge(context, target.challengeId);
    }
    if (mounted) {
      await _loadActiveChallenge();
    }
  }

  /// Opens the personalized result for [challengeId] by fetching the caller's
  /// history and reopening the full result surface for the matching entry.
  Future<void> _openResultForChallenge(
    BuildContext context,
    String challengeId,
  ) async {
    if (challengeId.isEmpty) {
      return;
    }
    ChallengeHistoryEntry? entry;
    try {
      final history = await widget.challengeRepository.history();
      for (final candidate in history) {
        if (candidate.challengeId == challengeId) {
          entry = candidate;
          break;
        }
      }
    } catch (_) {
      entry = null;
    }
    if (entry == null || !mounted) {
      return;
    }
    await _presentResult(entry.toResult());
  }

  HomeStageMapModel? _buildStageMapModel(BeginnerAdaptivePlanSnapshot? plan) {
    if (plan == null || !isEligibleCurrentSessionGeneratedPlan(plan)) {
      return null;
    }
    final activeWeek = activeGeneratedPlanWeekFor(
      plan,
      currentDate: widget.currentDate,
    );
    final activeWeekNumber =
        activeWeek?.weekNumber ?? plan.weeks.first.weekNumber;
    final activeWeekdayIndex = activeGeneratedPlanWeekdayFor(
      plan,
      currentDate: widget.currentDate,
    );
    final completedIds =
        widget.generatedPlanProgress?.completedScheduledWorkoutIds ??
        const <String>{};
    final backgroundSequence = homeStageBackgroundSequence(
      planId: plan.id,
      weekCount: plan.weeks.length,
    );
    return buildHomeStageMapModel(
      plan: plan,
      completedScheduledWorkoutIds: completedIds,
      activeWeekNumber: activeWeekNumber,
      currentWeekdayIndex: activeWeekdayIndex,
      backgroundSequence: backgroundSequence,
    );
  }

  /// Matches today's stage stone back to its full [BeginnerAdaptiveWorkout],
  /// using the same scheduled-workout id scheme the stage map was built
  /// with, so the guide request carries the rich display-only workout copy
  /// (description/steps/supportive note) rather than just the stone's title.
  BeginnerAdaptiveWorkout? _findTodayWorkout(
    BeginnerAdaptivePlanSnapshot plan,
    HomeStageMapModel model,
  ) {
    final weekIndex = model.currentWeekIndex;
    final dayIndex = model.todayDayIndex;
    if (weekIndex == null ||
        dayIndex == null ||
        weekIndex >= plan.weeks.length ||
        weekIndex >= model.sections.length) {
      return null;
    }
    final stones = model.sections[weekIndex].stones;
    if (dayIndex >= stones.length) {
      return null;
    }
    final scheduledWorkoutId = stones[dayIndex].scheduledWorkoutId;
    if (scheduledWorkoutId == null) {
      return null;
    }
    final week = plan.weeks[weekIndex];
    for (final workout in week.workouts) {
      if (!isGeneratedPlanSession(workout)) {
        continue;
      }
      final id = homeStageScheduledWorkoutId(
        weekNumber: week.weekNumber,
        dayLabel: workout.dayLabel,
        title: workout.title,
      );
      if (id == scheduledWorkoutId) {
        return workout;
      }
    }
    return null;
  }

  HomeGuideRequest? _buildGuideRequest(
    BeginnerAdaptivePlanSnapshot? plan,
    HomeStageMapModel? model,
  ) {
    if (plan == null || model == null || model.currentWeekIndex == null) {
      return null;
    }
    final weekIndex = model.currentWeekIndex!;
    if (weekIndex >= plan.weeks.length || weekIndex >= model.sections.length) {
      return null;
    }
    final week = plan.weeks[weekIndex];

    // On a scheduled rest day the today stone is a rest stone (no run session
    // claims it), so it carries no workout to summarise. Compose a rest-day
    // request instead of suppressing the guide entirely.
    final dayIndex = model.todayDayIndex;
    final stones = model.sections[weekIndex].stones;
    if (dayIndex != null &&
        dayIndex < stones.length &&
        !stones[dayIndex].isRun) {
      return HomeGuideRequest(
        planTitle: plan.title,
        weekNumber: week.weekNumber,
        weekFocus: week.focus,
        dayLabel: stones[dayIndex].dayLabel ?? '',
        workoutTitle: '',
        durationMinutes: 0,
        intensityLabel: '',
        description: '',
        isRestDay: true,
      );
    }

    final workout = _findTodayWorkout(plan, model);
    if (workout == null) {
      return null;
    }
    return HomeGuideRequest(
      planTitle: plan.title,
      weekNumber: week.weekNumber,
      weekFocus: week.focus,
      dayLabel: workout.dayLabel,
      workoutTitle: workout.title,
      durationMinutes: workout.durationMinutes,
      intensityLabel: _intensityLabel(workout.intensity),
      description: workout.description,
      steps: workout.steps,
      supportiveNote: workout.supportiveNote,
    );
  }

  String _intensityLabel(BeginnerPlanIntensity intensity) {
    return switch (intensity) {
      BeginnerPlanIntensity.veryGentle => 'Very gentle',
      BeginnerPlanIntensity.gentle => 'Gentle',
      BeginnerPlanIntensity.balanced => 'Balanced',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scopedSessionUserProgress = CurrentSessionUserProgressScope.maybeOf(
      context,
    );
    final sessionUserProgress =
        scopedSessionUserProgress?.snapshot.ownerUid == null
        ? null
        : scopedSessionUserProgress;
    if (sessionUserProgress == null) {
      _ensureUserProgressFutureForCurrentOwner();
    }
    _ensureUserProfileFutureForCurrentOwner();
    final plan = CurrentSessionGeneratedPlanScope.maybeOf(context)?.activePlan;
    final model = _buildStageMapModel(plan);
    final guideRequest = _buildGuideRequest(plan, model);

    return FutureBuilder<UserProfileReadModel?>(
      future: _userProfileFuture,
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data ?? _lastUserProfile;
        return StreamBuilder<int>(
          stream: widget.notificationInboxRepository.watchUnreadCount(),
          initialData: 0,
          builder: (context, unreadSnapshot) {
            if (sessionUserProgress != null) {
              final snapshot = sessionUserProgress.snapshot;
              final progress = snapshot.progress ?? _lastUserProgress;
              if (snapshot.progress != null) {
                _lastUserProgress = snapshot.progress;
              }
              return _buildHomeStageMap(
                context: context,
                model: model,
                guideRequest: guideRequest,
                profile: profile,
                profileLoading: profile == null,
                progress: progress,
                unreadNotificationCount: unreadSnapshot.data ?? 0,
              );
            }
            return FutureBuilder<UserProgressReadModel>(
              future: _userProgressFuture,
              builder: (context, progressSnapshot) {
                final progress = _lastUserProgress ?? progressSnapshot.data;
                return _buildHomeStageMap(
                  context: context,
                  model: model,
                  guideRequest: guideRequest,
                  profile: profile,
                  profileLoading: profile == null,
                  progress: progress,
                  unreadNotificationCount: unreadSnapshot.data ?? 0,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHomeStageMap({
    required BuildContext context,
    required HomeStageMapModel? model,
    required HomeGuideRequest? guideRequest,
    required UserProfileReadModel? profile,
    required bool profileLoading,
    required UserProgressReadModel? progress,
    required int unreadNotificationCount,
  }) {
    return HomeStageMap(
      model: model,
      streakCount: progress?.officialStreakCount ?? 0,
      unreadNotificationCount: unreadNotificationCount,
      profileInitials: _homeProfileInitials(profile),
      levelBadgeLabel: progress?.levelBadgeLabel ?? 'Lv.0',
      levelProgressFraction: progress?.levelProgressFraction ?? 0,
      progressLoading: progress == null,
      profileLoading: profileLoading,
      onNotifications: () => _openNotificationInbox(context),
      onProfile: () => _openAccountProfile(context),
      onOpenFriends: () => _openFriends(context),
      onOpenChallenge: () => _openChallenge(context),
      activeChallenge: _activeChallengeDisplay,
      onOpenChallengeProgress: () => _openChallengeProgress(context),
      onTapTodayStage: () => _openTodayWorkout(context),
      guideAgent: widget.homeGuideAgent,
      guideRequest: guideRequest,
      guideConsentStatus: _homeGuideConsentStatus,
    );
  }
}

String _homeProfileInitials(UserProfileReadModel? profile) {
  final initials = profile?.avatarInitials.trim();
  if (initials == null || initials.isEmpty) {
    return 'R';
  }
  return initials;
}
