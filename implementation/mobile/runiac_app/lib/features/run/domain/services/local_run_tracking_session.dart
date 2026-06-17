import '../models/run_location_sample.dart';
import '../models/run_map_view_state.dart';
import '../models/run_motion_evidence.dart';
import '../models/run_tracking_diagnostics.dart';
import '../models/run_tracking_state.dart';
import 'run_distance_calculator.dart';
import 'run_movement_classifier.dart';

class LocalRunTrackingSession {
  LocalRunTrackingSession({
    required this.startedAt,
    this.source = 'local_simulation',
    this.distanceCalculator = const RunDistanceCalculator(),
    this.maxAcceptedSpeedMetersPerSecond = 12,
    this.maxAcceptedHorizontalAccuracyMeters = 100,
    this.preMovementAutoPauseDwell = const Duration(seconds: 5),
    this.noSampleAutoPauseDwell = const Duration(seconds: 5),
    this.movingToStoppedAutoPauseDwell = const Duration(seconds: 7),
    this.stationaryDriftDistanceMeters = 3,
    this.resumeMovementDistanceMeters = 6,
    this.resumeSpeedMetersPerSecond = 1,
    this.stationarySpeedMetersPerSecond = 0.5,
    this.suspiciousSpeedMetersPerSecond = 4.5,
    this.abnormalTransportSpeedMetersPerSecond = 6.5,
    this.abnormalSustainedWindow = const Duration(seconds: 10),
    this.abnormalSustainedSampleCount = 3,
    this.normalResumeMinSpeedMetersPerSecond = 0.8,
    this.normalResumeMaxSpeedMetersPerSecond = 4.0,
    this.maxNoSampleStationaryAnchorAge = const Duration(seconds: 30),
    this.movementClassifier = const RunMovementClassifier(),
  });

  final DateTime startedAt;
  final String source;
  final double maxAcceptedSpeedMetersPerSecond;
  final double maxAcceptedHorizontalAccuracyMeters;
  final Duration preMovementAutoPauseDwell;
  final Duration noSampleAutoPauseDwell;
  final Duration movingToStoppedAutoPauseDwell;
  final double stationaryDriftDistanceMeters;
  final double resumeMovementDistanceMeters;
  final double resumeSpeedMetersPerSecond;
  final double stationarySpeedMetersPerSecond;
  final double suspiciousSpeedMetersPerSecond;
  final double abnormalTransportSpeedMetersPerSecond;
  final Duration abnormalSustainedWindow;
  final int abnormalSustainedSampleCount;
  final double normalResumeMinSpeedMetersPerSecond;
  final double normalResumeMaxSpeedMetersPerSecond;
  final Duration maxNoSampleStationaryAnchorAge;
  final RunDistanceCalculator distanceCalculator;
  final RunMovementClassifier movementClassifier;

  static const double _preMovementJitterCandidateMaxMeters = 25;

