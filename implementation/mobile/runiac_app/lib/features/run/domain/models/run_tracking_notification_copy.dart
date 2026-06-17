import 'run_tracking_state.dart';

class RunTrackingNotificationCopy {
  const RunTrackingNotificationCopy({required this.title, required this.body});

  factory RunTrackingNotificationCopy.fromState(RunTrackingState state) {
    if (state.isAbnormalPaused) {
      return const RunTrackingNotificationCopy(
        title: 'Tracking paused',
        body: 'Unusual movement detected. Resume when ready',
      );
    }

    if (state.isPaused) {
      return const RunTrackingNotificationCopy(
        title: 'Run paused',
        body: 'Tracking is paused until you resume',
      );
    }

    if (state.isAutoPaused) {
      return const RunTrackingNotificationCopy(
        title: 'Run auto-paused',
        body: 'Move again to continue tracking',
      );
    }

    return switch (state.locationStatus) {
      RunTrackingLocationStatus.waitingForGps =>
        const RunTrackingNotificationCopy(
          title: 'Getting GPS ready',
          body: 'Keep moving in an open area',
        ),
      RunTrackingLocationStatus.gpsWeak => const RunTrackingNotificationCopy(
        title: 'Runiac is tracking your run',
        body: 'GPS signal weak • Keep the app nearby',
      ),
      RunTrackingLocationStatus.approximateLocation =>
        const RunTrackingNotificationCopy(
          title: 'Runiac is tracking your run',
          body: 'Approximate location • Distance may be less precise',
        ),
      RunTrackingLocationStatus.gpsActive => RunTrackingNotificationCopy(
        title: 'Runiac is tracking your run',
        body:
            'GPS active • ${_formatElapsed(state.elapsedSeconds)} • '
            '${_formatDistance(state.distanceMeters)}',
      ),
      RunTrackingLocationStatus.demo => const RunTrackingNotificationCopy(
        title: 'Runiac demo run',
        body: 'Demo mode is active',
      ),
    };
  }

  static const gettingGpsReady = RunTrackingNotificationCopy(
    title: 'Getting GPS ready',
    body: 'Keep moving in an open area',
  );

  final String title;
  final String body;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RunTrackingNotificationCopy &&
            other.title == title &&
            other.body == body;
  }

  @override
  int get hashCode => Object.hash(title, body);
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
