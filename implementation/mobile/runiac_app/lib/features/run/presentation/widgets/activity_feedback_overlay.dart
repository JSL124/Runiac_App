import 'package:flutter/material.dart';

import '../../../../core/characters/runner_character.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../domain/models/activity_feedback_agent.dart';

const activityFeedbackRunDuration = Duration(milliseconds: 800);

const _activityFeedbackRunLeftAsset =
    'assets/images/characters/cap_runner_run_left.gif';
const _activityFeedbackIdleAsset =
    'assets/images/characters/blue_idle/blue_runner_idle.gif';

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
  late final AnimationController _motion;
  late final Future<ActivityFeedbackBundle> _feedback;
  var _stepIndex = 0;
  var _arrived = false;
  var _closing = false;
  var _reducedMotion = false;
  var _closeNotified = false;
  var _motionInitialized = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: activityFeedbackRunDuration,
    );
    _motion.addListener(_handleMotionValue);
    _motion.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_closing && mounted) {
        setState(() {
          _arrived = true;
        });
      }
      if (status == AnimationStatus.dismissed && _closing && mounted) {
        _notifyClose();
      }
    });
    _feedback = widget.loadFeedback();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionInitialized) {
      return;
    }
    _motionInitialized = true;
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion) {
      _motion.value = 1;
      _arrived = true;
      return;
    }
    _motion.forward();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) {
      return;
    }
    _closing = true;

    if (_reducedMotion) {
      if (mounted) {
        setState(() {});
      }
      _notifyClose();
      return;
    }

    // A close tap during the entrance still starts the exit from the stable
    // resting position, so the running-left asset always travels out through
    // the left edge instead of changing direction mid-flight.
    _motion.stop();
    _motion.value = 1;
    _arrived = true;
    if (mounted) {
      setState(() {});
    }
    await _motion.reverse();
    if (mounted) {
      _notifyClose();
    }
  }

  void _handleMotionValue() {
    if (_closing && _motion.value <= 0 && mounted) {
      _notifyClose();
    }
  }

  void _notifyClose() {
    if (_closeNotified) {
      return;
    }
    _closeNotified = true;
    widget.onClose();
  }

  void _showNext() {
    if (_stepIndex < 3) {
      setState(() {
        _stepIndex += 1;
      });
    }
  }

  void _showPrevious() {
    if (_stepIndex > 0) {
      setState(() {
        _stepIndex -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: ModalBarrier(
              key: const ValueKey('activity_feedback_barrier'),
              color: Colors.black.withValues(alpha: 0.58),
              dismissible: false,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  right: 12,
                  top: 20,
                  bottom: 20,
                  child: FutureBuilder<ActivityFeedbackBundle>(
                    future: _feedback,
                    builder: (context, snapshot) {
                      return AnimatedBuilder(
                        animation: _motion,
                        builder: (context, _) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final runDistance = constraints.maxWidth + 120;
                              final progress = Curves.easeOutCubic.transform(
                                _motion.value.clamp(0.0, 1.0),
                              );
                              final offsetX = _closing
                                  ? -runDistance * (1 - progress)
                                  : runDistance * (1 - progress);
                              final arrivedForFrame =
                                  _arrived || (!_closing && _motion.value >= 1);
                              return Transform.translate(
                                key: const ValueKey('activity_feedback_motion'),
                                offset: Offset(offsetX, 0),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: _FeedbackRow(
                                    bundle: snapshot.data,
                                    stepIndex: _stepIndex,
                                    maxBubbleHeight: constraints.maxHeight
                                        .clamp(0.0, 480.0),
                                    showIdle: arrivedForFrame && !_closing,
                                    bubbleVisible: arrivedForFrame && !_closing,
                                    onNext: _showNext,
                                    onPrevious: _showPrevious,
                                    onClose: _close,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow({
    required this.bundle,
    required this.stepIndex,
    required this.maxBubbleHeight,
    required this.showIdle,
    required this.bubbleVisible,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
  });

  final ActivityFeedbackBundle? bundle;
  final int stepIndex;
  final double maxBubbleHeight;
  final bool showIdle;
  final bool bubbleVisible;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final step = bundle?.sections.steps[stepIndex];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 96,
          height: 112,
          child: Image(
            image: AssetImage(
              showIdle
                  ? _activityFeedbackIdleAsset
                  : _activityFeedbackRunLeftAsset,
            ),
            key: ValueKey(
              showIdle
                  ? 'activity_feedback_idle_character'
                  : 'activity_feedback_running_character',
            ),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: IgnorePointer(
            ignoring: !bubbleVisible,
            child: AnimatedOpacity(
              key: const ValueKey('activity_feedback_bubble'),
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              opacity: bubbleVisible ? 1 : 0,
              child: _FeedbackBubble(
                bundle: bundle,
                step: step,
                stepIndex: stepIndex,
                maxHeight: maxBubbleHeight,
                onNext: onNext,
                onPrevious: onPrevious,
                onClose: onClose,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackBubble extends StatelessWidget {
  const _FeedbackBubble({
    required this.bundle,
    required this.step,
    required this.stepIndex,
    required this.maxHeight,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
  });

  final ActivityFeedbackBundle? bundle;
  final ActivityFeedbackSectionStep? step;
  final int stepIndex;
  final double maxHeight;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: RuniacColors.softCardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: bundle == null
                        ? const _LoadingCopy()
                        : Text(
                            step!.title,
                            style: const TextStyle(
                              color: RuniacColors.primaryBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                  ),
                  IconButton(
                    tooltip: 'Close activity feedback',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    color: RuniacColors.textSecondary,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (bundle != null) ...[
                const SizedBox(height: 6),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      step!.body,
                      style: const TextStyle(
                        color: RuniacColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${stepIndex + 1}/4',
                      style: const TextStyle(
                        color: RuniacColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Previous feedback step',
                      onPressed: stepIndex == 0 ? null : onPrevious,
                      icon: const Icon(Icons.chevron_left_rounded),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: 'Next feedback step',
                      onPressed: stepIndex == 3 ? null : onNext,
                      icon: const Icon(Icons.chevron_right_rounded),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ],
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
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        'Analysing your run...',
        style: TextStyle(
          color: RuniacColors.primaryBlue,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
      ),
    );
  }
}
