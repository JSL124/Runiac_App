import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/run_map_placeholder.dart';
import 'widgets/run_plan_card.dart';

class RunLaunchScreen extends StatelessWidget {
  const RunLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: RunMapPlaceholder()),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: RuniacColors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A172033),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: RuniacColors.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: const _RunLaunchOverlays(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunLaunchOverlays extends StatelessWidget {
  const _RunLaunchOverlays();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RunPlanCard(),
                SizedBox(height: compact ? 14 : 18),
                _RunLaunchControls(compact: compact),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RunLaunchControls extends StatelessWidget {
  const _RunLaunchControls({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final startSize = compact ? 88.0 : 96.0;
    final sideGap = compact ? 10.0 : 14.0;
    final sideHeight = compact ? 46.0 : 48.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _RunLaunchSecondaryAction(
            icon: Icons.tune,
            label: 'Setting',
            height: sideHeight,
          ),
        ),
        SizedBox(width: sideGap),
        SizedBox(
          width: startSize,
          height: startSize,
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              elevation: 6,
              padding: EdgeInsets.zero,
              shadowColor: const Color(0x332F50C7),
              shape: const CircleBorder(),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Start'),
          ),
        ),
        SizedBox(width: sideGap),
        Expanded(
          child: _RunLaunchSecondaryAction(
            icon: Icons.alt_route,
            label: 'Route setup',
            height: sideHeight,
          ),
        ),
      ],
    );
  }
}

class _RunLaunchSecondaryAction extends StatelessWidget {
  const _RunLaunchSecondaryAction({
    required this.icon,
    required this.label,
    required this.height,
  });

  final IconData icon;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
      style: OutlinedButton.styleFrom(
        backgroundColor: RuniacColors.white,
        foregroundColor: RuniacColors.primaryBlue,
        side: const BorderSide(color: RuniacColors.border),
        minimumSize: Size.fromHeight(height),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}
