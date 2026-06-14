enum RunTrackingPhase { idle, active, paused, finished }

class RunTrackingState {
  const RunTrackingState({
    required this.phase,
    required this.clientRunSessionId,
    required this.startedAt,
    required this.completedAt,
    required this.elapsedSeconds,
    required this.distanceMeters,
    required this.averagePaceSecondsPerKm,
    required this.routePrivacy,
    required this.source,
    this.routeLabel,
  });

  const RunTrackingState.idle()
    : phase = RunTrackingPhase.idle,
      clientRunSessionId = '',
      startedAt = null,
      completedAt = null,
      elapsedSeconds = 0,
      distanceMeters = 0,
      averagePaceSecondsPerKm = 0,
      routePrivacy = 'private',
      source = 'local_simulation',
      routeLabel = null;

  final RunTrackingPhase phase;
  final String clientRunSessionId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int elapsedSeconds;
  final int distanceMeters;
  final int averagePaceSecondsPerKm;
  final String routePrivacy;
  final String source;
  final String? routeLabel;

  bool get isPaused => phase == RunTrackingPhase.paused;
  bool get isActive => phase == RunTrackingPhase.active;

  RunTrackingState copyWith({
    RunTrackingPhase? phase,
    String? clientRunSessionId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? elapsedSeconds,
    int? distanceMeters,
    int? averagePaceSecondsPerKm,
    String? routePrivacy,
    String? source,
    String? routeLabel,
  }) {
    return RunTrackingState(
      phase: phase ?? this.phase,
      clientRunSessionId: clientRunSessionId ?? this.clientRunSessionId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      averagePaceSecondsPerKm:
          averagePaceSecondsPerKm ?? this.averagePaceSecondsPerKm,
      routePrivacy: routePrivacy ?? this.routePrivacy,
      source: source ?? this.source,
      routeLabel: routeLabel ?? this.routeLabel,
    );
  }
}
