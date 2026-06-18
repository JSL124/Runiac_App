import '../models/run_location_sample.dart';
import 'pace_graph_data_builder.dart';
import 'run_distance_calculator.dart';

class LocalPaceGraphSampleDeriver {
  const LocalPaceGraphSampleDeriver({
    this.distanceCalculator = const RunDistanceCalculator(),
  });

  final RunDistanceCalculator distanceCalculator;

  List<PaceGraphSample> derive({
    required DateTime startedAt,
    required List<List<RunLocationSample>> acceptedSampleSegments,
  }) {
    final samples = <PaceGraphSample>[];
    int? lastElapsedSeconds;

    for (final segment in acceptedSampleSegments) {
      if (segment.length < 2) {
        continue;
      }

      for (var index = 1; index < segment.length; index += 1) {
        final previous = segment[index - 1];
        final current = segment[index];
        final elapsedSeconds = current.recordedAt
            .difference(startedAt)
            .inSeconds;
        if (elapsedSeconds < 0 ||
            (lastElapsedSeconds != null &&
                elapsedSeconds <= lastElapsedSeconds)) {
          continue;
        }

        final segmentSeconds = current.recordedAt
            .difference(previous.recordedAt)
            .inSeconds;
        if (segmentSeconds <= 0) {
          continue;
        }

        final segmentMeters = distanceCalculator.distanceMeters(
          previous,
          current,
        );
        if (!segmentMeters.isFinite || segmentMeters <= 0) {
          continue;
        }

        final paceSecondsPerKm = (segmentSeconds / (segmentMeters / 1000))
            .round();
        if (paceSecondsPerKm < minGraphPaceSecondsPerKm ||
            paceSecondsPerKm > maxGraphPaceSecondsPerKm) {
          continue;
        }

        samples.add(
          PaceGraphSample(
            elapsedSeconds: elapsedSeconds,
            paceSecondsPerKm: paceSecondsPerKm,
          ),
        );
        lastElapsedSeconds = elapsedSeconds;
      }
    }

    return samples;
  }
}
