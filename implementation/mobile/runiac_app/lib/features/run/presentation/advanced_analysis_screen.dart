import 'package:flutter/material.dart';
import 'package:runiac_app/core/theme/runiac_colors.dart';
import 'package:runiac_app/core/widgets/runiac_back_header.dart';
import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';

import 'widgets/advanced_analysis/advanced_analysis_metric_sections.dart';
import 'widgets/advanced_analysis/advanced_analysis_overview_section.dart';
import 'widgets/advanced_analysis/advanced_analysis_theme.dart';
import 'widgets/share_achievement_sheet.dart';

class AdvancedAnalysisScreen extends StatelessWidget {
  const AdvancedAnalysisScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.analysisSnapshot,
  });

  final String title;
  final String subtitle;
  final AdvancedAnalysisSnapshot? analysisSnapshot;

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (context) => const ShareAchievementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        child: Column(
          children: [
            RuniacBackHeader(
              title: title,
              subtitle: subtitle,
              tooltip: 'Back to summary',
              onBack: () => Navigator.of(context).maybePop(),
              titleStyle: const TextStyle(
                color: advancedAnalysisBlue,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                height: 1.15,
              ),
              subtitleStyle: const TextStyle(
                color: advancedAnalysisBlue60,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
              trailing: IconButton(
                tooltip: 'Share advanced analysis',
                onPressed: () => _showShareSheet(context),
                style: IconButton.styleFrom(
                  foregroundColor: advancedAnalysisBlue,
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AdvancedAnalysisOverviewSection(),
                      const SizedBox(height: 14),
                      const AdvancedAnalysisPaceSection(),
                      const SizedBox(height: 14),
                      const AdvancedAnalysisHeartRateSection(),
                      const SizedBox(height: 14),
                      const AdvancedAnalysisElevationSection(),
                      const SizedBox(height: 14),
                      const AdvancedAnalysisCadenceSection(),
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
