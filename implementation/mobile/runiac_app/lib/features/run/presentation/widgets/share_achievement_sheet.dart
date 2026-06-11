import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const _blue = Color(0xFF2F51C8);
const _blueBright = Color(0xFF3E63E6);
const _orange = Color(0xFFFB6414);
const _surface = Color(0xFFF4F7FF);
const _card = Color(0xFFFFFFFF);
const _ink = Color(0xFF16235C);
const _blue75 = Color(0xBF2F51C8);
const _blue60 = Color(0x992F51C8);
const _blue22 = Color(0x382F51C8);
const _blue18 = Color(0x2E2F51C8);
const _blue12 = Color(0x1F2F51C8);
const _blue10 = Color(0x1A2F51C8);
const _orange22 = Color(0x38FB6414);
const _instagramStoriesIconAsset = 'assets/icons/instagram_stories.png';

class ShareAchievementSheet extends StatelessWidget {
  const ShareAchievementSheet({super.key});

  void _showPlaceholderFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.82;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: sheetHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Color(0x292F51C8),
              blurRadius: 50,
              offset: Offset(0, -18),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 9, 20, 12 + bottomInset),
          child: Column(
            children: [
              const _Grabber(),
              _SheetHeader(onClose: () => Navigator.of(context).pop()),
              SharePreviewCard(
                onFeedback: (message) =>
                    _showPlaceholderFeedback(context, message),
              ),
              const SizedBox(height: 12),
              ShareActions(
                onFeedback: (message) =>
                    _showPlaceholderFeedback(context, message),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: _blue18,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
      child: SizedBox(
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: _blue,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  minimumSize: const Size(48, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 58),
              child: Text(
                'Share Your Achievement',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SharePreviewCard extends StatelessWidget {
  const SharePreviewCard({super.key, required this.onFeedback});

  final ValueChanged<String> onFeedback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ShareCardSurface(),
        const SizedBox(height: 8),
        const _ThemeDots(),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: UtilityActionChip(
                icon: Icons.edit_outlined,
                label: 'Edit card',
                onPressed: () =>
                    onFeedback('Card editing will be available soon.'),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: UtilityActionChip(
                icon: Icons.palette_outlined,
                label: 'Change theme',
                onPressed: () =>
                    onFeedback('Theme changes will be available soon.'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShareCardSurface extends StatelessWidget {
  const _ShareCardSurface();

  @override
  Widget build(BuildContext context) {
    final cardWidth = math.min(MediaQuery.sizeOf(context).width * 0.66, 258.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blueBright, _blue, Color(0xFF233F9E)],
          stops: [0, 0.52, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x292F51C8),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.1,
                  colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShareCardTopRow(),
              SizedBox(height: 14),
              RoutePreviewPanel(),
              SizedBox(height: 24),
              _ShareCardTitleBlock(),
              SizedBox(height: 18),
              _HeroMetric(),
              SizedBox(height: 22),
              _ShareMetricGrid(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareCardTopRow extends StatelessWidget {
  const _ShareCardTopRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Runiac',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        Flexible(
          child: Text(
            'Today · 7:06 AM',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xA8FFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class RoutePreviewPanel extends StatelessWidget {
  const RoutePreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          const SizedBox(
            height: 126,
            width: double.infinity,
            child: CustomPaint(
              painter: _RoutePreviewPainter(),
              child: SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 11,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
                  decoration: const BoxDecoration(
                    color: Color(0xD1FFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_pin, color: _orange, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Marina Bay loop',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCardTitleBlock extends StatelessWidget {
  const _ShareCardTitleBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saturday Morning Run',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.1,
          ),
        ),
        SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SupportiveDot(),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Good steady effort',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xA8FFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SupportiveDot extends StatelessWidget {
  const _SupportiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(color: _orange22, blurRadius: 0, spreadRadius: 3),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '4.03',
                style: TextStyle(
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontSize: 58,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -3.2,
                  height: 0.9,
                ),
              ),
              SizedBox(width: 7),
              Text(
                'km',
                style: TextStyle(
                  color: Color(0xA8FFFFFF),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Distance',
          style: TextStyle(
            color: Color(0xA8FFFFFF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _ShareMetricGrid extends StatelessWidget {
  const _ShareMetricGrid();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x29FFFFFF))),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Expanded(
              child: _ShareMetric(value: '6\'30"', label: 'Avg pace'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _ShareMetric(value: '30:15', label: 'Time'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _ShareMetric(value: '145', label: 'Avg HR'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _ShareMetric(value: '145', label: 'Calories'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareMetric extends StatelessWidget {
  const _ShareMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: Color(0xA8FFFFFF),
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _ThemeDots extends StatelessWidget {
  const _ThemeDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 7,
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 7),
        const _InactiveThemeDot(),
        const SizedBox(width: 7),
        const _InactiveThemeDot(),
      ],
    );
  }
}

class _InactiveThemeDot extends StatelessWidget {
  const _InactiveThemeDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: _blue22,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class UtilityActionChip extends StatelessWidget {
  const UtilityActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _blue,
        backgroundColor: _card,
        side: const BorderSide(color: _blue10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(0, 32),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        shadowColor: _blue12,
        elevation: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class ShareActions extends StatelessWidget {
  const ShareActions({super.key, required this.onFeedback});

  final ValueChanged<String> onFeedback;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _blue10)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SHARE TO',
              style: TextStyle(
                color: _blue60,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShareActionButton(
                  icon: Icons.auto_awesome_rounded,
                  iconAsset: _instagramStoriesIconAsset,
                  label: 'Instagram Stories',
                  onPressed: () => onFeedback(
                    'Preview only. Instagram sharing is not connected yet.',
                  ),
                ),
                ShareActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy Image',
                  onPressed: () => onFeedback(
                    'Preview only. Image copying is not connected yet.',
                  ),
                ),
                ShareActionButton(
                  icon: Icons.file_download_outlined,
                  label: 'Save Image',
                  onPressed: () => onFeedback(
                    'Preview only. Image saving is not connected yet.',
                  ),
                ),
                ShareActionButton(
                  icon: Icons.link_rounded,
                  label: 'Copy Link',
                  onPressed: () => onFeedback(
                    'Preview only. Link copying is not connected yet.',
                  ),
                ),
                ShareActionButton(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  onPressed: () => onFeedback(
                    'Preview only. More sharing is not connected yet.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShareActionButton extends StatelessWidget {
  const ShareActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconAsset,
  });

  final IconData icon;
  final String? iconAsset;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const actionWidth = 61.0;
    const iconBoxSize = 56.0;
    const iconVisualSize = 22.0;
    const assetIconVisualSize = 26.0;
    const labelGap = 6.0;
    const labelAreaHeight = 28.0;

    final iconBox = BoxDecoration(
      color: _card,
      border: Border.all(color: _blue10),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x142F51C8),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
    );

    return SizedBox(
      width: actionWidth,
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: iconBox,
                alignment: Alignment.center,
                child: iconAsset == null
                    ? Icon(icon, color: _blue, size: iconVisualSize)
                    : Image.asset(
                        iconAsset!,
                        width: assetIconVisualSize,
                        height: assetIconVisualSize,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(height: labelGap),
              SizedBox(
                height: labelAreaHeight,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: _blue75,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      height: 1.18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePreviewPainter extends CustomPainter {
  const _RoutePreviewPainter();

  static const _points = [
    Offset(0.16, 0.62),
    Offset(0.29, 0.44),
    Offset(0.43, 0.52),
    Offset(0.55, 0.31),
    Offset(0.72, 0.37),
    Offset(0.83, 0.22),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEAF0FF), Color(0xFFDCE6FF)],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    _drawWater(canvas, size);
    _drawStreets(canvas, size);

    final route = _smoothRoute(size);
    final glowPaint = Paint()
      ..color = const Color(0x382F51C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(route, glowPaint);

    final routePaint = Paint()
      ..color = _blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(route, routePaint);

    final start = _scale(_points.first, size);
    final finish = _scale(_points.last, size);
    canvas.drawCircle(start, 7, Paint()..color = Colors.white);
    canvas.drawCircle(start, 4.5, Paint()..color = _blue);
    canvas.drawCircle(finish, 8, Paint()..color = Colors.white);
    canvas.drawCircle(finish, 5, Paint()..color = _orange);
  }

  void _drawWater(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x1A3E63E6);
    final path = Path()
      ..moveTo(0, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.27,
        size.height * 0.65,
        size.width * 0.46,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.95,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawStreets(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1A2F51C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 7; i += 1) {
      final y = size.height * (0.16 + i * 0.12);
      canvas.drawLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.94, y + math.sin(i) * 7),
        paint,
      );
    }

    for (var i = 0; i < 5; i += 1) {
      final x = size.width * (0.12 + i * 0.2);
      canvas.drawLine(
        Offset(x, size.height * 0.06),
        Offset(x + math.cos(i) * 8, size.height * 0.9),
        paint,
      );
    }
  }

  Path _smoothRoute(Size size) {
    final scaled = _points.map((point) => _scale(point, size)).toList();
    final path = Path()..moveTo(scaled.first.dx, scaled.first.dy);

    for (var i = 0; i < scaled.length - 1; i += 1) {
      final current = scaled[i];
      final next = scaled[i + 1];
      final control = Offset(
        (current.dx + next.dx) / 2,
        math.min(current.dy, next.dy) - size.height * 0.08,
      );
      path.quadraticBezierTo(control.dx, control.dy, next.dx, next.dy);
    }

    return path;
  }

  Offset _scale(Offset point, Size size) {
    return Offset(point.dx * size.width, point.dy * size.height);
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) => false;
}
