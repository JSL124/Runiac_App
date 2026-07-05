import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/core/theme/runiac_colors.dart';
import 'package:runiac_app/features/account/data/firestore_user_profile_repository.dart';
import 'package:runiac_app/features/account/domain/models/user_profile_read_model.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_repository.dart';
import 'package:runiac_app/features/auth/domain/runiac_auth_service.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/repositories/generated_plan_persistence_repository.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';

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
              previewNote: '',
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
    'Account profile shows email verification prompt for unverified user and resends successfully',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository();
      addTearDown(authRepository.dispose);
      authRepository.emitSignedIn(emailVerified: false);

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showAuth: true,
          enableForegroundGps: false,
          authRepository: authRepository,
          profileRepository: _SingleProfileRepository(_savedProfile()),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.text('Resend email'), findsOneWidget);

      await tester.tap(find.text('Resend email'));
      await tester.pumpAndSettle();

      expect(authRepository.sendEmailVerificationCalls, 1);
      expect(find.text('Verification email sent.'), findsWidgets);
    },
  );

  testWidgets('Account profile shows auth error when resend fails', (
    tester,
  ) async {
    final authRepository = FakeRuniacAuthRepository(
      emailVerificationError: const RuniacAuthException(
        code: RuniacAuthErrorCode.tooManyRequests,
        userMessage: 'Too many attempts. Please wait a moment and try again.',
      ),
    );
    addTearDown(authRepository.dispose);
    authRepository.emitSignedIn(emailVerified: false);

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showAuth: true,
        enableForegroundGps: false,
        authRepository: authRepository,
        profileRepository: _SingleProfileRepository(_savedProfile()),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resend email'));
    await tester.pumpAndSettle();

    expect(authRepository.sendEmailVerificationCalls, 1);
    expect(
      find.text('Too many attempts. Please wait a moment and try again.'),
      findsWidgets,
    );
  });

  testWidgets(
    'Edit profile shows read-only email and editable personal fields',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository();
      addTearDown(authRepository.dispose);
      authRepository.emitSignedIn();
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();
      final profileRepository = _MutableProfileRepository(
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
            UserProfileInfoItemReadModel(title: 'Current goal', value: 'habit'),
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
      );
      final persistenceRepository = _RecordingUserProfilePersistenceRepository(
        onSaveOnboardingProfile: (profile) {
          profileRepository.profile = UserProfileReadModel(
            userId: 'test-auth-user-1',
            displayName: profile.displayName,
            fullName: profile.fullName,
            nickname: profile.nickname,
            avatarInitials: profile.avatarInitials,
            dateOfBirthIso: profile.dateOfBirthIso,
            ageYears: profile.ageYears,
            weightKg: profile.weightKg,
            locationLabel: profile.locationLabel,
            previewNote: '',
            setupSectionLabel: 'RUNNING SETUP',
            manageSectionLabel: 'MANAGE',
            footerCaption: 'Runiac · Preview build · Built for new runners',
            setupItems: <UserProfileInfoItemReadModel>[
              UserProfileInfoItemReadModel(
                title: 'Current goal',
                value: profile.goals.join(', '),
              ),
              UserProfileInfoItemReadModel(
                title: 'Weekly rhythm',
                value:
                    '${profile.availability['weeklySessions']} sessions / week',
              ),
              UserProfileInfoItemReadModel(
                title: 'Experience',
                value: profile.fitnessLevel,
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
          );
        },
      );
      final generatedPlanPersistenceRepository =
          _RecordingGeneratedPlanPersistenceRepository();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showAuth: true,
          enableForegroundGps: false,
          authRepository: authRepository,
          profilePersistenceRepository: persistenceRepository,
          generatedPlanPersistenceRepository:
              generatedPlanPersistenceRepository,
          currentSessionGeneratedPlanStore: generatedPlanStore,
          profileRepository: profileRepository,
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
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Nickname is available.'), findsOneWidget);
      expect(
        _textColor(tester, 'Nickname is available.'),
        RuniacColors.successGreen,
      );
      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      await tester.enterText(
        find.bySemanticsLabel('Weight in kilograms'),
        '59',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<EditableText>()),
      );
      await tester.ensureVisible(find.bySemanticsLabel('Region'));
      await tester.tap(find.bySemanticsLabel('Region'));
      await tester.pumpAndSettle();
      expect(find.text('Tiong Bahru, Singapore'), findsOneWidget);
      await tapText(tester, 'Tiong Bahru, Singapore');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Retake onboarding'));
      await tester.tap(find.text('Retake onboarding'));
      await tester.pumpAndSettle();
      await completeOnboardingToFourSessionPreview(tester);
      await tapText(tester, 'Continue with this plan');
      await tester.pumpAndSettle();

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
      expect(
        persistenceRepository.onboardingProfile?.planCautiousness,
        'performance',
      );
      expect(generatedPlanStore.activePlan?.title, '10K Performance Build');
      expect(generatedPlanPersistenceRepository.savedUid, 'test-auth-user-1');
      expect(
        generatedPlanPersistenceRepository.savedPlan?.title,
        '10K Performance Build',
      );
      expect(
        generatedPlanPersistenceRepository
            .savedPlan
            ?.weeks
            .first
            .workouts
            .first
            .detail
            .coachNotes,
        isNotEmpty,
      );
      expect(profileRepository.loadCount, 2);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('4 sessions / week'), findsOneWidget);
      expect(find.text('3 sessions / week'), findsNothing);
    },
  );

  testWidgets('Edit profile refreshes Account after saving personal fields', (
    tester,
  ) async {
    final authRepository = FakeRuniacAuthRepository();
    addTearDown(authRepository.dispose);
    authRepository.emitSignedIn();
    final profileRepository = _MutableProfileRepository(
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
    );
    final persistenceRepository = _RecordingUserProfilePersistenceRepository(
      onSavePersonalProfile: (profile) {
        profileRepository.profile = UserProfileReadModel(
          userId: 'test-auth-user-1',
          displayName: profile.displayName,
          fullName: profile.fullName,
          nickname: profile.nickname,
          avatarInitials: profile.avatarInitials,
          dateOfBirthIso: profile.dateOfBirthIso,
          ageYears: profile.ageYears,
          weightKg: profile.weightKg,
          locationLabel: profile.locationLabel,
          previewNote: '',
          setupSectionLabel: 'RUNNING SETUP',
          manageSectionLabel: 'MANAGE',
          footerCaption: 'Runiac · Preview build · Built for new runners',
          manageRows: const <UserProfileManageRowReadModel>[
            UserProfileManageRowReadModel(
              title: 'Edit profile',
              subtitle: 'Email, personal details, and onboarding',
              snackBarMessage: '',
              action: UserProfileManageAction.editProfile,
            ),
          ],
        );
      },
    );

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showAuth: true,
        enableForegroundGps: false,
        authRepository: authRepository,
        profileRepository: profileRepository,
        profilePersistenceRepository: persistenceRepository,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Maya'), findsOneWidget);
    await tester.ensureVisible(find.text('Edit profile'));
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Name'), 'Jess Lee');
    await tester.enterText(find.bySemanticsLabel('Nickname'), 'Jess');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.bySemanticsLabel('Weight in kilograms'), '61');
    await tester.ensureVisible(find.bySemanticsLabel('Region'));
    await tester.tap(find.bySemanticsLabel('Region'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Orchard, Singapore');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Jess'), findsOneWidget);
    expect(find.text('Maya'), findsNothing);
    expect(find.text('Orchard, Singapore'), findsOneWidget);
    expect(profileRepository.loadCount, 2);
  });

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
    await tester.pump(const Duration(milliseconds: 500));
    expect(persistenceRepository.checkedNickname, 'TakenRunner');
    expect(find.text('Nickname is already taken.'), findsOneWidget);
    expect(
      _textColor(tester, 'Nickname is already taken.'),
      RuniacColors.errorRed,
    );
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Nickname is already taken.'), findsOneWidget);
    expect(persistenceRepository.personalProfile, isNull);
  });

  testWidgets('Edit profile explains when nickname rules block checking', (
    tester,
  ) async {
    final authRepository = FakeRuniacAuthRepository();
    addTearDown(authRepository.dispose);
    authRepository.emitSignedIn();
    final persistenceRepository = _RecordingUserProfilePersistenceRepository(
      nicknameCheckError: const NicknameAvailabilityCheckException(
        NicknameAvailabilityFailureReason.rulesUnavailable,
      ),
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

    await tester.enterText(find.bySemanticsLabel('Nickname'), 'Jinseo Lee');
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text(
        'Nickname check is blocked by Firestore rules. Deploy the updated rules or use the emulator.',
      ),
      findsOneWidget,
    );
    expect(persistenceRepository.personalProfile, isNull);
  });

  testWidgets(
    'Account profile shows recovery UI when authenticated profile is missing',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository();
      addTearDown(authRepository.dispose);
      authRepository.emitSignedIn();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showAuth: true,
          enableForegroundGps: false,
          authRepository: authRepository,
          profileRepository: FirestoreUserProfileRepository(
            authRepository: authRepository,
            reader: const _MissingUserProfileDocumentReader(),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile setup was not found'), findsOneWidget);
      expect(find.text('Set up profile'), findsOneWidget);
      expect(find.text('Runiac Runner'), findsNothing);

      await tester.tap(find.text('Set up profile'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Profile recovery setup requires completing signup/onboarding again.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Account profile shows loading state while profile is loading', (
    tester,
  ) async {
    final profileCompleter = Completer<UserProfileReadModel>();

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        enableForegroundGps: false,
        profileRepository: _CompletingProfileRepository(
          profileCompleter.future,
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Loading profile...'), findsOneWidget);
    expect(find.text('Runiac Runner'), findsNothing);

    profileCompleter.complete(_savedProfile());
    await tester.pumpAndSettle();

    expect(find.text('Loading profile...'), findsNothing);
    expect(find.text('Maya'), findsOneWidget);
  });

  testWidgets(
    'Edit profile retake waits when generated plan persistence fails',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository();
      addTearDown(authRepository.dispose);
      authRepository.emitSignedIn();
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();
      final profileRepository = _MutableProfileRepository(_savedProfile());
      final persistenceRepository = _RecordingUserProfilePersistenceRepository(
        onSaveOnboardingProfile: (profile) {
          profileRepository.profile = UserProfileReadModel(
            userId: 'test-auth-user-1',
            displayName: profile.displayName,
            fullName: profile.fullName,
            nickname: profile.nickname,
            avatarInitials: profile.avatarInitials,
            ageYears: profile.ageYears,
            weightKg: profile.weightKg,
            locationLabel: profile.locationLabel,
            setupItems: <UserProfileInfoItemReadModel>[
              UserProfileInfoItemReadModel(
                title: 'Weekly rhythm',
                value:
                    '${profile.availability['weeklySessions']} sessions / week',
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
          );
        },
      );
      final generatedPlanPersistenceRepository =
          _RecordingGeneratedPlanPersistenceRepository()..failNextSave = true;

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showAuth: true,
          enableForegroundGps: false,
          authRepository: authRepository,
          profilePersistenceRepository: persistenceRepository,
          generatedPlanPersistenceRepository:
              generatedPlanPersistenceRepository,
          currentSessionGeneratedPlanStore: generatedPlanStore,
          profileRepository: profileRepository,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Edit profile'));
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Retake onboarding'));
      await tester.tap(find.text('Retake onboarding'));
      await tester.pumpAndSettle();
      await completeOnboardingToPreview(tester);
      await tapText(tester, 'Continue with this plan');
      await tester.pumpAndSettle();
      final reportedError = tester.takeException();

      expect(find.text('Account'), findsNothing);
      expect(generatedPlanStore.activePlan, isNull);
      expect(persistenceRepository.onboardingProfile, isNotNull);
      expect(generatedPlanPersistenceRepository.saveCalls, 1);
      expect(
        find.text('We could not save your onboarding result. Try again.'),
        findsOneWidget,
      );
      expect(reportedError, isA<StateError>());
    },
  );

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

Color? _textColor(WidgetTester tester, String text) {
  return tester.widget<Text>(find.text(text)).style?.color;
}

UserProfileReadModel _savedProfile() {
  return UserProfileReadModel(
    userId: 'test-auth-user-1',
    displayName: 'Maya Tan',
    fullName: 'Maya Tan',
    nickname: 'Maya',
    avatarInitials: 'MT',
    dateOfBirthIso: '2002-06-28',
    ageYears: 24,
    weightKg: 58.5,
    locationLabel: 'Queenstown, Singapore',
    previewNote: '',
    setupSectionLabel: 'RUNNING SETUP',
    manageSectionLabel: 'MANAGE',
    footerCaption: 'Runiac · Preview build · Built for new runners',
    setupItems: const <UserProfileInfoItemReadModel>[
      UserProfileInfoItemReadModel(
        title: 'Current goal',
        value: 'First relaxed 5K',
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
  );
}

class _SingleProfileRepository implements UserProfileRepository {
  const _SingleProfileRepository(this.profile);

  final UserProfileReadModel profile;

  @override
  Future<UserProfileReadModel> loadUserProfile() async => profile;
}

class _CompletingProfileRepository implements UserProfileRepository {
  const _CompletingProfileRepository(this.profile);

  final Future<UserProfileReadModel> profile;

  @override
  Future<UserProfileReadModel> loadUserProfile() => profile;
}

class _MissingUserProfileDocumentReader implements UserProfileDocumentReader {
  const _MissingUserProfileDocumentReader();

  @override
  Future<UserProfileDocumentReadResult> readUserProfile({
    required String uid,
  }) async {
    return const UserProfileDocumentReadResult.missing();
  }
}

class _MutableProfileRepository implements UserProfileRepository {
  _MutableProfileRepository(this.profile);

  UserProfileReadModel profile;
  int loadCount = 0;

  @override
  Future<UserProfileReadModel> loadUserProfile() async {
    loadCount += 1;
    return profile;
  }
}

class _RecordingGeneratedPlanPersistenceRepository
    implements GeneratedPlanPersistenceRepository {
  String? savedUid;
  BeginnerAdaptivePlanSnapshot? savedPlan;
  bool failNextSave = false;
  int saveCalls = 0;

  @override
  Future<BeginnerAdaptivePlanSnapshot?> loadGeneratedPlan({
    required String uid,
  }) async {
    return null;
  }

  @override
  Future<void> saveGeneratedPlan({
    required String uid,
    required BeginnerAdaptivePlanSnapshot plan,
  }) async {
    saveCalls += 1;
    if (failNextSave) {
      failNextSave = false;
      throw StateError('generated plan save failed');
    }
    savedUid = uid;
    savedPlan = plan;
  }
}

class _RecordingUserProfilePersistenceRepository
    implements UserProfilePersistenceRepository {
  _RecordingUserProfilePersistenceRepository({
    this.nicknameAvailable = true,
    this.nicknameCheckError,
    this.onSaveOnboardingProfile,
    this.onSavePersonalProfile,
  });

  final bool nicknameAvailable;
  final NicknameAvailabilityCheckException? nicknameCheckError;
  final ValueChanged<UserProfileOnboardingSnapshot>? onSaveOnboardingProfile;
  final ValueChanged<UserProfilePersonalSnapshot>? onSavePersonalProfile;
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
    if (nicknameCheckError != null) {
      throw nicknameCheckError!;
    }
    return nicknameAvailable;
  }

  @override
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  }) async {
    this.uid = uid;
    onboardingProfile = profile;
    onSaveOnboardingProfile?.call(profile);
  }

  @override
  Future<void> savePersonalProfile({
    required String uid,
    required UserProfilePersonalSnapshot profile,
  }) async {
    this.uid = uid;
    personalProfile = profile;
    onSavePersonalProfile?.call(profile);
  }
}
