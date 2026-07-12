import 'package:flutter/material.dart';

import '../../../../core/assets/runiac_assets.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';
import '../data/account_profile_demo_snapshots.dart';

class AccountIdentityCard extends StatelessWidget {
  const AccountIdentityCard({required this.snapshot, super.key});

  final AccountProfileDemoSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _IdentityAccentStrip(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RuniacLevelProfileBadge(
                key: const ValueKey('account-profile-level-badge'),
                initials: snapshot.avatarInitials,
                levelLabel: snapshot.previewLevelBadge,
                progressFraction: snapshot.levelProgressFraction,
                size: 104,
                badgeHeight: 28,
                badgeMinWidth: 64,
                badgeHorizontalPadding: 11,
                badgeFontSize: 12,
                discColor: RuniacColors.primaryBlue,
                discBorderColor: RuniacColors.white,
                initialsColor: RuniacColors.white,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _AccountDivisionBadge(
                          divisionKey: snapshot.divisionKey,
                          divisionLabel: snapshot.divisionLabel,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            snapshot.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RuniacColors.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      snapshot.regionLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RuniacColors.primaryBlue,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountDivisionBadge extends StatelessWidget {
  const _AccountDivisionBadge({
    required this.divisionKey,
    required this.divisionLabel,
  });

  final String divisionKey;
  final String divisionLabel;

  @override
  Widget build(BuildContext context) {
    final assetPath = _divisionAssetPath(divisionKey);
    final isUnranked =
        assetPath == null || divisionLabel.trim().toLowerCase() == 'unranked';
    final semanticLabel = isUnranked
        ? 'Unranked division'
        : '${divisionLabel.trim()} division';

    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox.square(
        key: ValueKey(
          isUnranked
              ? 'account-division-badge-unranked'
              : 'account-division-badge-${divisionKey.trim()}',
        ),
        dimension: 30,
        child: isUnranked
            ? const Icon(
                Icons.shield_outlined,
                color: RuniacColors.border,
                size: 26,
              )
            : Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}

String? _divisionAssetPath(String divisionKey) {
  return switch (divisionKey.trim()) {
    'tier_01' => RuniacAssets.leaderboardLeagueIron,
    'tier_02' => RuniacAssets.leaderboardLeagueBronze,
    'tier_03' => RuniacAssets.leaderboardLeagueSilver,
    'tier_04' => RuniacAssets.leaderboardLeagueGold,
    'tier_05' => RuniacAssets.leaderboardLeaguePlatinum,
    'tier_06' => RuniacAssets.leaderboardLeagueEmerald,
    'tier_07' => RuniacAssets.leaderboardLeagueDiamond,
    'tier_08' => RuniacAssets.leaderboardLeagueMaster,
    'tier_09' => RuniacAssets.leaderboardLeagueGrandmaster,
    'tier_10' => RuniacAssets.leaderboardLeagueChallenger,
    _ => null,
  };
}

class AccountLevelUpGauge extends StatelessWidget {
  const AccountLevelUpGauge({required this.snapshot, super.key});

  final AccountProfileDemoSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final fraction = snapshot.levelProgressFraction.clamp(0.0, 1.0);
    final percentLabel = '${(fraction * 100).round()}%';
    final caption = snapshot.levelUpCaption;
    final trailingLabel = snapshot.levelXpSummary.isEmpty
        ? percentLabel
        : snapshot.levelXpSummary;
    final semanticLabel = [
      'Level progress $percentLabel',
      if (caption.isNotEmpty) caption,
      if (snapshot.levelXpSummary.isNotEmpty) snapshot.levelXpSummary,
    ].join(', ');

    return Semantics(
      label: semanticLabel,
      child: DecoratedBox(
        key: const ValueKey('account-level-up-gauge'),
        decoration: BoxDecoration(
          color: RuniacColors.sectionSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: RuniacColors.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    snapshot.previewLevelBadge,
                    style: const TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    snapshot.nextLevelBadge,
                    style: const TextStyle(
                      color: RuniacColors.textSecondary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: RuniacColors.innerTileSurface),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fraction,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: RuniacColors.primaryBlue,
                            borderRadius: BorderRadius.all(
                              Radius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (caption.isNotEmpty)
                    Expanded(
                      child: Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  Text(
                    trailingLabel,
                    style: const TextStyle(
                      color: RuniacColors.primaryBlue,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountPreviewNote extends StatelessWidget {
  const AccountPreviewNote({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.innerTileSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              color: RuniacColors.primaryBlue,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityAccentStrip extends StatelessWidget {
  const _IdentityAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
