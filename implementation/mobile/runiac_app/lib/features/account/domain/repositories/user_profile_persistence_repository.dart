abstract interface class UserProfilePersistenceRepository {
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  });

  Future<void> savePersonalProfile({
    required String uid,
    required UserProfilePersonalSnapshot profile,
  });
}

class PersonalProfileDraft {
  PersonalProfileDraft({
    required String fullName,
    required String nickname,
    required this.ageYears,
    required this.weightKg,
    required String locationLabel,
  }) : fullName = fullName.trim(),
       nickname = nickname.trim(),
       locationLabel = locationLabel.trim();

  final String fullName;
  final String nickname;
  final int ageYears;
  final num weightKg;
  final String locationLabel;

  String get displayName => nickname;

  String get avatarInitials => _avatarInitials(nickname, fullName);

  UserProfilePersonalSnapshot toPersonalSnapshot() {
    return UserProfilePersonalSnapshot(
      fullName: fullName,
      nickname: nickname,
      ageYears: ageYears,
      weightKg: weightKg,
      locationLabel: locationLabel,
    );
  }

  static String? validateFullName(String value) {
    return _validateText(value, 'Name', 80);
  }

  static String? validateNickname(String value) {
    return _validateText(value, 'Nickname', 30);
  }

  static String? validateLocationLabel(String value) {
    return _validateText(value, 'Region', 80);
  }

  static String? validateAge(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 13 || parsed > 100) {
      return 'Enter an age from 13 to 100.';
    }
    return null;
  }

  static String? validateWeight(String value) {
    final trimmed = value.trim();
    final parsed = num.tryParse(trimmed);
    final oneDecimal = RegExp(r'^\d+(\.\d)?$').hasMatch(trimmed);
    if (parsed == null || !oneDecimal || parsed < 30 || parsed > 250) {
      return 'Enter a weight from 30 to 250 kg.';
    }
    return null;
  }

  static PersonalProfileDraft? tryCreate({
    required String fullName,
    required String nickname,
    required String age,
    required String weightKg,
    required String locationLabel,
  }) {
    if (validateFullName(fullName) != null ||
        validateNickname(nickname) != null ||
        validateAge(age) != null ||
        validateWeight(weightKg) != null ||
        validateLocationLabel(locationLabel) != null) {
      return null;
    }
    return PersonalProfileDraft(
      fullName: fullName,
      nickname: nickname,
      ageYears: int.parse(age.trim()),
      weightKg: num.parse(weightKg.trim()),
      locationLabel: locationLabel,
    );
  }

  static String? _validateText(String value, String label, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      return '$label must be 1-$maxLength characters.';
    }
    if (RegExp(r'[\x00-\x1F]').hasMatch(trimmed)) {
      return '$label cannot include line breaks.';
    }
    return null;
  }
}

class UserProfilePersonalSnapshot {
  UserProfilePersonalSnapshot({
    required this.fullName,
    required this.nickname,
    required this.ageYears,
    required this.weightKg,
    required this.locationLabel,
  });

  final String fullName;
  final String nickname;
  final int ageYears;
  final num weightKg;
  final String locationLabel;

  String get displayName => nickname;

  String get avatarInitials => _avatarInitials(nickname, fullName);

  Map<String, Object> toFirestoreDocument({required Object updatedAt}) {
    return <String, Object>{
      'displayName': displayName,
      'fullName': fullName,
      'nickname': nickname,
      'avatarInitials': avatarInitials,
      'ageYears': ageYears,
      'weightKg': weightKg,
      'locationLabel': locationLabel,
      'updatedAt': updatedAt,
    };
  }
}

class UserProfileOnboardingSnapshot {
  UserProfileOnboardingSnapshot({
    required this.displayName,
    required this.fullName,
    required this.nickname,
    required this.avatarInitials,
    required this.ageYears,
    required this.weightKg,
    required this.locationLabel,
    required this.fitnessLevel,
    required List<String> goals,
    required Map<String, Object> availability,
    required this.planCautiousness,
    required Map<String, Object> healthSafetyReadiness,
  }) : goals = List.unmodifiable(goals),
       availability = Map.unmodifiable(availability),
       healthSafetyReadiness = Map.unmodifiable(healthSafetyReadiness);

  final String displayName;
  final String fullName;
  final String nickname;
  final String avatarInitials;
  final int ageYears;
  final num weightKg;
  final String locationLabel;
  final String fitnessLevel;
  final List<String> goals;
  final Map<String, Object> availability;
  final String planCautiousness;
  final Map<String, Object> healthSafetyReadiness;

  Map<String, Object> toFirestoreDocument({required Object updatedAt}) {
    return <String, Object>{
      'displayName': displayName,
      'fullName': fullName,
      'nickname': nickname,
      'avatarInitials': avatarInitials,
      'ageYears': ageYears,
      'weightKg': weightKg,
      'locationLabel': locationLabel,
      'fitnessLevel': fitnessLevel,
      'goals': goals,
      'availability': availability,
      'planCautiousness': planCautiousness,
      'healthSafetyReadiness': healthSafetyReadiness,
      'updatedAt': updatedAt,
    };
  }
}

class NoopUserProfilePersistenceRepository
    implements UserProfilePersistenceRepository {
  const NoopUserProfilePersistenceRepository();

  @override
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  }) async {}

  @override
  Future<void> savePersonalProfile({
    required String uid,
    required UserProfilePersonalSnapshot profile,
  }) async {}
}

String _avatarInitials(String nickname, String fullName) {
  final source = nickname.trim().isNotEmpty ? nickname.trim() : fullName.trim();
  final words = source
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .toList(growable: false);
  final initials = words.isNotEmpty
      ? words.map(_firstCharacter).take(3).join()
      : _firstCharacter(source);
  return initials.toUpperCase();
}

String _firstCharacter(String value) {
  return value.substring(0, 1);
}
