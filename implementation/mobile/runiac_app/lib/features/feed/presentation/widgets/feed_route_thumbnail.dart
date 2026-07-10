import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../domain/models/feed_display_models.dart';

class FeedRouteThumbnail extends StatelessWidget {
  const FeedRouteThumbnail({required this.thumbnail, super.key});

  final FeedRouteThumbnailReadModel thumbnail;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: thumbnail.accessibilityLabel,
      image: true,
      container: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 212,
          width: double.infinity,
          child: CustomPaint(
            painter: _FeedRouteThumbnailPainter(thumbnail.thumbnailKey),
          ),
        ),
      ),
    );
  }
}

class _FeedRouteThumbnailPainter extends CustomPainter {
  _FeedRouteThumbnailPainter(this.thumbnailKey);

  final String thumbnailKey;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = RuniacColors.sectionSurface,
    );

    final roadPaint = Paint()
      ..color = RuniacColors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final routePaint = Paint()
      ..color = RuniacColors.primaryBlue
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final highlightPaint = Paint()
      ..color = RuniacColors.accentOrange
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final road = Path()
      ..moveTo(-20, size.height * .22)
      ..cubicTo(
        size.width * .18,
        size.height * .44,
        size.width * .42,
        -8,
        size.width * .68,
        size.height * .26,
      )
      ..cubicTo(
        size.width * .8,
        size.height * .4,
        size.width * .92,
        size.height * .42,
        size.width + 16,
        size.height * .3,
      );
    canvas.drawPath(road, roadPaint);

    final crossRoad = Path()
      ..moveTo(size.width * .18, -12)
      ..cubicTo(
        size.width * .38,
        size.height * .26,
        size.width * .56,
        size.height * .58,
        size.width * .8,
        size.height + 10,
      );
    canvas.drawPath(crossRoad, roadPaint);

    final isEastCoast = thumbnailKey == 'east-coast-easy-loop';
    final route = Path()
      ..moveTo(size.width * (isEastCoast ? .17 : .24), size.height * .67)
      ..cubicTo(
        size.width * .32,
        size.height * .26,
        size.width * .62,
        size.height * .18,
        size.width * .75,
        size.height * .43,
      )
      ..cubicTo(
        size.width * .87,
        size.height * .67,
        size.width * .58,
        size.height * .82,
        size.width * .39,
        size.height * .68,
      )
      ..cubicTo(
        size.width * .26,
        size.height * .58,
        size.width * .22,
        size.height * .56,
        size.width * (isEastCoast ? .17 : .24),
        size.height * .67,
      );
    canvas.drawPath(route, routePaint);
    canvas.drawCircle(
      Offset(size.width * (isEastCoast ? .17 : .24), size.height * .67),
      6,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FeedRouteThumbnailPainter oldDelegate) {
    return oldDelegate.thumbnailKey != thumbnailKey;
  }
}
