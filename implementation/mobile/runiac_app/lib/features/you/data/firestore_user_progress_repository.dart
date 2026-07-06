import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/runiac_auth_service.dart';
import '../domain/models/user_progress_read_model.dart';
import '../domain/repositories/user_progress_repository.dart';

abstract interface class UserProgressDocumentReader {
  Future<Map<String, Object?>?> readUserProgress({required String uid});
}

class FirestoreUserProgressDocumentReader
    implements UserProgressDocumentReader {
  FirestoreUserProgressDocumentReader({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, Object?>?> readUserProgress({required String uid}) async {
    final snapshot = await _firestore.collection('userProfiles').doc(uid).get();
    final data = snapshot.data();
    return data == null ? null : Map<String, Object?>.from(data);
  }
}

class FirestoreUserProgressRepository implements UserProgressRepository {
  FirestoreUserProgressRepository({
    required this.authRepository,
    UserProgressDocumentReader? reader,
    this.fallbackRepository = const StaticUserProgressRepository(),
  }) : _reader = reader ?? FirestoreUserProgressDocumentReader();

  final RuniacAuthRepository authRepository;
  final UserProgressDocumentReader _reader;
  final UserProgressRepository fallbackRepository;

  @override
  Future<UserProgressReadModel> loadUserProgress() async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) {
      return fallbackRepository.loadUserProgress();
    }

    final data = await _reader.readUserProgress(uid: currentUser.uid);
    if (data == null) {
      return _emptyProgress(currentUser.uid);
    }

    return UserProgressReadModel(
      userId: currentUser.uid,
      officialStreakLabel: _streakLabel(data['streakCount']),
      levelLabel: _string(data['levelLabel']),
      totalXpLabel: _string(data['totalXpLabel']),
      weeklyXpLabel: _string(data['weeklyXpLabel']),
      monthlyXpLabel: _string(data['monthlyXpLabel']),
      weeklyDistanceLabel: _string(data['weeklyDistanceLabel']),
      goalProgressLabel: _string(data['goalProgressLabel']),
    );
  }

  UserProgressReadModel _emptyProgress(String uid) {
    return UserProgressReadModel(
      userId: uid,
      officialStreakLabel: '',
      levelLabel: '',
      totalXpLabel: '',
      weeklyXpLabel: '',
      monthlyXpLabel: '',
      weeklyDistanceLabel: '',
      goalProgressLabel: '',
    );
  }

  String _streakLabel(Object? streakCount) {
    if (streakCount is! int || streakCount <= 0) {
      return '';
    }
    return streakCount == 1 ? '1 day' : '$streakCount days';
  }

  String _string(Object? value) {
    return value is String ? value : '';
  }
}
