import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';
import '../../../run/domain/models/run_activity_display_model.dart';

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
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: _historyCardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _RouteIconTile(seed: activity.title.length),
          const SizedBox(width: 14),
          Expanded(child: _ActivityCardContent(activity: activity)),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFB8C5EE),
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _RouteIconTile extends StatelessWidget {
  const _RouteIconTile({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: _routeTileDecoration,
      child: CustomPaint(painter: _RouteIconPainter(seed)),
    );
  }
}

class _RouteIconPainter extends CustomPainter {
  const _RouteIconPainter(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = RuniacColors.primaryBlue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()..color = RuniacColors.accentOrange;
    final startPaint = Paint()
      ..color = RuniacColors.white
      ..style = PaintingStyle.fill;
    final startBorderPaint = Paint()
      ..color = RuniacColors.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final low = seed.isEven ? 0.62 : 0.55;
    final high = seed.isEven ? 0.40 : 0.48;
    final path = Path()
      ..moveTo(size.width * 0.30, size.height * low)
      ..cubicTo(
        size.width * 0.44,
        size.height * 0.58,
        size.width * 0.46,
        size.height * high,
        size.width * 0.62,
        size.height * high,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * high,
        size.width * 0.78,
        size.height * 0.36,
      );

    canvas.drawPath(path, pathPaint);
    canvas.drawCircle(
      Offset(size.width * 0.30, size.height * low),
      5,
      startPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.30, size.height * low),
      5,
      startBorderPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.36),
      6,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RouteIconPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

class _ActivityCardContent extends StatelessWidget {
  const _ActivityCardContent({required this.activity});

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
          Text(value, style: _metricValueStyle)
        else
          Text.rich(
            TextSpan(
              text: distanceParts.first,
              style: _metricValueStyle,
              children: const [TextSpan(text: ' km', style: _metricUnitStyle)],
            ),
          ),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: _metricLabelStyle),
      ],
    );
  }
}

final _routeTileDecoration = BoxDecoration(
  color: RuniacColors.sectionSurface,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: RuniacColors.cardBorder, width: 1.4),
);

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
