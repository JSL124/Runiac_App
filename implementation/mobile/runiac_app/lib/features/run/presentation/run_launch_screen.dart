import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_bottom_sheet_handle.dart';
import '../data/android_run_notification_permission_service.dart';
import '../data/geolocator_run_location_permission_service.dart';
import '../data/phone_motion_run_cadence_provider.dart';
import '../data/platform_run_foreground_service.dart';
import '../data/real_foreground_run_location_provider.dart';
import '../data/sensors_plus_run_motion_provider.dart';
import '../domain/models/complete_run_result.dart';
import '../domain/models/run_location_permission_status.dart';
import '../domain/models/run_location_sample.dart';
import '../domain/models/run_completion_error.dart';
import '../domain/models/run_route_snapshot.dart';
import '../domain/models/run_tracking_state.dart';
import '../domain/repositories/run_foreground_service.dart';
import '../domain/repositories/run_cadence_provider.dart';
import '../domain/repositories/run_location_permission_service.dart';
import '../domain/repositories/run_location_preview_provider.dart';
import '../domain/repositories/run_location_provider.dart';
import '../domain/repositories/run_motion_provider.dart';
import '../domain/repositories/run_notification_permission_service.dart';
import '../domain/repositories/run_repository.dart';
import '../domain/services/run_summary_local_analysis_merger.dart';
import 'active_run_session_coordinator.dart';
import 'controllers/run_tracking_controller.dart';
import 'cool_down_screen.dart';
import 'data/run_launch_demo_snapshots.dart';
import 'models/planned_run_context.dart';
import 'run_repository_scope.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_mapbox_follow_qa_overlay.dart';
import 'widgets/run_mapbox_surface_config.dart';
import 'widgets/run_tracking_map_surface.dart';
import 'widgets/run_tracking_sheet_content.dart';
import '../../you/presentation/current_session_activity_history.dart';

const _blueBorder = Color(0xFFDCE6FF);
const _sportOrange = Color(0xFFFF7A1A);
const _orangeShadow = Color(0x33FF7A1A);
const _screenBackground = Color(0xFF3153C9);
const _softControlBlue = Color(0x667A91E5);
const _panelTextBlue = Color(0xFF3151C8);
const _mutedBlue = Color(0xFF8296E8);
const _controlPressHold = Duration(milliseconds: 90);
const _sheetAnimationDuration = Duration(milliseconds: 280);
const _sheetExtentAnimationDuration = Duration(milliseconds: 220);
const _expandedRunSheetHeight = 405.0;
const _collapsedRunSheetHeight = 46.0;
const _sheetCollapseVelocityThreshold = 260.0;
const _recenterButtonSize = 48.0;
const _sheetAdjacentRecenterGap = 10.0;
const _launchRecenterRightPadding = 28.0;

enum RunSheetMode { preRun, running, paused }

enum RunLaunchSheetExtent { expanded, collapsed }

enum _RunPreviewLocationStatus {
  inactive,
  checkingPermission,
  permissionRequired,
  findingLocation,
  locationReady,
  serviceDisabled,
  permissionBlocked,
  unavailable,
}

RunLocationPermissionService? _resolveRunLaunchPermissionService({
  required bool enableForegroundGps,
  required RunLocationPermissionService? permissionService,
}) {
  if (!enableForegroundGps) {
    return permissionService;
  }
  return permissionService ?? const GeolocatorRunLocationPermissionService();
}

RunLocationPreviewProvider? _resolveRunLaunchPreviewProvider({
  required bool enableForegroundGps,
  required RunLocationPreviewProvider? locationPreviewProvider,
}) {
  if (!enableForegroundGps) {
    return locationPreviewProvider;
  }
  return locationPreviewProvider ??
      const RealForegroundRunLocationPreviewProvider();
}

RunNotificationPermissionService?
_resolveRunLaunchNotificationPermissionService({
  required bool enableForegroundGps,
  required RunNotificationPermissionService? notificationPermissionService,
}) {
  if (!enableForegroundGps) {
    return notificationPermissionService;
  }
  return notificationPermissionService ??
      const AndroidRunNotificationPermissionService();
}

