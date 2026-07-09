import '../domain/models/leaderboard_read_model.dart';
import 'models/leaderboard_display_models.dart';

LeaderboardDetailDisplaySnapshot leaderboardDisplaySnapshotFromReadModel(
  LeaderboardReadModel model,
  DateTime now,
) {
  final topRows = [
    for (final entry in model.entries)
      leaderboardRankRowDisplaySnapshotFromReadModel(
        entry,
        regionLabel: model.regionLabel,
      ),
  ];
  final nearbyRows = [
    for (final entry in model.nearbyEntries)
      leaderboardRankRowDisplaySnapshotFromReadModel(
        entry,
        regionLabel: model.regionLabel,
      ),
  ];
  final currentUser = nearbyRows.where((row) => row.isCurrentUser).firstOrNull;
  final hasCurrentRank =
      model.currentRunnerRankLabel.isNotEmpty && currentUser != null;

  return LeaderboardDetailDisplaySnapshot(
    regionId: model.regionId,
    regionName: model.regionLabel.isEmpty ? 'Leaderboard' : model.regionLabel,
    isUserRegion: model.isHomeRegion && hasCurrentRank,
    periodLabel: model.periodLabel ?? '',
    fallbackPeriodLabel: 'Monthly leaderboard',
    refreshLabel: model.refreshLabel?.trim().isNotEmpty == true
        ? model.refreshLabel!.trim()
        : _refreshLabel(model.periodEndsAt, now),
    fallbackRefreshLabel: 'Updating',
    monthlyResetLabel:
        'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
    divisionLabel: model.divisionLabel,
    topRanksTitle: 'Regional ranking',
    nearbyRanksTitle: 'NEARBY YOUR RANK',
    currentUser: CurrentUserRankSummaryDisplaySnapshot(
      rankLabel: hasCurrentRank ? model.currentRunnerRankLabel : 'Unranked',
      title: 'My monthly rank',
      xpLabel: currentUser?.xpLabel ?? '',
    ),
    topRanks: topRows,
    nearbyRanks: nearbyRows,
  );
}

String _refreshLabel(DateTime? periodEndsAt, DateTime now) {
  if (periodEndsAt == null) {
    return 'Updating';
  }
  final rawRemaining = periodEndsAt.difference(now);
  final remaining = rawRemaining.isNegative ? Duration.zero : rawRemaining;
  final days = remaining.inDays;
  final hours = remaining.inHours.remainder(24);
  final minutes = remaining.inMinutes.remainder(60);
  final seconds = remaining.inSeconds.remainder(60);
  return 'Refreshes in ${_twoDigits(days)}:${_twoDigits(hours)}:'
      '${_twoDigits(minutes)}:${_twoDigits(seconds)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

LeaderboardRankRowDisplaySnapshot
leaderboardRankRowDisplaySnapshotFromReadModel(
  LeaderboardRowReadModel entry, {
  required String regionLabel,
}) {
  final displayName = entry.displayName.trim().isEmpty
      ? 'Runiac Runner'
      : entry.displayName.trim();
  final levelLabel = entry.levelLabel.trim();
  final rankLabel = entry.rankLabel.trim();
  final divisionLabel = entry.divisionLabel.trim();
  return LeaderboardRankRowDisplaySnapshot(
    rankLabel: rankLabel,
    name: displayName,
    levelLabel: levelLabel,
    levelBadgeLabel: _levelBadgeLabel(levelLabel),
    xpLabel: entry.scoreLabel.trim(),
    trophy: rankLabel == '#1',
    medalTone: _medalTone(rankLabel),
    isCurrentUser: entry.isCurrentUser,
    profile: RunnerAchievementProfileSnapshot(
      name: displayName,
      initial: _initialFor(displayName),
      regionRankLabel: _regionRankLabel(regionLabel, rankLabel),
      levelBadgeLabel: _levelBadgeLabel(levelLabel),
      divisionLevelLabel: divisionLabel.isEmpty
          ? levelLabel
          : '$divisionLabel · $levelLabel',
      totalDistanceLabel: 'Not shared',
      bestStreakLabel: 'Not shared',
      badges: const <RunnerAchievementBadgeSnapshot>[],
      privacyNote: 'Only monthly ranking details are shown.',
      isCurrentUser: entry.isCurrentUser,
    ),
  );
}

RegionPreviewMedalTone? _medalTone(String rankLabel) {
  return switch (rankLabel) {
    '#1' => RegionPreviewMedalTone.gold,
    '#2' => RegionPreviewMedalTone.silver,
    '#3' => RegionPreviewMedalTone.bronze,
    _ => null,
  };
}

String _regionRankLabel(String regionLabel, String rankLabel) {
  final region = regionLabel.trim();
  final rank = rankLabel.trim();
  if (region.isEmpty) {
    return rank;
  }
  if (rank.isEmpty) {
    return region;
  }
  return '$region · Rank $rank';
}

String _initialFor(String displayName) {
  final trimmedName = displayName.trim();
  return trimmedName.isEmpty
      ? 'R'
      : String.fromCharCode(trimmedName.runes.first).toUpperCase();
}

String _levelBadgeLabel(String levelLabel) {
  final trimmedLabel = levelLabel.trim();
  return trimmedLabel.startsWith('Level ')
      ? 'Lv.${trimmedLabel.substring('Level '.length)}'
      : trimmedLabel;
}
