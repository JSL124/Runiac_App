import '../models/pace_graph_snapshot.dart';

const minGraphPaceSecondsPerKm = 150;
const maxGraphPaceSecondsPerKm = 1800;

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
  }) {
    final validSamples = _validIncreasingSamples(samples);
    if (durationSeconds < 60 ||
        distanceMeters < 50 ||
        validSamples.length < 3) {
      return const PaceGraphSnapshot.unavailable();
    }

    final firstElapsed = validSamples.first.elapsedSeconds;
    final lastElapsed = validSamples.last.elapsedSeconds;
    final elapsedRange = lastElapsed - firstElapsed;
    if (elapsedRange <= 0) {
      return const PaceGraphSnapshot.unavailable();
    }

    final paceValues = validSamples
        .map((sample) => sample.paceSecondsPerKm)
        .toList();
    final minPace = paceValues.reduce((a, b) => a < b ? a : b);
    final maxPace = paceValues.reduce((a, b) => a > b ? a : b);

    return PaceGraphSnapshot(
      isAvailable: true,
      points: validSamples.map((sample) {
        final progress = (sample.elapsedSeconds - firstElapsed) / elapsedRange;
        return PaceGraphPoint(
          elapsedSeconds: sample.elapsedSeconds,
          progressFraction: progress.clamp(0, 1).toDouble(),
          paceSecondsPerKm: sample.paceSecondsPerKm,
          displayLabel: _formatPace(sample.paceSecondsPerKm),
        );
      }).toList(),
      yAxisLabels: _paceAxisLabels(minPace: minPace, maxPace: maxPace),
      xAxisLabels: _timeAxisLabels(
        firstElapsed: firstElapsed,
        lastElapsed: lastElapsed,
      ),
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

  List<String> _paceAxisLabels({required int minPace, required int maxPace}) {
    final paddedMin = _roundDownToTwentySeconds(minPace - 20);
    final paddedMax = _roundUpToTwentySeconds(maxPace + 20);
    final midpoint = ((paddedMin + paddedMax) / 2).round();

    return [
      _formatTime(paddedMin),
      _formatTime(midpoint),
      _formatTime(paddedMax),
    ];
  }

  List<String> _timeAxisLabels({
    required int firstElapsed,
    required int lastElapsed,
  }) {
    final midpoint = firstElapsed + ((lastElapsed - firstElapsed) / 2).round();
    return [
      _formatTime(firstElapsed),
      _formatTime(midpoint),
      _formatTime(lastElapsed),
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

  String _formatPace(int paceSecondsPerKm) {
    return _formatTime(paceSecondsPerKm);
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
