import '../domain/challenge_result_seen_store.dart';
import '../domain/models/challenge_history.dart';
import '../domain/repositories/challenge_repository.dart';

/// Drives the one-shot foreground presentation of a terminal Challenge result.
///
/// When the app is foregrounded/resumed, the host calls [takeUnseenResult]. It
/// reads the caller's durable history (newest first) and returns the newest
/// entry that is strictly newer than the locally-persisted "last seen" marker,
/// after advancing the marker. This makes presentation idempotent: an immediate
/// replay, a resume, or a second foreground pass returns `null` for the same
/// result. Terminal state is owned by the backend; this controller only decides
/// whether the already-computed result has been shown yet, and never recomputes
/// eligibility or outcome.
class ChallengeResultPresentationController {
  ChallengeResultPresentationController({
    required this.repository,
    required this.seenStore,
  });

  final ChallengeRepository repository;
  final ChallengeResultSeenStore seenStore;

  bool _inFlight = false;

  /// Returns the newest unseen terminal result and marks it seen, or `null`
  /// when there is nothing new to present. Never throws: a read failure yields
  /// `null` so a transient error simply presents nothing.
  Future<ChallengeResult?> takeUnseenResult() async {
    if (_inFlight) {
      return null;
    }
    _inFlight = true;
    try {
      final List<ChallengeHistoryEntry> history = await repository.history();
      if (history.isEmpty) {
        return null;
      }
      // history() is contractually newest-first (orderBy endedAt desc).
      final ChallengeHistoryEntry newest = history.first;
      final int? marker = await seenStore.lastSeenResultEndedAtMs();
      if (marker != null && newest.endedAtMs <= marker) {
        return null;
      }
      await seenStore.recordSeenResult(newest.endedAtMs);
      return newest.toResult();
    } on ChallengeFailure {
      return null;
    } catch (_) {
      return null;
    } finally {
      _inFlight = false;
    }
  }
}
