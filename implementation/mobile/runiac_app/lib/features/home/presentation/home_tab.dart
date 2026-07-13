import 'package:flutter/material.dart';

import '../../account/presentation/account_profile_screen.dart';
import '../../account/domain/models/user_profile_read_model.dart';
import '../../account/domain/repositories/user_profile_persistence_repository.dart';
import '../../account/domain/repositories/user_profile_repository.dart';
import '../../auth/domain/runiac_auth_service.dart';
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
import '../domain/guide/home_guide_agent.dart';
import '../domain/guide/rule_based_home_guide_agent.dart';
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
    this.todayWorkoutDetailSnapshot,
    this.todayPlannedRunContext,
    this.generatedPlanProgress,
    this.currentDate,
    this.homeGuideAgent = const RuleBasedHomeGuideAgent(),
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
  final WeeklyWorkoutDetailSnapshot? todayWorkoutDetailSnapshot;
  final PlannedRunContext? todayPlannedRunContext;

  /// Guide seam that explains today's plan in the stage-map speech bubble.
  /// Defaults to the offline rule-based agent; the composition root
  /// (`main.dart` via `RuniacFirebaseBootstrap`) wires a Cloud Function-backed
  /// agent when Firebase is active. Display-only: never computes or writes
  /// XP, level, rank, streak, or leaderboard values.
  final HomeGuideAgent homeGuideAgent;

  /// Backend-owned generated-plan progress (completed scheduled-workout ids),
  /// forwarded from the shell. Display-only.
  final GeneratedPlanProgressDisplay? generatedPlanProgress;

  /// Injected "today" for deterministic active-week resolution in tests.
  final DateTime? currentDate;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final VoidCallback? onNotificationSettingsChanged;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<UserProgressReadModel> _userProgressFuture;
  late Future<UserProfileReadModel?> _userProfileFuture;
  var _userProgressFutureInitialized = false;
  String? _userProgressOwnerUid;
  String? _userProfileOwnerUid;
  UserProgressReadModel? _lastUserProgress;
  UserProfileReadModel? _lastUserProfile;
  int? _observedUserProgressRefreshRevision;

  @override
  void initState() {
    super.initState();
    _setUserProfileFuture(refresh: false);
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

  Future<void> _openAccountProfile(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return AccountProfileScreen(
            authRepository: widget.authRepository,
            profileRepository: widget.profileRepository,
            profilePersistenceRepository: widget.profilePersistenceRepository,
            generatedPlanPersistenceRepository:
                widget.generatedPlanPersistenceRepository,
            userProgressRepository: widget.userProgressRepository,
            leaderboardRepository: widget.leaderboardRepository,
            onNotificationSettingsChanged: widget.onNotificationSettingsChanged,
            onBack: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _setUserProgressFuture(refresh: true);
      _setUserProfileFuture(refresh: true);
    });
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

  void _openNotificationInbox(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return NotificationInboxPage(
            repository: widget.notificationInboxRepository,
          );
        },
      ),
    );
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
    final activeDayIndex = activeGeneratedPlanDayIndexFor(
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
      currentWeekdayIndex: activeDayIndex == null
          ? null
          : DateTime.monday + activeDayIndex,
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
    if (weekIndex >= plan.weeks.length) {
      return null;
    }
    final workout = _findTodayWorkout(plan, model);
    if (workout == null) {
      return null;
    }
    final week = plan.weeks[weekIndex];
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
      onTapTodayStage: () => _openTodayWorkout(context),
      guideAgent: widget.homeGuideAgent,
      guideRequest: guideRequest,
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
