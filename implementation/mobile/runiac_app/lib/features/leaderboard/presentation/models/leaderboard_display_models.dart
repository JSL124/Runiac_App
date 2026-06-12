import 'package:flutter/widgets.dart';

// Presentation-only display models for static leaderboard UI.
// Backend-owned values are read-only labels here, not client calculations.
class LeaderboardPreviewSnapshot {
  const LeaderboardPreviewSnapshot({
    required this.tipsTitle,
    required this.leaguesTipTitle,
    required this.cadenceTipTitle,
    required this.readinessTipTitle,
    required this.leaguesTipBody,
    required this.cadenceTipBody,
    required this.readinessTipBody,
  });

  final String tipsTitle;
  final String leaguesTipTitle;
  final String cadenceTipTitle;
  final String readinessTipTitle;
  final String leaguesTipBody;
  final String cadenceTipBody;
  final String readinessTipBody;
}

class LeaderboardLeagueSnapshot {
  const LeaderboardLeagueSnapshot({
    required this.selectedDivision,
    required this.selectedLevelRange,
    required this.dialogTitle,
    required this.entries,
  });

  final String selectedDivision;
  final String selectedLevelRange;
  final String dialogTitle;
  final List<LeagueTaxonomyEntry> entries;
}

class LeaderboardRegionSnapshot {
  const LeaderboardRegionSnapshot({
    required this.regionName,
    required this.rankPreviewTitle,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.userAreaLabel,
  });

  final String regionName;
  final String rankPreviewTitle;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final String userAreaLabel;
}

class LeaderboardDetailDisplaySnapshot {
  const LeaderboardDetailDisplaySnapshot({
    required this.regionName,
    required this.periodLabel,
    required this.fallbackPeriodLabel,
    required this.refreshLabel,
    required this.fallbackRefreshLabel,
    required this.divisionLabel,
    required this.topRanksTitle,
    required this.nearbyRanksTitle,
    required this.currentUser,
    required this.topRanks,
    required this.nearbyRanks,
  });

  final String regionName;
  final String periodLabel;
  final String fallbackPeriodLabel;
  final String refreshLabel;
  final String fallbackRefreshLabel;
  final String divisionLabel;
  final String topRanksTitle;
  final String nearbyRanksTitle;
  final CurrentUserRankSummaryDisplaySnapshot currentUser;
  final List<LeaderboardRankRowDisplaySnapshot> topRanks;
  final List<LeaderboardRankRowDisplaySnapshot> nearbyRanks;
}

String resolveLeaderboardPeriodLabelForDisplay({
  required String periodLabel,
  required String fallbackPeriodLabel,
}) {
  final trimmedPeriodLabel = periodLabel.trim();
  if (trimmedPeriodLabel.isNotEmpty) {
    return trimmedPeriodLabel;
  }

  return fallbackPeriodLabel;
}

class LeaderboardRankRowDisplaySnapshot {
  const LeaderboardRankRowDisplaySnapshot({
    required this.rankLabel,
    required this.name,
    required this.levelLabel,
    required this.xpLabel,
    required this.profile,
    this.trophy = false,
    this.isCurrentUser = false,
    this.medalTone,
  });

  final String rankLabel;
  final String name;
  final String levelLabel;
  final String xpLabel;
  final RunnerAchievementProfileSnapshot profile;
  final bool trophy;
  final bool isCurrentUser;
  final RegionPreviewMedalTone? medalTone;
}

class RunnerAchievementProfileSnapshot {
  const RunnerAchievementProfileSnapshot({
    required this.name,
    required this.initial,
    required this.regionRankLabel,
    required this.levelBadgeLabel,
    required this.divisionLevelLabel,
    required this.totalDistanceLabel,
    required this.bestStreakLabel,
    required this.badges,
    this.privacyNote = 'Only public running achievements are shown.',
    this.isCurrentUser = false,
  });

  final String name;
  final String initial;
  final String regionRankLabel;
  final String levelBadgeLabel;
  final String divisionLevelLabel;
  final String totalDistanceLabel;
  final String bestStreakLabel;
  final String privacyNote;
  final List<RunnerAchievementBadgeSnapshot> badges;
  final bool isCurrentUser;
}

class RunnerAchievementBadgeSnapshot {
  const RunnerAchievementBadgeSnapshot({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;
}

class CurrentUserRankSummaryDisplaySnapshot {
  const CurrentUserRankSummaryDisplaySnapshot({
    required this.rankLabel,
    required this.title,
    required this.xpLabel,
  });

  final String rankLabel;
  final String title;
  final String xpLabel;
}

enum RegionPreviewMedalTone { gold, silver, bronze }

class LeagueTaxonomyEntry {
  const LeagueTaxonomyEntry(this.name, this.range);

  final String name;
  final String range;
}
