import 'package:flutter/material.dart';

import 'advanced_analysis_screen.dart';
import 'xp_update_screen.dart';

const _rBlue = Color(0xFF2F51C8);
const _rOrange = Color(0xFFFB6414);
const _rWhite = Color(0xFFF8FAFF);
const _rBlue90 = Color(0xE62F51C8);
const _rBlue75 = Color(0xBF2F51C8);
const _rBlue60 = Color(0x992F51C8);
const _rBlue45 = Color(0x732F51C8);
const _rBlue30 = Color(0x4D2F51C8);
const _rBlue18 = Color(0x2E2F51C8);
const _rBlue10 = Color(0x1A2F51C8);
const _rBlue06 = Color(0x0F2F51C8);
const _rOrange12 = Color(0x1FFB6414);
const _cardRadius = 20.0;

class ViewSummaryScreen extends StatelessWidget {
  const ViewSummaryScreen({super.key});

  void _showSoonMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _rWhite,
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              children: [
                _SummaryHeader(
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  onShare: () {
                    _showSoonMessage(
                      context,
                      'Sharing will be available soon.',
                    );
                  },
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const _NoOverscrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _MapPreview(),
                          const _HeroDistance(),
                          const _MetricGrid(),
                          const _PaceSection(),
                          _AnalysisSection(
                            onMoreDetails: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const AdvancedAnalysisScreen(),
                                ),
                              );
                            },
                          ),
                          const _CoachingSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                _BottomActions(
                  onShareRoute: () {
                    _showSoonMessage(
                      context,
                      'Route sharing will be available soon.',
                    );
                  },
                  onXpUpdate: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const XpUpdateScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NoOverscrollBehavior extends ScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.onBack, required this.onShare});

  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _HeaderIconButton(
              tooltip: 'Back to cool down',
              icon: Icons.chevron_left_rounded,
              iconSize: 30,
              onPressed: onBack,
            ),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Saturday Morning Run',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Today · 7:06 AM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rBlue60,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              tooltip: 'Share summary',
              icon: Icons.share_outlined,
              iconSize: 20,
              onPressed: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: _rBlue,
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: iconSize),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: _rBlue10),
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          child: Stack(
            children: [
              const SizedBox(
                height: 184,
                child: CustomPaint(
                  painter: _MapPreviewPainter(),
                  child: SizedBox.expand(),
                ),
              ),
              const Positioned.fill(child: _MapFade()),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _rWhite,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x242F51C8),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_pin, color: _rOrange, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'East Coast Park Loop',
                        style: TextStyle(
                          color: _rBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
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

class _MapFade extends StatelessWidget {
  const _MapFade();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00F8FAFF), Color(0x8CF8FAFF)],
          stops: [0.6, 1],
        ),
      ),
    );
  }
}

