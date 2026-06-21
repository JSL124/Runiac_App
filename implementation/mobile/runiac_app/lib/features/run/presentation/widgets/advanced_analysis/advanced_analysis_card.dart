import 'package:flutter/material.dart';
import 'package:runiac_app/core/theme/runiac_colors.dart';

import 'advanced_analysis_theme.dart';

class AdvancedAnalysisSection extends StatelessWidget {
  const AdvancedAnalysisSection({
    super.key,
    required this.title,
    required this.child,
    this.useDividers = false,
  });

  final String title;
  final Widget child;
  final bool useDividers;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: const TextStyle(
        color: advancedAnalysisBlue,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );

    if (useDividers) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleWidget,
          const SizedBox(height: 12),
          const Divider(color: advancedAnalysisBlue12, height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: child,
          ),
          const Divider(color: advancedAnalysisBlue12, height: 1, thickness: 1),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 12), child: titleWidget),
        AdvancedAnalysisCard(child: child),
      ],
    );
  }
}

class AdvancedAnalysisCard extends StatelessWidget {
  const AdvancedAnalysisCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: advancedAnalysisCard,
        border: Border.all(color: RuniacColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
