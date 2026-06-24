import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';
import '../../../run/domain/models/run_activity_display_model.dart';
import 'activity_route_preview.dart';

class CompactRunActivityCard extends StatelessWidget {
  const CompactRunActivityCard({
    required this.activity,
    required this.onTap,
    super.key,
  });

  final RunActivityDisplayModel activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      onTap: onTap,
      semanticLabel: 'Open ${activity.title} summary',
      borderRadius: BorderRadius.circular(20),
      constraints: const BoxConstraints(minHeight: 114),
      padding: const EdgeInsets.all(12),
      decoration: _historyCardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ActivityRoutePreview(route: activity.summary.route),
          const SizedBox(width: 18),
          Expanded(
            child: _ActivityCardContent(
              key: const ValueKey('activity_card_content'),
              activity: activity,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCardContent extends StatelessWidget {
  const _ActivityCardContent({required this.activity, super.key});

  final RunActivityDisplayModel activity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _cardTitleStyle,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(activity.timeAgoLabel, style: _cardDateStyle),
            Text(activity.sourceLabel, style: _cardSourceStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Metric(value: activity.distanceLabel, label: 'Distance'),
            ),
            const _MetricDivider(),
            Expanded(
              child: _Metric(value: activity.paceLabel, label: 'Avg Pace'),
            ),
            const _MetricDivider(),
            Expanded(
              child: _Metric(value: activity.durationLabel, label: 'Time'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 34,
      child: VerticalDivider(width: 18, thickness: 1, color: Color(0xFFDDE5FA)),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final distanceParts = label == 'Distance' && value.endsWith(' km')
        ? value.split(' ')
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (distanceParts == null)
          _MetricValueText(child: Text(value, style: _metricValueStyle))
        else
          _MetricValueText(
            child: Text.rich(
              TextSpan(
                text: distanceParts.first,
                style: _metricValueStyle,
                children: const [
                  TextSpan(text: ' km', style: _metricUnitStyle),
                ],
              ),
            ),
          ),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: _metricLabelStyle),
      ],
    );
  }
}

class _MetricValueText extends StatelessWidget {
  const _MetricValueText({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

final _historyCardDecoration = BoxDecoration(
  color: RuniacColors.white,
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: RuniacColors.cardBorder, width: 1.1),
  boxShadow: const [
    BoxShadow(
      color: RuniacColors.softCardShadow,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ],
);

const _cardTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 17,
  fontWeight: FontWeight.w900,
  height: 1.1,
);
const _cardDateStyle = TextStyle(
  color: Color(0xFF7D93E1),
  fontSize: 13,
  fontWeight: FontWeight.w700,
);
const _cardSourceStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 12,
  fontWeight: FontWeight.w800,
);
const _metricValueStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 17,
  fontWeight: FontWeight.w900,
  height: 1,
);
const _metricUnitStyle = TextStyle(
  color: Color(0xFFA4B3EA),
  fontSize: 11,
  fontWeight: FontWeight.w800,
);
const _metricLabelStyle = TextStyle(
  color: Color(0xFFA4B3EA),
  fontSize: 10,
  fontWeight: FontWeight.w800,
);
