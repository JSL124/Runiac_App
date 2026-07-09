import 'package:flutter/material.dart';

import '../../core/theme/runiac_colors.dart';
import '../account/domain/repositories/user_profile_repository.dart';
import '../account/domain/repositories/user_profile_persistence_repository.dart';
import '../auth/domain/runiac_auth_service.dart';
import '../home/presentation/home_tab.dart';
import '../leaderboard/presentation/leaderboard_tab.dart';
import '../maps/presentation/maps_tab.dart';
import '../notifications/data/method_channel_plan_notification_scheduler.dart';
import '../notifications/data/shared_preferences_notification_center_settings_repository.dart';
import '../notifications/domain/models/plan_notification_schedule.dart';
import '../notifications/domain/repositories/notification_inbox_repository.dart';
import '../notifications/domain/services/plan_notification_sync_service.dart';
import '../plan/domain/models/adaptive_plan_estimate_read_model.dart';
import '../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../plan/domain/repositories/generated_plan_persistence_repository.dart';
import '../plan/domain/models/plan_progress_read_model.dart';
import '../plan/presentation/current_session_generated_plan.dart';
import '../run/domain/models/run_location_sample.dart';
import '../run/presentation/active_run_session_coordinator.dart';
import '../run/presentation/models/planned_run_context.dart';
import '../run/presentation/run_launch_screen.dart';
import '../run/presentation/run_open_intent.dart';
import '../you/data/static_activity_history_repository.dart';
import '../you/domain/models/user_progress_read_model.dart';
import '../you/domain/repositories/activity_history_repository.dart';
import '../you/domain/repositories/user_progress_repository.dart';
import '../you/presentation/adapters/generated_plan_you_display_adapter.dart';
import '../you/presentation/current_session_activity_history.dart';
import '../you/presentation/you_tab.dart';

class RuniacShell extends StatefulWidget {
  const RuniacShell({
    required this.authRepository,
    this.activityHistoryRepository = const StaticActivityHistoryRepository(),
    this.userProgressRepository = const StaticUserProgressRepository(),
    required this.profileRepository,
    required this.profilePersistenceRepository,
    this.generatedPlanPersistenceRepository =
        const NoopGeneratedPlanPersistenceRepository(),
    this.notificationInboxRepository =
        const StaticNotificationInboxRepository(),
    this.planProgress,
    this.adaptivePlanEstimate,
    super.key,
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.initialRunOpenIntent,
    this.youProgressToday,
    this.enableLocalPlanNotifications = false,
  });

  final RuniacAuthRepository authRepository;
  final ActivityHistoryRepository activityHistoryRepository;
  final UserProgressRepository userProgressRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final GeneratedPlanPersistenceRepository generatedPlanPersistenceRepository;
  final NotificationInboxRepository notificationInboxRepository;
  final PlanProgressReadModel? planProgress;
  final AdaptivePlanEstimateReadModel? adaptivePlanEstimate;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final RunOpenIntent? initialRunOpenIntent;
  final DateTime? youProgressToday;
  final bool enableLocalPlanNotifications;

  @override
  State<RuniacShell> createState() => _RuniacShellState();
}

class _RuniacShellState extends State<RuniacShell> with WidgetsBindingObserver {
  static const _localNotificationSmokeTestEnabled = bool.fromEnvironment(
    'RUNIAC_LOCAL_NOTIFICATION_SMOKE_TEST',
  );
  static const _localNotificationSmokeTestDelaySeconds = int.fromEnvironment(
    'RUNIAC_LOCAL_NOTIFICATION_SMOKE_TEST_DELAY_SECONDS',
    defaultValue: 60,
  );
  static const _localNotificationDebugLogs = bool.fromEnvironment(
    'RUNIAC_LOCAL_NOTIFICATION_DEBUG_LOGS',
  );

