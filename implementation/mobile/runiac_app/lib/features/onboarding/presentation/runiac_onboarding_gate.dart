import 'package:flutter/material.dart';

import '../domain/models/local_onboarding_draft.dart';
import 'onboarding_flow_screen.dart';

class RuniacOnboardingGate extends StatefulWidget {
  const RuniacOnboardingGate({
    required this.child,
    this.showOnboarding = false,
    this.onCompletedDraft,
    super.key,
  });

  final Widget child;
  final bool showOnboarding;
  final ValueChanged<LocalOnboardingDraft>? onCompletedDraft;

  @override
  State<RuniacOnboardingGate> createState() => _RuniacOnboardingGateState();
}

class _RuniacOnboardingGateState extends State<RuniacOnboardingGate> {
  bool _completed = false;

  @override
  void didUpdateWidget(covariant RuniacOnboardingGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showOnboarding && oldWidget.showOnboarding) {
      _completed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showOnboarding || _completed) {
      return widget.child;
    }

    return OnboardingFlowScreen(
      onComplete: (draft) {
        widget.onCompletedDraft?.call(draft);
        setState(() {
          _completed = true;
        });
      },
    );
  }
}
