import 'package:flutter/material.dart';

import '../../../../core/assets/runiac_assets.dart';
import '../../domain/models/challenge_enums.dart';

/// Maps a tier to its user-created badge PNG asset. Every Challenge badge
/// rendering MUST route through here — never an icon, emoji, or generated art.
String challengeBadgeAsset(ChallengeTierId tierId) {
  return switch (tierId) {
    ChallengeTierId.k10 => RuniacAssets.challengeBadge10k,
    ChallengeTierId.k20 => RuniacAssets.challengeBadge20k,
    ChallengeTierId.k42 => RuniacAssets.challengeBadge42kMarathon,
    ChallengeTierId.k100 => RuniacAssets.challengeBadge100k,
    ChallengeTierId.k200 => RuniacAssets.challengeBadge200k,
    ChallengeTierId.k250 => RuniacAssets.challengeBadge250k,
    ChallengeTierId.k300 => RuniacAssets.challengeBadge300k,
    ChallengeTierId.k500 => RuniacAssets.challengeBadge500k,
    ChallengeTierId.k1000 => RuniacAssets.challengeBadge1000k,
  };
}

/// The tier's short display title (e.g. `10K`), taken verbatim from the backend
/// tier id wire value — never re-derived from a target metre figure.
String challengeTierTitle(ChallengeTierId tierId) => tierId.wireValue;

/// Renders a tier badge PNG at [size]. When [dimmed] (unearned/locked state)
/// the same asset is desaturated and faded — never swapped for other art.
class ChallengeBadgeImage extends StatelessWidget {
  const ChallengeBadgeImage({
    required this.tierId,
    required this.size,
    this.dimmed = false,
    super.key,
  });

  final ChallengeTierId tierId;
  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      challengeBadgeAsset(tierId),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    if (!dimmed) {
      return ExcludeSemantics(child: image);
    }
    return ExcludeSemantics(
      child: Opacity(
        opacity: 0.45,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0, //
            0.2126, 0.7152, 0.0722, 0, 0, //
            0.2126, 0.7152, 0.0722, 0, 0, //
            0, 0, 0, 1, 0, //
          ]),
          child: image,
        ),
      ),
    );
  }
}
