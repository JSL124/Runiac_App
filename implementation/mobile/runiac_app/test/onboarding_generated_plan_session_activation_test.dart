import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';

import 'support/fake_runiac_auth_repository.dart';
import 'support/onboarding_flow_test_helpers.dart';
import 'support/plan_family_test_drafts.dart';

void main() {
  testWidgets(
    'eligible onboarding completion activates generated running plan session',
    (tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showOnboarding: true,
          enableForegroundGps: false,
          currentSessionGeneratedPlanStore: generatedPlanStore,
        ),
      );

      await completeOnboardingToFourSessionPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsOneWidget);
      expect(generatedPlanStore.activePlan, isNotNull);
      expect(generatedPlanStore.activePlan!.title, '10K Performance Build');
      expect(generatedPlanStore.currentWeekRunningSessionCount, 4);
    },
  );

  testWidgets(
    'starter onboarding completion activates generated movement plan session',
    (tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showOnboarding: true,
          enableForegroundGps: false,
          currentSessionGeneratedPlanStore: generatedPlanStore,
        ),
      );

      await completeOnboardingToPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsOneWidget);
      expect(generatedPlanStore.activePlan, isNotNull);
      expect(generatedPlanStore.activePlan!.title, 'Return to Movement');
      expect(generatedPlanStore.currentWeekRunningSessionCount, 3);
    },
  );

  testWidgets('signed-in onboarding completion persists safe profile fields', (
    tester,
  ) async {
    final authRepository = FakeRuniacAuthRepository();
    final profileRepository = _RecordingUserProfilePersistenceRepository();
    addTearDown(authRepository.dispose);
    authRepository.emitSignedIn();

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
        authRepository: authRepository,
        profilePersistenceRepository: profileRepository,
        initialPersonalProfileDraft: PersonalProfileDraft(
          fullName: 'Maya Tan',
          nickname: 'Maya',
          ageYears: 24,
          weightKg: 58.5,
          locationLabel: 'Queenstown',
        ),
      ),
    );

    await completeOnboardingToPreview(tester);
    await tapText(tester, 'Continue with this plan');

    expect(find.text('Good to see you'), findsOneWidget);
    expect(profileRepository.uid, 'test-auth-user-1');
    expect(profileRepository.profile?.displayName, 'Maya');
    expect(profileRepository.profile?.fullName, 'Maya Tan');
    expect(profileRepository.profile?.nickname, 'Maya');
    expect(profileRepository.profile?.avatarInitials, 'M');
    expect(profileRepository.profile?.ageYears, 24);
    expect(profileRepository.profile?.weightKg, 58.5);
    expect(profileRepository.profile?.locationLabel, 'Queenstown');
    expect(profileRepository.profile?.fitnessLevel, 'new');
    expect(profileRepository.profile?.goals, <String>['habit']);
    expect(profileRepository.profile?.availability, <String, Object>{
      'weeklySessions': '3',
      'preferredDays': <String>['Mon', 'Wed', 'Fri'],
      'preferredTime': 'morning',
      'sessionLengthMinutes': '20',
    });
    expect(profileRepository.profile?.planCautiousness, 'balanced');
    expect(profileRepository.profile?.healthSafetyReadiness, <String, Object>{
      'comfort': 'ready',
      'activitySymptoms': <String>['none'],
      'recentRunningConsistency': 'none',
      'currentWeeklyRunFrequency': '0',
      'continuousRunCapacity': 'walk',
      'runningPlace': 'park',
      'motivationStyle': 'reminders',
    });
  });

  testWidgets(
    'signed-in onboarding completion waits when profile persistence fails',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository();
      final profileRepository = _RecordingUserProfilePersistenceRepository()
        ..failNextSave = true;
      addTearDown(authRepository.dispose);
      authRepository.emitSignedIn();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showOnboarding: true,
          enableForegroundGps: false,
          authRepository: authRepository,
          profilePersistenceRepository: profileRepository,
          initialPersonalProfileDraft: PersonalProfileDraft(
            fullName: 'Maya Tan',
            nickname: 'Maya',
            ageYears: 24,
            weightKg: 58.5,
            locationLabel: 'Queenstown',
          ),
        ),
      );

      await completeOnboardingToPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsNothing);
      expect(find.text('Continue with this plan'), findsOneWidget);
      expect(find.textContaining('profile'), findsWidgets);

      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsOneWidget);
      expect(profileRepository.saveCalls, 2);
    },
  );

  testWidgets(
    'body concern onboarding completion activates recovery plan session',
    (tester) async {
      final generatedPlanStore = CurrentSessionGeneratedPlanStore();

      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          showOnboarding: true,
          enableForegroundGps: false,
          currentSessionGeneratedPlanStore: generatedPlanStore,
        ),
      );

      await completeOnboardingToBodyConcernPreview(tester);
      await tapText(tester, 'Continue with this plan');

      expect(find.text('Good to see you'), findsOneWidget);
      expect(generatedPlanStore.activePlan, isNotNull);
      expect(generatedPlanStore.activePlan!.title, 'Return to Movement');
      expect(generatedPlanStore.currentWeekRunningSessionCount, 3);
    },
  );

  testWidgets('needs clearance completion retains safety readiness display', (
    tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
        currentSessionGeneratedPlanStore: generatedPlanStore,
      ),
    );

    await completeOnboardingToNeedsClearancePreview(tester);

    expect(find.text('Safety-first setup'), findsOneWidget);
    expect(find.text('Safety Readiness Plan'), findsOneWidget);
    expect(
      find.textContaining('qualified professional guidance'),
      findsWidgets,
    );
    expect(find.text('First week preview'), findsNothing);
    expect(find.text('Suggested starting plan'), findsNothing);
    expect(find.textContaining(' min'), findsNothing);
    expect(find.textContaining('km'), findsNothing);
    expect(find.textContaining('pace'), findsNothing);
    expect(find.textContaining('Start Run'), findsNothing);
    expect(find.textContaining('continue anyway'), findsNothing);

    await tapText(tester, 'Finish for now');

    expect(find.text('Good to see you'), findsOneWidget);
    expect(generatedPlanStore.activePlan, isNotNull);
    expect(generatedPlanStore.activePlan!.isSafetyReadinessDisplay, isTrue);
    expect(generatedPlanStore.activePlan!.canStartPlannedRun, isFalse);
    expect(
      isEligibleCurrentSessionGeneratedPlan(generatedPlanStore.activePlan!),
      isFalse,
    );
    expect(generatedPlanStore.currentWeekRunningSessionCount, 0);
  });

  testWidgets('needs clearance completion replaces stale generated plan', (
    tester,
  ) async {
    final generatedPlanStore = CurrentSessionGeneratedPlanStore();
    final stalePlan = const BeginnerAdaptivePlanGenerator().generate(
      planFamilyPerformanceDraft(
        goal: OnboardingGoal.tenK,
        style: OnboardingPlanStyle.performanceFocused,
        days: const [
          OnboardingPreferredDay.mon,
          OnboardingPreferredDay.tue,
          OnboardingPreferredDay.wed,
          OnboardingPreferredDay.thu,
        ],
      ),
    );
    expect(generatedPlanStore.setActivePlan(stalePlan), isTrue);

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showOnboarding: true,
        enableForegroundGps: false,
        currentSessionGeneratedPlanStore: generatedPlanStore,
      ),
    );

    await completeOnboardingToNeedsClearancePreview(tester);

    expect(find.text('Safety-first setup'), findsOneWidget);
    expect(find.text('Safety Readiness Plan'), findsOneWidget);
    expect(find.text('Continue with this plan'), findsNothing);
    expect(find.text('Finish for now'), findsOneWidget);

    await tapText(tester, 'Finish for now');

    expect(find.text('Good to see you'), findsOneWidget);
    expect(generatedPlanStore.activePlan, isNotNull);
    expect(generatedPlanStore.activePlan, isNot(same(stalePlan)));
    expect(generatedPlanStore.activePlan!.isSafetyReadinessDisplay, isTrue);
    expect(
      isEligibleCurrentSessionGeneratedPlan(generatedPlanStore.activePlan!),
      isFalse,
    );
    expect(generatedPlanStore.currentWeekRunningSessionCount, 0);
  });
}

class _RecordingUserProfilePersistenceRepository
    implements UserProfilePersistenceRepository {
  String? uid;
  UserProfileOnboardingSnapshot? profile;
  bool failNextSave = false;
  int saveCalls = 0;

  @override
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  }) async {
    saveCalls += 1;
    if (failNextSave) {
      failNextSave = false;
      throw StateError('profile save failed');
    }
    this.uid = uid;
    this.profile = profile;
  }

  @override
  Future<void> savePersonalProfile({
    required String uid,
    required UserProfilePersonalSnapshot profile,
  }) async {}
}
