import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../domain/models/run_tracking_state.dart';
import 'controllers/run_tracking_controller.dart';
import 'cool_down_screen.dart';
import 'data/run_launch_demo_snapshots.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_tracking_sheet_content.dart';

const _blueBorder = Color(0xFFDCE6FF);
const _sportOrange = Color(0xFFFF7A1A);
const _orangeShadow = Color(0x33FF7A1A);
const _screenBackground = Color(0xFF3153C9);
const _softControlBlue = Color(0x667A91E5);
const _pressedControlBlue = Color(0x99A8B8FF);
const _controlSplash = Color(0x33FFFFFF);
const _controlHighlight = Color(0x24FFFFFF);
const _panelTextBlue = Color(0xFF3151C8);
const _mutedBlue = Color(0xFF8296E8);
const _controlPressHold = Duration(milliseconds: 90);
const _sheetAnimationDuration = Duration(milliseconds: 280);

enum RunSheetMode { preRun, running, paused }

class RunLaunchScreen extends StatefulWidget {
  const RunLaunchScreen({super.key});

  @override
  State<RunLaunchScreen> createState() => _RunLaunchScreenState();
}

class _RunLaunchScreenState extends State<RunLaunchScreen> {
  final RunTrackingController _controller = RunTrackingController();
  RunSheetMode _sheetMode = RunSheetMode.preRun;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startRun() {
    if (_sheetMode != RunSheetMode.preRun) {
      return;
    }

    if (_controller.state.phase == RunTrackingPhase.idle ||
        _controller.state.phase == RunTrackingPhase.finished) {
      _controller.start(routeLabel: 'Easy local route');
    }

    _ticker ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _controller.advanceBy(const Duration(seconds: 1)),
    );

