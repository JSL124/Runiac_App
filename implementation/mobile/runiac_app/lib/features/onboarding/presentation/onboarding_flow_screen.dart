import 'package:flutter/material.dart';

import '../domain/models/local_onboarding_draft.dart';
import '../domain/services/safety_gate_resolver.dart';
import 'onboarding_step_config.dart';
import 'onboarding_steps.dart';
import 'widgets/onboarding_bottom_actions.dart';
import 'widgets/onboarding_progress_header.dart';
import 'widgets/onboarding_step_body.dart';
import 'widgets/onboarding_visuals.dart';

typedef OnboardingCompleteCallback =
    Future<bool> Function(LocalOnboardingDraft draft);

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({required this.onComplete, super.key});

  final OnboardingCompleteCallback onComplete;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final _scrollController = ScrollController();
  final Map<String, Object> _answers = {};
  int _stepIndex = 0;
  bool _completing = false;
  String? _completionError;

  OnboardingStep get _step => onboardingSteps[_stepIndex];

  int? get _requiredPreferredDays {
    final availability = OnboardingAvailability.fromValue(
      _answers['availability'] as String?,
    );
    if (availability == null) {
      return null;
    }
    return requiredPreferredDayCountForAvailability(availability);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectSingle(String key, String value) {
    setState(() {
      _answers[key] = value;
    });
  }

  void _toggleMulti(String key, String value, {String? noneValue}) {
    final current = Set<String>.from(_answers[key] as Set<String>? ?? {});
    final next = <String>{};

    if (noneValue != null && value == noneValue) {
      if (!current.contains(noneValue)) {
        next.add(noneValue);
      }
    } else {
      next.addAll(current.where((item) => item != noneValue));
      if (current.contains(value)) {
        next.remove(value);
      } else {
        next.add(value);
      }
    }

    setState(() {
      _answers[key] = next;
    });
  }

  void _goNext() {
    setState(() {
      _stepIndex = (_stepIndex + 1).clamp(0, onboardingSteps.length - 1);
    });
    _resetScroll();
  }

  void _goBack() {
    setState(() {
      _stepIndex = (_stepIndex - 1).clamp(0, onboardingSteps.length - 1);
    });
    _resetScroll();
  }

  void _editAnswers() {
    setState(() {
      _stepIndex = 1;
    });
    _resetScroll();
  }

  Future<void> _completeOnboarding() async {
    if (_completing) {
      return;
    }
    final draft = LocalOnboardingDraft.fromAnswers(_answers);
    if (draft == null) {
      return;
    }
    setState(() {
      _completing = true;
      _completionError = null;
    });
    final completed = await widget.onComplete(draft);
    if (!mounted) {
      return;
    }
    setState(() {
      _completing = false;
      _completionError = completed
          ? null
          : 'We could not save your profile. Try again.';
    });
  }

  void _resetScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  bool get _canContinue {
    final step = _step;
    if (step.kind == OnboardingStepKind.single) {
      return _answers[step.answerKey] != null;
    }
    if (step.daysGrid) {
      final requiredDays = _requiredPreferredDays;
      final selectedDays = _answers[step.answerKey] as Set<String>? ?? {};
      return requiredDays != null && selectedDays.length >= requiredDays;
    }
    return true;
  }

  bool get _showsClearancePreview {
    if (_step.kind != OnboardingStepKind.preview) {
      return false;
    }
    final draft = LocalOnboardingDraft.fromAnswers(_answers);
    return draft != null &&
        const SafetyGateResolver().resolve(draft) ==
            SafetyGateState.needsClearance;
  }

  @override
  Widget build(BuildContext context) {
    final step = _step;
    final requiredPreferredDays = _requiredPreferredDays;

    return Scaffold(
      backgroundColor: onboardingSurfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingProgressHeader(
              stepIndex: _stepIndex,
              stepCount: onboardingSteps.length,
              title: step.title,
              onBack: _stepIndex == 0 ? null : _goBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey('onboarding_scroll_${step.id}'),
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: OnboardingStepBody(
                  step: step,
                  answers: _answers,
                  helperText: step.daysGrid && requiredPreferredDays != null
                      ? 'Choose at least $requiredPreferredDays days that usually work for you.'
                      : null,
                  onSelectSingle: _selectSingle,
                  onToggleMulti: _toggleMulti,
                ),
              ),
            ),
            OnboardingBottomActions(
              step: step,
              canContinue: _canContinue && !_completing,
              onPrimary: switch (step.kind) {
                OnboardingStepKind.welcome => _goNext,
                OnboardingStepKind.preview => _completeOnboarding,
                OnboardingStepKind.single => _goNext,
                OnboardingStepKind.multi => _goNext,
              },
              onSecondary: switch (step.kind) {
                OnboardingStepKind.preview => _editAnswers,
                OnboardingStepKind.welcome => null,
                OnboardingStepKind.single => null,
                OnboardingStepKind.multi => null,
              },
              previewPrimaryLabel: _showsClearancePreview
                  ? 'Finish for now'
                  : null,
              isSubmitting: _completing,
              errorText: _completionError,
            ),
          ],
        ),
      ),
    );
  }
}
