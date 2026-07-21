import '../domain/models/leaderboard_read_model.dart';
import 'league_asset_path.dart';
import 'models/leaderboard_display_models.dart';
import 'widgets/leaderboard_refresh_countdown.dart';

LeaderboardDetailDisplaySnapshot leaderboardDisplaySnapshotFromReadModel(
  LeaderboardReadModel model,
  DateTime now,
) {
  final topRows = [
    for (final (index, entry) in model.entries.indexed)
      leaderboardRankRowDisplaySnapshotFromReadModel(
        entry,
        regionLabel: model.regionLabel,
        ordinal: index,
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

  final serverRefreshLabel = model.refreshLabel?.trim();
  final hasServerRefreshLabel =
      serverRefreshLabel != null && serverRefreshLabel.isNotEmpty;

  return LeaderboardDetailDisplaySnapshot(
    regionId: model.regionId,
    regionName: model.regionLabel.isEmpty ? 'Leaderboard' : model.regionLabel,
    // Home-region treatment is independent of whether the runner already has
    // a rank: an unranked runner still sees their own board with
    // encouragement instead of the visitor layout.
    isUserRegion: model.isHomeRegion,
    periodLabel: model.periodLabel ?? '',
    fallbackPeriodLabel: 'Monthly leaderboard',
    refreshLabel: hasServerRefreshLabel
        ? serverRefreshLabel
        : formatLeaderboardRefreshLabel(model.periodEndsAt, now),
    refreshLabelIsLive: !hasServerRefreshLabel && model.periodEndsAt != null,
    periodEndsAt: model.periodEndsAt,
    fallbackRefreshLabel: 'Updating',
    monthlyResetLabel:
        'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
    divisionLabel: model.divisionLabel,
    divisionAssetPath: leagueAssetPathForTierKey(model.divisionKey),
    topRanksTitle: 'Regional ranking',
    nearbyRanksTitle: 'Ranks near you',
    currentUser: CurrentUserRankSummaryDisplaySnapshot(
      rankLabel: hasCurrentRank ? model.currentRunnerRankLabel : 'Unranked',
      title: 'My monthly rank',
      xpLabel: currentUser?.xpLabel ?? '',
    ),
    topRanks: topRows,
    nearbyRanks: nearbyRows,
    status: model.status,
    hasCurrentUserRank: hasCurrentRank,
  );
}

LeaderboardRankRowDisplaySnapshot
leaderboardRankRowDisplaySnapshotFromReadModel(
  LeaderboardRowReadModel entry, {
  required String regionLabel,
  int? ordinal,
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
    trophy: ordinal == 0,
    medalTone: _medalToneForOrdinal(ordinal),
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
      uid: entry.userId,
    ),
  );
}

// Medal tone follows the ordinal position within the backend-provided top
// entries list, not the rank label string. Index 0/1/2 map to gold/silver/
// bronze; a null ordinal (nearby rows) gets no medal tone.
RegionPreviewMedalTone? _medalToneForOrdinal(int? ordinal) {
  return switch (ordinal) {
    0 => RegionPreviewMedalTone.gold,
    1 => RegionPreviewMedalTone.silver,
    2 => RegionPreviewMedalTone.bronze,
    _ => null,
  };
}

String _regionRankLabel(String regionLabel, String rankLabel) {
  final region = regionLabel.trim();
  final rank = rankLabel.trim();
  if (region.isEmpty) {
    return rank;
  }
  if (rank.isEmpty || rank == '#--') {
    return '$region, Singapore';
  }
  return '$rank $region, Singapore';
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
