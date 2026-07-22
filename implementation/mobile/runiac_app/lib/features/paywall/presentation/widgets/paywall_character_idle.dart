import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/characters/runner_character.dart';

/// Blue's supplied idle-motion GIF. The other characters do not have idle
/// GIFs yet, so they fall back to their static front sprite with a gentle
/// code-driven bob (same fallback rule as the Home stage map guide).
const String _kBlueRunnerIdleGifAsset =
    'assets/images/characters/blue_idle/blue_runner_idle.gif';

/// The selected guide character idling beside the paywall feature card,
/// peeking at it like it can't wait for the runner to join Premium.
///
/// Blue plays its idle GIF; Cap/Mila/Ivy bob gently on a slow repeating
/// controller. Bumping [celebrateTick] plays a single celebratory hop (used
/// when the CTA is tapped). With reduced motion enabled every character
/// renders as a static front sprite and no controller runs, so
/// `pumpAndSettle`-based tests always settle.
class PaywallCharacterIdle extends StatefulWidget {
  const PaywallCharacterIdle({
    required this.character,
    this.width = 92,
    this.celebrateTick = 0,
    super.key,
  });

  final RunnerCharacter character;
  final double width;

  /// Increment to trigger one celebratory hop.
  final int celebrateTick;

  @override
  State<PaywallCharacterIdle> createState() => _PaywallCharacterIdleState();
}

class _PaywallCharacterIdleState extends State<PaywallCharacterIdle>
    with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final AnimationController _hopController;
  var _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    // Finite one-shot hop so the widget always settles when idle.
    _hopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion && _isBobRunningAsConfigured) {
      return;
    }
    _reduceMotion = reduceMotion;
    _syncBobController();
  }

  bool get _needsBob =>
      !_reduceMotion && widget.character != RunnerCharacter.blue;

  bool get _isBobRunningAsConfigured => _bobController.isAnimating == _needsBob;

  void _syncBobController() {
    if (_needsBob) {
      _bobController.repeat();
    } else {
      _bobController.stop();
      _bobController.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant PaywallCharacterIdle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character != widget.character) {
      _syncBobController();
    }
    if (oldWidget.celebrateTick != widget.celebrateTick && !_reduceMotion) {
      _hopController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    _hopController.dispose();
    super.dispose();
  }

  /// Fixed footprint height so the sheet can position the character by its
  /// feet regardless of which asset (tall idle GIF vs wide PNG) renders.
  static double footprintHeightForWidth(double width) => width * 289 / 193;

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    final useIdleGif = character == RunnerCharacter.blue && !_reduceMotion;
    final width = widget.width;
    final height = useIdleGif
        ? footprintHeightForWidth(width)
        : width * 280 / 350;

    // Bottom-aligned inside a stable box: every character's feet land on the
    // same line, so the sheet's overlap onto the feature card is identical
    // for the tall idle GIF and the wide PNG sprites.
    final sprite = SizedBox(
      width: width,
      height: footprintHeightForWidth(width),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          useIdleGif
              ? _kBlueRunnerIdleGifAsset
              : character.assetPath(RunnerCharacterFacing.front),
          key: const Key('paywall-character-sprite'),
          width: width,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );

    if (_reduceMotion) {
      return sprite;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_bobController, _hopController]),
      child: sprite,
      builder: (context, child) {
        final bobOffset = _needsBob
            ? -3 * math.sin(_bobController.value * 2 * math.pi)
            : 0.0;
        // One smooth up-and-down arc for the celebratory hop.
        final hopOffset = -10 * math.sin(_hopController.value * math.pi);
        return Transform.translate(
          offset: Offset(0, bobOffset + hopOffset),
          child: child,
        );
      },
    );
  }
}
