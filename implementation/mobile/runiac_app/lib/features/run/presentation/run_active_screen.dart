import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../domain/models/run_tracking_snapshot.dart';
import '../domain/models/run_tracking_state.dart';
import 'controllers/run_tracking_controller.dart';
import 'cool_down_screen.dart';
import 'widgets/run_map_placeholder.dart';

const _activeBlue = Color(0xFF3151C8);
const _activeOrange = Color(0xFFFF7A1A);
const _mutedBlue = Color(0xFF8296E8);
const _blueBorder = Color(0xFFDCE6FF);
const _softControlBlue = Color(0x667A91E5);
const _screenBackground = Color(0xFF3153C9);

class RunActiveScreen extends StatefulWidget {
  const RunActiveScreen({super.key, this.controller});

  final RunTrackingController? controller;

  @override
  State<RunActiveScreen> createState() => _RunActiveScreenState();
}

class _RunActiveScreenState extends State<RunActiveScreen> {
  late final RunTrackingController _controller;
  late final bool _ownsController;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RunTrackingController();
    if (_controller.state.phase == RunTrackingPhase.idle) {
      _controller.start(routeLabel: 'Easy local route');
    }
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _controller.advanceBy(const Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _finishRun() {
    _controller.finish();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const CoolDownScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomOffset = MediaQuery.viewPaddingOf(context).bottom + 24;

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
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return _RunStatusPill(
                      label: _controller.state.isPaused
                          ? 'Paused · easy'
                          : 'Running · easy',
                    );
                  },
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
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return _RunActivePanel(
                      state: _controller.state,
                      onPause: _controller.pause,
                      onResume: _controller.resume,
                      onFinish: _finishRun,
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

class _RunStatusPill extends StatelessWidget {
  const _RunStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _softControlBlue,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, color: _activeOrange, size: 14),
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
      ),
    );
  }
}

class _RunActivePanel extends StatelessWidget {
  const _RunActivePanel({
    required this.state,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
  });

  final RunTrackingState state;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final snapshot = RunTrackingSnapshot.fromState(state);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Container(
          padding: EdgeInsets.fromLTRB(24, compact ? 20 : 24, 24, 24),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MetricFocus(
                label: 'TIME',
                value: snapshot.elapsedTimeLabel,
                icon: Icons.timer_rounded,
              ),
              SizedBox(height: compact ? 18 : 22),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'DISTANCE',
                      value: snapshot.distanceLabel,
                      icon: Icons.route_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricTile(
                      label: 'AVG PACE',
                      value: snapshot.averagePaceLabel,
                      icon: Icons.speed_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                snapshot.guidance,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _activeBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              SizedBox(height: compact ? 16 : 20),
              _RunActiveActions(
                isPaused: state.isPaused,
                onPause: onPause,
                onResume: onResume,
                onFinish: onFinish,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricFocus extends StatelessWidget {
  const _MetricFocus({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricLabel(label: label, icon: icon),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: _activeBlue,
              fontSize: 68,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: _blueBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            _MetricLabel(label: label, icon: icon),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: _activeBlue,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _mutedBlue, size: 17),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _mutedBlue,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _RunActiveActions extends StatelessWidget {
  const _RunActiveActions({
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
  });

  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: isPaused ? onResume : onPause,
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
              label: Text(isPaused ? 'Resume' : 'Pause'),
              style: FilledButton.styleFrom(
                backgroundColor: _activeBlue,
                foregroundColor: RuniacColors.white,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onFinish,
              icon: const Icon(Icons.flag_rounded),
              label: const Text('Finish'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _activeBlue,
                side: const BorderSide(color: _blueBorder, width: 1.5),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
