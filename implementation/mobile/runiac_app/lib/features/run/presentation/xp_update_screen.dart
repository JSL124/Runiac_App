import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:runiac_app/core/theme/runiac_colors.dart';

import '../domain/models/xp_update_display_model.dart';
import 'data/run_completion_demo_snapshots.dart';

const _blue = Color(0xFF2F51C8);
const _orange = Color(0xFFFB6414);
const _pureWhite = Color(0xFFFFFFFF);
const _priorSolid = Color(0xFFBBC7EE);
const _lightBlue = Color(0xFF7C95E8);
const _blue60 = Color(0x992F51C8);
const _blue45 = Color(0x732F51C8);
const _blue12 = Color(0x1F2F51C8);
const _blue10 = Color(0x1A2F51C8);
const _blue06 = Color(0x0F2F51C8);
const _orange12 = Color(0x1FFB6414);

class XpUpdateScreen extends StatefulWidget {
  const XpUpdateScreen({super.key, this.model = defaultXpUpdateDisplayModel});

  final XpUpdateDisplayModel model;

  @override
  State<XpUpdateScreen> createState() => _XpUpdateScreenState();
}

class _XpUpdateScreenState extends State<XpUpdateScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _particles = _ConfettiParticle.deterministicBurst();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            final tokens = _XpLayoutTokens.fromCompact(compact);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final stage = _XpStage(
                      t: _controller.value,
                      model: widget.model,
                    );

                    return Column(
                      children: [
                        _XpHeader(onBack: () => Navigator.of(context).pop()),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              20,
                              compact ? 0 : 4,
                              20,
                              compact ? 12 : 24,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    constraints.maxHeight -
                                    56 -
                                    (compact ? 12 : 28),
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Opacity(
                                      opacity: stage.entrance,
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          (1 - stage.entrance) * 18,
                                        ),
                                        child: _HeroRewardCard(
                                          model: widget.model,
                                          stage: stage,
                                          tokens: tokens,
                                          particles: _particles,
                                          reduceMotion: reduceMotion,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: compact ? 10 : 12),
                                    _TotalXpCard(
                                      model: widget.model,
                                      stage: stage,
                                    ),
                                    SizedBox(height: compact ? 10 : 12),
                                    _StreakCard(
                                      model: widget.model,
                                      stage: stage,
                                    ),
                                    SizedBox(height: compact ? 12 : 18),
                                    const Spacer(),
                                    _GoHomeButton(
                                      height: compact ? 52 : 56,
                                      onPressed: _goHome,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Staged animation clock. All sub-stages are derived from a single controller
/// value so the celebration reads as one choreographed sequence.
class _XpStage {
  const _XpStage({required this.t, required this.model});

  final double t;
  final XpUpdateDisplayModel model;

  double _iv(double a, double b, [Curve curve = Curves.linear]) {
    return Interval(a, b, curve: curve).transform(t);
  }

  double get entrance => _iv(0.0, 0.15, Curves.easeOut);
  double get confetti => _iv(0.10, 0.45, Curves.easeOut);
  double get earned => _iv(0.15, 0.55, Curves.easeOutCubic);
  double get earnedPop => math.sin(_iv(0.42, 0.58, Curves.easeInOut) * math.pi);
  double get ring => _iv(0.45, 0.85, Curves.easeInOutCubic);
  double get total => _iv(0.70, 1.0, Curves.easeOutCubic);
  double get streakTick => _iv(0.72, 0.95, Curves.easeOut);
  double get streakPulse =>
      math.sin(_iv(0.78, 0.96, Curves.easeInOut) * math.pi);

  int get earnedXpShown => _lerp(0, model.earnedXp.toDouble(), earned).round();
  int get totalXpShown =>
      _lerp(model.previousTotalXp.toDouble(), model.totalXp.toDouble(), total)
          .round();
  int get streakShown => _lerp(
    model.previousStreakCount.toDouble(),
    model.streakCount.toDouble(),
    streakTick,
  ).round();

  /// Ring / bar fill fraction. Level-up fills to full then restarts into the
  /// new level's remainder inside the same fill window.
  double get progressFraction {
    final prev = model.previousProgressFraction;
    final cur = model.currentProgressFraction;
    if (!model.didLevelUp) {
      return _lerp(prev, cur, ring);
    }
    if (ring < 0.6) {
      return _lerp(prev, 1.0, ring / 0.6);
    }
    return _lerp(0.0, cur, (ring - 0.6) / 0.4);
  }

  /// Prior fraction still shown as the muted "already earned" band.
  double get priorFraction => model.didLevelUp ? 0.0 : model.previousProgressFraction;

  bool get showNewLevelBadge => model.didLevelUp && ring >= 0.6;

  double get levelBadgeScale {
    if (!model.didLevelUp || ring < 0.6) {
      return 1;
    }
    final p = ((ring - 0.6) / 0.4).clamp(0.0, 1.0);
    return 1 + 0.22 * math.sin(p * math.pi);
  }

  double get levelUpChipOpacity {
    if (!model.didLevelUp) {
      return 0;
    }
    return ((ring - 0.6) / 0.18).clamp(0.0, 1.0);
  }
}

class _XpHeader extends StatelessWidget {
  const _XpHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back to summary',
              onPressed: onBack,
              style: IconButton.styleFrom(
                foregroundColor: _blue45,
                minimumSize: const Size(40, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.chevron_left_rounded, size: 30),
            ),
            const Expanded(
              child: Text(
                'XP & Streak Update',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _blue,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

class _HeroRewardCard extends StatelessWidget {
  const _HeroRewardCard({
    required this.model,
    required this.stage,
    required this.tokens,
    required this.particles,
    required this.reduceMotion,
  });

  final XpUpdateDisplayModel model;
  final _XpStage stage;
  final _XpLayoutTokens tokens;
  final List<_ConfettiParticle> particles;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final confettiExtent = tokens.ring + 104;
    final showConfetti =
        !reduceMotion && model.isAwarded && stage.confetti < 1;

    return _XpCardSurface(
      radius: 24,
      padding: EdgeInsets.fromLTRB(20, tokens.heroY, 20, compactBottom),
      shadow: const BoxShadow(
        color: Color(0x1A2F51C8),
        blurRadius: 34,
        offset: Offset(0, 14),
      ),
      child: Column(
        children: [
          Text(
            _heroTitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _blue,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          SizedBox(height: tokens.titleGap),
          SizedBox(
            width: confettiExtent,
            height: confettiExtent,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (showConfetti)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConfettiPainter(
                        particles: particles,
                        progress: stage.confetti,
                      ),
                    ),
                  ),
                _LevelRing(
                  model: model,
                  progress: stage.progressFraction,
                  ringSize: tokens.ring,
                  avatarSize: tokens.avatar,
                  showBadge: model.level > 0,
                  badgeLabel: _badgeLabel(),
                  badgeScale: stage.levelBadgeScale,
                ),
                if (model.didLevelUp)
                  Positioned(
                    top: 0,
                    child: Opacity(
                      opacity: stage.levelUpChipOpacity,
                      child: const _LevelUpChip(),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: tokens.xpTopGap),
          _heroBody(),
        ],
      ),
    );
  }

  Widget _heroBody() {
    if (!model.isAwarded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          model.heroMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _blue,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.3,
          ),
        ),
      );
    }

    return Column(
      children: [
        Transform.scale(
          scale: 1 + 0.06 * stage.earnedPop,
          child: Text(
            '+${_formatThousands(stage.earnedXpShown)} XP',
            style: TextStyle(
              color: _orange,
              fontSize: tokens.xpGainSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -2.4,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          model.heroMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _blue60,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _heroTitle() {
    switch (model.xpAwardState) {
      case XpAwardState.awarded:
        return model.didLevelUp
            ? 'Level ${model.levelLabel}, ${model.runnerName}!'
            : 'Nice work, ${model.runnerName}!';
      case XpAwardState.notAwarded:
        return 'Good effort, ${model.runnerName}!';
      case XpAwardState.deferred:
        return 'Run saved, ${model.runnerName}!';
    }
  }

  String _badgeLabel() {
    if (model.didLevelUp && !stage.showNewLevelBadge) {
      return 'Lv.${model.previousLevel}';
    }
    return 'Lv.${model.levelLabel}';
  }

  double get compactBottom => tokens.heroY == 16 ? 16 : 20;
}

class _LevelUpChip extends StatelessWidget {
  const _LevelUpChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FB6414),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Level up!',
        style: TextStyle(
          color: _pureWhite,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          height: 1,
        ),
      ),
    );
  }
}

class _TotalXpCard extends StatelessWidget {
  const _TotalXpCard({required this.model, required this.stage});

  final XpUpdateDisplayModel model;
  final _XpStage stage;

  @override
  Widget build(BuildContext context) {
    final priorPct = stage.priorFraction;
    final shownPct = stage.progressFraction;
    final valueLabel = model.totalXp > 0
        ? '${_formatThousands(stage.totalXpShown)} XP'
        : model.totalXpLabel;

    return _XpCardSurface(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconChip(
                color: _blue06,
                icon: Icons.auto_awesome_rounded,
                iconColor: _blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total XP',
                      style: TextStyle(
                        color: _blue60,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valueLabel,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _RewardProgressBar(priorPct: priorPct, shownPct: shownPct),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  model.progressTargetLabel,
                  style: const TextStyle(
                    color: _blue60,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    model.didLevelUp && stage.showNewLevelBadge
                        ? 'Just leveled up'
                        : model.xpRemainingLabel,
                    style: const TextStyle(
                      color: _blue,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.model, required this.stage});

  final XpUpdateDisplayModel model;
  final _XpStage stage;

  @override
  Widget build(BuildContext context) {
    final increased = model.streakCount > model.previousStreakCount;
    final flameScale = increased ? 1 + 0.15 * stage.streakPulse : 1.0;

    return _XpCardSurface(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Row(
        children: [
          Transform.scale(
            scale: flameScale,
            child: const _IconChip(
              color: _orange12,
              icon: Icons.local_fire_department_rounded,
              iconColor: _orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Day streak',
                  style: TextStyle(
                    color: _blue60,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _streakText(),
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.08,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: _blue06,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              model.streakNote,
              style: const TextStyle(
                color: _blue60,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _streakText() {
    if (model.streakCount <= 0) {
      return model.streakChangeLabel;
    }
    final unit = model.streakCount == 1 ? 'day' : 'days';
    if (model.streakCount > model.previousStreakCount) {
      return '${model.previousStreakCount} → ${stage.streakShown} $unit';
    }
    return '${model.streakCount} $unit';
  }
}

class _GoHomeButton extends StatelessWidget {
  const _GoHomeButton({required this.height, required this.onPressed});

  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.home_rounded, size: 18),
      label: const Text('Home'),
      style: FilledButton.styleFrom(
        backgroundColor: _blue,
        foregroundColor: _pureWhite,
        minimumSize: Size.fromHeight(height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        elevation: 8,
        shadowColor: const Color(0x382F51C8),
      ),
    );
  }
}

class _LevelRing extends StatelessWidget {
  const _LevelRing({
    required this.model,
    required this.progress,
    required this.ringSize,
    required this.avatarSize,
    required this.showBadge,
    required this.badgeLabel,
    required this.badgeScale,
  });

  final XpUpdateDisplayModel model;
  final double progress;
  final double ringSize;
  final double avatarSize;
  final bool showBadge;
  final String badgeLabel;
  final double badgeScale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(ringSize),
            painter: _LevelRingPainter(progress: progress),
          ),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: _blue06,
              shape: BoxShape.circle,
              border: Border.all(color: _blue10),
            ),
            child: Center(
              child: Text(
                model.runnerName.characters.first,
                style: TextStyle(
                  color: _blue,
                  fontSize: ringSize < 100 ? 26 : 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              bottom: -4,
              child: Transform.scale(
                scale: badgeScale,
                child: Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: _pureWhite, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: _pureWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        height: 1,
                      ),
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

class _LevelRingPainter extends CustomPainter {
  const _LevelRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final strokeWidth = size.width < 100 ? 6.5 : 7.0;
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = _blue12
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = _orange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LevelRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _RewardProgressBar extends StatelessWidget {
  const _RewardProgressBar({required this.priorPct, required this.shownPct});

  final double priorPct;
  final double shownPct;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _blue10),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: shownPct.clamp(0, 1),
              child: const ColoredBox(color: _orange),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: priorPct.clamp(0, 1),
              child: const ColoredBox(color: _priorSolid),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class _XpCardSurface extends StatelessWidget {
  const _XpCardSurface({
    required this.child,
    required this.padding,
    required this.radius,
    this.shadow,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: RuniacColors.cardBorder),
        boxShadow: [
          ?shadow,
          const BoxShadow(
            color: Color(0x0A2F51C8),
            blurRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _XpLayoutTokens {
  const _XpLayoutTokens({
    required this.ring,
    required this.avatar,
    required this.heroY,
    required this.titleGap,
    required this.xpTopGap,
    required this.xpGainSize,
  });

  factory _XpLayoutTokens.fromCompact(bool compact) {
    if (compact) {
      return const _XpLayoutTokens(
        ring: 88,
        avatar: 66,
        heroY: 16,
        titleGap: 13,
        xpTopGap: 18,
        xpGainSize: 46,
      );
    }

    return const _XpLayoutTokens(
      ring: 104,
      avatar: 78,
      heroY: 22,
      titleGap: 16,
      xpTopGap: 22,
      xpGainSize: 56,
    );
  }

  final double ring;
  final double avatar;
  final double heroY;
  final double titleGap;
  final double xpTopGap;
  final double xpGainSize;
}

/// A single confetti fleck. The burst is deterministic (seeded) so the
/// animation is stable across rebuilds and reproducible in tests.
class _ConfettiParticle {
  const _ConfettiParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.isRect,
    required this.spin,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
  final bool isRect;
  final double spin;

  static List<_ConfettiParticle> deterministicBurst() {
    final random = math.Random(0x8151);
    const colors = [_blue, _orange, _lightBlue];
    const count = 26;
    return List<_ConfettiParticle>.generate(count, (index) {
      final angle = (index / count) * math.pi * 2 + random.nextDouble() * 0.5;
      return _ConfettiParticle(
        angle: angle,
        distance: 46 + random.nextDouble() * 62,
        size: 4 + random.nextDouble() * 5,
        color: colors[index % colors.length],
        isRect: random.nextBool(),
        spin: random.nextDouble() * math.pi,
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final travel = Curves.easeOut.transform(progress.clamp(0, 1));
    final opacity = (1 - progress).clamp(0.0, 1.0);
    if (opacity <= 0) {
      return;
    }

    for (final particle in particles) {
      final radius = particle.distance * travel;
      final dx = math.cos(particle.angle) * radius;
      final dy = math.sin(particle.angle) * radius + travel * travel * 14;
      final offset = center + Offset(dx, dy);
      final paint = Paint()..color = particle.color.withValues(alpha: opacity);

      if (particle.isRect) {
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
        canvas.rotate(particle.spin + travel * 3);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 1.6,
              height: particle.size,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(offset, particle.size / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

double _lerp(double from, double to, double value) {
  return from + (to - from) * value.clamp(0, 1);
}

String _formatThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index += 1) {
    if (index != 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return '${value < 0 ? '-' : ''}$buffer';
}
