import 'package:flutter/material.dart';

import '../../domain/models/run_summary_snapshot.dart';
import 'share_route_feed_preview.dart';

const _rBlue = Color(0xFF2F51C8);
const _rWhite = Color(0xFFFFFFFF);
const _rBlue60 = Color(0x992F51C8);
const _rBlue30 = Color(0x4D2F51C8);
const _rBlue18 = Color(0x2E2F51C8);

class ShareRouteToFeedSheet extends StatelessWidget {
  const ShareRouteToFeedSheet({
    required this.summary,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  final RunSummarySnapshot summary;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _rWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _rBlue18,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Share route to Feed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _rBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary.dateTimeLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _rBlue60,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Semantics(
                  label: 'Route thumbnail for ${summary.routeName}',
                  image: true,
                  child: ExcludeSemantics(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 132,
                        child: const ShareRouteFeedPreview(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  summary.routeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _rBlue60,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _ShareRouteMetrics(summary: summary),
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _rBlue,
                    side: const BorderSide(color: _rBlue30, width: 1.5),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  style: FilledButton.styleFrom(
                    backgroundColor: _rBlue,
                    foregroundColor: _rWhite,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  label: const Text('Post to Feed'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareRouteMetrics extends StatelessWidget {
  const _ShareRouteMetrics({required this.summary});

  final RunSummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ShareRouteMetric(label: 'Distance', value: '${summary.distanceKm} km'),
        const _ShareRouteMetricDivider(),
        _ShareRouteMetric(label: 'Pace', value: '${summary.avgPace} / km'),
        const _ShareRouteMetricDivider(),
        _ShareRouteMetric(label: 'Time', value: summary.duration),
      ],
    );
  }
}

class _ShareRouteMetric extends StatelessWidget {
  const _ShareRouteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _rBlue60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _rBlue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareRouteMetricDivider extends StatelessWidget {
  const _ShareRouteMetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: _rBlue18,
    );
  }
}
