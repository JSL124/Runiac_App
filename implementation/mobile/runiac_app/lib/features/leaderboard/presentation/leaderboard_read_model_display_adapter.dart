import '../domain/models/leaderboard_read_model.dart';
import 'data/leaderboard_demo_snapshots.dart';
import 'models/leaderboard_display_models.dart';

LeaderboardDetailDisplaySnapshot leaderboardDisplaySnapshotFromReadModel(
  LeaderboardReadModel model,
  DateTime now,
) {
  final fallback = defaultLeaderboardRegionRankingSnapshot;
  final rows = [
    for (final indexedEntry in model.entries.indexed)
      leaderboardRankRowDisplaySnapshotFromReadModel(
        indexedEntry.$2,
        currentRankLabel: model.currentRunnerRankLabel,
        regionLabel: model.regionLabel,
        fallbackRows: fallbackRows,
        fallbackIndex: indexedEntry.$1,
      ),
  ];
  final topRows = rows.take(fallback.topRanks.length).toList(growable: false);
  final nearbyRows = rows
      .skip(fallback.topRanks.length)
      .take(fallback.nearbyRanks.length)
      .toList(growable: false);
  final currentUser = rows.where((row) => row.isCurrentUser).firstOrNull;

  return LeaderboardDetailDisplaySnapshot(
    regionId: fallback.regionId,
    regionName: model.regionLabel.isEmpty
        ? fallback.regionName
        : model.regionLabel,
    isUserRegion: fallback.isUserRegion,
    periodLabel: model.periodLabel ?? fallback.periodLabel,
    fallbackPeriodLabel: fallback.fallbackPeriodLabel,
    refreshLabel: _refreshLabel(model.periodEndsAt, now, fallback.refreshLabel),
    fallbackRefreshLabel: fallback.fallbackRefreshLabel,
    monthlyResetLabel: fallback.monthlyResetLabel,
    divisionLabel: _firstNonEmpty(
      model.entries.map((entry) => entry.divisionLabel),
      fallback.divisionLabel,
    ),
    topRanksTitle: fallback.topRanksTitle,
    nearbyRanksTitle: fallback.nearbyRanksTitle,
    currentUser: CurrentUserRankSummaryDisplaySnapshot(
      rankLabel: model.currentRunnerRankLabel.isEmpty
          ? fallback.currentUser.rankLabel
          : model.currentRunnerRankLabel,
      title: fallback.currentUser.title,
      xpLabel: currentUser?.xpLabel ?? fallback.currentUser.xpLabel,
    ),
    topRanks: topRows.isEmpty ? fallback.topRanks : topRows,
    nearbyRanks: nearbyRows.isEmpty ? fallback.nearbyRanks : nearbyRows,
  );
}

String _refreshLabel(DateTime? periodEndsAt, DateTime now, String fallback) {
  if (periodEndsAt == null) {
    return fallback;
  }
  final remaining = periodEndsAt.difference(now).isNegative
      ? Duration.zero
      : periodEndsAt.difference(now);
  final days = remaining.inDays;
  final hours = remaining.inHours.remainder(24);
  final minutes = remaining.inMinutes.remainder(60);
  final seconds = remaining.inSeconds.remainder(60);
  return 'Refreshes in ${_twoDigits(days)}:${_twoDigits(hours)}:'
      '${_twoDigits(minutes)}:${_twoDigits(seconds)}';
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}

LeaderboardRankRowDisplaySnapshot
leaderboardRankRowDisplaySnapshotFromReadModel(
  LeaderboardRowReadModel entry, {
  required String currentRankLabel,
  required String regionLabel,
  required List<LeaderboardRankRowDisplaySnapshot> fallbackRows,
  required int fallbackIndex,
}) {
  final name = entry.displayName.trim();
  final displayName = name.isEmpty ? 'Runner' : name;
  final levelLabel = entry.levelLabel.trim();
  final rankLabel = entry.rankLabel.trim();
  final divisionLabel = entry.divisionLabel.trim();
  final isCurrentUser =
      currentRankLabel.isNotEmpty && rankLabel == currentRankLabel;
  final fallbackRow = _fallbackRowFor(
    entry,
    fallbackRows: fallbackRows,
    fallbackIndex: fallbackIndex,
  );
  final fallbackProfile = _fallbackProfileFor(
    entry,
    fallbackRows: fallbackRows,
    fallbackIndex: fallbackIndex,
  );

  return LeaderboardRankRowDisplaySnapshot(
    rankLabel: rankLabel,
    name: displayName,
    levelLabel: levelLabel,
    levelBadgeLabel:
        fallbackRow?.levelBadgeLabel ?? _levelBadgeLabel(levelLabel),
    xpLabel: entry.scoreLabel.trim(),
    isCurrentUser: isCurrentUser,
    trophy: fallbackRow?.trophy ?? false,
    medalTone: fallbackRow?.medalTone,
    profile:
        fallbackProfile ??
        RunnerAchievementProfileSnapshot(
          name: displayName,
          initial: _initialFor(displayName),
          regionRankLabel: _regionRankLabel(regionLabel, rankLabel),
          levelBadgeLabel: _levelBadgeLabel(levelLabel),
          divisionLevelLabel: divisionLabel.isEmpty
              ? levelLabel
              : '$divisionLabel · $levelLabel',
          totalDistanceLabel: '',
          bestStreakLabel: '',
          badges: const <RunnerAchievementBadgeSnapshot>[],
          isCurrentUser: isCurrentUser,
        ),
  );
}

List<LeaderboardRankRowDisplaySnapshot> get fallbackRows {
  return [
    ...defaultLeaderboardRegionRankingSnapshot.topRanks,
    ...defaultLeaderboardRegionRankingSnapshot.nearbyRanks,
  ];
}

RunnerAchievementProfileSnapshot? _fallbackProfileFor(
  LeaderboardRowReadModel entry, {
  required List<LeaderboardRankRowDisplaySnapshot> fallbackRows,
  required int fallbackIndex,
}) {
  return _fallbackRowFor(
    entry,
    fallbackRows: fallbackRows,
    fallbackIndex: fallbackIndex,
  )?.profile;
}

LeaderboardRankRowDisplaySnapshot? _fallbackRowFor(
  LeaderboardRowReadModel entry, {
  required List<LeaderboardRankRowDisplaySnapshot> fallbackRows,
  required int fallbackIndex,
}) {
  final rankLabel = entry.rankLabel.trim();
  final displayName = entry.displayName.trim();
  for (final fallbackRow in fallbackRows) {
    if (fallbackRow.rankLabel == rankLabel && fallbackRow.name == displayName) {
      return fallbackRow;
    }
  }
  if (fallbackIndex >= 0 && fallbackIndex < fallbackRows.length) {
    return fallbackRows[fallbackIndex];
  }
  return null;
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

String _firstNonEmpty(Iterable<String> values, String fallback) {
  for (final value in values) {
    if (value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return fallback;
}

String _initialFor(String displayName) {
  final trimmedName = displayName.trim();
  if (trimmedName.isEmpty) {
    return 'R';
  }
  return String.fromCharCode(trimmedName.runes.first).toUpperCase();
}

String _levelBadgeLabel(String levelLabel) {
  final trimmedLabel = levelLabel.trim();
  if (trimmedLabel.startsWith('Level ')) {
    return 'Lv.${trimmedLabel.substring('Level '.length)}';
  }
  return trimmedLabel;
}
