import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/leaderboard/domain/models/leaderboard_read_model.dart';
import 'package:runiac_app/features/leaderboard/presentation/leaderboard_status_copy.dart';
import 'package:runiac_app/features/leaderboard/presentation/models/leaderboard_display_models.dart';
import 'package:runiac_app/features/leaderboard/presentation/widgets/leaderboard_ranking_screen.dart';

RunnerAchievementProfileSnapshot _profile(
  String name, {
  bool isCurrentUser = false,
}) {
  return RunnerAchievementProfileSnapshot(
    name: name,
    initial: name.characters.first,
    regionRankLabel: '$name rank',
    levelBadgeLabel: 'Lv.10',
    divisionLevelLabel: 'Bronze · Level 10',
    totalDistanceLabel: '100 km',
    bestStreakLabel: '5 days',
    badges: const [],
    isCurrentUser: isCurrentUser,
  );
}

LeaderboardRankRowDisplaySnapshot _row(
  String rankLabel,
  String name, {
  bool isCurrentUser = false,
  RegionPreviewMedalTone? tone,
}) {
  return LeaderboardRankRowDisplaySnapshot(
    rankLabel: rankLabel,
    name: name,
    levelLabel: 'Level 10',
    levelBadgeLabel: 'Lv.10',
    xpLabel: '100 XP',
    profile: _profile(name, isCurrentUser: isCurrentUser),
    isCurrentUser: isCurrentUser,
    medalTone: tone,
  );
}

LeaderboardDetailDisplaySnapshot _snapshot({
  List<LeaderboardRankRowDisplaySnapshot> topRanks = const [],
  List<LeaderboardRankRowDisplaySnapshot> nearbyRanks = const [],
  bool isUserRegion = true,
  LeaderboardReadStatus status = LeaderboardReadStatus.data,
  bool hasCurrentUserRank = true,
}) {
  return LeaderboardDetailDisplaySnapshot(
    regionId: 'jurong-east',
    regionName: 'Jurong East',
    isUserRegion: isUserRegion,
    periodLabel: 'July 2026',
    fallbackPeriodLabel: 'Monthly board',
    refreshLabel: 'Refreshes soon',
    fallbackRefreshLabel: 'Refreshes soon',
    monthlyResetLabel: 'Monthly XP resets next month.',
    divisionLabel: 'Bronze',
    topRanksTitle: 'Regional ranking',
    nearbyRanksTitle: 'Ranks near you',
    currentUser: const CurrentUserRankSummaryDisplaySnapshot(
      rankLabel: '#1',
      title: 'You',
      xpLabel: '100 XP',
    ),
    topRanks: topRanks,
    nearbyRanks: nearbyRanks,
    status: status,
    hasCurrentUserRank: hasCurrentUserRank,
  );
}

Widget _app(LeaderboardDetailDisplaySnapshot snapshot) {
  return MaterialApp(
    home: Scaffold(body: LeaderboardRankingScreen(snapshot: snapshot)),
  );
}

const _rank1Key = ValueKey('leaderboard_podium_rank_1');
const _rank2Key = ValueKey('leaderboard_podium_rank_2');
const _rank3Key = ValueKey('leaderboard_podium_rank_3');
const _crownKey = Key('leaderboard_podium_crown');