  bool _isActive = true;
  bool _needsAnchorSample = false;
  bool _suppressedMovementNeedsAnchor = false;
  int _movingDurationSeconds = 0;
  int _trackingDurationSeconds = 0;
  double _distanceMeters = 0;
  RunMovementStatus _movementStatus = RunMovementStatus.moving;
  RunTrackingDiagnostics _diagnostics = const RunTrackingDiagnostics.initial();
  RunLocationSample? _currentPositionSample;
  RunLocationSample? _lastAcceptedSample;
  RunLocationSample? _lastRouteSample;
  RunLocationSample? _autoResumeCandidateSample;
  RunLocationSample? _preMovementCandidateSample;
  RunLocationSample? _abnormalCandidateStartedSample;
  int _abnormalCandidateCount = 0;
  RunLocationSample? _abnormalResumeAnchorSample;
  int _abnormalResumeCandidateCount = 0;
  DateTime? _stationaryStartedAt;
  double _stationaryCumulativeMovementMeters = 0;
  bool _suppressedMovingTimeInCurrentAdvance = false;
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
    Iterable<RunMotionEvidence> motionEvidence = const <RunMotionEvidence>[],
  }) {
    if (!_isActive || delta <= Duration.zero) {
      return;
    }

    final movementStatusBeforeAdvance = _movementStatus;
    final distanceBeforeAdvance = _distanceMeters;
    final sampleList = samples.toList();
    final motionEvidenceList = motionEvidence.toList();
    _suppressedMovingTimeInCurrentAdvance = false;
    _trackingDurationSeconds += delta.inSeconds;
    for (final sample in sampleList) {
      _acceptSample(sample, motionEvidenceList);
    }
    if (sampleList.isEmpty) {
      _recordNoSampleDwell(motionEvidenceList);
    }

    final becameAutoPausedWithoutDistance =
        movementStatusBeforeAdvance == RunMovementStatus.moving &&
        _movementStatus == RunMovementStatus.autoPaused &&
        _distanceMeters == distanceBeforeAdvance;
    if (movementStatusBeforeAdvance == RunMovementStatus.moving &&
        _movementStatus == RunMovementStatus.moving &&
        !becameAutoPausedWithoutDistance &&
        !_suppressedMovingTimeInCurrentAdvance) {
      _movingDurationSeconds += delta.inSeconds;
    }
  }

  void pause() {
    _isActive = false;
  }

  void resume() {
    _isActive = true;
    _needsAnchorSample = true;
    _suppressedMovementNeedsAnchor = false;
    _movementStatus = RunMovementStatus.moving;
    _autoResumeCandidateSample = null;
    _preMovementCandidateSample = null;
    _resetAbnormalCandidate();
    _resetAbnormalResumeCandidate();
    _stationaryStartedAt = null;
    _stationaryCumulativeMovementMeters = 0;
  }

  void updateLocationAccuracyStatus(
    RunTrackingLocationAccuracyStatus locationAccuracyStatus,
  ) {
    _diagnostics = _diagnostics.withLocationAccuracyStatus(
      locationAccuracyStatus,
    );
  }

  void _acceptSample(
    RunLocationSample sample,
    Iterable<RunMotionEvidence> motionEvidence,
  ) {
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
      _autoResumeCandidateSample = null;
      _preMovementCandidateSample = null;
      _resetAbnormalCandidate();
      _resetAbnormalResumeCandidate();
      _stationaryCumulativeMovementMeters = 0;
      return;
    }

    if (_suppressedMovementNeedsAnchor) {
      if (_isSameSample(previous, sample)) {
        return;
      }
      if (_isSuppressedCandidateFromPrevious(previous, sample)) {
        _acceptMovementSample(sample, motionEvidence);
        return;
      }

      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _suppressedMovementNeedsAnchor = false;
      _lastRouteSample = sample;
      _autoResumeCandidateSample = null;
      _preMovementCandidateSample = null;
      _resetAbnormalCandidate();
      _resetAbnormalResumeCandidate();
      _stationaryCumulativeMovementMeters = 0;
      _recordAcceptedCurrentSample(sample);
      return;
    }

    if (_needsAnchorSample) {
      if (_isSameSample(previous, sample)) {
        return;
      }

      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _needsAnchorSample = false;
      _lastRouteSample = sample;
      _autoResumeCandidateSample = null;
      _preMovementCandidateSample = null;
      _resetAbnormalCandidate();
      _resetAbnormalResumeCandidate();
      _stationaryCumulativeMovementMeters = 0;
      _recordAcceptedCurrentSample(sample);
      return;
    }

    _acceptMovementSample(sample, motionEvidence);
  }

  bool _acceptMovementSample(
    RunLocationSample sample,
    Iterable<RunMotionEvidence> motionEvidence,
  ) {
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
    final resumeCandidateSample =
        _movementStatus == RunMovementStatus.autoPaused
        ? _autoResumeCandidateSample
        : null;
    final movementAnchorSample = resumeCandidateSample ?? previousRouteSample;
    if (previousRouteSample == null) {
      _acceptedSampleSegments.add(<RunLocationSample>[sample]);
      _lastRouteSample = sample;
      _autoResumeCandidateSample = null;
      _preMovementCandidateSample = null;
      _resetAbnormalCandidate();
      _resetAbnormalResumeCandidate();
      _stationaryCumulativeMovementMeters = 0;
      _recordAcceptedCurrentSample(sample);
      return true;
    }
    if (movementAnchorSample == null) {
      _recordAcceptedCurrentSample(sample);
      _autoResumeCandidateSample = sample;
      return true;
    }

    final elapsedSeconds =
        sample.recordedAt
            .difference(movementAnchorSample.recordedAt)
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
      movementAnchorSample,
      sample,
    );
    if (!segmentDistanceMeters.isFinite) {
      _rejectSample(sample, RunLocationRejectionReason.nonFiniteDistance);
      return false;
    }
    final previousAcceptedDistanceMeters = distanceCalculator.distanceMeters(
      previousAccepted ?? previousRouteSample,
      sample,
    );
    if (!previousAcceptedDistanceMeters.isFinite) {
      _rejectSample(sample, RunLocationRejectionReason.nonFiniteDistance);
      return false;
    }
    final previousAcceptedElapsedSeconds =
        sample.recordedAt
            .difference((previousAccepted ?? previousRouteSample).recordedAt)
            .inMilliseconds /
        1000;
    final usablePreviousAcceptedDistanceMeters =
        previousAcceptedElapsedSeconds > 0 &&
            previousAcceptedDistanceMeters / previousAcceptedElapsedSeconds <=
                maxAcceptedSpeedMetersPerSecond
        ? previousAcceptedDistanceMeters
        : 0;

    final calculatedSpeedMetersPerSecond =
        segmentDistanceMeters / elapsedSeconds;
    final hardRejectSpeedMetersPerSecond = _hardRejectSpeedMetersPerSecond(
      sample: sample,
      calculatedSpeedMetersPerSecond: calculatedSpeedMetersPerSecond,
    );
    if (hardRejectSpeedMetersPerSecond > maxAcceptedSpeedMetersPerSecond) {
      _rejectSample(sample, RunLocationRejectionReason.impossibleJump);
      return false;
    }
    final speedMetersPerSecond = _classificationSpeedMetersPerSecond(
      sample: sample,
      calculatedSpeedMetersPerSecond: calculatedSpeedMetersPerSecond,
    );

    final speedBand = movementClassifier.classifyMovementSpeed(
      speedMetersPerSecond: speedMetersPerSecond,
      suspiciousSpeedMetersPerSecond: suspiciousSpeedMetersPerSecond,
      abnormalSpeedMetersPerSecond: abnormalTransportSpeedMetersPerSecond,
      hardRejectSpeedMetersPerSecond: maxAcceptedSpeedMetersPerSecond,
      normalResumeMinSpeedMetersPerSecond: normalResumeMinSpeedMetersPerSecond,
      normalResumeMaxSpeedMetersPerSecond: normalResumeMaxSpeedMetersPerSecond,
    );
    if (speedBand == RunMovementSpeedBand.suspiciousCandidate ||
        speedBand == RunMovementSpeedBand.abnormalCandidate ||
        _movementStatus == RunMovementStatus.abnormalPaused) {
      _handleSuppressedMovementSample(
        sample: sample,
        speedBand: speedBand,
        segmentDistanceMeters: segmentDistanceMeters,
      );
      return true;
    }

    if (_shouldHoldPreMovementCandidate(
      sample: sample,
      segmentDistanceMeters: segmentDistanceMeters,
      speedMetersPerSecond: speedMetersPerSecond,
      motionEvidence: motionEvidence,
    )) {
      _handlePreMovementCandidate(
        sample: sample,
        routeAnchorSample: previousRouteSample,
        segmentDistanceMeters: segmentDistanceMeters,
        motionEvidence: motionEvidence,
      );
      return true;
    }

    final stationaryStartedAt =
        _stationaryStartedAt ?? previousRouteSample.recordedAt;
    final autoPauseDwell = _distanceMeters <= 0
        ? preMovementAutoPauseDwell
        : movingToStoppedAutoPauseDwell;
    final cumulativeGpsMovementMeters =
        _stationaryCumulativeMovementMeters +
        usablePreviousAcceptedDistanceMeters;
    final classification = movementClassifier.classifyGpsSample(
      sample: sample,
      distanceFromRouteAnchorMeters: segmentDistanceMeters,
      stationaryDwell: sample.recordedAt.difference(stationaryStartedAt),
      stationaryAutoPauseDwell: autoPauseDwell,
      stationaryDriftDistanceMeters: stationaryDriftDistanceMeters,
      cumulativeGpsMovementMeters: cumulativeGpsMovementMeters,
      movementSpeedMetersPerSecond: speedMetersPerSecond,
      resumeMovementDistanceMeters: resumeMovementDistanceMeters,
      resumeSpeedMetersPerSecond: resumeSpeedMetersPerSecond,
      stationarySpeedMetersPerSecond: stationarySpeedMetersPerSecond,
      requiresSustainedGpsMovement:
          _movementStatus == RunMovementStatus.autoPaused &&
          resumeCandidateSample == null,
      motionEvidence: motionEvidence,
    );

    if (classification.shouldAutoResume) {
      if (_movementStatus == RunMovementStatus.autoPaused) {
        final resumeAnchor = resumeCandidateSample ?? sample;
        _acceptedSampleSegments.add(<RunLocationSample>[resumeAnchor, sample]);
        _distanceMeters += segmentDistanceMeters;
        _lastRouteSample = sample;
      } else {
        _appendRouteSample(sample, segmentDistanceMeters);
      }
      _movementStatus = RunMovementStatus.moving;
      _autoResumeCandidateSample = null;
      _preMovementCandidateSample = null;
      _resetAbnormalCandidate();
      _resetAbnormalResumeCandidate();
      _stationaryStartedAt = null;
      _stationaryCumulativeMovementMeters = 0;
      _recordAcceptedCurrentSample(sample);
      return true;
    }

    if (_movementStatus == RunMovementStatus.autoPaused &&
        classification.type ==
            RunMovementClassificationType.gpsResumeCandidate) {
      _recordAcceptedCurrentSample(sample);
      _autoResumeCandidateSample = sample;
      return true;
    }

    _recordStationarySample(
      sample,
      classification,
      cumulativeGpsMovementMeters,
    );
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
    _autoResumeCandidateSample = null;
    _preMovementCandidateSample = null;
    _resetAbnormalCandidate();
    _resetAbnormalResumeCandidate();
    _stationaryCumulativeMovementMeters = 0;
  }

  void _handleSuppressedMovementSample({
    required RunLocationSample sample,
    required RunMovementSpeedBand speedBand,
    required double segmentDistanceMeters,
  }) {
    _suppressedMovingTimeInCurrentAdvance = true;
    _recordAcceptedCurrentSample(sample);
    _autoResumeCandidateSample = null;
    _preMovementCandidateSample = null;
    _stationaryStartedAt = null;
    _stationaryCumulativeMovementMeters = 0;

    if (_movementStatus == RunMovementStatus.abnormalPaused) {
      _handleAbnormalResumeCandidate(sample: sample, speedBand: speedBand);
      return;
    }

    _suppressedMovementNeedsAnchor = true;
    if (speedBand != RunMovementSpeedBand.abnormalCandidate) {
      _resetAbnormalCandidate();
      return;
    }

    _abnormalCandidateStartedSample ??= sample;
    _abnormalCandidateCount += 1;
    final startedAt = _abnormalCandidateStartedSample!.recordedAt;
    final sustainedByTime =
        sample.recordedAt.difference(startedAt) >= abnormalSustainedWindow;
    final sustainedBySamples =
        _abnormalCandidateCount >= abnormalSustainedSampleCount;
    if (sustainedByTime || sustainedBySamples) {
      _movementStatus = RunMovementStatus.abnormalPaused;
      _suppressedMovementNeedsAnchor = false;
      _resetAbnormalResumeCandidate();
    }
  }

  void _handleAbnormalResumeCandidate({
    required RunLocationSample sample,
    required RunMovementSpeedBand speedBand,
  }) {
    if (speedBand != RunMovementSpeedBand.normalResume) {
      _resetAbnormalResumeCandidate();
      if (speedBand != RunMovementSpeedBand.abnormalCandidate) {
        _resetAbnormalCandidate();
      }
      return;
    }

    final resumeAnchor = _abnormalResumeAnchorSample;
    if (resumeAnchor == null) {
      _abnormalResumeAnchorSample = sample;
      _abnormalResumeCandidateCount = 1;
      return;
    }

    final resumeDistanceMeters = distanceCalculator.distanceMeters(
      resumeAnchor,
      sample,
    );
    if (!resumeDistanceMeters.isFinite) {
      _rejectSample(sample, RunLocationRejectionReason.nonFiniteDistance);
      return;
    }

    _abnormalResumeCandidateCount += 1;
    if (_abnormalResumeCandidateCount < 2 ||
        resumeDistanceMeters < resumeMovementDistanceMeters) {
      return;
    }

    _acceptedSampleSegments.add(<RunLocationSample>[resumeAnchor, sample]);
    _distanceMeters += resumeDistanceMeters;
    _lastRouteSample = sample;
    _movementStatus = RunMovementStatus.moving;
    _suppressedMovingTimeInCurrentAdvance = false;
    _suppressedMovementNeedsAnchor = false;
    _preMovementCandidateSample = null;
    _resetAbnormalCandidate();
    _resetAbnormalResumeCandidate();
  }

  bool _shouldHoldPreMovementCandidate({
    required RunLocationSample sample,
    required double segmentDistanceMeters,
    required double speedMetersPerSecond,
    required Iterable<RunMotionEvidence> motionEvidence,
  }) {
    if (_distanceMeters > 0 || _movementStatus != RunMovementStatus.moving) {
      return false;
    }
    if (segmentDistanceMeters <= stationaryDriftDistanceMeters ||
        segmentDistanceMeters > _preMovementJitterCandidateMaxMeters) {
      return false;
    }
    if (speedMetersPerSecond.isFinite &&
        speedMetersPerSecond >= resumeSpeedMetersPerSecond) {
      return false;
    }
    final reportedSpeed = sample.speedMetersPerSecond;
    if (reportedSpeed != null && reportedSpeed.isFinite && reportedSpeed >= 0) {
      return reportedSpeed < resumeSpeedMetersPerSecond;
    }
    return _hasStationaryMotionEvidence(motionEvidence);
  }

  void _handlePreMovementCandidate({
    required RunLocationSample sample,
    required RunLocationSample routeAnchorSample,
    required double segmentDistanceMeters,
    required Iterable<RunMotionEvidence> motionEvidence,
  }) {
    _suppressedMovingTimeInCurrentAdvance = true;
    final candidate = _preMovementCandidateSample;
    if (candidate != null) {
      final candidateDistanceMeters = distanceCalculator.distanceMeters(
        candidate,
        sample,
      );
      final anchorToCandidateMeters = distanceCalculator.distanceMeters(
        routeAnchorSample,
        candidate,
      );
      if (!candidateDistanceMeters.isFinite ||
          !anchorToCandidateMeters.isFinite) {
        _rejectSample(sample, RunLocationRejectionReason.nonFiniteDistance);
        return;
      }

      final hasConsistentDisplacement =
          candidateDistanceMeters >= resumeMovementDistanceMeters &&
          segmentDistanceMeters >=
              anchorToCandidateMeters + resumeMovementDistanceMeters;
      if (hasConsistentDisplacement) {
        _acceptedSampleSegments.add(<RunLocationSample>[candidate, sample]);
        _distanceMeters += candidateDistanceMeters;
        _lastRouteSample = sample;
        _autoResumeCandidateSample = null;
        _preMovementCandidateSample = null;
        _resetAbnormalCandidate();
        _resetAbnormalResumeCandidate();
        _stationaryStartedAt = null;
        _stationaryCumulativeMovementMeters = 0;
        _recordAcceptedCurrentSample(sample);
        return;
      }
    }

    _preMovementCandidateSample = sample;
    _autoResumeCandidateSample = null;
    _recordAcceptedCurrentSample(sample);
    _stationaryStartedAt ??= routeAnchorSample.recordedAt;
    _stationaryCumulativeMovementMeters = 0;

    final dwell = sample.recordedAt.difference(_stationaryStartedAt!);
    if (dwell >= preMovementAutoPauseDwell &&
        !_hasMovingMotionEvidence(motionEvidence)) {
      _movementStatus = RunMovementStatus.autoPaused;
      _preMovementCandidateSample = null;
      _resetAbnormalCandidate();
      _resetAbnormalResumeCandidate();
    }
  }

  void _recordStationarySample(
    RunLocationSample sample,
    RunMovementClassification classification,
    double cumulativeGpsMovementMeters,
  ) {
    _recordAcceptedCurrentSample(sample);
    if (_movementStatus == RunMovementStatus.autoPaused) {
      return;
    }

    _stationaryStartedAt ??= _lastRouteSample?.recordedAt ?? sample.recordedAt;
    _stationaryCumulativeMovementMeters = cumulativeGpsMovementMeters;
    if (classification.shouldAutoPause) {
      _movementStatus = RunMovementStatus.autoPaused;
      _autoResumeCandidateSample = null;
      _preMovementCandidateSample = null;
      _resetAbnormalCandidate();
      _resetAbnormalResumeCandidate();
    }
  }

  void _recordNoSampleDwell(Iterable<RunMotionEvidence> motionEvidence) {
    final lastAcceptedSample = _lastAcceptedSample;
    if (_movementStatus == RunMovementStatus.autoPaused ||
        lastAcceptedSample == null) {
      return;
    }

    final currentTrackingAt = startedAt.add(
      Duration(seconds: _trackingDurationSeconds),
    );
    _stationaryStartedAt ??= lastAcceptedSample.recordedAt;
    final classification = movementClassifier.classifyNoSampleWindow(
      dwell: currentTrackingAt.difference(_stationaryStartedAt!),
      noSampleAutoPauseDwell: noSampleAutoPauseDwell,
      anchorAge: currentTrackingAt.difference(lastAcceptedSample.recordedAt),
      maxAnchorAge: maxNoSampleStationaryAnchorAge,
      hasAcceptedAnchor: _diagnostics.hasAcceptedSample,
      gpsStatusAllowsDwell:
          _diagnostics.lastRejectedSampleSequence <=
          _diagnostics.lastAcceptedSampleSequence,
      motionEvidence: motionEvidence,
    );
    if (!classification.shouldAutoPause) {
      return;
    }
    _movementStatus = RunMovementStatus.autoPaused;
    _autoResumeCandidateSample = null;
    _preMovementCandidateSample = null;
    _resetAbnormalCandidate();
    _resetAbnormalResumeCandidate();
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

  bool _isSuppressedCandidateFromPrevious(
    RunLocationSample previous,
    RunLocationSample sample,
  ) {
    final elapsedSeconds =
        sample.recordedAt.difference(previous.recordedAt).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      return false;
    }
    final distanceMeters = distanceCalculator.distanceMeters(previous, sample);
    if (!distanceMeters.isFinite) {
      return false;
    }
    final speedMetersPerSecond = _hardRejectSpeedMetersPerSecond(
      sample: sample,
      calculatedSpeedMetersPerSecond: distanceMeters / elapsedSeconds,
    );
    return speedMetersPerSecond >= suspiciousSpeedMetersPerSecond &&
        speedMetersPerSecond <= maxAcceptedSpeedMetersPerSecond;
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

  double _classificationSpeedMetersPerSecond({
    required RunLocationSample sample,
    required double calculatedSpeedMetersPerSecond,
  }) {
    final reportedSpeed = sample.speedMetersPerSecond;
    if (reportedSpeed != null && reportedSpeed.isFinite && reportedSpeed >= 0) {
      return reportedSpeed;
    }
    return calculatedSpeedMetersPerSecond;
  }

  double _hardRejectSpeedMetersPerSecond({
    required RunLocationSample sample,
    required double calculatedSpeedMetersPerSecond,
  }) {
    final reportedSpeed = sample.speedMetersPerSecond;
    if (reportedSpeed == null || !reportedSpeed.isFinite || reportedSpeed < 0) {
      return calculatedSpeedMetersPerSecond;
    }
    if (!calculatedSpeedMetersPerSecond.isFinite ||
        calculatedSpeedMetersPerSecond < 0) {
      return reportedSpeed;
    }
    return reportedSpeed > calculatedSpeedMetersPerSecond
        ? reportedSpeed
        : calculatedSpeedMetersPerSecond;
  }

  bool _hasMovingMotionEvidence(Iterable<RunMotionEvidence> motionEvidence) {
    RunMotionEvidence? latest;
    for (final evidence in motionEvidence) {
      if (latest == null || evidence.recordedAt.isAfter(latest.recordedAt)) {
        latest = evidence;
      }
    }
    return latest?.signal == RunMotionSignal.moving &&
        (latest?.confidence ?? 0) >= 0.6;
  }

  bool _hasStationaryMotionEvidence(
    Iterable<RunMotionEvidence> motionEvidence,
  ) {
    RunMotionEvidence? latest;
    for (final evidence in motionEvidence) {
      if (latest == null || evidence.recordedAt.isAfter(latest.recordedAt)) {
        latest = evidence;
      }
    }
    return latest?.signal == RunMotionSignal.stationary &&
        (latest?.confidence ?? 0) >= 0.6;
  }

  void _resetAbnormalCandidate() {
    _abnormalCandidateStartedSample = null;
    _abnormalCandidateCount = 0;
  }

  void _resetAbnormalResumeCandidate() {
    _abnormalResumeAnchorSample = null;
    _abnormalResumeCandidateCount = 0;
  }
}
