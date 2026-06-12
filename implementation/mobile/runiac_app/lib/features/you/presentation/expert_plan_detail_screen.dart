import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_section_header.dart';
import 'data/expert_plan_demo_snapshots.dart';

class ExpertPlanDetailScreen extends StatefulWidget {
  const ExpertPlanDetailScreen({
    required this.onBack,
    this.snapshot = expertPlanDetailSnapshot,
    super.key,
  });

  final VoidCallback onBack;
  final ExpertPlanDetailSnapshot snapshot;

  @override
  State<ExpertPlanDetailScreen> createState() => _ExpertPlanDetailScreenState();
}

class _ExpertPlanDetailScreenState extends State<ExpertPlanDetailScreen> {
  final _expandedWeekIndexes = <int>{};

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Plan Preview',
              tooltip: 'Back to Expert Plans',
              onBack: widget.onBack,
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _ExpertPlanDetailAccentStrip(),
                      const SizedBox(height: 14),
                      const _ExpertPlanHeroBanner(),
                      const SizedBox(height: 10),
                      _CoachInsightCard(widget.snapshot.coachInsight),
                      const SizedBox(height: 10),
                      _PlanSummaryCard(widget.snapshot),
                      const SizedBox(height: 10),
                      _PlanTimelineCard(
                        weeks: widget.snapshot.weeklyPreview,
                        expandedWeekIndexes: _expandedWeekIndexes,
                        onWeekSelected: (index) {
                          setState(() {
                            if (_expandedWeekIndexes.contains(index)) {
                              _expandedWeekIndexes.remove(index);
                            } else {
                              _expandedWeekIndexes.add(index);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const _DisabledSelectionCallToAction(),
                      const SizedBox(height: 10),
                      const _BoundaryNote(),
                      const SizedBox(height: 8),
                      const _MedicalNote(),
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

class _ExpertPlanDetailAccentStrip extends StatelessWidget {
  const _ExpertPlanDetailAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('expert_plan_detail_header_accent_strip'),
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _ExpertPlanHeroBanner extends StatelessWidget {
  const _ExpertPlanHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 154,
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RuniacColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF7FAFF),
                    RuniacColors.white,
                    RuniacColors.accentOrange.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 40,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: RuniacColors.primaryBlue.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            left: 38,
            bottom: 30,
            child: _RouteDot(RuniacColors.primaryBlue),
          ),
          Positioned(
            right: 46,
            bottom: 30,
            child: _RouteDot(RuniacColors.accentOrange),
          ),
          const Center(
            child: Icon(
              Icons.directions_run,
              color: RuniacColors.primaryBlue,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteDot extends StatelessWidget {
  const _RouteDot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: RuniacColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
    );
  }
}

class _CoachInsightCard extends StatelessWidget {
  const _CoachInsightCard(this.copy);

  final String copy;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: RuniacColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: RuniacColors.border),
            ),
            child: const Icon(
              Icons.support_agent,
              color: RuniacColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Coach Insight', style: _accentTitleStyle),
                const SizedBox(height: 3),
                const Text('Verified by Running Coach', style: _smallBodyStyle),
                const SizedBox(height: 8),
                Text(copy, style: _bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard(this.snapshot);

  final ExpertPlanDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(snapshot.title, style: _planTitleStyle)),
              const SizedBox(width: 8),
              const _CoachVerifiedBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _MetaLine(Icons.calendar_month, snapshot.duration),
              _MetaLine(Icons.directions_run, snapshot.frequency),
              _MetaLine(Icons.signal_cellular_alt, snapshot.level),
              _MetaLine(Icons.favorite_border, snapshot.pressure),
            ],
          ),
          const SizedBox(height: 10),
          const _VerifiedLine(),
          const SizedBox(height: 10),
          Text(snapshot.subtitle, style: _bodyStyle),
        ],
      ),
    );
  }
}

