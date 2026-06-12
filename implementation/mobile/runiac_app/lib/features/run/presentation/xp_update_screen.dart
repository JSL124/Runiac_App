import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:runiac_app/core/theme/runiac_colors.dart';

import '../domain/models/xp_update_display_model.dart';

const _blue = Color(0xFF2F51C8);
const _orange = Color(0xFFFB6414);
const _pureWhite = Color(0xFFFFFFFF);
const _priorSolid = Color(0xFFBBC7EE);
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
  late final Animation<double> _ease;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _ease = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
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
                  animation: _ease,
                  builder: (context, child) {
                    final value = _ease.value;

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
                                    _HeroRewardCard(
                                      model: widget.model,
                                      animationValue: value,
                                      tokens: tokens,
                                    ),
                                    SizedBox(height: compact ? 10 : 12),
                                    _TotalXpCard(
                                      model: widget.model,
                                      animationValue: value,
                                    ),
                                    SizedBox(height: compact ? 10 : 12),
                                    _StreakCard(model: widget.model),
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
    required this.animationValue,
    required this.tokens,
  });

  final XpUpdateDisplayModel model;
  final double animationValue;
  final _XpLayoutTokens tokens;

  @override
  Widget build(BuildContext context) {
    final ringPct = model.didLevelUp
        ? 1.0
        : _lerp(
            model.previousProgressFraction,
            model.currentProgressFraction,
            animationValue,
          );

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
            model.didLevelUp
                ? 'Level ${model.nextLevelLabel}, ${model.runnerName}!'
                : 'Nice work, ${model.runnerName}!',
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
          _LevelRing(
            model: model,
            progress: ringPct,
            ringSize: tokens.ring,
            avatarSize: tokens.avatar,
          ),
          SizedBox(height: tokens.xpTopGap),
          Text(
            model.earnedXpLabel,
            style: TextStyle(
              color: _orange,
              fontSize: tokens.xpGainSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -2.4,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            model.didLevelUp
                ? 'You reached a new level. Keep it up.'
                : 'Earned from this run',
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
      ),
    );
  }

  double get compactBottom => tokens.heroY == 16 ? 16 : 20;
}

class _TotalXpCard extends StatelessWidget {
  const _TotalXpCard({required this.model, required this.animationValue});

  final XpUpdateDisplayModel model;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final priorPct = model.didLevelUp ? 0.0 : model.previousProgressFraction;
    final newPct = model.didLevelUp ? 0.08 : model.currentProgressFraction;
    final shownPct = _lerp(priorPct, newPct, animationValue);

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
                      model.totalXpLabel,
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
                    model.didLevelUp
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
  const _StreakCard({required this.model});

  final XpUpdateDisplayModel model;

  @override
  Widget build(BuildContext context) {
    return _XpCardSurface(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Row(
        children: [
          const _IconChip(
            color: _orange12,
            icon: Icons.local_fire_department_rounded,
            iconColor: _orange,
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
                  model.streakChangeLabel,
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
      label: const Text('Go Home'),
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
  });

  final XpUpdateDisplayModel model;
  final double progress;
  final double ringSize;
  final double avatarSize;

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
          Positioned(
            bottom: -4,
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
                  'Lv.${model.didLevelUp ? model.nextLevelLabel : model.levelLabel}',
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

double _lerp(double from, double to, double value) {
  return from + (to - from) * value.clamp(0, 1);
}
