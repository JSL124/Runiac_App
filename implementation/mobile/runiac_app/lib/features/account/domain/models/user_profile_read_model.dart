/// Backend-produced account profile display contract.
///
/// Identity, account, region, and progression labels are read-only outputs for
/// Flutter. Future persistence must come from approved backend/Auth read paths.
class UserProfileReadModel {
  UserProfileReadModel({
    required this.userId,
    required this.displayName,
    required this.avatarInitials,
    required this.locationLabel,
    this.previewLevelBadge = '',
    this.previewNote = '',
    this.setupSectionLabel = '',
    this.manageSectionLabel = '',
    this.footerCaption = '',
    List<UserProfileInfoItemReadModel> setupItems =
        const <UserProfileInfoItemReadModel>[],
    List<UserProfileManageRowReadModel> manageRows =
        const <UserProfileManageRowReadModel>[],
  }) : setupItems = List.unmodifiable(setupItems),
       manageRows = List.unmodifiable(manageRows);

  final String userId;
  final String displayName;
  final String avatarInitials;
  final String locationLabel;
  final String previewLevelBadge;
  final String previewNote;
  final String setupSectionLabel;
  final String manageSectionLabel;
  final String footerCaption;
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
  });

  final String title;
  final String subtitle;
  final String snackBarMessage;
}
