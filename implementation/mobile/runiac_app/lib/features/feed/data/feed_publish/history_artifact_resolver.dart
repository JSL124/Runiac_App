import '../../../you/presentation/widgets/activity_route_preview.dart';
import '../../../you/presentation/widgets/activity_route_snapshot_thumbnail_cache.dart';
import 'feed_thumbnail_artifact.dart';
import 'feed_thumbnail_capture.dart';

abstract interface class HistoryArtifactResolver {
  Future<FeedThumbnailArtifact?> resolve(ActivityRouteThumbnailRequest request);
}

class CacheOnlyHistoryArtifactResolver implements HistoryArtifactResolver {
  CacheOnlyHistoryArtifactResolver({
    ActivityRouteSnapshotThumbnailMemoryCache? cache,
    String? Function()? ownerUidProvider,
  }) : _provider = CachedActivityRouteThumbnailProvider(
         cache: cache ?? ActivityRouteSnapshotThumbnailMemoryCache(),
         ownerUidProvider: ownerUidProvider,
       );

  final ActivityRouteThumbnailProvider _provider;

  @override
  Future<FeedThumbnailArtifact?> resolve(
    ActivityRouteThumbnailRequest request,
  ) async {
    try {
      return await FeedThumbnailCapture(provider: _provider).capture(request);
    } on FeedThumbnailCaptureException {
      return null;
    }
  }
}
