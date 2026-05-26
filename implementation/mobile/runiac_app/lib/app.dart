import 'package:flutter/material.dart';

class RuniacColors {
  const RuniacColors._();

  static const primaryBlue = Color(0xFF2F50C7);
  static const accentOrange = Color(0xFFFC6818);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F8FC);
  static const textPrimary = Color(0xFF172033);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE6EAF2);
}

class RuniacApp extends StatelessWidget {
  const RuniacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runiac',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: RuniacColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: RuniacColors.white,
          foregroundColor: RuniacColors.textPrimary,
          elevation: 0,
          surfaceTintColor: RuniacColors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: RuniacColors.white,
          selectedItemColor: RuniacColors.primaryBlue,
          unselectedItemColor: RuniacColors.textSecondary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: RuniacColors.primaryBlue,
            foregroundColor: RuniacColors.white,
          ),
        ),
      ),
      home: const _RuniacShell(),
    );
  }
}

class _RuniacShell extends StatefulWidget {
  const _RuniacShell();

  @override
  State<_RuniacShell> createState() => _RuniacShellState();
}

class _RuniacShellState extends State<_RuniacShell> {
  static const List<Widget> _tabs = [
    _HomeTab(),
    _PlaceholderTab(
      title: 'Maps',
      message: 'Community routes and maps will appear here.',
    ),
    _PlaceholderTab(title: 'Run', message: 'Run tools will appear here.'),
    _PlaceholderTab(
      title: 'Leaderboard',
      message: 'Leaderboard content will appear here.',
    ),
    _PlaceholderTab(
      title: 'You',
      message: 'Profile and settings will appear here.',
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Runiac')),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: RuniacColors.background,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: const [
            _HomeHeader(),
            SizedBox(height: 16),
            _TodayPlanCard(),
            SizedBox(height: 14),
            _GoalPreparationCard(),
            SizedBox(height: 14),
            _RunnerProgressCard(),
            SizedBox(height: 14),
            _WeeklyPlanCard(),
            SizedBox(height: 14),
            _LastRunCard(),
            SizedBox(height: 14),
            _AdviceCard(),
            SizedBox(height: 14),
            _CommunityRouteCard(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeAccentBar(),
        SizedBox(height: 16),
        Text(
          'Good to see you',
          style: TextStyle(
            color: RuniacColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.12,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your Home dashboard is ready for a calm start.',
          style: TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.calendar_today, title: 'Today\'s Plan'),
          const SizedBox(height: 16),
          const Text(
            'Ready for an easy run?',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your next run will appear here.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions_run),
                  label: const Text('Quick Start'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RuniacColors.primaryBlue,
                    side: const BorderSide(color: RuniacColors.border),
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('View Plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalPreparationCard extends StatelessWidget {
  const _GoalPreparationCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.flag_outlined, title: 'Goal Preparation'),
          SizedBox(height: 14),
          Text(
            'Your training progress will appear here.',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Next milestone appears after your plan starts.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 18),
          _ProgressPlaceholder(),
        ],
      ),
    );
  }
}

class _RunnerProgressCard extends StatelessWidget {
  const _RunnerProgressCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.emoji_events_outlined,
            title: 'Runner Progress',
          ),
          SizedBox(height: 14),
          Text(
            'XP and level will appear after verified runs.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 18),
          _ProgressPlaceholder(),
        ],
      ),
    );
  }
}

class _WeeklyPlanCard extends StatelessWidget {
  const _WeeklyPlanCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.view_week_outlined,
            title: 'This Week\'s Plan',
          ),
          const SizedBox(height: 14),
          const Text(
            'Your weekly plan will appear after setup.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const _PlanSkeletonRow(),
          const SizedBox(height: 10),
          const _PlanSkeletonRow(),
          const SizedBox(height: 10),
          const _PlanSkeletonRow(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: RuniacColors.primaryBlue,
                side: const BorderSide(color: RuniacColors.border),
                minimumSize: const Size.fromHeight(46),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('View Plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastRunCard extends StatelessWidget {
  const _LastRunCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.history, title: 'Last Run'),
          SizedBox(height: 14),
          Text(
            'Complete a run to see your summary.',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your first run summary will appear here.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.tips_and_updates_outlined, title: 'Advice'),
          SizedBox(height: 14),
          Text(
            'Post-run advice will appear after your completed runs.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          _SoftNotice(text: 'Helpful guidance will appear here after a run.'),
        ],
      ),
    );
  }
}

class _CommunityRouteCard extends StatelessWidget {
  const _CommunityRouteCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.route_outlined,
            title: 'Recommended Community Route',
            accent: true,
          ),
          SizedBox(height: 14),
          Text(
            'Community routes will appear here.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          _RoutePlaceholder(),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: RuniacColors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: RuniacColors.border),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent ? const Color(0x1AFC6818) : const Color(0x1A2F50C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: accent
                ? RuniacColors.accentOrange
                : RuniacColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeAccentBar extends StatelessWidget {
  const _HomeAccentBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.primaryBlue,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _ProgressPlaceholder extends StatelessWidget {
  const _ProgressPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: RuniacColors.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: RuniacColors.border),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: _SkeletonLine()),
            SizedBox(width: 12),
            _SkeletonLine(width: 58),
          ],
        ),
      ],
    );
  }
}

class _PlanSkeletonRow extends StatelessWidget {
  const _PlanSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RuniacColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Row(
        children: const [
          _SkeletonDot(),
          SizedBox(width: 12),
          Expanded(child: _SkeletonLine()),
          SizedBox(width: 12),
          _SkeletonLine(width: 44),
        ],
      ),
    );
  }
}

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: RuniacColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 44,
            right: 20,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: RuniacColors.accentOrange,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Positioned(left: 18, top: 35, child: _RoutePin()),
          const Positioned(right: 18, top: 35, child: _RoutePin()),
        ],
      ),
    );
  }
}

class _RoutePin extends StatelessWidget {
  const _RoutePin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RuniacColors.accentOrange, width: 3),
      ),
    );
  }
}

class _SoftNotice extends StatelessWidget {
  const _SoftNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RuniacColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: RuniacColors.textSecondary,
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SkeletonDot extends StatelessWidget {
  const _SkeletonDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: RuniacColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: RuniacColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
