import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/repositories/user_profile_persistence_repository.dart';

typedef UserProfileUpdatedAtFactory = Object Function();

abstract interface class UserProfileDocumentWriter {
  Future<bool> isNicknameAvailable({
    required String uid,
    required String nicknameKey,
  });

  Future<void> mergeUserProfile({
    required String uid,
    required Map<String, Object> data,
    required String nickname,
    required String nicknameKey,
  });
}

class FirestoreUserProfileDocumentWriter implements UserProfileDocumentWriter {
  FirestoreUserProfileDocumentWriter({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<bool> isNicknameAvailable({
    required String uid,
    required String nicknameKey,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('nicknameClaims')
          .doc(nicknameKey)
          .get();
      if (!snapshot.exists) {
        return true;
      }
      return snapshot.data()?['ownerUid'] == uid;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw const NicknameAvailabilityCheckException(
          NicknameAvailabilityFailureReason.rulesUnavailable,
        );
      }
      throw const NicknameAvailabilityCheckException(
        NicknameAvailabilityFailureReason.unavailable,
      );
    }
  }

  @override
  Future<void> mergeUserProfile({
    required String uid,
    required Map<String, Object> data,
    required String nickname,
    required String nicknameKey,
  }) {
    final profileRef = _firestore.collection('userProfiles').doc(uid);
    final claimRef = _firestore.collection('nicknameClaims').doc(nicknameKey);
    return _firestore.runTransaction((transaction) async {
      final claimSnapshot = await transaction.get(claimRef);
      if (claimSnapshot.exists && claimSnapshot.data()?['ownerUid'] != uid) {
        throw const DuplicateNicknameException();
      }

      final profileSnapshot = await transaction.get(profileRef);
      final previousNicknameKey = profileSnapshot.data()?['nicknameKey'];
      if (previousNicknameKey is String &&
          previousNicknameKey.isNotEmpty &&
          previousNicknameKey != nicknameKey) {
        final previousClaimRef = _firestore
            .collection('nicknameClaims')
            .doc(previousNicknameKey);
        final previousClaimSnapshot = await transaction.get(previousClaimRef);
        if (previousClaimSnapshot.exists &&
            previousClaimSnapshot.data()?['ownerUid'] == uid) {
          transaction.delete(previousClaimRef);
        }
      }

      transaction.set(claimRef, <String, Object>{
        'ownerUid': uid,
        'nickname': nickname,
        'nicknameKey': nicknameKey,
        'updatedAt': data['updatedAt']!,
      }, SetOptions(merge: true));
      transaction.set(profileRef, data, SetOptions(merge: true));
    });
  }
}

class FirestoreUserProfilePersistenceRepository
    implements UserProfilePersistenceRepository {
  FirestoreUserProfilePersistenceRepository({
    UserProfileDocumentWriter? writer,
    UserProfileUpdatedAtFactory? updatedAt,
  }) : _writer = writer ?? FirestoreUserProfileDocumentWriter(),
       _updatedAt = updatedAt ?? FieldValue.serverTimestamp;

  final UserProfileDocumentWriter _writer;
  final UserProfileUpdatedAtFactory _updatedAt;

  @override
  Future<bool> isNicknameAvailable({
    required String uid,
    required String nickname,
  }) {
    return _writer.isNicknameAvailable(
      uid: uid,
      nicknameKey: normalizeNicknameKey(nickname),
    );
  }

  @override
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  }) {
    return _writer.mergeUserProfile(
      uid: uid,
      data: profile.toFirestoreDocument(updatedAt: _updatedAt()),
      nickname: profile.nickname,
      nicknameKey: profile.nicknameKey,
    );
  }

  @override
  Future<void> savePersonalProfile({
    required String uid,
    required UserProfilePersonalSnapshot profile,
  }) {
    return _writer.mergeUserProfile(
      uid: uid,
      data: profile.toFirestoreDocument(updatedAt: _updatedAt()),
      nickname: profile.nickname,
      nicknameKey: profile.nicknameKey,
    );
  }
}

class DuplicateNicknameException implements Exception {
  const DuplicateNicknameException();
}
