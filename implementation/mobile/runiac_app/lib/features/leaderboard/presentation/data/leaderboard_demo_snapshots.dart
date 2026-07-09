import 'package:flutter/material.dart';

import '../models/leaderboard_display_models.dart';

// Display-only demo snapshots. In production, rank, XP, level, and
// leaderboard values must come from backend-owned read models.
const leaderboardRunnerAchievementDemoBadges = [
  RunnerAchievementBadgeSnapshot(
    icon: Icons.flag_outlined,
    label: 'First 5K',
    highlighted: true,
  ),
  RunnerAchievementBadgeSnapshot(
    icon: Icons.check,
    label: 'Consistency Starter',
  ),
  RunnerAchievementBadgeSnapshot(
    icon: Icons.favorite_border,
    label: 'Weekend Runner',
  ),
  RunnerAchievementBadgeSnapshot(
    icon: Icons.wb_sunny_outlined,
    label: 'Morning Miles',
    highlighted: true,
  ),
  RunnerAchievementBadgeSnapshot(
    icon: Icons.route_outlined,
    label: 'Steady Builder',
  ),
  RunnerAchievementBadgeSnapshot(
    icon: Icons.location_on_outlined,
    label: 'Park Route Fan',
  ),
];

const leaderboardPreviewDemoSnapshot = LeaderboardPreviewSnapshot(
  tipsTitle: 'Tips',
  leaguesTipTitle: 'Leagues',
  cadenceTipTitle: 'Board timing',
  readinessTipTitle: 'Static sample data',
  leaguesTipBody:
      'Leagues group runners by broad progress bands so the board feels fair and beginner-friendly.',
  cadenceTipBody:
      'This static preview keeps one monthly board context for a calmer comparison.',
  readinessTipBody:
      'Leaderboard values shown here are display-only sample rows for this UI milestone.',
);

const leaderboardLeagueDemoSnapshot = LeaderboardLeagueSnapshot(
  selectedDivision: 'Rising Runner Division',
  selectedLevelRange: 'Lv.11 - Lv.20',
  dialogTitle: 'Leagues',
  entries: [
    LeagueTaxonomyEntry('Apex Runner League', 'Lv.81 - Lv.90'),
    LeagueTaxonomyEntry('Summitborn League', 'Lv.71 - Lv.80'),
    LeagueTaxonomyEntry('Roadrunner League', 'Lv.51 - Lv.60'),
    LeagueTaxonomyEntry('Endurancer League', 'Lv.41 - Lv.50'),
    LeagueTaxonomyEntry('Milehunter League', 'Lv.31 - Lv.40'),
    LeagueTaxonomyEntry('Pacebreaker League', 'Lv.21 - Lv.30'),
    LeagueTaxonomyEntry('Strideforge League', 'Lv.11 - Lv.20'),
    LeagueTaxonomyEntry('Trailborn League', 'Lv.1 - Lv.10'),
  ],
);

const leaderboardRegionDemoSnapshot = LeaderboardRegionSnapshot(
  regionName: 'Jurong East',
  rankPreviewTitle: 'My Rank Preview',
  primaryActionLabel: 'View More Ranking',
  secondaryActionLabel: 'Share My Rank',
  userAreaLabel: 'Your ranked area',
);

