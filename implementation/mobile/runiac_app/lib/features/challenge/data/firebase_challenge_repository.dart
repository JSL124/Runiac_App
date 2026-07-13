import 'package:cloud_functions/cloud_functions.dart';

import '../domain/models/active_challenge.dart';
import '../domain/models/challenge_action_results.dart';
import '../domain/models/challenge_badge_ownership.dart';
import '../domain/models/challenge_enums.dart';
import '../domain/models/challenge_history.dart';
import '../domain/models/challenge_invitation_summary.dart';
import '../domain/models/challenge_parse.dart';
import '../domain/models/challenge_parse_exception.dart';
import '../domain/models/challenge_tier.dart';
import '../domain/repositories/challenge_repository.dart';

/// Resolves the currently-authenticated uid (used to flag the caller's own
/// participant row). Returns `null` when signed out.
typedef ChallengeCurrentUid = String? Function();

/// Cloud Functions callable adapter for the Challenge distance system.
///
/// Mirrors the app's callable convention: a region-`asia-southeast1`
/// [FirebaseFunctions] instance (the same one the bootstrap points at the
/// emulator when `RUNIAC_FIREBASE_EMULATOR=true`), stable failure codes read
/// from `HttpsError.details.reason`, and strict response parsing. This class
/// touches no Firestore APIs; the two read paths without a callable (history,
/// badges) delegate to an injected [ChallengeReadStore].
class FirebaseChallengeRepository implements ChallengeRepository {
  FirebaseChallengeRepository({
    required this.currentUid,
    FirebaseFunctions? functions,
    this.readStore,
  }) : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  /// Resolves the signed-in uid; `null` when signed out.
  final ChallengeCurrentUid currentUid;

  /// Firestore-free read source for history/badges; `null` until wired.
  final ChallengeReadStore? readStore;

  final FirebaseFunctions _functions;

  @override
  Future<ChallengeCatalog> catalog() async {
    final data = await _call('getChallengeCatalog');
    return _map(() => ChallengeCatalog.fromMap(data));
  }

  @override
  Future<CreateLobbyResult> createLobby(ChallengeTierId tierId) async {
    final data = await _call('createChallengeLobby', <String, Object?>{
      'tierId': tierId.wireValue,
    });
    return _map(() => CreateLobbyResult.fromMap(data));
  }

  @override
  Future<InviteResult> invite({
    required String challengeId,
    required List<String> uids,
  }) async {
    final data = await _call('inviteChallengeFriends', <String, Object?>{
      'challengeId': challengeId,
      'uids': uids,
    });
    return _map(() => InviteResult.fromMap(data));
  }

  @override
  Future<RespondResult> respondToInvitation({
    required String inviteId,
    required bool accept,
  }) async {
    final data = await _call('respondToChallengeInvitation', <String, Object?>{
      'inviteId': inviteId,
      'response': accept ? 'accept' : 'decline',
    });
    return _map(() => RespondResult.fromMap(data));
  }

  @override
  Future<WithdrawResult> withdraw({required String challengeId}) async {
    final data = await _call('withdrawFromChallengeLobby', <String, Object?>{
      'challengeId': challengeId,
    });
    return _map(() => WithdrawResult.fromMap(data));
  }

  @override
  Future<CancelLobbyResult> cancelLobby({required String challengeId}) async {
    final data = await _call('cancelChallengeLobby', <String, Object?>{
      'challengeId': challengeId,
    });
    return _map(() => CancelLobbyResult.fromMap(data));
  }

  @override
  Future<StartChallengeResult> start({required String challengeId}) async {
    final data = await _call('startChallenge', <String, Object?>{
      'challengeId': challengeId,
    });
    return _map(() => StartChallengeResult.fromMap(data));
  }

  @override
  Future<ActiveChallenge?> activeChallenge() async {
    final data = await _call('getActiveChallenge');
    return _map(() {
      final challenge = data['challenge'];
      if (challenge == null) {
        return null;
      }
      return ActiveChallenge.fromChallengeMap(
        ChallengeParse.asMap(challenge, field: 'challenge'),
        currentUid: currentUid(),
      );
    });
  }

  @override
  Future<List<ChallengeInvitationSummary>> invitations() async {
    final data = await _call('getChallengeInvitations');
    return _map(() {
      final raw =
          ChallengeParse.asList(data['invitations'], field: 'invitations');
      final invitations = raw
          .map(
            (entry) => ChallengeInvitationSummary.fromPendingView(
              ChallengeParse.asMap(entry, field: 'invitations[]'),
            ),
          )
          .toList(growable: false);
      return List<ChallengeInvitationSummary>.unmodifiable(invitations);
    });
  }

  @override
  Future<LeaveChallengeResult> leave({required String challengeId}) async {
    final data = await _call('leaveChallenge', <String, Object?>{
      'challengeId': challengeId,
    });
    return _map(() => LeaveChallengeResult.fromMap(data));
  }

  @override
  Future<AbandonChallengeResult> abandon({required String challengeId}) async {
    final data = await _call('abandonChallenge', <String, Object?>{
      'challengeId': challengeId,
    });
    return _map(() => AbandonChallengeResult.fromMap(data));
  }

  @override
  Future<List<ChallengeHistoryEntry>> history() {
    final store = _requireReadStore();
    return store.loadHistory(ownerUid: _requireUid());
  }

  @override
  Future<ChallengeBadgeOwnership> ownedBadges() {
    final store = _requireReadStore();
    return store.loadOwnedBadges(ownerUid: _requireUid());
  }

  Future<Map<String, Object?>> _call(
    String name, [
    Map<String, Object?> payload = const <String, Object?>{},
  ]) async {
    try {
      final result = await _functions.httpsCallable(name).call(payload);
      return _asStringMap(result.data);
    } on FirebaseFunctionsException catch (error) {
      throw _failure(error);
    }
  }

  Map<String, Object?> _asStringMap(Object? data) {
    if (data is Map) {
      return <String, Object?>{
        for (final entry in data.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
    }
    throw const ChallengeFailure(reason: 'INVALID_RESPONSE');
  }

  ChallengeReadStore _requireReadStore() {
    final store = readStore;
    if (store == null) {
      throw const ChallengeFailure(reason: ChallengeFailure.unavailableReason);
    }
    return store;
  }

  String _requireUid() {
    final uid = currentUid();
    if (uid == null || uid.isEmpty) {
      throw const ChallengeFailure(reason: 'UNAUTHENTICATED');
    }
    return uid;
  }

  T _map<T>(T Function() parse) {
    try {
      return parse();
    } on ChallengeParseException catch (error) {
      throw ChallengeFailure(
        reason: 'INVALID_RESPONSE',
        message: error.toString(),
      );
    }
  }

  ChallengeFailure _failure(FirebaseFunctionsException error) {
    final details = error.details;
    String? reason;
    if (details is Map) {
      final raw = details['reason'];
      if (raw is String && raw.isNotEmpty) {
        reason = raw;
      }
    }
    return ChallengeFailure(
      reason: reason ?? error.code,
      message: error.message,
    );
  }
}
