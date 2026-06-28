import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/data/firestore_user_profile_repository.dart';
import 'package:runiac_app/features/account/presentation/data/account_profile_demo_snapshots.dart';

import 'support/fake_runiac_auth_repository.dart';

void main() {
  group('FirestoreUserProfileRepository', () {
    test('reads the current auth user profile document', () async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      final reader = _FakeUserProfileDocumentReader(
        documents: const <String, UserProfileDocumentReadResult>{
          'test-auth-user-1': UserProfileDocumentReadResult.exists(
            <String, Object?>{
              'displayName': 'Maya Tan',
              'avatarInitials': 'MT',
              'locationLabel': 'Queenstown, Singapore',
              'fitnessLevel': 'Returning runner',
              'goals': <String>['First relaxed 5K', 'Consistent habit'],
              'availability': <String, Object?>{'weeklySessions': '4'},
              'xp': 999999,
              'level': 99,
              'rank': 1,
              'leaderboardScore': 123456,
              'weeklyXp': 5000,
              'monthlyXp': 20000,
              'subscriptionStatus': 'premium',
              'userRole': 'platformAdministrator',
            },
          ),
        },
      );
      final repository = FirestoreUserProfileRepository(
        authRepository: authRepository,
        reader: reader,
      );

      final profile = await repository.loadUserProfile();

      expect(reader.readUids, <String>['test-auth-user-1']);
      expect(profile.userId, 'test-auth-user-1');
      expect(profile.displayName, 'Maya Tan');
      expect(profile.avatarInitials, 'MT');
      expect(profile.locationLabel, 'Queenstown, Singapore');
      expect(profile.previewLevelBadge, isEmpty);
      expect(
        profile.setupItems.map((item) => item.value),
        isNot(contains('99')),
      );
      expect(
        profile.setupItems.map((item) => item.value),
        isNot(contains('999999')),
      );
      expect(
        profile.setupItems.map((item) => item.value),
        containsAll(<String>[
          'First relaxed 5K, Consistent habit',
          '4 sessions / week',
          'Returning runner',
        ]),
      );
    });

    test('falls back to the demo profile when signed out', () async {
      final reader = _FakeUserProfileDocumentReader();
      final repository = FirestoreUserProfileRepository(
        authRepository: FakeRuniacAuthRepository(),
        reader: reader,
      );

      final profile = await repository.loadUserProfile();

      expect(reader.readUids, isEmpty);
      expect(profile.displayName, accountProfileDemoSnapshot.displayName);
      expect(profile.locationLabel, accountProfileDemoSnapshot.regionLabel);
    });

    test(
      'throws a recovery exception for missing signed-in profiles',
      () async {
        final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
        final repository = FirestoreUserProfileRepository(
          authRepository: authRepository,
          reader: _FakeUserProfileDocumentReader(),
        );

        await expectLater(
          repository.loadUserProfile(),
          throwsA(
            isA<CurrentUserProfileException>()
                .having((error) => error.uid, 'uid', 'test-auth-user-1')
                .having(
                  (error) => error.reason,
                  'reason',
                  CurrentUserProfileFailureReason.missing,
                ),
          ),
        );
      },
    );

    test('throws a recovery exception for malformed identity fields', () async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      final repository = FirestoreUserProfileRepository(
        authRepository: authRepository,
        reader: _FakeUserProfileDocumentReader(
          documents: const <String, UserProfileDocumentReadResult>{
            'test-auth-user-1':
                UserProfileDocumentReadResult.exists(<String, Object?>{
                  'displayName': 'Maya Tan',
                  'avatarInitials': '',
                  'locationLabel': 'Queenstown, Singapore',
                }),
          },
        ),
      );

      await expectLater(
        repository.loadUserProfile(),
        throwsA(
          isA<CurrentUserProfileException>()
              .having((error) => error.uid, 'uid', 'test-auth-user-1')
              .having(
                (error) => error.reason,
                'reason',
                CurrentUserProfileFailureReason.invalid,
              ),
        ),
      );
    });
  });
}

class _FakeUserProfileDocumentReader implements UserProfileDocumentReader {
  _FakeUserProfileDocumentReader({
    this.documents = const <String, UserProfileDocumentReadResult>{},
  });

  final Map<String, UserProfileDocumentReadResult> documents;
  final List<String> readUids = <String>[];

  @override
  Future<UserProfileDocumentReadResult> readUserProfile({
    required String uid,
  }) async {
    readUids.add(uid);
    return documents[uid] ?? const UserProfileDocumentReadResult.missing();
  }
}
