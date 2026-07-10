import 'package:flutter/material.dart';

import '../../account/presentation/account_profile_screen.dart';
import '../../account/domain/repositories/user_profile_persistence_repository.dart';
import '../../account/domain/repositories/user_profile_repository.dart';
import '../../auth/domain/runiac_auth_service.dart';
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
    } else if (!_isSameDate(oldWidget.currentDate, widget.currentDate)) {
      _setUserProgressFuture(refresh: true);
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
      currentWeekdayIndex: widget.currentDate?.weekday,
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
    _ensureUserProgressFutureForCurrentOwner();
    final plan = CurrentSessionGeneratedPlanScope.maybeOf(context)?.activePlan;
    final model = _buildStageMapModel(plan);
    final guideRequest = _buildGuideRequest(plan, model);

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
              guideAgent: widget.homeGuideAgent,
              guideRequest: guideRequest,
            );
          },
        );
      },
    );
  }
}

bool _isSameDate(DateTime? left, DateTime? right) {
  return left?.year == right?.year &&
      left?.month == right?.month &&
      left?.day == right?.day;
}
