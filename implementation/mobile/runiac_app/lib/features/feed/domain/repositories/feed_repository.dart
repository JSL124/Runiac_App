import '../models/feed_display_models.dart';

abstract interface class FeedRepository {
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext);
}
