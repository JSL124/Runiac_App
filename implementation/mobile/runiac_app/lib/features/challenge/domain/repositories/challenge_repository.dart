import '../models/active_challenge.dart';
import '../models/challenge_action_results.dart';
import '../models/challenge_badge_ownership.dart';
import '../models/challenge_enums.dart';
import '../models/challenge_history.dart';
import '../models/challenge_invitation_summary.dart';
import '../models/challenge_tier.dart';

/// Read/command surface over the server-owned Challenge distance system.
///
/// Every method either reads a backend-owned projection or invokes a trusted
/// Cloud Functions callable. The client never calculates or writes target
/// progress, contribution, eligibility, completion, reward/slot ownership, or
/// terminal state — those live entirely behind these operations.
abstract interface class ChallengeRepository {
  /// The versioned nine-tier catalog (`getChallengeCatalog`).
  Future<ChallengeCatalog> catalog();

  /// Creates a RECRUITING solo lobby the caller owns (`createChallengeLobby`).
  Future<CreateLobbyResult> createLobby(ChallengeTierId tierId);

  /// Invites reciprocal friends to a lobby (`inviteChallengeFriends`).
  Future<InviteResult> invite({
    required String challengeId,
    required List<String> uids,
  });

  /// Accepts or declines an invitation (`respondToChallengeInvitation`).
  Future<RespondResult> respondToInvitation({
    required String inviteId,
    required bool accept,
  });

  /// Withdraws the caller from a RECRUITING lobby (`withdrawFromChallengeLobby`).
  Future<WithdrawResult> withdraw({required String challengeId});

  /// Owner-cancels a RECRUITING lobby (`cancelChallengeLobby`).
  Future<CancelLobbyResult> cancelLobby({required String challengeId});

  /// Owner-starts a lobby, locking mode/rules (`startChallenge`).
  Future<StartChallengeResult> start({required String challengeId});

  /// The caller's current recruiting/active/settling challenge, or `null`
  /// (`getActiveChallenge`). One-shot: the backend exposes no member-scoped
  /// live listener, so surfaces refetch rather than stream.
  Future<ActiveChallenge?> activeChallenge();

  /// The caller's PENDING invitations (`getChallengeInvitations`).
  Future<List<ChallengeInvitationSummary>> invitations();

  /// Non-owner leaves an ACTIVE challenge (`leaveChallenge`).
  Future<LeaveChallengeResult> leave({required String challengeId});

  /// Owner abandons an ACTIVE challenge for everyone (`abandonChallenge`).
  Future<AbandonChallengeResult> abandon({required String challengeId});

  /// The caller's durable challenge history, newest first.
  Future<List<ChallengeHistoryEntry>> history();

  /// The caller's owned tier badges.
  Future<ChallengeBadgeOwnership> ownedBadges();
}

/// Typed failure for every Challenge repository operation.
///
/// [reason] carries the backend `CHALLENGE_REASON` code when present
/// (parsed from `HttpsError.details.reason`), otherwise the coarse transport
/// code. Surfaces map it to user copy; they never inspect the raw message for
/// control flow.
class ChallengeFailure implements Exception {
  const ChallengeFailure({required this.reason, this.message});

  final String reason;
  final String? message;

  /// Sentinel reason used when a required read path is not yet wired.
  static const String unavailableReason = 'CHALLENGE_UNAVAILABLE';

  @override
  String toString() => 'ChallengeFailure(reason: $reason)';
}

/// Firestore-free port for the two read paths that have no callable: durable
/// history and badge ownership.
///
/// The Challenge feature tree is kept entirely free of Firestore data APIs
/// (enforced by the backend-owned contract test), so the concrete member-scoped
/// Firestore read adapter for these lives outside `lib/features/challenge/**`
/// and is injected here. Until it is wired, callers receive a
/// [ChallengeFailure] with [ChallengeFailure.unavailableReason].
abstract interface class ChallengeReadStore {
  Future<List<ChallengeHistoryEntry>> loadHistory({required String ownerUid});

  Future<ChallengeBadgeOwnership> loadOwnedBadges({required String ownerUid});
}
