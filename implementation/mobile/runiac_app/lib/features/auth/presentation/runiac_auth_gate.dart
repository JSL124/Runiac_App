import 'package:flutter/material.dart';

import 'runiac_auth_flow_screen.dart';

export 'runiac_auth_flow_screen.dart' show RuniacAuthCompletion;

class RuniacAuthGate extends StatefulWidget {
  const RuniacAuthGate({
    required this.child,
    this.showAuth = false,
    this.onAuthenticated,
    super.key,
  });

  final Widget child;
  final bool showAuth;
  final ValueChanged<RuniacAuthCompletion>? onAuthenticated;

  @override
  State<RuniacAuthGate> createState() => _RuniacAuthGateState();
}

class _RuniacAuthGateState extends State<RuniacAuthGate> {
  bool _authenticated = false;

  @override
  void didUpdateWidget(covariant RuniacAuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showAuth && oldWidget.showAuth) {
      _authenticated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAuth || _authenticated) {
      return widget.child;
    }

    return RuniacAuthFlowScreen(
      onAuthenticated: (completion) {
        widget.onAuthenticated?.call(completion);
        setState(() {
          _authenticated = true;
        });
      },
    );
  }
}
