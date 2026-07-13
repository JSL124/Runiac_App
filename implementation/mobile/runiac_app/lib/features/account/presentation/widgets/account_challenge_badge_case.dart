import 'package:flutter/material.dart';

import '../../../../core/assets/runiac_assets.dart';

class AccountChallengeBadgeCase extends StatelessWidget {
  const AccountChallengeBadgeCase({super.key});

  static const _caseAspectRatio = 1371 / 982;
  static const _badgeSizeFraction = 0.255;

  static const _badgeSlots = [
    _BadgeSlot(0.232, 0.251, RuniacAssets.challengeBadge10k),
    _BadgeSlot(0.5, 0.251, RuniacAssets.challengeBadge20k),
    _BadgeSlot(0.768, 0.251, RuniacAssets.challengeBadge42kMarathon),
    _BadgeSlot(0.232, 0.544, RuniacAssets.challengeBadge100k),
    _BadgeSlot(0.5, 0.544, RuniacAssets.challengeBadge200k),
    _BadgeSlot(0.768, 0.544, RuniacAssets.challengeBadge250k),
    _BadgeSlot(0.232, 0.83, RuniacAssets.challengeBadge300k),
    _BadgeSlot(0.5, 0.83, RuniacAssets.challengeBadge500k),
    _BadgeSlot(0.768, 0.83, RuniacAssets.challengeBadge1000k),
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
            final badgeSize = constraints.maxWidth * _badgeSizeFraction;
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    RuniacAssets.challengeBadgeCase,
                    fit: BoxFit.fill,
                  ),
                ),
                for (final slot in _badgeSlots)
                  Positioned(
                    left: constraints.maxWidth * slot.centerX - badgeSize / 2,
                    top: constraints.maxHeight * slot.centerY - badgeSize / 2,
                    width: badgeSize,
                    height: badgeSize,
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
  const _BadgeSlot(this.centerX, this.centerY, this.assetPath);

  final double centerX;
  final double centerY;
  final String assetPath;
}
