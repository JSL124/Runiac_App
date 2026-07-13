import 'package:flutter/material.dart';

import '../../../../core/assets/runiac_assets.dart';

class AccountChallengeBadgeCase extends StatelessWidget {
  const AccountChallengeBadgeCase({super.key});

  static const _caseAspectRatio = 1448 / 1086;
  static const _badgeSlots = [
    _BadgeSlot(0.23, 0.235, 0.245, RuniacAssets.challengeBadge10k),
    _BadgeSlot(0.5, 0.235, 0.245, RuniacAssets.challengeBadge20k),
    _BadgeSlot(0.78, 0.235, 0.24, RuniacAssets.challengeBadge42kMarathon),
    _BadgeSlot(0.23, 0.51, 0.245, RuniacAssets.challengeBadge100k),
    _BadgeSlot(0.5, 0.51, 0.245, RuniacAssets.challengeBadge200k),
    _BadgeSlot(0.78, 0.50, 0.245, RuniacAssets.challengeBadge250k),
    _BadgeSlot(0.226, 0.795, 0.265, RuniacAssets.challengeBadge300k),
    _BadgeSlot(0.5, 0.794, 0.33, RuniacAssets.challengeBadge500k),
    _BadgeSlot(0.785, 0.8, 0.28, RuniacAssets.challengeBadge1000k),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Challenge badge case preview with nine collection badges',
      image: true,
      child: AspectRatio(
        aspectRatio: _caseAspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      constraints.maxWidth * 0.035,
                    ),
                    child: Image.asset(
                      RuniacAssets.challengeBadgeCase,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                for (final slot in _badgeSlots)
                  Positioned(
                    left:
                        constraints.maxWidth * slot.centerX -
                        constraints.maxWidth * slot.sizeFraction / 2,
                    top:
                        constraints.maxHeight * slot.centerY -
                        constraints.maxWidth * slot.sizeFraction / 2,
                    width: constraints.maxWidth * slot.sizeFraction,
                    height: constraints.maxWidth * slot.sizeFraction,
                    child: ExcludeSemantics(
                      child: Image.asset(slot.assetPath, fit: BoxFit.contain),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BadgeSlot {
  const _BadgeSlot(
    this.centerX,
    this.centerY,
    this.sizeFraction,
    this.assetPath,
  );

  final double centerX;
  final double centerY;
  final double sizeFraction;
  final String assetPath;
}