const leaderboardDetailDemoSnapshot = LeaderboardDetailDisplaySnapshot(
  regionId: 'jurong-east',
  regionName: 'Jurong East',
  isUserRegion: true,
  periodLabel: 'July 2026',
  fallbackPeriodLabel: 'Monthly board',
  refreshLabel: 'Refreshes in 24:14:05:45',
  fallbackRefreshLabel: 'Refreshes in 00:00:00:00',
  monthlyResetLabel:
      'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
  divisionLabel: 'Rising Runner Division',
  topRanksTitle: 'Regional ranking',
  nearbyRanksTitle: 'Nearby your rank',
  currentUser: CurrentUserRankSummaryDisplaySnapshot(
    rankLabel: '#18',
    title: 'Nearby monthly rank',
    xpLabel: '520 XP',
  ),
  topRanks: [
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#1',
      name: 'Alex T.',
      levelLabel: 'Level 18',
      levelBadgeLabel: 'Lv.18',
      xpLabel: '1,240 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Alex T.',
        initial: 'A',
        regionRankLabel: 'Jurong East · Rank #1',
        levelBadgeLabel: 'Lv.18',
        divisionLevelLabel: 'Rising Runner Division · Level 18',
        totalDistanceLabel: '10000 km',
        bestStreakLabel: '365 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      trophy: true,
      medalTone: RegionPreviewMedalTone.gold,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#2',
      name: 'Maya L.',
      levelLabel: 'Level 17',
      levelBadgeLabel: 'Lv.17',
      xpLabel: '1,180 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Maya L.',
        initial: 'M',
        regionRankLabel: 'Jurong East · Rank #2',
        levelBadgeLabel: 'Lv.17',
        divisionLevelLabel: 'Rising Runner Division · Level 17',
        totalDistanceLabel: '198.2 km',
        bestStreakLabel: '19 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.silver,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#3',
      name: 'Ryan K.',
      levelLabel: 'Level 16',
      levelBadgeLabel: 'Lv.16',
      xpLabel: '1,050 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Ryan K.',
        initial: 'R',
        regionRankLabel: 'Jurong East · Rank #3',
        levelBadgeLabel: 'Lv.16',
        divisionLevelLabel: 'Rising Runner Division · Level 16',
        totalDistanceLabel: '176.0 km',
        bestStreakLabel: '18 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.bronze,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#4',
      name: 'Ethan G.',
      levelLabel: 'Level 15',
      levelBadgeLabel: 'Lv.15',
      xpLabel: '870 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Ethan G.',
        initial: 'E',
        regionRankLabel: 'Jurong East · Rank #4',
        levelBadgeLabel: 'Lv.15',
        divisionLevelLabel: 'Rising Runner Division · Level 15',
        totalDistanceLabel: '154.5 km',
        bestStreakLabel: '16 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#5',
      name: 'Sarah C.',
      levelLabel: 'Level 14',
      levelBadgeLabel: 'Lv.14',
      xpLabel: '760 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Sarah C.',
        initial: 'S',
        regionRankLabel: 'Jurong East · Rank #5',
        levelBadgeLabel: 'Lv.14',
        divisionLevelLabel: 'Rising Runner Division · Level 14',
        totalDistanceLabel: '143.6 km',
        bestStreakLabel: '15 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#6',
      name: 'Priya N.',
      levelLabel: 'Level 14',
      levelBadgeLabel: 'Lv.14',
      xpLabel: '735 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Priya N.',
        initial: 'P',
        regionRankLabel: 'Jurong East · Rank #6',
        levelBadgeLabel: 'Lv.14',
        divisionLevelLabel: 'Rising Runner Division · Level 14',
        totalDistanceLabel: '139.2 km',
        bestStreakLabel: '14 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#7',
      name: 'Omar R.',
      levelLabel: 'Level 13',
      levelBadgeLabel: 'Lv.13',
      xpLabel: '710 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Omar R.',
        initial: 'O',
        regionRankLabel: 'Jurong East · Rank #7',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '135.8 km',
        bestStreakLabel: '13 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#8',
      name: 'Hana S.',
      levelLabel: 'Level 13',
      levelBadgeLabel: 'Lv.13',
      xpLabel: '690 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Hana S.',
        initial: 'H',
        regionRankLabel: 'Jurong East · Rank #8',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '132.4 km',
        bestStreakLabel: '12 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#9',
      name: 'Leo P.',
      levelLabel: 'Level 13',
      levelBadgeLabel: 'Lv.13',
      xpLabel: '675 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Leo P.',
        initial: 'L',
        regionRankLabel: 'Jurong East · Rank #9',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '130.1 km',
        bestStreakLabel: '12 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#10',
      name: 'Grace L.',
      levelLabel: 'Level 13',
      levelBadgeLabel: 'Lv.13',
      xpLabel: '660 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Grace L.',
        initial: 'G',
        regionRankLabel: 'Jurong East · Rank #10',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '128.8 km',
        bestStreakLabel: '11 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
  ],
  nearbyRanks: [
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#16',
      name: 'Chloe B.',
      levelLabel: 'Level 13',
      levelBadgeLabel: 'Lv.13',
      xpLabel: '650 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Chloe B.',
        initial: 'C',
        regionRankLabel: 'Jurong East · Rank #16',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '126.1 km',
        bestStreakLabel: '11 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#17',
      name: 'Daniel W.',
      levelLabel: 'Level 13',
      levelBadgeLabel: 'Lv.13',
      xpLabel: '640 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Daniel W.',
        initial: 'D',
        regionRankLabel: 'Jurong East · Rank #17',
        levelBadgeLabel: 'Lv.13',
        divisionLevelLabel: 'Rising Runner Division · Level 13',
        totalDistanceLabel: '124.7 km',
        bestStreakLabel: '10 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#18',
      name: 'Jinseo (You)',
      levelLabel: 'Level 12',
      levelBadgeLabel: 'Lv.12',
      xpLabel: '520 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Jinseo',
        initial: 'J',
        regionRankLabel: 'Jurong East · Rank #18',
        levelBadgeLabel: 'Lv.12',
        divisionLevelLabel: 'Rising Runner Division · Level 12',
        totalDistanceLabel: '128.4 km',
        bestStreakLabel: '14 days',
        badges: leaderboardRunnerAchievementDemoBadges,
        isCurrentUser: true,
      ),
      isCurrentUser: true,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#19',
      name: 'Noah K.',
      levelLabel: 'Level 12',
      levelBadgeLabel: 'Lv.12',
      xpLabel: '505 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Noah K.',
        initial: 'N',
        regionRankLabel: 'Jurong East · Rank #19',
        levelBadgeLabel: 'Lv.12',
        divisionLevelLabel: 'Rising Runner Division · Level 12',
        totalDistanceLabel: '119.3 km',
        bestStreakLabel: '9 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#20',
      name: 'Aisha P.',
      levelLabel: 'Level 12',
      levelBadgeLabel: 'Lv.12',
      xpLabel: '492 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Aisha P.',
        initial: 'A',
        regionRankLabel: 'Jurong East · Rank #20',
        levelBadgeLabel: 'Lv.12',
        divisionLevelLabel: 'Rising Runner Division · Level 12',
        totalDistanceLabel: '116.6 km',
        bestStreakLabel: '8 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
    ),
  ],
);

