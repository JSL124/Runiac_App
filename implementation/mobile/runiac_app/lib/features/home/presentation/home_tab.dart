import 'package:flutter/material.dart';

import '../../account/presentation/account_profile_screen.dart';
import '../../run/presentation/active_run_session_coordinator.dart';
import '../../run/presentation/run_launch_screen.dart';
import '../../you/presentation/weekly_workout_detail_screen.dart';
import 'widgets/home_header.dart';
import 'widgets/home_progress_insight_section.dart';
import 'widgets/explore_routes_section.dart';
import 'widgets/today_plan_card.dart';

const _homeScreenBackground = Colors.white;

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    this.enableForegroundGps = true,
    this.activeRunSessionCoordinator,
  });

  final bool enableForegroundGps;
  final ActiveRunSessionCoordinator? activeRunSessionCoordinator;

  void _showPreviewMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTodayWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return WeeklyWorkoutDetailScreen(
            onBack: () => Navigator.of(context).pop(),
            showEditScheduleAction: false,
            enableForegroundGps: enableForegroundGps,
            activeRunSessionCoordinator: activeRunSessionCoordinator,
          );
        },
      ),
    );
  }

  Future<void> _openQuickStart(BuildContext context) async {
    final initialPreviewCurrentPosition =
        await prewarmRunLaunchPreviewCurrentPosition(
          enableForegroundGps: enableForegroundGps,
        );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RunLaunchScreen(
          enableForegroundGps: enableForegroundGps,
          initialPreviewCurrentPosition: initialPreviewCurrentPosition,
          activeRunSessionCoordinator: activeRunSessionCoordinator,
        ),
      ),
    );
  }

  void _openAccountProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return AccountProfileScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: _homeScreenBackground,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
            children: [
              _HomeContentPadding(
                child: HomeHeader(
                  onNotifications: () => _showPreviewMessage(
                    context,
                    'Notifications preview is coming soon.',
                  ),
                  onProfile: () => _openAccountProfile(context),
                ),
              ),
              const SizedBox(height: 12),
              TodayPlanCard(
                onViewPlan: () => _openTodayWorkout(context),
                onQuickStart: () => _openQuickStart(context),
              ),
              const SizedBox(height: 10),
              const _HomeContentPadding(child: HomeProgressInsightSection()),
              const SizedBox(height: 10),
              const _HomeContentPadding(child: ExploreRoutesSection()),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContentPadding extends StatelessWidget {
  const _HomeContentPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
