import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../domain/models/run_tracking_state.dart';
import '../domain/repositories/run_repository.dart';
import 'active_run_session_coordinator.dart';
import 'controllers/run_tracking_controller.dart';
import 'cool_down_screen.dart';
import 'models/planned_run_context.dart';
import 'run_repository_scope.dart';
import 'run_completion_coordinator.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_mapbox_follow_qa_overlay.dart';
import 'widgets/run_mapbox_surface_config.dart';
import 'widgets/run_status_pill.dart';
import 'widgets/run_tracking_map_surface.dart';
import 'widgets/run_tracking_sheet_content.dart';
import '../../you/presentation/current_session_activity_history.dart';

const _screenBackground = Color(0xFF3153C9);
const _recenterButtonSize = 48.0;
const _sheetAdjacentRecenterGap = 10.0;
const _activeRecenterRightPadding = 24.0;

class RunActiveScreen extends StatefulWidget {
  const RunActiveScreen({
    super.key,
    this.controller,
    this.repository,
    this.mapboxAccessToken,
    this.mapboxBuilder,
    this.enableMapboxFollowQa = runMapboxFollowQaEnabled,
    this.activeRunSessionCoordinator,
    this.plannedWorkout,
  });

  final RunTrackingController? controller;
  final RunRepository? repository;
  final String? mapboxAccessToken;
  final RunMapboxSurfaceBuilder? mapboxBuilder;
  final bool enableMapboxFollowQa;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final PlannedRunContext? plannedWorkout;

  @override
  State<RunActiveScreen> createState() => _RunActiveScreenState();
}

class _RunActiveScreenState extends State<RunActiveScreen> {
  late final RunTrackingController _controller;
  late final ActiveRunSessionCoordinator _activeRunSessionCoordinator;
  late final bool _ownsActiveRunSessionCoordinator;
  bool _isFollowingRunner = true;
  bool _isCompletingRun = false;
  int _mapRecenterRequestId = 0;
  late final RunMapboxFollowQaDiagnostics? _followQaDiagnostics =
      widget.enableMapboxFollowQa
      ? RunMapboxFollowQaDiagnostics(enabled: true, screenPath: 'active')
      : null;

  @override
  void initState() {
    super.initState();
    _ownsActiveRunSessionCoordinator =
        widget.activeRunSessionCoordinator == null;
    _activeRunSessionCoordinator =
        widget.activeRunSessionCoordinator ??
        ActiveRunSessionCoordinator(
          controller: widget.controller,
          disposeController: widget.controller == null,
        );
    _controller = _activeRunSessionCoordinator.controllerFor(
      () => RunTrackingController(),
    );
    if (_controller.state.phase == RunTrackingPhase.idle) {
      _controller.start(
        startedAt: _activeRunSessionCoordinator.now(),
        routeLabel: 'Easy local route',
      );
    }
    _activeRunSessionCoordinator.startForegroundTicker();
  }

  @override
  void dispose() {
    _activeRunSessionCoordinator.stopForegroundTicker();
    if (_ownsActiveRunSessionCoordinator) {
      _activeRunSessionCoordinator.dispose();
    }
    super.dispose();
  }