const leaderboardTampinesDetailDemoSnapshot = LeaderboardDetailDisplaySnapshot(
  regionId: 'tampines',
  regionName: 'Tampines',
  isUserRegion: false,
  periodLabel: 'July 2026',
  fallbackPeriodLabel: 'Monthly board',
  refreshLabel: 'Refreshes in 18:09:32:10',
  fallbackRefreshLabel: 'Refreshes in 00:00:00:00',
  monthlyResetLabel:
      'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
  divisionLabel: 'Rising Runner Division',
  topRanksTitle: 'Regional ranking',
  nearbyRanksTitle: 'Nearby your rank',
  currentUser: CurrentUserRankSummaryDisplaySnapshot(
    rankLabel: '#--',
    title: 'Monthly ranking context',
    xpLabel: '0 XP',
  ),
  topRanks: [
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#1',
      name: 'Nadia R.',
      levelLabel: 'Level 19',
      levelBadgeLabel: 'Lv.19',
      xpLabel: '1,330 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Nadia R.',
        initial: 'N',
        regionRankLabel: 'Tampines · Rank #1',
        levelBadgeLabel: 'Lv.19',
        divisionLevelLabel: 'Rising Runner Division · Level 19',
        totalDistanceLabel: '210.4 km',
        bestStreakLabel: '22 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      trophy: true,
      medalTone: RegionPreviewMedalTone.gold,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#2',
      name: 'Wei H.',
      levelLabel: 'Level 18',
      levelBadgeLabel: 'Lv.18',
      xpLabel: '1,210 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Wei H.',
        initial: 'W',
        regionRankLabel: 'Tampines · Rank #2',
        levelBadgeLabel: 'Lv.18',
        divisionLevelLabel: 'Rising Runner Division · Level 18',
        totalDistanceLabel: '188.7 km',
        bestStreakLabel: '20 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.silver,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#3',
      name: 'Anika S.',
      levelLabel: 'Level 16',
      levelBadgeLabel: 'Lv.16',
      xpLabel: '980 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Anika S.',
        initial: 'A',
        regionRankLabel: 'Tampines · Rank #3',
        levelBadgeLabel: 'Lv.16',
        divisionLevelLabel: 'Rising Runner Division · Level 16',
        totalDistanceLabel: '166.2 km',
        bestStreakLabel: '17 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.bronze,
    ),
  ],
  nearbyRanks: [],
);

const leaderboardWoodlandsDetailDemoSnapshot = LeaderboardDetailDisplaySnapshot(
  regionId: 'woodlands',
  regionName: 'Woodlands',
  isUserRegion: false,
  periodLabel: 'July 2026',
  fallbackPeriodLabel: 'Monthly board',
  refreshLabel: 'Refreshes in 18:09:32:10',
  fallbackRefreshLabel: 'Refreshes in 00:00:00:00',
  monthlyResetLabel:
      'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
  divisionLabel: 'Rising Runner Division',
  topRanksTitle: 'Regional ranking',
  nearbyRanksTitle: 'Nearby your rank',
  currentUser: CurrentUserRankSummaryDisplaySnapshot(
    rankLabel: '#--',
    title: 'Monthly ranking context',
    xpLabel: '0 XP',
  ),
  topRanks: [
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#1',
      name: 'Farah M.',
      levelLabel: 'Level 17',
      levelBadgeLabel: 'Lv.17',
      xpLabel: '1,090 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Farah M.',
        initial: 'F',
        regionRankLabel: 'Woodlands · Rank #1',
        levelBadgeLabel: 'Lv.17',
        divisionLevelLabel: 'Rising Runner Division · Level 17',
        totalDistanceLabel: '174.0 km',
        bestStreakLabel: '18 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      trophy: true,
      medalTone: RegionPreviewMedalTone.gold,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#2',
      name: 'Jun P.',
      levelLabel: 'Level 16',
      levelBadgeLabel: 'Lv.16',
      xpLabel: '970 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Jun P.',
        initial: 'J',
        regionRankLabel: 'Woodlands · Rank #2',
        levelBadgeLabel: 'Lv.16',
        divisionLevelLabel: 'Rising Runner Division · Level 16',
        totalDistanceLabel: '160.5 km',
        bestStreakLabel: '16 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.silver,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#3',
      name: 'Iris C.',
      levelLabel: 'Level 15',
      levelBadgeLabel: 'Lv.15',
      xpLabel: '880 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Iris C.',
        initial: 'I',
        regionRankLabel: 'Woodlands · Rank #3',
        levelBadgeLabel: 'Lv.15',
        divisionLevelLabel: 'Rising Runner Division · Level 15',
        totalDistanceLabel: '150.2 km',
        bestStreakLabel: '14 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.bronze,
    ),
  ],
  nearbyRanks: [],
);

