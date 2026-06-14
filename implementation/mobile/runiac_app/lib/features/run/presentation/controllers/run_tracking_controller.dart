import 'package:flutter/foundation.dart';

import '../../domain/models/local_run_completion_payload.dart';
import '../../domain/models/run_tracking_state.dart';

class RunTrackingController extends ChangeNotifier {
  RunTrackingController({this.metersPerSecond = 2.4});

  final double metersPerSecond;

  RunTrackingState _state = const RunTrackingState.idle();
  int _sessionSequence = 0;

  RunTrackingState get state => _state;

  void start({
    DateTime? startedAt,
    String? clientRunSessionId,
    String routePrivacy = 'private',
    String? routeLabel,
  }) {
    _sessionSequence += 1;
    _state = RunTrackingState(
      phase: RunTrackingPhase.active,
      clientRunSessionId:
          clientRunSessionId ?? 'local-run-${_sessionSequence.toString()}',
      startedAt: startedAt ?? DateTime.now(),
      completedAt: null,
      elapsedSeconds: 0,
      distanceMeters: 0,
      averagePaceSecondsPerKm: 0,
      routePrivacy: routePrivacy,
      routeLabel: routeLabel,
      source: 'local_simulation',
    );
    notifyListeners();
  }

  void advanceBy(Duration delta) {
    if (!_state.isActive || delta <= Duration.zero) {
      return;
    }

    final elapsedSeconds = _state.elapsedSeconds + delta.inSeconds;
    final distanceMeters = (elapsedSeconds * metersPerSecond).round();
    final averagePaceSecondsPerKm = distanceMeters <= 0
        ? 0
        : (elapsedSeconds / (distanceMeters / 1000)).floor();

    _state = _state.copyWith(
      elapsedSeconds: elapsedSeconds,
      distanceMeters: distanceMeters,
      averagePaceSecondsPerKm: averagePaceSecondsPerKm,
    );
    notifyListeners();
  }

  void pause() {
    if (!_state.isActive) {
      return;
    }

    _state = _state.copyWith(phase: RunTrackingPhase.paused);
    notifyListeners();
  }

  void resume() {
    if (!_state.isPaused) {
      return;
    }

    _state = _state.copyWith(phase: RunTrackingPhase.active);
    notifyListeners();
  }

  LocalRunCompletionPayload finish({DateTime? completedAt}) {
    final startedAt = _state.startedAt;
    if (startedAt == null || _state.phase == RunTrackingPhase.idle) {
      throw StateError('Cannot finish a run before it starts.');
    }

    final finishedAt = completedAt ?? DateTime.now();
    final payload = LocalRunCompletionPayload(
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

    _state = _state.copyWith(
      phase: RunTrackingPhase.finished,
      completedAt: finishedAt,
    );
    notifyListeners();

    return payload;
  }
}
