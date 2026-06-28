import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/account/domain/models/user_profile_read_model.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_repository.dart';

import 'support/fake_runiac_auth_repository.dart';
import 'support/onboarding_flow_test_helpers.dart';

void main() {
  testWidgets(
    'Account profile displays saved profile values from the repository',
    (tester) async {
      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          enableForegroundGps: false,
          profileRepository: _SingleProfileRepository(
            UserProfileReadModel(
              userId: 'test-auth-user-1',
              displayName: 'Maya Tan',
              fullName: 'Maya Tan',
              nickname: 'Maya',
              avatarInitials: 'MT',
              ageYears: 24,
              weightKg: 58.5,
              locationLabel: 'Queenstown, Singapore',
              previewLevelBadge: '',
              previewNote: 'Loaded from your saved profile.',
              setupSectionLabel: 'RUNNING SETUP',
              manageSectionLabel: 'MANAGE',
              footerCaption: 'Runiac · Preview build · Built for new runners',
              setupItems: const <UserProfileInfoItemReadModel>[
                UserProfileInfoItemReadModel(
                  title: 'Current goal',
                  value: 'First relaxed 5K',
                ),
                UserProfileInfoItemReadModel(
                  title: 'Weekly rhythm',
                  value: '4 sessions / week',
                ),
                UserProfileInfoItemReadModel(
                  title: 'Experience',
                  value: 'Returning runner',
                ),
              ],
              manageRows: const <UserProfileManageRowReadModel>[
                UserProfileManageRowReadModel(
                  title: 'Edit profile',
                  subtitle: 'Email, personal details, and onboarding',
                  snackBarMessage: '',
                  action: UserProfileManageAction.editProfile,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Maya'), findsOneWidget);
      expect(find.text('MT'), findsOneWidget);
      expect(find.text('Queenstown, Singapore'), findsOneWidget);
      expect(find.text('Lv. 12'), findsNothing);
      expect(find.text('First relaxed 5K'), findsOneWidget);
      expect(find.text('4 sessions / week'), findsOneWidget);
      expect(find.text('Returning runner'), findsOneWidget);
    },
  );

  testWidgets(
    'Edit profile shows read-only email and editable personal fields',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository();
      addTearDown(authRepository.dispose);
      authRepository.emitSignedIn();
      final persistenceRepository =
          _RecordingUserProfilePersistenceRepository();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showAuth: true,
          enableForegroundGps: false,
          authRepository: authRepository,
          profilePersistenceRepository: persistenceRepository,
          profileRepository: _SingleProfileRepository(
            UserProfileReadModel(
              userId: 'test-auth-user-1',
              displayName: 'Maya',
              fullName: 'Maya Tan',
              nickname: 'Maya',
              avatarInitials: 'M',
              dateOfBirthIso: '2000-01-01',
              ageYears: 24,
              weightKg: 58.5,
              locationLabel: 'Queenstown',
              setupItems: const <UserProfileInfoItemReadModel>[
                UserProfileInfoItemReadModel(
                  title: 'Current goal',
                  value: 'habit',
                ),
                UserProfileInfoItemReadModel(
                  title: 'Weekly rhythm',
                  value: '3 sessions / week',
                ),
                UserProfileInfoItemReadModel(title: 'Experience', value: 'new'),
              ],
              manageRows: const <UserProfileManageRowReadModel>[
                UserProfileManageRowReadModel(
                  title: 'Edit profile',
                  subtitle: 'Email, personal details, and onboarding',
                  snackBarMessage: '',
                  action: UserProfileManageAction.editProfile,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Edit profile'));
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();

      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('runner@runiac.app'), findsOneWidget);
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Onboarding result'), findsOneWidget);
      expect(find.text('Retake onboarding'), findsOneWidget);

      await tester.enterText(find.bySemanticsLabel('Nickname'), 'May');
      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      await tester.enterText(
        find.bySemanticsLabel('Weight in kilograms'),
        '59',
      );
      await tester.tap(find.bySemanticsLabel('Region'));
      await tester.pumpAndSettle();
      expect(find.text('Tiong Bahru, Singapore'), findsOneWidget);
      await tapText(tester, 'Tiong Bahru, Singapore');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(persistenceRepository.uid, 'test-auth-user-1');
      expect(persistenceRepository.checkedNickname, 'May');
      expect(persistenceRepository.personalProfile?.nickname, 'May');
      expect(
        persistenceRepository.personalProfile?.dateOfBirthIso,
        '2000-01-01',
      );
      expect(persistenceRepository.personalProfile?.ageYears, 26);
      expect(persistenceRepository.personalProfile?.weightKg, 59);
      expect(
        persistenceRepository.personalProfile?.locationLabel,
        'Tiong Bahru, Singapore',
      );

      await tester.ensureVisible(find.text('Retake onboarding'));
      await tester.tap(find.text('Retake onboarding'));
      await tester.pumpAndSettle();
      await completeOnboardingToPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(persistenceRepository.onboardingProfile?.nickname, 'May');
      expect(
        persistenceRepository.onboardingProfile?.dateOfBirthIso,
        '2000-01-01',
      );
      expect(persistenceRepository.onboardingProfile?.ageYears, 26);
      expect(persistenceRepository.onboardingProfile?.weightKg, 59);
      expect(
        persistenceRepository.onboardingProfile?.locationLabel,
        'Tiong Bahru, Singapore',
      );
    },
  );

  testWidgets('Edit profile blocks duplicate nickname before saving', (
    tester,
  ) async {
    final authRepository = FakeRuniacAuthRepository();
    addTearDown(authRepository.dispose);
    authRepository.emitSignedIn();
    final persistenceRepository = _RecordingUserProfilePersistenceRepository(
      nicknameAvailable: false,
    );

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showAuth: true,
        enableForegroundGps: false,
        authRepository: authRepository,
        profilePersistenceRepository: persistenceRepository,
        profileRepository: _SingleProfileRepository(
          UserProfileReadModel(
            userId: 'test-auth-user-1',
            displayName: 'Maya',
            fullName: 'Maya Tan',
            nickname: 'Maya',
            avatarInitials: 'M',
            dateOfBirthIso: '2000-01-01',
            ageYears: 24,
            weightKg: 58.5,
            locationLabel: 'Queenstown, Singapore',
            manageRows: const <UserProfileManageRowReadModel>[
              UserProfileManageRowReadModel(
                title: 'Edit profile',
                subtitle: 'Email, personal details, and onboarding',
                snackBarMessage: '',
                action: UserProfileManageAction.editProfile,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit profile'));
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Nickname'), 'TakenRunner');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(persistenceRepository.checkedNickname, 'TakenRunner');
    expect(find.text('Nickname is already taken.'), findsOneWidget);
    expect(persistenceRepository.personalProfile, isNull);
  });

  testWidgets('Account profile falls back to the demo profile snapshot', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Runiac Runner'), findsOneWidget);
    expect(find.text('RR'), findsOneWidget);
    expect(find.text('Jurong East, Singapore'), findsOneWidget);
    expect(find.text('Lv. 12'), findsOneWidget);
    expect(find.text('Build a consistent 10K habit'), findsOneWidget);
  });
}

class _SingleProfileRepository implements UserProfileRepository {
  const _SingleProfileRepository(this.profile);

  final UserProfileReadModel profile;

  @override
  Future<UserProfileReadModel> loadUserProfile() async => profile;
}

class _RecordingUserProfilePersistenceRepository
    implements UserProfilePersistenceRepository {
  _RecordingUserProfilePersistenceRepository({this.nicknameAvailable = true});

  final bool nicknameAvailable;
  String? uid;
  String? checkedNickname;
  UserProfilePersonalSnapshot? personalProfile;
  UserProfileOnboardingSnapshot? onboardingProfile;

  @override
  Future<bool> isNicknameAvailable({
    required String uid,
    required String nickname,
  }) async {
    checkedNickname = nickname;
    return nicknameAvailable;
  }

  @override
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  }) async {
    this.uid = uid;
    onboardingProfile = profile;
  }

  @override
  Future<void> savePersonalProfile({
    required String uid,
    required UserProfilePersonalSnapshot profile,
  }) async {
    this.uid = uid;
    personalProfile = profile;
  }
}
