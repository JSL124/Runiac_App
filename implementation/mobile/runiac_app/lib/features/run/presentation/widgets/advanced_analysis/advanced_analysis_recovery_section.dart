import 'package:flutter/material.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_shared_widgets.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisRecoverySection extends StatelessWidget {
  const AdvancedAnalysisRecoverySection({super.key, required this.onStretches});

  final VoidCallback onStretches;

  @override
  Widget build(BuildContext context) {
    return AdvancedAnalysisSection(
      title: 'Recovery Recommendation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AdvancedAnalysisRecoveryGrid(),
          const SizedBox(height: 16),
          const _AdvancedAnalysisRecoveryCallout(),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onStretches,
            icon: const Icon(Icons.chevron_right_rounded, size: 24),
            iconAlignment: IconAlignment.end,
            label: const Text('View Recommended Stretches'),
            style: FilledButton.styleFrom(
              backgroundColor: advancedAnalysisOrange,
              foregroundColor: advancedAnalysisCard,
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

class _AdvancedAnalysisRecoveryGrid extends StatelessWidget {
  const _AdvancedAnalysisRecoveryGrid();

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
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final fact in advancedAnalysisRecoveryFacts)
          _AdvancedAnalysisRecoveryFact(fact: fact),
      ],
    );
  }
}

class _AdvancedAnalysisRecoveryFact extends StatelessWidget {
  const _AdvancedAnalysisRecoveryFact({required this.fact});

  final AdvancedAnalysisRecoveryFactData fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: advancedAnalysisSurface,
        border: Border.all(color: advancedAnalysisBlue10),
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
            child: Icon(fact.icon, color: advancedAnalysisBlue, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.label.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: advancedAnalysisBlue45,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fact.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: advancedAnalysisInk,
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

class _AdvancedAnalysisRecoveryCallout extends StatelessWidget {
  const _AdvancedAnalysisRecoveryCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: advancedAnalysisOrange08,
        border: Border.all(color: advancedAnalysisOrange16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdvancedAnalysisOrangeIconBadge(),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'A light recovery routine is recommended. Stretch your calves, hamstrings, and quads and avoid another hard session today.',
              style: TextStyle(
                color: advancedAnalysisBlue90,
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

class _AdvancedAnalysisOrangeIconBadge extends StatelessWidget {
  const _AdvancedAnalysisOrangeIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: advancedAnalysisOrange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FB6414),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.monitor_heart_outlined,
        color: advancedAnalysisCard,
        size: 24,
      ),
    );
  }
}
