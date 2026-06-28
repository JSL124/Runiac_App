import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/repositories/user_profile_persistence_repository.dart';

typedef UserProfileUpdatedAtFactory = Object Function();

abstract interface class UserProfileDocumentWriter {
  Future<void> mergeUserProfile({
    required String uid,
    required Map<String, Object> data,
  });
}

class FirestoreUserProfileDocumentWriter implements UserProfileDocumentWriter {
  FirestoreUserProfileDocumentWriter({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> mergeUserProfile({
    required String uid,
    required Map<String, Object> data,
  }) {
    return _firestore
        .collection('userProfiles')
        .doc(uid)
        .set(data, SetOptions(merge: true));
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
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  }) {
    return _writer.mergeUserProfile(
      uid: uid,
      data: profile.toFirestoreDocument(updatedAt: _updatedAt()),
    );
  }
}
