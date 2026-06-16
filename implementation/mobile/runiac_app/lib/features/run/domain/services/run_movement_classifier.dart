import '../models/run_location_sample.dart';
import '../models/run_motion_evidence.dart';

enum RunMovementClassificationType {
  gpsMeaningfulMovement,
  gpsStationaryDrift,
  noSampleStationaryDwell,
  noSampleWaiting,
}

class RunMovementClassification {
  const RunMovementClassification({
    required this.type,
    required this.acceptForDistance,
    required this.acceptForRoute,
    required this.countsAsMovingTime,
    required this.shouldAutoPause,
    required this.shouldAutoResume,
  });

  final RunMovementClassificationType type;
  final bool acceptForDistance;
  final bool acceptForRoute;
  final bool countsAsMovingTime;
  final bool shouldAutoPause;
  final bool shouldAutoResume;
}

class RunMovementClassifier {
  const RunMovementClassifier();

  RunMovementClassification classifyGpsSample({
    required RunLocationSample sample,
    required double distanceFromRouteAnchorMeters,
    required Duration stationaryDwell,
    required Duration autoPauseDwell,
    required double stationaryDriftDistanceMeters,
    required double resumeMovementDistanceMeters,
    required double resumeSpeedMetersPerSecond,
    required double stationarySpeedMetersPerSecond,
    Iterable<RunMotionEvidence> motionEvidence = const <RunMotionEvidence>[],
  }) {
    if (_hasMeaningfulMovement(
      sample: sample,
      distanceFromRouteAnchorMeters: distanceFromRouteAnchorMeters,
      resumeMovementDistanceMeters: resumeMovementDistanceMeters,
      resumeSpeedMetersPerSecond: resumeSpeedMetersPerSecond,
    )) {
      return const RunMovementClassification(
        type: RunMovementClassificationType.gpsMeaningfulMovement,
        acceptForDistance: true,
        acceptForRoute: true,
        countsAsMovingTime: true,
        shouldAutoPause: false,
        shouldAutoResume: true,
      );
    }

    final hasMovingSpeedSignal = _hasMovingSpeedSignal(
      sample,
      stationarySpeedMetersPerSecond,
    );
    final shouldAutoPause =
        !hasMovingSpeedSignal &&
        distanceFromRouteAnchorMeters <= stationaryDriftDistanceMeters &&
        stationaryDwell >= autoPauseDwell;
    return RunMovementClassification(
      type: RunMovementClassificationType.gpsStationaryDrift,
      acceptForDistance: false,
      acceptForRoute: false,
      countsAsMovingTime: !shouldAutoPause,
      shouldAutoPause: shouldAutoPause,
      shouldAutoResume: false,
    );
  }

  RunMovementClassification classifyNoSampleWindow({
    required Duration dwell,
    required Duration autoPauseDwell,
    required Duration anchorAge,
    required Duration maxAnchorAge,
    required bool hasAcceptedAnchor,
    required bool gpsStatusAllowsDwell,
    Iterable<RunMotionEvidence> motionEvidence = const <RunMotionEvidence>[],
  }) {
    final shouldAutoPause =
        hasAcceptedAnchor &&
        gpsStatusAllowsDwell &&
        anchorAge <= maxAnchorAge &&
        dwell >= autoPauseDwell;
    return RunMovementClassification(
      type: shouldAutoPause
          ? RunMovementClassificationType.noSampleStationaryDwell
          : RunMovementClassificationType.noSampleWaiting,
      acceptForDistance: false,
      acceptForRoute: false,
      countsAsMovingTime: !shouldAutoPause,
      shouldAutoPause: shouldAutoPause,
      shouldAutoResume: false,
    );
  }

  bool _hasMeaningfulMovement({
    required RunLocationSample sample,
    required double distanceFromRouteAnchorMeters,
    required double resumeMovementDistanceMeters,
    required double resumeSpeedMetersPerSecond,
  }) {
    final reportedSpeed = sample.speedMetersPerSecond;
    final hasSpeedSignal =
        reportedSpeed != null &&
        reportedSpeed.isFinite &&
        reportedSpeed >= resumeSpeedMetersPerSecond;
    return distanceFromRouteAnchorMeters >= resumeMovementDistanceMeters ||
        hasSpeedSignal;
  }

  bool _hasMovingSpeedSignal(
    RunLocationSample sample,
    double stationarySpeedMetersPerSecond,
  ) {
    final reportedSpeed = sample.speedMetersPerSecond;
    return reportedSpeed != null &&
        reportedSpeed.isFinite &&
        reportedSpeed >= stationarySpeedMetersPerSecond;
  }
}