Future<RunLocationSample?> prewarmRunLaunchPreviewCurrentPosition({
  required bool enableForegroundGps,
  RunLocationPermissionService? permissionService,
  RunLocationPreviewProvider? locationPreviewProvider,
}) async {
  final effectivePermissionService = _resolveRunLaunchPermissionService(
    enableForegroundGps: enableForegroundGps,
    permissionService: permissionService,
  );
  final effectivePreviewProvider = _resolveRunLaunchPreviewProvider(
    enableForegroundGps: enableForegroundGps,
    locationPreviewProvider: locationPreviewProvider,
  );
  if (effectivePermissionService == null || effectivePreviewProvider == null) {
    return null;
  }

  try {
    final permissionStatus = await effectivePermissionService.checkStatus();
    if (permissionStatus != RunLocationPermissionStatus.granted) {
      return null;
    }
    return await effectivePreviewProvider.currentLocation();
  } on Object {
    return null;
  }
}

class RunLaunchScreen extends StatefulWidget {
  const RunLaunchScreen({
    super.key,
    this.repository,
    this.locationProvider,
    this.cadenceProvider,
    this.motionProvider,
    this.locationPreviewProvider,
    this.permissionService,
    this.notificationPermissionService,
    this.foregroundService,
    this.enableForegroundGps = true,
    this.mapboxAccessToken,
    this.mapboxBuilder,
    this.enableMapboxFollowQa = runMapboxFollowQaEnabled,
    this.initialPreviewCurrentPosition,
    this.activeRunSessionCoordinator,
    this.plannedWorkout,
  });

  final RunRepository? repository;
  final RunLocationProvider? locationProvider;
  final RunCadenceProvider? cadenceProvider;
  final RunMotionProvider? motionProvider;
  final RunLocationPreviewProvider? locationPreviewProvider;
  final RunLocationPermissionService? permissionService;
  final RunNotificationPermissionService? notificationPermissionService;
  final RunForegroundService? foregroundService;
  final bool enableForegroundGps;
  final String? mapboxAccessToken;
  final RunMapboxSurfaceBuilder? mapboxBuilder;
  final bool enableMapboxFollowQa;
  final RunLocationSample? initialPreviewCurrentPosition;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final PlannedRunContext? plannedWorkout;

  @override
  State<RunLaunchScreen> createState() => _RunLaunchScreenState();
}

class _RunLaunchScreenState extends State<RunLaunchScreen> {
  late final RunTrackingController _controller;
  late final ActiveRunSessionCoordinator _activeRunSessionCoordinator;
  late final bool _ownsActiveRunSessionCoordinator;
  late final RunLocationPermissionService? _permissionService;
  late final RunLocationPreviewProvider? _locationPreviewProvider;
  RunSheetMode _sheetMode = RunSheetMode.preRun;
  RunLaunchSheetExtent _sheetExtent = RunLaunchSheetExtent.expanded;
  double _sheetProgress = 1;
  bool _isCompletingRun = false;
  bool _isFollowingRunner = true;
  int _mapRecenterRequestId = 0;
  int _previewRequestId = 0;
  late final RunMapboxFollowQaDiagnostics? _followQaDiagnostics =
      widget.enableMapboxFollowQa
      ? RunMapboxFollowQaDiagnostics(enabled: true, screenPath: 'launch')
      : null;
  _RunPreviewLocationStatus _previewLocationStatus =
      _RunPreviewLocationStatus.inactive;

  @override
  void initState() {
    super.initState();
    final useForegroundGps = widget.enableForegroundGps;
    _permissionService = _resolveRunLaunchPermissionService(
      enableForegroundGps: useForegroundGps,
      permissionService: widget.permissionService,
    );
    _locationPreviewProvider = _resolveRunLaunchPreviewProvider(
      enableForegroundGps: useForegroundGps,
      locationPreviewProvider: widget.locationPreviewProvider,
    );
    _ownsActiveRunSessionCoordinator =
        widget.activeRunSessionCoordinator == null;
    _activeRunSessionCoordinator =
        widget.activeRunSessionCoordinator ?? ActiveRunSessionCoordinator();
    _controller = _activeRunSessionCoordinator.controllerFor(
      () => RunTrackingController(
        locationProvider: useForegroundGps
            ? widget.locationProvider ?? RealForegroundRunLocationProvider()
            : widget.locationProvider,
        cadenceProvider:
            widget.cadenceProvider ??
            (useForegroundGps && widget.locationProvider == null
                ? PhoneMotionRunCadenceProvider()
                : null),
        motionProvider: useForegroundGps
            ? widget.motionProvider ?? SensorsPlusRunMotionProvider()
            : widget.motionProvider,
        foregroundService: useForegroundGps
            ? widget.foregroundService ?? platformRunForegroundService()
            : null,
        permissionService: _permissionService,
        notificationPermissionService:
            _resolveRunLaunchNotificationPermissionService(
              enableForegroundGps: useForegroundGps,
              notificationPermissionService:
                  widget.notificationPermissionService,
            ),
        locationStatus: useForegroundGps
            ? RunTrackingLocationStatus.waitingForGps
            : RunTrackingLocationStatus.demo,
        initialPreviewCurrentPosition: widget.initialPreviewCurrentPosition,
      ),
    );
    _restoreSheetModeForActiveController();
    if (useForegroundGps) {
      _previewLocationStatus = widget.initialPreviewCurrentPosition == null
          ? _RunPreviewLocationStatus.checkingPermission
          : _RunPreviewLocationStatus.locationReady;
      unawaited(_refreshPreviewLocation(requestPermission: false));
    }
  }

