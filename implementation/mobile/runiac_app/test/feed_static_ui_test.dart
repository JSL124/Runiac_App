import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/feed/domain/models/feed_display_models.dart';
import 'package:runiac_app/features/feed/domain/repositories/feed_repository.dart';
import 'package:runiac_app/features/feed/presentation/current_session_feed.dart';
import 'package:runiac_app/features/you/presentation/widgets/you_surface_primitives.dart';

void main() {
  Future<SemanticsHandle> pumpFeed(WidgetTester tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CurrentSessionFeed())),
    );
    await tester.pumpAndSettle();
    return semantics;
  }

  testWidgets(
    'Feed uses the shared header treatment without a refresh button',
    (WidgetTester tester) async {
      final semantics = await pumpFeed(tester);

      expect(find.text('Feed'), findsOneWidget);
      expect(find.byType(YouHeaderAccentStrip), findsOneWidget);
      expect(find.byTooltip('Refresh'), findsNothing);
      semantics.dispose();
    },
  );

  testWidgets('Feed shows static posts as full-width divider sections', (
    WidgetTester tester,
  ) async {
    final semantics = await pumpFeed(tester);

    expect(find.text('Runiac Runner'), findsOneWidget);
    expect(find.text('Jamie Tan'), findsOneWidget);
    expect(find.text('3.2 km'), findsOneWidget);
    expect(find.text('7:20 / km'), findsOneWidget);
    expect(find.text('23 min'), findsOneWidget);
    expect(
      find.bySemanticsLabel('A simplified route preview'),
      findsNWidgets(2),
    );
    expect(
      find.byKey(const ValueKey('feed-post-divider-feed-current-001')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('feed-post-divider-feed-friend-001')),
      findsOneWidget,
    );
    expect(find.byType(Card), findsNothing);
    semantics.dispose();
  });

  testWidgets('Feed exposes pull-to-refresh and read-only engagement actions', (
    WidgetTester tester,
  ) async {
    final semantics = await pumpFeed(tester);

    final refreshIndicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );

    expect(refreshIndicator.onRefresh, isNotNull);
    expect(find.bySemanticsLabel('Like 4 likes'), findsOneWidget);
    expect(find.bySemanticsLabel('Comment 1 comment'), findsOneWidget);
    expect(find.bySemanticsLabel('Post options'), findsNWidgets(2));
    semantics.dispose();
  });

  testWidgets('Feed shows an empty state after a successful empty load', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrentSessionFeed(repository: _EmptyFeedRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No shared runs yet.'), findsOneWidget);
    expect(
      find.text('Runs shared by you and accepted friends will appear here.'),
      findsOneWidget,
    );
    expect(find.byType(RefreshIndicator), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Feed error state can retry and recover', (
    WidgetTester tester,
  ) async {
    final repository = _RecoveringFeedRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CurrentSessionFeed(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feed could not refresh.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(repository.loadCount, 2);
    expect(find.text('Recovered Runner'), findsOneWidget);
    expect(find.text('Feed could not refresh.'), findsNothing);
  });

  testWidgets('Feed disables comments when a visible post cannot be commented', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrentSessionFeed(repository: _NonCommentableFeedRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quiet Runner'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('feed-comment-action-feed-quiet-001')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Comments'), findsNothing);
  });
}

class _EmptyFeedRepository implements FeedRepository {
  @override
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext) async {
    return FeedReadModel(posts: const []);
  }
}

class _RecoveringFeedRepository implements FeedRepository {
  var loadCount = 0;

  @override
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext) async {
    loadCount += 1;
    if (loadCount == 1) {
      throw StateError('temporary feed failure');
    }
    return FeedReadModel(
      posts: const [
        FeedPostReadModel(
          postId: 'feed-recovered-001',
          authorUserId: 'runner-current',
          authorDisplayName: 'Recovered Runner',
          authorAvatarInitials: 'RR',
          relativeTimeLabel: 'Now',
          distanceLabel: '2.0 km',
          paceLabel: '7:00 / km',
          durationLabel: '14 min',
          likeCount: 0,
          commentCount: 0,
          isLikedByViewer: false,
          hasViewerCommented: false,
          canComment: true,
          showsOwnerMenu: true,
          routeThumbnail: FeedRouteThumbnailReadModel(
            thumbnailKey: 'recovered-preview',
            accessibilityLabel: 'Recovered route preview',
          ),
        ),
      ],
    );
  }
}

class _NonCommentableFeedRepository implements FeedRepository {
  @override
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext) async {
    return FeedReadModel(
      posts: const [
        FeedPostReadModel(
          postId: 'feed-quiet-001',
          authorUserId: 'runner-friend',
          authorDisplayName: 'Quiet Runner',
          authorAvatarInitials: 'QR',
          relativeTimeLabel: 'Today',
          distanceLabel: '1.8 km',
          paceLabel: '8:10 / km',
          durationLabel: '15 min',
          likeCount: 0,
          commentCount: 0,
          isLikedByViewer: false,
          hasViewerCommented: false,
          canComment: false,
          showsOwnerMenu: false,
          routeThumbnail: FeedRouteThumbnailReadModel(
            thumbnailKey: 'quiet-preview',
            accessibilityLabel: 'Quiet route preview',
          ),
        ),
      ],
    );
  }
}