  int _selectedIndex = 0;
  late final bool _ownsActiveRunSessionCoordinator =
      widget.activeRunSessionCoordinator == null;
  late final ActiveRunSessionCoordinator _activeRunSessionCoordinator =
      widget.activeRunSessionCoordinator ?? ActiveRunSessionCoordinator();
  bool _handledInitialRunOpenIntent = false;
  bool _runLaunchRouteOpen = false;
  String? _lastPlanNotificationSyncSignature;
  var _planNotificationSyncInFlight = false;
  var _pendingPlanNotificationSync = false;
  var _localNotificationSmokeTestScheduled = false;
  BeginnerAdaptivePlanSnapshot? _pendingPlanNotificationPlan;
  GeneratedPlanProgressDisplay? _pendingPlanNotificationProgress;
  late final PlanNotificationSyncService _planNotificationSyncService =
      PlanNotificationSyncService(
        settingsRepository:
            const SharedPreferencesNotificationCenterSettingsRepository(),
        scheduler: const MethodChannelPlanNotificationScheduler(),
        inboxRepository: widget.notificationInboxRepository,
        debugLog: _localNotificationDebugLogs
            ? _logLocalNotificationDebug
            : null,
      );

  static void _logLocalNotificationDebug(String message) {
    debugPrint('[RuniacLocalNotifications][Dart] $message');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleInitialRunOpenIntent();
    _scheduleLocalNotificationSmokeTestIfEnabled();
  }

