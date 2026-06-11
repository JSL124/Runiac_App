import 'dart:math' as math;

import 'package:flutter/material.dart';

const _blue = Color(0xFF2F51C8);
const _orange = Color(0xFFFB6414);
const _surface = Color(0xFFF4F7FF);
const _card = Color(0xFFFFFFFF);
const _ink = Color(0xFF16235C);
const _blue90 = Color(0xE62F51C8);
const _blue75 = Color(0xBF2F51C8);
const _blue60 = Color(0x992F51C8);
const _blue45 = Color(0x732F51C8);
const _blue30 = Color(0x4D2F51C8);
const _blue22 = Color(0x382F51C8);
const _blue18 = Color(0x2E2F51C8);
const _blue12 = Color(0x1F2F51C8);
const _blue10 = Color(0x1A2F51C8);
const _blue07 = Color(0x122F51C8);
const _orange16 = Color(0x29FB6414);
const _orange12 = Color(0x1FFB6414);
const _orange08 = Color(0x14FB6414);

const _pacePoints = [
  _Point(0.00, 392),
  _Point(0.25, 384),
  _Point(0.50, 372),
  _Point(0.80, 360),
  _Point(1.00, 384),
  _Point(1.40, 396),
  _Point(1.80, 404),
  _Point(2.20, 412),
  _Point(2.60, 420),
  _Point(3.00, 425),
  _Point(3.30, 410),
  _Point(3.60, 392),
  _Point(3.90, 372),
  _Point(4.03, 366),
];

const _elevationPoints = [
  _Point(0.00, 4),
  _Point(0.4, 6),
  _Point(0.8, 9),
  _Point(1.2, 7),
  _Point(1.6, 5),
  _Point(2.0, 8),
  _Point(2.4, 11),
  _Point(2.8, 9),
  _Point(3.2, 6),
  _Point(3.6, 4),
  _Point(4.03, 5),
];

const _cadencePoints = [
  _Point(0.0, 158),
  _Point(0.1, 162),
  _Point(0.2, 165),
  _Point(0.3, 163),
  _Point(0.4, 166),
  _Point(0.5, 164),
  _Point(0.6, 167),
  _Point(0.7, 163),
  _Point(0.8, 165),
  _Point(0.9, 168),
  _Point(1.0, 166),
];

class AdvancedAnalysisScreen extends StatelessWidget {
  const AdvancedAnalysisScreen({super.key});

  void _showSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            _AnalysisHeader(
              onBack: () => Navigator.of(context).maybePop(),
              onShare: () => _showSoon(
                context,
                'Advanced analysis sharing will be available soon.',
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: const _NoOverscrollBehavior(),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _OverviewSection(),
                      const SizedBox(height: 14),
                      const _PaceAnalysisSection(),
                      const SizedBox(height: 14),
                      const _HeartRateSection(),
                      const SizedBox(height: 14),
                      const _EffortSection(),
                      const SizedBox(height: 14),
                      const _ElevationSection(),
                      const SizedBox(height: 14),
                      const _CadenceSection(),
                      const SizedBox(height: 14),
                      _RecoverySection(
                        onStretches: () => _showSoon(
                          context,
                          'Recommended stretches will be available soon.',
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

class _AnalysisHeader extends StatelessWidget {
  const _AnalysisHeader({required this.onBack, required this.onShare});

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
              tooltip: 'Back to summary',
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
                      color: _blue,
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
                      color: _blue60,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              tooltip: 'Share advanced analysis',
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
        foregroundColor: _blue,
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: iconSize),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Performance Overview',
            icon: Icons.wb_sunny_outlined,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _ScoreRing(value: 82, size: 112, stroke: 9, color: _blue),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good steady effort',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You maintained a stable pace and kept your heart rate mostly in the right zone.',
                      style: TextStyle(
                        color: _blue75,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InsightBadge(icon: Icons.speed_rounded, label: 'Stable Pace'),
              _InsightBadge(
                icon: Icons.favorite_border_rounded,
                label: 'Controlled HR',
              ),
              _InsightBadge(
                icon: Icons.emoji_events_outlined,
                label: 'Good Endurance',
                highlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaceAnalysisSection extends StatelessWidget {
  const _PaceAnalysisSection();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Pace Analysis',
            icon: Icons.speed_rounded,
            badge: '86% stable',
            hotBadge: true,
          ),
          SizedBox(height: 16),
          _StatGrid(
            stats: [
              _StatData('Avg Pace', '6’30”', '/km'),
              _StatData('Fastest Pace', '5’58”', '/km', hot: true),
              _StatData('Slowest Pace', '7’05”', '/km'),
              _StatData('Pace Stability', '86', '%'),
            ],
          ),
          SizedBox(height: 16),
          _ChartPanel(height: 170, painter: _PaceChartPainter()),
          SizedBox(height: 16),
          _Subhead('Splits'),
          SizedBox(height: 8),
          _SplitRow(),
          _InterpretationRow(
            text:
                'Your pace slowed slightly in the middle section but recovered well in the final part.',
          ),
        ],
      ),
    );
  }
}

class _HeartRateSection extends StatelessWidget {
  const _HeartRateSection();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Heart Rate Analysis',
            icon: Icons.favorite_border_rounded,
            badge: '72% in zone',
            hotBadge: true,
          ),
          SizedBox(height: 16),
          _StatGrid(
            stats: [
              _StatData('Avg Heart Rate', '145', 'bpm'),
              _StatData('Max Heart Rate', '158', 'bpm'),
              _StatData('Target Zone', '130–150', 'bpm'),
              _StatData('Time in Zone', '72', '%'),
            ],
          ),
          SizedBox(height: 18),
          _Subhead('Zone Distribution'),
          SizedBox(height: 10),
          _ZoneBars(),
          _InterpretationRow(
            text:
                'You spent most of the run in the aerobic zone, which is ideal for building endurance.',
          ),
        ],
      ),
    );
  }
}

