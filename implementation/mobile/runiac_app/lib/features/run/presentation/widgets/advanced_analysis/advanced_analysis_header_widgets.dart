import 'package:flutter/material.dart';
import 'package:runiac_app/core/widgets/runiac_section_header.dart';

import 'advanced_analysis_theme.dart';

class AdvancedAnalysisSectionHeader extends StatelessWidget {
  const AdvancedAnalysisSectionHeader({
    super.key,
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
    return RuniacSectionHeader(
      title: title,
      leading: _AdvancedAnalysisIconTile(icon: icon),
      leadingSpacing: 12,
      trailing: badge == null
          ? null
          : _AdvancedAnalysisBadge(label: badge!, hot: hotBadge),
      titleStyle: const TextStyle(
        color: advancedAnalysisInk,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
    );
  }
}

class AdvancedAnalysisInsightBadge extends StatelessWidget {
  const AdvancedAnalysisInsightBadge({
    super.key,
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
        color: highlighted ? advancedAnalysisOrange08 : advancedAnalysisSurface,
        border: Border.all(
          color: highlighted
              ? advancedAnalysisOrange16
              : advancedAnalysisBlue12,
        ),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: highlighted ? advancedAnalysisOrange : advancedAnalysisBlue,
            size: 15,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: highlighted
                  ? advancedAnalysisOrange
                  : advancedAnalysisBlue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedAnalysisIconTile extends StatelessWidget {
  const _AdvancedAnalysisIconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: advancedAnalysisSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: advancedAnalysisBlue, size: 22),
    );
  }
}

class _AdvancedAnalysisBadge extends StatelessWidget {
  const _AdvancedAnalysisBadge({required this.label, this.hot = false});

  final String label;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hot ? advancedAnalysisOrange12 : advancedAnalysisBlue07,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: hot ? advancedAnalysisOrange : advancedAnalysisBlue45,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: hot ? advancedAnalysisOrange : advancedAnalysisBlue75,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