const leaderboardMarinaBayDetailDemoSnapshot = LeaderboardDetailDisplaySnapshot(
  regionId: 'marina-bay',
  regionName: 'Marina Bay',
  isUserRegion: false,
  periodLabel: 'July 2026',
  fallbackPeriodLabel: 'Monthly board',
  refreshLabel: 'Refreshes in 18:09:32:10',
  fallbackRefreshLabel: 'Refreshes in 00:00:00:00',
  monthlyResetLabel:
      'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
  divisionLabel: 'Rising Runner Division',
  topRanksTitle: 'Regional ranking',
  nearbyRanksTitle: 'Nearby your rank',
  currentUser: CurrentUserRankSummaryDisplaySnapshot(
    rankLabel: '#--',
    title: 'Monthly ranking context',
    xpLabel: '0 XP',
  ),
  topRanks: [
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#1',
      name: 'Kai V.',
      levelLabel: 'Level 20',
      levelBadgeLabel: 'Lv.20',
      xpLabel: '1,450 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Kai V.',
        initial: 'K',
        regionRankLabel: 'Marina Bay · Rank #1',
        levelBadgeLabel: 'Lv.20',
        divisionLevelLabel: 'Rising Runner Division · Level 20',
        totalDistanceLabel: '226.8 km',
        bestStreakLabel: '25 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      trophy: true,
      medalTone: RegionPreviewMedalTone.gold,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#2',
      name: 'Lina Q.',
      levelLabel: 'Level 18',
      levelBadgeLabel: 'Lv.18',
      xpLabel: '1,260 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Lina Q.',
        initial: 'L',
        regionRankLabel: 'Marina Bay · Rank #2',
        levelBadgeLabel: 'Lv.18',
        divisionLevelLabel: 'Rising Runner Division · Level 18',
        totalDistanceLabel: '190.0 km',
        bestStreakLabel: '19 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.silver,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#3',
      name: 'Sam D.',
      levelLabel: 'Level 17',
      levelBadgeLabel: 'Lv.17',
      xpLabel: '1,080 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Sam D.',
        initial: 'S',
        regionRankLabel: 'Marina Bay · Rank #3',
        levelBadgeLabel: 'Lv.17',
        divisionLevelLabel: 'Rising Runner Division · Level 17',
        totalDistanceLabel: '171.2 km',
        bestStreakLabel: '18 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.bronze,
    ),
  ],
  nearbyRanks: [],
);

const leaderboardAngMoKioDetailDemoSnapshot = LeaderboardDetailDisplaySnapshot(
  regionId: 'ang-mo-kio',
  regionName: 'Ang Mo Kio',
  isUserRegion: false,
  periodLabel: 'July 2026',
  fallbackPeriodLabel: 'Monthly board',
  refreshLabel: 'Refreshes in 18:09:32:10',
  fallbackRefreshLabel: 'Refreshes in 00:00:00:00',
  monthlyResetLabel:
      'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
  divisionLabel: 'Rising Runner Division',
  topRanksTitle: 'Regional ranking',
  nearbyRanksTitle: 'Nearby your rank',
  currentUser: CurrentUserRankSummaryDisplaySnapshot(
    rankLabel: '#--',
    title: 'Monthly ranking context',
    xpLabel: '0 XP',
  ),
  topRanks: [
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#1',
      name: 'Mei T.',
      levelLabel: 'Level 18',
      levelBadgeLabel: 'Lv.18',
      xpLabel: '1,190 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Mei T.',
        initial: 'M',
        regionRankLabel: 'Ang Mo Kio · Rank #1',
        levelBadgeLabel: 'Lv.18',
        divisionLevelLabel: 'Rising Runner Division · Level 18',
        totalDistanceLabel: '184.3 km',
        bestStreakLabel: '20 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      trophy: true,
      medalTone: RegionPreviewMedalTone.gold,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#2',
      name: 'Arun B.',
      levelLabel: 'Level 16',
      levelBadgeLabel: 'Lv.16',
      xpLabel: '940 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Arun B.',
        initial: 'A',
        regionRankLabel: 'Ang Mo Kio · Rank #2',
        levelBadgeLabel: 'Lv.16',
        divisionLevelLabel: 'Rising Runner Division · Level 16',
        totalDistanceLabel: '158.9 km',
        bestStreakLabel: '15 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.silver,
    ),
    LeaderboardRankRowDisplaySnapshot(
      rankLabel: '#3',
      name: 'Tara J.',
      levelLabel: 'Level 15',
      levelBadgeLabel: 'Lv.15',
      xpLabel: '860 XP',
      profile: RunnerAchievementProfileSnapshot(
        name: 'Tara J.',
        initial: 'T',
        regionRankLabel: 'Ang Mo Kio · Rank #3',
        levelBadgeLabel: 'Lv.15',
        divisionLevelLabel: 'Rising Runner Division · Level 15',
        totalDistanceLabel: '148.4 km',
        bestStreakLabel: '13 days',
        badges: leaderboardRunnerAchievementDemoBadges,
      ),
      medalTone: RegionPreviewMedalTone.bronze,
    ),
  ],
  nearbyRanks: [],
);

