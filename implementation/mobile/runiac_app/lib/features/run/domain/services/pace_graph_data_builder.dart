import '../models/pace_graph_snapshot.dart';

const minGraphPaceSecondsPerKm = 150;
const maxGraphPaceSecondsPerKm = 1800;
const minVisiblePaceRangeSeconds = 80;
const maxPaceGraphDisplayPoints = 60;
const _shortRunBucketSeconds = 20;
const _mediumRunBucketSeconds = 30;
const _longRunBucketSeconds = 60;

class PaceGraphSample {
  const PaceGraphSample({
    required this.elapsedSeconds,
    required this.paceSecondsPerKm,
  });

  final int elapsedSeconds;
  final int paceSecondsPerKm;
}

class PaceGraphDataBuilder {
  const PaceGraphDataBuilder();

  PaceGraphSnapshot build({
    required List<PaceGraphSample> samples,
    required int durationSeconds,
    required int distanceMeters,
    int? averagePaceSecondsPerKm,
  }) {
    if (durationSeconds < 60 || distanceMeters < 50) {
      return const PaceGraphSnapshot.unavailable();
    }

    final validSamples = _validIncreasingSamples(
      samples,
      durationSeconds: durationSeconds,
    );
    if (validSamples.length < 3) {
      return const PaceGraphSnapshot.unavailable();
    }

    final displaySamples = _displaySamples(
      samples: validSamples,
      durationSeconds: durationSeconds,
    );
    final lineSamples = _validLineSamples(
      displaySamples,
      durationSeconds: durationSeconds,
    );
    if (lineSamples.length < 3) {
      return const PaceGraphSnapshot.unavailable();
    }

    final paceValues = lineSamples
        .map((sample) => sample.paceSecondsPerKm)
        .toList();
    final minPace = paceValues.reduce((a, b) => a < b ? a : b);
    final maxPace = paceValues.reduce((a, b) => a > b ? a : b);
    final paceRange = _paceAxisRange(minPace: minPace, maxPace: maxPace);
    final points = lineSamples.map((sample) {
      final progress = sample.elapsedSeconds / durationSeconds;
      return PaceGraphPoint(
        elapsedSeconds: sample.elapsedSeconds,
        progressFraction: progress.clamp(0, 1).toDouble(),
        paceSecondsPerKm: sample.paceSecondsPerKm,
        displayLabel: _formatPace(sample.paceSecondsPerKm),
      );
    }).toList();
    final bestPacePoint = points.reduce(
      (a, b) => a.paceSecondsPerKm <= b.paceSecondsPerKm ? a : b,
    );
    final slowestPacePoint = points.reduce(
      (a, b) => a.paceSecondsPerKm >= b.paceSecondsPerKm ? a : b,
    );

    return PaceGraphSnapshot(
      isAvailable: true,
      points: points,
      yAxisLabels: _paceAxisLabels(paceRange),
      xAxisLabels: _timeAxisLabels(durationSeconds),
      totalDurationSeconds: durationSeconds,
      averagePaceSecondsPerKm: averagePaceSecondsPerKm,
      bestPacePoint: bestPacePoint,
      slowestPacePoint: slowestPacePoint,
      paceRangeMinSecondsPerKm: paceRange.minSecondsPerKm,
      paceRangeMaxSecondsPerKm: paceRange.maxSecondsPerKm,
    );
  }

  List<PaceGraphSample> _validIncreasingSamples(
    List<PaceGraphSample> samples, {
    required int durationSeconds,
  }) {
    final validSamples = <PaceGraphSample>[];
    int? lastElapsed;

    for (final sample in samples) {
      final elapsed = sample.elapsedSeconds;
      if (elapsed < 0 || elapsed > durationSeconds) {
        continue;
      }

      final pace = sample.paceSecondsPerKm;
      if (pace < minGraphPaceSecondsPerKm || pace > maxGraphPaceSecondsPerKm) {
        continue;
      }
      if (lastElapsed != null && elapsed <= lastElapsed) {
        continue;
      }

      lastElapsed = elapsed;
      validSamples.add(sample);
    }

    return validSamples;
  }

