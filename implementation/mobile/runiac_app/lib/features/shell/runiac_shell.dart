import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/runiac_colors.dart';
import '../home/presentation/home_tab.dart';
import '../leaderboard/presentation/leaderboard_tab.dart';
import '../maps/presentation/maps_tab.dart';
import '../run/domain/models/run_location_sample.dart';
import '../run/presentation/active_run_session_coordinator.dart';
import '../run/presentation/run_launch_screen.dart';
import '../run/presentation/run_open_intent.dart';
import '../you/presentation/you_tab.dart';

const _floatingBottomNavigationKey = ValueKey(
  'runiac-floating-bottom-navigation',
);
const _floatingBottomNavigationActivePillKey = ValueKey(
  'runiac-floating-bottom-navigation-active-pill',
);

const _bottomNavigationItems = [
  _BottomNavigationItem(label: 'Home', icon: Icons.home),
  _BottomNavigationItem(label: 'Maps', icon: Icons.map),
  _BottomNavigationItem(label: 'Run', icon: Icons.directions_run),
  _BottomNavigationItem(label: 'Leaderboard', icon: Icons.leaderboard),
  _BottomNavigationItem(label: 'You', icon: Icons.person),
];

class RuniacShell extends StatefulWidget {
  const RuniacShell({
    super.key,
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
    this.initialRunOpenIntent,
  });

  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;
  final RunOpenIntent? initialRunOpenIntent;

  @override
  State<RuniacShell> createState() => _RuniacShellState();
}

class _RuniacShellState extends State<RuniacShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final bool _ownsActiveRunSessionCoordinator =
      widget.activeRunSessionCoordinator == null;
  late final ActiveRunSessionCoordinator _activeRunSessionCoordinator =
      widget.activeRunSessionCoordinator ?? ActiveRunSessionCoordinator();
  bool _handledInitialRunOpenIntent = false;
  bool _runLaunchRouteOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleInitialRunOpenIntent();
  }

  @override
  void didUpdateWidget(covariant RuniacShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRunOpenIntent != widget.initialRunOpenIntent) {
      _handledInitialRunOpenIntent = false;
      _scheduleInitialRunOpenIntent();
    }
  }

  void _scheduleInitialRunOpenIntent() {
    if (widget.initialRunOpenIntent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openInitialRunIntent();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsActiveRunSessionCoordinator) {
      _activeRunSessionCoordinator.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _openActiveRunFromSystemReturn();
    }
  }

  Future<void> _handleNavigationTap(int index) async {
    if (index == 2) {
      final initialPreviewCurrentPosition =
          await prewarmRunLaunchPreviewCurrentPosition(
            enableForegroundGps: widget.enableForegroundGps,
          );
      if (!mounted) {
        return;
      }
      _pushRunLaunchRoute(
        initialPreviewCurrentPosition: initialPreviewCurrentPosition,
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _openInitialRunIntent() {
    if (!mounted ||
        _handledInitialRunOpenIntent ||
        !_activeRunSessionCoordinator.hasOpenRun) {
      return;
    }

    _handledInitialRunOpenIntent = true;
    _activeRunSessionCoordinator.syncNow();
    _pushRunLaunchRoute();
  }

  void _openActiveRunFromSystemReturn() {
    if (!mounted ||
        _runLaunchRouteOpen ||
        !_activeRunSessionCoordinator.hasOpenRun) {
      return;
    }

    _activeRunSessionCoordinator.syncNow();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _runLaunchRouteOpen ||
          !_activeRunSessionCoordinator.hasOpenRun) {
        return;
      }
      _pushRunLaunchRoute();
    });
  }

  void _pushRunLaunchRoute({RunLocationSample? initialPreviewCurrentPosition}) {
    _runLaunchRouteOpen = true;
    Navigator.of(context)
        .push(
          _buildRunLaunchRoute(
            initialPreviewCurrentPosition: initialPreviewCurrentPosition,
          ),
        )
        .whenComplete(() {
          _runLaunchRouteOpen = false;
        });
  }

  PageRouteBuilder<void> _buildRunLaunchRoute({
    RunLocationSample? initialPreviewCurrentPosition,
  }) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return RunLaunchScreen(
          enableForegroundGps: widget.enableForegroundGps,
          initialPreviewCurrentPosition: initialPreviewCurrentPosition,
          activeRunSessionCoordinator: _activeRunSessionCoordinator,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(
        enableForegroundGps: widget.enableForegroundGps,
        activeRunSessionCoordinator: _activeRunSessionCoordinator,
      ),
      const MapsTab(),
      const SizedBox.shrink(),
      const LeaderboardTab(),
      YouTab(
        enableForegroundGps: widget.enableForegroundGps,
        activeRunSessionCoordinator: _activeRunSessionCoordinator,
      ),
    ];

    return Scaffold(
      appBar:
          _selectedIndex == 0 ||
              _selectedIndex == 1 ||
              _selectedIndex == 3 ||
              _selectedIndex == 4
          ? null
          : AppBar(title: const Text('Runiac')),
      body: tabs[_selectedIndex],
      bottomNavigationBar: _FloatingIslandBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: _handleNavigationTap,
      ),
    );
  }
}