const leaderboardRegionalDemoSnapshots = [
  leaderboardDetailDemoSnapshot,
  leaderboardTampinesDetailDemoSnapshot,
  leaderboardWoodlandsDetailDemoSnapshot,
  leaderboardMarinaBayDetailDemoSnapshot,
  leaderboardAngMoKioDetailDemoSnapshot,
];

const _jurongEastColor = Color(0xFFFF5A1F);
const _orchardColor = Color(0xFF7C3AED);
const _angMoKioColor = Color(0xFF0891B2);
const _bedokColor = Color(0xFF16A34A);
const _bishanColor = Color(0xFFD946EF);
const _boonLayColor = Color(0xFFEA580C);
const _bukitBatokColor = Color(0xFFF59E0B);
const _bukitMerahColor = Color(0xFFE11D48);
const _bukitPanjangColor = Color(0xFF84CC16);
const _bukitTimahColor = Color(0xFF8B5CF6);
const _changiColor = Color(0xFF0D9488);
const _choaChuKangColor = Color(0xFFCA8A04);
const _clementiColor = Color(0xFFF97316);
const _downtownCoreColor = Color(0xFFDB2777);
const _geylangColor = Color(0xFF9333EA);
const _hougangColor = Color(0xFF0284C7);
const _jurongWestColor = Color(0xFFDC2626);
const _kallangColor = Color(0xFF4F46E5);
const _marineParadeColor = Color(0xFF14B8A6);
const _museumColor = Color(0xFF65A30D);
const _newtonColor = Color(0xFF64748B);
const _novenaColor = Color(0xFFA855F7);
const _outramColor = Color(0xFFF43F5E);
const _pasirRisColor = Color(0xFF22C55E);
const _punggolColor = Color(0xFF2563EB);
const _queenstownColor = Color(0xFFBE185D);
const _riverValleyColor = Color(0xFF6D28D9);
const _rochorColor = Color(0xFFB45309);
const _sembawangColor = Color(0xFF1D4ED8);
const _sengkangColor = Color(0xFF06B6D4);
const _serangoonColor = Color(0xFF0EA5E9);
const _singaporeRiverColor = Color(0xFF0F766E);
const _tampinesColor = Color(0xFF15803D);
const _tanglinColor = Color(0xFFC026D3);
const _toaPayohColor = Color(0xFF7E22CE);
const _woodlandsColor = Color(0xFF1E40AF);
const _yishunColor = Color(0xFF3B82F6);

