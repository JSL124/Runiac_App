import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/you/data/firestore_user_progress_repository.dart';
import 'package:runiac_app/features/you/domain/models/user_progress_read_model.dart';
import 'package:runiac_app/features/you/domain/repositories/user_progress_repository.dart';

import 'support/fake_runiac_auth_repository.dart';

void main() {
  test(
    'maps backend-owned streak count into singular official label',
    () async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      final repository = FirestoreUserProgressRepository(
        authRepository: authRepository,
        reader: const _FakeUserProgressDocumentReader({'streakCount': 1}),
      );

      final progress = await repository.loadUserProgress();

      expect(progress.officialStreakLabel, '1 day');
    },
  );

  test('maps backend-owned streak count into plural official label', () async {
    final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
    final repository = FirestoreUserProgressRepository(
      authRepository: authRepository,
      reader: const _FakeUserProgressDocumentReader({'streakCount': 17}),
    );

    final progress = await repository.loadUserProgress();

    expect(progress.officialStreakLabel, '17 days');
  });

  test('uses fallback progress when no user is signed in', () async {
    final repository = FirestoreUserProgressRepository(
      authRepository: FakeRuniacAuthRepository(),
      reader: const _FakeUserProgressDocumentReader({'streakCount': 17}),
      fallbackRepository: const _FallbackUserProgressRepository(),
    );

    final progress = await repository.loadUserProgress();

    expect(progress.officialStreakLabel, 'fallback');
  });
}

class _FakeUserProgressDocumentReader implements UserProgressDocumentReader {
  const _FakeUserProgressDocumentReader(this.document);

  final Map<String, Object?>? document;

  @override
  Future<Map<String, Object?>?> readUserProgress({required String uid}) async {
    return document;
  }
}

class _FallbackUserProgressRepository implements UserProgressRepository {
  const _FallbackUserProgressRepository();

  @override
  Future<UserProgressReadModel> loadUserProgress() async {
    return const UserProgressReadModel(
      userId: 'fallback-user',
      officialStreakLabel: 'fallback',
      levelLabel: '',
      totalXpLabel: '',
      weeklyXpLabel: '',
      monthlyXpLabel: '',
      weeklyDistanceLabel: '',
      goalProgressLabel: '',
    );
  }
}
