import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:runiac_app/core/theme/runiac_colors.dart';
import 'package:runiac_app/core/widgets/runiac_back_header.dart';

import 'advanced_analysis_screen.dart';
import '../domain/models/complete_run_result.dart';
import '../domain/models/run_summary_snapshot.dart';
import 'data/run_completion_demo_snapshots.dart';
import 'widgets/share_achievement_sheet.dart';
import 'xp_update_screen.dart';

const _rBlue = Color(0xFF2F51C8);
const _rOrange = Color(0xFFFB6414);
const _rWhite = Color(0xFFFFFFFF);
const _rBlue90 = Color(0xE62F51C8);
const _rBlue75 = Color(0xBF2F51C8);
const _rBlue60 = Color(0x992F51C8);
const _rBlue45 = Color(0x732F51C8);
const _rBlue30 = Color(0x4D2F51C8);
const _rBlue18 = Color(0x2E2F51C8);
const _rBlue10 = Color(0x1A2F51C8);
const _rBlue06 = Color(0x0F2F51C8);
const _cardRadius = 20.0;

class ViewSummaryScreen extends StatelessWidget {
  const ViewSummaryScreen({
    super.key,
    this.summary = defaultRunSummarySnapshot,
    this.completionResult,
    this.showXpUpdateAction = true,
  });

  final RunSummarySnapshot summary;
  final CompleteRunResult? completionResult;
  final bool showXpUpdateAction;

  void _showSoonMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final displayedSummary = completionResult?.summary ?? summary;
    final hasSufficientData = displayedSummary.hasSufficientData;

