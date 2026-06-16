import '../models/run_location_sample.dart';
import '../models/run_map_view_state.dart';
import '../models/run_tracking_diagnostics.dart';
import '../models/run_tracking_state.dart';
import 'run_distance_calculator.dart';

class LocalRunTrackingSession {
  LocalRunTrackingSession({
    required this.startedAt,
    this.source = 'local_simulation',
    this.distanceCalculator = const RunDistanceCalculator(),
    this.maxAcceptedSpeedMetersPerSecond = 12,
    this.maxAcceptedHorizontalAccuracyMeters = 100,
    this.autoPauseDwell = const Duration(seconds: 10),
    this.stationaryDriftDistanceMeters = 3,
    this.resumeMovementDistanceMeters = 6,
    this.resumeSpeedMetersPerSecond = 1,
    this.stationarySpeedMetersPerSecond = 0.5,
  });

  final DateTime startedAt;
  final String source;
  final double maxAcceptedSpeedMetersPerSecond;
  final double maxAcceptedHorizontalAccuracyMeters;
  final Duration autoPauseDwell;
  final double stationaryDriftDistanceMeters;
  final double resumeMovementDistanceMeters;
  final double resumeSpeedMetersPerSecond;
  final double stationarySpeedMetersPerSecond;
  final RunDistanceCalculator distanceCalculator;

  bool _isActive = true;
  bool _needsAnchorSample = false;
  int _movingDurationSeconds = 0;
  int _trackingDurationSeconds = 0;
  double _distanceMeters = 0;
  RunMovementStatus _movementStatus = RunMovementStatus.moving;
  bool _hasRecordedMovement = false;
  RunTrackingDiagnostics _diagnostics = const RunTrackingDiagnostics.initial();
  RunLocationSample? _currentPositionSample;
  RunLocationSample? _lastAcceptedSample;
  RunLocationSample? _lastRouteSample;
  DateTime? _stationaryStartedAt;
  final List<List<RunLocationSample>> _acceptedSampleSegments =
      <List<RunLocationSample>>[];

  int get activeDurationSeconds => _movingDurationSeconds;
  int get trackingDurationSeconds => _trackingDurationSeconds;
  int get distanceMeters => _distanceMeters.round();
  int get acceptedSampleCount => _diagnostics.acceptedSampleCount;
  int get rejectedSampleCount => _diagnostics.rejectedSampleCount;
  RunMovementStatus get movementStatus => _movementStatus;
  RunTrackingDiagnostics get diagnostics => _diagnostics;
  RunMapViewState get mapViewState {
    return RunMapViewState(
      currentPosition: _currentPositionSample,
      routeSegments: _acceptedSampleSegments,
    );
  }

  int get averagePaceSecondsPerKm {
    if (_distanceMeters <= 0) {
      return 0;
    }
    return (_movingDurationSeconds / (_distanceMeters / 1000)).floor();
  }

  void advanceBy(
    Duration delta, {
    Iterable<RunLocationSample> samples = const <RunLocationSample>[],
  }) {
    if (!_isActive || delta <= Duration.zero) {
      return;
    }

    final movementStatusBeforeAdvance = _movementStatus;
    final distanceBeforeAdvance = _distanceMeters;
    _trackingDurationSeconds += delta.inSeconds;
    for (final sample in samples) {
      _acceptSample(sample);
    }

    final becameAutoPausedWithoutDistance =
        movementStatusBeforeAdvance == RunMovementStatus.moving &&
        _movementStatus == RunMovementStatus.autoPaused &&
        _distanceMeters == distanceBeforeAdvance;
    if (movementStatusBeforeAdvance == RunMovementStatus.moving &&
        !becameAutoPausedWithoutDistance) {
      _movingDurationSeconds += delta.inSeconds;
    }
  }

  void pause() {
    _isActive = false;
  }

  void resume() {
    _isActive = true;
    _needsAnchorSample = true;
    _movementStatus = RunMovementStatus.moving;
    _stationaryStartedAt = null;
  }

  void updateLocationAccuracyStatus(
    RunTrackingLocationAccuracyStatus locationAccuracyStatus,
  ) {
    _diagnostics = _diagnostics.withLocationAccuracyStatus(
      locationAccuracyStatus,
    );
  }

  void _acceptSample(RunLocationSample sample) {
    _diagnostics = _diagnostics.recordSampleReceived(sample);

    final rejectionReason = _sampleRejectionReason(sample);
    if (rejectionReason != RunLocationRejectionReason.none) {
      _rejectSample(sample, rejectionReason);
      return;
    }

    final previous = _lastAcceptedSample;
    if (previous == null) {
      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _recordAcceptedCurrentSample(sample);
      _lastRouteSample = sample;
      return;
    }

    if (_needsAnchorSample) {
      if (_isSameSample(previous, sample)) {
        return;
      }

      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _needsAnchorSample = false;
      _lastRouteSample = sample;
      _recordAcceptedCurrentSample(sample);
      return;
    }

    _acceptMovementSample(sample);
  }

