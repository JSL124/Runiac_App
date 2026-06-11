import 'package:flutter/material.dart';

import '../theme/runiac_colors.dart';

class SoftNotice extends StatelessWidget {
  const SoftNotice({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RuniacColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: RuniacColors.textSecondary,
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}
