import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:runiac_app/core/theme/runiac_colors.dart';

import '../domain/models/xp_update_display_model.dart';
import 'data/run_completion_demo_snapshots.dart';

part 'xp_update_stage.dart';
part 'xp_update_header.dart';
part 'xp_update_hero.dart';
part 'xp_update_cards.dart';
part 'xp_update_level_ring.dart';
part 'xp_update_shared_widgets.dart';
part 'xp_update_layout.dart';
part 'xp_update_confetti.dart';

const _blue = Color(0xFF2F51C8);
const _orange = Color(0xFFFB6414);
const _pureWhite = Color(0xFFFFFFFF);
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
            final compact = constraints.maxHeight < 820;
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
