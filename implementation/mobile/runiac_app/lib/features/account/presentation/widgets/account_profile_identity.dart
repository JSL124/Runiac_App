import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
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
              _AvatarWithLevelBadge(
                initials: snapshot.avatarInitials,
                levelBadge: snapshot.previewLevelBadge,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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

class _AvatarWithLevelBadge extends StatelessWidget {
  const _AvatarWithLevelBadge({
    required this.initials,
    required this.levelBadge,
  });

  final String initials;
  final String levelBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98,
      height: 98,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          _AccountAvatar(initials: initials),
          if (levelBadge.isNotEmpty)
            Positioned(
              top: 69,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: RuniacColors.primaryBlue,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: RuniacColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: RuniacColors.primaryBlue.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    levelBadge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: RuniacColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(5),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: RuniacColors.accentOrange,
        shape: BoxShape.circle,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: RuniacColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: RuniacColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
