import 'package:flutter/material.dart';

import '../home/presentation/home_tab.dart';
import '../leaderboard/presentation/leaderboard_tab.dart';
import '../maps/presentation/maps_tab.dart';
import '../run/domain/models/run_location_sample.dart';
import '../run/presentation/active_run_session_coordinator.dart';
import '../run/presentation/run_launch_screen.dart';
import '../run/presentation/run_open_intent.dart';
import '../you/presentation/you_tab.dart';

const _bottomNavLabels = ['Home', 'Maps', 'Run', 'Leaderboard', 'You'];
const _bottomNavSelectedFontSize = 14.0;
const _bottomNavUnselectedFontSize = 12.0;
const _bottomNavMinFontSize = 10.5;

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
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / _bottomNavLabels.length;
          final selectedFontSize = _bottomNavFontSizeForWidth(
            context: context,
            label: 'Leaderboard',
            availableWidth: tabWidth,
            baseFontSize: _bottomNavSelectedFontSize,
          );
          final unselectedFontSize = _bottomNavFontSizeForWidth(
            context: context,
            label: 'Leaderboard',
            availableWidth: tabWidth,
            baseFontSize: _bottomNavUnselectedFontSize,
          );

          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: selectedFontSize,
            unselectedFontSize: unselectedFontSize,
            selectedLabelStyle: TextStyle(
              fontSize: selectedFontSize,
              overflow: TextOverflow.visible,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: unselectedFontSize,
              overflow: TextOverflow.visible,
            ),
            onTap: _handleNavigationTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_run),
                label: 'Run',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard),
                label: 'Leaderboard',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
            ],
          );
        },
      ),
    );
  }
}

double _bottomNavFontSizeForWidth({
  required BuildContext context,
  required String label,
  required double availableWidth,
  required double baseFontSize,
}) {
  if (!availableWidth.isFinite || availableWidth <= 0) {
    return baseFontSize;
  }

  final textPainter = TextPainter(
    maxLines: 1,
    text: TextSpan(
      text: label,
      style: TextStyle(fontSize: baseFontSize),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();

  final measuredWidth = textPainter.width;
  if (measuredWidth <= availableWidth) {
    return baseFontSize;
  }

  return (baseFontSize * (availableWidth / measuredWidth)).clamp(
    _bottomNavMinFontSize,
    baseFontSize,
  );
}
