import 'package:flutter/foundation.dart';

import '../../domain/models/local_run_completion_payload.dart';
import '../../domain/models/run_tracking_state.dart';
import '../../domain/repositories/run_location_provider.dart';
import '../../domain/services/local_run_tracking_session.dart';

class RunTrackingController extends ChangeNotifier {
  RunTrackingController({
    double metersPerSecond = 2.4,
    RunLocationProvider? locationProvider,
  }) : metersPerSecond = metersPerSecond,
       _locationProvider =
           locationProvider ??
           ConstantSpeedRunLocationProvider(metersPerSecond: metersPerSecond);

  final double metersPerSecond;
  final RunLocationProvider _locationProvider;

  RunTrackingState _state = const RunTrackingState.idle();
  LocalRunTrackingSession? _trackingSession;
  int _sessionSequence = 0;

  RunTrackingState get state => _state;

  void start({
    DateTime? startedAt,
    String? clientRunSessionId,
    String routePrivacy = 'private',
    String? routeLabel,
  }) {
    _sessionSequence += 1;
    final effectiveStartedAt = startedAt ?? DateTime.now();
    final session = LocalRunTrackingSession(startedAt: effectiveStartedAt);
    _trackingSession = session;
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
    );
    notifyListeners();
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

    final fromActiveOffset = Duration(seconds: session.activeDurationSeconds);
    final toActiveOffset = fromActiveOffset + delta;
    final samples = _locationProvider.samplesBetween(
      fromActiveOffset: fromActiveOffset,
      toActiveOffset: toActiveOffset,
      startedAt: startedAt,
    );
    session.advanceBy(delta, samples: samples);

    _state = _state.copyWith(
      elapsedSeconds: session.activeDurationSeconds,
      distanceMeters: session.distanceMeters,
      averagePaceSecondsPerKm: session.averagePaceSecondsPerKm,
    );
    notifyListeners();
  }

  void pause() {
    if (!_state.isActive) {
      return;
    }

    _trackingSession?.pause();
    _state = _state.copyWith(phase: RunTrackingPhase.paused);
    notifyListeners();
  }

  void resume() {
    if (!_state.isPaused) {
      return;
    }

    _trackingSession?.resume();
    _state = _state.copyWith(phase: RunTrackingPhase.active);
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
    _state = _state.copyWith(
      phase: RunTrackingPhase.finished,
      completedAt: payload.completedAt,
    );
    notifyListeners();

    return payload;
  }
}
