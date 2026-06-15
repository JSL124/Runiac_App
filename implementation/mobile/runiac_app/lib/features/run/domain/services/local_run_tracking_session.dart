import '../models/run_location_sample.dart';
import '../models/run_map_view_state.dart';
import '../models/run_tracking_diagnostics.dart';
import 'run_distance_calculator.dart';

class LocalRunTrackingSession {
  LocalRunTrackingSession({
    required this.startedAt,
    this.source = 'local_simulation',
    this.distanceCalculator = const RunDistanceCalculator(),
    this.maxAcceptedSpeedMetersPerSecond = 12,
    this.maxAcceptedHorizontalAccuracyMeters = 100,
  });

  final DateTime startedAt;
  final String source;
  final double maxAcceptedSpeedMetersPerSecond;
  final double maxAcceptedHorizontalAccuracyMeters;
  final RunDistanceCalculator distanceCalculator;

  bool _isActive = true;
  bool _needsAnchorSample = false;
  int _activeDurationSeconds = 0;
  double _distanceMeters = 0;
  RunTrackingDiagnostics _diagnostics = const RunTrackingDiagnostics.initial();
  RunLocationSample? _lastAcceptedSample;
  final List<List<RunLocationSample>> _acceptedSampleSegments =
      <List<RunLocationSample>>[];

  int get activeDurationSeconds => _activeDurationSeconds;
  int get distanceMeters => _distanceMeters.round();
  int get acceptedSampleCount => _diagnostics.acceptedSampleCount;
  int get rejectedSampleCount => _diagnostics.rejectedSampleCount;
  RunTrackingDiagnostics get diagnostics => _diagnostics;
  RunMapViewState get mapViewState {
    return RunMapViewState(
      currentPosition: _lastAcceptedSample,
      routeSegments: _acceptedSampleSegments,
    );
  }

  int get averagePaceSecondsPerKm {
    if (_distanceMeters <= 0) {
      return 0;
    }
    return (_activeDurationSeconds / (_distanceMeters / 1000)).floor();
  }

  void advanceBy(
    Duration delta, {
    Iterable<RunLocationSample> samples = const <RunLocationSample>[],
  }) {
    if (!_isActive || delta <= Duration.zero) {
      return;
    }

    _activeDurationSeconds += delta.inSeconds;
    for (final sample in samples) {
      _acceptSample(sample);
    }
  }

  void pause() {
    _isActive = false;
  }

  void resume() {
    _isActive = true;
    _needsAnchorSample = true;
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
      _lastAcceptedSample = sample;
      _diagnostics = _diagnostics.recordAcceptedSample(sample);
      return;
    }

    if (_needsAnchorSample) {
      if (_needsAnchorSample && _isSameSample(previous, sample)) {
        return;
      }

      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _lastAcceptedSample = sample;
      _needsAnchorSample = false;
      _diagnostics = _diagnostics.recordAcceptedSample(sample);
      return;
    }

    _acceptSegment(previous, sample);
  }

  bool _acceptSegment(RunLocationSample previous, RunLocationSample sample) {
    final elapsedSeconds =
        sample.recordedAt.difference(previous.recordedAt).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      _rejectSample(
        sample,
        RunLocationRejectionReason.duplicateOrOutOfOrderTimestamp,
      );
      return false;
    }

    final segmentDistanceMeters = distanceCalculator.distanceMeters(
      previous,
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

    _distanceMeters += segmentDistanceMeters;
    if (_acceptedSampleSegments.isEmpty) {
      _acceptedSampleSegments.add(<RunLocationSample>[previous]);
      _acceptedSampleSegments.last.add(sample);
    } else {
      _acceptedSampleSegments.last.add(sample);
    }
    _lastAcceptedSample = sample;
    _diagnostics = _diagnostics.recordAcceptedSample(sample);
    return true;
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
