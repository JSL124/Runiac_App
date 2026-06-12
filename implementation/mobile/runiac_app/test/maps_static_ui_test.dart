import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

final _forbiddenBackendOwnedCopy = RegExp(
  r'\bXP\b|streak|level|rank|score|saved count|popularity|owned|'
  r'territory owned|route completed|activity saved|synced|premium|'
  r'subscription',
  caseSensitive: false,
);

void main() {
  testWidgets('Maps tab shows static route discovery placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    expect(find.text('Marina Bay easy loop'), findsOneWidget);
    expect(find.text('3.2 km · 25 min · Easy'), findsOneWidget);
    expect(find.text('Route preview'), findsNothing);
    expect(
      find.text('A calm route card can guide the next step later.'),
      findsNothing,
    );

    await tester.drag(find.text('Shared Routes'), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('Beginner-friendly route ideas'), findsNothing);
    expect(find.text('Preview'), findsNothing);
    expect(find.text('Bishan Park starter route'), findsOneWidget);
    expect(find.text('2.4 km · 18 min · Easy'), findsOneWidget);

    expect(find.text('East Coast flat run'), findsOneWidget);
    expect(find.text('4.0 km · 32 min · Easy'), findsOneWidget);
    expect(find.text('Shared routes'), findsNothing);
    expect(find.text('Saved routes'), findsNothing);
    expect(find.textContaining(_forbiddenBackendOwnedCopy), findsNothing);
  });

  testWidgets('Maps search field accepts focus and visible typed input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    expect(find.text('Punggol waterway loop'), findsNothing);
    expect(find.text('Kallang riverside run'), findsNothing);

    await tester.tap(find.byKey(const Key('maps_see_all_shared_routes')));
    await tester.pumpAndSettle();

    expect(find.text('Shared Routes'), findsOneWidget);
    expect(find.text('All shared routes'), findsNothing);
    expect(find.text('See all'), findsNothing);
    expect(find.text('Show less'), findsOneWidget);
    expect(find.text('Marina Bay easy loop'), findsOneWidget);
    expect(find.text('Bishan Park starter route'), findsOneWidget);
    expect(find.text('East Coast flat run'), findsOneWidget);
    expect(find.text('Punggol waterway loop'), findsOneWidget);
    expect(find.text('3.6 km · 28 min · Easy'), findsOneWidget);
    expect(tester.getTopLeft(sheetSurface).dy, lessThan(initialTop));
    expect(tester.getSize(sheetSurface).height, closeTo(screenHeight * 0.7, 1));
    expect(
      find.byKey(const Key('maps_expanded_shared_routes_list')),
      findsOneWidget,
    );

    final expandedTop = tester.getTopLeft(sheetSurface).dy;
    final expandedHeight = tester.getSize(sheetSurface).height;

    await tester.scrollUntilVisible(
      find.text('Kallang riverside run'),
      120,
      scrollable: find.descendant(
        of: find.byKey(const Key('maps_expanded_shared_routes_list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kallang riverside run'), findsOneWidget);
    expect(find.text('3.0 km · 23 min · Easy'), findsOneWidget);
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
    expect(find.text('Punggol waterway loop'), findsNothing);
    expect(find.text('Kallang riverside run'), findsNothing);
  });

  testWidgets(
    'Maps manual collapse from expanded routes resets to preview state',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp(showSplash: false));

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();

      final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
      final initialTop = tester.getTopLeft(sheetSurface).dy;

      await tester.tap(find.byKey(const Key('maps_see_all_shared_routes')));
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);
      expect(find.text('Punggol waterway loop'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('maps_sheet_handle')),
        const Offset(0, 700),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsNothing);
      expect(find.text('Show less'), findsNothing);
      expect(find.text('Punggol waterway loop'), findsNothing);

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
      expect(find.text('Punggol waterway loop'), findsNothing);
    },
  );

  testWidgets('Maps Saved opens static My routes page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    expect(find.text('Route changing preview is coming soon.'), findsOneWidget);

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
      await tester.pumpWidget(const RuniacApp(showSplash: false));

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
      expect(
        find.text('Route changing preview is coming soon.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Maps sheet keeps a non-scrolling Home-style accent layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    for (final key in const [
      Key('route_preview_card_marina_bay_easy_loop'),
      Key('route_preview_card_bishan_park_starter_route'),
      Key('route_preview_card_east_coast_flat_run'),
    ]) {
      expect(tester.getSize(find.byKey(key)).height, 92);
    }

    final routeTitle = tester.widget<Text>(find.text('Marina Bay easy loop'));
    final routeMessage = tester.widget<Text>(
      find.text('3.2 km · 25 min · Easy'),
    );

    expect(routeTitle.maxLines, 1);
    expect(routeTitle.overflow, TextOverflow.ellipsis);
    expect(routeMessage.maxLines, 2);
    expect(routeMessage.overflow, TextOverflow.ellipsis);
  });

  testWidgets(
    'Maps shared route detail opens from first card and renders static route content',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RuniacApp(showSplash: false));

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marina Bay easy loop'));
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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marina Bay easy loop'));
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
      await tester.pumpWidget(const RuniacApp(showSplash: false));

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marina Bay easy loop'));
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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marina Bay easy loop'));
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
      await tester.pumpWidget(const RuniacApp(showSplash: false));

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marina Bay easy loop'));
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
      await tester.pumpWidget(const RuniacApp(showSplash: false));

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marina Bay easy loop'));
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
      await tester.pumpWidget(const RuniacApp(showSplash: false));

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsOneWidget);
      expect(find.text('Bishan Park starter route'), findsOneWidget);
      expect(find.text('East Coast flat run'), findsOneWidget);

      await tester.tap(find.text('Marina Bay easy loop'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Shared Routes'), findsOneWidget);
      expect(find.text('Marina Bay easy loop'), findsOneWidget);

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
    final initialTop = tester.getTopLeft(sheetSurface).dy;

    expect(find.text('Marina Bay easy loop'), findsOneWidget);
    expect(find.text('Bishan Park starter route'), findsOneWidget);
    expect(find.text('East Coast flat run'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('maps_sheet_handle')),
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(sheetSurface).dy, initialTop);
    expect(find.text('East Coast flat run'), findsOneWidget);
  });

  testWidgets(
    'Maps sheet height fits the shared route content bottom padding',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const RuniacApp(showSplash: false));

      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();

      final sheetSurface = find.byKey(const Key('maps_sheet_surface'));
      final savedRouteCard = find.byKey(
        const Key('route_preview_card_east_coast_flat_run'),
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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
    await tester.pumpWidget(const RuniacApp(showSplash: false));

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
}
