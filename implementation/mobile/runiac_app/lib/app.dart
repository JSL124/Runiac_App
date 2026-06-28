import 'package:flutter/material.dart';

import 'core/theme/runiac_theme.dart';
import 'features/account/data/static_user_profile_repository.dart';
import 'features/account/domain/models/user_profile_read_model.dart';
import 'features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'features/account/domain/repositories/user_profile_repository.dart';
import 'features/account/presentation/personal_profile_collection_screen.dart';
import 'features/auth/data/non_production_auth_repository.dart';
import 'features/auth/domain/runiac_auth_service.dart';
import 'features/auth/presentation/runiac_auth_gate.dart';
import 'features/auth/presentation/runiac_profile_setup_gate.dart';
import 'features/onboarding/domain/models/local_onboarding_draft.dart';
import 'features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'features/plan/presentation/current_session_generated_plan.dart';
import 'features/run/data/static_run_repository.dart';
import 'features/run/domain/repositories/run_repository.dart';
import 'features/run/presentation/active_run_session_coordinator.dart';
import 'features/run/presentation/run_open_intent.dart';
import 'features/run/presentation/run_repository_scope.dart';
import 'features/onboarding/presentation/runiac_onboarding_gate.dart';
import 'features/shell/runiac_shell.dart';
import 'features/splash/presentation/runiac_splash_tokens.dart';
import 'features/splash/presentation/runiac_startup_gate.dart';
import 'features/you/presentation/current_session_activity_history.dart';

export 'features/run/presentation/run_open_intent.dart';

class RuniacApp extends StatefulWidget {
  const RuniacApp({
    super.key,
    this.showSplash = true,
    this.showAuth = false,
    this.showOnboarding = false,
    this.splashDuration = RuniacSplashTokens.minVisibleDuration,
    this.authRepository = const NonProductionAuthRepository(),
    this.runRepository = const StaticRunRepository(),
    this.profileRepository = const StaticUserProfileRepository(),
    this.profilePersistenceRepository =
        const NoopUserProfilePersistenceRepository(),
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.initialRunOpenIntent,
    this.currentSessionActivityHistoryStore,
    this.currentSessionGeneratedPlanStore,
    this.initialPersonalProfileDraft,
    this.onOnboardingCompleted,
  });

  final bool showSplash;
  final bool showAuth;
  final bool showOnboarding;
  final Duration splashDuration;
  final RuniacAuthRepository authRepository;
  final RunRepository runRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final RunOpenIntent? initialRunOpenIntent;
  final CurrentSessionActivityHistoryStore? currentSessionActivityHistoryStore;
  final CurrentSessionGeneratedPlanStore? currentSessionGeneratedPlanStore;
  final PersonalProfileDraft? initialPersonalProfileDraft;
  final ValueChanged<LocalOnboardingDraft>? onOnboardingCompleted;

  @override
  State<RuniacApp> createState() => _RuniacAppState();
}

class _RuniacAppState extends State<RuniacApp> {
  late final CurrentSessionActivityHistoryStore _activityHistoryStore;
  late final bool _ownsActivityHistoryStore;
  late final CurrentSessionGeneratedPlanStore _generatedPlanStore;
  late final bool _ownsGeneratedPlanStore;
  RuniacAuthCompletion? _authCompletion;
  PersonalProfileDraft? _personalProfileDraft;
  String? _authStateError;

  @override
  void initState() {
    super.initState();
    _ownsActivityHistoryStore =
        widget.currentSessionActivityHistoryStore == null;
    _activityHistoryStore =
        widget.currentSessionActivityHistoryStore ??
        CurrentSessionActivityHistoryStore();
    _ownsGeneratedPlanStore = widget.currentSessionGeneratedPlanStore == null;
    _generatedPlanStore =
        widget.currentSessionGeneratedPlanStore ??
        CurrentSessionGeneratedPlanStore();
    _personalProfileDraft = widget.initialPersonalProfileDraft;
  }