  List<PaceGraphSample> _displaySamples({
    required List<PaceGraphSample> samples,
    required int durationSeconds,
  }) {
    if (samples.length < 3) {
      return samples;
    }

    final bucketSeconds = _bucketSecondsFor(durationSeconds);
    final buckets = <int, List<PaceGraphSample>>{};
    for (final sample in samples) {
      final bucket = sample.elapsedSeconds ~/ bucketSeconds;
      buckets.putIfAbsent(bucket, () => <PaceGraphSample>[]).add(sample);
    }

    final displaySamples = buckets.entries.map((entry) {
      final bucketSamples = entry.value;
      return PaceGraphSample(
        elapsedSeconds: _median(
          bucketSamples.map((sample) {
            return sample.elapsedSeconds;
          }),
        ),
        paceSecondsPerKm: _median(
          bucketSamples.map((sample) {
            return sample.paceSecondsPerKm;
          }),
        ),
      );
    }).toList()..sort((a, b) => a.elapsedSeconds.compareTo(b.elapsedSeconds));

    final anchoredSamples = _withAnchoredEndpoints(
      displaySamples: displaySamples,
      first: samples.first,
      last: samples.last,
    );
    return _stabilizeIsolatedPaces(_capDisplaySamples(anchoredSamples));
  }

  List<PaceGraphSample> _validLineSamples(
    List<PaceGraphSample> samples, {
    required int durationSeconds,
  }) {
    final lineSamples = <PaceGraphSample>[];
    int? lastElapsed;
    double? lastRenderedProgress;

    for (final sample in samples) {
      final elapsed = sample.elapsedSeconds;
      if (elapsed < 0 ||
          elapsed > durationSeconds ||
          (lastElapsed != null && elapsed <= lastElapsed)) {
        continue;
      }

      final progress = (elapsed / durationSeconds).clamp(0.0, 1.0).toDouble();
      if (lastRenderedProgress != null && progress <= lastRenderedProgress) {
        continue;
      }

      lineSamples.add(sample);
      lastElapsed = elapsed;
      lastRenderedProgress = progress;
    }

    return lineSamples;
  }

  int _bucketSecondsFor(int durationSeconds) {
    if (durationSeconds < 300) {
      return _shortRunBucketSeconds;
    }
    if (durationSeconds < 900) {
      return _mediumRunBucketSeconds;
    }
    return _longRunBucketSeconds;
  }

