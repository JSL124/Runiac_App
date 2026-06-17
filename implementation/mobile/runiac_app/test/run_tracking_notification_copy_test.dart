import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_diagnostics.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_notification_copy.dart';
import 'package:runiac_app/features/run/domain/models/run_tracking_state.dart';

void main() {
  group('RunTrackingNotificationCopy', () {
    RunTrackingState state({
      RunTrackingPhase phase = RunTrackingPhase.active,
      RunMovementStatus movementStatus = RunMovementStatus.moving,
      RunTrackingLocationStatus locationStatus =
          RunTrackingLocationStatus.gpsActive,
    }) {
      return RunTrackingState(
        phase: phase,
        clientRunSessionId: 'notification-copy-run',
        startedAt: DateTime.utc(2026, 6, 17, 8),
        completedAt: null,
        elapsedSeconds: 125,
        distanceMeters: 620,
        averagePaceSecondsPerKm: 0,
        routePrivacy: 'private',
        source: 'local_gps',
        locationStatus: locationStatus,
        diagnostics: const RunTrackingDiagnostics.initial(),
        movementStatus: movementStatus,
      );
    }

    test('formats active GPS copy with elapsed time and distance', () {
      final copy = RunTrackingNotificationCopy.fromState(state());

      expect(copy.title, 'Runiac is tracking your run');
      expect(copy.body, 'GPS active • 02:05 • 0.62 km');
    });

    test('formats waiting and weak GPS copy without shaming language', () {
      final waiting = RunTrackingNotificationCopy.fromState(
        state(locationStatus: RunTrackingLocationStatus.waitingForGps),
      );
      final weak = RunTrackingNotificationCopy.fromState(
        state(locationStatus: RunTrackingLocationStatus.gpsWeak),
      );

      expect(waiting.title, 'Getting GPS ready');
      expect(waiting.body, 'Keep moving in an open area');
      expect(weak.title, 'Runiac is tracking your run');
      expect(weak.body, 'GPS signal weak • Keep the app nearby');
    });

    test('formats manual auto and abnormal paused states', () {
      final manual = RunTrackingNotificationCopy.fromState(
        state(phase: RunTrackingPhase.paused),
      );
      final autoPaused = RunTrackingNotificationCopy.fromState(
        state(movementStatus: RunMovementStatus.autoPaused),
      );
      final abnormalPaused = RunTrackingNotificationCopy.fromState(
        state(movementStatus: RunMovementStatus.abnormalPaused),
      );

      expect(manual.title, 'Run paused');
      expect(manual.body, 'Tracking is paused until you resume');
      expect(autoPaused.title, 'Run auto-paused');
      expect(autoPaused.body, 'Move again to continue tracking');
      expect(abnormalPaused.title, 'Tracking paused');
      expect(
        abnormalPaused.body,
        'Unusual movement detected. Resume when ready',
      );
    });

    test('formats approximate location copy', () {
      final copy = RunTrackingNotificationCopy.fromState(
        state(locationStatus: RunTrackingLocationStatus.approximateLocation),
      );

      expect(copy.title, 'Runiac is tracking your run');
      expect(copy.body, 'Approximate location • Distance may be less precise');
    });
  });
}
