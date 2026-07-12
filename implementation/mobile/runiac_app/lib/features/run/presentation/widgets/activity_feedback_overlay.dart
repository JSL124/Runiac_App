import 'package:flutter/material.dart';

import '../../../../core/characters/runner_character.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../domain/models/activity_feedback_agent.dart';

class ActivityFeedbackOverlay extends StatefulWidget {
  const ActivityFeedbackOverlay({
    required this.character,
    required this.loadFeedback,
    required this.onClose,
    super.key,
  });

  final RunnerCharacter character;
  final Future<ActivityFeedbackBundle> Function() loadFeedback;
  final VoidCallback onClose;

  @override
  State<ActivityFeedbackOverlay> createState() =>
      _ActivityFeedbackOverlayState();
}

class _ActivityFeedbackOverlayState extends State<ActivityFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Future<ActivityFeedbackBundle> _feedback;
  var _stepIndex = 0;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _feedback = widget.loadFeedback();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      await _entrance.reverse();
    }
    if (mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black.withValues(alpha: 0.58),
              dismissible: false,
            ),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _entrance,
              builder: (context, child) {
                final value = Curves.easeOutCubic.transform(_entrance.value);
                return Transform.translate(
                  offset: Offset((1 - value) * 280, 0),
                  child: Opacity(opacity: value.clamp(0, 1), child: child),
                );
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: FutureBuilder<ActivityFeedbackBundle>(
                    future: _feedback,
                    builder: (context, snapshot) {
                      final bundle = snapshot.data;
                      return _FeedbackPanel(
                        character: widget.character,
                        bundle: bundle,
                        stepIndex: _stepIndex,
                        onNext: bundle == null
                            ? null
                            : () {
                                setState(() {
                                  _stepIndex = (_stepIndex + 1).clamp(0, 3);
                                });
                              },
                        onPrevious: bundle == null
                            ? null
                            : () {
                                setState(() {
                                  _stepIndex = (_stepIndex - 1).clamp(0, 3);
                                });
                              },
                        onClose: _close,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.character,
    required this.bundle,
    required this.stepIndex,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
  });

  final RunnerCharacter character;
  final ActivityFeedbackBundle? bundle;
  final int stepIndex;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bundle = this.bundle;
    final step = bundle?.sections.steps[stepIndex];
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close activity feedback',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(
                      character.assetPath(RunnerCharacterFacing.front),
                      width: 92,
                      height: 92,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFD8E1FF)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: bundle == null
                              ? const _LoadingCopy()
                              : _StepCopy(step: step!),
                        ),
                      ),
                    ),
                  ],
                ),
                if (bundle != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${stepIndex + 1}/4',
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Previous feedback step',
                        onPressed: stepIndex == 0 ? null : onPrevious,
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      IconButton(
                        tooltip: 'Next feedback step',
                        onPressed: stepIndex == 3 ? null : onNext,
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCopy extends StatelessWidget {
  const _LoadingCopy();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Analysing your run...',
      style: TextStyle(
        color: RuniacColors.primaryBlue,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.25,
      ),
    );
  }
}

class _StepCopy extends StatelessWidget {
  const _StepCopy({required this.step});

  final ActivityFeedbackSectionStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key('activity_feedback_step_${step.title}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(
            color: RuniacColors.primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.body,
          style: const TextStyle(
            color: RuniacColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