  @override
  void didUpdateWidget(covariant RuniacShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRunOpenIntent != widget.initialRunOpenIntent) {
      _handledInitialRunOpenIntent = false;
      _scheduleInitialRunOpenIntent();
    }
  }

  void _scheduleInitialRunOpenIntent() {
    if (widget.initialRunOpenIntent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openInitialRunIntent();
      });
    }
  }

  void _scheduleLocalNotificationSmokeTestIfEnabled() {
    if (!widget.enableLocalPlanNotifications ||
        !_localNotificationSmokeTestEnabled ||
        _localNotificationSmokeTestScheduled) {
      return;
    }
    _localNotificationSmokeTestScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _planNotificationSyncService.scheduleSmokeTestNotification(
          now: widget.youProgressToday ?? DateTime.now(),
          delay: Duration(seconds: _localNotificationSmokeTestDelaySeconds),
        );
      } catch (error, stackTrace) {
        // QA smoke notification must not block the app shell.
        if (_localNotificationDebugLogs) {
          debugPrint(
            '[RuniacLocalNotifications][Dart] '
            'scheduleSmokeTestNotification failed: $error',
          );
          debugPrint(stackTrace.toString());
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsActiveRunSessionCoordinator) {
      _activeRunSessionCoordinator.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _openActiveRunFromSystemReturn();
    }
  }

  Future<void> _handleNavigationTap(int index) async {
    if (index == 2) {
      final initialPreviewCurrentPosition =
          await prewarmRunLaunchPreviewCurrentPosition(
            enableForegroundGps: widget.enableForegroundGps,
          );
      if (!mounted) {
        return;
      }
      _pushRunLaunchRoute(
        initialPreviewCurrentPosition: initialPreviewCurrentPosition,
        plannedWorkout: _todayPlannedRunContext(),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _openInitialRunIntent() {
    if (!mounted ||
        _handledInitialRunOpenIntent ||
        !_activeRunSessionCoordinator.hasOpenRun) {
      return;
    }

    _handledInitialRunOpenIntent = true;
    _activeRunSessionCoordinator.syncNow();
    _pushRunLaunchRoute(plannedWorkout: _todayPlannedRunContext());
  }

  void _openActiveRunFromSystemReturn() {
    if (!mounted ||
        _runLaunchRouteOpen ||
        !_activeRunSessionCoordinator.hasOpenRun) {
      return;
    }

    _activeRunSessionCoordinator.syncNow();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _runLaunchRouteOpen ||
          !_activeRunSessionCoordinator.hasOpenRun) {
        return;
      }
      _pushRunLaunchRoute(plannedWorkout: _todayPlannedRunContext());
    });
  }

  void _pushRunLaunchRoute({
    RunLocationSample? initialPreviewCurrentPosition,
    PlannedRunContext? plannedWorkout,
  }) {
    _runLaunchRouteOpen = true;
    Navigator.of(context)
        .push(
          _buildRunLaunchRoute(
            initialPreviewCurrentPosition: initialPreviewCurrentPosition,
            plannedWorkout: plannedWorkout,
          ),
        )
        .whenComplete(() {
          _runLaunchRouteOpen = false;
        });
  }

  PageRouteBuilder<void> _buildRunLaunchRoute({
    RunLocationSample? initialPreviewCurrentPosition,
    PlannedRunContext? plannedWorkout,
  }) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return RunLaunchScreen(
          enableForegroundGps: widget.enableForegroundGps,
          initialPreviewCurrentPosition: initialPreviewCurrentPosition,
          activeRunSessionCoordinator: _activeRunSessionCoordinator,
          plannedWorkout: plannedWorkout,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGeneratedPlan = CurrentSessionGeneratedPlanScope.of(
      context,
    ).activePlan;
    final generatedPlanProgress = _generatedPlanProgress(activeGeneratedPlan);
    final todayWorkoutDetail = todayGeneratedWorkoutDetailFromSnapshot(
      activeGeneratedPlan,
      currentDate: widget.youProgressToday,
      planProgress: generatedPlanProgress,
      adaptiveEstimate: widget.adaptivePlanEstimate,
    );
    final todayPlannedRunContext = todayPlannedRunContextFromSnapshot(
      activeGeneratedPlan,
      currentDate: widget.youProgressToday,
      planProgress: generatedPlanProgress,
      adaptiveEstimate: widget.adaptivePlanEstimate,
    );
    _syncGeneratedPlanNotifications(
      activeGeneratedPlan,
      generatedPlanProgress,
      force: false,
    );
    final tabs = [
      HomeTab(
        authRepository: widget.authRepository,
        profileRepository: widget.profileRepository,
        profilePersistenceRepository: widget.profilePersistenceRepository,
        generatedPlanPersistenceRepository:
            widget.generatedPlanPersistenceRepository,
        notificationInboxRepository: widget.notificationInboxRepository,
        userProgressRepository: widget.userProgressRepository,
        todayWorkoutDetailSnapshot: todayWorkoutDetail,
        todayPlannedRunContext: todayPlannedRunContext,
        generatedPlanProgress: generatedPlanProgress,
        currentDate: widget.youProgressToday,
        enableForegroundGps: widget.enableForegroundGps,
        activeRunSessionCoordinator: _activeRunSessionCoordinator,
        onNotificationSettingsChanged: () {
          _syncGeneratedPlanNotifications(
            activeGeneratedPlan,
            generatedPlanProgress,
            force: true,
          );
        },
      ),
      const MapsTab(),
      const SizedBox.shrink(),
      const LeaderboardTab(),
      YouTab(
        activityHistoryRepository: widget.activityHistoryRepository,
        userProgressRepository: widget.userProgressRepository,
        authRepository: widget.authRepository,
        generatedPlanPersistenceRepository:
            widget.generatedPlanPersistenceRepository,
        enableForegroundGps: widget.enableForegroundGps,
        activeRunSessionCoordinator: _activeRunSessionCoordinator,
        progressToday: widget.youProgressToday,
        generatedPlanProgress: generatedPlanProgress,
        adaptivePlanEstimate: widget.adaptivePlanEstimate,
      ),
    ];

    return Scaffold(
      appBar:
          _selectedIndex == 0 ||
              _selectedIndex == 1 ||
              _selectedIndex == 3 ||
              _selectedIndex == 4
          ? null
          : AppBar(title: const Text('Runiac')),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _handleNavigationTap,
        backgroundColor: RuniacColors.white,
        selectedItemColor: RuniacColors.primaryBlue,
        unselectedItemColor: RuniacColors.textSecondary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        selectedIconTheme: const IconThemeData(size: 32),
        unselectedIconTheme: const IconThemeData(size: 30),
        selectedLabelStyle: const TextStyle(fontSize: 0, height: 0),
        unselectedLabelStyle: const TextStyle(fontSize: 0, height: 0),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
            tooltip: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '',
            tooltip: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: '',
            tooltip: 'Run',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: '',
            tooltip: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
            tooltip: 'You',
          ),
        ],
      ),
    );
  }

  PlannedRunContext? _todayPlannedRunContext() {
    final generatedPlanStore = CurrentSessionGeneratedPlanScope.maybeOf(
      context,
    );
    return todayPlannedRunContextFromSnapshot(
      generatedPlanStore?.activePlan,
      currentDate: widget.youProgressToday,
      planProgress: _generatedPlanProgress(generatedPlanStore?.activePlan),
      adaptiveEstimate: widget.adaptivePlanEstimate,
    );
  }

  GeneratedPlanProgressDisplay? _generatedPlanProgress(
    BeginnerAdaptivePlanSnapshot? activePlan,
  ) {
    final completedIds = <String>{
      if (widget.planProgress != null)
        ...widget.planProgress!.completedScheduledWorkoutIds,
      ...?CurrentSessionActivityHistoryScope.maybeRead(
        context,
      )?.completedScheduledWorkoutIdsForPlan(activePlan?.id ?? ''),
    };
    if (completedIds.isEmpty) {
      return null;
    }
    return GeneratedPlanProgressDisplay(
      completedScheduledWorkoutIds: completedIds,
    );
  }

  void _syncGeneratedPlanNotifications(
    BeginnerAdaptivePlanSnapshot? activeGeneratedPlan,
    GeneratedPlanProgressDisplay? generatedPlanProgress, {
    required bool force,
  }) {
    if (!widget.enableLocalPlanNotifications) {
      return;
    }
    final signature = _planNotificationSyncSignature(
      activeGeneratedPlan,
      generatedPlanProgress,
    );
    if (!force && signature == _lastPlanNotificationSyncSignature) {
      return;
    }
    if (_planNotificationSyncInFlight) {
      _pendingPlanNotificationSync = true;
      _pendingPlanNotificationPlan = activeGeneratedPlan;
      _pendingPlanNotificationProgress = generatedPlanProgress;
      return;
    }
    _lastPlanNotificationSyncSignature = signature;
    _planNotificationSyncInFlight = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final now = widget.youProgressToday ?? DateTime.now();
        await _planNotificationSyncService.syncGeneratedPlan(
          activeGeneratedPlan,
          now: now,
          completedScheduledWorkoutIds:
              generatedPlanProgress?.completedScheduledWorkoutIds ??
              const <String>{},
          streakRisk: await _streakRiskInputForPlan(
            activeGeneratedPlan,
            now: now,
          ),
        );
      } catch (_) {
        // Notification sync should not block the primary app shell.
      } finally {
        _planNotificationSyncInFlight = false;
        if (_pendingPlanNotificationSync && mounted) {
          final pendingPlan = _pendingPlanNotificationPlan;
          final pendingProgress = _pendingPlanNotificationProgress;
          _pendingPlanNotificationSync = false;
          _pendingPlanNotificationPlan = null;
          _pendingPlanNotificationProgress = null;
          _syncGeneratedPlanNotifications(
            pendingPlan,
            pendingProgress,
            force: true,
          );
        }
      }
    });
  }

  String _planNotificationSyncSignature(
    BeginnerAdaptivePlanSnapshot? activeGeneratedPlan,
    GeneratedPlanProgressDisplay? generatedPlanProgress,
  ) {
    final completedIds = [
      ...?generatedPlanProgress?.completedScheduledWorkoutIds,
    ]..sort();
    final currentDate = widget.youProgressToday;
    final dayKey = currentDate == null
        ? 'today'
        : '${currentDate.year}-${currentDate.month}-${currentDate.day}';
    return [
      activeGeneratedPlan?.id ?? 'none',
      activeGeneratedPlan?.startsOnDate ?? 'no-start',
      dayKey,
      ...completedIds,
    ].join('|');
  }

  Future<StreakRiskNotificationInput?> _streakRiskInputForPlan(
    BeginnerAdaptivePlanSnapshot? activeGeneratedPlan, {
    required DateTime now,
  }) async {
    if (activeGeneratedPlan == null) {
      return null;
    }
    final progress = await widget.userProgressRepository.loadUserProgress();
    if (!_isStreakAtRisk(progress, now: now)) {
      return null;
    }
    return StreakRiskNotificationInput(
      planId: activeGeneratedPlan.id,
      riskDate: now,
      streakWouldBreakWithoutValidatedRun: true,
    );
  }

  bool _isStreakAtRisk(
    UserProgressReadModel progress, {
    required DateTime now,
  }) {
    final streakCount = progress.officialStreakCount;
    if (streakCount == null || streakCount <= 0) {
      return false;
    }
    return progress.lastStreakRunDate != _dateKey(now);
  }

  String _dateKey(DateTime date) {
    return [
      date.year.toString().padLeft(4, '0'),
      date.month.toString().padLeft(2, '0'),
      date.day.toString().padLeft(2, '0'),
    ].join('-');
  }
}