  @override
  void didUpdateWidget(covariant RuniacApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authRepository != widget.authRepository ||
        oldWidget.profileRepository != widget.profileRepository) {
      _authCompletion = null;
      _personalProfileDraft = widget.initialPersonalProfileDraft;
    }
  }

  @override
  void dispose() {
    if (_ownsActivityHistoryStore) {
      _activityHistoryStore.dispose();
    }
    if (_ownsGeneratedPlanStore) {
      _generatedPlanStore.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CurrentSessionActivityHistoryScope(
      store: _activityHistoryStore,
      child: CurrentSessionGeneratedPlanScope(
        store: _generatedPlanStore,
        child: RunRepositoryScope(
          repository: widget.runRepository,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Runiac',
            theme: buildRuniacTheme(),
            home: RuniacStartupGate(
              showSplash: widget.showSplash,
              splashDuration: widget.splashDuration,
              child: RuniacAuthGate(
                authRepository: widget.authRepository,
                showAuth: widget.showAuth,
                onAuthenticated: (completion) {
                  setState(() {
                    _authCompletion = completion;
                    _authStateError = null;
                  });
                },
                childBuilder: (_) => _buildPostAuthFlow(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostAuthFlow() {
    if (_shouldShowPersonalProfile) {
      final currentUser = widget.authRepository.currentUser;
      if (currentUser == null) {
        return _AuthStateErrorScreen(
          message:
              _authStateError ??
              'We could not confirm your account. Please try signing in again.',
        );
      }
      return _buildPersonalProfileCollection(currentUser);
    }

    final currentUser = widget.authRepository.currentUser;
    if (_shouldProbeSignedInProfileSetup(currentUser)) {
      return RuniacProfileSetupGate(
        authRepository: widget.authRepository,
        profileRepository: widget.profileRepository,
        currentUser: currentUser!,
        onLoadedProfile: _hydrateGeneratedPlanFromProfile,
        child: _buildOnboardingAndShell(),
      );
    }

    return _buildOnboardingAndShell();
  }

  Widget _buildOnboardingAndShell() {
    return RuniacOnboardingGate(
      showOnboarding: _shouldShowOnboarding,
      onCompletedDraft: _completeOnboarding,
      child: RuniacShell(
        authRepository: widget.authRepository,
        profileRepository: widget.profileRepository,
        profilePersistenceRepository: widget.profilePersistenceRepository,
        enableForegroundGps: widget.enableForegroundGps,
        activeRunSessionCoordinator: widget.activeRunSessionCoordinator,
        initialRunOpenIntent: widget.initialRunOpenIntent,
      ),
    );
  }

  Widget _buildPersonalProfileCollection(RuniacAuthUser currentUser) {
    return PersonalProfileCollectionScreen(
      uid: currentUser.uid,
      emailLabel: currentUser.email ?? 'Email unavailable',
      persistenceRepository: widget.profilePersistenceRepository,
      onComplete: (draft) {
        setState(() {
          _personalProfileDraft = draft;
        });
      },
    );
  }

  void _hydrateGeneratedPlanFromProfile(UserProfileReadModel profile) {
    final draft = profile.onboardingDraft;
    if (draft == null) {
      return;
    }
    final snapshot = const BeginnerAdaptivePlanGenerator().generate(draft);
    if (!_generatedPlanStore.setActivePlan(snapshot)) {
      _generatedPlanStore.clear();
    }
  }

  Future<bool> _completeOnboarding(LocalOnboardingDraft draft) async {
    final snapshot = const BeginnerAdaptivePlanGenerator().generate(draft);
    final currentUser = widget.authRepository.currentUser;
    if (currentUser != null) {
      final saved = await _saveOnboardingProfile(currentUser.uid, draft);
      if (!saved) {
        return false;
      }
    }
    if (!_generatedPlanStore.setActivePlan(snapshot)) {
      _generatedPlanStore.clear();
    }
    widget.onOnboardingCompleted?.call(draft);
    return true;
  }

  Future<bool> _saveOnboardingProfile(
    String uid,
    LocalOnboardingDraft draft,
  ) async {
    try {
      await widget.profilePersistenceRepository.saveOnboardingProfile(
        uid: uid,
        profile: _profileSnapshotFromDraft(draft),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  UserProfileOnboardingSnapshot _profileSnapshotFromDraft(
    LocalOnboardingDraft draft,
  ) {
    final personalProfile = _personalProfileDraft;
    final displayName = personalProfile?.displayName ?? 'Runiac Runner';
    final fullName = personalProfile?.fullName ?? 'Runiac Runner';
    final nickname = personalProfile?.nickname ?? 'Runiac Runner';
    final avatarInitials = personalProfile?.avatarInitials ?? 'RR';
    final nicknameKey = personalProfile?.nicknameKey ?? 'runiac-runner';
    final dateOfBirthIso = personalProfile?.dateOfBirthIso ?? '2008-01-01';
    final ageYears = personalProfile?.ageYears ?? 18;
    final weightKg = personalProfile?.weightKg ?? 60;
    final locationLabel = personalProfile?.locationLabel ?? 'Not set yet';
    return UserProfileOnboardingSnapshot(
      displayName: displayName,
      fullName: fullName,
      nickname: nickname,
      avatarInitials: avatarInitials,
      nicknameKey: nicknameKey,
      dateOfBirthIso: dateOfBirthIso,
      ageYears: ageYears,
      weightKg: weightKg,
      locationLabel: locationLabel,
      fitnessLevel: draft.experience.value,
      goals: <String>[draft.goal.value],
      availability: <String, Object>{
        'weeklySessions': draft.availability.value,
        'preferredDays': draft.preferredDays
            .map((day) => day.value)
            .toList(growable: false),
        'preferredTime': draft.preferredTime.value,
        'sessionLengthMinutes': draft.sessionLength.value,
      },
      planCautiousness: draft.planStyle.value,
      healthSafetyReadiness: <String, Object>{
        'comfort': draft.healthComfort.value,
        'activitySymptoms': draft.activitySymptoms
            .map((symptom) => symptom.value)
            .toList(growable: false),
        'recentRunningConsistency': draft.recentRunningConsistency.value,
        'currentWeeklyRunFrequency': draft.currentWeeklyRunFrequency.value,
        'continuousRunCapacity': draft.continuousRunCapacity.value,
        'runningPlace': draft.runningPlace.value,
        'motivationStyle': draft.motivationStyle.value,
      },
    );
  }

  bool get _shouldShowOnboarding {
    if (!widget.showOnboarding) {
      return false;
    }
    if (!widget.showAuth) {
      return true;
    }
    return _authCompletion == RuniacAuthCompletion.signup &&
        _personalProfileDraft != null;
  }

  bool get _shouldShowPersonalProfile {
    return widget.showAuth &&
        widget.showOnboarding &&
        _authCompletion == RuniacAuthCompletion.signup &&
        _personalProfileDraft == null;
  }

  bool _shouldProbeSignedInProfileSetup(RuniacAuthUser? currentUser) {
    return widget.showAuth &&
        widget.showOnboarding &&
        currentUser != null &&
        _authCompletion == null &&
        _personalProfileDraft == null;
  }
}

class _AuthStateErrorScreen extends StatelessWidget {
  const _AuthStateErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