class _FloatingIslandBottomNavigation extends StatelessWidget {
  const _FloatingIslandBottomNavigation({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _FloatingIslandNavigationMetrics.fromWidth(
          constraints.maxWidth,
        );

        return SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: metrics.bottomGap),
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1,
            child: SizedBox(
              key: _floatingBottomNavigationKey,
              width: metrics.islandWidth,
              height: metrics.islandHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(metrics.islandRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: RuniacColors.textPrimary.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(metrics.islandRadius),
                      border: Border.all(
                        color: RuniacColors.white.withValues(alpha: 0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RuniacColors.primaryBlue.withValues(
                            alpha: 0.18,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.outerPadding,
                        vertical: metrics.outerPadding,
                      ),
                      child: Row(
                        children: [
                          for (
                            var index = 0;
                            index < _bottomNavigationItems.length;
                            index += 1
                          )
                            Expanded(
                              child: _FloatingIslandNavigationButton(
                                item: _bottomNavigationItems[index],
                                selected: index == selectedIndex,
                                metrics: metrics,
                                onPressed: () => onTap(index),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingIslandNavigationButton extends StatelessWidget {
  const _FloatingIslandNavigationButton({
    required this.item,
    required this.selected,
    required this.metrics,
    required this.onPressed,
  });

  final _BottomNavigationItem item;
  final bool selected;
  final _FloatingIslandNavigationMetrics metrics;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected
        ? RuniacColors.white
        : RuniacColors.white.withValues(alpha: 0.72);
    final segmentColor = selected
        ? RuniacColors.primaryBlue.withValues(alpha: 0.78)
        : Colors.transparent;

    return Tooltip(
      message: item.label,
      child: Semantics(
        label: '${item.label} tab',
        button: true,
        selected: selected,
        child: AnimatedContainer(
          key: selected ? _floatingBottomNavigationActivePillKey : null,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: selected ? metrics.selectedPillWidth : metrics.inactiveWidth,
          height: metrics.buttonHeight,
          decoration: BoxDecoration(
            color: segmentColor,
            borderRadius: BorderRadius.circular(metrics.pillRadius),
            border: selected
                ? Border.all(color: RuniacColors.white.withValues(alpha: 0.2))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: RuniacColors.primaryBlue.withValues(alpha: 0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            onPressed: onPressed,
            color: iconColor,
            iconSize: metrics.iconSize,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.expand(),
            icon: Icon(item.icon),
          ),
        ),
      ),
    );
  }
}

class _FloatingIslandNavigationMetrics {
  const _FloatingIslandNavigationMetrics({
    required this.islandWidth,
    required this.islandHeight,
    required this.bottomGap,
    required this.outerPadding,
    required this.iconSize,
    required this.buttonHeight,
    required this.selectedPillWidth,
    required this.inactiveWidth,
  });

  factory _FloatingIslandNavigationMetrics.fromWidth(double availableWidth) {
    final safeWidth = availableWidth.isFinite && availableWidth > 0
        ? availableWidth
        : 360.0;
    final horizontalInset = safeWidth < 380 ? 14.0 : 22.0;
    final maxIslandWidth = math.min(430.0, safeWidth - (horizontalInset * 2));
    final preferredWidth = safeWidth * (safeWidth < 380 ? 0.92 : 0.9);
    final islandWidth = math.min(
      math.max(0.0, maxIslandWidth),
      math.max(280.0, preferredWidth),
    );
    final islandHeight = (islandWidth * 0.18).clamp(64.0, 76.0);
    final outerPadding = (islandHeight * 0.1).clamp(6.0, 8.0);
    final buttonHeight = islandHeight - (outerPadding * 2);

    return _FloatingIslandNavigationMetrics(
      islandWidth: islandWidth,
      islandHeight: islandHeight,
      bottomGap: (islandHeight * 0.22).clamp(14.0, 18.0),
      outerPadding: outerPadding,
      iconSize: (islandHeight * 0.4).clamp(24.0, 30.0),
      buttonHeight: buttonHeight,
      selectedPillWidth: (islandHeight * 1.42).clamp(82.0, 104.0),
      inactiveWidth: (islandHeight * 0.72).clamp(46.0, 54.0),
    );
  }

  final double islandWidth;
  final double islandHeight;
  final double bottomGap;
  final double outerPadding;
  final double iconSize;
  final double buttonHeight;
  final double selectedPillWidth;
  final double inactiveWidth;

  double get islandRadius => islandHeight / 2;
  double get pillRadius => buttonHeight / 2;
}

class _BottomNavigationItem {
  const _BottomNavigationItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
