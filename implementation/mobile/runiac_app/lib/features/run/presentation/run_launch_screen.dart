import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/run_map_placeholder.dart';

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
const _endHoldDuration = Duration(milliseconds: 1500);

const _runLaunchSnapshot = _RunLaunchDisplaySnapshot(
  planLabel: 'TODAY\'S PLAN',
  switchRouteLabel: 'Switch route',
  distanceValue: '4.5',
  distanceUnitLabel: 'km easy run',
  paceLabel: 'Pace 7:10-7:40 / km · ~32 min',
  startLabel: 'Start run',
);

const _runLiveSnapshot = _RunLiveDisplaySnapshot(
  progressSummaryLabel: '4.10 of 4.50 km',
  progressPercentLabel: '91%',
  progressValue: 0.91,
  distanceLabel: 'DISTANCE',
  distanceValue: '4.10',
  distanceUnitLabel: 'km',
  timeLabel: 'TIME',
  timeValue: '30:10',
  avgPaceLabel: 'AVG PACE',
  avgPaceValue: '6:30/km',
);

enum _RunScreenMode { launch, live, paused }

class _RunLaunchDisplaySnapshot {
  const _RunLaunchDisplaySnapshot({
    required this.planLabel,
    required this.switchRouteLabel,
    required this.distanceValue,
    required this.distanceUnitLabel,
    required this.paceLabel,
    required this.startLabel,
  });

  final String planLabel;
  final String switchRouteLabel;
  final String distanceValue;
  final String distanceUnitLabel;
  final String paceLabel;
  final String startLabel;
}

class _RunLiveDisplaySnapshot {
  const _RunLiveDisplaySnapshot({
    required this.progressSummaryLabel,
    required this.progressPercentLabel,
    required this.progressValue,
    required this.distanceLabel,
    required this.distanceValue,
    required this.distanceUnitLabel,
    required this.timeLabel,
    required this.timeValue,
    required this.avgPaceLabel,
    required this.avgPaceValue,
  });

  final String progressSummaryLabel;
  final String progressPercentLabel;
  final double progressValue;
  final String distanceLabel;
  final String distanceValue;
  final String distanceUnitLabel;
  final String timeLabel;
  final String timeValue;
  final String avgPaceLabel;
  final String avgPaceValue;
}

class RunLaunchScreen extends StatefulWidget {
  const RunLaunchScreen({super.key});

  @override
  State<RunLaunchScreen> createState() => _RunLaunchScreenState();
}

class _RunLaunchScreenState extends State<RunLaunchScreen> {
  _RunScreenMode _mode = _RunScreenMode.launch;

  bool get _hasActiveRun => _mode != _RunScreenMode.launch;

  void _startRun() {
    setState(() => _mode = _RunScreenMode.live);
  }

  void _pauseRun() {
    setState(() => _mode = _RunScreenMode.paused);
  }

  void _resumeRun() {
    setState(() => _mode = _RunScreenMode.live);
  }

