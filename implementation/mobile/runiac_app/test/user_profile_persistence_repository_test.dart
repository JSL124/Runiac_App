import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/data/firestore_user_profile_persistence_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_persistence_repository.dart';

void main() {
  group('UserProfileOnboardingSnapshot', () {
    test('serializes only client-owned onboarding profile fields', () {
      final snapshot = UserProfileOnboardingSnapshot(
        displayName: 'Maya',
        fullName: 'Maya Tan',
        nickname: 'Maya',
        avatarInitials: 'M',
        nicknameKey: 'maya',
        dateOfBirthIso: '2002-06-28',
        ageYears: 24,
        weightKg: 58.5,
        locationLabel: 'Queenstown, Singapore',
        fitnessLevel: 'new',
        goals: const <String>['habit'],
        availability: const <String, Object>{
          'weeklySessions': '3',
          'preferredDays': <String>['Mon', 'Wed', 'Fri'],
          'preferredTime': 'morning',
          'sessionLengthMinutes': '20',
        },
        planCautiousness: 'balanced',
        healthSafetyReadiness: const <String, Object>{
          'comfort': 'ready',
          'activitySymptoms': <String>['none'],
          'recentRunningConsistency': 'none',
          'currentWeeklyRunFrequency': '0',
          'continuousRunCapacity': 'walk',
          'runningPlace': 'park',
          'motivationStyle': 'reminders',
        },
      );

      final document = snapshot.toFirestoreDocument(updatedAt: 1);

      expect(document.keys, <String>[
        'displayName',
        'fullName',
        'nickname',
        'avatarInitials',
        'nicknameKey',
        'dateOfBirth',
        'ageYears',
        'weightKg',
        'locationLabel',
        'fitnessLevel',
        'goals',
        'availability',
        'planCautiousness',
        'healthSafetyReadiness',
        'updatedAt',
      ]);
      expect(document, isNot(containsPair('xp', anything)));
      expect(document, isNot(containsPair('level', anything)));
      expect(document, isNot(containsPair('rank', anything)));
      expect(document, isNot(containsPair('streak', anything)));
      expect(document, isNot(containsPair('subscriptionStatus', anything)));
      expect(document, isNot(containsPair('userRole', anything)));
      expect(document, isNot(containsPair('email', anything)));
    });

    test('serializes only changed personal profile fields', () {
      final snapshot = UserProfilePersonalSnapshot(
        fullName: 'Maya Tan',
        nickname: 'May',
        nicknameKey: 'may',
        dateOfBirthIso: '2000-01-01',
        ageYears: 26,
        weightKg: 59,
        locationLabel: 'Tiong Bahru, Singapore',
      );

      final document = snapshot.toFirestoreDocument(updatedAt: 2);

      expect(document, <String, Object>{
        'displayName': 'May',
        'fullName': 'Maya Tan',
        'nickname': 'May',
        'avatarInitials': 'M',
        'nicknameKey': 'may',
        'dateOfBirth': '2000-01-01',
        'ageYears': 26,
        'weightKg': 59,
        'locationLabel': 'Tiong Bahru, Singapore',
        'updatedAt': 2,
      });
      expect(document, isNot(containsPair('email', anything)));
      expect(document, isNot(containsPair('fitnessLevel', anything)));
    });
  });

  group('FirestoreUserProfilePersistenceRepository', () {
    test(
      'merges the onboarding profile under the authenticated user id',
      () async {
        final writer = _RecordingUserProfileDocumentWriter();
        final repository = FirestoreUserProfilePersistenceRepository(
          writer: writer,
          updatedAt: () => 42,
        );

        await repository.saveOnboardingProfile(
          uid: 'test-auth-user-1',
          profile: UserProfileOnboardingSnapshot(
            displayName: 'Maya',
            fullName: 'Maya Tan',
            nickname: 'Maya',
            avatarInitials: 'M',
            nicknameKey: 'maya',
            dateOfBirthIso: '2002-06-28',
            ageYears: 24,
            weightKg: 58.5,
            locationLabel: 'Queenstown, Singapore',
            fitnessLevel: 'new',
            goals: const <String>['habit'],
            availability: const <String, Object>{
              'weeklySessions': '3',
              'preferredDays': <String>['Mon', 'Wed', 'Fri'],
              'preferredTime': 'morning',
              'sessionLengthMinutes': '20',
            },
            planCautiousness: 'balanced',
            healthSafetyReadiness: const <String, Object>{
              'comfort': 'ready',
              'activitySymptoms': <String>['none'],
              'recentRunningConsistency': 'none',
              'currentWeeklyRunFrequency': '0',
              'continuousRunCapacity': 'walk',
              'runningPlace': 'park',
              'motivationStyle': 'reminders',
            },
          ),
        );

        expect(writer.uid, 'test-auth-user-1');
        expect(writer.data?['updatedAt'], 42);
        expect(writer.data?['displayName'], 'Maya');
        expect(writer.data?['fullName'], 'Maya Tan');
        expect(writer.data?['nickname'], 'Maya');
        expect(writer.data?['avatarInitials'], 'M');
        expect(writer.data?['nicknameKey'], 'maya');
        expect(writer.data?['dateOfBirth'], '2002-06-28');
        expect(writer.data?['ageYears'], 24);
        expect(writer.data?['weightKg'], 58.5);
        expect(writer.data?['locationLabel'], 'Queenstown, Singapore');
        expect(writer.data?['fitnessLevel'], 'new');
        expect(
          writer.data,
          isNot(containsPair('subscriptionStatus', anything)),
        );
        expect(writer.data, isNot(containsPair('userRole', anything)));
      },
    );

    test(
      'merges personal profile updates without onboarding or email fields',
      () async {
        final writer = _RecordingUserProfileDocumentWriter();
        final repository = FirestoreUserProfilePersistenceRepository(
          writer: writer,
          updatedAt: () => 43,
        );

        await repository.savePersonalProfile(
          uid: 'test-auth-user-1',
          profile: UserProfilePersonalSnapshot(
            fullName: 'Maya Tan',
            nickname: 'May',
            nicknameKey: 'may',
            dateOfBirthIso: '2000-01-01',
            ageYears: 26,
            weightKg: 59,
            locationLabel: 'Tiong Bahru, Singapore',
          ),
        );

        expect(writer.uid, 'test-auth-user-1');
        expect(writer.data?['updatedAt'], 43);
        expect(writer.data?['displayName'], 'May');
        expect(writer.data?['nicknameKey'], 'may');
        expect(writer.data?['dateOfBirth'], '2000-01-01');
        expect(writer.data?['locationLabel'], 'Tiong Bahru, Singapore');
        expect(writer.data, isNot(containsPair('email', anything)));
        expect(writer.data, isNot(containsPair('fitnessLevel', anything)));
        expect(writer.data, isNot(containsPair('goals', anything)));
      },
    );

    test('normalizes nickname keys consistently', () {
      final draft = PersonalProfileDraft.tryCreate(
        fullName: 'Maya Tan',
        nickname: '  May Runner  ',
        dateOfBirthIso: '2000-01-01',
        weightKg: '59',
        locationLabel: 'Orchard, Singapore',
      );

      expect(draft, isNotNull);
      expect(draft?.nicknameKey, 'may-runner');
      expect(draft?.ageYears, 26);
    });
  });
}

class _RecordingUserProfileDocumentWriter implements UserProfileDocumentWriter {
  String? uid;
  Map<String, Object>? data;
  String? nickname;
  String? nicknameKey;

  @override
  Future<bool> isNicknameAvailable({
    required String uid,
    required String nicknameKey,
  }) async {
    this.uid = uid;
    this.nicknameKey = nicknameKey;
    return true;
  }

  @override
  Future<void> mergeUserProfile({
    required String uid,
    required Map<String, Object> data,
    required String nickname,
    required String nicknameKey,
  }) async {
    this.uid = uid;
    this.data = Map<String, Object>.from(data);
    this.nickname = nickname;
    this.nicknameKey = nicknameKey;
  }
}
