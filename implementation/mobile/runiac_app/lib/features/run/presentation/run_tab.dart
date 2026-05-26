import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/run_controls.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_plan_card.dart';

class RunTab extends StatelessWidget {
  const RunTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: RuniacColors.background,
        child: Stack(
          children: [
            const Positioned.fill(child: RunMapPlaceholder()),
            Positioned(
              left: 20,
              right: 20,
              bottom: 28,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 360;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: const RunPlanCard(),
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: RunControls(compact: compact),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
