import 'package:flutter/material.dart';

import '../../account/presentation/account_profile_screen.dart';
import '../../account/domain/repositories/user_profile_persistence_repository.dart';
import '../../account/domain/repositories/user_profile_repository.dart';
import '../../auth/domain/runiac_auth_service.dart';
import '../../notifications/domain/repositories/notification_inbox_repository.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import '../../plan/domain/repositories/generated_plan_persistence_repository.dart';
import '../../plan/presentation/current_session_generated_plan.dart';
import '../../run/presentation/active_run_session_coordinator.dart';
import '../../run/presentation/models/planned_run_context.dart';
import '../../you/domain/models/user_progress_read_model.dart';
import '../../you/domain/repositories/user_progress_repository.dart';
import '../../you/presentation/adapters/generated_plan_you_display_adapter.dart';
import '../../you/presentation/data/weekly_workout_demo_snapshots.dart';
import '../../you/presentation/weekly_workout_detail_screen.dart';
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
    this.todayWorkoutDetailSnapshot,
    this.todayPlannedRunContext,
    this.generatedPlanProgress,
    this.currentDate,
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
  final WeeklyWorkoutDetailSnapshot? todayWorkoutDetailSnapshot;
  final PlannedRunContext? todayPlannedRunContext;

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
  String? _userProgressOwnerUid;
  UserProgressReadModel? _lastUserProgress;

  @override
  void initState() {
    super.initState();
    _setUserProgressFuture(refresh: false);
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProgressRepository != widget.userProgressRepository ||
        _currentOwnerUid != _userProgressOwnerUid) {
      _setUserProgressFuture(refresh: false);
    }
  }

  String? get _currentOwnerUid => widget.authRepository.currentUser?.uid;

  void _ensureUserProgressFutureForCurrentOwner() {
    if (_currentOwnerUid != _userProgressOwnerUid) {
      _setUserProgressFuture(refresh: false);
    }
  }

  void _setUserProgressFuture({required bool refresh}) {
    final ownerUid = _currentOwnerUid;
    if (ownerUid != _userProgressOwnerUid) {
      _lastUserProgress = null;
    }
    _userProgressOwnerUid = ownerUid;
    final source = refresh
        ? widget.userProgressRepository.refreshUserProgress()
        : widget.userProgressRepository.loadUserProgress();
    _userProgressFuture = _progressFutureForOwner(
      ownerUid: ownerUid,
      source: source,
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
    });
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

  HomeStageMapModel? _buildStageMapModel() {
    final plan = CurrentSessionGeneratedPlanScope.maybeOf(context)?.activePlan;
    if (plan == null || !isEligibleCurrentSessionGeneratedPlan(plan)) {
      return null;
    }
    final activeWeek = activeGeneratedPlanWeekFor(
      plan,
      currentDate: widget.currentDate,
    );
    final activeWeekNumber =
        activeWeek?.weekNumber ?? plan.weeks.first.weekNumber;
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
      backgroundSequence: backgroundSequence,
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureUserProgressFutureForCurrentOwner();
    final model = _buildStageMapModel();

    return StreamBuilder<int>(
      stream: widget.notificationInboxRepository.watchUnreadCount(),
      initialData: 0,
      builder: (context, unreadSnapshot) {
        return FutureBuilder<UserProgressReadModel>(
          future: _userProgressFuture,
          builder: (context, progressSnapshot) {
            final progress = progressSnapshot.data ?? _lastUserProgress;
            return HomeStageMap(
              model: model,
              streakCount: progress?.officialStreakCount ?? 0,
              unreadNotificationCount: unreadSnapshot.data ?? 0,
              levelBadgeLabel: progress?.levelBadgeLabel ?? 'Lv.0',
              levelProgressFraction: progress?.levelProgressFraction ?? 0,
              onNotifications: () => _openNotificationInbox(context),
              onProfile: () => _openAccountProfile(context),
              onTapTodayStage: () => _openTodayWorkout(context),
            );
          },
        );
      },
    );
  }
}
