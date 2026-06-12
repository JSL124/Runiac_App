import 'package:flutter/material.dart';

import '../theme/runiac_colors.dart';

class RuniacBackHeader extends StatelessWidget {
  const RuniacBackHeader({
    required this.title,
    this.onBack,
    this.tooltip = 'Back',
    this.subtitle,
    this.trailing,
    this.titleKey,
    this.titleStyle,
    this.subtitleStyle,
    this.height = 56,
    this.trailingWidth = 48,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final String tooltip;
  final String? subtitle;
  final Widget? trailing;
  final Key? titleKey;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double height;
  final double trailingWidth;

  @override
  Widget build(BuildContext context) {
    final actionSlotWidth = trailing == null ? 48.0 : trailingWidth;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: actionSlotWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  label: tooltip,
                  button: true,
                  child: IconButton(
                    tooltip: tooltip,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: RuniacColors.primaryBlue,
                      size: 30,
                    ),
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _RuniacBackHeaderTitle(
                title: title,
                subtitle: subtitle,
                titleKey: titleKey,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
              ),
            ),
            SizedBox(
              width: actionSlotWidth,
              child: trailing == null
                  ? null
                  : Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuniacBackHeaderTitle extends StatelessWidget {
  const _RuniacBackHeaderTitle({
    required this.title,
    required this.subtitle,
    required this.titleKey,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  final String title;
  final String? subtitle;
  final Key? titleKey;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle ?? _defaultTitleStyle;
    final subtitle = this.subtitle;

    if (subtitle == null) {
      return Text(
        title,
        key: titleKey,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: effectiveTitleStyle,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          key: titleKey,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: effectiveTitleStyle,
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle ?? _defaultSubtitleStyle,
        ),
      ],
    );
  }
}

const _defaultTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w900,
);

const _defaultSubtitleStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 12.5,
  fontWeight: FontWeight.w600,
  height: 1.15,
);
