import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/runiac_auth_service.dart';
import '../domain/models/user_profile_read_model.dart';
import '../domain/repositories/user_profile_repository.dart';
import 'static_user_profile_repository.dart';

abstract interface class UserProfileDocumentReader {
  Future<UserProfileDocumentReadResult> readUserProfile({required String uid});
}

class UserProfileDocumentReadResult {
  const UserProfileDocumentReadResult.exists(this.data) : exists = true;

  const UserProfileDocumentReadResult.missing()
    : exists = false,
      data = const <String, Object?>{};

  final bool exists;
  final Map<String, Object?> data;
}

enum CurrentUserProfileFailureReason { missing, invalid }

class CurrentUserProfileException implements Exception {
  const CurrentUserProfileException({required this.uid, required this.reason});

  final String uid;
  final CurrentUserProfileFailureReason reason;

  @override
  String toString() {
    return 'CurrentUserProfileException(uid: $uid, reason: $reason)';
  }
}

class FirestoreUserProfileDocumentReader implements UserProfileDocumentReader {
  FirestoreUserProfileDocumentReader({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<UserProfileDocumentReadResult> readUserProfile({
    required String uid,
  }) async {
    final snapshot = await _firestore.collection('userProfiles').doc(uid).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return const UserProfileDocumentReadResult.missing();
    }
    return UserProfileDocumentReadResult.exists(
      Map<String, Object?>.from(data),
    );
  }
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({
    required this.authRepository,
    UserProfileDocumentReader? reader,
    this.fallbackRepository = const StaticUserProfileRepository(),
  }) : documentReader = reader ?? FirestoreUserProfileDocumentReader();

  final RuniacAuthRepository authRepository;
  final UserProfileDocumentReader documentReader;
  final UserProfileRepository fallbackRepository;

  @override
  Future<UserProfileReadModel> loadUserProfile() async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) {
      return fallbackRepository.loadUserProfile();
    }

    final result = await documentReader.readUserProfile(uid: currentUser.uid);
    if (!result.exists) {
      throw CurrentUserProfileException(
        uid: currentUser.uid,
        reason: CurrentUserProfileFailureReason.missing,
      );
    }

    final profile = _mapDocument(currentUser.uid, result.data);
    if (profile == null) {
      throw CurrentUserProfileException(
        uid: currentUser.uid,
        reason: CurrentUserProfileFailureReason.invalid,
      );
    }
    return profile;
  }

  UserProfileReadModel? _mapDocument(
    String uid,
    Map<String, Object?> document,
  ) {
    final displayName = _requiredTrimmedString(document['displayName']);
    final fullName = _optionalTrimmedString(document['fullName']);
    final nickname = _optionalTrimmedString(document['nickname']);
    final dateOfBirthIso = _optionalTrimmedString(document['dateOfBirth']);
    final avatarInitials = _requiredTrimmedString(document['avatarInitials']);
    final ageYears = _intValue(document['ageYears']);
    final weightKg = _numValue(document['weightKg']);
    final locationLabel = _requiredTrimmedString(document['locationLabel']);
    if (displayName == null ||
        avatarInitials == null ||
        locationLabel == null) {
      return null;
    }

    return UserProfileReadModel(
      userId: uid,
      displayName: displayName,
      fullName: fullName,
      nickname: nickname,
      dateOfBirthIso: dateOfBirthIso,
      avatarInitials: avatarInitials,
      ageYears: ageYears,
      weightKg: weightKg,
      locationLabel: locationLabel,
      previewLevelBadge: '',
      previewNote: 'Loaded from your saved profile.',
      setupSectionLabel: 'RUNNING SETUP',
      manageSectionLabel: 'MANAGE',
      footerCaption: 'Runiac · Preview build · Built for new runners',
      setupItems: _setupItemsFromDocument(document),
      manageRows: const <UserProfileManageRowReadModel>[
        UserProfileManageRowReadModel(
          title: 'Edit profile',
          subtitle: 'Email, personal details, and onboarding',
          snackBarMessage: '',
          action: UserProfileManageAction.editProfile,
        ),
        UserProfileManageRowReadModel(
          title: 'Settings',
          subtitle: 'Units, reminders, and app comfort',
          snackBarMessage: 'Settings preview is coming soon.',
        ),
        UserProfileManageRowReadModel(
          title: 'Privacy & Safety',
          subtitle: 'Routes, activity, and sharing controls',
          snackBarMessage: 'Privacy & Safety preview is coming soon.',
        ),
        UserProfileManageRowReadModel(
          title: 'Notifications',
          subtitle: 'Gentle running nudges and reminders',
          snackBarMessage: 'Notification preferences preview is coming soon.',
        ),
        UserProfileManageRowReadModel(
          title: 'Watch & Health Apps',
          subtitle: 'Connect watch runs and health apps',
          snackBarMessage: 'Adding watch runs comes next.',
          action: UserProfileManageAction.watchHealthApps,
        ),
        UserProfileManageRowReadModel(
          title: 'About Runiac',
          subtitle: 'App version and project information',
          snackBarMessage: 'About Runiac preview is coming soon.',
        ),
      ],
    );
  }

  List<UserProfileInfoItemReadModel> _setupItemsFromDocument(
    Map<String, Object?> document,
  ) {
    final items = <UserProfileInfoItemReadModel>[];
    final goals = _stringList(document['goals']);
    if (goals.isNotEmpty) {
      items.add(
        UserProfileInfoItemReadModel(
          title: 'Current goal',
          value: goals.join(', '),
        ),
      );
    }

    final weeklySessions = _weeklySessionsLabel(document['availability']);
    if (weeklySessions != null) {
      items.add(
        UserProfileInfoItemReadModel(
          title: 'Weekly rhythm',
          value: weeklySessions,
        ),
      );
    }

    final fitnessLevel = _requiredTrimmedString(document['fitnessLevel']);
    if (fitnessLevel != null) {
      items.add(
        UserProfileInfoItemReadModel(title: 'Experience', value: fitnessLevel),
      );
    }
    return items;
  }

  String? _weeklySessionsLabel(Object? availability) {
    if (availability is! Map) {
      return null;
    }
    final sessions = _requiredTrimmedString(availability['weeklySessions']);
    if (sessions == null) {
      return null;
    }
    return '$sessions sessions / week';
  }

  List<String> _stringList(Object? value) {
    if (value is! Iterable) {
      return const <String>[];
    }
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? _requiredTrimmedString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _optionalTrimmedString(Object? value) {
    if (value is! String) {
      return '';
    }
    return value.trim();
  }

  int? _intValue(Object? value) {
    return value is int ? value : null;
  }

  num? _numValue(Object? value) {
    return value is num ? value : null;
  }
}
