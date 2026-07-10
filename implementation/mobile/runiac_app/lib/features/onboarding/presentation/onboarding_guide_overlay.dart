import 'package:flutter/material.dart';

import '../../../core/characters/runner_character.dart';
import '../../../core/theme/runiac_colors.dart';

/// Animated guide overlay shown when the user stalls on an onboarding step.
///
/// The selected [character] pops in from the bottom (scale + slide with
/// easing), keeps a gentle idle bob, and a speech bubble types its [message]
/// in. It can be dismissed with the close button or by tapping away.
///
/// Display-only: the overlay renders sprites and hint copy and never touches
/// XP, level, rank, streak, or leaderboard values.
class OnboardingGuideOverlay extends StatefulWidget {
  const OnboardingGuideOverlay({
    required this.character,
    required this.message,
    required this.onDismiss,
    super.key,
  });

  final RunnerCharacter character;
  final String message;
  final VoidCallback onDismiss;

  @override
  State<OnboardingGuideOverlay> createState() => _OnboardingGuideOverlayState();
}

class _OnboardingGuideOverlayState extends State<OnboardingGuideOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _bob;
  late final AnimationController _type;
  late final Animation<int> _typedLength;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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
    _entrance.forward();
    _bob.repeat(reverse: true);
    _type.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _bob.dispose();
    _type.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack);
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
          bottom: 16,
          child: AnimatedBuilder(
            animation: Listenable.merge([_entrance, _bob]),
            builder: (context, child) {
              final entrance = slide.value;
              final bob = (_bob.value - 0.5) * 6;
              return Opacity(
                opacity: _entrance.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - entrance) * 120 + bob),
                  child: Transform.scale(
                    scale: 0.9 + entrance * 0.1,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  ),
                ),
              );
            },
            child: _GuideCard(
              character: widget.character,
              message: widget.message,
              typedLength: _typedLength,
              onDismiss: widget.onDismiss,
            ),
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
    required this.onDismiss,
  });

  final RunnerCharacter character;
  final String message;
  final Animation<int> typedLength;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 92,
          height: 104,
          child: Image.asset(
            character.assetPath(RunnerCharacterFacing.right),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
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
      ],
    );
  }
}
