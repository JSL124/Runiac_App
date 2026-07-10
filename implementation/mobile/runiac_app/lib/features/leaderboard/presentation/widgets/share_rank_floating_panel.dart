import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/assets/runiac_assets.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_share_bottom_sheet.dart';

class ShareRankFloatingPanel extends StatelessWidget {
  const ShareRankFloatingPanel({
    super.key,
    required this.regionName,
    required this.divisionName,
    required this.rankLabel,
  });

  final String regionName;
  final String divisionName;
  final String rankLabel;

  Future<void> _copyRank(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            'I\'m ranked $rankLabel in $regionName\'s $divisionName on Runiac.',
      ),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rank copied to clipboard')));
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share action coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return RuniacShareBottomSheet(
      key: const Key('leaderboard_share_rank_panel'),
      title: 'Share your rank',
      preview: LayoutBuilder(
        builder: (context, constraints) {
          // Cap the card width by the available preview height too, so the
          // fixed-aspect card plus page indicator always fit without a bottom
          // overflow on shorter screens.
          const cardAspectRatio = 1122 / 1402;
          const belowCardExtent = 24.0 + 8.0 + 7.0;
          final availableCardHeight = (constraints.maxHeight - belowCardExtent)
              .clamp(0.0, double.infinity);
          final cardWidth = (MediaQuery.sizeOf(context).width * 0.88)
              .clamp(0.0, constraints.maxWidth)
              .clamp(0.0, availableCardHeight * cardAspectRatio)
              .toDouble();

          return SizedBox(
            height: constraints.maxHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _ShareRankCardPreview(
                        regionName: regionName,
                        divisionName: divisionName,
                        rankLabel: rankLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _ShareRankPageIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      shareTargets: [
        RuniacShareTargetButton(
          icon: Icons.camera_alt_outlined,
          iconAsset: RuniacAssets.instagramStoriesIcon,
          label: 'Instagram',
          onPressed: () => _showComingSoon(context),
        ),
        RuniacShareTargetButton(
          key: const Key('leaderboard_copy_rank_action'),
          icon: Icons.content_paste_outlined,
          label: 'Copy to Clipboard',
          onPressed: () => _copyRank(context),
        ),
        RuniacShareTargetButton(
          icon: Icons.file_download_outlined,
          label: 'Save',
          onPressed: () => _showComingSoon(context),
        ),
        RuniacShareTargetButton(
          icon: Icons.link,
          label: 'Copy Link',
          onPressed: () => _showComingSoon(context),
        ),
        RuniacShareTargetButton(
          icon: Icons.more_horiz,
          label: 'More',
          onPressed: () => _showComingSoon(context),
        ),
      ],
    );
  }
}

class _ShareRankPageIndicator extends StatelessWidget {
  const _ShareRankPageIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: Key('leaderboard_share_rank_page_indicator'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShareRankIndicatorDot(active: true),
        SizedBox(width: 6),
        _ShareRankIndicatorDot(active: false),
        SizedBox(width: 6),
        _ShareRankIndicatorDot(active: false),
      ],
    );
  }
}

class _ShareRankIndicatorDot extends StatelessWidget {
  const _ShareRankIndicatorDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? RuniacColors.primaryBlue
            : RuniacColors.primaryBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(width: active ? 18 : 7, height: 7),
    );
  }
}

class _ShareRankCardPreview extends StatelessWidget {
  const _ShareRankCardPreview({
    required this.regionName,
    required this.divisionName,
    required this.rankLabel,
  });

  final String regionName;
  final String divisionName;
  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1122 / 1402,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;

          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              key: const Key('leaderboard_share_rank_card_preview'),
              fit: StackFit.expand,
              children: [
                Image.asset(
                  RuniacAssets.leaderboardShareRankCardBackground,
                  key: const Key('leaderboard_share_rank_card_background'),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: cardWidth * 0.34,
                  right: cardWidth * 0.29,
                  top: cardHeight * 0.344,
                  height: cardHeight * 0.075,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      regionName,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: RuniacColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: cardWidth * 0.18,
                  right: cardWidth * 0.18,
                  top: cardHeight * 0.435,
                  height: cardHeight * 0.052,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      divisionName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE1E8FF),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: cardWidth * 0.2,
                  right: cardWidth * 0.2,
                  top: cardHeight * 0.535,
                  height: cardHeight * 0.225,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _ShareRankNumber(rankLabel: rankLabel),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShareRankNumber extends StatelessWidget {
  const _ShareRankNumber({required this.rankLabel});

  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    // Numeric ranks arrive as '#18'; a rank-less runner arrives as the plain
    // backend summary word (e.g. 'Unranked'), which reads wrong with the
    // decorative '#' glyph in front of it.
    final hasRankNumber = rankLabel.startsWith('#');
    final rankNumber = hasRankNumber ? rankLabel.substring(1) : rankLabel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (hasRankNumber)
          const Text(
            '#',
            style: TextStyle(
              color: RuniacColors.accentOrange,
              fontSize: 122,
              fontWeight: FontWeight.w900,
              height: 0.94,
              shadows: [
                Shadow(
                  color: Color(0xAA000000),
                  blurRadius: 16,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        Text(
          rankNumber,
          style: const TextStyle(
            color: RuniacColors.white,
            fontSize: 150,
            fontWeight: FontWeight.w900,
            height: 0.94,
            shadows: [
              Shadow(
                color: Color(0xAA000000),
                blurRadius: 16,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