  void _endRun() {
    // Static placeholder only. Real end-run flow belongs to a later capsule.
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomOffset = math.max(viewPadding.bottom + 20.0, 28.0);

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
                    if (_hasActiveRun)
                      const SizedBox(width: 58, height: 58)
                    else
                      _MapCircleButton(
                        tooltip: 'Close',
                        icon: Icons.close,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    Expanded(
                      child: Center(
                        child: _RunStatusPill(
                          label: switch (_mode) {
                            _RunScreenMode.launch => 'GPS ready',
                            _RunScreenMode.live => 'Running · easy',
                            _RunScreenMode.paused => 'Paused · easy',
                          },
                        ),
                      ),
                    ),
                    if (_hasActiveRun)
                      const SizedBox(width: 58, height: 58)
                    else
                      _MapCircleButton(
                        tooltip: 'Run settings',
                        icon: Icons.settings_outlined,
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomOffset,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _hasActiveRun
                      ? _LiveTrackingPanel(
                          key: const ValueKey('live'),
                          isPaused: _mode == _RunScreenMode.paused,
                          onPause: _pauseRun,
                          onResume: _resumeRun,
                          onEnd: _endRun,
                        )
                      : _RunBottomPanel(
                          key: const ValueKey('launch'),
                          onStart: _startRun,
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

class _MapCircleButton extends StatefulWidget {
  const _MapCircleButton({
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
  const _RunStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            label,
            style: const TextStyle(
              color: RuniacColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunBottomPanel extends StatelessWidget {
  const _RunBottomPanel({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final panelPadding = compact
            ? const EdgeInsets.fromLTRB(22, 20, 22, 22)
            : const EdgeInsets.fromLTRB(28, 24, 28, 26);
        final startHeight = compact ? 56.0 : 66.0;

        return Container(
          padding: panelPadding,
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26172033),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _runLaunchSnapshot.planLabel,
                      style: const TextStyle(
                        color: _sportOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
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
                    child: Text(_runLaunchSnapshot.switchRouteLabel),
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
                    _runLaunchSnapshot.distanceValue,
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
                      _runLaunchSnapshot.distanceUnitLabel,
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
                _runLaunchSnapshot.paceLabel,
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
                  label: Text(_runLaunchSnapshot.startLabel),
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
          ),
        );
      },
    );
  }
}

class _LiveTrackingPanel extends StatelessWidget {
  const _LiveTrackingPanel({
    super.key,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final panelPadding = compact
            ? const EdgeInsets.fromLTRB(20, 18, 20, 18)
            : const EdgeInsets.fromLTRB(24, 20, 24, 22);
        final pauseHeight = compact ? 50.0 : 56.0;

        return Container(
          padding: panelPadding,
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26172033),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProgressSummaryRow(),
              const SizedBox(height: 8),
              _RunProgressBar(progress: _runLiveSnapshot.progressValue),
              SizedBox(height: compact ? 14 : 16),
              const _DistanceFocus(),
              SizedBox(height: compact ? 12 : 14),
              const Divider(height: 1, color: _blueBorder),
              SizedBox(height: compact ? 10 : 12),
              const _LiveMetricRow(),
              SizedBox(height: compact ? 14 : 16),
              _LiveRunActions(
                isPaused: isPaused,
                height: pauseHeight,
                compact: compact,
                onPause: onPause,
                onResume: onResume,
                onEnd: onEnd,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveRunActions extends StatelessWidget {
  const _LiveRunActions({
    required this.isPaused,
    required this.height,
    required this.compact,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  final bool isPaused;
  final double height;
  final bool compact;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
          child: isPaused
              ? SizedBox.expand(
                  key: const ValueKey('paused-actions'),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: height,
                          child: FilledButton.icon(
                            onPressed: onResume,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 25,
                            ),
                            label: const Text('Resume'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _panelTextBlue,
                              foregroundColor: RuniacColors.white,
                              elevation: 8,
                              shadowColor: const Color(0x333151C8),
                              textStyle: TextStyle(
                                fontSize: compact ? 18 : 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: height,
                          child: _HoldToEndButton(
                            compact: compact,
                            onHoldAnimationCompleted: onEnd,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.expand(
                  key: const ValueKey('live-action'),
                  child: FilledButton.icon(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause_rounded, size: 26),
                    label: const Text('Pause'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _panelTextBlue,
                      foregroundColor: RuniacColors.white,
                      elevation: 8,
                      shadowColor: const Color(0x333151C8),
                      textStyle: TextStyle(
                        fontSize: compact ? 20 : 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _HoldToEndButton extends StatefulWidget {
  const _HoldToEndButton({
    required this.compact,
    required this.onHoldAnimationCompleted,
  });

  final bool compact;
  final VoidCallback onHoldAnimationCompleted;

  @override
  State<_HoldToEndButton> createState() => _HoldToEndButtonState();
}

class _HoldToEndButtonState extends State<_HoldToEndButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _holdAnimationCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _endHoldDuration)
      ..addStatusListener(_handleHoldStatus);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleHoldStatus)
      ..dispose();
    super.dispose();
  }

  void _handleHoldStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _holdAnimationCompleted) {
      return;
    }

    _holdAnimationCompleted = true;
    widget.onHoldAnimationCompleted();
    if (!mounted) {
      return;
    }
    _controller.reset();
  }

  void _startHold(PointerDownEvent event) {
    _holdAnimationCompleted = false;
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_holdAnimationCompleted) {
      _holdAnimationCompleted = false;
      return;
    }

    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Hold to end',
      child: Listener(
        key: const Key('run_hold_to_end_button'),
        behavior: HitTestBehavior.opaque,
        onPointerDown: _startHold,
        onPointerUp: (_) => _cancelHold(),
        onPointerCancel: (_) => _cancelHold(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      border: Border.all(color: _blueBorder),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      key: const Key('run_hold_to_end_fill'),
                      widthFactor: _controller.value,
                      heightFactor: 1,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0x26FF7A1A)),
                      ),
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'End',
                    style: TextStyle(
                      color: _panelTextBlue,
                      fontSize: widget.compact ? 18 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSummaryRow extends StatelessWidget {
  const _ProgressSummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _runLiveSnapshot.progressSummaryLabel,
            style: const TextStyle(
              color: _mutedBlue,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          _runLiveSnapshot.progressPercentLabel,
          style: const TextStyle(
            color: _panelTextBlue,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RunProgressBar extends StatelessWidget {
  const _RunProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: const Color(0xFFE5EAFF),
        color: _sportOrange,
      ),
    );
  }
}

class _DistanceFocus extends StatelessWidget {
  const _DistanceFocus();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _runLiveSnapshot.distanceLabel,
            style: const TextStyle(
              color: _mutedBlue,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _runLiveSnapshot.distanceValue,
                style: const TextStyle(
                  color: _panelTextBlue,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 0.92,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _runLiveSnapshot.distanceUnitLabel,
                  style: const TextStyle(
                    color: _mutedBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveMetricRow extends StatelessWidget {
  const _LiveMetricRow();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(
              label: _runLiveSnapshot.timeLabel,
              value: _runLiveSnapshot.timeValue,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: _blueBorder),
          Expanded(
            child: _MetricItem(
              label: _runLiveSnapshot.avgPaceLabel,
              value: _runLiveSnapshot.avgPaceValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _mutedBlue,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _panelTextBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
