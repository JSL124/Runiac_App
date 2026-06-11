import 'package:flutter/material.dart';

import '../theme/runiac_colors.dart';

class RuniacBackHeader extends StatelessWidget {
  const RuniacBackHeader({
    required this.title,
    this.onBack,
    this.tooltip = 'Back',
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              tooltip: tooltip,
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: RuniacColors.primaryBlue,
                size: 30,
              ),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
