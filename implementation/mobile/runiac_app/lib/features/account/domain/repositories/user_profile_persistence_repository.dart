abstract interface class UserProfilePersistenceRepository {
  Future<void> saveOnboardingProfile({
    required String uid,
    required UserProfileOnboardingSnapshot profile,
  });
}

class UserProfileOnboardingSnapshot {
  UserProfileOnboardingSnapshot({
    required this.fitnessLevel,
    required List<String> goals,
    required Map<String, Object> availability,
    required this.planCautiousness,
    required Map<String, Object> healthSafetyReadiness,
  }) : goals = List.unmodifiable(goals),
       availability = Map.unmodifiable(availability),
       healthSafetyReadiness = Map.unmodifiable(healthSafetyReadiness);

  final String fitnessLevel;
  final List<String> goals;
  final Map<String, Object> availability;
  final String planCautiousness;
  final Map<String, Object> healthSafetyReadiness;

  Map<String, Object> toFirestoreDocument({required Object updatedAt}) {
    return <String, Object>{
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
}
