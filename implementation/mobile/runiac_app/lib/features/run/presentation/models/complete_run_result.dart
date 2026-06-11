import 'run_summary_snapshot.dart';
import 'xp_update_display_model.dart';

/// Future backend-produced display result for a completed run.
///
/// This presentation-only shape must not calculate rewards, decide progression
/// eligibility, or perform backend, network, or storage actions.
class CompleteRunResult {
  const CompleteRunResult({required this.summary, required this.xpUpdate});

  final RunSummarySnapshot summary;
  final XpUpdateDisplayModel xpUpdate;
}
