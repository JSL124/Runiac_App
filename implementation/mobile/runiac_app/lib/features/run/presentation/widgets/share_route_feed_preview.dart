import 'package:flutter/material.dart';

import '../../../feed/data/feed_publish/feed_thumbnail_artifact.dart';
import '../../domain/models/run_summary_snapshot.dart';

class ShareRouteFeedPreview extends StatelessWidget {
  const ShareRouteFeedPreview({
    required this.artifact,
    required this.routeName,
    super.key,
  });

  final FeedThumbnailArtifact? artifact;
  final String routeName;

  @override
  Widget build(BuildContext context) => Semantics(
    label: artifact == null
        ? 'Route thumbnail unavailable'
        : 'Route thumbnail for $routeName',
    image: artifact != null,
    child: ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 132,
          child: artifact == null
              ? const ColoredBox(color: Color(0xFFEFF3FF))
              : Image(image: artifact!.memoryImage, fit: BoxFit.cover),
        ),
      ),
    ),
  );
}

class ShareRouteMetrics extends StatelessWidget {
  const ShareRouteMetrics({required this.summary, super.key});
  final RunSummarySnapshot summary;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Metric('Distance', '${summary.distanceKm} km'),
      const _Divider(),
      _Metric('Pace', '${summary.avgPace} / km'),
      const _Divider(),
      _Metric('Time', summary.duration),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0x992F51C8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF2F51C8),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: const Color(0x2E2F51C8),
  );
}
