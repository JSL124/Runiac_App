import 'package:flutter/material.dart';

import 'advanced_analysis_theme.dart';

class AdvancedAnalysisCard extends StatelessWidget {
  const AdvancedAnalysisCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: advancedAnalysisCard,
        border: Border.all(color: advancedAnalysisBlue07),
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
