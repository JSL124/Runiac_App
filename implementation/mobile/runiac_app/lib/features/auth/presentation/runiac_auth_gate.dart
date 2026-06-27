import 'package:flutter/material.dart';

import '../domain/runiac_auth_service.dart';
import 'runiac_auth_flow_screen.dart';

export 'runiac_auth_flow_screen.dart' show RuniacAuthCompletion;

class RuniacAuthGate extends StatefulWidget {
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
  State<RuniacAuthGate> createState() => _RuniacAuthGateState();
}

class _RuniacAuthGateState extends State<RuniacAuthGate> {
  Stream<RuniacAuthUser?>? _authStateChanges;

  Stream<RuniacAuthUser?> get _authStream {
    return _authStateChanges ??= widget.authRepository.authStateChanges();
  }

  @override
  void didUpdateWidget(covariant RuniacAuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authRepository != widget.authRepository) {
      _authStateChanges = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAuth) {
      return widget.child;
    }

    return StreamBuilder<RuniacAuthUser?>(
      initialData: widget.authRepository.currentUser,
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const _RuniacAuthGateLoading();
        }

        if (snapshot.data != null) {
          return widget.child;
        }

        return RuniacAuthFlowScreen(
          authRepository: widget.authRepository,
          onAuthenticated: (completion) {
            widget.onAuthenticated?.call(completion);
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
