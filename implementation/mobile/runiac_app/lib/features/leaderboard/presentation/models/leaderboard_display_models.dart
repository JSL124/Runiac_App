import 'package:flutter/widgets.dart';

import '../../../../core/assets/runiac_assets.dart';
import '../../domain/models/leaderboard_read_model.dart';

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
    required this.selectedDivisionAssetPath,
    required this.dialogTitle,
    required this.entries,
  });

  final String selectedDivision;
  final String selectedLevelRange;
  final String selectedDivisionAssetPath;
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
    required this.regionId,
    required this.regionName,
    required this.isUserRegion,
    required this.periodLabel,
    required this.fallbackPeriodLabel,
    required this.refreshLabel,
    required this.fallbackRefreshLabel,
    required this.monthlyResetLabel,
    required this.divisionLabel,
    required this.topRanksTitle,
    required this.nearbyRanksTitle,
    required this.currentUser,
    required this.topRanks,
    required this.nearbyRanks,
    this.divisionAssetPath = RuniacAssets.leaderboardLeagueIron,
    this.status = LeaderboardReadStatus.data,
    this.hasCurrentUserRank = true,
    this.periodEndsAt,
    this.refreshLabelIsLive = false,
  });

  final String regionId;
  final String regionName;
  final bool isUserRegion;
  final String periodLabel;
  final String fallbackPeriodLabel;
  final String refreshLabel;
  final String fallbackRefreshLabel;
  final String monthlyResetLabel;
  final String divisionLabel;
  // League (division) badge artwork for this board, resolved from the
  // backend-owned division tier. Display-only; never computed on the client.
  final String divisionAssetPath;
  final String topRanksTitle;
  final String nearbyRanksTitle;
  final CurrentUserRankSummaryDisplaySnapshot currentUser;
  final List<LeaderboardRankRowDisplaySnapshot> topRanks;
  final List<LeaderboardRankRowDisplaySnapshot> nearbyRanks;

  // Backend-owned read status. Display-only; the client renders empty,
  // unranked, updating, and ineligible states from this signal without
  // computing any rank or score.
  final LeaderboardReadStatus status;

  // True when the backend reported a rank for the current user. Detected
  // from presence in the read model, never computed on the client.
  final bool hasCurrentUserRank;

  // Backend-owned monthly period end. Display-only: the refresh countdown is
  // re-derived from this trusted instant; the client never computes the reset.
  final DateTime? periodEndsAt;

  // True when [refreshLabel] was derived from [periodEndsAt] (should tick live)
  // rather than supplied verbatim by the backend as a static copy string.
  final bool refreshLabelIsLive;
}

class LeaderboardMapRegionDisplaySnapshot {
  const LeaderboardMapRegionDisplaySnapshot({
    required this.regionId,
    required this.regionName,
    required this.semanticLabel,
    required this.locationLabel,
    required this.planningAreaName,
    required this.planningAreaCode,
    required this.planningRegionCode,
    required this.fallbackAlignment,
    required this.color,
    this.isUserRegion = false,
  });

  final String regionId;
  final String regionName;
  final String semanticLabel;
  final String locationLabel;
  final String planningAreaName;
  final String planningAreaCode;
  final String planningRegionCode;
  final Alignment fallbackAlignment;
  final Color color;
  final bool isUserRegion;

  LeaderboardMapRegionDisplaySnapshot copyWith({bool? isUserRegion}) {
    return LeaderboardMapRegionDisplaySnapshot(
      regionId: regionId,
      regionName: regionName,
      semanticLabel: semanticLabel,
      locationLabel: locationLabel,
      planningAreaName: planningAreaName,
      planningAreaCode: planningAreaCode,
      planningRegionCode: planningRegionCode,
      fallbackAlignment: fallbackAlignment,
      color: color,
      isUserRegion: isUserRegion ?? this.isUserRegion,
    );
  }
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
    required this.levelBadgeLabel,
    required this.xpLabel,
    required this.profile,
    this.trophy = false,
    this.isCurrentUser = false,
    this.medalTone,
  });

  final String rankLabel;
  final String name;
  final String levelLabel;
  final String levelBadgeLabel;
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
    this.uid = '',
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

  /// Backend-issued uid of the runner this profile describes. Used only to
  /// address a report-a-user write (`targetId`); never displayed and never
  /// used for any XP/rank/score computation. Empty for demo/preview
  /// snapshots that have no real backing user, which also hides the report
  /// affordance for those.
  final String uid;
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
  const LeagueTaxonomyEntry(this.name, this.range, this.assetPath);

  final String name;
  final String range;
  final String assetPath;
}
