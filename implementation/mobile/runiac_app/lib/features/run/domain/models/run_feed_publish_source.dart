enum FeedPublishDisabledReason {
  notAvailable,
  localOnly,
  notValidated,
  orphanSummary,
  insufficientData,
}

class RunFeedPublishSource {
  const RunFeedPublishSource._({
    required this.activityId,
    required this.cacheIdentity,
    required this.disabledReason,
    required this.allowsCurrentSessionRouteCapture,
    required this.allowsMetricThumbnailFallback,
  });

  const RunFeedPublishSource.enabled({
    required String activityId,
    String? cacheIdentity,
    bool allowsCurrentSessionRouteCapture = false,
    bool allowsMetricThumbnailFallback = true,
  }) : this._(
         activityId: activityId,
         cacheIdentity: cacheIdentity,
         disabledReason: null,
         allowsCurrentSessionRouteCapture: allowsCurrentSessionRouteCapture,
         allowsMetricThumbnailFallback: allowsMetricThumbnailFallback,
       );

  const RunFeedPublishSource.disabled(FeedPublishDisabledReason reason)
    : this._(
        activityId: null,
        cacheIdentity: null,
        disabledReason: reason,
        allowsCurrentSessionRouteCapture: false,
        allowsMetricThumbnailFallback: false,
      );

  final String? activityId;
  final String? cacheIdentity;
  final FeedPublishDisabledReason? disabledReason;
  final bool allowsCurrentSessionRouteCapture;
  final bool allowsMetricThumbnailFallback;

  bool get isPublishable => activityId != null && disabledReason == null;
}
