import '../models/user_progress_read_model.dart';

abstract interface class UserProgressRepository {
  Future<UserProgressReadModel> loadUserProgress();

  Future<UserProgressReadModel> refreshUserProgress();
}

class StaticUserProgressRepository implements UserProgressRepository {
  const StaticUserProgressRepository();

  @override
  Future<UserProgressReadModel> loadUserProgress() async {
    return const UserProgressReadModel(
      userId: 'static_you_progress',
      officialStreakLabel: '',
      levelLabel: 'Level 12',
      totalXpLabel: '2,520 XP',
      weeklyXpLabel: '520 XP',
      monthlyXpLabel: '1,240 XP',
      weeklyDistanceLabel: '12.4 km',
      goalProgressLabel: '43%',
    );
  }

  @override
  Future<UserProgressReadModel> refreshUserProgress() {
    return loadUserProgress();
  }
}
