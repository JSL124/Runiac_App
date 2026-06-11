import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';
import 'package:runiac_app/core/theme/runiac_colors.dart';
import 'package:runiac_app/core/widgets/runiac_share_bottom_sheet.dart';
import 'package:runiac_app/features/leaderboard/presentation/leaderboard_tab.dart';
import 'package:runiac_app/features/run/presentation/advanced_analysis_screen.dart';
import 'package:runiac_app/features/run/presentation/cool_down_guide_screen.dart';
import 'package:runiac_app/features/run/presentation/cool_down_screen.dart';
import 'package:runiac_app/features/run/presentation/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/presentation/models/xp_update_display_model.dart';
import 'package:runiac_app/features/run/presentation/view_summary_screen.dart';
import 'package:runiac_app/features/run/presentation/widgets/share_achievement_sheet.dart';
import 'package:runiac_app/features/run/presentation/xp_update_screen.dart';

final _forbiddenBackendOwnedCopy = RegExp(
  r'\bXP\b|streak|level|rank|score|saved count|popularity|owned|'
  r'territory owned|route completed|activity saved|synced|premium|'
  r'subscription',
  caseSensitive: false,
);

final _isWithinMetricFontRange = allOf(
  greaterThanOrEqualTo(16),
  lessThanOrEqualTo(24),
);

final _forbiddenRunCompletionCopy = RegExp(
  r'XP|streak|Leaderboard|Activity saved|Saved activity|activity saved|'
  r'saved activity|backend completion|backend-completion|completed run|'
  r'run completed',
  caseSensitive: false,
);

final _forbiddenRealActivitySaveCopy = RegExp(
  r'Activity saved|Saved activity|activity saved|saved activity|'
  r'backend completion|backend-completion|completed run|run completed|'
  r'synced|uploaded',
  caseSensitive: false,
);

final _forbiddenXpUpdateCompetitiveCopy = RegExp(
  r'leaderboard|rank|ranking|percentile|beat others|division',
  caseSensitive: false,
);

