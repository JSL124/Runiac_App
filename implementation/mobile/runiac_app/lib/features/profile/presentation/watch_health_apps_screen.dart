import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../../run/data/apple_health_workout_import_repository.dart';
import '../../run/domain/repositories/health_workout_import_repository.dart';

class WatchHealthAppsScreen extends StatefulWidget {
  const WatchHealthAppsScreen({
    super.key,
    this.appleHealthRepository = const AppleHealthWorkoutImportRepository(),
  });

  final HealthWorkoutImportRepository appleHealthRepository;

  static const _rowHeight = 80.0;
  static const _horizontalInset = 16.0;
  static const _titleDescriptionGap = 3.0;

  static const _manageDeviceRows = <_WatchHealthRowData>[
    _WatchHealthRowData(
      icon: Icons.add_circle_outline_rounded,
      title: 'Connect a new device to Runiac',
      description:
          'Use your watch or health app to bring in completed runs later.',
    ),
    _WatchHealthRowData(
      icon: Icons.watch_outlined,
      title: 'Apple Watch',
      description: 'Set up Apple Health permissions later.',
    ),
    _WatchHealthRowData(
      icon: Icons.watch_outlined,
      title: 'Garmin',
      description: 'Available later through health app sync.',
    ),
  ];

  static const _serviceRows = <_WatchHealthRowData>[
    _WatchHealthRowData(
      icon: Icons.favorite_border_rounded,
      title: 'Apple Health',
      description: 'Bring in completed runs from Apple Health later.',
      checksAppleHealth: true,
    ),
    _WatchHealthRowData(
      icon: Icons.health_and_safety_outlined,
      title: 'Health Connect',
      description: 'Bring in completed runs from Health Connect later.',
    ),
    _WatchHealthRowData(
      icon: Icons.watch_outlined,
      title: 'Garmin via Health',
      description: 'Use health app sync for Garmin runs later.',
    ),
  ];

  @override
  State<WatchHealthAppsScreen> createState() => _WatchHealthAppsScreenState();
}

class _WatchHealthAppsScreenState extends State<WatchHealthAppsScreen> {
  bool _isCheckingAppleHealth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Watch & Health Apps',
              tooltip: 'Back to Account',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _WatchHealthSection(
                        label: 'MANAGE DEVICES',
                        rows: WatchHealthAppsScreen._manageDeviceRows,
                      ),
                      const SizedBox(height: 16),
                      _WatchHealthSection(
                        label: 'SERVICES',
                        rows: WatchHealthAppsScreen._serviceRows,
                        onAppleHealthTap: _checkAppleHealth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAppleHealth(BuildContext context) async {
    if (_isCheckingAppleHealth) {
      return;
    }
    _isCheckingAppleHealth = true;
    try {
      final candidates = await widget.appleHealthRepository
          .listRecentRunningWorkouts();
      if (!context.mounted) {
        return;
      }
      final message = candidates.isEmpty
          ? 'No Apple Health runs found yet.'
          : 'Found ${candidates.length} Apple Health runs.';
      _showSnackBar(context, message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, 'Apple Health is not available right now.');
    } finally {
      _isCheckingAppleHealth = false;
    }
  }
}

class _WatchHealthSection extends StatelessWidget {
  const _WatchHealthSection({
    required this.label,
    required this.rows,
    this.onAppleHealthTap,
  });

  final String label;
  final List<_WatchHealthRowData> rows;
  final Future<void> Function(BuildContext context)? onAppleHealthTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WatchHealthAppsScreen._horizontalInset,
          ),
          child: _SectionLabel(label),
        ),
        const SizedBox(height: 6),
        for (var index = 0; index < rows.length; index++) ...[
          _WatchHealthRow(row: rows[index], onAppleHealthTap: onAppleHealthTap),
        ],
      ],
    );
  }
}

class _WatchHealthRow extends StatelessWidget {
  const _WatchHealthRow({required this.row, this.onAppleHealthTap});

  final _WatchHealthRowData row;
  final Future<void> Function(BuildContext context)? onAppleHealthTap;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      semanticLabel: row.title,
      borderRadius: BorderRadius.zero,
      height: WatchHealthAppsScreen._rowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: WatchHealthAppsScreen._horizontalInset,
      ),
      onTap: () {
        if (row.checksAppleHealth && onAppleHealthTap != null) {
          onAppleHealthTap!(context);
          return;
        }
        _showSnackBar(context, 'Health connections come next.');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconTile(icon: row.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(
                  height: WatchHealthAppsScreen._titleDescriptionGap,
                ),
                Text(
                  row.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.chevron_right_rounded,
            color: RuniacColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RuniacColors.sectionSurfaceStrong,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: RuniacColors.primaryBlue, size: 18),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: RuniacColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _WatchHealthRowData {
  const _WatchHealthRowData({
    required this.icon,
    required this.title,
    required this.description,
    this.checksAppleHealth = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool checksAppleHealth;
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
