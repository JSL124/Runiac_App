import '../models/pace_graph_snapshot.dart';

const minGraphPaceSecondsPerKm = 150;
const maxGraphPaceSecondsPerKm = 1800;
const minVisiblePaceRangeSeconds = 80;

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
    final validSamples = _validIncreasingSamples(samples);
    if (durationSeconds < 60 ||
        distanceMeters < 50 ||
        validSamples.length < 3) {
      return const PaceGraphSnapshot.unavailable();
    }

    final paceValues = validSamples
        .map((sample) => sample.paceSecondsPerKm)
        .toList();
    final minPace = paceValues.reduce((a, b) => a < b ? a : b);
    final maxPace = paceValues.reduce((a, b) => a > b ? a : b);
    final paceRange = _paceAxisRange(minPace: minPace, maxPace: maxPace);
    final points = validSamples.map((sample) {
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

  List<PaceGraphSample> _validIncreasingSamples(List<PaceGraphSample> samples) {
    final validSamples = <PaceGraphSample>[];
    int? lastElapsed;

    for (final sample in samples) {
      final elapsed = sample.elapsedSeconds;
      if (elapsed < 0 || (lastElapsed != null && elapsed <= lastElapsed)) {
        continue;
      }
      lastElapsed = elapsed;

      final pace = sample.paceSecondsPerKm;
      if (pace < minGraphPaceSecondsPerKm || pace > maxGraphPaceSecondsPerKm) {
        continue;
      }
      validSamples.add(sample);
    }

    return validSamples;
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
