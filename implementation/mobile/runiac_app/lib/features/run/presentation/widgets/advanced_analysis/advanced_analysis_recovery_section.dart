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
        ],
      ),
    );
  }
}

class _AdvancedAnalysisRecoveryGrid extends StatelessWidget {
  const _AdvancedAnalysisRecoveryGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < advancedAnalysisRecoveryFacts.length; i += 2) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _AdvancedAnalysisRecoveryFact(
                  fact: advancedAnalysisRecoveryFacts[i],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: i + 1 < advancedAnalysisRecoveryFacts.length
                    ? _AdvancedAnalysisRecoveryFact(
                        fact: advancedAnalysisRecoveryFacts[i + 1],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (i + 2 < advancedAnalysisRecoveryFacts.length)
            const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _AdvancedAnalysisRecoveryFact extends StatelessWidget {
  const _AdvancedAnalysisRecoveryFact({required this.fact});

  final AdvancedAnalysisRecoveryFactData fact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: Column(
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
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fact.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: advancedAnalysisInk,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
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
