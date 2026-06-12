import 'package:flutter/material.dart';

import 'core/theme/runiac_theme.dart';
import 'features/shell/runiac_shell.dart';
import 'features/splash/presentation/runiac_splash_tokens.dart';
import 'features/splash/presentation/runiac_startup_gate.dart';

class RuniacApp extends StatelessWidget {
  const RuniacApp({
    super.key,
    this.showSplash = true,
    this.splashDuration = RuniacSplashTokens.minVisibleDuration,
  });

  final bool showSplash;
  final Duration splashDuration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runiac',
      theme: buildRuniacTheme(),
      home: RuniacStartupGate(
        showSplash: showSplash,
        splashDuration: splashDuration,
        child: const RuniacShell(),
      ),
    );
  }
}
