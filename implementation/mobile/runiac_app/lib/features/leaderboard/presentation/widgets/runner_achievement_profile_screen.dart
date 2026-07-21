import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/assets/runiac_assets.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_back_header.dart';
import '../../../moderation/data/report_user_writer.dart';
import '../../../moderation/presentation/widgets/report_user_sheet.dart';
import '../models/leaderboard_display_models.dart';

class RunnerAchievementProfileScreen extends StatelessWidget {
  const RunnerAchievementProfileScreen({
    super.key,
    required this.profile,
    required this.onBack,
  });

  final RunnerAchievementProfileSnapshot profile;
  final VoidCallback onBack;

  // Never offer reporting yourself, and never offer it for a profile with no
  // real backing uid (demo/preview snapshots) — the security rules would
  // reject both anyway, but hiding the affordance keeps the UI honest.
  bool get _canReport =>
      !profile.isCurrentUser &&
      profile.uid.isNotEmpty &&
      _currentReporterUid() != null;

  // Guarded the same way activity_route_snapshot_thumbnail_cache.dart guards
  // its own FirebaseAuth.instance read: widget tests that build this screen
  // with static/demo repositories never call Firebase.initializeApp(), so
  // FirebaseAuth.instance itself throws rather than just returning a null
  // user.
  String? _currentReporterUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } on Object {
      return null;
    }
  }

  void _showReportSheet(BuildContext context) {
    final reporterUid = _currentReporterUid();
    if (reporterUid == null) return;
    showReportUserSheet(
      context,
      targetDisplayName: profile.name,
      onSubmit: (reason, description) => reportUser(
        reporterUid: reporterUid,
        targetId: profile.uid,
        reason: reason,
        description: description,
      ),
    );
  }

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
              trailing: _canReport
                  ? Semantics(
                      label: 'Report ${profile.name}',
                      button: true,
                      child: IconButton(
                        key: const Key('runner_profile_report_action'),
                        tooltip: 'Report ${profile.name}',
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: RuniacColors.primaryBlue,
                        ),
                        onPressed: () => _showReportSheet(context),
                      ),
                    )
                  : null,
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  profile.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: RuniacColors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _RunnerDivisionBadge(profile: profile),
                            ],
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

class _RunnerDivisionBadge extends StatelessWidget {
  const _RunnerDivisionBadge({required this.profile});

  final RunnerAchievementProfileSnapshot profile;

  String? _divisionName() {
    final segments = profile.divisionLevelLabel.split(' · ');
    if (segments.isEmpty) {
      return null;
    }
    return segments.first.trim();
  }

  String? _divisionAssetPath(String divisionName) {
    return switch (divisionName.toLowerCase()) {
      'iron' => RuniacAssets.leaderboardLeagueIron,
      'bronze' => RuniacAssets.leaderboardLeagueBronze,
      'silver' => RuniacAssets.leaderboardLeagueSilver,
      'gold' => RuniacAssets.leaderboardLeagueGold,
      'platinum' => RuniacAssets.leaderboardLeaguePlatinum,
      'emerald' => RuniacAssets.leaderboardLeagueEmerald,
      'diamond' => RuniacAssets.leaderboardLeagueDiamond,
      'master' => RuniacAssets.leaderboardLeagueMaster,
      'grandmaster' => RuniacAssets.leaderboardLeagueGrandmaster,
      'challenger' => RuniacAssets.leaderboardLeagueChallenger,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final divisionName = _divisionName();
    if (divisionName == null) {
      return const SizedBox.shrink();
    }
    final assetPath = _divisionAssetPath(divisionName);
    if (assetPath == null) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: '$divisionName division',
      image: true,
      child: SizedBox.square(
        key: const Key('runner_profile_division_badge'),
        dimension: 30,
        child: Image.asset(assetPath, fit: BoxFit.contain),
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
            key: const Key('runner_profile_max_streak_metric'),
            icon: Icons.local_fire_department,
            value: profile.bestStreakLabel,
            label: 'Max streak',
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
          padding: const EdgeInsets.fromLTRB(14, 22, 14, 20),
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(26),
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
    if (badge.highlighted) {
      return _buildSlot(
        iconColor: RuniacColors.accentOrange,
        fillColor: const Color(0xFFFFECE5),
        borderColor: RuniacColors.accentOrange.withValues(alpha: 0.28),
        labelColor: RuniacColors.textSecondary,
      );
    }

    // Unearned/generic badges get the same dimmed/desaturated treatment
    // ChallengeBadgeImage applies to unearned tier badges: muted fill, muted
    // icon tone, no vivid accent.
    return _buildSlot(
      iconColor: RuniacColors.textSecondary.withValues(alpha: 0.55),
      fillColor: const Color(0xFFF0F1F5),
      borderColor: const Color(0xFFE1E3EA),
      labelColor: RuniacColors.textSecondary.withValues(alpha: 0.7),
    );
  }

  Widget _buildSlot({
    required Color iconColor,
    required Color fillColor,
    required Color borderColor,
    required Color labelColor,
  }) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Icon(badge.icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          badge.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
