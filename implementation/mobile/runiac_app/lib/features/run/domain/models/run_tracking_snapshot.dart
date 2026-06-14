import 'run_tracking_state.dart';

class RunTrackingSnapshot {
  const RunTrackingSnapshot({
    required this.elapsedTimeLabel,
    required this.distanceLabel,
    required this.averagePaceLabel,
    required this.guidance,
  });

  factory RunTrackingSnapshot.fromState(RunTrackingState state) {
    return RunTrackingSnapshot(
      elapsedTimeLabel: _formatElapsed(state.elapsedSeconds),
      distanceLabel: _formatDistance(state.distanceMeters),
      averagePaceLabel: _formatPace(state.averagePaceSecondsPerKm),
      guidance: state.isPaused
          ? 'You can pause anytime.'
          : state.elapsedSeconds < 30
          ? 'Easy effort is enough.'
          : 'Keep it comfortable.',
    );
  }

  final String elapsedTimeLabel;
  final String distanceLabel;
  final String averagePaceLabel;
  final String guidance;
}

String _formatElapsed(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainder.toString().padLeft(2, '0')}';
}

String _formatDistance(int meters) {
  final kilometers = meters / 1000;
  return '${kilometers.toStringAsFixed(2)} km';
}

String _formatPace(int secondsPerKm) {
  if (secondsPerKm <= 0) {
    return '--/km';
  }

  final minutes = secondsPerKm ~/ 60;
  final seconds = secondsPerKm % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}/km';
}