  void _restoreSheetModeForActiveController() {
    final state = _controller.state;
    if (state.phase == RunTrackingPhase.idle ||
        state.phase == RunTrackingPhase.finished) {
      return;
    }

    _sheetMode = state.isPaused || state.isAutoPaused || state.isAbnormalPaused
        ? RunSheetMode.paused
        : RunSheetMode.running;
    _activeRunSessionCoordinator.startForegroundTicker();
    _activeRunSessionCoordinator.syncNow();
  }

  @override
  void dispose() {
    _activeRunSessionCoordinator.stopForegroundTicker();
    if (_ownsActiveRunSessionCoordinator) {
      _activeRunSessionCoordinator.dispose();
    }
    super.dispose();
  }

  void _updateFollowQaMapState() {
    final diagnostics = _followQaDiagnostics;
    diagnostics?.updateMapState(
      mapPath: diagnostics.mapPath,
      isFollowingRunner: _isFollowingRunner,
      recenterRequestId: _mapRecenterRequestId,
    );
  }

  Future<void> _startRun() async {
    if (_sheetMode != RunSheetMode.preRun) {
      return;
    }

    if (_controller.state.phase == RunTrackingPhase.idle ||
        _controller.state.phase == RunTrackingPhase.finished) {
      final started = await _controller.requestStart(
        startedAt: _activeRunSessionCoordinator.now(),
        routeLabel: 'Easy local route',
      );
      if (!mounted) {
        return;
      }
      if (!started) {
        _showPreviewMessage(_controller.locationPermissionMessage);
        return;
      }
    }

    _activeRunSessionCoordinator.startForegroundTicker();

    final shouldAlignCameraOnStart = _isFollowingRunner && _hasCurrentPosition;
    setState(() {
      _sheetExtent = RunLaunchSheetExtent.expanded;
      _sheetProgress = 1;
      if (shouldAlignCameraOnStart) {
        _mapRecenterRequestId++;
      }
      _sheetMode = RunSheetMode.running;
    });
    if (shouldAlignCameraOnStart) {
      _followQaDiagnostics?.recordRecenterRequest(_mapRecenterRequestId);
    }
    _updateFollowQaMapState();
  }

  void _pauseRun() {
    if (_isCompletingRun) {
      return;
    }
    final pausedAt = _activeRunSessionCoordinator.now();
    _activeRunSessionCoordinator.syncTo(pausedAt);
    _controller.pause(pausedAt: pausedAt);
    setState(() => _sheetMode = RunSheetMode.paused);
  }

  void _resumeRun() {
    if (_isCompletingRun) {
      return;
    }
    _controller.resume(resumedAt: _activeRunSessionCoordinator.now());
    setState(() => _sheetMode = RunSheetMode.running);
    _followQaDiagnostics?.recordResume();
    _updateFollowQaMapState();
  }

  void _handleSheetDragStart(DragStartDetails details) {}

  void _handleSheetDragUpdate(DragUpdateDetails details) {
    setState(() {
      _sheetProgress =
          (_sheetProgress -
                  details.delta.dy /
                      (_expandedRunSheetHeight - _collapsedRunSheetHeight))
              .clamp(0, 1);
      _sheetExtent = _sheetProgress <= 0.01
          ? RunLaunchSheetExtent.collapsed
          : RunLaunchSheetExtent.expanded;
    });
  }

