import 'package:flutter/material.dart';

// Production account/profile/region values must come from approved
// backend/Auth/location read paths later, not this static snapshot.
const accountProfileDemoSnapshot = AccountProfileDemoSnapshot(
  displayName: 'Runiac Runner',
  avatarInitials: 'RR',
  regionLabel: 'Jurong East, Singapore',
  // Static decorative preview only. Real level/progression display is
  // backend-owned and must come from approved read paths later.
  previewLevelBadge: 'Lv. 12',
  previewNote: 'Account changes are not saved in this prototype.',
  setupSectionLabel: 'RUNNING SETUP',
  manageSectionLabel: 'MANAGE',
  footerCaption: 'Runiac · Preview build · Built for new runners',
  setupItems: [
    AccountProfileInfoItem(
      icon: Icons.flag_outlined,
      title: 'Current goal',
      value: 'Build a consistent 10K habit',
    ),
    AccountProfileInfoItem(
      icon: Icons.straighten,
      title: 'Preferred unit',
      value: 'Kilometers',
    ),
    AccountProfileInfoItem(
      icon: Icons.calendar_today_outlined,
      title: 'Weekly rhythm',
      value: '3 gentle sessions / week',
    ),
    AccountProfileInfoItem(
      icon: Icons.directions_walk,
      title: 'Experience',
      value: 'Beginner runner',
    ),
  ],
  manageRows: [
    AccountProfileManageRow(
      icon: Icons.settings_outlined,
      title: 'Settings',
      subtitle: 'Units, reminders, and app comfort',
      snackBarMessage: 'Settings preview is coming soon.',
    ),
    AccountProfileManageRow(
      icon: Icons.shield_outlined,
      title: 'Privacy & Safety',
      subtitle: 'Routes, activity, and sharing controls',
      snackBarMessage: 'Privacy & Safety preview is coming soon.',
    ),
    AccountProfileManageRow(
      icon: Icons.notifications_none,
      title: 'Notifications',
      subtitle: 'Gentle running nudges and reminders',
      snackBarMessage: 'Notification preferences preview is coming soon.',
    ),
    AccountProfileManageRow(
      icon: Icons.watch_outlined,
      title: 'Watch & Health Apps',
      subtitle: 'Connect watch runs and health apps',
      snackBarMessage: 'Adding watch runs comes next.',
      opensWatchHealthApps: true,
    ),
    AccountProfileManageRow(
      icon: Icons.info_outline,
      title: 'About Runiac',
      subtitle: 'App version and project information',
      snackBarMessage: 'About Runiac preview is coming soon.',
    ),
  ],
);

class AccountProfileDemoSnapshot {
  const AccountProfileDemoSnapshot({
    required this.displayName,
    required this.avatarInitials,
    required this.regionLabel,
    required this.previewLevelBadge,
    required this.previewNote,
    required this.setupSectionLabel,
    required this.manageSectionLabel,
    required this.footerCaption,
    required this.setupItems,
    required this.manageRows,
  });

  final String displayName;
  final String avatarInitials;
  final String regionLabel;
  final String previewLevelBadge;
  final String previewNote;
  final String setupSectionLabel;
  final String manageSectionLabel;
  final String footerCaption;
  final List<AccountProfileInfoItem> setupItems;
  final List<AccountProfileManageRow> manageRows;
}

class AccountProfileInfoItem {
  const AccountProfileInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class AccountProfileManageRow {
  const AccountProfileManageRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.snackBarMessage,
    this.opensWatchHealthApps = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String snackBarMessage;
  final bool opensWatchHealthApps;
}