const leaderboardMapRegionDemoSnapshots = [
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'jurong-east',
    regionName: 'Jurong East',
    locationLabel: 'Jurong East, Singapore',
    semanticLabel: 'Jurong East user region ranking polygon',
    planningAreaName: 'JURONG EAST',
    planningAreaCode: 'JE',
    planningRegionCode: 'WR',
    fallbackAlignment: Alignment(-0.56, 0.22),
    color: _jurongEastColor,
    isUserRegion: true,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'orchard',
    regionName: 'Orchard',
    locationLabel: 'Orchard, Singapore',
    semanticLabel: 'Orchard region ranking polygon',
    planningAreaName: 'ORCHARD',
    planningAreaCode: 'OR',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(-0.02, 0.12),
    color: _orchardColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'ang-mo-kio',
    regionName: 'Ang Mo Kio',
    locationLabel: 'Ang Mo Kio, Singapore',
    semanticLabel: 'Ang Mo Kio region ranking polygon',
    planningAreaName: 'ANG MO KIO',
    planningAreaCode: 'AM',
    planningRegionCode: 'NER',
    fallbackAlignment: Alignment(0.05, -0.44),
    color: _angMoKioColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'bedok',
    regionName: 'Bedok',
    locationLabel: 'Bedok, Singapore',
    semanticLabel: 'Bedok region ranking polygon',
    planningAreaName: 'BEDOK',
    planningAreaCode: 'BD',
    planningRegionCode: 'ER',
    fallbackAlignment: Alignment(0.62, 0.12),
    color: _bedokColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'bishan',
    regionName: 'Bishan',
    locationLabel: 'Bishan, Singapore',
    semanticLabel: 'Bishan region ranking polygon',
    planningAreaName: 'BISHAN',
    planningAreaCode: 'BS',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.04, -0.28),
    color: _bishanColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'boon-lay',
    regionName: 'Boon Lay',
    locationLabel: 'Boon Lay, Singapore',
    semanticLabel: 'Boon Lay region ranking polygon',
    planningAreaName: 'BOON LAY',
    planningAreaCode: 'BL',
    planningRegionCode: 'WR',
    fallbackAlignment: Alignment(-0.82, 0.08),
    color: _boonLayColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'bukit-batok',
    regionName: 'Bukit Batok',
    locationLabel: 'Bukit Batok, Singapore',
    semanticLabel: 'Bukit Batok region ranking polygon',
    planningAreaName: 'BUKIT BATOK',
    planningAreaCode: 'BK',
    planningRegionCode: 'WR',
    fallbackAlignment: Alignment(-0.48, -0.16),
    color: _bukitBatokColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'bukit-merah',
    regionName: 'Bukit Merah',
    locationLabel: 'Bukit Merah, Singapore',
    semanticLabel: 'Bukit Merah region ranking polygon',
    planningAreaName: 'BUKIT MERAH',
    planningAreaCode: 'BM',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(-0.14, 0.36),
    color: _bukitMerahColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'bukit-panjang',
    regionName: 'Bukit Panjang',
    locationLabel: 'Bukit Panjang, Singapore',
    semanticLabel: 'Bukit Panjang region ranking polygon',
    planningAreaName: 'BUKIT PANJANG',
    planningAreaCode: 'BP',
    planningRegionCode: 'WR',
    fallbackAlignment: Alignment(-0.56, -0.34),
    color: _bukitPanjangColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'bukit-timah',
    regionName: 'Bukit Timah',
    locationLabel: 'Bukit Timah, Singapore',
    semanticLabel: 'Bukit Timah region ranking polygon',
    planningAreaName: 'BUKIT TIMAH',
    planningAreaCode: 'BT',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(-0.26, -0.14),
    color: _bukitTimahColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'changi',
    regionName: 'Changi',
    locationLabel: 'Changi, Singapore',
    semanticLabel: 'Changi region ranking polygon',
    planningAreaName: 'CHANGI',
    planningAreaCode: 'CH',
    planningRegionCode: 'ER',
    fallbackAlignment: Alignment(0.86, -0.02),
    color: _changiColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'choa-chu-kang',
    regionName: 'Choa Chu Kang',
    locationLabel: 'Choa Chu Kang, Singapore',
    semanticLabel: 'Choa Chu Kang region ranking polygon',
    planningAreaName: 'CHOA CHU KANG',
    planningAreaCode: 'CK',
    planningRegionCode: 'WR',
    fallbackAlignment: Alignment(-0.68, -0.28),
    color: _choaChuKangColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'clementi',
    regionName: 'Clementi',
    locationLabel: 'Clementi, Singapore',
    semanticLabel: 'Clementi region ranking polygon',
    planningAreaName: 'CLEMENTI',
    planningAreaCode: 'CL',
    planningRegionCode: 'WR',
    fallbackAlignment: Alignment(-0.44, 0.16),
    color: _clementiColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'downtown-core',
    regionName: 'Downtown Core',
    locationLabel: 'Downtown Core, Singapore',
    semanticLabel: 'Downtown Core region ranking polygon',
    planningAreaName: 'DOWNTOWN CORE',
    planningAreaCode: 'DT',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.16, 0.36),
    color: _downtownCoreColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'geylang',
    regionName: 'Geylang',
    locationLabel: 'Geylang, Singapore',
    semanticLabel: 'Geylang region ranking polygon',
    planningAreaName: 'GEYLANG',
    planningAreaCode: 'GL',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.32, 0.16),
    color: _geylangColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'hougang',
    regionName: 'Hougang',
    locationLabel: 'Hougang, Singapore',
    semanticLabel: 'Hougang region ranking polygon',
    planningAreaName: 'HOUGANG',
    planningAreaCode: 'HG',
    planningRegionCode: 'NER',
    fallbackAlignment: Alignment(0.30, -0.40),
    color: _hougangColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'jurong-west',
    regionName: 'Jurong West',
    locationLabel: 'Jurong West, Singapore',
    semanticLabel: 'Jurong West region ranking polygon',
    planningAreaName: 'JURONG WEST',
    planningAreaCode: 'JW',
    planningRegionCode: 'WR',
    fallbackAlignment: Alignment(-0.74, 0.00),
    color: _jurongWestColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'kallang',
    regionName: 'Kallang',
    locationLabel: 'Kallang, Singapore',
    semanticLabel: 'Kallang region ranking polygon',
    planningAreaName: 'KALLANG',
    planningAreaCode: 'KL',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.20, 0.18),
    color: _kallangColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'marine-parade',
    regionName: 'Marine Parade',
    locationLabel: 'Marine Parade, Singapore',
    semanticLabel: 'Marine Parade region ranking polygon',
    planningAreaName: 'MARINE PARADE',
    planningAreaCode: 'MP',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.42, 0.34),
    color: _marineParadeColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'museum',
    regionName: 'Museum',
    locationLabel: 'Museum, Singapore',
    semanticLabel: 'Museum region ranking polygon',
    planningAreaName: 'MUSEUM',
    planningAreaCode: 'MU',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.02, 0.18),
    color: _museumColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'newton',
    regionName: 'Newton',
    locationLabel: 'Newton, Singapore',
    semanticLabel: 'Newton region ranking polygon',
    planningAreaName: 'NEWTON',
    planningAreaCode: 'NT',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(-0.02, -0.02),
    color: _newtonColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'novena',
    regionName: 'Novena',
    locationLabel: 'Novena, Singapore',
    semanticLabel: 'Novena region ranking polygon',
    planningAreaName: 'NOVENA',
    planningAreaCode: 'NV',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.02, -0.10),
    color: _novenaColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'outram',
    regionName: 'Outram',
    locationLabel: 'Outram, Singapore',
    semanticLabel: 'Outram region ranking polygon',
    planningAreaName: 'OUTRAM',
    planningAreaCode: 'OT',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.04, 0.36),
    color: _outramColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'pasir-ris',
    regionName: 'Pasir Ris',
    locationLabel: 'Pasir Ris, Singapore',
    semanticLabel: 'Pasir Ris region ranking polygon',
    planningAreaName: 'PASIR RIS',
    planningAreaCode: 'PR',
    planningRegionCode: 'ER',
    fallbackAlignment: Alignment(0.66, -0.30),
    color: _pasirRisColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'punggol',
    regionName: 'Punggol',
    locationLabel: 'Punggol, Singapore',
    semanticLabel: 'Punggol region ranking polygon',
    planningAreaName: 'PUNGGOL',
    planningAreaCode: 'PG',
    planningRegionCode: 'NER',
    fallbackAlignment: Alignment(0.44, -0.58),
    color: _punggolColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'queenstown',
    regionName: 'Queenstown',
    locationLabel: 'Queenstown, Singapore',
    semanticLabel: 'Queenstown region ranking polygon',
    planningAreaName: 'QUEENSTOWN',
    planningAreaCode: 'QT',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(-0.26, 0.20),
    color: _queenstownColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'river-valley',
    regionName: 'River Valley',
    locationLabel: 'River Valley, Singapore',
    semanticLabel: 'River Valley region ranking polygon',
    planningAreaName: 'RIVER VALLEY',
    planningAreaCode: 'RV',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(-0.04, 0.20),
    color: _riverValleyColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'rochor',
    regionName: 'Rochor',
    locationLabel: 'Rochor, Singapore',
    semanticLabel: 'Rochor region ranking polygon',
    planningAreaName: 'ROCHOR',
    planningAreaCode: 'RC',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.14, 0.10),
    color: _rochorColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'sembawang',
    regionName: 'Sembawang',
    locationLabel: 'Sembawang, Singapore',
    semanticLabel: 'Sembawang region ranking polygon',
    planningAreaName: 'SEMBAWANG',
    planningAreaCode: 'SB',
    planningRegionCode: 'NR',
    fallbackAlignment: Alignment(-0.18, -0.78),
    color: _sembawangColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'sengkang',
    regionName: 'Sengkang',
    locationLabel: 'Sengkang, Singapore',
    semanticLabel: 'Sengkang region ranking polygon',
    planningAreaName: 'SENGKANG',
    planningAreaCode: 'SE',
    planningRegionCode: 'NER',
    fallbackAlignment: Alignment(0.36, -0.52),
    color: _sengkangColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'serangoon',
    regionName: 'Serangoon',
    locationLabel: 'Serangoon, Singapore',
    semanticLabel: 'Serangoon region ranking polygon',
    planningAreaName: 'SERANGOON',
    planningAreaCode: 'SG',
    planningRegionCode: 'NER',
    fallbackAlignment: Alignment(0.22, -0.30),
    color: _serangoonColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'singapore-river',
    regionName: 'Singapore River',
    locationLabel: 'Singapore River, Singapore',
    semanticLabel: 'Singapore River region ranking polygon',
    planningAreaName: 'SINGAPORE RIVER',
    planningAreaCode: 'SR',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.02, 0.30),
    color: _singaporeRiverColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'tampines',
    regionName: 'Tampines',
    locationLabel: 'Tampines, Singapore',
    semanticLabel: 'Tampines region ranking polygon',
    planningAreaName: 'TAMPINES',
    planningAreaCode: 'TM',
    planningRegionCode: 'ER',
    fallbackAlignment: Alignment(0.62, -0.14),
    color: _tampinesColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'tanglin',
    regionName: 'Tanglin',
    locationLabel: 'Tanglin, Singapore',
    semanticLabel: 'Tanglin region ranking polygon',
    planningAreaName: 'TANGLIN',
    planningAreaCode: 'TN',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(-0.12, 0.04),
    color: _tanglinColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'toa-payoh',
    regionName: 'Toa Payoh',
    locationLabel: 'Toa Payoh, Singapore',
    semanticLabel: 'Toa Payoh region ranking polygon',
    planningAreaName: 'TOA PAYOH',
    planningAreaCode: 'TP',
    planningRegionCode: 'CR',
    fallbackAlignment: Alignment(0.12, -0.18),
    color: _toaPayohColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'woodlands',
    regionName: 'Woodlands',
    locationLabel: 'Woodlands, Singapore',
    semanticLabel: 'Woodlands region ranking polygon',
    planningAreaName: 'WOODLANDS',
    planningAreaCode: 'WD',
    planningRegionCode: 'NR',
    fallbackAlignment: Alignment(-0.34, -0.72),
    color: _woodlandsColor,
  ),
  LeaderboardMapRegionDisplaySnapshot(
    regionId: 'yishun',
    regionName: 'Yishun',
    locationLabel: 'Yishun, Singapore',
    semanticLabel: 'Yishun region ranking polygon',
    planningAreaName: 'YISHUN',
    planningAreaCode: 'YS',
    planningRegionCode: 'NR',
    fallbackAlignment: Alignment(0.02, -0.68),
    color: _yishunColor,
  ),
];

