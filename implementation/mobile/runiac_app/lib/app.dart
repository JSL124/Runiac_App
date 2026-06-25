import 'package:flutter/material.dart';

import 'core/theme/runiac_theme.dart';
import 'features/onboarding/domain/models/local_onboarding_draft.dart';
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
    this.showOnboarding = false,
    this.splashDuration = RuniacSplashTokens.minVisibleDuration,
    this.runRepository = const StaticRunRepository(),
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.initialRunOpenIntent,
    this.currentSessionActivityHistoryStore,
    this.onOnboardingCompleted,
  });

  final bool showSplash;
  final bool showOnboarding;
  final Duration splashDuration;
  final RunRepository runRepository;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final RunOpenIntent? initialRunOpenIntent;
  final CurrentSessionActivityHistoryStore? currentSessionActivityHistoryStore;
  final ValueChanged<LocalOnboardingDraft>? onOnboardingCompleted;

  @override
  State<RuniacApp> createState() => _RuniacAppState();
}

class _RuniacAppState extends State<RuniacApp> {
  late final CurrentSessionActivityHistoryStore _activityHistoryStore;
  late final bool _ownsActivityHistoryStore;

  @override
  void initState() {
    super.initState();
    _ownsActivityHistoryStore =
        widget.currentSessionActivityHistoryStore == null;
    _activityHistoryStore =
        widget.currentSessionActivityHistoryStore ??
        CurrentSessionActivityHistoryStore();
  }

  @override
  void dispose() {
    if (_ownsActivityHistoryStore) {
      _activityHistoryStore.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CurrentSessionActivityHistoryScope(
      store: _activityHistoryStore,
      child: RunRepositoryScope(
        repository: widget.runRepository,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Runiac',
          theme: buildRuniacTheme(),
          home: RuniacStartupGate(
            showSplash: widget.showSplash,
            splashDuration: widget.splashDuration,
            child: RuniacOnboardingGate(
              showOnboarding: widget.showOnboarding,
              onCompletedDraft: widget.onOnboardingCompleted,
              child: RuniacShell(
                enableForegroundGps: widget.enableForegroundGps,
                activeRunSessionCoordinator: widget.activeRunSessionCoordinator,
                initialRunOpenIntent: widget.initialRunOpenIntent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
