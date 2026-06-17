import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/local_run_completion_payload.dart';
import '../../domain/models/run_location_sample.dart';
import '../../domain/models/run_location_permission_status.dart';
import '../../domain/models/run_map_view_state.dart';
import '../../domain/models/run_tracking_diagnostics.dart';
import '../../domain/models/run_tracking_state.dart';
import '../../domain/repositories/run_location_permission_service.dart';
import '../../domain/repositories/run_location_provider.dart';
import '../../domain/repositories/run_motion_provider.dart';
import '../../domain/services/local_run_tracking_session.dart';

class RunTrackingController extends ChangeNotifier {
  RunTrackingController({
    double metersPerSecond = 2.4,
    RunLocationProvider? locationProvider,
    RunMotionProvider? motionProvider,
    this.permissionService,
    RunTrackingLocationStatus locationStatus = RunTrackingLocationStatus.demo,
    RunLocationSample? initialPreviewCurrentPosition,
  }) : metersPerSecond = metersPerSecond,
       _locationProvider =
           locationProvider ??
           ConstantSpeedRunLocationProvider(metersPerSecond: metersPerSecond),
       _motionProvider = motionProvider ?? const NoopRunMotionProvider(),
       _initialLocationStatus = locationStatus,
       _previewCurrentPosition = initialPreviewCurrentPosition;

  final double metersPerSecond;
  final RunLocationProvider _locationProvider;
  final RunMotionProvider _motionProvider;
  final RunLocationPermissionService? permissionService;
  final RunTrackingLocationStatus _initialLocationStatus;

  RunTrackingState _state = const RunTrackingState.idle();
  RunLocationPermissionStatus _locationPermissionStatus =
      RunLocationPermissionStatus.checking;
  LocalRunTrackingSession? _trackingSession;
  RunMapViewState _mapViewState = const RunMapViewState.empty();
  RunLocationSample? _previewCurrentPosition;
  int _sessionSequence = 0;
  RunTrackingLocationStatus _latestLocationStatus =
      RunTrackingLocationStatus.demo;

  RunTrackingState get state => _state;
  RunMapViewState get mapViewState {
    final activeCurrentPosition = _mapViewState.currentPosition;
    if (activeCurrentPosition != null || _previewCurrentPosition == null) {
      return _mapViewState;
    }
    return RunMapViewState(
      previewPosition: _previewCurrentPosition,
      currentPosition: _mapViewState.currentPosition,
      acceptedRouteSegments: _mapViewState.acceptedRouteSegments,
    );
  }

  RunLocationSample? get previewCurrentPosition => _previewCurrentPosition;
  RunLocationPermissionStatus get locationPermissionStatus =>
      _locationPermissionStatus;
  String get locationPermissionMessage => _locationPermissionStatus.message;

  void setPreviewCurrentPosition(RunLocationSample sample) {
    _previewCurrentPosition = sample;
    notifyListeners();
  }

  void start({
    DateTime? startedAt,
    String? clientRunSessionId,
    String routePrivacy = 'private',
    String? routeLabel,
  }) {
    final effectiveStartedAt = _startSession(
      startedAt: startedAt,
      clientRunSessionId: clientRunSessionId,
      routePrivacy: routePrivacy,
      routeLabel: routeLabel,
    );
    unawaited(_locationProvider.start(startedAt: effectiveStartedAt));
    unawaited(_motionProvider.start(startedAt: effectiveStartedAt));
    notifyListeners();
  }

  Future<bool> requestStart({
    DateTime? startedAt,
    String? clientRunSessionId,
    String routePrivacy = 'private',
    String? routeLabel,
  }) async {
    final service = permissionService;
    if (service == null) {
      start(
        startedAt: startedAt,
        clientRunSessionId: clientRunSessionId,
        routePrivacy: routePrivacy,
        routeLabel: routeLabel,
      );
      return true;
    }

    _locationPermissionStatus = RunLocationPermissionStatus.checking;
    notifyListeners();

    var permissionStatus = await service.checkStatus();
    if (permissionStatus == RunLocationPermissionStatus.denied) {
      permissionStatus = await service.requestPermission();
    }

    _locationPermissionStatus = permissionStatus;
    if (!permissionStatus.canStartRun) {
      notifyListeners();
      return false;
    }

    final effectiveStartedAt = _startSession(
      startedAt: startedAt,
      clientRunSessionId: clientRunSessionId,
      routePrivacy: routePrivacy,
      routeLabel: routeLabel,
    );
    await _locationProvider.start(startedAt: effectiveStartedAt);
    await _motionProvider.start(startedAt: effectiveStartedAt);
    notifyListeners();
    return true;
  }

  DateTime _startSession({
    DateTime? startedAt,
    String? clientRunSessionId,
    String routePrivacy = 'private',
    String? routeLabel,
  }) {
    _sessionSequence += 1;
    final effectiveStartedAt = startedAt ?? DateTime.now();
    final session = LocalRunTrackingSession(startedAt: effectiveStartedAt);
    _trackingSession = session;
    _mapViewState = const RunMapViewState.empty();
    _latestLocationStatus = _initialLocationStatus;
    _state = RunTrackingState(
      phase: RunTrackingPhase.active,
      clientRunSessionId:
          clientRunSessionId ?? 'local-run-${_sessionSequence.toString()}',
      startedAt: effectiveStartedAt,
      completedAt: null,
      elapsedSeconds: 0,
      distanceMeters: 0,
      averagePaceSecondsPerKm: 0,
      routePrivacy: routePrivacy,
      routeLabel: routeLabel,
      source: session.source,
      locationStatus: _initialLocationStatus,
      diagnostics: session.diagnostics,
    );
    return effectiveStartedAt;
  }

