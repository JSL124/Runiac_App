import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/core/widgets/runiac_share_bottom_sheet.dart';
import 'package:runiac_app/features/account/domain/singapore_region_options.dart';
import 'package:runiac_app/features/leaderboard/domain/models/leaderboard_read_model.dart';
import 'package:runiac_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:runiac_app/features/leaderboard/presentation/data/leaderboard_demo_snapshots.dart';
import 'package:runiac_app/features/leaderboard/presentation/leaderboard_tab.dart';
import 'package:runiac_app/features/leaderboard/presentation/models/leaderboard_display_models.dart';
import 'package:runiac_app/features/leaderboard/presentation/widgets/leaderboard_map_background.dart';

void _useCompactShareSheetSurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

final _isWithinMetricFontRange = allOf(
  greaterThanOrEqualTo(16),
  lessThanOrEqualTo(24),
);

void main() {
  testWidgets('Leaderboard tab displays backend-owned repository rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LeaderboardTab(
          repository: _FakeLeaderboardRepository(
            LeaderboardReadModel(
              regionId: 'jurong-east',
              homeRegionId: 'jurong-east',
              regionLabel: 'Jurong East',
              divisionKey: 'tier_02',
              divisionLabel: 'Bronze League',
              currentRunnerRankLabel: '#2',
              entries: [
                LeaderboardRowReadModel(
                  userId: 'runner-2',
                  displayName: 'Ari S.',
                  rankLabel: '#1',
                  scoreLabel: '1,480 XP',
                  levelLabel: 'Level 19',
                  divisionLabel: 'Bronze',
                  regionLabel: 'Jurong East',
                ),
                LeaderboardRowReadModel(
                  userId: 'runner-1',
                  displayName: 'Jinseo (You)',
                  rankLabel: '#2',
                  scoreLabel: '1,320 XP',
                  levelLabel: 'Level 18',
                  divisionLabel: 'Bronze',
                  regionLabel: 'Jurong East',
                ),
              ],
              nearbyEntries: const [
                LeaderboardRowReadModel(
                  userId: 'runner-1',
                  displayName: 'Jinseo (You)',
                  rankLabel: '#2',
                  scoreLabel: '1,320 XP',
                  levelLabel: 'Level 18',
                  divisionLabel: 'Bronze League',
                  regionLabel: 'Jurong East',
                  isCurrentUser: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ari S.'), findsOneWidget);
    expect(find.text('1,480 XP'), findsOneWidget);
    expect(find.text('Jinseo (You)'), findsWidgets);
    expect(find.text('1,320 XP'), findsWidgets);
    expect(find.text('Alex T.'), findsNothing);
  });

  testWidgets('Leaderboard tab refreshes reads when countdown has ended', (
    WidgetTester tester,
  ) async {
    final repository = _QueuedLeaderboardRepository([
      LeaderboardReadModel(
        regionLabel: 'Jurong East',
        currentRunnerRankLabel: '#1',
        periodEndsAt: DateTime.utc(2026, 7, 31, 16),
        entries: const [
          LeaderboardRowReadModel(
            userId: 'runner-old',
            displayName: 'Old Rank',
            rankLabel: '#1',
            scoreLabel: '900 XP',
            levelLabel: 'Level 9',
          ),
        ],
      ),
      LeaderboardReadModel(
        regionLabel: 'Jurong East',
        currentRunnerRankLabel: '#1',
        entries: const [
          LeaderboardRowReadModel(
            userId: 'runner-new',
            displayName: 'New Rank',
            rankLabel: '#1',
            scoreLabel: '1,100 XP',
            levelLabel: 'Level 11',
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: LeaderboardTab(
          repository: repository,
          clock: () => DateTime.utc(2026, 7, 31, 16),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.loadCount, 2);
    expect(find.text('New Rank'), findsWidgets);
    expect(find.text('Old Rank'), findsNothing);
  });

  testWidgets('Leaderboard tab shows static map-first landing shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Runiac'), findsNothing);
    expect(find.text('Weekly XP'), findsNothing);
    expect(find.text('Monthly XP'), findsNothing);
    expect(find.text('Bronze'), findsOneWidget);
    expect(find.text('Lv.11 - Lv.20'), findsOneWidget);
    expect(
      find.byKey(const Key('leaderboard_current_league_emblem')),
      findsOneWidget,
    );
    expect(find.textContaining('Division'), findsNothing);
    expect(find.text('Your ranked area'), findsOneWidget);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Feed'), findsOneWidget);
    expect(find.byTooltip('Run'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('You'), findsOneWidget);
    expect(find.text('Jurong East'), findsOneWidget);
    expect(find.text('Weekly XP · Bronze'), findsNothing);
    expect(
      find.byKey(const ValueKey('leaderboard_region_accent_strip')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('leaderboard_sheet_handle_area'))),
      const Size(768, 46),
    );
    expect(
      tester.getSize(find.byKey(const Key('leaderboard_sheet_handle'))),
      const Size(44, 5),
    );
    final leaderboardAccentBottom = tester
        .getBottomLeft(
          find.byKey(const ValueKey('leaderboard_region_accent_strip')),
        )
        .dy;
    final leaderboardTitleTop = tester.getTopLeft(find.text('Jurong East')).dy;
    expect(leaderboardTitleTop - leaderboardAccentBottom, closeTo(10, 0.1));
    expect(find.text('Refreshes in 24:14:05:45'), findsOneWidget);
    expect(find.text('Bronze'), findsOneWidget);
    expect(find.text('Region Leaderboard'), findsNothing);
    expect(find.text('Region Preview'), findsNothing);
    expect(find.text('Ranking preview pending'), findsNothing);
    expect(find.text('My Rank Preview'), findsOneWidget);
    expect(find.text('Alex T.'), findsOneWidget);
    expect(find.text('Maya L.'), findsOneWidget);
    expect(find.text('Ryan K.'), findsOneWidget);
    expect(find.text('Jinseo (You)'), findsOneWidget);
    expect(find.text('Level 18'), findsNothing);
    expect(find.text('Level 17'), findsNothing);
    expect(find.text('Level 16'), findsNothing);
    expect(find.text('Level 12'), findsNothing);
    expect(
      find.byKey(const Key('leaderboard_profile_level_badge')),
      findsWidgets,
    );
    expect(find.text('1,240 XP'), findsOneWidget);
    expect(find.text('1,180 XP'), findsOneWidget);
    expect(find.text('1,050 XP'), findsOneWidget);
    expect(find.text('520 XP'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('leaderboard_region_top_rank_row_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_region_top_rank_row_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_region_top_rank_row_2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_region_top_rank_row_3')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_region_my_rank_row_0')),
      findsOneWidget,
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey('leaderboard_region_rank_badge_#1')),
      ),
      tester.getSize(
        find.byKey(const Key('leaderboard_region_current_user_rank_badge')),
      ),
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('leaderboard_region_current_user_rank_badge')),
          )
          .dx,
      tester
          .getTopLeft(
            find.byKey(const ValueKey('leaderboard_region_rank_badge_#1')),
          )
          .dx,
    );
    expect(
      tester
          .getTopLeft(
            find.descendant(
              of: find.byKey(
                const ValueKey('leaderboard_region_my_rank_row_0'),
              ),
              matching: find.byKey(
                const Key('leaderboard_profile_level_badge'),
              ),
            ),
          )
          .dx,
      tester
          .getTopLeft(
            find.descendant(
              of: find.byKey(
                const ValueKey('leaderboard_region_top_rank_row_0'),
              ),
              matching: find.byKey(
                const Key('leaderboard_profile_level_badge'),
              ),
            ),
          )
          .dx,
    );
    expect(
      tester.getTopLeft(find.text('Jinseo (You)')).dx,
      tester.getTopLeft(find.text('Alex T.')).dx,
    );
    expect(
      find.byKey(const Key('leaderboard_region_current_user_row')),
      findsOneWidget,
    );
    final currentUserRowMaterial = tester.widget<Material>(
      find
          .ancestor(
            of: find.byKey(const Key('leaderboard_region_current_user_row')),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(currentUserRowMaterial.color, Colors.transparent);
    expect(
      find.text('Your position will appear after leaderboard data is ready.'),
      findsNothing,
    );
    expect(find.text('View More Ranking'), findsOneWidget);
    expect(find.text('Share My Rank'), findsOneWidget);
    expect(find.byKey(const Key('leaderboard_sheet_handle')), findsOneWidget);
    expect(find.bySemanticsLabel('Leaderboard information'), findsOneWidget);
    expect(find.text('Tips'), findsNothing);

    await tester.drag(
      find.byKey(const Key('leaderboard_sheet_handle')),
      const Offset(0, 420),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('leaderboard_sheet_handle')), findsOneWidget);

    await tester.tap(find.text('Your ranked area'));
    await tester.pumpAndSettle();

    expect(find.text('Region Leaderboard'), findsNothing);
    expect(find.text('View More Ranking'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Leaderboard information'));
    await tester.pumpAndSettle();

    expect(find.text('Tips'), findsOneWidget);
    expect(find.text('Leagues'), findsOneWidget);
    expect(find.text('Board timing'), findsOneWidget);
    expect(find.text('Static sample data'), findsOneWidget);
    expect(
      find.text(
        'Leagues group runners by broad progress bands so the board feels fair and beginner-friendly.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'This static preview keeps one monthly board context for a calmer comparison.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Leaderboard values shown here are display-only sample rows for this UI milestone.',
      ),
      findsOneWidget,
    );

    expect(find.text('Community motivation'), findsNothing);
    expect(find.text('No live ranking data yet'), findsNothing);
    expect(find.text('Top 3 Runners'), findsNothing);

    await tester.tap(find.byTooltip('Close tips'));
    await tester.pumpAndSettle();

    expect(find.text('Tips'), findsNothing);
    expect(find.text('Leagues'), findsNothing);
    expect(find.text('Bronze'), findsOneWidget);
    expect(find.text('Region Leaderboard'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open leagues list'));
    await tester.pumpAndSettle();

    expect(find.text('Leagues'), findsOneWidget);
    expect(find.text('Challenger (Lv.91 - Lv.100)'), findsOneWidget);
    expect(find.text('Grandmaster (Lv.81 - Lv.90)'), findsOneWidget);
    expect(find.text('Master (Lv.71 - Lv.80)'), findsOneWidget);
    expect(find.text('Diamond (Lv.61 - Lv.70)'), findsOneWidget);
    expect(find.text('Emerald (Lv.51 - Lv.60)'), findsOneWidget);
    expect(find.text('Platinum (Lv.41 - Lv.50)'), findsOneWidget);
    expect(find.text('Gold (Lv.31 - Lv.40)'), findsOneWidget);
    expect(find.text('Silver (Lv.21 - Lv.30)'), findsOneWidget);
    expect(find.text('Bronze (Lv.11 - Lv.20)'), findsOneWidget);
    expect(find.text('Iron (Lv.1 - Lv.10)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('leaderboard_league_emblem_Challenger')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_league_emblem_Bronze')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('leaderboard_league_emblem_Iron')),
      findsOneWidget,
    );
    expect(find.textContaining('Division'), findsNothing);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Feed'), findsOneWidget);
    expect(find.byTooltip('Run'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('You'), findsOneWidget);
    expect(find.textContaining('Current'), findsNothing);
    expect(find.textContaining('current'), findsNothing);
    expect(find.textContaining('Selected'), findsNothing);
    expect(find.textContaining('selected'), findsNothing);
    expect(find.textContaining('Unlocked'), findsNothing);
    expect(find.textContaining('unlocked'), findsNothing);
    expect(find.textContaining('Earned'), findsNothing);
    expect(find.textContaining('earned'), findsNothing);

    await tester.tap(find.byTooltip('Close leagues'));
    await tester.pumpAndSettle();

    expect(find.text('Leagues'), findsNothing);
    expect(find.text('Bronze'), findsOneWidget);
    expect(find.text('Lv.11 - Lv.20'), findsOneWidget);
    expect(find.text('Region Leaderboard'), findsNothing);
  });

  testWidgets('Leaderboard preview rank rows open runner profiles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('leaderboard_region_top_rank_row_0')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Runner profile'), findsOneWidget);
    expect(find.text('Alex T.'), findsOneWidget);
    expect(find.text('Jurong East · Rank #1'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Rankings'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('leaderboard_region_my_rank_row_0')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Runner profile'), findsOneWidget);
    expect(find.text('Jinseo (You)'), findsOneWidget);
    expect(find.text('Jurong East · Rank #18'), findsOneWidget);
    expect(find.text('520 XP'), findsNothing);
  });

  testWidgets(
    'Leaderboard regional map defaults to the user region and exposes region polygons',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      await tester.tap(find.byTooltip('Leaderboard'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('leaderboard_planning_area_touch_jurong-east')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('leaderboard_planning_area_touch_tampines')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('leaderboard_planning_area_touch_woodlands')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('leaderboard_planning_area_touch_ang-mo-kio')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('leaderboard_planning_area_touch_newton')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('leaderboard_planning_area_touch_museum')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('leaderboard_planning_area_touch_singapore-river'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('leaderboard_user_planning_area_highlight')),
        findsOneWidget,
      );
      expect(find.text('Jurong East'), findsOneWidget);
      expect(find.text('My Rank Preview'), findsOneWidget);
      expect(find.text('Share My Rank'), findsOneWidget);
      expect(find.text('View More Ranking'), findsOneWidget);
    },
  );

  testWidgets(
    'Leaderboard planning-area map exposes app region polygons and highlights the user planning area',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      await tester.tap(find.byTooltip('Leaderboard'));
      await tester.pumpAndSettle();

      expect(leaderboardPlanningAreaGeoJsonAsset, contains('2025'));
      expect(leaderboardPlanningAreaLabelLayerId, contains('label'));
      expect(
        leaderboardMapRegionDemoSnapshots
            .map((region) => region.color.toARGB32())
            .toSet(),
        hasLength(leaderboardMapRegionDemoSnapshots.length),
      );
      expect(
        leaderboardMapRegionDemoSnapshots.map((region) => region.regionId),
        containsAll(<String>[
          'jurong-east',
          'museum',
          'newton',
          'singapore-river',
          'tampines',
          'woodlands',
        ]),
      );
      expect(
        leaderboardMapRegionDemoSnapshots.map(
          (region) => region.planningAreaName,
        ),
        containsAll(<String>[
          'JURONG EAST',
          'MUSEUM',
          'NEWTON',
          'SINGAPORE RIVER',
          'TAMPINES',
          'WOODLANDS',
        ]),
      );
      expect(
        leaderboardMapRegionDemoSnapshots
            .where((region) => region.isUserRegion)
            .single
            .regionId,
        'jurong-east',
      );
      expect(
        find.byKey(const Key('leaderboard_user_planning_area_highlight')),
        findsOneWidget,
      );
      final userPlanningAreaHighlight = tester.widget<Container>(
        find.byKey(const Key('leaderboard_user_planning_area_highlight')),
      );
      expect(userPlanningAreaHighlight.constraints?.maxWidth, 34);
      expect(userPlanningAreaHighlight.constraints?.maxHeight, 34);
      final userHighlightDecoration =
          userPlanningAreaHighlight.decoration as BoxDecoration;
      expect(userHighlightDecoration.color, isNotNull);
      expect(userHighlightDecoration.border?.top.color, Colors.white);
      expect(userHighlightDecoration.border?.top.width, 3);
      expect(
        find.byKey(const Key('leaderboard_region_polygon_jurong-east')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('leaderboard_region_polygon_tampines')),
        findsNothing,
      );
    },
  );

  test(
    'Leaderboard planning areas match selectable Singapore regions one-to-one',
    () {
      final mappedRegionIds = <String>{};
      final mappedPlanningAreas = <String>{};
      for (final option in SingaporeRegionOptions.values) {
        final regionId = leaderboardPlanningAreaIdForLocationLabel(option);
        final planningAreaName = leaderboardPlanningAreaNameForLocationLabel(
          option,
        );

        expect(regionId, isNotNull, reason: '$option needs a map polygon');
        expect(
          planningAreaName,
          isNotNull,
          reason: '$option needs a planning area label',
        );
        expect(
          mappedRegionIds.add(regionId!),
          isTrue,
          reason: '$option must not share a polygon with another option',
        );
        expect(
          mappedPlanningAreas.add(planningAreaName!),
          isTrue,
          reason: '$option must not share a planning area with another option',
        );
      }

      expect(mappedRegionIds, hasLength(SingaporeRegionOptions.values.length));
      expect(
        mappedPlanningAreas,
        hasLength(SingaporeRegionOptions.values.length),
      );
      expect(
        leaderboardMapRegionDemoSnapshots,
        hasLength(SingaporeRegionOptions.values.length),
      );

      expect(
        leaderboardRegionRankingSnapshotById('not-a-supported-region').regionId,
        'jurong-east',
      );
      expect(
        leaderboardRegionRankingSnapshotById('newton').regionName,
        'Newton',
      );
      expect(
        leaderboardRegionRankingSnapshotById('newton').isUserRegion,
        false,
      );
      expect(
        leaderboardRegionRankingSnapshotById('museum').regionName,
        'Museum',
      );
      expect(
        leaderboardRegionRankingSnapshotById('singapore-river').regionName,
        'Singapore River',
      );
    },
  );

  testWidgets(
    'Leaderboard non-user region hides personal actions and opens selected monthly detail',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const RuniacApp(showSplash: false, enableForegroundGps: false),
      );

      await tester.tap(find.byTooltip('Leaderboard'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('leaderboard_sheet_handle')),
        const Offset(0, 420),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('leaderboard_planning_area_touch_tampines')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tampines'), findsOneWidget);
      expect(find.text('My Rank Preview'), findsNothing);
      expect(find.text('Share My Rank'), findsNothing);
      expect(
        find.byKey(const Key('leaderboard_share_my_rank_button')),
        findsNothing,
      );

      final sheetWidth = tester
          .getSize(find.byKey(const Key('leaderboard_sheet_surface')))
          .width;
      final sheetHeight = tester
          .getSize(find.byKey(const Key('leaderboard_sheet_surface')))
          .height;
      final viewMoreWidth = tester
          .getSize(
            find.byKey(const Key('leaderboard_view_more_ranking_button')),
          )
          .width;
      expect(sheetHeight, lessThan(410));
      expect(viewMoreWidth, greaterThan(sheetWidth * 0.84));

      await tester.tap(
        find.byKey(const Key('leaderboard_view_more_ranking_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back to Leaderboard'), findsOneWidget);
      expect(find.text('Tampines'), findsOneWidget);
      expect(find.text('July 2026'), findsOneWidget);
      expect(find.textContaining('Refreshes in'), findsOneWidget);
      expect(
        find.text(
          'Monthly gained XP resets to 0 XP next month. Your level stays the same.',
        ),
        findsOneWidget,
      );
      expect(find.text('You · Monthly ranking preview'), findsNothing);
      expect(find.text('NEARBY YOUR RANK'), findsNothing);
    },
  );

  testWidgets('Leaderboard visible region polygons select matching snapshots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();

    for (final region in <({String id, String title})>[
      (id: 'woodlands', title: 'Woodlands'),
      (id: 'tampines', title: 'Tampines'),
      (id: 'ang-mo-kio', title: 'Ang Mo Kio'),
      (id: 'newton', title: 'Newton'),
      (id: 'museum', title: 'Museum'),
      (id: 'singapore-river', title: 'Singapore River'),
    ]) {
      await tester.drag(
        find.byKey(const Key('leaderboard_sheet_handle')),
        const Offset(0, 420),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(Key('leaderboard_planning_area_touch_${region.id}')),
      );
      await tester.pumpAndSettle();

      expect(find.text(region.title), findsOneWidget);
      expect(find.text('My Rank Preview'), findsNothing);
      expect(
        find.byKey(const Key('leaderboard_share_my_rank_button')),
        findsNothing,
      );
    }
  });

  testWidgets('Share My Rank opens floating share card panel', (
    WidgetTester tester,
  ) async {
    _useCompactShareSheetSurface(tester);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == 'Clipboard.setData') {
        return null;
      }

      return null;
    });

    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('leaderboard_share_my_rank_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('leaderboard_share_rank_panel')),
      findsOneWidget,
    );
    expect(find.text('Share your rank'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Share your rank')).dx,
      moreOrLessEquals(
        tester
            .getCenter(find.byKey(const Key('leaderboard_share_rank_panel')))
            .dx,
        epsilon: 2,
      ),
    );
    expect(
      find.byKey(const Key('leaderboard_share_rank_card_background')),
      findsOneWidget,
    );
    final sheetRect = tester.getRect(
      find.byKey(const Key('leaderboard_share_rank_panel')),
    );
    final cardRect = tester.getRect(
      find.byKey(const Key('leaderboard_share_rank_card_background')),
    );
    final titleRect = tester.getRect(find.text('Share your rank'));
    final shareToRect = tester.getRect(find.text('SHARE TO'));
    expect(cardRect.width, greaterThanOrEqualTo(sheetRect.width * 0.86));
    expect(cardRect.top - titleRect.bottom, lessThanOrEqualTo(84));
    expect(shareToRect.top - cardRect.bottom, lessThanOrEqualTo(72));
    expect(find.text('Jurong East'), findsWidgets);
    expect(find.text('Bronze'), findsWidgets);
    expect(find.text('#'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(
      find.byKey(const Key('leaderboard_share_rank_page_indicator')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('leaderboard_share_rank_panel')),
        matching: find.image(
          const AssetImage('assets/icons/instagram_stories.png'),
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('leaderboard_share_rank_panel')),
        matching: find.text('520 XP'),
      ),
      findsNothing,
    );
    expect(find.byType(RuniacShareBottomSheet), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Close'), findsOneWidget);
    expect(find.text('SHARE TO'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('Copy to Clipboard'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    await tester.tap(find.byKey(const Key('leaderboard_copy_rank_action')));
    await tester.pump();
    expect(find.text('Rank copied to clipboard'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('leaderboard_share_rank_panel')), findsNothing);
  });

  testWidgets('View More Ranking opens static monthly detail board', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('leaderboard_view_more_ranking_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back to Leaderboard'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.text('Jurong East'), findsOneWidget);
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.text('Monthly board'), findsNothing);
    expect(find.text('Refreshes in 24:14:05:45'), findsOneWidget);
    expect(find.text('Refreshes in 12 days'), findsNothing);
    expect(find.text('Refreshes in 24D : 14H : 05M : 45S'), findsNothing);
    expect(find.text('24:14:05:45'), findsNothing);
    expect(find.text('Bronze'), findsOneWidget);
    expect(find.text('Weekly XP'), findsNothing);
    expect(find.text('Monthly XP'), findsNothing);
    expect(find.text('Regional ranking'), findsOneWidget);
    expect(find.text('NEARBY YOUR RANK'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('leaderboard_detail_header_accent_strip')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('leaderboard_detail_header_accent_strip'),
            ),
          )
          .width,
      greaterThan(650),
    );

    for (var index = 0; index < 10; index++) {
      expect(
        find.byKey(ValueKey('leaderboard_detail_top_rank_row_$index')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const ValueKey('leaderboard_detail_top_rank_row_10')),
      findsNothing,
    );
    for (var index = 0; index < 3; index++) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('leaderboard_detail_top_rank_row_$index')),
          matching: find.byIcon(Icons.emoji_events_outlined),
        ),
        findsOneWidget,
      );
    }
    expect(find.text('#2'), findsNothing);
    expect(find.text('#3'), findsNothing);

    for (var index = 0; index < 5; index++) {
      expect(
        find.byKey(ValueKey('leaderboard_detail_nearby_rank_row_$index')),
        findsOneWidget,
      );
    }
    expect(find.text('Alex T.'), findsOneWidget);
    expect(find.text('Grace L.'), findsOneWidget);
    expect(find.text('Daniel W.'), findsOneWidget);
    expect(find.text('Jinseo (You)'), findsOneWidget);
    expect(find.text('#18'), findsOneWidget);
    expect(find.text('520 XP'), findsOneWidget);
    expect(
      find.byKey(const Key('leaderboard_detail_current_user_row')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('leaderboard_current_user_floating_bar')),
      findsNothing,
    );
    expect(find.text('You · Monthly ranking preview'), findsNothing);
    expect(find.textContaining('to reach'), findsNothing);
    expect(find.textContaining('progress'), findsNothing);
    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Feed'), findsOneWidget);
    expect(find.byTooltip('Run'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('You'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Region Leaderboard'), findsNothing);
    expect(find.text('View More Ranking'), findsOneWidget);
    expect(find.text('Monthly board'), findsNothing);
  });

  testWidgets('Leaderboard rows open read-only runner achievement profiles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('leaderboard_view_more_ranking_button')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('leaderboard_detail_top_rank_row_0')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Runner profile'), findsOneWidget);
    expect(find.text('PUBLIC'), findsNothing);
    expect(find.text('Alex T.'), findsOneWidget);
    expect(find.text('Jurong East · Rank #1'), findsOneWidget);
    expect(find.text('Bronze · Level 18'), findsOneWidget);
    expect(
      find.byKey(const Key('runner_profile_total_distance_metric')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('runner_profile_best_streak_metric')),
      findsOneWidget,
    );
    expect(find.text('Not shared'), findsNWidgets(2));
    expect(find.text('Total distance'), findsOneWidget);
    expect(find.text('Total distance (km)'), findsNothing);
    expect(find.text('Best streak'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('0 earned'), findsOneWidget);
    expect(find.text('First 5K'), findsNothing);
    expect(
      find.text('Only monthly ranking details are shown.'),
      findsOneWidget,
    );
    expect(find.text('Experience'), findsNothing);
    expect(find.text('1,240 XP'), findsNothing);
    expect(find.byKey(const Key('runner_profile_level_metric')), findsNothing);
    expect(find.text('Recent Public Achievements'), findsNothing);
    expect(find.textContaining('GPS'), findsNothing);
    expect(find.textContaining('pace'), findsNothing);
    expect(find.textContaining('calories'), findsNothing);
    expect(find.textContaining('premium'), findsNothing);

    await tester.tap(find.byTooltip('Back to Rankings'));
    await tester.pumpAndSettle();

    expect(find.text('Regional ranking'), findsOneWidget);

    final nearbyRow = find.byKey(
      const ValueKey('leaderboard_detail_nearby_rank_row_1'),
    );
    await tester.ensureVisible(nearbyRow);
    await tester.pumpAndSettle();
    await tester.tap(nearbyRow);
    await tester.pumpAndSettle();

    expect(find.text('Runner profile'), findsOneWidget);
    expect(find.text('Daniel W.'), findsOneWidget);
    expect(find.text('Jurong East · Rank #17'), findsOneWidget);
    expect(find.text('640 XP'), findsNothing);

    await tester.tap(find.byTooltip('Back to Rankings'));
    await tester.pumpAndSettle();

    final currentUserRow = find.byKey(
      const ValueKey('leaderboard_detail_nearby_rank_row_2'),
    );
    await tester.ensureVisible(currentUserRow);
    await tester.pumpAndSettle();
    await tester.tap(currentUserRow);
    await tester.pumpAndSettle();

    expect(find.text('Runner profile'), findsOneWidget);
    expect(find.text('Jinseo (You)'), findsOneWidget);
    expect(find.text('Jurong East · Rank #18'), findsOneWidget);
    expect(find.text('520 XP'), findsNothing);
    expect(find.byTooltip('You'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Rankings'));
    await tester.pumpAndSettle();

    expect(find.text('Runner profile'), findsNothing);
    expect(find.text('Regional ranking'), findsOneWidget);
  });

  test('Leaderboard source isolates static display snapshots', () {
    final uiSource = File(
      'lib/features/leaderboard/presentation/leaderboard_tab.dart',
    ).readAsStringSync();
    final runnerProfileSource = File(
      'lib/features/leaderboard/presentation/widgets/runner_achievement_profile_screen.dart',
    ).readAsStringSync();
    final modelSource = File(
      'lib/features/leaderboard/presentation/models/leaderboard_display_models.dart',
    ).readAsStringSync();
    final demoSource = File(
      'lib/features/leaderboard/presentation/data/leaderboard_demo_snapshots.dart',
    ).readAsStringSync();
    final source = '$uiSource\n$runnerProfileSource\n$modelSource\n$demoSource';

    expect(modelSource, contains('class LeaderboardPreviewSnapshot'));
    expect(modelSource, contains('class LeaderboardLeagueSnapshot'));
    expect(modelSource, contains('class LeaderboardRegionSnapshot'));
    expect(modelSource, contains('class LeaderboardDetailDisplaySnapshot'));
    expect(modelSource, contains('class LeaderboardRankRowDisplaySnapshot'));
    expect(modelSource, contains('class RunnerAchievementProfileSnapshot'));
    expect(modelSource, contains('class RunnerAchievementBadgeSnapshot'));
    expect(modelSource, contains('enum RegionPreviewMedalTone'));
    expect(modelSource, contains('class LeagueTaxonomyEntry'));
    expect(runnerProfileSource, contains('class RunnerMetricValueText'));
    expect(demoSource, contains('const leaderboardPreviewDemoSnapshot'));
    expect(demoSource, contains('const leaderboardLeagueDemoSnapshot'));
    expect(demoSource, contains('const leaderboardRegionDemoSnapshot'));
    expect(demoSource, contains('const leaderboardDetailDemoSnapshot'));
    expect(demoSource, contains('leaderboardLeagueChallenger'));
    expect(demoSource, contains('leaderboardLeagueBronze'));
    expect(demoSource, contains('leaderboardLeagueIron'));
    expect(demoSource, contains('periodLabel: \'July 2026\''));
    expect(demoSource, contains('fallbackPeriodLabel: \'Monthly board\''));
    expect(demoSource, contains('Refreshes in 24:14:05:45'));
    expect(demoSource, contains('Refreshes in 00:00:00:00'));
    expect(uiSource, isNot(contains('const leaderboardPreviewDemoSnapshot')));
    expect(uiSource, isNot(contains('const leaderboardLeagueDemoSnapshot')));
    expect(uiSource, isNot(contains('const leaderboardRegionDemoSnapshot')));
    expect(uiSource, isNot(contains('const leaderboardDetailDemoSnapshot')));

    for (final forbidden in [
      'calculateRank',
      'calculateScore',
      'calculateXP',
      'deriveDivision',
      'deriveNearbyRanks',
      'sortLeaderboard',
      'aggregateWeeklyXp',
      'daysUntilMonthlyReset',
      'calculateRefresh',
      'calculateLevel',
      'calculateStreak',
      'calculateTotalDistance',
      'calculateAchievements',
      'deriveAchievement',
      'DateTime.now',
      'Timer.periodic',
      'nextRefreshAt',
      'monthEnd',
      'tickCountdown',
      'currentYear',
      'currentMonth',
      'DateFormat',
      'reformatMetric',
      'roundMetric',
      'capMetric',
      'shortenMetric',
    ]) {
      expect(source, isNot(contains(forbidden)));
    }

    final metricValueStart = runnerProfileSource.indexOf(
      'class RunnerMetricValueText',
    );
    final metricValueEnd = runnerProfileSource.indexOf(
      'class _RunnerAchievementsSection',
      metricValueStart,
    );
    final metricValueSource = runnerProfileSource.substring(
      metricValueStart,
      metricValueEnd,
    );

    expect(metricValueSource, contains('minFontSize = 16'));
    expect(metricValueSource, isNot(contains('TextOverflow.ellipsis')));
  });

  test('Runner metric value font size adapts without changing labels', () {
    expect(
      resolveRunnerMetricValueFontSize(value: '10000 km', maxWidth: 240),
      _isWithinMetricFontRange,
    );
    expect(
      resolveRunnerMetricValueFontSize(value: '365 days', maxWidth: 240),
      _isWithinMetricFontRange,
    );
    expect(
      resolveRunnerMetricValueFontSize(value: '10000 km', maxWidth: 72),
      greaterThanOrEqualTo(16),
    );
  });

  test('Leaderboard period label falls back without date derivation', () {
    expect(
      resolveLeaderboardPeriodLabelForDisplay(
        periodLabel: 'July 2026',
        fallbackPeriodLabel: 'Monthly board',
      ),
      'July 2026',
    );
    expect(
      resolveLeaderboardPeriodLabelForDisplay(
        periodLabel: '',
        fallbackPeriodLabel: 'Monthly board',
      ),
      'Monthly board',
    );
    expect(
      resolveLeaderboardPeriodLabelForDisplay(
        periodLabel: '   ',
        fallbackPeriodLabel: 'Monthly board',
      ),
      'Monthly board',
    );
  });

  testWidgets('Leaderboard static labels do not expose owned totals', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.byTooltip('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Weekly XP'), findsNothing);
    expect(find.text('Monthly XP'), findsNothing);
    expect(find.text('1,240 XP'), findsOneWidget);
    expect(find.text('1,180 XP'), findsOneWidget);
    expect(find.text('1,050 XP'), findsOneWidget);
    expect(find.text('520 XP'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'rank\s*#', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('score', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('points', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('calculated', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('eligible', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('premium advantage', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('subscription', caseSensitive: false)),
      findsNothing,
    );
  });
}

class _FakeLeaderboardRepository implements LeaderboardRepository {
  const _FakeLeaderboardRepository(this.model);

  final LeaderboardReadModel model;

  @override
  Future<LeaderboardReadModel> loadLeaderboard() async {
    return model;
  }

  @override
  Future<LeaderboardReadModel> loadRegion({required String regionId}) async {
    return model;
  }
}

class _QueuedLeaderboardRepository implements LeaderboardRepository {
  _QueuedLeaderboardRepository(this.models);

  final List<LeaderboardReadModel> models;
  int loadCount = 0;

  @override
  Future<LeaderboardReadModel> loadLeaderboard() async {
    final index = loadCount >= models.length ? models.length - 1 : loadCount;
    loadCount += 1;
    return models[index];
  }

  @override
  Future<LeaderboardReadModel> loadRegion({required String regionId}) {
    return loadLeaderboard();
  }
}
