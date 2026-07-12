import '../services/pace_graph_data_builder.dart';
import 'elevation_analysis_series.dart';
import 'run_location_sample.dart';
import 'run_route_snapshot.dart';

class RunCompletionRequestPayloadSerializer {
  const RunCompletionRequestPayloadSerializer._();

  static const int maxRoutePreviewPoints = 256;
  static const int maxRoutePreviewSegments = 64;
  static const int maxPaceAnalysisSamples = 360;
  static const int maxElevationSamples = 360;

  static Map<String, Object?> optionalField(String key, Object? value) {
    return value == null
        ? const <String, Object?>{}
        : <String, Object?>{key: value};
  }

  static Map<String, Object?>? routePreviewToBackendMap(
    RunRouteSnapshot route,
  ) {
    var sourceSegments = route.segments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    if (sourceSegments.isEmpty && route.lastKnownLocation != null) {
      sourceSegments = <List<RunLocationSample>>[
        <RunLocationSample>[route.lastKnownLocation!],
      ];
    }
    if (sourceSegments.isEmpty) {
      return null;
    }

    final boundedSegments = _boundedRouteSegments(sourceSegments);
    if (boundedSegments.isEmpty) {
      return null;
    }
    return <String, Object?>{
      'segments': [
        for (final segment in boundedSegments)
          <String, Object?>{
            'points': [
              for (final sample in segment)
                _routePreviewPointToBackendMap(sample),
            ],
          },
      ],
    };
  }

  static List<List<RunLocationSample>> _boundedRouteSegments(
    List<List<RunLocationSample>> sourceSegments,
  ) {
    if (sourceSegments.length > maxRoutePreviewSegments) {
      return [
        for (final segmentIndex in _evenlySpacedIndexes(
          sourceSegments.length,
          maxRoutePreviewSegments,
        ))
          <RunLocationSample>[sourceSegments[segmentIndex].first],
      ];
    }

    final totalPoints = sourceSegments.fold<int>(
      0,
      (total, segment) => total + segment.length,
    );
    if (totalPoints <= maxRoutePreviewPoints) {
      return [
        for (final segment in sourceSegments)
          List<RunLocationSample>.of(segment),
      ];
    }

    final targetCounts = [
      for (final segment in sourceSegments) segment.length < 2 ? 1 : 2,
    ];
    final extras = [
      for (var index = 0; index < sourceSegments.length; index += 1)
        sourceSegments[index].length - targetCounts[index],
    ];
    final totalExtra = extras.fold<int>(0, (total, extra) => total + extra);
    var allocatedPoints = targetCounts.fold<int>(
      0,
      (total, targetCount) => total + targetCount,
    );
    final availableExtra = maxRoutePreviewPoints - allocatedPoints;
    if (totalExtra > 0 && availableExtra > 0) {
      for (var index = 0; index < sourceSegments.length; index += 1) {
        final extraAllocation = (availableExtra * extras[index] / totalExtra)
            .floor();
        targetCounts[index] += extraAllocation;
        allocatedPoints += extraAllocation;
      }
      while (allocatedPoints < maxRoutePreviewPoints) {
        var bestIndex = -1;
        var bestRemaining = -1;
        for (var index = 0; index < sourceSegments.length; index += 1) {
          final remaining = sourceSegments[index].length - targetCounts[index];
          if (remaining > bestRemaining) {
            bestIndex = index;
            bestRemaining = remaining;
          }
        }
        if (bestIndex < 0 || bestRemaining <= 0) {
          break;
        }
        targetCounts[bestIndex] += 1;
        allocatedPoints += 1;
      }
    }

    return [
      for (var index = 0; index < sourceSegments.length; index += 1)
        _sampleRouteSegment(sourceSegments[index], targetCounts[index]),
    ];
  }

  static List<RunLocationSample> _sampleRouteSegment(
    List<RunLocationSample> source,
    int targetCount,
  ) {
    if (targetCount >= source.length) {
      return List<RunLocationSample>.of(source);
    }
    return [
      for (final index in _evenlySpacedIndexes(source.length, targetCount))
        source[index],
    ];
  }

  static Map<String, Object?> _routePreviewPointToBackendMap(
    RunLocationSample sample,
  ) {
    return <String, Object?>{
      'latitude': _quantizeCoordinate(sample.latitude),
      'longitude': _quantizeCoordinate(sample.longitude),
    };
  }

  static double _quantizeCoordinate(double value) {
    return (value * 1000).round() / 1000;
  }

  static Map<String, Object?>? paceAnalysisSeriesToBackendMap(
    List<PaceGraphSample> sourceSamples,
  ) {
    if (sourceSamples.isEmpty) {
      return null;
    }
    final allSamples = <Map<String, Object?>>[];
    int? previousElapsedSeconds;
    var derivedDistanceMeters = 0;
    for (final sample in sourceSamples) {
      final elapsedDelta =
          sample.elapsedSeconds - (previousElapsedSeconds ?? 0);
      if (sample.cumulativeDistanceMeters != null) {
        derivedDistanceMeters = sample.cumulativeDistanceMeters!;
      } else if (elapsedDelta > 0 && sample.paceSecondsPerKm > 0) {
        derivedDistanceMeters += (elapsedDelta * 1000 / sample.paceSecondsPerKm)
            .round();
      }
      allSamples.add(<String, Object?>{
        'elapsedSeconds': sample.elapsedSeconds,
        'cumulativeDistanceMeters': derivedDistanceMeters,
        'paceSecondsPerKm': sample.paceSecondsPerKm,
        'status': 'accepted',
      });
      previousElapsedSeconds = sample.elapsedSeconds;
    }
    return <String, Object?>{
      'source': 'localAccepted',
      'confidence': 'derived',
      'samples': _boundedMaps(allSamples, maxPaceAnalysisSamples),
    };
  }

  static Map<String, Object?> elevationAnalysisSeriesToBackendMap(
    ElevationAnalysisSeries series,
  ) {
    return <String, Object?>{
      'source': series.source.name,
      'confidence': series.confidence.name,
      'samples': [
        for (final sample in _boundedList(
          series.validSamples,
          maxElevationSamples,
        ))
          <String, Object?>{
            'distanceKm': sample.distanceKm,
            'elevationMeters': sample.elevationMeters,
          },
      ],
    };
  }

  static List<Map<String, Object?>> _boundedMaps(
    List<Map<String, Object?>> source,
    int maxLength,
  ) {
    return [
      for (final index in _evenlySpacedIndexes(source.length, maxLength))
        source[index],
    ];
  }

  static List<T> _boundedList<T>(List<T> source, int maxLength) {
    return [
      for (final index in _evenlySpacedIndexes(source.length, maxLength))
        source[index],
    ];
  }

  static List<int> _evenlySpacedIndexes(int sourceLength, int maxLength) {
    if (sourceLength <= maxLength) {
      return [for (var index = 0; index < sourceLength; index += 1) index];
    }
    if (maxLength <= 1) {
      return const [0];
    }
    final lastSourceIndex = sourceLength - 1;
    final lastTargetIndex = maxLength - 1;
    return [
      for (var targetIndex = 0; targetIndex < maxLength; targetIndex += 1)
        (targetIndex * lastSourceIndex / lastTargetIndex).round(),
    ];
  }
}
