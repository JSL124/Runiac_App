import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_buttons.dart';

class WatchHealthAppsScreen extends StatelessWidget {
  const WatchHealthAppsScreen({super.key});

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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      _WatchHealthSection(
                        label: 'MANAGE DEVICES',
                        rows: _manageDeviceRows,
                      ),
                      SizedBox(height: 22),
                      _WatchHealthSection(
                        label: 'SERVICES',
                        rows: _serviceRows,
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
}

class _WatchHealthSection extends StatelessWidget {
  const _WatchHealthSection({required this.label, required this.rows});

  final String label;
  final List<_WatchHealthRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 8),
        for (var index = 0; index < rows.length; index++) ...[
          _WatchHealthRow(row: rows[index]),
          if (index != rows.length - 1)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 46,
              color: RuniacColors.border,
            ),
        ],
      ],
    );
  }
}

class _WatchHealthRow extends StatelessWidget {
  const _WatchHealthRow({required this.row});

  final _WatchHealthRowData row;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      semanticLabel: row.title,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(vertical: 13),
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Health connections come next.')),
          );
      },
      child: Row(
        children: [
          _IconTile(icon: row.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
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
  });

  final IconData icon;
  final String title;
  final String description;
}
