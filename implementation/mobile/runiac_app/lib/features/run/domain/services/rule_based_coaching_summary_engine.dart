import '../models/coaching_summary_snapshot.dart';
import '../models/run_summary_snapshot.dart';

class RuleBasedCoachingSummaryEngine {
  const RuleBasedCoachingSummaryEngine();

  CoachingSummarySnapshot build(RunSummarySnapshot summary) {
    if (!summary.hasSufficientData) {
      return const CoachingSummarySnapshot(
        source: CoachingSummarySource.ruleBased,
        headline: 'Thanks for getting out there',
        message:
            'This run has limited run data, so the summary stays simple. Your effort still counts.',
        bullets: ['Use it as a gentle check-in, not a full run analysis.'],
        nextAction: 'Try one short easy run with GPS ready.',
      );
    }

    if (summary.paceGraph.isAvailable) {
      return CoachingSummarySnapshot(
        source: CoachingSummarySource.ruleBased,
        headline: 'Good work finishing this run',
        message:
            'You completed ${summary.distanceKm} km in ${summary.duration}. The pace graph is available, so this summary can focus on keeping your effort steady.',
        bullets: const ['Start relaxed, then settle into a pace you can hold.'],
        nextAction: 'Keep your next run easy and comfortable.',
      );
    }

    return CoachingSummarySnapshot(
      source: CoachingSummarySource.ruleBased,
      headline: 'Good work completing the run',
      message:
          'This summary uses your distance, time, and average pace. There is not enough graph data for pacing detail.',
      bullets: const ['Keep the next run simple and relaxed.'],
      nextAction: 'Keep your next run easy and comfortable.',
    );
  }
}
