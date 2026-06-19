import '../models/coaching_summary_snapshot.dart';
import '../models/pace_graph_snapshot.dart';
import '../models/run_summary_snapshot.dart';

class RuleBasedCoachingSummaryEngine {
  const RuleBasedCoachingSummaryEngine();

  static const int _shortRunDurationSeconds = 6 * 60;
  static const double _shortRunDistanceKm = 0.8;
  static const int _minimumUsableGraphPoints = 3;
  static const int _minimumUsablePaceSecondsPerKm = 150;
  static const int _maximumUsablePaceSecondsPerKm = 1800;
  static const int _paceControlSpreadSeconds = 60;
  static const int _steadyEffortSpreadSeconds = 35;

  CoachingSummarySnapshot build(RunSummarySnapshot summary) {
    if (!summary.hasSufficientData) {
      return _lowDataInterpretation;
    }

    if (_isShortValidRun(summary)) {
      return _shortValidInterpretation;
    }

    if (!summary.paceGraph.isAvailable) {
      return _buildScalarOrBasicInterpretation(summary);
    }

    final graphPoints = _usableGraphPoints(summary.paceGraph);
    if (graphPoints.length < _minimumUsableGraphPoints) {
      return _dataQualityFallbackInterpretation;
    }

    final paceSpread = _paceSpreadSeconds(graphPoints);
    if (paceSpread >= _paceControlSpreadSeconds) {
      return _paceControlInterpretation;
    }

    if (paceSpread <= _steadyEffortSpreadSeconds) {
      return _steadyEffortInterpretation;
    }

    return _pacingAwarenessInterpretation;
  }

  bool _isShortValidRun(RunSummarySnapshot summary) {
    final distanceKm = _parseDistanceKm(summary.distanceKm);
    final durationSeconds = _parseDurationSeconds(summary.duration);

    return (distanceKm != null && distanceKm < _shortRunDistanceKm) ||
        (durationSeconds != null && durationSeconds < _shortRunDurationSeconds);
  }

  CoachingSummarySnapshot _buildScalarOrBasicInterpretation(
    RunSummarySnapshot summary,
  ) {
    if (_hasDisplayAveragePace(summary.avgPace)) {
      return _scalarOnlyInterpretation;
    }

    return _basicCompletionInterpretation;
  }

  List<PaceGraphPoint> _usableGraphPoints(PaceGraphSnapshot graph) {
    final points =
        graph.points
            .where(
              (point) =>
                  point.progressFraction.isFinite &&
                  point.progressFraction >= 0 &&
                  point.progressFraction <= 1 &&
                  point.paceSecondsPerKm >= _minimumUsablePaceSecondsPerKm &&
                  point.paceSecondsPerKm <= _maximumUsablePaceSecondsPerKm,
            )
            .toList()
          ..sort((a, b) => a.elapsedSeconds.compareTo(b.elapsedSeconds));

    if (!_hasIncreasingGraphOrder(points)) {
      return const [];
    }

    return points;
  }

  bool _hasIncreasingGraphOrder(List<PaceGraphPoint> points) {
    for (var index = 1; index < points.length; index += 1) {
      final previous = points[index - 1];
      final current = points[index];

      if (current.elapsedSeconds <= previous.elapsedSeconds ||
          current.progressFraction <= previous.progressFraction) {
        return false;
      }
    }

    return true;
  }

  int _paceSpreadSeconds(List<PaceGraphPoint> points) {
    var minimumPace = points.first.paceSecondsPerKm;
    var maximumPace = points.first.paceSecondsPerKm;

    for (final point in points.skip(1)) {
      if (point.paceSecondsPerKm < minimumPace) {
        minimumPace = point.paceSecondsPerKm;
      }
      if (point.paceSecondsPerKm > maximumPace) {
        maximumPace = point.paceSecondsPerKm;
      }
    }

    return maximumPace - minimumPace;
  }

