import 'package:flutter/material.dart';

import '../../domain/models/user_profile_read_model.dart';

// Production account/profile/region values must come from approved
// backend/Auth/location read paths later, not this static snapshot.
const accountProfileDemoSnapshot = AccountProfileDemoSnapshot(
  displayName: 'Runiac Runner',
  avatarInitials: 'RR',
  regionLabel: 'Jurong East, Singapore',
  // Fallback display only. Real streak/distance totals come from the
  // backend-owned user progress read path.
  maxStreakLabel: '12 days',
  totalDistanceLabel: '148.6 km',
  divisionKey: '',
  divisionLabel: 'Unranked',
  // Fallback display only. Real level/progression values come from the
  // backend-owned user progress read path.
  previewLevelBadge: 'Lv.0',
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
      icon: Icons.edit_outlined,
      title: 'Edit profile',
      subtitle: 'Email, personal details, and onboarding',
      snackBarMessage: '',
      action: UserProfileManageAction.editProfile,
    ),
    AccountProfileManageRow(
      icon: Icons.settings_outlined,
      title: 'Settings',
      subtitle: 'Units, reminders, and app comfort',
      snackBarMessage: 'Settings preview is coming soon.',
    ),
    AccountProfileManageRow(
      icon: Icons.shield_outlined,
      title: 'Privacy & Safety',
      subtitle: 'Personalized guide data use and sharing controls',
      snackBarMessage: '',
      action: UserProfileManageAction.privacySafety,
    ),
    AccountProfileManageRow(
      icon: Icons.notifications_none,
      title: 'Notifications',
      subtitle: 'Gentle running nudges and reminders',
      snackBarMessage: 'Notification preferences preview is coming soon.',
      action: UserProfileManageAction.notifications,
    ),
    AccountProfileManageRow(
      icon: Icons.watch_outlined,
      title: 'Watch & Health Apps',
      subtitle: 'Connect watch runs and health apps',
      snackBarMessage: 'Adding watch runs comes next.',
      action: UserProfileManageAction.watchHealthApps,
    ),
    AccountProfileManageRow(
      icon: Icons.info_outline,
      title: 'About Runiac',
      subtitle: 'App version and project information',
      snackBarMessage: 'About Runiac preview is coming soon.',
    ),
    AccountProfileManageRow(
      icon: Icons.feedback_outlined,
      title: 'Feedback',
      subtitle: 'Report a bug or share a suggestion',
      snackBarMessage: '',
      action: UserProfileManageAction.feedback,
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
    this.regionalRankLabel = '',
    this.maxStreakLabel = '',
    this.totalDistanceLabel = '',
    this.divisionKey = '',
    this.divisionLabel = 'Unranked',
    this.levelProgressFraction = 0,
    this.nextLevelBadge = '',
    this.levelUpCaption = '',
    this.levelXpSummary = '',
  });

  final String displayName;
  final String avatarInitials;
  final String regionLabel;

  /// Backend-provided regional rank label for the current runner (e.g. '#1');
  /// empty when the backend has not published a home-region rank yet.
  final String regionalRankLabel;

  /// Backend-provided longest (max) streak label for the current runner
  /// (e.g. '14 days'); empty when the backend has not published it yet.
  final String maxStreakLabel;

  /// Backend-provided lifetime total distance label for the current runner
  /// (e.g. '148.6 km'); empty when the backend has not published it yet.
  final String totalDistanceLabel;
  final String divisionKey;
  final String divisionLabel;
  final String previewLevelBadge;
  final double levelProgressFraction;

  /// Backend-provided next level badge (e.g. 'Lv.4'); empty when unknown or
  /// at max level.
  final String nextLevelBadge;

  /// Backend-provided XP-to-level-up caption (e.g. '320 XP to level up');
  /// empty when the backend has not published progression data yet.
  final String levelUpCaption;

  /// Backend-provided current/target XP summary (e.g. '520 / 600 XP');
  /// empty when the backend has not published both values yet.
  final String levelXpSummary;
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
    this.action = UserProfileManageAction.snackBar,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String snackBarMessage;
  final UserProfileManageAction action;
}