class _EffortSection extends StatelessWidget {
  const _EffortSection();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Effort & Intensity',
            icon: Icons.show_chart_rounded,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _IntensityTile(
                  label: 'Planned Intensity',
                  value: 'Low',
                  progress: 0.33,
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _IntensityTile(
                  label: 'Actual Intensity',
                  value: 'Low–Moderate',
                  progress: 0.46,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _MatchCard(),
          _InterpretationRow(
            text:
                'This run matched your planned easy effort well. Try starting a little slower next time.',
          ),
        ],
      ),
    );
  }
}

class _ElevationSection extends StatelessWidget {
  const _ElevationSection();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Elevation Analysis',
            icon: Icons.terrain_rounded,
            badge: 'Mostly flat',
          ),
          SizedBox(height: 16),
          _ChartPanel(height: 150, painter: _ElevationChartPainter()),
          SizedBox(height: 16),
          _StatGrid(
            stats: [
              _StatData('Total Gain', '+12', 'm', hot: true),
              _StatData('Highest Point', '11', 'm'),
              _StatData('Lowest Point', '3', 'm'),
              _StatData('Route Difficulty', 'Mostly Flat', ''),
            ],
          ),
          _InterpretationRow(
            text:
                'The route was mostly flat, which helped you maintain a stable pace and steady heart rate.',
          ),
        ],
      ),
    );
  }
}

class _CadenceSection extends StatelessWidget {
  const _CadenceSection();

  @override
  Widget build(BuildContext context) {
    return const _AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Running Form / Cadence',
            icon: Icons.access_time_rounded,
            badge: 'Good',
            hotBadge: true,
          ),
          SizedBox(height: 16),
          _StatGrid(
            stats: [
              _StatData('Avg Cadence', '164', 'spm'),
              _StatData('Target Range', '160–175', 'spm'),
              _StatData('Stride Consistency', 'Stable', ''),
              _StatData('Cadence Status', 'Good', ''),
            ],
          ),
          SizedBox(height: 16),
          _ChartPanel(height: 150, painter: _CadenceChartPainter()),
          _InterpretationRow(
            text:
                'Your cadence stayed within a comfortable range with a consistent running rhythm.',
          ),
        ],
      ),
    );
  }
}

class _RecoverySection extends StatelessWidget {
  const _RecoverySection({required this.onStretches});

  final VoidCallback onStretches;

