import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_back_header.dart';
import '../models/leaderboard_display_models.dart';

class RunnerAchievementProfileScreen extends StatelessWidget {
  const RunnerAchievementProfileScreen({
    super.key,
    required this.profile,
    required this.onBack,
  });

  final RunnerAchievementProfileSnapshot profile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // Scaffold (not a bare ColoredBox) so this screen keeps a Material
    // ancestor when pushed as its own route; without one, every Text renders
    // with debug yellow underlines.
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Runner profile',
              tooltip: 'Back to Rankings',
              onBack: onBack,
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RunnerIdentityCard(profile: profile),
                      const SizedBox(height: 16),
                      _RunnerPublicMetrics(profile: profile),
                      const SizedBox(height: 18),
                      _RunnerAchievementsSection(profile: profile),
                      const SizedBox(height: 14),
                      Text(
                        profile.privacyNote,
                        key: const Key('runner_profile_privacy_note'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunnerIdentityCard extends StatelessWidget {
  const _RunnerIdentityCard({required this.profile});

  final RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 12,
            decoration: const BoxDecoration(
              color: RuniacColors.accentOrange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    _RunnerProfileAvatar(profile: profile),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RuniacColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFFE1E8FF),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  profile.regionRankLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFE1E8FF),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: RuniacColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          color: RuniacColors.accentOrange,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profile.divisionLevelLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: RuniacColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunnerProfileAvatar extends StatelessWidget {
  const _RunnerProfileAvatar({required this.profile});

  final RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: RuniacColors.accentOrange, width: 3),
          ),
          child: Text(
            profile.initial,
            style: const TextStyle(
              color: RuniacColors.primaryBlue,
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          bottom: -11,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: RuniacColors.accentOrange,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                profile.levelBadgeLabel,
                style: const TextStyle(
                  color: RuniacColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RunnerPublicMetrics extends StatelessWidget {
  const _RunnerPublicMetrics({required this.profile});

  final RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RunnerMetricTile(
            key: const Key('runner_profile_total_distance_metric'),
            icon: Icons.route_outlined,
            value: profile.totalDistanceLabel,
            label: 'Total distance',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RunnerMetricTile(
            key: const Key('runner_profile_best_streak_metric'),
            icon: Icons.water_drop_outlined,
            value: profile.bestStreakLabel,
            label: 'Best streak',
          ),
        ),
      ],
    );
  }
}

class _RunnerMetricTile extends StatelessWidget {
  const _RunnerMetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE3F8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: RuniacColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RunnerMetricValueText(value: value),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RunnerMetricValueText extends StatelessWidget {
  const RunnerMetricValueText({super.key, required this.value});

  static const double maxFontSize = 24;
  static const double minFontSize = 16;

  final String value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = resolveRunnerMetricValueFontSize(
          value: value,
          maxWidth: constraints.maxWidth,
        );

        return Text(
          value,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            color: RuniacColors.primaryBlue,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
        );
      },
    );
  }
}

double resolveRunnerMetricValueFontSize({
  required String value,
  required double maxWidth,
}) {
  if (!maxWidth.isFinite || maxWidth <= 0) {
    return RunnerMetricValueText.minFontSize;
  }

  const minSize = RunnerMetricValueText.minFontSize;
  const maxSize = RunnerMetricValueText.maxFontSize;
  final painter = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);

  for (var fontSize = maxSize; fontSize >= minSize; fontSize--) {
    painter.text = TextSpan(
      text: value,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900),
    );
    painter.layout(maxWidth: double.infinity);

    if (painter.width <= maxWidth) {
      return fontSize;
    }
  }

  return minSize;
}

class _RunnerAchievementsSection extends StatelessWidget {
  const _RunnerAchievementsSection({required this.profile});

  final RunnerAchievementProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('runner_profile_achievements_section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Achievements',
                style: TextStyle(
                  color: RuniacColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${profile.badges.length} earned',
              style: const TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 18),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDDE3F8)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) =>
                _RunnerAchievementBadge(badge: profile.badges[index]),
          ),
        ),
      ],
    );
  }
}

class _RunnerAchievementBadge extends StatelessWidget {
  const _RunnerAchievementBadge({required this.badge});

  final RunnerAchievementBadgeSnapshot badge;

  @override
  Widget build(BuildContext context) {
    final badgeColor = badge.highlighted
        ? RuniacColors.accentOrange
        : RuniacColors.primaryBlue;

    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: badge.highlighted
                ? const Color(0xFFFFECE5)
                : RuniacColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: badgeColor.withValues(alpha: 0.28)),
          ),
          child: Icon(badge.icon, color: badgeColor, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          badge.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 13,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