  void advanceBy(Duration delta) {
    if (!_state.isActive || delta <= Duration.zero) {
      return;
    }

    final session = _trackingSession;
    final startedAt = _state.startedAt;
    if (session == null || startedAt == null) {
      return;
    }

    final fromActiveOffset = Duration(seconds: session.trackingDurationSeconds);
    final toActiveOffset = fromActiveOffset + delta;
    final samples = _locationProvider
        .samplesBetween(
          fromActiveOffset: fromActiveOffset,
          toActiveOffset: toActiveOffset,
          startedAt: startedAt,
        )
        .toList();
    final motionEvidence = _motionProvider
        .evidenceBetween(
          fromTrackingOffset: fromActiveOffset,
          toTrackingOffset: toActiveOffset,
          startedAt: startedAt,
        )
        .toList();
    session.updateLocationAccuracyStatus(
      _locationProvider.locationAccuracyStatus,
    );
    session.advanceBy(delta, samples: samples, motionEvidence: motionEvidence);
    _latestLocationStatus = _locationStatusFor(session.diagnostics);

    _state = _state.copyWith(
      elapsedSeconds: session.activeDurationSeconds,
      distanceMeters: session.distanceMeters,
      averagePaceSecondsPerKm: session.averagePaceSecondsPerKm,
      locationStatus: _latestLocationStatus,
      diagnostics: session.diagnostics,
      movementStatus: session.movementStatus,
    );
    _mapViewState = session.mapViewState;
    notifyListeners();
  }

  RunTrackingLocationStatus _locationStatusFor(
    RunTrackingDiagnostics diagnostics,
  ) {
    if (_initialLocationStatus == RunTrackingLocationStatus.demo) {
      return RunTrackingLocationStatus.demo;
    }

    if (diagnostics.locationAccuracyStatus ==
        RunTrackingLocationAccuracyStatus.reduced) {
      return RunTrackingLocationStatus.approximateLocation;
    }

    final latestAcceptedAt = diagnostics.lastAcceptedSampleAt;
    final latestRejectedAt = diagnostics.lastRejectedSampleAt;
    if (latestAcceptedAt == null && latestRejectedAt == null) {
      return RunTrackingLocationStatus.waitingForGps;
    }
    if (diagnostics.lastRejectedSampleSequence >
        diagnostics.lastAcceptedSampleSequence) {
      return RunTrackingLocationStatus.gpsWeak;
    }
    return RunTrackingLocationStatus.gpsActive;
  }

  void pause() {
    if (!_state.isActive) {
      return;
    }

    _trackingSession?.pause();
    unawaited(_locationProvider.pause());
    unawaited(_motionProvider.pause());
    _state = _state.copyWith(phase: RunTrackingPhase.paused);
    notifyListeners();
  }

  void resume() {
    if (!_state.isPaused && !_state.isAutoPaused && !_state.isAbnormalPaused) {
      return;
    }

    final activeOffset = Duration(
      seconds:
          _trackingSession?.trackingDurationSeconds ?? _state.elapsedSeconds,
    );
    _trackingSession?.resume();
    unawaited(
      _locationProvider.resume(
        resumedAt: DateTime.now(),
        activeOffset: activeOffset,
      ),
    );
    unawaited(
      _motionProvider.resume(
        resumedAt: DateTime.now(),
        trackingOffset: activeOffset,
      ),
    );
    _state = _state.copyWith(
      phase: RunTrackingPhase.active,
      movementStatus: RunMovementStatus.moving,
    );
    notifyListeners();
  }

  LocalRunCompletionPayload completionPayload({DateTime? completedAt}) {
    final startedAt = _state.startedAt;
    if (startedAt == null || _state.phase == RunTrackingPhase.idle) {
      throw StateError('Cannot finish a run before it starts.');
    }

    final finishedAt = completedAt ?? DateTime.now();
    return LocalRunCompletionPayload(
      clientRunSessionId: _state.clientRunSessionId,
      startedAt: startedAt,
      completedAt: finishedAt,
      durationSeconds: _state.elapsedSeconds,
      distanceMeters: _state.distanceMeters,
      avgPaceSecondsPerKm: _state.averagePaceSecondsPerKm,
      source: _state.source,
      routePrivacy: _state.routePrivacy,
      routeLabel: _state.routeLabel,
    );
  }

  LocalRunCompletionPayload finish({DateTime? completedAt}) {
    final payload = completionPayload(completedAt: completedAt);
    unawaited(_locationProvider.stop());
    unawaited(_motionProvider.stop());
    _mapViewState = const RunMapViewState.empty();
    _previewCurrentPosition = null;
    _state = _state.copyWith(
      phase: RunTrackingPhase.finished,
      completedAt: payload.completedAt,
    );
    notifyListeners();

    return payload;
  }

  @override
  void dispose() {
    unawaited(_locationProvider.stop());
    unawaited(_motionProvider.stop());
    super.dispose();
  }
}