  int _median(Iterable<int> values) {
    final sorted = values.toList()..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle];
    }
    return ((sorted[middle - 1] + sorted[middle]) / 2).round();
  }

  List<PaceGraphSample> _withAnchoredEndpoints({
    required List<PaceGraphSample> displaySamples,
    required PaceGraphSample first,
    required PaceGraphSample last,
  }) {
    final anchored = <PaceGraphSample>[
      if (displaySamples.isEmpty ||
          displaySamples.first.elapsedSeconds != first.elapsedSeconds)
        first,
      ...displaySamples,
      if (displaySamples.isEmpty ||
          displaySamples.last.elapsedSeconds != last.elapsedSeconds)
        last,
    ]..sort((a, b) => a.elapsedSeconds.compareTo(b.elapsedSeconds));

    final deduplicated = <PaceGraphSample>[];
    for (final sample in anchored) {
      if (deduplicated.isEmpty ||
          deduplicated.last.elapsedSeconds != sample.elapsedSeconds) {
        deduplicated.add(sample);
      }
    }
    return deduplicated;
  }

  List<PaceGraphSample> _capDisplaySamples(List<PaceGraphSample> samples) {
    if (samples.length <= maxPaceGraphDisplayPoints) {
      return samples;
    }

    final capped = <PaceGraphSample>[];
    final lastIndex = samples.length - 1;
    final lastSlot = maxPaceGraphDisplayPoints - 1;
    for (var slot = 0; slot < maxPaceGraphDisplayPoints; slot += 1) {
      final index = (slot * lastIndex) ~/ lastSlot;
      final sample = samples[index];
      if (capped.isEmpty ||
          capped.last.elapsedSeconds != sample.elapsedSeconds) {
        capped.add(sample);
      }
    }

    if (capped.last.elapsedSeconds != samples.last.elapsedSeconds) {
      capped[capped.length - 1] = samples.last;
    }
    return capped;
  }

  List<PaceGraphSample> _stabilizeIsolatedPaces(List<PaceGraphSample> samples) {
    if (samples.length < 5) {
      return samples;
    }

    final sortedPaces =
        samples.map((sample) => sample.paceSecondsPerKm).toList()..sort();
    final q1 = _lowerQuartile(sortedPaces);
    final q3 = _upperQuartile(sortedPaces);
    final iqr = q3 - q1;
    final lowerFence = q1 - (iqr * 1.5);
    final upperFence = q3 + (iqr * 1.5);

    return List<PaceGraphSample>.generate(samples.length, (index) {
      final sample = samples[index];
      if (!_isOutsideFence(sample.paceSecondsPerKm, lowerFence, upperFence)) {
        return sample;
      }

      return PaceGraphSample(
        elapsedSeconds: sample.elapsedSeconds,
        paceSecondsPerKm: _nearestStablePace(
          samples: samples,
          outlierIndex: index,
          lowerFence: lowerFence,
          upperFence: upperFence,
        ),
      );
    });
  }

  int _lowerQuartile(List<int> sortedValues) {
    return _median(sortedValues.take(sortedValues.length ~/ 2));
  }

  int _upperQuartile(List<int> sortedValues) {
    return _median(sortedValues.skip((sortedValues.length + 1) ~/ 2));
  }

  bool _isOutsideFence(int value, double lowerFence, double upperFence) {
    return value < lowerFence || value > upperFence;
  }

  int _nearestStablePace({
    required List<PaceGraphSample> samples,
    required int outlierIndex,
    required double lowerFence,
    required double upperFence,
  }) {
    final outlierElapsed = samples[outlierIndex].elapsedSeconds;
    PaceGraphSample? nearest;
    int? nearestDistance;

    for (var index = 0; index < samples.length; index += 1) {
      if (index == outlierIndex) {
        continue;
      }

      final sample = samples[index];
      if (_isOutsideFence(sample.paceSecondsPerKm, lowerFence, upperFence)) {
        continue;
      }

      final distance = (sample.elapsedSeconds - outlierElapsed).abs();
      if (nearestDistance == null || distance < nearestDistance) {
        nearest = sample;
        nearestDistance = distance;
      }
    }

    return nearest?.paceSecondsPerKm ?? samples[outlierIndex].paceSecondsPerKm;
  }

  _PaceAxisRange _paceAxisRange({required int minPace, required int maxPace}) {
    var paddedMin = _roundDownToTwentySeconds(minPace - 20);
    var paddedMax = _roundUpToTwentySeconds(maxPace + 20);

    if (paddedMax - paddedMin < minVisiblePaceRangeSeconds) {
      final midpoint = ((paddedMin + paddedMax) / 2).round();
      paddedMin = _roundDownToTwentySeconds(
        midpoint - (minVisiblePaceRangeSeconds ~/ 2),
      );
      paddedMax = _roundUpToTwentySeconds(
        paddedMin + minVisiblePaceRangeSeconds,
      );
      if (paddedMax - paddedMin < minVisiblePaceRangeSeconds) {
        paddedMin = _roundDownToTwentySeconds(
          paddedMax - minVisiblePaceRangeSeconds,
        );
      }
    }

    return _PaceAxisRange(
      minSecondsPerKm: paddedMin,
      maxSecondsPerKm: paddedMax,
    );
  }

  List<String> _paceAxisLabels(_PaceAxisRange paceRange) {
    final paddedMin = paceRange.minSecondsPerKm;
    final paddedMax = paceRange.maxSecondsPerKm;
    final midpoint = ((paddedMin + paddedMax) / 2).round();

    return [
      _formatTime(paddedMin),
      _formatTime(midpoint),
      _formatTime(paddedMax),
    ];
  }

  List<String> _timeAxisLabels(int durationSeconds) {
    if (durationSeconds < 900) {
      return [
        _formatTime(0),
        _formatTime(_roundDownToMinute(durationSeconds ~/ 2)),
        _formatTime(durationSeconds),
      ];
    }

    return [
      _formatTime(0),
      _formatTime(_roundDownToMinute(durationSeconds ~/ 3)),
      _formatTime(_roundDownToMinute((durationSeconds * 2) ~/ 3)),
      _formatTime(durationSeconds),
    ];
  }

  int _roundDownToTwentySeconds(int value) {
    final safeValue = value < minGraphPaceSecondsPerKm
        ? minGraphPaceSecondsPerKm
        : value;
    return safeValue - (safeValue % 20);
  }

  int _roundUpToTwentySeconds(int value) {
    final safeValue = value > maxGraphPaceSecondsPerKm
        ? maxGraphPaceSecondsPerKm
        : value;
    final remainder = safeValue % 20;
    return remainder == 0 ? safeValue : safeValue + (20 - remainder);
  }

  int _roundDownToMinute(int value) {
    return value - (value % 60);
  }

  String _formatPace(int paceSecondsPerKm) {
    return _formatTime(paceSecondsPerKm);
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PaceAxisRange {
  const _PaceAxisRange({
    required this.minSecondsPerKm,
    required this.maxSecondsPerKm,
  });

  final int minSecondsPerKm;
  final int maxSecondsPerKm;
}
