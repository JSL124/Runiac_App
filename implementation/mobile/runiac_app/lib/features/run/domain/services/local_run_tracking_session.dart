import '../models/run_location_sample.dart';
import '../models/run_map_view_state.dart';
import 'run_distance_calculator.dart';

class LocalRunTrackingSession {
  LocalRunTrackingSession({
    required this.startedAt,
    this.source = 'local_simulation',
    this._distanceCalculator = const RunDistanceCalculator(),
    this.maxAcceptedSpeedMetersPerSecond = 12,
    this.maxAcceptedHorizontalAccuracyMeters = 100,
  });

  final DateTime startedAt;
  final String source;
  final double maxAcceptedSpeedMetersPerSecond;
  final double maxAcceptedHorizontalAccuracyMeters;
  final RunDistanceCalculator _distanceCalculator;

  bool _isActive = true;
  bool _needsAnchorSample = false;
  int _activeDurationSeconds = 0;
  double _distanceMeters = 0;
  int _acceptedSampleCount = 0;
  int _rejectedSampleCount = 0;
  RunLocationSample? _lastAcceptedSample;
  final List<List<RunLocationSample>> _acceptedSampleSegments =
      <List<RunLocationSample>>[];

  int get activeDurationSeconds => _activeDurationSeconds;
  int get distanceMeters => _distanceMeters.round();
  int get acceptedSampleCount => _acceptedSampleCount;
  int get rejectedSampleCount => _rejectedSampleCount;
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

  void _acceptSample(RunLocationSample sample) {
    if (!_isValidSample(sample)) {
      _rejectedSampleCount += 1;
      return;
    }

    final previous = _lastAcceptedSample;
    if (previous == null) {
      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _lastAcceptedSample = sample;
      _acceptedSampleCount += 1;
      return;
    }

    if (_needsAnchorSample) {
      if (_needsAnchorSample && _isSameSample(previous, sample)) {
        return;
      }

      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _lastAcceptedSample = sample;
      _needsAnchorSample = false;
      _acceptedSampleCount += 1;
      return;
    }

    _acceptSegment(previous, sample);
  }

  bool _acceptSegment(RunLocationSample previous, RunLocationSample sample) {
    final elapsedSeconds =
        sample.recordedAt.difference(previous.recordedAt).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      _rejectedSampleCount += 1;
      return false;
    }

    final segmentDistanceMeters = _distanceCalculator.distanceMeters(
      previous,
      sample,
    );
    if (!segmentDistanceMeters.isFinite) {
      _rejectedSampleCount += 1;
      return false;
    }

    final speedMetersPerSecond = segmentDistanceMeters / elapsedSeconds;
    if (speedMetersPerSecond > maxAcceptedSpeedMetersPerSecond) {
      _rejectedSampleCount += 1;
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
    _acceptedSampleCount += 1;
    return true;
  }

  bool _isSameSample(RunLocationSample? left, RunLocationSample right) {
    return left != null &&
        left.recordedAt == right.recordedAt &&
        left.latitude == right.latitude &&
        left.longitude == right.longitude;
  }

  bool _isValidSample(RunLocationSample sample) {
    if (sample.recordedAt.isBefore(startedAt)) {
      return false;
    }
    if (!sample.latitude.isFinite || !sample.longitude.isFinite) {
      return false;
    }
    if (sample.latitude < -90 || sample.latitude > 90) {
      return false;
    }
    if (sample.longitude < -180 || sample.longitude > 180) {
      return false;
    }

    final horizontalAccuracyMeters = sample.horizontalAccuracyMeters;
    if (horizontalAccuracyMeters == null) {
      return true;
    }
    return horizontalAccuracyMeters.isFinite &&
        horizontalAccuracyMeters >= 0 &&
        horizontalAccuracyMeters <= maxAcceptedHorizontalAccuracyMeters;
  }
}
