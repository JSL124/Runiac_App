import '../../../onboarding/domain/models/local_onboarding_draft.dart';

/// Backend-produced account profile display contract.
///
/// Identity, account, region, and progression labels are read-only outputs for
/// Flutter. Future persistence must come from approved backend/Auth read paths.
class UserProfileReadModel {
  UserProfileReadModel({
    required this.userId,
    required this.displayName,
    this.fullName = '',
    this.nickname = '',
    this.dateOfBirthIso = '',
    required this.avatarInitials,
    this.ageYears,
    this.weightKg,
    required this.locationLabel,
    this.previewLevelBadge = '',
    this.previewNote = '',
    this.setupSectionLabel = '',
    this.manageSectionLabel = '',
    this.footerCaption = '',
    this.onboardingDraft,
    List<UserProfileInfoItemReadModel> setupItems =
        const <UserProfileInfoItemReadModel>[],
    List<UserProfileManageRowReadModel> manageRows =
        const <UserProfileManageRowReadModel>[],
  }) : setupItems = List.unmodifiable(setupItems),
       manageRows = List.unmodifiable(manageRows);

  final String userId;
  final String displayName;
  final String fullName;
  final String nickname;
  final String dateOfBirthIso;
  final String avatarInitials;
  final int? ageYears;
  final num? weightKg;
  final String locationLabel;
  final String previewLevelBadge;
  final String previewNote;
  final String setupSectionLabel;
  final String manageSectionLabel;
  final String footerCaption;
  final LocalOnboardingDraft? onboardingDraft;
  final List<UserProfileInfoItemReadModel> setupItems;
  final List<UserProfileManageRowReadModel> manageRows;
}

class UserProfileInfoItemReadModel {
  const UserProfileInfoItemReadModel({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;
}

class UserProfileManageRowReadModel {
  const UserProfileManageRowReadModel({
    required this.title,
    required this.subtitle,
    required this.snackBarMessage,
    this.action = UserProfileManageAction.snackBar,
  });

  final String title;
  final String subtitle;
  final String snackBarMessage;
  final UserProfileManageAction action;
}

enum UserProfileManageAction { snackBar, editProfile, watchHealthApps }