void _useCompactShareSheetSurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void _useTallSummarySurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(800, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _shareSheetHarness() {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return Center(
            child: FilledButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withValues(alpha: 0.48),
                  builder: (context) => const ShareAchievementSheet(),
                );
              },
              child: const Text('Open share sheet'),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _openPausedRun(WidgetTester tester) async {
  await tester.pumpWidget(const RuniacApp());

  await tester.tap(find.text('Run'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start run'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pause'));
  await tester.pumpAndSettle();
}

Future<void> _completeHoldToEnd(WidgetTester tester) async {
  final completedHoldGesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('run_hold_to_end_button'))),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1600));
  await completedHoldGesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Runiac app shell shows static tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('Home dashboard keeps a calm primary quick start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    expect(find.text('Good to see you'), findsOneWidget);
    expect(
      find.text('Your Home dashboard is ready for a calm start.'),
      findsOneWidget,
    );
    expect(find.text('Ready for an easy run?'), findsOneWidget);
    expect(find.text('Start small and keep it comfortable.'), findsOneWidget);
    expect(find.text('View Plan'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);

    await tester.tap(find.text('Quick Start'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Quick Start'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('This Week\'s Plan'), findsOneWidget);
    expect(find.text('Last Run'), findsOneWidget);
    expect(find.text('View Details'), findsNothing);
    expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);
  });

  testWidgets('Maps tab shows static route discovery placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Search routes or parks'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('Beginner-friendly route ideas'), findsNothing);
    expect(find.text('Preview'), findsNothing);
    expect(
      find.text(
        'Start with a gentle preview. Routes stay as placeholders until setup is ready.',
      ),
      findsNothing,
    );
    expect(find.text('Route preview'), findsOneWidget);
    expect(
      find.text('A calm route card can guide the next step later.'),
      findsOneWidget,
    );

    await tester.drag(find.text('Shared Routes'), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('Beginner-friendly route ideas'), findsNothing);
    expect(find.text('Preview'), findsNothing);
    expect(find.text('Shared routes'), findsOneWidget);
    expect(
      find.text('Community route ideas remain review-only for now.'),
      findsOneWidget,
    );

    expect(find.text('Saved routes'), findsOneWidget);
    expect(
      find.text('Saved route slots stay visible without saving data.'),
      findsOneWidget,
    );
    expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);
  });

  testWidgets('Maps search field accepts focus and visible typed input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
    final initialSheetTop = tester.getTopLeft(sheetSurface).dy;
    final searchField = find.byKey(const Key('maps_search_field'));

    expect(find.text('Search routes or parks'), findsOneWidget);
    expect(find.text('Marina Bay'), findsNothing);
    expect(tester.widget<TextField>(searchField).focusNode?.hasFocus, isFalse);

    await tester.tap(searchField);
    await tester.pump();
    await tester.enterText(searchField, 'Marina Bay');
    await tester.pumpAndSettle();

    expect(find.text('Marina Bay'), findsOneWidget);
    final focusedSearchField = tester.widget<TextField>(searchField);

    expect(focusedSearchField.controller?.text, 'Marina Bay');
    expect(focusedSearchField.focusNode?.hasFocus, isTrue);
    expect(tester.getTopLeft(sheetSurface).dy, initialSheetTop);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Show less'), findsNothing);
    expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);
  });

  testWidgets('Maps See all opens scrollable static shared routes state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
    final initialTop = tester.getTopLeft(sheetSurface).dy;
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final initialHeight = tester.getSize(sheetSurface).height;

    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('All shared routes'), findsNothing);
    expect(find.text('Show less'), findsNothing);
    expect(find.text('Park connector loop'), findsNothing);
    expect(find.text('Morning waterfront'), findsNothing);

    await tester.tap(find.byKey(const Key('maps_see_all_shared_routes')));
    await tester.pumpAndSettle();

    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('All shared routes'), findsNothing);
    expect(find.text('See all'), findsNothing);
    expect(find.text('Show less'), findsOneWidget);
    expect(find.text('Route preview'), findsOneWidget);
    expect(find.text('Shared routes'), findsOneWidget);
    expect(find.text('Saved routes'), findsOneWidget);
    expect(find.text('Park connector loop'), findsOneWidget);
    expect(tester.getTopLeft(sheetSurface).dy, lessThan(initialTop));
    expect(tester.getSize(sheetSurface).height, closeTo(screenHeight * 0.7, 1));
    expect(
      find.byKey(const Key('maps_expanded_shared_routes_list')),
      findsOneWidget,
    );

    final expandedTop = tester.getTopLeft(sheetSurface).dy;
    final expandedHeight = tester.getSize(sheetSurface).height;

    await tester.scrollUntilVisible(
      find.text('Sunset recovery route'),
      120,
      scrollable: find.descendant(
        of: find.byKey(const Key('maps_expanded_shared_routes_list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sunset recovery route'), findsOneWidget);
    expect(tester.getTopLeft(sheetSurface).dy, expandedTop);
    expect(tester.getSize(sheetSurface).height, expandedHeight);
    expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);

    await tester.tap(find.byKey(const Key('maps_show_less_shared_routes')));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(sheetSurface).dy, initialTop);
    expect(tester.getSize(sheetSurface).height, initialHeight);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Show less'), findsNothing);
    expect(find.text('All shared routes'), findsNothing);
    expect(find.text('Park connector loop'), findsNothing);
    expect(find.text('Morning waterfront'), findsNothing);
    expect(find.text('Sunset recovery route'), findsNothing);
  });

  testWidgets(
    'Maps manual collapse from expanded routes resets to preview state',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();

      final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
      final initialTop = tester.getTopLeft(sheetSurface).dy;

      await tester.tap(find.byKey(const Key('maps_see_all_shared_routes')));
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);
      expect(find.text('Park connector loop'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('maps_sheet_handle')),
        const Offset(0, 700),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsNothing);
      expect(find.text('Show less'), findsNothing);
      expect(find.text('Park connector loop'), findsNothing);

      await tester.flingFrom(
        const Offset(400, 505),
        const Offset(0, -700),
        1000,
      );
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(sheetSurface).dy, initialTop);
      expect(find.text('Shared Routes'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.text('Show less'), findsNothing);
      expect(find.text('Park connector loop'), findsNothing);
    },
  );

  testWidgets('Maps Saved opens static My routes page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text('My routes'), findsOneWidget);
    expect(
      find.byKey(const Key('my_routes_header_accent_strip')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    expect(find.text('SELECTED FOR TODAY'), findsOneWidget);
    expect(find.byKey(const Key('selected_route_card')), findsOneWidget);
    expect(find.text('Marina Bay easy loop'), findsOneWidget);
    expect(find.text('3.2 km · 25 min · Easy'), findsOneWidget);
    expect(find.text('Ready for today'), findsNothing);
    expect(find.text('Change route'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(
      find.byKey(const Key('selected_route_change_action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('selected_route_remove_action')),
      findsOneWidget,
    );
    expect(find.text('Favourite routes'), findsOneWidget);
    expect(find.text('Bishan Park starter route'), findsOneWidget);
    expect(find.text('East Coast flat run'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('selected_route_card')),
        matching: find.byKey(const Key('selected_route_arrow_affordance')),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const Key('favourite_route_arrow_affordance')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('favourite_route_radio_affordance')),
      findsNothing,
    );
    await tester.tap(find.text('Change route'));
    await tester.pumpAndSettle();
    expect(find.text('My routes'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Kallang riverside run'),
      180,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Punggol waterway loop'), findsOneWidget);
    expect(find.text('Kallang riverside run'), findsOneWidget);
    expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('My routes'), findsNothing);
    expect(find.text('Search routes or parks'), findsOneWidget);
    expect(find.text('Shared Routes'), findsOneWidget);
  });

  testWidgets('Maps Saved selected route opens static route detail preview', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('selected_route_card')));
    await tester.pumpAndSettle();

    expect(find.text('Route'), findsOneWidget);
    expect(find.text('Marina Bay easy loop'), findsOneWidget);
    expect(find.text('3.2 km'), findsWidgets);
    expect(find.text('25 min'), findsOneWidget);
    expect(find.text('Easy'), findsWidgets);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.text('My routes'), findsOneWidget);
  });

  testWidgets('Maps Saved favourite route opens static route detail preview', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bishan Park starter route'));
    await tester.pumpAndSettle();

    expect(find.text('Route'), findsOneWidget);
    expect(find.text('Bishan Park starter route'), findsOneWidget);
    expect(find.text('2.4 km'), findsWidgets);
    expect(find.text('18 min'), findsOneWidget);
    expect(find.text('Easy'), findsWidgets);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.text('My routes'), findsOneWidget);
  });

  testWidgets('Maps Saved remove dialog can cancel without changing route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('selected_route_remove_action')));
    await tester.pumpAndSettle();

    expect(find.text('Remove selected route?'), findsOneWidget);
    expect(
      find.text(
        'This will remove Marina Bay easy loop from today’s selected route.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Remove'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('My routes'), findsOneWidget);
    expect(find.text('Marina Bay easy loop'), findsOneWidget);
    expect(find.byKey(const Key('selected_route_card')), findsOneWidget);
    expect(
      find.byKey(const Key('selected_route_remove_action')),
      findsOneWidget,
    );
    expect(find.text('No route selected for today'), findsNothing);
  });

  testWidgets(
    'Maps Saved confirm remove shows local empty selected route state',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('selected_route_remove_action')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Remove'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No route selected for today'), findsOneWidget);
      expect(
        find.text('Choose a route when you are ready to plan your next run.'),
        findsOneWidget,
      );
      expect(find.text('Change route'), findsOneWidget);
      expect(find.byKey(const Key('selected_route_card')), findsNothing);
      expect(
        find.byKey(const Key('selected_route_remove_action')),
        findsNothing,
      );
      expect(find.text('Route removed'), findsNothing);
      expect(find.text('Deleted from Firestore'), findsNothing);
      expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);

      await tester.tap(find.text('Change route'));
      await tester.pumpAndSettle();

      expect(find.text('My routes'), findsOneWidget);
      expect(find.text('No route selected for today'), findsOneWidget);
    },
  );

  testWidgets('Maps sheet keeps a non-scrolling Home-style accent layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    final sheetBody = find.byKey(const Key('maps_sheet_body'));
    final handle = find.byKey(const Key('maps_sheet_handle'));
    final accentStrip = find.byKey(const Key('maps_sheet_accent_strip'));
    final accentBlue = find.byKey(const Key('maps_sheet_accent_blue'));
    final accentGap = find.byKey(const Key('maps_sheet_accent_gap'));
    final accentOrange = find.byKey(const Key('maps_sheet_accent_orange'));

    expect(sheetBody, findsOneWidget);
    expect(handle, findsOneWidget);
    expect(accentStrip, findsOneWidget);
    expect(accentBlue, findsOneWidget);
    expect(accentGap, findsOneWidget);
    expect(accentOrange, findsOneWidget);

    expect(
      find.descendant(
        of: sheetBody,
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: sheetBody, matching: find.byType(ListView)),
      findsNothing,
    );
    expect(
      find.descendant(of: sheetBody, matching: find.byType(CustomScrollView)),
      findsNothing,
    );

    expect(tester.getSize(accentBlue).height, 4);
    expect(tester.getSize(accentGap).width, 8);
    expect(tester.getSize(accentOrange), const Size(34, 4));

    expect(
      tester.getTopLeft(handle).dy,
      lessThan(tester.getTopLeft(accentStrip).dy),
    );
    expect(
      tester.getBottomLeft(accentStrip).dy,
      lessThan(tester.getTopLeft(find.text('Shared Routes')).dy),
    );
  });

  testWidgets('Maps route cards stay compact with bounded text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    for (final key in const [
      Key('route_preview_card_route_preview'),
      Key('route_preview_card_shared_routes'),
      Key('route_preview_card_saved_routes'),
    ]) {
      expect(tester.getSize(find.byKey(key)).height, 92);
    }

    final routeTitle = tester.widget<Text>(find.text('Route preview'));
    final routeMessage = tester.widget<Text>(
      find.text('A calm route card can guide the next step later.'),
    );

    expect(routeTitle.maxLines, 1);
    expect(routeTitle.overflow, TextOverflow.ellipsis);
    expect(routeMessage.maxLines, 2);
    expect(routeMessage.overflow, TextOverflow.ellipsis);
  });

  testWidgets(
    'Maps shared route detail opens from first card and renders static route content',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Route preview'));
      await tester.pumpAndSettle();

      expect(find.text('Route'), findsOneWidget);
      expect(find.text('Marina Bay easy loop'), findsOneWidget);
      expect(find.text('EASY · LOOP'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('3.2 km'), findsWidgets);
      expect(find.text('25 min'), findsOneWidget);
      expect(find.text('Easy'), findsWidgets);
      final detailScrollView = tester.widget<ListView>(
        find.byKey(const Key('shared_route_detail_scroll_view')),
      );
      expect(detailScrollView.physics, isA<ClampingScrollPhysics>());

      final mapPainterSize = tester.getSize(
        find.byKey(const Key('shared_route_detail_map_painter')),
      );
      expect(mapPainterSize.width, greaterThan(0));
      expect(mapPainterSize.height, greaterThan(0));

      await tester.scrollUntilVisible(
        find.text('Runner notes'),
        320,
        scrollable: find.byType(Scrollable).last,
      );

      expect(find.text('Runner notes'), findsOneWidget);
      expect(
        tester
            .getSize(
              find.byKey(const Key('shared_route_detail_elevation_painter')),
            )
            .width,
        greaterThan(0),
      );
      expect(find.bySemanticsLabel('Save route'), findsOneWidget);
      expect(find.bySemanticsLabel('Share route'), findsOneWidget);
      expect(find.text('Select Route'), findsOneWidget);
    },
  );

  testWidgets('Maps shared route detail share opens preview-only sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Route preview'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Share route'));
    await tester.pumpAndSettle();

    expect(find.text('Share route preview'), findsOneWidget);
    expect(find.text('Marina Bay easy loop'), findsWidgets);
    expect(find.text('3.2 km · 25 min · Easy'), findsOneWidget);
    expect(find.text('Preview only'), findsOneWidget);
    expect(
      find.text('Route sharing is preview-only in this prototype.'),
      findsOneWidget,
    );
    expect(
      find.text('Link sharing will be available after setup.'),
      findsOneWidget,
    );
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Coming soon'), findsNWidgets(3));
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Shared successfully'), findsNothing);
    expect(find.text('Link copied'), findsNothing);
    expect(find.text('Route sent'), findsNothing);
    expect(find.text('Invite friends now'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Close'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Share route preview'), findsNothing);
    expect(find.text('Route'), findsOneWidget);
    expect(find.text('Marina Bay easy loop'), findsOneWidget);
  });

  testWidgets(
    'Maps shared route detail report sheet submits static report note',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Route preview'));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.bySemanticsLabel('Report route')).dx,
        lessThan(tester.getTopLeft(find.bySemanticsLabel('Share route')).dx),
      );

      await tester.tap(find.bySemanticsLabel('Report route'));
      await tester.pumpAndSettle();

      expect(find.text('Report Route'), findsOneWidget);
      expect(find.text('Reporting'), findsOneWidget);
      expect(find.text('Marina Bay easy loop'), findsWidgets);
      expect(find.text('3.2 km · 25 min · Easy'), findsWidgets);
      expect(find.text('Doesn’t exist'), findsOneWidget);
      expect(find.text('Unsafe'), findsOneWidget);
      expect(find.text('Wrong info'), findsOneWidget);
      expect(find.text('Inappropriate'), findsOneWidget);
      expect(find.byIcon(Icons.wrong_location_outlined), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_location_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.report_gmailerrorred_outlined), findsOneWidget);

      await tester.tap(find.text('Wrong info'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tell us which distance, time, difficulty, or location detail seems wrong.',
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('route_report_why_field')),
        'The distance marker looks incorrect.',
      );
      await tester.pumpAndSettle();

      final reportButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Report'),
      );
      expect(reportButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Report'));
      await tester.pumpAndSettle();

      expect(find.text('Report noted'), findsOneWidget);
      expect(
        find.text('This preview keeps your report on this screen only.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Report noted'), findsNothing);
      expect(find.text('Route'), findsOneWidget);
    },
  );

  testWidgets('Maps shared route detail report sheet requires reason and why', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Route preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Report route'));
    await tester.pumpAndSettle();

    FilledButton currentReportButton() {
      return tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Report'),
      );
    }

    expect(currentReportButton().onPressed, isNull);
    expect(
      find.text('Add details to help us review this route.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Unsafe'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tell us what makes this route feel unsafe.'),
      findsOneWidget,
    );
    expect(currentReportButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('route_report_why_field')),
      '   ',
    );
    await tester.pumpAndSettle();

    expect(currentReportButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('route_report_why_field')),
      'Poor lighting after sunset',
    );
    await tester.pumpAndSettle();

    expect(currentReportButton().onPressed, isNotNull);
  });

  testWidgets(
    'Maps shared route detail keeps share preview after adding report',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Route preview'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Report route'), findsOneWidget);
      expect(find.bySemanticsLabel('Share route'), findsOneWidget);
      expect(
        tester.getTopLeft(find.bySemanticsLabel('Report route')).dx,
        lessThan(tester.getTopLeft(find.bySemanticsLabel('Share route')).dx),
      );

      await tester.tap(find.bySemanticsLabel('Share route'));
      await tester.pumpAndSettle();

      expect(find.text('Share route preview'), findsOneWidget);
      expect(find.text('Copy Link'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Close'),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Report route'));
      await tester.pumpAndSettle();

      expect(find.text('Report Route'), findsOneWidget);
      expect(find.text('Submitted to Firebase'), findsNothing);
      expect(find.text('Sent to moderation queue'), findsNothing);
      expect(find.text('Admin review created'), findsNothing);
      expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);
    },
  );

  testWidgets(
    'Maps shared route detail confirms with saving overlay and stay here disables select',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Route preview'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Route'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Route'), findsOneWidget);
      expect(
        find.text('This will replace your current selected route.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Confirm Route'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Setting up your next run...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      expect(find.text('Route selected'), findsOneWidget);
      expect(
        find.text('This route has been saved and set for your next run.'),
        findsOneWidget,
      );
      expect(find.text('Start Run'), findsOneWidget);
      expect(find.text('View Planned Routes'), findsOneWidget);
      expect(find.text('Stay Here'), findsOneWidget);

      await tester.tap(find.text('Stay Here'));
      await tester.pumpAndSettle();

      expect(find.text('Route selected'), findsNothing);
      expect(find.text('Selected for your next run'), findsNothing);

      final selectButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Select Route'),
      );
      expect(selectButton.onPressed, isNull);
    },
  );

  testWidgets(
    'Maps shared route detail remains static and preserves sheet regression boundaries',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsOneWidget);
      expect(find.text('Shared routes'), findsOneWidget);
      expect(find.text('Saved routes'), findsOneWidget);

      await tester.tap(find.text('Route preview'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsOneWidget);
      expect(find.text('Route preview'), findsOneWidget);

      final mapsSource = Directory('lib/features/maps')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) {
            return file.readAsStringSync();
          })
          .join('\n');

      expect(mapsSource, contains('Sign in to select this route.'));
      expect(
        mapsSource,
        contains("You seem to be offline. Try again when you're connected."),
      );
      expect(
        mapsSource,
        contains("We couldn't select this route. Please try again."),
      );
      expect(mapsSource, contains('Marina Bay easy loop, 3.2 km'));
      expect(
        mapsSource,
        isNot(
          contains(
            RegExp(
              r'Firebase|Firestore|FirebaseAuth|cloud_firestore|'
              r'firebase_auth|\bcollection\(|\bdoc\(|\bupdate\(|\bset\(',
            ),
          ),
        ),
      );
    },
  );

  testWidgets('Maps sheet first landing is the maximum full-content height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
    final initialTop = tester.getTopLeft(sheetSurface).dy;

    expect(find.text('Route preview'), findsOneWidget);
    expect(find.text('Shared routes'), findsOneWidget);
    expect(find.text('Saved routes'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('maps_sheet_handle')),
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(sheetSurface).dy, initialTop);
    expect(find.text('Saved routes'), findsOneWidget);
  });

  testWidgets(
    'Maps sheet height fits the shared route content bottom padding',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const RuniacApp());

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();

      final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
      final savedRouteCard = find.byKey(
        const Key('route_preview_card_saved_routes'),
      );

      expect(sheetSurface, findsOneWidget);
      expect(savedRouteCard, findsOneWidget);

      final bottomPadding =
          tester.getBottomLeft(sheetSurface).dy -
          tester.getBottomLeft(savedRouteCard).dy;

      expect(bottomPadding, closeTo(14, 1));
    },
  );

  testWidgets('Maps sheet collapses without an internal scrollable body', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    final sheetBody = find.byKey(const Key('maps_sheet_body'));
    final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
    final handle = find.byKey(const Key('maps_sheet_handle'));
    final initialTop = tester.getTopLeft(sheetBody).dy;

    await tester.drag(handle, const Offset(0, 700));
    await tester.pumpAndSettle();

    final collapsedSheetTop = tester.getTopLeft(sheetSurface).dy;
    final handleTop = tester.getTopLeft(handle).dy;
    final handleBottom = tester.getBottomLeft(handle).dy;
    final bottomNavTop = tester.getTopLeft(find.byType(BottomNavigationBar)).dy;

    expect(tester.getTopLeft(sheetBody).dy, greaterThan(initialTop + 200));
    expect(handle, findsOneWidget);
    expect(handleTop, greaterThanOrEqualTo(0));
    expect(handleBottom, lessThanOrEqualTo(bottomNavTop));
    expect(handleTop, greaterThanOrEqualTo(collapsedSheetTop));
    expect(handleBottom, lessThanOrEqualTo(collapsedSheetTop + 46));
    expect(find.text('Shared Routes'), findsNothing);
    expect(
      find.descendant(
        of: sheetBody,
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: sheetBody, matching: find.byType(ListView)),
      findsNothing,
    );
    expect(
      find.descendant(of: sheetBody, matching: find.byType(CustomScrollView)),
      findsNothing,
    );
  });

  testWidgets('Maps sheet uses progressive Leaderboard-style dragging', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
    final initialTop = tester.getTopLeft(sheetSurface).dy;

    final collapseGesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('maps_sheet_handle'))),
    );
    await collapseGesture.moveBy(const Offset(0, 120));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final partialCollapseTop = tester.getTopLeft(sheetSurface).dy;

    expect(partialCollapseTop, greaterThan(initialTop));
    expect(find.text('Shared Routes'), findsOneWidget);
    await collapseGesture.up();

    await tester.drag(
      find.byKey(const Key('maps_sheet_handle')),
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();
    final collapsedTop = tester.getTopLeft(sheetSurface).dy;

    expect(collapsedTop, greaterThan(partialCollapseTop));
    expect(find.text('Shared Routes'), findsNothing);

    await tester.flingFrom(const Offset(400, 505), const Offset(0, -700), 1000);
    await tester.pumpAndSettle();
    final restoredTop = tester.getTopLeft(sheetSurface).dy;

    expect(restoredTop, initialTop);
    expect(find.text('Shared Routes'), findsOneWidget);
  });

  testWidgets('Leaderboard tab shows static map-first landing shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Runiac'), findsNothing);
    expect(find.text('Weekly XP'), findsNothing);
    expect(find.text('Monthly XP'), findsNothing);
    expect(find.text('Rising Runner Division'), findsOneWidget);
    expect(find.text('Lv.11 - Lv.20'), findsOneWidget);
    expect(find.text('Your ranked area'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Jurong East'), findsOneWidget);
    expect(find.text('Weekly XP · Rising Runner Division'), findsNothing);
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
    expect(find.text('Rising Runner Division'), findsOneWidget);
    expect(find.text('Region Leaderboard'), findsNothing);
    expect(find.text('Region Preview'), findsNothing);
    expect(find.text('Ranking preview pending'), findsNothing);
    expect(find.text('My Rank Preview'), findsOneWidget);
    expect(find.text('Alex T.'), findsOneWidget);
    expect(find.text('Maya L.'), findsOneWidget);
    expect(find.text('Ryan K.'), findsOneWidget);
    expect(find.text('Jinseo (You)'), findsOneWidget);
    expect(find.text('Level 18'), findsOneWidget);
    expect(find.text('Level 17'), findsOneWidget);
    expect(find.text('Level 16'), findsOneWidget);
    expect(find.text('Level 12'), findsOneWidget);
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
    expect(find.textContaining('Lv.18'), findsNothing);

    await tester.tap(find.byTooltip('Close tips'));
    await tester.pumpAndSettle();

    expect(find.text('Tips'), findsNothing);
    expect(find.text('Leagues'), findsNothing);
    expect(find.text('Rising Runner Division'), findsOneWidget);
    expect(find.text('Region Leaderboard'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open leagues list'));
    await tester.pumpAndSettle();

    expect(find.text('Leagues'), findsOneWidget);
    expect(find.text('Apex Runner League (Lv.81 - Lv.90)'), findsOneWidget);
    expect(find.text('Summitborn League (Lv.71 - Lv.80)'), findsOneWidget);
    expect(find.text('Roadrunner League (Lv.51 - Lv.60)'), findsOneWidget);
    expect(find.text('Endurancer League (Lv.41 - Lv.50)'), findsOneWidget);
    expect(find.text('Milehunter League (Lv.31 - Lv.40)'), findsOneWidget);
    expect(find.text('Pacebreaker League (Lv.21 - Lv.30)'), findsOneWidget);
    expect(find.text('Strideforge League (Lv.11 - Lv.20)'), findsOneWidget);
    expect(find.text('Trailborn League (Lv.1 - Lv.10)'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
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
    expect(find.text('Rising Runner Division'), findsOneWidget);
    expect(find.text('Lv.11 - Lv.20'), findsOneWidget);
    expect(find.text('Region Leaderboard'), findsNothing);
  });

  testWidgets('Leaderboard preview rank rows open runner profiles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Leaderboard'));
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
    expect(find.text('Jinseo'), findsOneWidget);
    expect(find.text('Jurong East · Rank #18'), findsOneWidget);
    expect(find.text('520 XP'), findsNothing);
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

    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Leaderboard'));
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
    expect(find.text('Rising Runner Division'), findsWidgets);
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
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('leaderboard_view_more_ranking_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back to Leaderboard'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.text('Jurong East'), findsOneWidget);
    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('Monthly board'), findsNothing);
    expect(find.text('Refreshes in 24:14:05:45'), findsOneWidget);
    expect(find.text('Refreshes in 12 days'), findsNothing);
    expect(find.text('Refreshes in 24D : 14H : 05M : 45S'), findsNothing);
    expect(find.text('24:14:05:45'), findsNothing);
    expect(find.text('Rising Runner Division'), findsOneWidget);
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
    expect(find.text('#18'), findsNWidgets(2));
    expect(find.text('520 XP'), findsNWidgets(2));
    expect(
      find.byKey(const Key('leaderboard_detail_current_user_row')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('leaderboard_current_user_floating_bar')),
      findsOneWidget,
    );
    expect(find.textContaining('to reach'), findsNothing);
    expect(find.textContaining('progress'), findsNothing);

    final floatingBarBottom = tester
        .getBottomLeft(
          find.byKey(const Key('leaderboard_current_user_floating_bar')),
        )
        .dy;
    final bottomNavTop = tester.getTopLeft(find.text('Home')).dy;
    expect(floatingBarBottom, lessThan(bottomNavTop));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Region Leaderboard'), findsNothing);
    expect(find.text('View More Ranking'), findsOneWidget);
    expect(find.text('Monthly board'), findsNothing);
  });

  testWidgets('Leaderboard rows open read-only runner achievement profiles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Leaderboard'));
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
    expect(find.text('Rising Runner Division · Level 18'), findsOneWidget);
    expect(
      find.byKey(const Key('runner_profile_total_distance_metric')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('runner_profile_best_streak_metric')),
      findsOneWidget,
    );
    expect(find.text('10000 km'), findsOneWidget);
    expect(find.text('365 days'), findsOneWidget);
    expect(find.text('Total distance'), findsOneWidget);
    expect(find.text('Total distance (km)'), findsNothing);
    expect(find.text('Best streak'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('6 earned'), findsOneWidget);
    expect(find.text('First 5K'), findsOneWidget);
    expect(find.text('Consistency Starter'), findsOneWidget);
    expect(find.text('Weekend Runner'), findsOneWidget);
    expect(find.text('Morning Miles'), findsOneWidget);
    expect(find.text('Steady Builder'), findsOneWidget);
    expect(find.text('Park Route Fan'), findsOneWidget);
    expect(
      find.text('Only public running achievements are shown.'),
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
    expect(find.text('Jinseo'), findsOneWidget);
    expect(find.text('Jurong East · Rank #18'), findsOneWidget);
    expect(find.text('520 XP'), findsNothing);
    expect(find.text('You'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Rankings'));
    await tester.pumpAndSettle();

    expect(find.text('Runner profile'), findsNothing);
    expect(find.text('Regional ranking'), findsOneWidget);
  });

  test('Leaderboard source isolates static display snapshots', () {
    final source = File(
      'lib/features/leaderboard/presentation/leaderboard_tab.dart',
    ).readAsStringSync();

    expect(source, contains('class _LeaderboardPreviewSnapshot'));
    expect(source, contains('class _LeaderboardLeagueSnapshot'));
    expect(source, contains('class _LeaderboardRegionSnapshot'));
    expect(source, contains('class _LeaderboardDetailDisplaySnapshot'));
    expect(source, contains('class _LeaderboardRankRowDisplaySnapshot'));
    expect(source, contains('class _RunnerAchievementProfileSnapshot'));
    expect(source, contains('class _RunnerAchievementBadgeSnapshot'));
    expect(source, contains('class _RunnerMetricValueText'));
    expect(source, contains('const _leaderboardPreviewSnapshot'));
    expect(source, contains('const _leaderboardLeagueSnapshot'));
    expect(source, contains('const _leaderboardRegionSnapshot'));
    expect(source, contains('const _leaderboardDetailSnapshot'));
    expect(source, contains('periodLabel: \'June 2026\''));
    expect(source, contains('fallbackPeriodLabel: \'Monthly board\''));
    expect(source, contains('Refreshes in 24:14:05:45'));
    expect(source, contains('Refreshes in 00:00:00:00'));

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

    final metricValueStart = source.indexOf('class _RunnerMetricValueText');
    final metricValueEnd = source.indexOf(
      'class _RunnerAchievementsSection',
      metricValueStart,
    );
    final metricValueSource = source.substring(
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
        periodLabel: 'June 2026',
        fallbackPeriodLabel: 'Monthly board',
      ),
      'June 2026',
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
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Leaderboard'));
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

  testWidgets('Run item opens and protects static live end controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Run settings'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('km easy run'), findsOneWidget);
    expect(find.text('Pace 7:10-7:40 / km · ~32 min'), findsOneWidget);
    expect(find.text('Switch route'), findsOneWidget);
    expect(find.text('Start run'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Maps'), findsNothing);
    expect(find.text('Leaderboard'), findsNothing);
    expect(find.text('You'), findsNothing);

    await tester.tap(find.text('Start run'));
    await tester.pumpAndSettle();

    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.text('TODAY\'S PLAN'), findsNothing);
    expect(find.text('RUNNING'), findsNothing);
    expect(find.text('4.10 of 4.50 km'), findsOneWidget);
    expect(find.text('91%'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('4.10'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('30:10'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.text('6:30/km'), findsOneWidget);
    expect(find.text('HEART'), findsNothing);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
    expect(find.text('GPS ready'), findsNothing);
    expect(find.text('Start run'), findsNothing);

    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(find.text('Pause'), findsNothing);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('Hold to end'), findsNothing);
    expect(find.text('Keep holding...'), findsNothing);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('4.10 of 4.50 km'), findsOneWidget);
    expect(find.text('91%'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('4.10'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('30:10'), findsOneWidget);
    expect(find.text('AVG PACE'), findsOneWidget);
    expect(find.text('6:30/km'), findsOneWidget);

    await tester.tap(find.byKey(const Key('run_hold_to_end_button')));
    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('Hold to end'), findsNothing);
    expect(find.text('Keep holding...'), findsNothing);
    expect(find.text('Run summary'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.text('Leaderboard'), findsNothing);
    expect(find.textContaining('Activity saved'), findsNothing);
    expect(find.textContaining('Saved activity'), findsNothing);

    final earlyReleaseGesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('run_hold_to_end_button'))),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('End'), findsOneWidget);
    expect(find.text('Hold to end'), findsNothing);
    expect(find.text('Keep holding...'), findsNothing);

    await earlyReleaseGesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Paused · easy'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('Hold to end'), findsNothing);
    expect(find.text('Keep holding...'), findsNothing);
    expect(find.text('Run summary'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.text('Leaderboard'), findsNothing);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Running · easy'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('End'), findsNothing);
    expect(find.text('Hold to end'), findsNothing);
    expect(find.text('Keep holding...'), findsNothing);
    expect(find.text('4.10 of 4.50 km'), findsOneWidget);
    expect(find.text('30:10'), findsOneWidget);
  });

  testWidgets(
    'Run completed hold opens Cool down page with placeholder actions',
    (WidgetTester tester) async {
      await _openPausedRun(tester);

      await _completeHoldToEnd(tester);

      expect(find.text('Cool down'), findsOneWidget);
      expect(
        find.text('Great job! Now let’s cool down and stretch.'),
        findsOneWidget,
      );
      expect(find.text('Why cool-down?'), findsOneWidget);
      expect(
        find.text(
          'A gentle cool-down helps your heart rate settle and can reduce muscle soreness.',
        ),
        findsOneWidget,
      );
      expect(find.text('Slow Walk'), findsOneWidget);
      expect(find.text('3-5 min'), findsOneWidget);
      expect(find.text('Stretching'), findsOneWidget);
      expect(find.text('5-8 min · 5 exercises'), findsOneWidget);
      expect(find.text('Start Cool-down'), findsOneWidget);
      expect(find.text('Skip to Summary'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.textContaining(_forbiddenRunCompletionCopy), findsNothing);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Skip to Summary'));
      await tester.pumpAndSettle();

      expect(find.text('Saturday Morning Run'), findsOneWidget);
      expect(find.text('Today · 7:06 AM'), findsOneWidget);
      expect(find.text('4.03'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
      expect(find.text('6’30”'), findsOneWidget);
      expect(find.text('30:15'), findsOneWidget);
      expect(find.text('Pace Over Time'), findsOneWidget);
      expect(find.text('Advanced Analysis'), findsOneWidget);
      expect(find.text('AI Coaching Summary'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Share Route'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'View XP Update'),
        findsOneWidget,
      );
      expect(find.text('XP & Streak Update'), findsNothing);
      expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'View XP Update'));
      await tester.pumpAndSettle();

      expect(find.text('XP & Streak Update'), findsOneWidget);
      expect(find.text('Nice work, Jinseo!'), findsOneWidget);
      expect(find.text('+120 XP'), findsOneWidget);
      expect(find.text('Total XP'), findsOneWidget);
      expect(find.text('2,520 XP'), findsOneWidget);
      expect(find.text('5 \u2192 6 days'), findsOneWidget);
      expect(find.text('Great consistency!'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Go Home'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Go Home'));
      await tester.tap(find.widgetWithText(FilledButton, 'Go Home'));
      await tester.pumpAndSettle();

      expect(find.text('XP & Streak Update'), findsNothing);
      expect(find.text('Good to see you'), findsOneWidget);
    },
  );

  testWidgets('View summary static content and actions match design', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);
    await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

    final summaryScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(summaryScaffold.backgroundColor, RuniacColors.white);
    expect(find.text('Saturday Morning Run'), findsOneWidget);
    expect(find.text('Today · 7:06 AM'), findsOneWidget);
    expect(find.byTooltip('Back to cool down'), findsOneWidget);
    expect(find.byTooltip('Share summary'), findsOneWidget);
    expect(find.text('East Coast Park Loop'), findsOneWidget);
    expect(find.text('Run complete'), findsOneWidget);
    expect(find.text('4.03'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('6’30”'), findsOneWidget);
    expect(find.text('Avg Pace'), findsOneWidget);
    expect(find.text('30:15'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('145 bpm'), findsOneWidget);
    expect(find.text('145 kcal'), findsOneWidget);
    expect(find.text('Avg Heart Rate'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(find.byIcon(Icons.speed_rounded), findsNothing);
    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    expect(find.byIcon(Icons.local_fire_department_outlined), findsNothing);
    expect(find.text('Pace Over Time'), findsOneWidget);
    expect(find.text('4:00'), findsOneWidget);
    expect(find.text('10:00'), findsNWidgets(2));
    expect(find.text('15:02'), findsOneWidget);
    expect(find.text('Advanced Analysis'), findsOneWidget);
    expect(find.text('Heart rate zones, cadence & elevation'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
    expect(find.text('Steady'), findsOneWidget);
    expect(find.text('22%'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(find.text('More Details'), findsOneWidget);
    expect(find.text('AI Coaching Summary'), findsOneWidget);
    expect(
      find.text(
        'Great job completing today\'s planned run! You maintained a steady pace and finished feeling in control. Consistency like this builds a strong foundation.',
      ),
      findsOneWidget,
    );
    expect(find.text('Next Run Tip'), findsOneWidget);
    expect(find.text('Next Run Tip:'), findsNothing);
    expect(
      find.text(
        'Try a 5-minute dynamic warmup before your next run to help your body move more easily.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Share Route'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsOneWidget);
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);

    await tester.tap(find.byTooltip('Share summary'));
    await tester.pumpAndSettle();

    expect(find.text('Share Your Achievement'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(OutlinedButton, 'More Details'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'More Details'));
    await tester.pumpAndSettle();

    expect(find.text('Performance Overview'), findsOneWidget);
    expect(find.text('Good steady effort'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to summary'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(OutlinedButton, 'Share Route'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Share Route'));
    await tester.pumpAndSettle();

    expect(find.text('Route sharing will be available soon.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'View XP Update'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'View XP Update'));
    await tester.pumpAndSettle();

    expect(find.text('XP & Streak Update'), findsOneWidget);
    expect(find.text('Nice work, Jinseo!'), findsOneWidget);
    expect(find.text('+120 XP'), findsOneWidget);
    expect(find.text('Earned from this run'), findsOneWidget);
  });

  testWidgets('View summary accepts selected static run summary data', (
    WidgetTester tester,
  ) async {
    _useTallSummarySurface(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: ViewSummaryScreen(
          summary: RunSummarySnapshot(
            title: 'Recovery Jog',
            dateLabel: '4/11/26',
            timeLabel: '8:10 PM',
            distanceKm: '5.17',
            avgPace: '7’40”',
            duration: '39:38',
            avgHeartRate: '132',
            calories: '286',
            routeName: 'Park Connector Recovery Loop',
          ),
        ),
      ),
    );

    expect(find.text('Recovery Jog'), findsOneWidget);
    expect(find.text('4/11/26 · 8:10 PM'), findsOneWidget);
    expect(find.text('Park Connector Recovery Loop'), findsOneWidget);
    expect(find.text('5.17'), findsOneWidget);
    expect(find.text('7’40”'), findsOneWidget);
    expect(find.text('39:38'), findsOneWidget);
    expect(find.text('132 bpm'), findsOneWidget);
    expect(find.text('286 kcal'), findsOneWidget);
    expect(find.text('Saturday Morning Run'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Share Route'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsOneWidget);
  });

  testWidgets(
    'View summary share icon opens Share Your Achievement bottom sheet',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);
      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      expect(find.byTooltip('Share summary'), findsOneWidget);
      expect(find.text('Share Your Achievement'), findsNothing);

      await tester.tap(find.byTooltip('Share summary'));
      await tester.pumpAndSettle();

      expect(find.text('Saturday Morning Run'), findsWidgets);
      expect(find.text('Share Your Achievement'), findsOneWidget);
    },
  );

  testWidgets(
    'Share achievement sheet renders static preview metrics and actions',
    (WidgetTester tester) async {
      _useCompactShareSheetSurface(tester);
      await tester.pumpWidget(_shareSheetHarness());

      await tester.tap(find.text('Open share sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Share Your Achievement'), findsOneWidget);
      expect(find.text('4.03'), findsWidgets);
      expect(find.text('km'), findsWidgets);
      expect(find.text('6\'30"'), findsOneWidget);
      expect(find.text('Avg pace'), findsOneWidget);
      expect(find.text('30:15'), findsWidgets);
      expect(find.text('Time'), findsWidgets);
      expect(find.text('Avg HR'), findsOneWidget);
      expect(find.text('145'), findsWidgets);
      expect(find.text('Calories'), findsWidgets);
      expect(find.text('Edit card'), findsOneWidget);
      expect(find.text('Change theme'), findsOneWidget);
      expect(find.text('Instagram Stories'), findsOneWidget);
      expect(find.text('Copy Image'), findsOneWidget);
      expect(find.text('Save Image'), findsOneWidget);
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('More'), findsWidgets);
      expect(
        find.image(const AssetImage('assets/icons/instagram_stories.png')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ShareAchievementSheet),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Copy Image'));
      await tester.pump();

      expect(
        find.text('Preview only. Image copying is not connected yet.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Share achievement sheet close dismisses without leaving summary',
    (WidgetTester tester) async {
      _useTallSummarySurface(tester);
      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      await tester.tap(find.byTooltip('Share summary'));
      await tester.pumpAndSettle();

      expect(find.text('Share Your Achievement'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();

      expect(find.text('Share Your Achievement'), findsNothing);
      expect(find.text('Saturday Morning Run'), findsOneWidget);
      expect(find.text('Run saved'), findsNothing);
    },
  );

  testWidgets('Advanced Analysis renders handoff sections and sample values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdvancedAnalysisScreen()));

    expect(find.text('Saturday Morning Run'), findsOneWidget);
    expect(find.text('Today · 7:06 AM'), findsOneWidget);
    expect(find.text('Performance Overview'), findsOneWidget);
    expect(find.text('82'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);
    expect(find.text('Good steady effort'), findsOneWidget);
    expect(find.text('Stable Pace'), findsOneWidget);
    expect(find.text('Controlled HR'), findsOneWidget);
    expect(find.text('Good Endurance'), findsOneWidget);

    expect(find.text('Pace Analysis'), findsOneWidget);
    expect(find.text('6’30”'), findsOneWidget);
    expect(find.text('5’58”'), findsOneWidget);
    expect(find.text('7’05”'), findsOneWidget);
    expect(find.text('86'), findsOneWidget);
    expect(find.text('1 km'), findsOneWidget);
    expect(find.text('4.03 km'), findsOneWidget);

    await tester.ensureVisible(find.text('Heart Rate Analysis'));

    expect(find.text('Heart Rate Analysis'), findsOneWidget);
    expect(find.text('145'), findsOneWidget);
    expect(find.text('158'), findsOneWidget);
    expect(find.text('130–150'), findsOneWidget);
    expect(find.text('72'), findsOneWidget);
    expect(find.text('Zone 2 Aerobic'), findsOneWidget);

    await tester.ensureVisible(find.text('Recovery Recommendation'));

    expect(find.text('Effort & Intensity'), findsOneWidget);
    expect(find.text('88% · Good'), findsOneWidget);
    expect(find.text('Elevation Analysis'), findsOneWidget);
    expect(find.text('+12'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('Mostly Flat'), findsOneWidget);
    expect(find.text('Running Form / Cadence'), findsOneWidget);
    expect(find.text('164'), findsOneWidget);
    expect(find.text('160–175'), findsOneWidget);
    expect(find.text('Recovery Recommendation'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('5–8 min'), findsOneWidget);
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('Ready in 24 hours'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'View Recommended Stretches'),
      findsOneWidget,
    );
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);
  });

  testWidgets('View XP Update opens reward screen and Go Home exits it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'View XP Update'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'View XP Update'));
    await tester.pumpAndSettle();

    expect(find.text('XP & Streak Update'), findsOneWidget);
    expect(find.text('Nice work, Jinseo!'), findsOneWidget);
    expect(find.text('+120 XP'), findsOneWidget);
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('2,520 XP'), findsOneWidget);
    expect(find.text('5 \u2192 6 days'), findsOneWidget);
    expect(find.text('Great consistency!'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Go Home'), findsOneWidget);
    expect(
      find.textContaining(_forbiddenXpUpdateCompetitiveCopy),
      findsNothing,
    );

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Go Home'));
    await tester.tap(find.widgetWithText(FilledButton, 'Go Home'));
    await tester.pumpAndSettle();

    expect(find.text('XP & Streak Update'), findsNothing);
    expect(find.text('Saturday Morning Run'), findsOneWidget);
  });

  testWidgets('XP Update renders supplied backend-ready display model values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: XpUpdateScreen(
          model: XpUpdateDisplayModel(
            runnerName: 'Maya',
            earnedXpLabel: '+80 XP',
            totalXpLabel: '1,840 XP',
            levelLabel: '9',
            nextLevelLabel: '10',
            progressTargetLabel: 'Progress to Lv.10',
            xpRemainingLabel: '220 XP to go',
            previousProgressFraction: 0.41,
            currentProgressFraction: 0.49,
            streakChangeLabel: '2 \u2192 3 days',
            streakNote: 'Steady return!',
            didLevelUp: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nice work, Maya!'), findsOneWidget);
    expect(find.text('+80 XP'), findsOneWidget);
    expect(find.text('1,840 XP'), findsOneWidget);
    expect(find.text('Lv.9'), findsOneWidget);
    expect(find.text('Progress to Lv.10'), findsOneWidget);
    expect(find.text('220 XP to go'), findsOneWidget);
    expect(find.text('2 \u2192 3 days'), findsOneWidget);
    expect(find.text('Steady return!'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Go Home'), findsOneWidget);
    expect(find.text('Nice work, Jinseo!'), findsNothing);
    expect(find.text('+120 XP'), findsNothing);
    expect(
      find.textContaining(_forbiddenXpUpdateCompetitiveCopy),
      findsNothing,
    );
  });

  testWidgets('XP Update source stays display-only and backend free', (
    WidgetTester tester,
  ) async {
    final screenSource = File(
      'lib/features/run/presentation/xp_update_screen.dart',
    ).readAsStringSync();
    final modelSource = File(
      'lib/features/run/presentation/models/xp_update_display_model.dart',
    ).readAsStringSync();

    expect(modelSource, contains('class XpUpdateDisplayModel'));
    expect(screenSource, contains('models/xp_update_display_model.dart'));
    expect(screenSource, isNot(contains('class RunReward')));
    expect(modelSource, isNot(contains('class RunReward')));
    expect(screenSource, isNot(contains('_demoReward')));
    expect(modelSource, isNot(contains('_demoReward')));
    for (final forbidden in [
      'calculateXP',
      'calculateXp',
      'calculateLevel',
      'calculateStreak',
      'Firebase',
      'firebase',
      'Firestore',
      'Auth',
      'SharedPreferences',
    ]) {
      expect(screenSource, isNot(contains(forbidden)));
      expect(modelSource, isNot(contains(forbidden)));
    }
    for (final forbiddenCall in [
      RegExp(r'\bcollection\s*\('),
      RegExp(r'\bdoc\s*\('),
      RegExp(r'\bset\s*\('),
      RegExp(r'\bupdate\s*\('),
    ]) {
      expect(screenSource, isNot(contains(forbiddenCall)));
      expect(modelSource, isNot(contains(forbiddenCall)));
    }
  });

  testWidgets(
    'View summary scrolls with local clamping no-overscroll behavior',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ViewSummaryScreen()));

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      final localNoOverscrollConfiguration = find.byWidgetPredicate(
        (widget) =>
            widget is ScrollConfiguration &&
            widget.behavior.runtimeType.toString() == '_NoOverscrollBehavior',
      );

      expect(scrollView.physics, isA<ClampingScrollPhysics>());
      expect(localNoOverscrollConfiguration, findsOneWidget);

      final scrollConfiguration = tester.widget<ScrollConfiguration>(
        localNoOverscrollConfiguration,
      );
      expect(
        scrollConfiguration.behavior.getScrollPhysics(
          tester.element(find.byType(SingleChildScrollView)),
        ),
        isA<ClampingScrollPhysics>(),
      );

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(find.text('View XP Update'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Cool down page fits compact screens without scroll containers', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 667);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CoolDownScreen()));

    expect(find.text('Cool down'), findsOneWidget);
    expect(find.text('Start Cool-down'), findsOneWidget);
    expect(find.text('Skip to Summary'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Cool-down'));
    await tester.pumpAndSettle();

    expect(find.text('Cool down guide'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Slow Walk'), findsOneWidget);
    expect(find.text('Walk slowly to lower your heart rate.'), findsOneWidget);
    expect(find.text('Keep your breathing relaxed.'), findsOneWidget);
    expect(find.text('Walk at an easy pace.'), findsOneWidget);
    expect(
      find.text('Let your heart rate come down gradually.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);
  });

  testWidgets('Cool down guide supports walk pause stretch and finish states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CoolDownGuideScreen(timerEnabled: false)),
    );

    expect(find.text('Cool down guide'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('REMAINING'), findsOneWidget);
    expect(find.text('Slow Walk'), findsOneWidget);
    expect(find.text('Walk slowly to lower your heart rate.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Tips'), findsOneWidget);
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Stretch'));
    await tester.pumpAndSettle();

    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('Slow Walk'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('Slow Walk'), findsNothing);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);
    expect(find.byTooltip('Resume'), findsOneWidget);

    await tester.tap(find.text('Walk'));
    await tester.pumpAndSettle();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: CoolDownGuideScreen(timerEnabled: true, initialSecondsLeft: 1),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Walk complete'), findsOneWidget);
    expect(find.byTooltip('Pause'), findsNothing);
    expect(find.text('Gentle Stretch'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: CoolDownGuideScreen(timerEnabled: false, initialSecondsLeft: 0),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Walk complete'), findsOneWidget);
    expect(
      find.text('Nicely done. Let’s move into some gentle stretching.'),
      findsOneWidget,
    );
    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('5 min · gentle recovery'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Stretch'));
    await tester.pumpAndSettle();

    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Walk complete'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('Ease through each stretch and breathe.'), findsOneWidget);
    expect(find.text('Stretch slowly — never bounce.'), findsOneWidget);
    expect(find.text('Keep your breathing steady.'), findsOneWidget);
    expect(find.text('Stop if anything feels sharp.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Gentle Stretch'), findsOneWidget);
    expect(find.text('Saturday Morning Run'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: CoolDownGuideScreen(
          timerEnabled: false,
          initialPhase: CoolDownPhase.stretch,
          initialSecondsLeft: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cool-down complete'), findsOneWidget);
    expect(
      find.text('That’s your recovery done. Great work today.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Finish'), findsOneWidget);
    expect(find.text('UP NEXT'), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.textContaining(_forbiddenRealActivitySaveCopy), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Saturday Morning Run'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View XP Update'), findsOneWidget);
    expect(find.text('XP & Streak Update'), findsNothing);
  });

  test('Run launch source isolates static display snapshots', () {
    final source = File(
      'lib/features/run/presentation/run_launch_screen.dart',
    ).readAsStringSync();

    expect(source, contains('class _RunLaunchDisplaySnapshot'));
    expect(source, contains('class _RunLiveDisplaySnapshot'));
    expect(source, contains('const _runLaunchSnapshot'));
    expect(source, contains('const _runLiveSnapshot'));
    expect(source, isNot(contains(RegExp(r'\bonCompleted\b'))));
    expect(source, isNot(contains('bool _completed')));
    expect(source, isNot(contains('completedRun')));
    expect(source, isNot(contains('calculateRunCompletion')));
    expect(source, isNot(contains('saveActivity')));
  });

  testWidgets('Android back dismisses static Run launch surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    expect(find.text('Shared Routes'), findsOneWidget);

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();
    expect(find.text('GPS ready'), findsOneWidget);
    expect(find.text('Maps'), findsNothing);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.text('GPS ready'), findsNothing);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });
}
