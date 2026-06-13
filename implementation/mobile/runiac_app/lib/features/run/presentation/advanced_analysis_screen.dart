import 'package:flutter/material.dart';
import 'package:runiac_app/core/widgets/runiac_back_header.dart';

import 'widgets/advanced_analysis/advanced_analysis_metric_sections.dart';
import 'widgets/advanced_analysis/advanced_analysis_overview_section.dart';
import 'widgets/advanced_analysis/advanced_analysis_recovery_section.dart';
import 'widgets/advanced_analysis/advanced_analysis_theme.dart';

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
      backgroundColor: advancedAnalysisSurface,
      body: SafeArea(
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Saturday Morning Run',
              subtitle: 'Today · 7:06 AM',
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
                onPressed: () => _showSoon(
                  context,
                  'Advanced analysis sharing will be available soon.',
                ),
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
                      const AdvancedAnalysisEffortSection(),
                      const SizedBox(height: 14),
                      const AdvancedAnalysisElevationSection(),
                      const SizedBox(height: 14),
                      const AdvancedAnalysisCadenceSection(),
                      const SizedBox(height: 14),
                      AdvancedAnalysisRecoverySection(
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
