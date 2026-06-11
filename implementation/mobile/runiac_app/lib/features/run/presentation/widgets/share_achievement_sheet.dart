import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const _blue = Color(0xFF2F51C8);
const _blueBright = Color(0xFF3E63E6);
const _orange = Color(0xFFFB6414);
const _orangeDeep = Color(0xFFE8550A);
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

class ShareAchievementSheet extends StatelessWidget {
  const ShareAchievementSheet({super.key});

  void _showPlaceholderFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
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
          child: Column(
            children: [
              const SizedBox(height: 9),
              const _Grabber(),
              _SheetHeader(onClose: () => Navigator.of(context).pop()),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 8 + bottomInset),
                  child: Column(
                    children: [
                      SharePreviewCard(
                        onFeedback: (message) =>
                            _showPlaceholderFeedback(context, message),
                      ),
                      const SizedBox(height: 22),
                      ShareActions(
                        onFeedback: (message) =>
                            _showPlaceholderFeedback(context, message),
                      ),
                      const SizedBox(height: 16),
                      const _HomeIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: _blue,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  minimumSize: const Size(48, 36),
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
          ),
          const Text(
            'Share Your Achievement',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
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
        const SizedBox(height: 16),
        const _ThemeDots(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UtilityActionChip(
              icon: Icons.edit_outlined,
              label: 'Edit card',
              onPressed: () =>
                  onFeedback('Card editing will be available soon.'),
            ),
            const SizedBox(width: 10),
            UtilityActionChip(
              icon: Icons.palette_outlined,
              label: 'Change theme',
              onPressed: () =>
                  onFeedback('Theme changes will be available soon.'),
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
    final cardWidth = math.min(MediaQuery.sizeOf(context).width - 40, 312.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
              SizedBox(height: 15),
              _ShareCardTitleBlock(),
              SizedBox(height: 16),
              _HeroMetric(),
              SizedBox(height: 18),
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Today · 7:06 AM',
          style: TextStyle(
            color: Color(0xA8FFFFFF),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
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
            height: 134,
            width: double.infinity,
            child: CustomPaint(
              painter: _RoutePreviewPainter(),
              child: SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
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
                      Icon(Icons.location_pin, color: _orange, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Marina Bay loop',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 10.5,
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
            fontSize: 17,
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
            Text(
              'Good steady effort',
              style: TextStyle(
                color: Color(0xA8FFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '4.03',
              style: TextStyle(
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -2.5,
                height: 0.9,
              ),
            ),
            SizedBox(width: 7),
            Text(
              'km',
              style: TextStyle(
                color: Color(0xA8FFFFFF),
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 7),
        Text(
          'Distance',
          style: TextStyle(
            color: Color(0xA8FFFFFF),
            fontSize: 11,
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
        padding: EdgeInsets.only(top: 16),
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1,
          ),
        ),
        const SizedBox(height: 5),
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
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _blue,
        backgroundColor: _card,
        side: const BorderSide(color: _blue10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 38),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        shadowColor: _blue12,
        elevation: 3,
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
        padding: const EdgeInsets.only(top: 18),
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShareActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Instagram Stories',
                  isPrimary: true,
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
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final iconBox = isPrimary
        ? const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_orange, _orangeDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x52FB6414),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          )
        : BoxDecoration(
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
      width: 61,
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: iconBox,
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : _blue,
                  size: isPrimary ? 24 : 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: isPrimary ? _ink : _blue75,
                  fontSize: 11.5,
                  fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.1,
                  height: 1.18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 134,
        height: 5,
        decoration: BoxDecoration(
          color: _blue22,
          borderRadius: BorderRadius.circular(99),
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