    setState(() => _sheetMode = RunSheetMode.running);
  }

  void _pauseRun() {
    _controller.pause();
    setState(() => _sheetMode = RunSheetMode.paused);
  }

  void _resumeRun() {
    _controller.resume();
    setState(() => _sheetMode = RunSheetMode.running);
  }

  void _finishRun() {
    _ticker?.cancel();
    _ticker = null;
    _controller.finish();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const CoolDownScreen()),
    );
  }

  void _showPreviewMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusLabel(RunTrackingState state) {
    if (_sheetMode == RunSheetMode.preRun) {
      return 'GPS ready';
    }

    if (_sheetMode == RunSheetMode.paused || state.isPaused) {
      return 'Paused · easy';
    }

    return 'Running · easy';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _screenBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: RunMapPlaceholder()),
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: _sheetAnimationDuration,
                      child: _sheetMode == RunSheetMode.preRun
                          ? _MapCircleButton(
                              key: const ValueKey('close_button'),
                              tooltip: 'Close',
                              icon: Icons.close,
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          : const SizedBox(
                              key: ValueKey('close_button_hidden'),
                              width: 48,
                              height: 48,
                            ),
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return Center(
                            child: AnimatedSwitcher(
                              duration: _sheetAnimationDuration,
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: _RunStatusPill(
                                key: ValueKey(_statusLabel(_controller.state)),
                                label: _statusLabel(_controller.state),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: _sheetAnimationDuration,
                      child: _sheetMode == RunSheetMode.preRun
                          ? _MapCircleButton(
                              key: const ValueKey('settings_button'),
                              tooltip: 'Run settings',
                              icon: Icons.settings_outlined,
                              onPressed: () => _showPreviewMessage(
                                'Run settings preview is coming soon.',
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey('settings_button_hidden'),
                              width: 48,
                              height: 48,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return AnimatedSize(
                      duration: _sheetAnimationDuration,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.bottomCenter,
                      child: _RunBottomSheetShell(
                        bottomInset: bottomInset,
                        mode: _sheetMode,
                        child: AnimatedSwitcher(
                          duration: _sheetAnimationDuration,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(animation);

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: _sheetMode == RunSheetMode.preRun
                              ? _PreRunSheetContent(
                                  key: const ValueKey(RunSheetMode.preRun),
                                  onStart: _startRun,
                                  onSwitchRoute: () => _showPreviewMessage(
                                    'Route switching preview is coming soon.',
                                  ),
                                )
                              : RunTrackingSheetContent(
                                  key: ValueKey(_sheetMode),
                                  state: _controller.state,
                                  onPause: _pauseRun,
                                  onResume: _resumeRun,
                                  onEnd: _finishRun,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCircleButton extends StatefulWidget {
  const _MapCircleButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_MapCircleButton> createState() => _MapCircleButtonState();
}

class _MapCircleButtonState extends State<_MapCircleButton> {
  bool _pressed = false;
  bool _activating = false;

  bool get _visuallyPressed => _pressed || _activating;

  void _setPressed(bool pressed) {
    if (!mounted || _pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }

  Future<void> _handleTap() async {
    setState(() => _activating = true);
    await Future<void>.delayed(_controlPressHold);
    if (!mounted) {
      return;
    }
    setState(() {
      _activating = false;
      _pressed = false;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: _visuallyPressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Material(
          color: _visuallyPressed ? _pressedControlBlue : _softControlBlue,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkResponse(
            onTap: _handleTap,
            onHighlightChanged: _setPressed,
            containedInkWell: true,
            customBorder: const CircleBorder(),
            radius: 34,
            splashColor: _controlSplash,
            highlightColor: _controlHighlight,
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(widget.icon, color: RuniacColors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _RunStatusPill extends StatelessWidget {
  const _RunStatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _softControlBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: _sportOrange, size: 14),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RuniacColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunBottomSheetShell extends StatelessWidget {
  const _RunBottomSheetShell({
    required this.bottomInset,
    required this.mode,
    required this.child,
  });

  final double bottomInset;
  final RunSheetMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final horizontalPadding = mode == RunSheetMode.preRun
            ? (compact ? 22.0 : 28.0)
            : 24.0;
        final topPadding = mode == RunSheetMode.preRun
            ? (compact ? 20.0 : 24.0)
            : (compact ? 18.0 : 20.0);
        final bottomPadding =
            bottomInset +
            (mode == RunSheetMode.preRun
                ? (compact ? 18.0 : 22.0)
                : (compact ? 18.0 : 22.0));

        return Container(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26172033),
                blurRadius: 26,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class _PreRunSheetContent extends StatelessWidget {
  const _PreRunSheetContent({
    super.key,
    required this.onStart,
    required this.onSwitchRoute,
  });

  final VoidCallback onStart;
  final VoidCallback onSwitchRoute;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final startHeight = compact ? 56.0 : 66.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    runLaunchDemoSnapshot.planLabel,
                    style: const TextStyle(
                      color: _sportOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: onSwitchRoute,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _panelTextBlue,
                    side: const BorderSide(color: _blueBorder),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(runLaunchDemoSnapshot.switchRouteLabel),
                ),
              ],
            ),
            SizedBox(height: compact ? 16 : 22),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              runSpacing: 2,
              children: [
                Text(
                  runLaunchDemoSnapshot.distanceValue,
                  style: const TextStyle(
                    color: _panelTextBlue,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    runLaunchDemoSnapshot.distanceUnitLabel,
                    style: const TextStyle(
                      color: _mutedBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              runLaunchDemoSnapshot.paceLabel,
              style: const TextStyle(
                color: _mutedBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: compact ? 18 : 24),
            SizedBox(
              width: double.infinity,
              height: startHeight,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
                label: Text(runLaunchDemoSnapshot.startLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: _sportOrange,
                  foregroundColor: RuniacColors.white,
                  elevation: 8,
                  shadowColor: _orangeShadow,
                  textStyle: TextStyle(
                    fontSize: compact ? 24 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