void main() {
  testWidgets(
    'three entries render podium keys, crown, and a larger #1 avatar',
    (tester) async {
      await tester.pumpWidget(
        _app(
          _snapshot(
            topRanks: [
              _row('#1', 'Alex', tone: RegionPreviewMedalTone.gold),
              _row('#2', 'Maya', tone: RegionPreviewMedalTone.silver),
              _row('#3', 'Ryan', tone: RegionPreviewMedalTone.bronze),
            ],
          ),
        ),
      );

      expect(find.byKey(_rank1Key), findsOneWidget);
      expect(find.byKey(_rank2Key), findsOneWidget);
      expect(find.byKey(_rank3Key), findsOneWidget);
      expect(find.byKey(_crownKey), findsOneWidget);

      final firstAvatar = tester.getSize(
        find.byKey(const ValueKey('leaderboard_podium_avatar_1')),
      );
      final secondAvatar = tester.getSize(
        find.byKey(const ValueKey('leaderboard_podium_avatar_2')),
      );
      expect(firstAvatar.width, greaterThan(secondAvatar.width));
    },
  );

  testWidgets('two entries omit the rank-3 podium slot', (tester) async {
    await tester.pumpWidget(
      _app(
        _snapshot(
          topRanks: [
            _row('#1', 'Alex', tone: RegionPreviewMedalTone.gold),
            _row('#2', 'Maya', tone: RegionPreviewMedalTone.silver),
          ],
        ),
      ),
    );

    expect(find.byKey(_rank1Key), findsOneWidget);
    expect(find.byKey(_rank2Key), findsOneWidget);
    expect(find.byKey(_rank3Key), findsNothing);
  });

  testWidgets('single entry renders only the rank-1 podium slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _snapshot(
          topRanks: [_row('#1', 'Alex', tone: RegionPreviewMedalTone.gold)],
        ),
      ),
    );

    expect(find.byKey(_rank1Key), findsOneWidget);
    expect(find.byKey(_rank2Key), findsNothing);
    expect(find.byKey(_rank3Key), findsNothing);
    expect(find.byKey(_crownKey), findsOneWidget);
  });

  testWidgets(
    'empty status renders friendly empty state without podium or error',
    (tester) async {
      await tester.pumpWidget(
        _app(_snapshot(status: LeaderboardReadStatus.empty)),
      );

      expect(find.byKey(const Key('leaderboard_empty_state')), findsOneWidget);
      expect(find.text(leaderboardEmptyStateTitle), findsOneWidget);
      expect(find.byKey(_rank1Key), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    },
  );

  testWidgets('only the current-user row carries the highlight key and fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _snapshot(
          topRanks: [
            _row('#1', 'Alex', tone: RegionPreviewMedalTone.gold),
            _row('#2', 'Maya', tone: RegionPreviewMedalTone.silver),
            _row('#3', 'Ryan', tone: RegionPreviewMedalTone.bronze),
          ],
          nearbyRanks: [
            _row('#17', 'Dan'),
            _row('#18', 'You', isCurrentUser: true),
            _row('#19', 'Noah'),
          ],
        ),
      ),
    );

    final currentUserRow = find.byKey(
      const Key('leaderboard_detail_current_user_row'),
    );
    expect(currentUserRow, findsOneWidget);
    expect(
      find.byKey(const ValueKey('leaderboard_detail_top_rank_row_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_detail_nearby_rank_row_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_detail_nearby_rank_row_2')),
      findsOneWidget,
    );

    // The original rank-row design paints the current-user highlight on the
    // enclosing Material, not on the keyed layout Container.
    final material = tester.widget<Material>(
      find.ancestor(of: currentUserRow, matching: find.byType(Material)).first,
    );
    expect(material.color, const Color(0xFFFFF1EA));
  });

  testWidgets('page never renders Daily or Weekly labels', (tester) async {
    await tester.pumpWidget(
      _app(
        _snapshot(
          topRanks: [
            _row('#1', 'Alex', tone: RegionPreviewMedalTone.gold),
            _row('#2', 'Maya', tone: RegionPreviewMedalTone.silver),
            _row('#3', 'Ryan', tone: RegionPreviewMedalTone.bronze),
          ],
          nearbyRanks: [_row('#18', 'You', isCurrentUser: true)],
        ),
      ),
    );

    expect(find.text('Daily'), findsNothing);
    expect(find.text('Weekly'), findsNothing);
  });

  testWidgets('renders on a 320px-wide surface without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        _snapshot(
          topRanks: [
            _row('#1', 'Alexandra P.', tone: RegionPreviewMedalTone.gold),
            _row('#2', 'Maya Lawrence', tone: RegionPreviewMedalTone.silver),
            _row('#3', 'Ryan Kowalski', tone: RegionPreviewMedalTone.bronze),
          ],
          nearbyRanks: [
            _row('#17', 'Daniel Whitmore'),
            _row('#18', 'Jinseo (You)', isCurrentUser: true),
            _row('#19', 'Noah Kingston'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unranked home region shows encouragement instead of ranking rows',
    (tester) async {
      await tester.pumpWidget(
        _app(
          _snapshot(
            topRanks: [
              _row('#1', 'Alex', tone: RegionPreviewMedalTone.gold),
              _row('#2', 'Maya', tone: RegionPreviewMedalTone.silver),
              _row('#3', 'Ryan', tone: RegionPreviewMedalTone.bronze),
            ],
            nearbyRanks: [_row('#18', 'Someone')],
            hasCurrentUserRank: false,
          ),
        ),
      );

      expect(find.text(leaderboardUnrankedBody), findsOneWidget);
      // The regional ranking card stays visible; only the nearby list is
      // replaced by the encouragement card while unranked.
      expect(
        find.byKey(const ValueKey('leaderboard_detail_top_rank_row_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('leaderboard_detail_nearby_rank_row_0')),
        findsNothing,
      );
    },
  );
}
