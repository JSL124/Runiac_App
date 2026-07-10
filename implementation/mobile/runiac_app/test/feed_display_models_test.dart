import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/feed/data/static_feed_repository.dart';
import 'package:runiac_app/features/feed/domain/models/feed_display_models.dart';

void main() {
  group('Feed display models', () {
    test(
      'Feed route preview payload omits raw coordinate-like values',
      () async {
        const feed = StaticFeedRepository();
        final readModel = await feed.loadFeed(
          const FeedViewerContext(
            currentUserId: 'runner-current',
            acceptedFriendUserIds: <String>{'runner-friend'},
          ),
        );
        final coordinatePattern = RegExp(
          r'(-?\d{1,3}\.\d{4,})\s*[,|]\s*(-?\d{1,3}\.\d{4,})',
        );
        final coordinateTerms = RegExp(
          r'\b(lat|latitude|lng|lon|longitude|coordinate|polyline)\b',
          caseSensitive: false,
        );

        for (final post in readModel.posts) {
          final routePreviewPayload = [
            post.routeThumbnail.thumbnailKey,
            post.routeThumbnail.accessibilityLabel,
            post.routeName,
          ].whereType<String>().join(' ');

          expect(
            routePreviewPayload,
            isNot(matches(coordinatePattern)),
            reason: post.postId,
          );
          expect(
            routePreviewPayload,
            isNot(matches(coordinateTerms)),
            reason: post.postId,
          );
        }
      },
    );
  });
}
