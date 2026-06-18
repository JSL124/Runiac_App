import 'dart:math' as math;

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
        final horizontalInset = constraints.maxWidth < 380 ? 12.0 : 20.0;
        final islandWidth = math.min(
          math.max(0.0, constraints.maxWidth - (horizontalInset * 2)),
          430.0,
        );

        return SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 14),
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1,
            child: SizedBox(
              key: _floatingBottomNavigationKey,
              width: islandWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: RuniacColors.white,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: RuniacColors.border.withValues(alpha: 0.78),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RuniacColors.primaryBlue.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (
                        var index = 0;
                        index < _bottomNavigationItems.length;
                        index += 1
                      )
                        _FloatingIslandNavigationButton(
                          item: _bottomNavigationItems[index],
                          selected: index == selectedIndex,
                          onPressed: () => onTap(index),
                        ),
                    ],
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
    required this.onPressed,
  });

  final _BottomNavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected
        ? RuniacColors.white
        : RuniacColors.textSecondary;
    final segmentColor = selected
        ? RuniacColors.primaryBlue
        : Colors.transparent;

    return Tooltip(
      message: item.label,
      child: Semantics(
        label: '${item.label} tab',
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: selected ? 84 : 48,
          height: 52,
          decoration: BoxDecoration(
            color: segmentColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: RuniacColors.primaryBlue.withValues(alpha: 0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            onPressed: onPressed,
            color: iconColor,
            icon: Icon(item.icon),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItem {
  const _BottomNavigationItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
