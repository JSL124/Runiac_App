import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme/runiac_theme.dart';
import 'features/account/domain/repositories/user_profile_persistence_repository.dart';
import 'features/auth/data/non_production_auth_repository.dart';
import 'features/auth/domain/runiac_auth_service.dart';
import 'features/auth/presentation/runiac_auth_gate.dart';
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
    this.profilePersistenceRepository =
        const NoopUserProfilePersistenceRepository(),
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.initialRunOpenIntent,
    this.currentSessionActivityHistoryStore,
    this.currentSessionGeneratedPlanStore,
    this.onOnboardingCompleted,
  });

  final bool showSplash;
  final bool showAuth;
  final bool showOnboarding;
  final Duration splashDuration;
  final RuniacAuthRepository authRepository;
  final RunRepository runRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final RunOpenIntent? initialRunOpenIntent;
  final CurrentSessionActivityHistoryStore? currentSessionActivityHistoryStore;
  final CurrentSessionGeneratedPlanStore? currentSessionGeneratedPlanStore;
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
                  });
                },
                child: RuniacOnboardingGate(
                  showOnboarding: _shouldShowOnboarding,
                  onCompletedDraft: _completeOnboarding,
                  child: RuniacShell(
                    authRepository: widget.authRepository,
                    enableForegroundGps: widget.enableForegroundGps,
                    activeRunSessionCoordinator:
                        widget.activeRunSessionCoordinator,
                    initialRunOpenIntent: widget.initialRunOpenIntent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _completeOnboarding(LocalOnboardingDraft draft) {
    final snapshot = const BeginnerAdaptivePlanGenerator().generate(draft);
    if (!_generatedPlanStore.setActivePlan(snapshot)) {
      _generatedPlanStore.clear();
    }
    final currentUser = widget.authRepository.currentUser;
    if (currentUser != null) {
      unawaited(_saveOnboardingProfile(currentUser.uid, draft));
    }
    widget.onOnboardingCompleted?.call(draft);
  }

  Future<void> _saveOnboardingProfile(
    String uid,
    LocalOnboardingDraft draft,
  ) async {
    try {
      await widget.profilePersistenceRepository.saveOnboardingProfile(
        uid: uid,
        profile: _profileSnapshotFromDraft(draft),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac profile persistence',
          context: ErrorDescription('saving the onboarding profile'),
        ),
      );
    }
  }

  UserProfileOnboardingSnapshot _profileSnapshotFromDraft(
    LocalOnboardingDraft draft,
  ) {
    return UserProfileOnboardingSnapshot(
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
      planCautiousness: draft.planCautiousness.value,
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
    return _authCompletion == RuniacAuthCompletion.signup;
  }
}