  @override
  Widget build(BuildContext context) {
    return _AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            title: 'Recovery Recommendation',
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 16),
          const _RecoveryGrid(),
          const SizedBox(height: 16),
          const _RecoveryCallout(),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onStretches,
            icon: const Icon(Icons.chevron_right_rounded, size: 24),
            iconAlignment: IconAlignment.end,
            label: const Text('View Recommended Stretches'),
            style: FilledButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: _card,
              minimumSize: const Size.fromHeight(58),
              elevation: 8,
              shadowColor: const Color(0x4DFB6414),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: _blue07),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2F51C8),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.badge,
    this.hotBadge = false,
  });

  final String title;
  final IconData icon;
  final String? badge;
  final bool hotBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconTile(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ),
        if (badge != null) _Badge(label: badge!, hot: hotBadge),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _blue, size: 22),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.hot = false});

  final String label;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hot ? _orange12 : _blue07,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: hot ? _orange : _blue45,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: hot ? _orange : _blue75,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBadge extends StatelessWidget {
  const _InsightBadge({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted ? _orange08 : _surface,
        border: Border.all(color: highlighted ? _orange16 : _blue12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: highlighted ? _orange : _blue, size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: highlighted ? _orange : _blue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<_StatData> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.72,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      children: [for (final stat in stats) _StatTile(stat: stat)],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    final color = stat.hot ? _orange : _ink;

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 10, 10),
      decoration: BoxDecoration(
        color: stat.hot ? _orange08 : _surface,
        border: Border.all(color: stat.hot ? _orange16 : _blue10, width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _blue45,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  stat.value,
                  style: TextStyle(
                    color: color,
                    fontSize: stat.value.length > 8 ? 18 : 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                if (stat.unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(
                    stat.unit,
                    style: TextStyle(
                      color: stat.hot ? _orange : _blue45,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
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

class _Subhead extends StatelessWidget {
  const _Subhead(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _blue45,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.height, required this.painter});

  final double height;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _blue10, width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: CustomPaint(painter: painter, child: const SizedBox.expand()),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow();

  @override
  Widget build(BuildContext context) {
    const splits = [
      _SplitData('1 km', '6’24”'),
      _SplitData('2 km', '6’33”'),
      _SplitData('3 km', '6’41”'),
      _SplitData('4 km', '6’21”', fastest: true),
      _SplitData('4.03 km', '0’16”', partial: true),
    ];

    return Row(
      children: [
        for (var i = 0; i < splits.length; i++) ...[
          Expanded(child: _SplitChip(split: splits[i])),
          if (i != splits.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _SplitChip extends StatelessWidget {
  const _SplitChip({required this.split});

  final _SplitData split;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
      decoration: BoxDecoration(
        color: split.fastest ? _orange08 : _surface,
        border: Border.all(
          color: split.partial
              ? _blue18
              : split.fastest
              ? _orange16
              : _blue10,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              split.km,
              style: const TextStyle(
                color: _blue45,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            child: Text(
              split.pace,
              style: TextStyle(
                color: split.fastest ? _orange : _blue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
        _ZoneRow(label: 'Zone 1 Easy', percent: 18, color: _blue22, max: 54),
        SizedBox(height: 10),
        _ZoneRow(label: 'Zone 2 Aerobic', percent: 54, color: _blue, max: 54),
        SizedBox(height: 10),
        _ZoneRow(label: 'Zone 3 Tempo', percent: 22, color: _blue60, max: 54),
        SizedBox(height: 10),
        _ZoneRow(label: 'Zone 4 Hard', percent: 6, color: _orange, max: 54),
      ],
    );
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({
    required this.label,
    required this.percent,
    required this.color,
    required this.max,
  });

  final String label;
  final int percent;
  final Color color;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: const TextStyle(
              color: _blue75,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percent / max,
              minHeight: 12,
              backgroundColor: _surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntensityTile extends StatelessWidget {
  const _IntensityTile({
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _blue10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _blue45,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: _blue07,
            valueColor: const AlwaysStoppedAnimation<Color>(_blue),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _blue10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          _ScoreRing(
            value: 88,
            size: 64,
            stroke: 6,
            color: _orange,
            percentOnly: true,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Match',
                  style: TextStyle(
                    color: _blue45,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '88% · Good',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your real effort closely tracked the easy plan.',
                  style: TextStyle(
                    color: _blue75,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _InterpretationRow extends StatelessWidget {
  const _InterpretationRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _blue10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            color: _blue45,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _blue75,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryGrid extends StatelessWidget {
  const _RecoveryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: const [
        _RecoveryFact(
          icon: Icons.access_time_rounded,
          label: 'Recovery Level',
          value: 'Light',
        ),
        _RecoveryFact(
          icon: Icons.directions_run_rounded,
          label: 'Stretching',
          value: '5–8 min',
        ),
        _RecoveryFact(
          icon: Icons.water_drop_outlined,
          label: 'Hydration',
          value: 'Drink water',
        ),
        _RecoveryFact(
          icon: Icons.schedule_rounded,
          label: 'Next Run Readiness',
          value: 'Ready in 24 hours',
        ),
      ],
    );
  }
}

class _RecoveryFact extends StatelessWidget {
  const _RecoveryFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _blue10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0x0A2F51C8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _blue, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _blue45,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

class _RecoveryCallout extends StatelessWidget {
  const _RecoveryCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _orange08,
        border: Border.all(color: _orange16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrangeIconBadge(),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'A light recovery routine is recommended. Stretch your calves, hamstrings, and quads and avoid another hard session today.',
              style: TextStyle(
                color: _blue90,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrangeIconBadge extends StatelessWidget {
  const _OrangeIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FB6414),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.monitor_heart_outlined, color: _card, size: 24),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.value,
    required this.size,
    required this.stroke,
    required this.color,
    this.percentOnly = false,
  });

  final int value;
  final double size;
  final double stroke;
  final Color color;
  final bool percentOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _RingPainter(value: value, stroke: stroke, color: color),
            child: const SizedBox.expand(),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                percentOnly ? '$value%' : '$value',
                style: TextStyle(
                  color: _ink,
                  fontSize: percentOnly ? 20 : 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              if (!percentOnly)
                const Text(
                  '/ 100',
                  style: TextStyle(
                    color: _blue45,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
  });

  final int value;
  final double stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = stroke / 2;
    final arcRect = rect.deflate(inset);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = _blue10;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas
      ..drawArc(arcRect, 0, math.pi * 2, false, track)
      ..drawArc(arcRect, -math.pi / 2, math.pi * 2 * value / 100, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.stroke != stroke ||
        oldDelegate.color != color;
  }
}

class _PaceChartPainter extends CustomPainter {
  const _PaceChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _ChartGeometry(size, left: 34, top: 12, right: 8, bottom: 24);
    final values = _pacePoints.map((point) => point.y).toList();
    final min = values.reduce(math.min) - 8;
    final max = values.reduce(math.max) + 8;
    double xFor(double km) => plot.left + (km / 4.03) * plot.width;
    double yFor(double pace) =>
        plot.top + ((pace - min) / (max - min)) * plot.height;

    _drawGrid(
      canvas,
      plot,
      ['6’00”', '6’30”', '7’00”'],
      ['0 km', '1 km', '2 km', '3 km', '4.03 km'],
    );

    final bandTop = yFor(384);
    final bandBottom = yFor(401);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(plot.left, bandTop, plot.right, bandBottom),
        const Radius.circular(4),
      ),
      Paint()..color = _blue07,
    );

    final offsets = _pacePoints
        .map((p) => Offset(xFor(p.x), yFor(p.y)))
        .toList();
    _drawLineArea(canvas, offsets, plot.bottom, _orange08, _blue);
    final fast = _pacePoints.reduce((a, b) => b.y < a.y ? b : a);
    final slow = _pacePoints.reduce((a, b) => b.y > a.y ? b : a);
    canvas
      ..drawCircle(
        Offset(xFor(slow.x), yFor(slow.y)),
        5,
        Paint()..color = _card,
      )
      ..drawCircle(
        Offset(xFor(slow.x), yFor(slow.y)),
        5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _blue30,
      )
      ..drawCircle(
        Offset(xFor(fast.x), yFor(fast.y)),
        7,
        Paint()..color = _card,
      )
      ..drawCircle(
        Offset(xFor(fast.x), yFor(fast.y)),
        6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _orange,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ElevationChartPainter extends CustomPainter {
  const _ElevationChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _ChartGeometry(size, left: 30, top: 12, right: 8, bottom: 22);
    double xFor(double km) => plot.left + (km / 4.03) * plot.width;
    double yFor(double m) => plot.bottom - (m / 15) * plot.height;

    _drawGrid(
      canvas,
      plot,
      ['10 m', '0 m'],
      ['0 km', '1 km', '2 km', '3 km', '4 km'],
    );
    final offsets = _elevationPoints
        .map((p) => Offset(xFor(p.x), yFor(p.y)))
        .toList();
    _drawLineArea(canvas, offsets, plot.bottom, _blue12, _blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CadenceChartPainter extends CustomPainter {
  const _CadenceChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _ChartGeometry(size, left: 34, top: 14, right: 8, bottom: 24);
    double xFor(double t) => plot.left + t * plot.width;
    double yFor(double c) => plot.bottom - ((c - 152) / 26) * plot.height;

    _drawGrid(
      canvas,
      plot,
      ['175', '160'],
      ['0:00', '10:00', '20:00', '30:15'],
    );
    final bandTop = yFor(175);
    final bandBottom = yFor(160);
    canvas.drawRect(
      Rect.fromLTRB(plot.left, bandTop, plot.right, bandBottom),
      Paint()..color = _blue07,
    );
    _drawDashedLine(
      canvas,
      Offset(plot.left, bandTop),
      Offset(plot.right, bandTop),
    );
    _drawDashedLine(
      canvas,
      Offset(plot.left, bandBottom),
      Offset(plot.right, bandBottom),
    );
    _drawText(
      canvas,
      'Target 160–175',
      Offset(plot.right - 96, bandTop - 13),
      _blue45,
      10,
    );
    final offsets = _cadencePoints
        .map((p) => Offset(xFor(p.x), yFor(p.y)))
        .toList();
    _drawPolyline(canvas, offsets, _blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartGeometry {
  _ChartGeometry(
    Size size, {
    required this.left,
    required this.top,
    required double right,
    required double bottom,
  }) : right = size.width - right,
       bottom = size.height - bottom;

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
}

void _drawGrid(
  Canvas canvas,
  _ChartGeometry plot,
  List<String> yLabels,
  List<String> xLabels,
) {
  final gridPaint = Paint()
    ..color = _blue10
    ..strokeWidth = 1;
  for (var i = 0; i < yLabels.length; i++) {
    final y = yLabels.length == 1
        ? plot.top
        : plot.top + (i / (yLabels.length - 1)) * plot.height;
    _drawDashedLine(canvas, Offset(plot.left, y), Offset(plot.right, y));
    _drawText(canvas, yLabels[i], Offset(2, y - 7), _blue45, 10);
  }
  for (var i = 0; i < xLabels.length; i++) {
    final x = xLabels.length == 1
        ? plot.left
        : plot.left + (i / (xLabels.length - 1)) * plot.width;
    canvas.drawLine(
      Offset(x, plot.top),
      Offset(x, plot.bottom),
      gridPaint..color = const Color(0x002F51C8),
    );
    _drawText(canvas, xLabels[i], Offset(x - 10, plot.bottom + 7), _blue45, 10);
  }
}

void _drawLineArea(
  Canvas canvas,
  List<Offset> offsets,
  double bottom,
  Color fill,
  Color stroke,
) {
  final path = _smoothPath(offsets);
  final area = Path.from(path)
    ..lineTo(offsets.last.dx, bottom)
    ..lineTo(offsets.first.dx, bottom)
    ..close();
  canvas.drawPath(area, Paint()..color = fill);
  canvas.drawPath(
    path,
    Paint()
      ..color = stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke,
  );
}

void _drawPolyline(Canvas canvas, List<Offset> offsets, Color color) {
  canvas.drawPath(
    _smoothPath(offsets),
    Paint()
      ..color = color
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke,
  );
}

Path _smoothPath(List<Offset> points) {
  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (var i = 0; i < points.length - 1; i++) {
    final p0 = points[(i - 1).clamp(0, points.length - 1)];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = points[(i + 2).clamp(0, points.length - 1)];
    path.cubicTo(
      p1.dx + (p2.dx - p0.dx) / 6,
      p1.dy + (p2.dy - p0.dy) / 6,
      p2.dx - (p3.dx - p1.dx) / 6,
      p2.dy - (p3.dy - p1.dy) / 6,
      p2.dx,
      p2.dy,
    );
  }
  return path;
}

void _drawDashedLine(Canvas canvas, Offset start, Offset end) {
  final paint = Paint()
    ..color = _blue10
    ..strokeWidth = 1;
  const dash = 4.0;
  const gap = 5.0;
  final distance = (end - start).distance;
  final direction = (end - start) / distance;
  var drawn = 0.0;
  while (drawn < distance) {
    final from = start + direction * drawn;
    final to = start + direction * math.min(drawn + dash, distance);
    canvas.drawLine(from, to, paint);
    drawn += dash + gap;
  }
}

void _drawText(
  Canvas canvas,
  String text,
  Offset offset,
  Color color,
  double size,
) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, offset);
}

class _Point {
  const _Point(this.x, this.y);

  final double x;
  final double y;
}

class _StatData {
  const _StatData(this.label, this.value, this.unit, {this.hot = false});

  final String label;
  final String value;
  final String unit;
  final bool hot;
}

class _SplitData {
  const _SplitData(
    this.km,
    this.pace, {
    this.fastest = false,
    this.partial = false,
  });

  final String km;
  final String pace;
  final bool fastest;
  final bool partial;
}
