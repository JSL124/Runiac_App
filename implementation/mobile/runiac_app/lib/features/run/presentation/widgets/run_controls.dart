import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class RunControls extends StatelessWidget {
  const RunControls({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final startSize = compact ? 88.0 : 96.0;
    final sideGap = compact ? 10.0 : 14.0;
    final sideHeight = compact ? 46.0 : 48.0;
    final sideFontSize = compact ? 12.0 : 13.0;
    final sideIconSize = compact ? 17.0 : 18.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _RunSecondaryControl(
                icon: Icons.tune,
                label: 'Setting',
                height: sideHeight,
                fontSize: sideFontSize,
                iconSize: sideIconSize,
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
              child: _RunSecondaryControl(
                icon: Icons.alt_route,
                label: 'Switch Route',
                height: sideHeight,
                fontSize: sideFontSize,
                iconSize: sideIconSize,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RunSecondaryControl extends StatelessWidget {
  const _RunSecondaryControl({
    required this.icon,
    required this.label,
    required this.height,
    required this.fontSize,
    required this.iconSize,
  });

  final IconData icon;
  final String label;
  final double height;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: iconSize),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
      style: OutlinedButton.styleFrom(
        backgroundColor: RuniacColors.white,
        foregroundColor: RuniacColors.primaryBlue,
        side: const BorderSide(color: RuniacColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        minimumSize: Size.fromHeight(height),
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}
