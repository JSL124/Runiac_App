import 'package:flutter/material.dart';

import 'core/theme/runiac_theme.dart';
import 'features/run/data/static_run_repository.dart';
import 'features/run/domain/repositories/run_repository.dart';
import 'features/run/presentation/active_run_session_coordinator.dart';
import 'features/run/presentation/run_repository_scope.dart';
import 'features/shell/runiac_shell.dart';
import 'features/splash/presentation/runiac_splash_tokens.dart';
import 'features/splash/presentation/runiac_startup_gate.dart';

class RuniacApp extends StatelessWidget {
  const RuniacApp({
    super.key,
    this.showSplash = true,
    this.splashDuration = RuniacSplashTokens.minVisibleDuration,
    this.runRepository = const StaticRunRepository(),
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
  });

  final bool showSplash;
  final Duration splashDuration;
  final RunRepository runRepository;
  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runiac',
      theme: buildRuniacTheme(),
      home: RunRepositoryScope(
        repository: runRepository,
        child: RuniacStartupGate(
          showSplash: showSplash,
          splashDuration: splashDuration,
          child: RuniacShell(
            enableForegroundGps: enableForegroundGps,
            activeRunSessionCoordinator: activeRunSessionCoordinator,
          ),
        ),
      ),
    );
  }
}