  void _handleSheetDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    setState(() {
      if (velocity > _sheetCollapseVelocityThreshold) {
        _sheetExtent = RunLaunchSheetExtent.collapsed;
        _sheetProgress = 0;
      } else if (velocity < -_sheetCollapseVelocityThreshold) {
        _sheetExtent = RunLaunchSheetExtent.expanded;
        _sheetProgress = 1;
      } else if (_sheetProgress >= 0.5) {
        _sheetExtent = RunLaunchSheetExtent.expanded;
        _sheetProgress = 1;
      } else {
        _sheetExtent = RunLaunchSheetExtent.collapsed;
        _sheetProgress = 0;
      }
    });
  }

  void _handleSheetDragCancel() {
    setState(() {
      if (_sheetProgress >= 0.5) {
        _sheetExtent = RunLaunchSheetExtent.expanded;
        _sheetProgress = 1;
      } else {
        _sheetExtent = RunLaunchSheetExtent.collapsed;
        _sheetProgress = 0;
      }
    });
  }

  void _toggleSheetExtent() {
    setState(() {
      if (_sheetExtent == RunLaunchSheetExtent.expanded) {
        _sheetExtent = RunLaunchSheetExtent.collapsed;
        _sheetProgress = 0;
      } else {
        _sheetExtent = RunLaunchSheetExtent.expanded;
        _sheetProgress = 1;
      }
    });
  }

  Future<void> _finishRun() async {
    if (_isCompletingRun) {
      return;
    }

    final completedAt = _activeRunSessionCoordinator.now();
    _activeRunSessionCoordinator.syncTo(completedAt);
    final payload = _controller.completionPayload(completedAt: completedAt);
    final route = RunRouteSnapshot.fromMapViewState(_controller.mapViewState);
    setState(() => _isCompletingRun = true);

    CompleteRunResult result;
    try {
      result = await _repository.completeRun(payload);
    } on RunCompletionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isCompletingRun = false);
      _showPreviewMessage(
        error.isRetryable
            ? 'Run completion is unavailable. Please try again.'
            : 'Run details could not be submitted.',
      );
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isCompletingRun = false);
      _showPreviewMessage('Run completion is unavailable. Please try again.');
      return;
    }

    if (!mounted) {
      return;
    }
    result = result.copyWith(
      summary: const RunSummaryLocalAnalysisMerger().merge(
        backendSummary: result.summary,
        localPayload: payload,
        localRoute: route,
        resultClientRunSessionId: result.clientRunSessionId,
      ),
    );
    CurrentSessionActivityHistoryScope.maybeOf(
      context,
    )?.registerCompletedRun(result);
    _activeRunSessionCoordinator.stopForegroundTicker();
    _controller.finish(completedAt: completedAt);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => CoolDownScreen(completionResult: result),
      ),
    );
  }

  RunRepository get _repository {
    return widget.repository ?? RunRepositoryScope.of(context);
  }

  void _showPreviewMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshPreviewLocation({
    required bool requestPermission,
    bool showFailureMessage = false,
    bool recenterOnSuccess = false,
  }) async {
    final permissionService = _permissionService;
    final previewProvider = _locationPreviewProvider;
    if (!widget.enableForegroundGps ||
        permissionService == null ||
        previewProvider == null) {
      return;
    }

    final requestId = ++_previewRequestId;
    final hasSeededPreview = _controller.previewCurrentPosition != null;
    if (mounted) {
      setState(() {
        _previewLocationStatus = requestPermission
            ? _RunPreviewLocationStatus.findingLocation
            : hasSeededPreview
            ? _RunPreviewLocationStatus.locationReady
            : _RunPreviewLocationStatus.checkingPermission;
      });
    }

    var permissionStatus = await permissionService.checkStatus();
    if (requestPermission &&
        permissionStatus == RunLocationPermissionStatus.denied) {
      permissionStatus = await permissionService.requestPermission();
    }
    if (!mounted || requestId != _previewRequestId) {
      return;
    }

    if (!permissionStatus.canStartRun) {
      setState(() {
        _previewLocationStatus = _previewStatusForPermission(permissionStatus);
      });
      if (showFailureMessage) {
        _showPreviewMessage(permissionStatus.message);
      }
      return;
    }

    if (!hasSeededPreview || requestPermission) {
      setState(() {
        _previewLocationStatus = _RunPreviewLocationStatus.findingLocation;
      });
    }

    try {
      final sample = await previewProvider.currentLocation();
      if (!mounted || requestId != _previewRequestId) {
        return;
      }
      _controller.setPreviewCurrentPosition(sample);
      setState(() {
        _previewLocationStatus = _RunPreviewLocationStatus.locationReady;
        if (recenterOnSuccess) {
          _isFollowingRunner = true;
          _mapRecenterRequestId++;
        }
      });
      if (recenterOnSuccess) {
        _followQaDiagnostics?.recordRecenterRequest(_mapRecenterRequestId);
        _updateFollowQaMapState();
      }
    } on Object {
      if (!mounted || requestId != _previewRequestId) {
        return;
      }
      setState(() {
        _previewLocationStatus = _RunPreviewLocationStatus.unavailable;
      });
      if (showFailureMessage) {
        _showPreviewMessage(RunLocationPermissionStatus.unavailable.message);
      }
    }
  }

  _RunPreviewLocationStatus _previewStatusForPermission(
    RunLocationPermissionStatus status,
  ) {
    return switch (status) {
      RunLocationPermissionStatus.checking =>
        _RunPreviewLocationStatus.checkingPermission,
      RunLocationPermissionStatus.granted =>
        _RunPreviewLocationStatus.findingLocation,
      RunLocationPermissionStatus.denied =>
        _RunPreviewLocationStatus.permissionRequired,
      RunLocationPermissionStatus.deniedForever =>
        _RunPreviewLocationStatus.permissionBlocked,
      RunLocationPermissionStatus.notificationDenied =>
        _RunPreviewLocationStatus.permissionBlocked,
      RunLocationPermissionStatus.serviceDisabled =>
        _RunPreviewLocationStatus.serviceDisabled,
      RunLocationPermissionStatus.unavailable =>
        _RunPreviewLocationStatus.unavailable,
    };
  }

  String _statusLabel(RunTrackingState state) {
    if (_sheetMode == RunSheetMode.preRun) {
      if (!widget.enableForegroundGps) {
        return RunTrackingLocationStatus.demo.label;
      }
      return switch (_previewLocationStatus) {
        _RunPreviewLocationStatus.inactive => 'Checking GPS',
        _RunPreviewLocationStatus.checkingPermission => 'Checking GPS',
        _RunPreviewLocationStatus.permissionRequired => 'Tap location',
        _RunPreviewLocationStatus.findingLocation => 'Finding you',
        _RunPreviewLocationStatus.locationReady => 'GPS ready',
        _RunPreviewLocationStatus.serviceDisabled => 'GPS off',
        _RunPreviewLocationStatus.permissionBlocked => 'GPS blocked',
        _RunPreviewLocationStatus.unavailable => 'Location unavailable',
      };
    }

    if (state.isAbnormalPaused) {
      return 'Tracking paused';
    }

    if (_sheetMode == RunSheetMode.paused ||
        state.isPaused ||
        state.isAutoPaused) {
      return 'Paused';
    }

    return state.locationStatus.label;
  }

  void _recenterRunner() {
    setState(() {
      _isFollowingRunner = true;
      _mapRecenterRequestId++;
    });
    _followQaDiagnostics?.recordRecenterRequest(_mapRecenterRequestId);
    _updateFollowQaMapState();
    if (!_hasCurrentPosition && _sheetMode == RunSheetMode.preRun) {
      unawaited(
        _refreshPreviewLocation(
          requestPermission: true,
          showFailureMessage: true,
          recenterOnSuccess: true,
        ),
      );
    }
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
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: _sheetAnimationDuration,
                        child: _sheetMode == RunSheetMode.preRun
                            ? _MapCircleButton(
                                key: const ValueKey('close_button'),
                                tooltip: 'Close',
                                icon: Icons.close,
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            : const SizedBox(
                                key: ValueKey('close_button_hidden'),
                                width: 48,
                                height: 48,
                              ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return Center(
                            child: AnimatedSwitcher(
                              duration: _sheetAnimationDuration,
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: _RunStatusPill(
                                key: ValueKey(_statusLabel(_controller.state)),
                                label: _statusLabel(_controller.state),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: _sheetAnimationDuration,
                        child: _sheetMode == RunSheetMode.preRun
                            ? _MapCircleButton(
                                key: const ValueKey('settings_button'),
                                tooltip: 'Run settings',
                                icon: Icons.settings_outlined,
                                onPressed: () => _showPreviewMessage(
                                  'Run settings preview is coming soon.',
                                ),
                              )
                            : const SizedBox(
                                key: ValueKey('settings_button_hidden'),
                                width: 48,
                                height: 48,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: _sheetProgress > 0.01 && _sheetProgress < 1
                ? -((_expandedRunSheetHeight - _collapsedRunSheetHeight) *
                      (1 - _sheetProgress))
                : 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: _recenterButtonSize + _sheetAdjacentRecenterGap,
                      ),
                      child: AnimatedSize(
                        duration: _sheetExtentAnimationDuration,
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.bottomCenter,
                        child: _RunBottomSheetShell(
                          key: const Key('runLaunchBottomSheet'),
                          bottomInset: bottomInset,
                          mode: _sheetMode,
                          extent: _sheetExtent,
                          sheetProgress: _sheetProgress,
                          onHandleTap: _toggleSheetExtent,
                          onVerticalDragStart: _handleSheetDragStart,
                          onVerticalDragUpdate: _handleSheetDragUpdate,
                          onVerticalDragEnd: _handleSheetDragEnd,
                          onVerticalDragCancel: _handleSheetDragCancel,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              final offsetAnimation =
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.025),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                      reverseCurve: Curves.easeInCubic,
                                    ),
                                  );

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: _sheetMode == RunSheetMode.preRun
                                ? AnimatedBuilder(
                                    key: const ValueKey('preRunSheetContent'),
                                    animation: _controller,
                                    builder: (context, _) {
                                      final permissionStatus =
                                          _controller.locationPermissionStatus;
                                      final permissionMessage =
                                          permissionStatus.canStartRun ||
                                              permissionStatus ==
                                                  RunLocationPermissionStatus
                                                      .checking
                                          ? null
                                          : permissionStatus.message;

                                      return _PreRunSheetContent(
                                        permissionMessage: permissionMessage,
                                        plannedWorkout: widget.plannedWorkout,
                                        onStart: _startRun,
                                        onSwitchRoute: () => _showPreviewMessage(
                                          'Route switching preview is coming soon.',
                                        ),
                                      );
                                    },
                                  )
                                : AnimatedBuilder(
                                    key: const ValueKey('trackingSheetContent'),
                                    animation: _controller,
                                    builder: (context, _) {
                                      return RunTrackingSheetContent(
                                        state: _controller.state,
                                        onPause: _pauseRun,
                                        onResume: _resumeRun,
                                        onEnd: _finishRun,
                                        isCompletingRun: _isCompletingRun,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Positioned(
                          top: 0,
                          right: _launchRecenterRightPadding,
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

class _MapCircleButton extends StatefulWidget {
  const _MapCircleButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_MapCircleButton> createState() => _MapCircleButtonState();
}

class _MapCircleButtonState extends State<_MapCircleButton> {
  bool _pressed = false;
  bool _activating = false;

  bool get _visuallyPressed => _pressed || _activating;

  void _setPressed(bool pressed) {
    if (!mounted || _pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }

  Future<void> _handleTap() async {
    setState(() => _activating = true);
    await Future<void>.delayed(_controlPressHold);
    if (!mounted) {
      return;
    }
    setState(() {
      _activating = false;
      _pressed = false;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: _visuallyPressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Material(
          color: _visuallyPressed ? const Color(0xFFE8EEFF) : Colors.white,
          elevation: 8,
          shadowColor: const Color(0x33172033),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkResponse(
            onTap: _handleTap,
            onHighlightChanged: _setPressed,
            containedInkWell: true,
            customBorder: const CircleBorder(),
            radius: 34,
            splashColor: const Color(0x1A3151C8),
            highlightColor: const Color(0x143151C8),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(widget.icon, color: _panelTextBlue, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _RunStatusPill extends StatelessWidget {
  const _RunStatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _softControlBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: _sportOrange, size: 14),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: RuniacColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunBottomSheetShell extends StatelessWidget {
  const _RunBottomSheetShell({
    super.key,
    required this.bottomInset,
    required this.mode,
    required this.extent,
    required this.sheetProgress,
    required this.onHandleTap,
    required this.onVerticalDragStart,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
    required this.onVerticalDragCancel,
    required this.child,
  });

  final double bottomInset;
  final RunSheetMode mode;
  final RunLaunchSheetExtent extent;
  final double sheetProgress;
  final VoidCallback onHandleTap;
  final GestureDragStartCallback onVerticalDragStart;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final GestureDragCancelCallback onVerticalDragCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final collapsed = extent == RunLaunchSheetExtent.collapsed;
        final contentVisible = sheetProgress > 0.01;
        final horizontalPadding = mode == RunSheetMode.preRun
            ? (compact ? 22.0 : 28.0)
            : 24.0;
        const topPadding = 0.0;
        final bottomPadding =
            bottomInset +
            (collapsed
                ? 0.0
                : mode == RunSheetMode.preRun
                ? (compact ? 18.0 : 22.0)
                : (compact ? 18.0 : 22.0));

        return Container(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26172033),
                blurRadius: 26,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                key: const Key('runLaunchSheetHandleArea'),
                behavior: HitTestBehavior.opaque,
                onTap: onHandleTap,
                onVerticalDragStart: onVerticalDragStart,
                onVerticalDragUpdate: onVerticalDragUpdate,
                onVerticalDragEnd: onVerticalDragEnd,
                onVerticalDragCancel: onVerticalDragCancel,
                child: const SizedBox(
                  height: _collapsedRunSheetHeight,
                  child: Center(
                    child: RuniacBottomSheetHandle(
                      key: Key('runLaunchSheetHandle'),
                      semanticLabel: 'Run launch sheet handle',
                    ),
                  ),
                ),
              ),
              if (collapsed) ...[
                const SizedBox.shrink(
                  key: Key('runLaunchSheetCollapsedContent'),
                ),
              ],
              Offstage(offstage: collapsed || !contentVisible, child: child),
            ],
          ),
        );
      },
    );
  }
}

class _PreRunSheetContent extends StatelessWidget {
  const _PreRunSheetContent({
    this.permissionMessage,
    this.plannedWorkout,
    required this.onStart,
    required this.onSwitchRoute,
  });

  final String? permissionMessage;
  final PlannedRunContext? plannedWorkout;
  final VoidCallback onStart;
  final VoidCallback onSwitchRoute;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final startHeight = compact ? 56.0 : 66.0;
        final planned = plannedWorkout;
        final planLabel =
            planned?.title.toUpperCase() ?? runLaunchDemoSnapshot.planLabel;
        final primaryValue =
            planned?.durationLabel ?? runLaunchDemoSnapshot.distanceValue;
        final primaryUnit =
            planned?.workoutKindLabel ??
            runLaunchDemoSnapshot.distanceUnitLabel;
        final supportLabel =
            planned?.planTitle ?? runLaunchDemoSnapshot.paceLabel;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    planLabel,
                    style: const TextStyle(
                      color: _sportOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: onSwitchRoute,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _panelTextBlue,
                    side: const BorderSide(color: _blueBorder),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(runLaunchDemoSnapshot.switchRouteLabel),
                ),
              ],
            ),
            SizedBox(height: compact ? 16 : 22),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              runSpacing: 2,
              children: [
                Text(
                  primaryValue,
                  style: const TextStyle(
                    color: _panelTextBlue,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    primaryUnit,
                    style: const TextStyle(
                      color: _mutedBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              supportLabel,
              style: const TextStyle(
                color: _mutedBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (planned case final workout?) ...[
              const SizedBox(height: 8),
              Text(
                workout.supportiveNote,
                style: const TextStyle(
                  color: _mutedBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (permissionMessage case final message?) ...[
              SizedBox(height: compact ? 12 : 14),
              _RunPermissionGuidance(message: message),
            ],
            SizedBox(height: compact ? 18 : 24),
            SizedBox(
              width: double.infinity,
              height: startHeight,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
                label: Text(runLaunchDemoSnapshot.startLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: _sportOrange,
                  foregroundColor: RuniacColors.white,
                  elevation: 8,
                  shadowColor: _orangeShadow,
                  textStyle: TextStyle(
                    fontSize: compact ? 24 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RunPermissionGuidance extends StatelessWidget {
  const _RunPermissionGuidance({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('runPermissionGuidance'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: _sportOrange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: _panelTextBlue,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.28,
            ),
          ),
        ),
      ],
    );
  }
}