class _CoachVerifiedBadge extends StatelessWidget {
  const _CoachVerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_user, size: 15, color: RuniacColors.primaryBlue),
          SizedBox(width: 5),
          Text('Coach Verified', style: _smallAccentStyle),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: RuniacColors.primaryBlue, size: 16),
        const SizedBox(width: 5),
        Text(label, style: _smallStrongStyle),
      ],
    );
  }
}

class _VerifiedLine extends StatelessWidget {
  const _VerifiedLine();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.verified_user_outlined,
          color: RuniacColors.primaryBlue,
          size: 16,
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text('Verified by Running Coach', style: _smallAccentStyle),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return RuniacSectionHeader(
      title: title,
      leading: Icon(icon, color: RuniacColors.primaryBlue, size: 18),
      titleStyle: _sectionTitleStyle,
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 7),
          decoration: const BoxDecoration(
            color: RuniacColors.accentOrange,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: _bodyStrongStyle)),
      ],
    );
  }
}

class _PlanTimelineCard extends StatelessWidget {
  const _PlanTimelineCard({
    required this.weeks,
    required this.expandedWeekIndexes,
    required this.onWeekSelected,
  });

  final List<ExpertPlanWeekPreview> weeks;
  final Set<int> expandedWeekIndexes;
  final ValueChanged<int> onWeekSelected;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Plan Timeline', icon: Icons.timeline),
          const SizedBox(height: 12),
          for (var index = 0; index < weeks.length; index++)
            _TimelineRow(
              week: weeks[index],
              expanded: expandedWeekIndexes.contains(index),
              isLast: index == weeks.length - 1,
              onTap: () => onWeekSelected(index),
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.week,
    required this.expanded,
    required this.isLast,
    required this.onTap,
  });

  final ExpertPlanWeekPreview week;
  final bool expanded;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: RuniacColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: RuniacColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 68,
                  child: Text(week.weekLabel, style: _smallStrongStyle),
                ),
                Expanded(child: Text(week.title, style: _smallBodyStyle)),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: RuniacColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const Divider(height: 1, color: RuniacColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 12, 0, 14),
            child: Column(
              children: [
                for (final bullet in week.bullets) ...[
                  _BulletItem(bullet),
                  if (bullet != week.bullets.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
        if (!isLast) const Divider(height: 1, color: RuniacColors.border),
      ],
    );
  }
}

class _DisabledSelectionCallToAction extends StatelessWidget {
  const _DisabledSelectionCallToAction();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: RuniacColors.disabledButtonBackground,
              disabledForegroundColor: RuniacColors.disabledButtonForeground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Select This Plan', style: _ctaTextStyle),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Plan selection is not available in this preview.',
          textAlign: TextAlign.center,
          style: _smallBodyStyle,
        ),
      ],
    );
  }
}

class _BoundaryNote extends StatelessWidget {
  const _BoundaryNote();

  @override
  Widget build(BuildContext context) {
    return const _NoteBox(
      icon: Icons.lock_outline,
      text:
          'This preview does not enroll you in a plan or update your progress.',
    );
  }
}

class _MedicalNote extends StatelessWidget {
  const _MedicalNote();

  @override
  Widget build(BuildContext context) {
    return const _NoteBox(
      icon: Icons.health_and_safety_outlined,
      text:
          'Plans are reviewed for beginner suitability. This is general fitness guidance, not medical advice.',
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RuniacColors.textSecondary, size: 18),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: _smallBodyStyle)),
        ],
      ),
    );
  }
}

const _planTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 22,
  fontWeight: FontWeight.w900,
);

const _sectionTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w900,
);

const _accentTitleStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 14,
  fontWeight: FontWeight.w900,
);

const _bodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 13,
  height: 1.35,
  fontWeight: FontWeight.w600,
);

const _bodyStrongStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
  height: 1.25,
  fontWeight: FontWeight.w700,
);

const _smallBodyStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 12,
  height: 1.25,
  fontWeight: FontWeight.w700,
);

const _smallStrongStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 12,
  fontWeight: FontWeight.w800,
);

const _smallAccentStyle = TextStyle(
  color: RuniacColors.primaryBlue,
  fontSize: 12,
  fontWeight: FontWeight.w900,
);

const _ctaTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w900);