  double? _parseDistanceKm(String label) {
    final normalized = label.toLowerCase().replaceAll('km', '').trim();
    return double.tryParse(normalized);
  }

  int? _parseDurationSeconds(String label) {
    final parts = label.split(':');
    if (parts.length < 2 || parts.length > 3) {
      return null;
    }

    final values = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0) {
        return null;
      }
      values.add(value);
    }

    if (values.length == 2) {
      return values[0] * 60 + values[1];
    }

    return values[0] * 3600 + values[1] * 60 + values[2];
  }

  bool _hasDisplayAveragePace(String label) {
    final normalized = label.trim();
    return normalized.isNotEmpty && normalized != '--';
  }
}

const _lowDataInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.lowDataInterpretation,
  headline: 'Thanks for getting out there',
  message:
      'This run has limited run data, so the summary stays simple. Your effort still counts.',
  bullets: [
    'What went well: You started and created a check-in point.',
    'What to improve: Aim for a little more time or distance with GPS ready.',
  ],
  nextAction: 'Try one short easy run with GPS ready.',
);

const _shortValidInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.shortValidInterpretation,
  headline: 'A solid short start',
  message:
      'This was a real but short running effort, best used for building the habit.',
  bullets: [
    'What went well: You completed a measurable start.',
    'What to improve: Repeat it calmly before adding more.',
  ],
  nextAction: 'Repeat a short easy run and keep it relaxed.',
);

const _scalarOnlyInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.scalarOnlyInterpretation,
  headline: 'Good work completing the run',
  message:
      'Your distance, time, and average pace are usable, so this summary focuses on the overall effort.',
  bullets: [
    'What went well: You completed a measurable run.',
    'What to improve: Keep the next run simple and consistent.',
  ],
  nextAction: 'Keep your next run easy and comfortable.',
);

const _dataQualityFallbackInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.dataQualityFallbackInterpretation,
  headline: 'Good work finishing this run',
  message:
      'The run summary is available, but the graph detail is too limited for a pacing trend.',
  bullets: [
    'What went well: You still have useful distance and time data.',
    'What to improve: Use the next run as a clean, easy check-in.',
  ],
  nextAction: 'Run easy with GPS ready and let the data settle.',
);

const _paceControlInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.paceControlInterpretation,
  headline: 'Your pace moved around today',
  message:
      'Your pace changed noticeably, which is normal while you are finding rhythm.',
  bullets: [
    'What went well: You kept moving and completed the effort.',
    'What to improve: Start easier so the run can settle into a relaxed rhythm.',
  ],
  nextAction: 'Begin the next run slower for the first few minutes.',
);

const _steadyEffortInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.steadyEffortInterpretation,
  headline: 'You kept a controlled rhythm',
  message:
      'The available pace data stayed fairly steady, which is useful for easy beginner runs.',
  bullets: [
    'What went well: Your rhythm looked consistent in the available data.',
    'What to improve: Repeat the easy consistency rather than trying to go faster.',
  ],
  nextAction: 'Repeat an easy run with the same relaxed rhythm.',
);

const _pacingAwarenessInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.pacingAwarenessInterpretation,
  headline: 'You have pacing data to learn from',
  message: 'The pace graph gives a simple view of rhythm during the run.',
  bullets: [
    'What went well: You completed a run with enough data to review pacing.',
    'What to improve: Notice how the first few minutes feel before settling in.',
  ],
  nextAction: 'Start relaxed, then settle into a pace you can hold.',
);

const _basicCompletionInterpretation = CoachingSummarySnapshot(
  source: CoachingSummarySource.ruleBased,
  interpretationId: CoachingInterpretationId.basicCompletionInterpretation,
  headline: 'Good work finishing the run',
  message:
      'This was a completed beginner running effort with enough data for a simple summary.',
  bullets: [
    'What went well: You finished a measurable run.',
    'What to improve: Build consistency by repeating an easy effort.',
  ],
  nextAction: 'Keep the next run easy and repeatable.',
);
