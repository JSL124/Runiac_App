import 'package:flutter/material.dart';

import '../../account/presentation/account_profile_screen.dart';
import '../../account/domain/repositories/user_profile_persistence_repository.dart';
import '../../account/domain/repositories/user_profile_repository.dart';
import '../../auth/domain/runiac_auth_service.dart';
import '../../notifications/domain/repositories/notification_inbox_repository.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import '../../plan/domain/repositories/generated_plan_persistence_repository.dart';
import '../../run/presentation/active_run_session_coordinator.dart';
import '../../run/presentation/models/planned_run_context.dart';
import '../../run/presentation/run_launch_screen.dart';
import '../../you/domain/models/user_progress_read_model.dart';
import '../../you/domain/repositories/user_progress_repository.dart';
import '../../you/presentation/data/weekly_workout_demo_snapshots.dart';
import '../../you/presentation/weekly_workout_detail_screen.dart';
import 'widgets/home_header.dart';
import 'widgets/home_progress_insight_section.dart';
import 'widgets/explore_routes_section.dart';
import 'widgets/today_plan_card.dart';

const _homeScreenBackground = Colors.white;

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

  Future<void> _openQuickStart(BuildContext context) async {
    final initialPreviewCurrentPosition =
        await prewarmRunLaunchPreviewCurrentPosition(
          enableForegroundGps: widget.enableForegroundGps,
        );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RunLaunchScreen(
          enableForegroundGps: widget.enableForegroundGps,
          initialPreviewCurrentPosition: initialPreviewCurrentPosition,
          activeRunSessionCoordinator: widget.activeRunSessionCoordinator,
          plannedWorkout: widget.todayPlannedRunContext,
        ),
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

  @override
  Widget build(BuildContext context) {
    _ensureUserProgressFutureForCurrentOwner();
    return SafeArea(
      child: ColoredBox(
        color: _homeScreenBackground,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
            children: [
              _HomeContentPadding(
                child: StreamBuilder<int>(
                  stream: widget.notificationInboxRepository.watchUnreadCount(),
                  initialData: 0,
                  builder: (context, snapshot) {
                    return FutureBuilder<UserProgressReadModel>(
                      future: _userProgressFuture,
                      builder: (context, progressSnapshot) {
                        final progress =
                            progressSnapshot.data ?? _lastUserProgress;
                        return HomeHeader(
                          unreadNotificationCount: snapshot.data ?? 0,
                          levelBadgeLabel: progress?.levelBadgeLabel ?? 'Lv.0',
                          levelProgressFraction:
                              progress?.levelProgressFraction ?? 0,
                          onNotifications: () =>
                              _openNotificationInbox(context),
                          onProfile: () => _openAccountProfile(context),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TodayPlanCard(
                onViewPlan: () => _openTodayWorkout(context),
                onQuickStart: () => _openQuickStart(context),
              ),
              const SizedBox(height: 10),
              const _HomeContentPadding(child: HomeProgressInsightSection()),
              const SizedBox(height: 10),
              const _HomeContentPadding(child: ExploreRoutesSection()),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContentPadding extends StatelessWidget {
  const _HomeContentPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