  bool _acceptMovementSample(RunLocationSample sample) {
    final previousAccepted = _lastAcceptedSample;
    if (previousAccepted != null &&
        !sample.recordedAt.isAfter(previousAccepted.recordedAt)) {
      _rejectSample(
        sample,
        RunLocationRejectionReason.duplicateOrOutOfOrderTimestamp,
      );
      return false;
    }

    final previousRouteSample = _lastRouteSample ?? previousAccepted;
    if (previousRouteSample == null) {
      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _lastRouteSample = sample;
      _recordAcceptedCurrentSample(sample);
      return true;
    }

    final elapsedSeconds =
        sample.recordedAt
            .difference(previousRouteSample.recordedAt)
            .inMilliseconds /
        1000;
    if (elapsedSeconds <= 0) {
      _rejectSample(
        sample,
        RunLocationRejectionReason.duplicateOrOutOfOrderTimestamp,
      );
      return false;
    }
    final segmentDistanceMeters = distanceCalculator.distanceMeters(
      previousRouteSample,
      sample,
    );
    if (!segmentDistanceMeters.isFinite) {
      _rejectSample(sample, RunLocationRejectionReason.nonFiniteDistance);
      return false;
    }

    final speedMetersPerSecond = segmentDistanceMeters / elapsedSeconds;
    if (speedMetersPerSecond > maxAcceptedSpeedMetersPerSecond) {
      _rejectSample(sample, RunLocationRejectionReason.impossibleJump);
      return false;
    }

    if (_hasMeaningfulMovement(sample, segmentDistanceMeters)) {
      if (_movementStatus == RunMovementStatus.autoPaused) {
        _acceptedSampleSegments.add(<RunLocationSample>[sample]);
        _lastRouteSample = sample;
      } else {
        _appendRouteSample(sample, segmentDistanceMeters);
      }
      _movementStatus = RunMovementStatus.moving;
      _hasRecordedMovement = true;
      _stationaryStartedAt = null;
      _recordAcceptedCurrentSample(sample);
      return true;
    }

    _recordStationarySample(sample, segmentDistanceMeters);
    return true;
  }

  void _appendRouteSample(
    RunLocationSample sample,
    double segmentDistanceMeters,
  ) {
    _distanceMeters += segmentDistanceMeters;
    if (_acceptedSampleSegments.isEmpty) {
      final previousRouteSample = _lastRouteSample;
      if (previousRouteSample != null) {
        _acceptedSampleSegments.add(<RunLocationSample>[previousRouteSample]);
      } else {
        _acceptedSampleSegments.add(<RunLocationSample>[]);
      }
      _acceptedSampleSegments.last.add(sample);
    } else {
      _acceptedSampleSegments.last.add(sample);
    }
    _lastRouteSample = sample;
  }

  bool _hasMeaningfulMovement(
    RunLocationSample sample,
    double distanceFromRouteAnchorMeters,
  ) {
    final reportedSpeed = sample.speedMetersPerSecond;
    final hasSpeedSignal =
        reportedSpeed != null &&
        reportedSpeed.isFinite &&
        reportedSpeed >= resumeSpeedMetersPerSecond;
    return distanceFromRouteAnchorMeters >= resumeMovementDistanceMeters ||
        hasSpeedSignal;
  }

  void _recordStationarySample(
    RunLocationSample sample,
    double distanceFromRouteAnchorMeters,
  ) {
    _recordAcceptedCurrentSample(sample);
    if (_movementStatus == RunMovementStatus.autoPaused) {
      return;
    }

    _stationaryStartedAt ??= sample.recordedAt;
    final reportedSpeed = sample.speedMetersPerSecond;
    final hasMovingSpeedSignal =
        reportedSpeed != null &&
        reportedSpeed.isFinite &&
        reportedSpeed >= stationarySpeedMetersPerSecond;
    final stationaryDwell = sample.recordedAt.difference(_stationaryStartedAt!);
    if (!hasMovingSpeedSignal &&
        distanceFromRouteAnchorMeters <= stationaryDriftDistanceMeters &&
        stationaryDwell >= autoPauseDwell) {
      if (!_hasRecordedMovement) {
        _movingDurationSeconds = 0;
      }
      _movementStatus = RunMovementStatus.autoPaused;
    }
  }

  void _recordAcceptedCurrentSample(RunLocationSample sample) {
    _currentPositionSample = sample;
    _lastAcceptedSample = sample;
    _diagnostics = _diagnostics.recordAcceptedSample(sample);
  }

  bool _isSameSample(RunLocationSample? left, RunLocationSample right) {
    return left != null &&
        left.recordedAt == right.recordedAt &&
        left.latitude == right.latitude &&
        left.longitude == right.longitude;
  }

  void _rejectSample(
    RunLocationSample sample,
    RunLocationRejectionReason reason,
  ) {
    _diagnostics = _diagnostics.recordRejectedSample(sample, reason);
  }

  RunLocationRejectionReason _sampleRejectionReason(RunLocationSample sample) {
    if (sample.recordedAt.isBefore(startedAt)) {
      return RunLocationRejectionReason.staleTimestamp;
    }
    if (!sample.latitude.isFinite || !sample.longitude.isFinite) {
      return RunLocationRejectionReason.invalidCoordinate;
    }
    if (sample.latitude < -90 || sample.latitude > 90) {
      return RunLocationRejectionReason.invalidCoordinate;
    }
    if (sample.longitude < -180 || sample.longitude > 180) {
      return RunLocationRejectionReason.invalidCoordinate;
    }

    final horizontalAccuracyMeters = sample.horizontalAccuracyMeters;
    if (horizontalAccuracyMeters == null) {
      return RunLocationRejectionReason.none;
    }
    if (!horizontalAccuracyMeters.isFinite ||
        horizontalAccuracyMeters < 0 ||
        horizontalAccuracyMeters > maxAcceptedHorizontalAccuracyMeters) {
      return RunLocationRejectionReason.poorAccuracy;
    }
    return RunLocationRejectionReason.none;
  }
}
