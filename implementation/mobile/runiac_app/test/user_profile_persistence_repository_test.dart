import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/data/firestore_user_profile_persistence_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_persistence_repository.dart';

void main() {
  group('UserProfileOnboardingSnapshot', () {
    test('serializes only client-owned onboarding profile fields', () {
      final snapshot = UserProfileOnboardingSnapshot(
        displayName: 'Runiac Runner',
        avatarInitials: 'RR',
        locationLabel: 'Not set yet',
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
        'avatarInitials',
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
            displayName: 'Runiac Runner',
            avatarInitials: 'RR',
            locationLabel: 'Not set yet',
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
        expect(writer.data?['displayName'], 'Runiac Runner');
        expect(writer.data?['avatarInitials'], 'RR');
        expect(writer.data?['locationLabel'], 'Not set yet');
        expect(writer.data?['fitnessLevel'], 'new');
        expect(
          writer.data,
          isNot(containsPair('subscriptionStatus', anything)),
        );
        expect(writer.data, isNot(containsPair('userRole', anything)));
      },
    );
  });
}

class _RecordingUserProfileDocumentWriter implements UserProfileDocumentWriter {
  String? uid;
  Map<String, Object>? data;

  @override
  Future<void> mergeUserProfile({
    required String uid,
    required Map<String, Object> data,
  }) async {
    this.uid = uid;
    this.data = Map<String, Object>.from(data);
  }
}
