import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/characters/runner_character.dart';
import '../../../core/theme/runiac_colors.dart';

/// Animated guide overlay shown when the user stalls on an onboarding step.
///
/// The Blue guide runs in from a random horizontal direction, then settles in
/// the lower safe area before its speech bubble appears. Other selected guide
/// characters retain the existing static presentation until matching running
/// and idle assets are available.
///
/// Display-only: the overlay renders sprites and hint copy and never touches
/// XP, level, rank, streak, or leaderboard values.
class OnboardingGuideOverlay extends StatefulWidget {
  const OnboardingGuideOverlay({
    required this.character,
    required this.message,
    required this.onDismiss,
    this.enterFromLeft,
    super.key,
  });

  final RunnerCharacter character;
  final String message;
  final VoidCallback onDismiss;

  /// Test seam for a deterministic entrance direction. Production uses a
  /// random side for each newly shown guide.
  final bool? enterFromLeft;

  @override
  State<OnboardingGuideOverlay> createState() => _OnboardingGuideOverlayState();
}

/// Long enough for the running GIF to read as movement without delaying help.
const onboardingGuideRunInDuration = Duration(milliseconds: 800);

const _blueIdleAsset =
    'assets/images/characters/blue_idle/blue_runner_idle.gif';
const _blueRunLeftAsset = 'assets/images/characters/cap_runner_run_left.gif';
const _blueRunRightAsset = 'assets/images/characters/cap_runner_run_right.gif';

class _OnboardingGuideOverlayState extends State<OnboardingGuideOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _runIn;
  late final AnimationController _bob;
  late final AnimationController _type;
  late final Animation<int> _typedLength;
  late final bool _entersFromLeft;
  bool _hasArrived = false;
  bool _motionInitialized = false;

  @override
  void initState() {
    super.initState();
    _entersFromLeft = widget.enterFromLeft ?? Random().nextBool();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _runIn = AnimationController(
      vsync: this,
      duration: onboardingGuideRunInDuration,
    );
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    final typeMillis = (widget.message.length * 18).clamp(500, 2600);
    _type = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: typeMillis),
    );
    _typedLength = IntTween(
      begin: 0,
      end: widget.message.length,
    ).animate(CurvedAnimation(parent: _type, curve: Curves.easeOut));
    _bob.repeat(reverse: true);
    _type.forward();
    _hasArrived = widget.character != RunnerCharacter.blue;
    _runIn.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _hasArrived = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionInitialized) {
      return;
    }
    _motionInitialized = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.character != RunnerCharacter.blue) {
      if (reduceMotion) {
        _entrance.value = 1;
      } else {
        _entrance.forward();
      }
      return;
    }
    if (reduceMotion) {
      _runIn.value = 1;
      _hasArrived = true;
      return;
    }
    _runIn.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _runIn.dispose();
    _bob.dispose();
    _type.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBlueGuide = widget.character == RunnerCharacter.blue;
    final runIn = CurvedAnimation(parent: _runIn, curve: Curves.easeOutCubic);
    return Stack(
      children: [
        // Tap-away dismiss layer behind the guide card.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: isBlueGuide
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedBuilder(
                      animation: Listenable.merge([_runIn, _bob]),
                      builder: (context, _) {
                        final horizontalDistance = constraints.maxWidth + 112;
                        final direction = _entersFromLeft ? -1.0 : 1.0;
                        final bob = _hasArrived ? (_bob.value - 0.5) * 4 : 0.0;
                        return Transform.translate(
                          offset: Offset(
                            direction * (1 - runIn.value) * horizontalDistance,
                            bob,
                          ),
                          child: _GuideCard(
                            character: widget.character,
                            message: widget.message,
                            typedLength: _typedLength,
                            enterFromLeft: _entersFromLeft,
                            hasArrived: _hasArrived,
                            onDismiss: widget.onDismiss,
                          ),
                        );
                      },
                    );
                  },
                )
              : AnimatedBuilder(
                  animation: Listenable.merge([_entrance, _bob]),
                  builder: (context, _) {
                    final entrance = Curves.easeOutBack.transform(
                      _entrance.value,
                    );
                    final bob = (_bob.value - 0.5) * 6;
                    return Opacity(
                      opacity: _entrance.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, (1 - entrance) * 120 + bob),
                        child: Transform.scale(
                          scale: 0.9 + entrance * 0.1,
                          alignment: Alignment.bottomCenter,
                          child: _GuideCard(
                            character: widget.character,
                            message: widget.message,
                            typedLength: _typedLength,
                            enterFromLeft: true,
                            hasArrived: true,
                            onDismiss: widget.onDismiss,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.character,
    required this.message,
    required this.typedLength,
    required this.enterFromLeft,
    required this.hasArrived,
    required this.onDismiss,
  });

  final RunnerCharacter character;
  final String message;
  final Animation<int> typedLength;
  final bool enterFromLeft;
  final bool hasArrived;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final character = _GuideCharacter(
      character: this.character,
      facing: enterFromLeft
          ? RunnerCharacterFacing.right
          : RunnerCharacterFacing.left,
      isRunning: !hasArrived,
    );
    final bubble = _GuideBubble(
      character: this.character,
      message: message,
      typedLength: typedLength,
      visible: hasArrived,
      onDismiss: onDismiss,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: enterFromLeft
          ? [character, const SizedBox(width: 8), bubble]
          : [bubble, const SizedBox(width: 8), character],
    );
  }
}

class _GuideCharacter extends StatelessWidget {
  const _GuideCharacter({
    required this.character,
    required this.facing,
    required this.isRunning,
  });

  final RunnerCharacter character;
  final RunnerCharacterFacing facing;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final isBlueGuide = character == RunnerCharacter.blue;
    final assetPath = isBlueGuide
        ? isRunning
              ? facing == RunnerCharacterFacing.left
                    ? _blueRunLeftAsset
                    : _blueRunRightAsset
              : _blueIdleAsset
        : character.assetPath(facing);
    return SizedBox(
      width: 92,
      height: 104,
      child: Image.asset(
        assetPath,
        key: ValueKey(
          isBlueGuide && isRunning
              ? 'onboarding_guide_running_character'
              : 'onboarding_guide_idle_character',
        ),
        fit: BoxFit.contain,
      ),
    );
  }
}

class _GuideBubble extends StatelessWidget {
  const _GuideBubble({
    required this.character,
    required this.message,
    required this.typedLength,
    required this.visible,
    required this.onDismiss,
  });

  final RunnerCharacter character;
  final String message;
  final Animation<int> typedLength;
  final bool visible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          key: const ValueKey('onboarding_guide_bubble'),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: visible ? 1 : 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            decoration: BoxDecoration(
              color: RuniacColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuniacColors.cardBorder, width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: RuniacColors.softCardShadow,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        character.displayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: RuniacColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: typedLength,
                        builder: (context, _) {
                          final count = typedLength.value.clamp(
                            0,
                            message.length,
                          );
                          return Text(
                            message.substring(0, count),
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: RuniacColors.textPrimary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4, top: 2),
                    child: Tooltip(
                      message: 'Dismiss',
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: RuniacColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
