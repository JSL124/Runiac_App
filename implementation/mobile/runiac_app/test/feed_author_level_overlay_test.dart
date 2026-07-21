import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/feed/data/firebase_feed_repository/feed_data_port.dart';
import 'package:runiac_app/features/feed/data/firebase_feed_repository/feed_test_data_port.dart';
import 'package:runiac_app/features/feed/data/firebase_feed_repository/firebase_feed_repository.dart';
import 'package:runiac_app/features/feed/domain/models/feed_display_models.dart';

void main() {
  const viewer = FeedViewerContext(
    currentUserId: 'viewer',
    acceptedFriendUserIds: <String>{},
  );

  test(
    'a resolved live author level overrides a post\'s stored label and progress',
    () async {
      final port = FeedTestDataPort.withSingleFriend('friend-01');
      port.authorLevels['friend-01'] = const FeedAuthorLevel(
        levelLabel: 'Level 12',
        levelProgressFraction: 0.75,
      );
      final repository = FirebaseFeedRepository(port: port);

      final state = await repository.loadInitial(viewer);

      final post = state.posts.singleWhere(
        (post) => post.authorUserId == 'friend-01',
      );
      expect(post.authorLevelLabel, 'Level 12');
      expect(post.authorLevelProgressFraction, 0.75);
      expect(port.authorLevelQueries, hasLength(1));
    },
  );

  test(
    'an author the resolver has nothing for leaves the stored label intact '
    'and the progress fraction unresolved',
    () async {
      final port = FeedTestDataPort.withSingleFriend('friend-02');
      final repository = FirebaseFeedRepository(port: port);

      final state = await repository.loadInitial(viewer);

      final post = state.posts.single;
      expect(post.authorLevelLabel, 'Level 3');
      expect(post.authorLevelProgressFraction, isNull);
    },
  );

  test(
    'a port failure leaves the stored label intact and never throws out of '
    'the loader, and leaves the progress fraction unresolved',
    () async {
      final port = FeedTestDataPort.withSingleFriend('friend-03');
      port.authorLevels['friend-03'] = const FeedAuthorLevel(
        levelLabel: 'Level 99',
        levelProgressFraction: 0.99,
      );
      port.authorLevelsError = Exception('offline');
      final repository = FirebaseFeedRepository(port: port);

      final state = await repository.loadInitial(viewer);

      expect(state.recoverableError, isNull);
      final post = state.posts.single;
      expect(post.authorLevelLabel, 'Level 3');
      expect(post.authorLevelProgressFraction, isNull);
    },
  );

  test(
    'a resolved empty levelLabel leaves the stored label intact and the '
    'progress fraction unresolved',
    () async {
      final port = FeedTestDataPort.withSingleFriend('friend-07');
      port.authorLevels['friend-07'] = const FeedAuthorLevel(
        levelLabel: '',
        levelProgressFraction: 0.42,
      );
      final repository = FirebaseFeedRepository(port: port);

      final state = await repository.loadInitial(viewer);

      final post = state.posts.single;
      expect(post.authorLevelLabel, 'Level 3');
      expect(post.authorLevelProgressFraction, isNull);
    },
  );

  test('pull-to-refresh invalidates the cache and re-resolves', () async {
    final port = FeedTestDataPort.withSingleFriend('friend-04');
    port.authorLevels['friend-04'] = const FeedAuthorLevel(
      levelLabel: 'Level 1',
      levelProgressFraction: 0.1,
    );
    final repository = FirebaseFeedRepository(port: port);
    await repository.loadInitial(viewer);
    expect(port.authorLevelQueries, hasLength(1));

    port.authorLevels['friend-04'] = const FeedAuthorLevel(
      levelLabel: 'Level 2',
      levelProgressFraction: 0.2,
    );
    final refreshed = await repository.refresh();

    expect(port.authorLevelQueries, hasLength(2));
    expect(refreshed.posts.single.authorLevelLabel, 'Level 2');
  });

  test(
    'the same live-level overlay applies to a comment\'s stored label and progress',
    () async {
      final port = FeedTestDataPort.withSingleFriend('friend-05')
        ..addTiedComments(2);
      port.authorLevels['friend'] = const FeedAuthorLevel(
        levelLabel: 'Level 20',
        levelProgressFraction: 0.9,
      );
      final repository = FirebaseFeedRepository(port: port);
      await repository.loadInitial(viewer);

      final page = await repository.loadComments(postId: 'post-1');

      final resolvedComment = page.comments.firstWhere(
        (comment) => comment.authorUserId == 'friend',
      );
      expect(resolvedComment.authorLevelLabel, 'Level 20');
      expect(resolvedComment.authorLevelProgressFraction, 0.9);

      final unresolvedComment = page.comments.firstWhere(
        (comment) => comment.authorUserId == 'viewer',
      );
      expect(unresolvedComment.authorLevelLabel, 'Level 3');
      expect(unresolvedComment.authorLevelProgressFraction, isNull);
    },
  );

  test(
    'a comment author the resolver has nothing for keeps its stored label '
    'and leaves the progress fraction unresolved',
    () async {
      final port = FeedTestDataPort.withSingleFriend('friend-06')
        ..addTiedComments(2)
        ..authorLevelsError = Exception('not deployed yet');
      final repository = FirebaseFeedRepository(port: port);
      await repository.loadInitial(viewer);

      final page = await repository.loadComments(postId: 'post-1');

      expect(page.comments, hasLength(2));
      for (final comment in page.comments) {
        expect(comment.authorLevelLabel, 'Level 3');
        expect(comment.authorLevelProgressFraction, isNull);
      }
    },
  );

  test(
    'a comment with a resolved empty levelLabel keeps its stored label and '
    'leaves the progress fraction unresolved',
    () async {
      final port = FeedTestDataPort.withSingleFriend('friend-08')
        ..addTiedComments(2);
      port.authorLevels['friend'] = const FeedAuthorLevel(
        levelLabel: '',
        levelProgressFraction: 0.5,
      );
      final repository = FirebaseFeedRepository(port: port);
      await repository.loadInitial(viewer);

      final page = await repository.loadComments(postId: 'post-1');

      final comment = page.comments.firstWhere(
        (comment) => comment.authorUserId == 'friend',
      );
      expect(comment.authorLevelLabel, 'Level 3');
      expect(comment.authorLevelProgressFraction, isNull);
    },
  );
}
