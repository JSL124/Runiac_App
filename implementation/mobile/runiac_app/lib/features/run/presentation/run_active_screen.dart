import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../domain/models/run_tracking_state.dart';
import 'controllers/run_tracking_controller.dart';
import 'cool_down_screen.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_tracking_sheet_content.dart';

const _sportOrange = Color(0xFFFF7A1A);
const _softControlBlue = Color(0x667A91E5);
const _screenBackground = Color(0xFF3153C9);
const _activeRecenterButtonBottom = 336.0;

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
  bool _isFollowingRunner = true;

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
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _screenBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return RunMapPlaceholder(
                  mapViewState: _controller.mapViewState,
                  isFollowingRunner: _isFollowingRunner,
                  onManualPan: () {
                    setState(() => _isFollowingRunner = false);
                  },
                  onRecenter: () {
                    setState(() => _isFollowingRunner = true);
                  },
                  showRecenterButton: false,
                );
              },
            ),
          ),
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
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return _RunActivePanel(
                      key: const Key('runActivePanel'),
                      state: _controller.state,
                      onPause: _controller.pause,
                      onResume: _controller.resume,
                      onFinish: _finishRun,
                      bottomInset: bottomInset,
                    );
                  },
                ),
              ),
            ),
          ),
          if (!_isFollowingRunner)
            Positioned(
              right: 24,
              bottom: bottomInset + _activeRecenterButtonBottom,
              child: RunMapRecenterButton(
                onPressed: () {
                  setState(() => _isFollowingRunner = true);
                },
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
      ),
    );
  }
}

class _RunActivePanel extends StatelessWidget {
  const _RunActivePanel({
    super.key,
    required this.state,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.bottomInset,
  });

  final RunTrackingState state;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            compact ? 18 : 20,
            24,
            bottomInset + (compact ? 18 : 22),
          ),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26172033),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: RunTrackingSheetContent(
            state: state,
            onPause: onPause,
            onResume: onResume,
            onEnd: onFinish,
          ),
        );
      },
    );
  }
}