    return Scaffold(
      backgroundColor: _rWhite,
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              children: [
                RuniacBackHeader(
                  title: displayedSummary.title,
                  subtitle: displayedSummary.dateTimeLabel,
                  tooltip: 'Back to cool down',
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  titleStyle: const TextStyle(
                    color: _rBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                  subtitleStyle: const TextStyle(
                    color: _rBlue60,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                  trailing: IconButton(
                    tooltip: 'Share summary',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withValues(alpha: 0.48),
                        builder: (context) => const ShareAchievementSheet(),
                      );
                    },
                    style: IconButton.styleFrom(
                      foregroundColor: _rBlue,
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.share_outlined, size: 20),
                  ),
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
                          _MapPreview(routeName: displayedSummary.routeName),
                          _HeroDistance(
                            distanceKm: displayedSummary.distanceKm,
                          ),
                          _MetricSummary(summary: displayedSummary),
                          _PaceSection(hasSufficientData: hasSufficientData),
                          _AnalysisSection(
                            hasSufficientData: hasSufficientData,
                            onMoreDetails: () {
                              if (!hasSufficientData) {
                                _showSoonMessage(
                                  context,
                                  'Run a little longer to unlock analysis.',
                                );
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const AdvancedAnalysisScreen(),
                                ),
                              );
                            },
                          ),
                          _CoachingSection(
                            hasSufficientData: hasSufficientData,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _BottomActions(
                  hasSufficientData: hasSufficientData,
                  showXpUpdateAction: showXpUpdateAction,
                  onShareRoute: () {
                    _showSoonMessage(
                      context,
                      'Route sharing will be available soon.',
                    );
                  },
                  onXpUpdate: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => XpUpdateScreen(
                          model:
                              completionResult?.xpUpdate ??
                              defaultXpUpdateDisplayModel,
                        ),
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

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.routeName});

  final String routeName;

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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 230),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: _rOrange,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            routeName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _rBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
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
  const _HeroDistance({required this.distanceKm});

  final String distanceKm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              distanceKm,
              style: const TextStyle(
                color: _rBlue,
                fontSize: 72,
                fontWeight: FontWeight.w800,
                letterSpacing: -2.8,
                height: 0.95,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'km',
              style: TextStyle(
                color: _rBlue75,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricSummary extends StatelessWidget {
  const _MetricSummary({required this.summary});

  final RunSummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 18, 34, 0),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricText(
                      value: summary.avgPace,
                      label: 'Avg Pace',
                    ),
                  ),
                  Expanded(
                    child: _MetricText(value: summary.duration, label: 'Time'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MetricText(
                      value: _metricValueWithUnit(summary.avgHeartRate, 'bpm'),
                      label: 'Avg Heart Rate',
                    ),
                  ),
                  Expanded(
                    child: _MetricText(
                      value: _metricValueWithUnit(summary.calories, 'kcal'),
                      label: 'Est. calories',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _metricValueWithUnit(String value, String unit) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == '--') {
    return '--';
  }
  return '$normalized $unit';
}

class _MetricText extends StatelessWidget {
  const _MetricText({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _rBlue,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _rBlue60,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _PaceSection extends StatelessWidget {
  const _PaceSection({required this.hasSufficientData});

  final bool hasSufficientData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel(title: 'Pace Over Time'),
          _CardSurface(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
            child: _GuardedAnalysisPreview(
              showGuard: !hasSufficientData,
              child: const _PaceChart(),
            ),
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
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: const Padding(
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
  const _AnalysisSection({
    required this.hasSufficientData,
    required this.onMoreDetails,
  });

  final bool hasSufficientData;
  final VoidCallback onMoreDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel(title: 'Advanced Analysis'),
          _CardSurface(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Heart rate zones, cadence & elevation',
                  style: TextStyle(
                    color: _rBlue60,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _GuardedAnalysisPreview(
                  showGuard: !hasSufficientData,
                  minHeight: hasSufficientData ? 0 : 116,
                  child: const _ZoneBars(),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onMoreDetails,
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
                  child: const Text('More Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuardedAnalysisPreview extends StatelessWidget {
  const _GuardedAnalysisPreview({
    required this.showGuard,
    required this.child,
    this.minHeight = 0,
  });

  final bool showGuard;
  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            if (showGuard) const Positioned.fill(child: _LowDataGraphGuard()),
          ],
        ),
      ),
    );
  }
}

class _LowDataGraphGuard extends StatelessWidget {
  const _LowDataGraphGuard();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.4, sigmaY: 2.4),
        child: DecoratedBox(
          decoration: BoxDecoration(color: _rWhite.withValues(alpha: 0.56)),
          child: Center(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'More run data needed',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _rOrange,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(color: _rWhite, blurRadius: 10),
                        Shadow(
                          color: _rWhite,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pace insights will appear after a longer run.',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _rOrange,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      shadows: [
                        Shadow(color: _rWhite, blurRadius: 10),
                        Shadow(
                          color: _rWhite,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  const _CoachingSection({required this.hasSufficientData});

  final bool hasSufficientData;

  @override
  Widget build(BuildContext context) {
    final coachingCopy = hasSufficientData
        ? 'Great job completing today\'s planned run! You maintained a steady pace and finished feeling in control. Consistency like this builds a strong foundation.'
        : 'You started your run today — that still counts. We need a little more movement data to estimate your effort accurately.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel(title: 'AI Coaching Summary'),
          _CardSurface(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coachingCopy,
                  style: const TextStyle(
                    color: _rBlue90,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: _rBlue10),
                const SizedBox(height: 14),
                const _NextTipBlock(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextTipBlock extends StatelessWidget {
  const _NextTipBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
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
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.hasSufficientData,
    required this.showXpUpdateAction,
    required this.onShareRoute,
    required this.onXpUpdate,
  });

  final bool hasSufficientData;
  final bool showXpUpdateAction;
  final VoidCallback onShareRoute;
  final VoidCallback onXpUpdate;

  @override
  Widget build(BuildContext context) {
    if (!hasSufficientData) {
      return const SizedBox.shrink();
    }

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
          if (showXpUpdateAction) ...[
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
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _rWhite,
        border: Border.all(color: RuniacColors.cardBorder),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Padding(padding: padding, child: child),
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