String? leaderboardPlanningAreaIdForLocationLabel(String locationLabel) {
  final normalizedLocationLabel = _normalizeLocationLabel(locationLabel);
  final aliasLocationLabel =
      _planningAreaAliasByLocationLabel[normalizedLocationLabel];
  for (final region in leaderboardMapRegionDemoSnapshots) {
    final normalizedRegionLabel = _normalizeLocationLabel(region.locationLabel);
    if (normalizedRegionLabel == normalizedLocationLabel ||
        normalizedRegionLabel == aliasLocationLabel) {
      return region.regionId;
    }
  }

  return null;
}

String? leaderboardPlanningAreaNameForLocationLabel(String locationLabel) {
  final normalizedLocationLabel = _normalizeLocationLabel(locationLabel);
  final aliasLocationLabel =
      _planningAreaAliasByLocationLabel[normalizedLocationLabel];
  for (final region in leaderboardMapRegionDemoSnapshots) {
    final normalizedRegionLabel = _normalizeLocationLabel(region.locationLabel);
    if (normalizedRegionLabel == normalizedLocationLabel ||
        normalizedRegionLabel == aliasLocationLabel) {
      return region.planningAreaName;
    }
  }

  return null;
}

String _normalizeLocationLabel(String value) {
  return value.trim().toLowerCase();
}

