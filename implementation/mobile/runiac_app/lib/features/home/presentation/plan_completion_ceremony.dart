import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/assets/runiac_assets.dart';
import '../../../core/haptics/runiac_haptics_scope.dart';

/// Shows a non-interactive "Plan Completed!" celebration overlay: a gauge
/// animation fills first, then once full, a second celebration animation and
/// a congrats message reveal above it. A black semi-transparent backdrop
/// blocks all interaction except the top-right close button.
///
/// Under reduced motion the overlay opens already in its fully-revealed
/// state, matching the pattern used by [showRuniacSuccessCheckOverlay] and
/// [ChallengeBadgeCeremony].
///
/// Triggered from `HomeTab` when the backend records the active plan as
/// finished (`planProgress/{uid}.planCompletions[planId].completedAt`, written
/// by the `completeRun` Cloud Function). The client never derives completion
/// itself. The celebration is one-shot per completion, guarded by a local
/// `PlanCompletionSeenStore` marker.
Future<void> showPlanCompletionCeremony(BuildContext context) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Plan completed',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _PlanCompletionOverlay(revealedOnOpen: reduceMotion),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _PlanCompletionOverlay extends StatefulWidget {
  const _PlanCompletionOverlay({required this.revealedOnOpen});

  final bool revealedOnOpen;

  @override
  State<_PlanCompletionOverlay> createState() =>
      _PlanCompletionOverlayState();
}

class _PlanCompletionOverlayState extends State<_PlanCompletionOverlay>
    with SingleTickerProviderStateMixin {
  // A fixed sequencing duration, independent of whether (or how fast) the
  // gauge Lottie composition loads, so `pumpAndSettle` always terminates —
  // matching the approach in `runiac_success_check_overlay.dart`.
  static const _gaugeFillDuration = Duration(milliseconds: 1600);

  late final AnimationController _sequence;
  var _revealed = false;
  var _hapticFired = false;

  @override
  void initState() {
    super.initState();
    _revealed = widget.revealedOnOpen;
    _sequence = AnimationController(
      vsync: this,
      duration: _gaugeFillDuration,
      value: widget.revealedOnOpen ? 1 : 0,
    );
    if (!widget.revealedOnOpen) {
      _sequence
        ..addStatusListener(_handleSequenceStatus)
        ..forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `initState` cannot legally read an InheritedWidget, so the entrance
    // haptic fires here instead, guarded to fire exactly once for the whole
    // life of this overlay.
    if (!_hapticFired) {
      _hapticFired = true;
      RuniacHapticsScope.maybeOf(context)?.impactHeavy();
    }
  }

  void _handleSequenceStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _revealed = true);
    }
  }

  @override
  void dispose() {
    _sequence
      ..removeStatusListener(_handleSequenceStatus)
      ..dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: _close,
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Close',
              ),
            ),
            Center(
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 132,
                      child: AnimatedOpacity(
                        opacity: _revealed ? 1 : 0,
                        duration: const Duration(milliseconds: 260),
                        child: Lottie.asset(
                          RuniacAssets.planCompleteBurstLottie,
                          fit: BoxFit.contain,
                          repeat: false,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: _revealed ? 1 : 0,
                      duration: const Duration(milliseconds: 260),
                      child: const Text(
                        'Plan Completed!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 280,
                      height: 70,
                      child: Lottie.asset(
                        RuniacAssets.planCompleteGaugeLottie,
                        fit: BoxFit.contain,
                        repeat: false,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
