import 'package:flutter/material.dart';

import '../domain/runiac_auth_service.dart';
import 'runiac_auth_flow_screen.dart';

export 'runiac_auth_flow_screen.dart' show RuniacAuthCompletion;

class RuniacAuthGate extends StatelessWidget {
  const RuniacAuthGate({
    required this.authRepository,
    required this.child,
    this.showAuth = false,
    this.onAuthenticated,
    super.key,
  });

  final RuniacAuthRepository authRepository;
  final Widget child;
  final bool showAuth;
  final ValueChanged<RuniacAuthCompletion>? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    if (!showAuth) {
      return child;
    }

    return StreamBuilder<RuniacAuthUser?>(
      initialData: authRepository.currentUser,
      stream: authRepository.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const _RuniacAuthGateLoading();
        }

        if (snapshot.data != null) {
          return child;
        }

        return RuniacAuthFlowScreen(
          authRepository: authRepository,
          onAuthenticated: (completion) {
            onAuthenticated?.call(completion);
          },
        );
      },
    );
  }
}

class _RuniacAuthGateLoading extends StatelessWidget {
  const _RuniacAuthGateLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox.square(
          key: ValueKey('auth_gate_loading'),
          dimension: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}