const _planningAreaAliasByLocationLabel = {
  'central area, singapore': 'downtown core, singapore',
  'tiong bahru, singapore': 'bukit merah, singapore',
};

LeaderboardDetailDisplaySnapshot defaultLeaderboardRegionRankingSnapshot =
    leaderboardRegionalDemoSnapshots.firstWhere((snapshot) {
      return snapshot.isUserRegion;
    });

LeaderboardDetailDisplaySnapshot leaderboardRegionRankingSnapshotById(
  String regionId,
) {
  return leaderboardRegionalDemoSnapshots.firstWhere(
    (snapshot) => snapshot.regionId == regionId,
    orElse: () {
      for (final region in leaderboardMapRegionDemoSnapshots) {
        if (region.regionId == regionId) {
          return _genericLeaderboardRegionRankingSnapshot(region);
        }
      }

      return defaultLeaderboardRegionRankingSnapshot;
    },
  );
}

LeaderboardDetailDisplaySnapshot _genericLeaderboardRegionRankingSnapshot(
  LeaderboardMapRegionDisplaySnapshot region,
) {
  return LeaderboardDetailDisplaySnapshot(
    regionId: region.regionId,
    regionName: region.regionName,
    isUserRegion: false,
    periodLabel: leaderboardDetailDemoSnapshot.periodLabel,
    fallbackPeriodLabel: leaderboardDetailDemoSnapshot.fallbackPeriodLabel,
    refreshLabel: leaderboardDetailDemoSnapshot.refreshLabel,
    fallbackRefreshLabel: leaderboardDetailDemoSnapshot.fallbackRefreshLabel,
    monthlyResetLabel: leaderboardDetailDemoSnapshot.monthlyResetLabel,
    divisionLabel: leaderboardDetailDemoSnapshot.divisionLabel,
    topRanksTitle: leaderboardDetailDemoSnapshot.topRanksTitle,
    nearbyRanksTitle: leaderboardDetailDemoSnapshot.nearbyRanksTitle,
    currentUser: leaderboardDetailDemoSnapshot.currentUser,
    topRanks: leaderboardDetailDemoSnapshot.topRanks,
    nearbyRanks: const [],
  );
}
