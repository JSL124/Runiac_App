import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  static const _beforeRunRows = <_NotificationPreferenceRowData>[
    _NotificationPreferenceRowData(
      icon: Icons.event_available_outlined,
      title: 'Plan-start reminder',
      subtitle: 'Notifies you 2 hours, 1 hour, and 10 min before your run.',
    ),
    _NotificationPreferenceRowData(
      icon: Icons.today_outlined,
      title: "Today's plan reminder",
      subtitle: 'Notifies you at 12:00 AM if a plan is scheduled for today.',
    ),
  ];

  static const _afterRunRows = <_NotificationPreferenceRowData>[
    _NotificationPreferenceRowData(
      icon: Icons.directions_run_outlined,
      title: 'Missed run nudge',
      subtitle:
          "Notifies you 1 hour and 2 hours after today's plan time if you haven't run.",
    ),
    _NotificationPreferenceRowData(
      icon: Icons.update_outlined,
      title: 'Plan updates',
      subtitle: 'Know when your coach adjusts an upcoming plan.',
    ),
  ];

  static const _notificationRows = [..._beforeRunRows, ..._afterRunRows];

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  bool _notificationsEnabled = true;
  late final List<bool> _notificationRowEnabled = List<bool>.filled(
    NotificationCenterScreen._notificationRows.length,
    true,
  );
  @override
  Widget build(BuildContext context) {
    final enabledCount = _notificationRowEnabled
        .where((enabled) => enabled)
        .length;
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Notification Center',
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
                    children: [
                      _MasterNotificationsCard(
                        enabled: _notificationsEnabled,
                        enabledCount: enabledCount,
                        totalCount: _notificationRowEnabled.length,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      if (!_notificationsEnabled) ...[
                        const SizedBox(height: 10),
                        const _DisabledHelper(),
                      ],
                      const SizedBox(height: 20),
                      _NotificationGroup(
                        label: 'BEFORE YOUR RUN',
                        rows: NotificationCenterScreen._beforeRunRows,
                        rowOffset: 0,
                        notificationsEnabled: _notificationsEnabled,
                        rowEnabled: _notificationRowEnabled,
                        onRowChanged: (index, value) {
                          setState(() {
                            _notificationRowEnabled[index] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _NotificationGroup(
                        label: 'AFTER YOUR RUN',
                        rows: NotificationCenterScreen._afterRunRows,
                        rowOffset: NotificationCenterScreen._beforeRunRows.length,
                        notificationsEnabled: _notificationsEnabled,
                        rowEnabled: _notificationRowEnabled,
                        onRowChanged: (index, value) {
                          setState(() {
                            _notificationRowEnabled[index] = value;
                          });
                        },
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

class _MasterNotificationsCard extends StatelessWidget {
  const _MasterNotificationsCard({
    required this.enabled,
    required this.enabledCount,
    required this.totalCount,
    required this.onChanged,
  });

  final bool enabled;
  final int enabledCount;
  final int totalCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final subtitle = enabled
        ? '$enabledCount of $totalCount reminders on'
        : 'All reminders paused';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _IconTile(icon: Icons.notifications_outlined, enabled: enabled),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeThumbColor: RuniacColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledHelper extends StatelessWidget {
  const _DisabledHelper();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.sectionSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.cardBorder),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          'Turn Notifications on to edit reminder controls.',
          style: TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.label,
    required this.rows,
    required this.rowOffset,
    required this.notificationsEnabled,
    required this.rowEnabled,
    required this.onRowChanged,
  });

  final String label;
  final List<_NotificationPreferenceRowData> rows;
  final int rowOffset;
  final bool notificationsEnabled;
  final List<bool> rowEnabled;
  final void Function(int index, bool value) onRowChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 8),
        _NotificationPreferenceSection(
          notificationsEnabled: notificationsEnabled,
          rows: rows,
          rowEnabled: rowEnabled,
          rowOffset: rowOffset,
          onRowChanged: onRowChanged,
        ),
      ],
    );
  }
}

class _NotificationPreferenceSection extends StatelessWidget {
  const _NotificationPreferenceSection({
    required this.notificationsEnabled,
    required this.rows,
    required this.rowEnabled,
    required this.rowOffset,
    required this.onRowChanged,
  });

  final bool notificationsEnabled;
  final List<_NotificationPreferenceRowData> rows;
  final List<bool> rowEnabled;
  final int rowOffset;
  final void Function(int index, bool value) onRowChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _NotificationPreferenceRow(
              row: rows[index],
              notificationsEnabled: notificationsEnabled,
              rowEnabled: rowEnabled[rowOffset + index],
              onChanged: (value) => onRowChanged(rowOffset + index, value),
            ),
            if (index != rows.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: RuniacColors.border,
                indent: 58,
              ),
          ],
        ],
      ),
    );
  }
}

class _NotificationPreferenceRow extends StatelessWidget {
  const _NotificationPreferenceRow({
    required this.row,
    required this.notificationsEnabled,
    required this.rowEnabled,
    required this.onChanged,
  });

  final _NotificationPreferenceRowData row;
  final bool notificationsEnabled;
  final bool rowEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final controlsEnabled = notificationsEnabled && rowEnabled;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconTile(icon: row.icon, enabled: controlsEnabled),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: controlsEnabled
                        ? RuniacColors.textPrimary
                        : RuniacColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  row.subtitle,
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
          Switch(
            value: controlsEnabled,
            onChanged: notificationsEnabled ? onChanged : null,
            activeThumbColor: RuniacColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.enabled});

  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled
            ? RuniacColors.sectionSurfaceStrong
            : RuniacColors.innerTileSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: enabled ? RuniacColors.primaryBlue : RuniacColors.textSecondary,
        size: 18,
      ),
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

class _NotificationPreferenceRowData {
  const _NotificationPreferenceRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
