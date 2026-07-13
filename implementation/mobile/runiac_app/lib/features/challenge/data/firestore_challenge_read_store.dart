import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/challenge_badge_ownership.dart';
import '../domain/models/challenge_history.dart';
import '../domain/repositories/challenge_repository.dart';

/// Member-scoped Firestore read adapter for the two Challenge read paths that
/// have no Cloud Functions callable: durable per-user history and per-tier
/// badge ownership.
///
/// This is the only Firestore-touching file in the Challenge feature tree; it
/// is explicitly allowlisted in the backend-owned contract test so every other
/// Challenge file stays Firestore-free. It performs READS ONLY over the exact
/// owner-scoped documents the security rules permit:
/// `users/{uid}/challengeHistory` and `users/{uid}/challengeBadges`, each capped
/// at the rules' 30-document list limit. It never writes trusted Challenge data;
/// history, badges, rewards, slots, and terminal state are all backend-owned.
class FirestoreChallengeReadStore implements ChallengeReadStore {
  FirestoreChallengeReadStore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const int _listLimit = 30;

  @override
  Future<List<ChallengeHistoryEntry>> loadHistory({
    required String ownerUid,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(ownerUid)
        .collection('challengeHistory')
        .orderBy('endedAt', descending: true)
        .limit(_listLimit)
        .get();

    return List<ChallengeHistoryEntry>.unmodifiable(
      snapshot.docs.map(
        (document) => ChallengeHistoryEntry.fromMap(
          _normalizeHistoryDoc(document.id, document.data()),
        ),
      ),
    );
  }

  @override
  Future<ChallengeBadgeOwnership> loadOwnedBadges({
    required String ownerUid,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(ownerUid)
        .collection('challengeBadges')
        .limit(_listLimit)
        .get();

    return ChallengeBadgeOwnership.fromTierIds(
      snapshot.docs.map((document) => document.id).toList(growable: false),
    );
  }

  /// Normalizes a raw history document into the plain map the immutable model
  /// parses: injects the `challengeId` from the doc id and converts Firestore
  /// `Timestamp` fields to epoch milliseconds the model expects.
  Map<String, Object?> _normalizeHistoryDoc(
    String challengeId,
    Map<String, Object?> data,
  ) {
    return <String, Object?>{
      ...data,
      'challengeId': challengeId,
      'startedAtMs': _millis(data['startedAt']),
      'endedAtMs': _millis(data['endedAt']),
    };
  }

  Object? _millis(Object? value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }
    if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    }
    return value;
  }
}
