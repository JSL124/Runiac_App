import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';

class RoutePreviewCard extends StatelessWidget {
  const RoutePreviewCard({
    required this.title,
    required this.message,
    this.likeActionKey,
    this.likeCountLabel,
    this.onTap,
    super.key,
  });

  final String title;
  final String message;
  final Key? likeActionKey;
  final String? likeCountLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);

    return RuniacTappableSurface(
      onTap: onTap,
      borderRadius: borderRadius,
      height: 92,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: borderRadius,
        border: Border.all(color: RuniacColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A172033),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      semanticsButton: onTap != null,
      child: Row(
        children: [
          const _RouteThumbnailPlaceholder(),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RuniacColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (likeCountLabel != null && likeActionKey != null) ...[
                  const SizedBox(width: 8),
                  _RouteLikeAction(
                    actionKey: likeActionKey!,
                    countLabel: likeCountLabel!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLikeAction extends StatefulWidget {
  const _RouteLikeAction({required this.actionKey, required this.countLabel});

  final Key actionKey;
  final String countLabel;

  @override
  State<_RouteLikeAction> createState() => _RouteLikeActionState();
}

class _RouteLikeActionState extends State<_RouteLikeAction> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _isLiked ? 'Unlike route' : 'Like route',
      button: true,
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              key: widget.actionKey,
              tooltip: _isLiked ? 'Unlike route' : 'Like route',
              onPressed: () => setState(() => _isLiked = !_isLiked),
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: RuniacColors.primaryBlue,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            const SizedBox(width: 2),
            Text(
              widget.countLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteThumbnailPlaceholder extends StatelessWidget {
  const _RouteThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RuniacColors.sectionSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RuniacColors.cardBorder),
        ),
        child: const CustomPaint(painter: _RouteThumbnailPainter()),
      ),
    );
  }
}

class _RouteThumbnailPainter extends CustomPainter {
  const _RouteThumbnailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = RuniacColors.white
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(-6, 8),
        Offset(size.width + 6, size.height - 10),
        roadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.58, -4),
        Offset(size.width * 0.35, size.height + 4),
        roadPaint,
      );

    final routePaint = Paint()
      ..color = RuniacColors.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final routePath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.68)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.24,
        size.width * 0.62,
        size.height * 0.84,
        size.width * 0.78,
        size.height * 0.36,
      );
    canvas.drawPath(routePath, routePaint);

    final startPaint = Paint()..color = RuniacColors.accentOrange;
    final endPaint = Paint()..color = RuniacColors.primaryBlue;
    canvas
      ..drawCircle(Offset(size.width * 0.24, size.height * 0.68), 4, startPaint)
      ..drawCircle(Offset(size.width * 0.78, size.height * 0.36), 4, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
