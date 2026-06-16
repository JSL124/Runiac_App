import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../domain/models/run_tracking_state.dart';
import 'controllers/run_tracking_controller.dart';
import 'cool_down_screen.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_mapbox_follow_qa_overlay.dart';
import 'widgets/run_mapbox_surface_config.dart';
import 'widgets/run_tracking_map_surface.dart';
import 'widgets/run_tracking_sheet_content.dart';

const _sportOrange = Color(0xFFFF7A1A);
const _softControlBlue = Color(0x667A91E5);
const _screenBackground = Color(0xFF3153C9);
const _recenterButtonSize = 48.0;
const _sheetAdjacentRecenterGap = 10.0;
const _activeRecenterRightPadding = 24.0;

class RunActiveScreen extends StatefulWidget {
  const RunActiveScreen({
    super.key,
    this.controller,
    this.mapboxAccessToken,
    this.mapboxBuilder,
    this.enableMapboxFollowQa = runMapboxFollowQaEnabled,
  });

  final RunTrackingController? controller;
  final String? mapboxAccessToken;
  final RunMapboxSurfaceBuilder? mapboxBuilder;
  final bool enableMapboxFollowQa;

  @override
  State<RunActiveScreen> createState() => _RunActiveScreenState();
}

class _RunActiveScreenState extends State<RunActiveScreen> {
  late final RunTrackingController _controller;
  late final bool _ownsController;
  Timer? _ticker;
  bool _isFollowingRunner = true;
  int _mapRecenterRequestId = 0;
  late final RunMapboxFollowQaDiagnostics? _followQaDiagnostics =
      widget.enableMapboxFollowQa
      ? RunMapboxFollowQaDiagnostics(enabled: true, screenPath: 'active')
      : null;

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

  void _updateFollowQaMapState() {
    final diagnostics = _followQaDiagnostics;
    diagnostics?.updateMapState(
      mapPath: diagnostics.mapPath,
      isFollowingRunner: _isFollowingRunner,
      recenterRequestId: _mapRecenterRequestId,
    );
  }

  void _recenterRunner() {
    setState(() {
      _isFollowingRunner = true;
      _mapRecenterRequestId++;
    });
    _followQaDiagnostics?.recordRecenterRequest(_mapRecenterRequestId);
    _updateFollowQaMapState();
  }

  void _resumeRun() {
    _controller.resume();
    _followQaDiagnostics?.recordResume();
    _updateFollowQaMapState();
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
                return RunTrackingMapSurface(
                  mapViewState: _controller.mapViewState,
                  isFollowingRunner: _isFollowingRunner,
                  recenterRequestId: _mapRecenterRequestId,
                  onManualPan: () {
                    _followQaDiagnostics?.recordOnManualPan();
                    setState(() => _isFollowingRunner = false);
                    _updateFollowQaMapState();
                  },
                  onRecenter: _recenterRunner,
                  showRecenterButton: false,
                  mapboxAccessToken: widget.mapboxAccessToken,
                  mapboxBuilder: widget.mapboxBuilder,
                  followQaDiagnostics: _followQaDiagnostics,
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
                          : _controller.state.locationStatus.label,
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
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: _recenterButtonSize + _sheetAdjacentRecenterGap,
                      ),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return _RunActivePanel(
                            key: const Key('runActivePanel'),
                            state: _controller.state,
                            onPause: _controller.pause,
                            onResume: _resumeRun,
                            onFinish: _finishRun,
                            bottomInset: bottomInset,
                          );
                        },
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Positioned(
                          top: 0,
                          right: _activeRecenterRightPadding,
                          child: Opacity(
                            opacity: _hasCurrentPosition ? 1 : 0.58,
                            child: RunMapRecenterButton(
                              onPressed: _recenterRunner,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasCurrentPosition {
    return _controller.mapViewState.currentPosition != null;
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: RuniacColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
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
