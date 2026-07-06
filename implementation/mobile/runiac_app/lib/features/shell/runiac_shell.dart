import 'package:flutter/material.dart';

import '../../core/theme/runiac_colors.dart';
import '../account/domain/repositories/user_profile_repository.dart';
import '../account/domain/repositories/user_profile_persistence_repository.dart';
import '../auth/domain/runiac_auth_service.dart';
import '../home/presentation/home_tab.dart';
import '../leaderboard/presentation/leaderboard_tab.dart';
import '../maps/presentation/maps_tab.dart';
import '../plan/domain/repositories/generated_plan_persistence_repository.dart';
import '../plan/presentation/current_session_generated_plan.dart';
import '../run/domain/models/run_location_sample.dart';
import '../run/presentation/active_run_session_coordinator.dart';
import '../run/presentation/models/planned_run_context.dart';
import '../run/presentation/run_launch_screen.dart';
import '../run/presentation/run_open_intent.dart';
import '../you/data/static_activity_history_repository.dart';
import '../you/domain/repositories/activity_history_repository.dart';
import '../you/domain/repositories/user_progress_repository.dart';
import '../you/presentation/adapters/generated_plan_you_display_adapter.dart';
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
    super.key,
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.initialRunOpenIntent,
    this.youProgressToday,
  });

  final RuniacAuthRepository authRepository;
  final ActivityHistoryRepository activityHistoryRepository;
  final UserProgressRepository userProgressRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final GeneratedPlanPersistenceRepository generatedPlanPersistenceRepository;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final RunOpenIntent? initialRunOpenIntent;
  final DateTime? youProgressToday;

  @override
  State<RuniacShell> createState() => _RuniacShellState();
}

class _RuniacShellState extends State<RuniacShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final bool _ownsActiveRunSessionCoordinator =
      widget.activeRunSessionCoordinator == null;
  late final ActiveRunSessionCoordinator _activeRunSessionCoordinator =
      widget.activeRunSessionCoordinator ?? ActiveRunSessionCoordinator();
  bool _handledInitialRunOpenIntent = false;
  bool _runLaunchRouteOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleInitialRunOpenIntent();
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
    final todayWorkoutDetail = todayGeneratedWorkoutDetailFromSnapshot(
      activeGeneratedPlan,
      currentDate: widget.youProgressToday,
    );
    final todayPlannedRunContext = todayPlannedRunContextFromSnapshot(
      activeGeneratedPlan,
      currentDate: widget.youProgressToday,
    );
    final tabs = [
      HomeTab(
        authRepository: widget.authRepository,
        profileRepository: widget.profileRepository,
        profilePersistenceRepository: widget.profilePersistenceRepository,
        generatedPlanPersistenceRepository:
            widget.generatedPlanPersistenceRepository,
        todayWorkoutDetailSnapshot: todayWorkoutDetail,
        todayPlannedRunContext: todayPlannedRunContext,
        enableForegroundGps: widget.enableForegroundGps,
        activeRunSessionCoordinator: _activeRunSessionCoordinator,
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
    );
  }
}