  Future<void> _finishRun() async {
    if (_isCompletingRun) {
      return;
    }

    final completedAt = _activeRunSessionCoordinator.now();
    _activeRunSessionCoordinator.syncTo(completedAt);
    final planEnrollmentId =
        widget.plannedWorkout?.alreadyCompletedToday == true
        ? null
        : widget.plannedWorkout?.planEnrollmentId;
    final scheduledWorkoutId =
        widget.plannedWorkout?.alreadyCompletedToday == true
        ? null
        : widget.plannedWorkout?.scheduledWorkoutId;
    final payload = _controller.completionPayload(
      completedAt: completedAt,
      planEnrollmentId: planEnrollmentId,
      scheduledWorkoutId: scheduledWorkoutId,
    );
    setState(() => _isCompletingRun = true);

    final activityHistoryStore = CurrentSessionActivityHistoryScope.maybeOf(
      context,
    );
    final result = await const RunCompletionCoordinator().complete(
      repository: _repository,
      payload: payload,
      activityHistoryStore: activityHistoryStore,
    );
    if (!mounted) {
      return;
    }
    _activeRunSessionCoordinator.stopForegroundTicker();
    _controller.finish(completedAt: completedAt);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => CoolDownScreen(
          completionResult: result,
          completionPayload: payload,
          repository: _repository,
        ),
      ),
    );
  }

  RunRepository get _repository {
    return widget.repository ?? RunRepositoryScope.of(context);
  }

  void _updateFollowQaMapState() {
    final diagnostics = _followQaDiagnostics;
    diagnostics?.updateMapState(
      mapPath: diagnostics.mapPath,
      isFollowingRunner: _isFollowingRunner,
      recenterRequestId: _mapRecenterRequestId,
    );
  }

  void _recenterRunner() {
    setState(() {
      _isFollowingRunner = true;
      _mapRecenterRequestId++;
    });
    _followQaDiagnostics?.recordRecenterRequest(_mapRecenterRequestId);
    _updateFollowQaMapState();
  }

  void _resumeRun() {
    _controller.resume(resumedAt: _activeRunSessionCoordinator.now());
    _followQaDiagnostics?.recordResume();
    _updateFollowQaMapState();
  }

  void _pauseRun() {
    final pausedAt = _activeRunSessionCoordinator.now();
    _activeRunSessionCoordinator.syncTo(pausedAt);
    _controller.pause(pausedAt: pausedAt);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _screenBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return RunTrackingMapSurface(
                  mapViewState: _controller.mapViewState,
                  isFollowingRunner: _isFollowingRunner,
                  recenterRequestId: _mapRecenterRequestId,
                  onManualPan: () {
                    _followQaDiagnostics?.recordOnManualPan();
                    setState(() => _isFollowingRunner = false);
                    _updateFollowQaMapState();
                  },
                  onRecenter: _recenterRunner,
                  showRecenterButton: false,
                  mapboxAccessToken: widget.mapboxAccessToken,
                  mapboxBuilder: widget.mapboxBuilder,
                  followQaDiagnostics: _followQaDiagnostics,
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Center(
                      child: RunStatusPill(
                        maxWidth: 240,
                        horizontalPadding: 16,
                        label: _controller.state.isAbnormalPaused
                            ? 'Tracking paused'
                            : _controller.state.isPaused ||
                                  _controller.state.isAutoPaused
                            ? 'Paused'
                            : _controller.state.locationStatus.label,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: _recenterButtonSize + _sheetAdjacentRecenterGap,
                      ),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return _RunActivePanel(
                            key: const Key('runActivePanel'),
                            state: _controller.state,
                            plannedWorkout: widget.plannedWorkout,
                            onPause: _pauseRun,
                            onResume: _resumeRun,
                            onFinish: _finishRun,
                            isCompletingRun: _isCompletingRun,
                            bottomInset: bottomInset,
                          );
                        },
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Positioned(
                          top: 0,
                          right: _activeRecenterRightPadding,
                          child: Opacity(
                            opacity: _hasCurrentPosition ? 1 : 0.58,
                            child: RunMapRecenterButton(
                              onPressed: _recenterRunner,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasCurrentPosition {
    return _controller.mapViewState.currentPosition != null;
  }
}

class _RunActivePanel extends StatelessWidget {
  const _RunActivePanel({
    super.key,
    required this.state,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.isCompletingRun,
    required this.bottomInset,
    this.plannedWorkout,
  });

  final RunTrackingState state;
  final PlannedRunContext? plannedWorkout;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final bool isCompletingRun;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            compact ? 18 : 20,
            24,
            bottomInset + (compact ? 18 : 22),
          ),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26172033),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: RunTrackingSheetContent(
            state: state,
            plannedWorkout: plannedWorkout,
            onPause: onPause,
            onResume: onResume,
            onEnd: onFinish,
            isCompletingRun: isCompletingRun,
          ),
        );
      },
    );
  }
}
