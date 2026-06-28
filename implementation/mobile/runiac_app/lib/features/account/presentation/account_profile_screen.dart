import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../auth/domain/runiac_auth_service.dart';
import '../domain/models/user_profile_read_model.dart';
import '../domain/repositories/user_profile_persistence_repository.dart';
import '../domain/repositories/user_profile_repository.dart';
import 'account_edit_profile_screen.dart';
import 'data/account_profile_demo_snapshots.dart';
import 'widgets/account_profile_identity.dart';
import 'widgets/account_profile_sections.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({
    required this.authRepository,
    required this.profileRepository,
    required this.profilePersistenceRepository,
    required this.onBack,
    this.snapshot = accountProfileDemoSnapshot,
    super.key,
  });

  final RuniacAuthRepository authRepository;
  final UserProfileRepository profileRepository;
  final UserProfilePersistenceRepository profilePersistenceRepository;
  final VoidCallback onBack;
  final AccountProfileDemoSnapshot snapshot;

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  late Future<UserProfileReadModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.profileRepository.loadUserProfile();
  }

  @override
  void didUpdateWidget(covariant AccountProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileRepository != widget.profileRepository) {
      _profileFuture = widget.profileRepository.loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Account',
              tooltip: 'Back to Home',
              onBack: widget.onBack,
            ),
            Expanded(
              child: FutureBuilder<UserProfileReadModel>(
                future: _profileFuture,
                builder: (context, asyncProfile) {
                  final snapshot = _snapshotFromProfile(
                    asyncProfile.data,
                    widget.snapshot,
                  );
                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AccountIdentityCard(snapshot: snapshot),
                          const SizedBox(height: 14),
                          AccountPreviewNote(message: snapshot.previewNote),
                          const SizedBox(height: 22),
                          AccountSectionLabel(snapshot.setupSectionLabel),
                          const SizedBox(height: 8),
                          AccountSetupSection(items: snapshot.setupItems),
                          const SizedBox(height: 22),
                          AccountSectionLabel(snapshot.manageSectionLabel),
                          const SizedBox(height: 8),
                          AccountManageSection(
                            rows: snapshot.manageRows,
                            authRepository: widget.authRepository,
                            onEditProfile: asyncProfile.data == null
                                ? null
                                : () => _openEditProfile(asyncProfile.data!),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            snapshot.footerCaption,
                            textAlign: TextAlign.center,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AccountProfileDemoSnapshot _snapshotFromProfile(
    UserProfileReadModel? profile,
    AccountProfileDemoSnapshot fallback,
  ) {
    if (profile == null) {
      return fallback;
    }
    return AccountProfileDemoSnapshot(
      displayName: profile.nickname.isEmpty
          ? profile.displayName
          : profile.nickname,
      avatarInitials: profile.avatarInitials,
      regionLabel: profile.locationLabel,
      previewLevelBadge: profile.previewLevelBadge,
      previewNote: profile.previewNote.isEmpty
          ? fallback.previewNote
          : profile.previewNote,
      setupSectionLabel: profile.setupSectionLabel.isEmpty
          ? fallback.setupSectionLabel
          : profile.setupSectionLabel,
      manageSectionLabel: profile.manageSectionLabel.isEmpty
          ? fallback.manageSectionLabel
          : profile.manageSectionLabel,
      footerCaption: profile.footerCaption.isEmpty
          ? fallback.footerCaption
          : profile.footerCaption,
      setupItems: profile.setupItems.isEmpty
          ? fallback.setupItems
          : profile.setupItems
                .map((item) => _setupItemFromProfileItem(item, fallback))
                .toList(growable: false),
      manageRows: profile.manageRows.isEmpty
          ? fallback.manageRows
          : profile.manageRows
                .map((row) => _manageRowFromProfileRow(row, fallback))
                .toList(growable: false),
    );
  }

  AccountProfileInfoItem _setupItemFromProfileItem(
    UserProfileInfoItemReadModel item,
    AccountProfileDemoSnapshot fallback,
  ) {
    return AccountProfileInfoItem(
      icon: _matchingSetupIcon(item.title, fallback),
      title: item.title,
      value: item.value,
    );
  }

  AccountProfileManageRow _manageRowFromProfileRow(
    UserProfileManageRowReadModel row,
    AccountProfileDemoSnapshot fallback,
  ) {
    final matchingFallbackRow = _matchingManageRow(row.title, fallback);
    return AccountProfileManageRow(
      icon: matchingFallbackRow?.icon ?? Icons.settings_outlined,
      title: row.title,
      subtitle: row.subtitle,
      snackBarMessage: row.snackBarMessage,
      action: row.action == UserProfileManageAction.snackBar
          ? matchingFallbackRow?.action ?? UserProfileManageAction.snackBar
          : row.action,
    );
  }

  Future<void> _openEditProfile(UserProfileReadModel profile) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => AccountEditProfileScreen(
          authRepository: widget.authRepository,
          persistenceRepository: widget.profilePersistenceRepository,
          profile: profile,
          onBack: () => Navigator.of(context).pop(false),
        ),
      ),
    );
    if (!mounted || updated != true) {
      return;
    }
    setState(() {
      _profileFuture = widget.profileRepository.loadUserProfile();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile updated.')));
  }

  IconData _matchingSetupIcon(
    String title,
    AccountProfileDemoSnapshot fallback,
  ) {
    for (final item in fallback.setupItems) {
      if (item.title == title) {
        return item.icon;
      }
    }
    return Icons.info_outline;
  }

  AccountProfileManageRow? _matchingManageRow(
    String title,
    AccountProfileDemoSnapshot fallback,
  ) {
    for (final row in fallback.manageRows) {
      if (row.title == title) {
        return row;
      }
    }
    return null;
  }
}