class _HeroDistance extends StatelessWidget {
  const _HeroDistance();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded, color: _rOrange, size: 15),
              SizedBox(width: 6),
              Text(
                'Run complete',
                style: TextStyle(
                  color: _rOrange,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '4.03',
                style: TextStyle(
                  color: _rBlue,
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2.8,
                  height: 0.95,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'km',
                style: TextStyle(
                  color: _rBlue75,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.44,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: const [
        _MetricTile(
          icon: Icons.speed_rounded,
          value: '6’30”',
          label: 'Avg Pace',
        ),
        _MetricTile(
          icon: Icons.schedule_rounded,
          value: '30:15',
          label: 'Time',
        ),
        _MetricTile(
          icon: Icons.favorite_border_rounded,
          value: '145',
          unit: 'bpm',
          label: 'Avg Heart Rate',
        ),
        _MetricTile(
          icon: Icons.local_fire_department_outlined,
          value: '145',
          unit: 'kcal',
          label: 'Calories',
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    this.unit,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _rBlue06,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _rBlue, size: 18),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _rBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                    color: _rBlue60,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _rBlue60,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaceSection extends StatelessWidget {
  const _PaceSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(title: 'Pace Over Time'),
          _CardSurface(
            padding: EdgeInsets.fromLTRB(14, 16, 14, 12),
            child: _PaceChart(),
          ),
        ],
      ),
    );
  }
}

class _PaceChart extends StatelessWidget {
  const _PaceChart();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 96,
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _AxisLabel('4:00'),
                    _AxisLabel('6:00'),
                    _AxisLabel('8:00'),
                    _AxisLabel('10:00'),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: CustomPaint(
                  painter: _PaceChartPainter(),
                  child: SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 38),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AxisLabel('0:00'),
              _AxisLabel('5:00'),
              _AxisLabel('10:00'),
              _AxisLabel('15:02'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _rBlue45,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        height: 0.95,
      ),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  const _AnalysisSection({required this.onMoreDetails});

  final VoidCallback onMoreDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: _CardSurface(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Row(
              children: [
                _IconBadge(icon: Icons.auto_awesome_rounded, size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Analysis',
                        style: TextStyle(
                          color: _rBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Heart rate zones, cadence & elevation',
                        style: TextStyle(
                          color: _rBlue60,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _ZoneBars(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onMoreDetails,
              icon: const SizedBox.shrink(),
              label: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('More Details'),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 16),
                ],
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _rBlue,
                side: const BorderSide(color: _rBlue18, width: 1.5),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneBars extends StatelessWidget {
  const _ZoneBars();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ZoneRow(label: 'Easy', percent: 72, color: _rBlue30),
        SizedBox(height: 9),
        _ZoneRow(label: 'Steady', percent: 22, color: _rBlue60),
        SizedBox(height: 9),
        _ZoneRow(label: 'Hard', percent: 6, color: _rOrange),
      ],
    );
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: const TextStyle(
              color: _rBlue60,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 7,
              backgroundColor: _rBlue06,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _rBlue,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoachingSection extends StatelessWidget {
  const _CoachingSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: _CardSurface(
        color: _rBlue06,
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SparkBadge(),
                SizedBox(width: 11),
                Text(
                  'AI Coaching Summary',
                  style: TextStyle(
                    color: _rBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Great job completing today\'s planned run! You maintained a steady pace and finished feeling in control. Consistency like this builds a strong foundation.',
              style: TextStyle(
                color: _rBlue90,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.55,
                letterSpacing: -0.1,
              ),
            ),
            SizedBox(height: 14),
            _NextTipCard(),
          ],
        ),
      ),
    );
  }
}

class _NextTipCard extends StatelessWidget {
  const _NextTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _rWhite,
        border: Border.all(color: _rBlue10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WarmupBadge(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Run Tip',
                  style: TextStyle(
                    color: _rBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Try a 5-minute dynamic warmup before your next run to help your body move more easily.',
                  style: TextStyle(
                    color: _rBlue75,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onShareRoute, required this.onXpUpdate});

  final VoidCallback onShareRoute;
  final VoidCallback onXpUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
      decoration: const BoxDecoration(
        color: _rWhite,
        border: Border(top: BorderSide(color: _rBlue10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onShareRoute,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share Route'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _rBlue,
              side: const BorderSide(color: _rBlue30, width: 1.5),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onXpUpdate,
            icon: const Icon(Icons.auto_awesome_rounded, size: 19),
            label: const Text('View XP Update'),
            style: FilledButton.styleFrom(
              backgroundColor: _rOrange,
              foregroundColor: _rWhite,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
              elevation: 8,
              shadowColor: const Color(0x4DFB6414),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: _rBlue,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  const _CardSurface({
    required this.child,
    this.color = _rWhite,
    this.padding = const EdgeInsets.all(16),
    this.radius = _cardRadius,
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: _rBlue10),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.size = 34});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _rBlue06,
        borderRadius: BorderRadius.circular(size == 40 ? 13 : 11),
      ),
      child: Icon(icon, color: _rBlue, size: size == 40 ? 20 : 18),
    );
  }
}

class _SparkBadge extends StatelessWidget {
  const _SparkBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _rBlue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x472F51C8),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: _rWhite, size: 19),
    );
  }
}

class _WarmupBadge extends StatelessWidget {
  const _WarmupBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _rOrange12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.star_border_rounded, color: _rOrange, size: 18),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  const _MapPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _rBlue06);
    canvas.save();
    canvas.scale(size.width / 360, size.height / 240);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 360, 240));

    final gridPaint = Paint()
      ..color = _rBlue10
      ..strokeWidth = 1;
    for (var x = 0.0; x <= 360; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, 240), gridPaint);
    }
    for (var y = 0.0; y <= 240; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(360, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = _rBlue18
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-20, 40), const Offset(380, 240), roadPaint);
    canvas.drawLine(const Offset(-20, 200), const Offset(380, 40), roadPaint);
    canvas.drawLine(const Offset(120, -20), const Offset(240, 260), roadPaint);

    final riverPath = Path()
      ..moveTo(-20, 130)
      ..cubicTo(60, 100, 140, 170, 220, 130)
      ..cubicTo(280, 100, 340, 100, 380, 130);
    canvas.drawPath(
      riverPath,
      Paint()
        ..color = _rBlue10
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22,
    );

    final routePath = Path()
      ..moveTo(70, 180)
      ..cubicTo(100, 120, 150, 150, 180, 110)
      ..cubicTo(210, 70, 260, 80, 290, 130);
    canvas.drawPath(
      routePath,
      Paint()
        ..color = _rBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(70, 180), 7, Paint()..color = _rBlue);
    canvas.drawCircle(const Offset(70, 180), 3, Paint()..color = _rWhite);
    canvas.drawCircle(const Offset(290, 130), 7, Paint()..color = _rOrange);
    canvas.drawCircle(const Offset(180, 110), 8, Paint()..color = _rOrange);
    canvas.drawCircle(
      const Offset(180, 110),
      8,
      Paint()
        ..color = _rWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPreviewPainter oldDelegate) => false;
}

class _PaceChartPainter extends CustomPainter {
  const _PaceChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = _rBlue10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final y in [8.0, 36.0, 64.0, 92.0]) {
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), guidePaint);
    }

    final points = [60, 56, 64, 58, 52, 60, 55, 50, 57, 54, 49, 56, 52, 58, 54];
    final step = size.width / (points.length - 1);
    final line = Path();
    for (var i = 0; i < points.length; i += 1) {
      final point = Offset(i * step, points[i].toDouble());
      if (i == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        line.lineTo(point.dx, point.dy);
      }
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = const Color(0x14FB6414));
    canvas.drawPath(
      line,
      Paint()
        ..color = _rOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 2.0;
    const dashSpace = 4.0;
    var x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(
        Offset(x, start.dy),
        Offset(x + dashWidth, end.dy),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _PaceChartPainter oldDelegate) => false;
}
