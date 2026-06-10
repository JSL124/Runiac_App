import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

const _cdBlue = Color(0xFF2F51C8);
const _cdOrange = Color(0xFFFB6414);
const _cdWhite = Color(0xFFF8FAFF);
const _cdBlue75 = Color(0xBF2F51C8);
const _cdBlue60 = Color(0x992F51C8);
const _cdBlue45 = Color(0x732F51C8);
const _cdBlue30 = Color(0x4D2F51C8);
const _cdBlue18 = Color(0x2E2F51C8);
const _cdBlue10 = Color(0x1A2F51C8);
const _cdBlue06 = Color(0x0F2F51C8);
const _completeBg = Color(0x1A22C55E);
const _completeBorder = Color(0x3816A34A);
const _completeCheck = Color(0xE016A34A);

enum CoolDownPhase { walk, stretch }

enum _TimerStatus { running, paused, complete }

class CoolDownGuideScreen extends StatefulWidget {
  const CoolDownGuideScreen({
    super.key,
    this.timerEnabled = true,
    this.initialPhase = CoolDownPhase.walk,
    this.initialSecondsLeft,
  });

  final bool timerEnabled;
  final CoolDownPhase initialPhase;
  final int? initialSecondsLeft;

  @override
  State<CoolDownGuideScreen> createState() => _CoolDownGuideScreenState();
}

class _CoolDownGuideScreenState extends State<CoolDownGuideScreen> {
  static const _walkDuration = 180;
  static const _stretchDuration = 300;

  late CoolDownPhase _phase;
  late int _secondsLeft;
  late _TimerStatus _status;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetFromWidget();
    _scheduleTick();
  }

  @override
  void didUpdateWidget(covariant CoolDownGuideScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPhase != widget.initialPhase ||
        oldWidget.initialSecondsLeft != widget.initialSecondsLeft ||
        oldWidget.timerEnabled != widget.timerEnabled) {
      _resetFromWidget();
      _scheduleTick();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _durationFor(CoolDownPhase phase) {
    return phase == CoolDownPhase.walk ? _walkDuration : _stretchDuration;
  }

  void _resetFromWidget() {
    _phase = widget.initialPhase;
    _secondsLeft = widget.initialSecondsLeft ?? _durationFor(_phase);
    _status = _secondsLeft <= 0 ? _TimerStatus.complete : _TimerStatus.running;
  }

  void _scheduleTick() {
    _timer?.cancel();
    if (!widget.timerEnabled || _status != _TimerStatus.running) {
      return;
    }
    _timer = Timer(const Duration(seconds: 1), () {
      if (!mounted || _status != _TimerStatus.running) {
        return;
      }
      setState(() {
        _secondsLeft -= 1;
        if (_secondsLeft <= 0) {
          _secondsLeft = 0;
          _status = _TimerStatus.complete;
        }
      });
      _scheduleTick();
    });
  }

  void _selectPhase(CoolDownPhase phase) {
    setState(() {
      _phase = phase;
      _secondsLeft = _durationFor(phase);
      _status = _TimerStatus.running;
    });
    _scheduleTick();
  }

  void _togglePause() {
    setState(() {
      _status = _status == _TimerStatus.running
          ? _TimerStatus.paused
          : _TimerStatus.running;
    });
    _scheduleTick();
  }

  void _handlePrimary() {
    if (_phase == CoolDownPhase.walk) {
      _selectPhase(CoolDownPhase.stretch);
      return;
    }
    _showFinishedMessage();
  }

  void _showFinishedMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Cool-down complete. Summary will be available next.'),
        ),
      );
  }

  _PhaseContent get _content {
    return _phase == CoolDownPhase.walk
        ? const _PhaseContent(
            title: 'Slow Walk',
            guidance: 'Walk slowly to bring your heart rate down.',
            tips: [
              'Keep your breathing relaxed.',
              'Walk at an easy, comfortable pace.',
              'Let your heart rate come down gradually.',
            ],
            completeTitle: 'Walk complete',
            completeHelper: 'Nice work. Let’s move into gentle stretching.',
            primaryLabel: 'Start Stretching',
            ghostLabel: 'Next',
            icon: Icons.directions_walk_rounded,
          )
        : const _PhaseContent(
            title: 'Stretching',
            guidance: 'Move gently through each stretch.',
            tips: [
              'Stretch slowly and avoid bouncing.',
              'Keep breathing steady.',
              'Stop if anything feels painful.',
            ],
            completeTitle: 'Stretching complete',
            completeHelper: 'You’ve finished your cool-down. Well done!',
            primaryLabel: 'Finish',
            ghostLabel: 'Finish',
            icon: Icons.self_improvement,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cdBlue,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 670;

            return Column(
              children: [
                _HeroSection(
                  phase: _phase,
                  status: _status,
                  secondsLeft: _secondsLeft,
                  totalSeconds: _durationFor(_phase),
                  compact: compact,
                  onBack: () => Navigator.of(context).pop(),
                  onPhaseSelected: _selectPhase,
                ),
                Expanded(
                  child: _GuidanceSheet(
                    phase: _phase,
                    status: _status,
                    content: _content,
                    compact: compact,
                    onPauseResume: _togglePause,
                    onPrimary: _handlePrimary,
                    onGhost: _phase == CoolDownPhase.walk
                        ? () => _selectPhase(CoolDownPhase.stretch)
                        : _showFinishedMessage,
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

class _PhaseContent {
  const _PhaseContent({
    required this.title,
    required this.guidance,
    required this.tips,
    required this.completeTitle,
    required this.completeHelper,
    required this.primaryLabel,
    required this.ghostLabel,
    required this.icon,
  });

  final String title;
  final String guidance;
  final List<String> tips;
  final String completeTitle;
  final String completeHelper;
  final String primaryLabel;
  final String ghostLabel;
  final IconData icon;
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.phase,
    required this.status,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.compact,
    required this.onBack,
    required this.onPhaseSelected,
  });

  final CoolDownPhase phase;
  final _TimerStatus status;
  final int secondsLeft;
  final int totalSeconds;
  final bool compact;
  final VoidCallback onBack;
  final ValueChanged<CoolDownPhase> onPhaseSelected;

  @override
  Widget build(BuildContext context) {
    final heroBottomPadding = compact ? 10.0 : 30.0;
    final tabBottomGap = compact ? 8.0 : 24.0;

    return ColoredBox(
      color: _cdBlue,
      child: Padding(
        padding: EdgeInsets.only(bottom: heroBottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: compact ? 42 : 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onBack,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0x1AFFFFFF),
                        foregroundColor: _cdWhite,
                        minimumSize: const Size(36, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.chevron_left_rounded, size: 26),
                    ),
                    const Expanded(
                      child: Text(
                        'Cool down guide',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _cdWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, tabBottomGap),
              child: _PhaseTabs(phase: phase, onPhaseSelected: onPhaseSelected),
            ),
            _TimerRing(
              secondsLeft: secondsLeft,
              totalSeconds: totalSeconds,
              status: status,
              compact: compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseTabs extends StatelessWidget {
  const _PhaseTabs({required this.phase, required this.onPhaseSelected});

  final CoolDownPhase phase;
  final ValueChanged<CoolDownPhase> onPhaseSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _PhaseTab(
            label: 'Walk',
            number: '1',
            active: phase == CoolDownPhase.walk,
            onTap: () => onPhaseSelected(CoolDownPhase.walk),
          ),
          _PhaseTab(
            label: 'Stretch',
            number: '2',
            active: phase == CoolDownPhase.stretch,
            onTap: () => onPhaseSelected(CoolDownPhase.stretch),
          ),
        ],
      ),
    );
  }
}

class _PhaseTab extends StatelessWidget {
  const _PhaseTab({
    required this.label,
    required this.number,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String number;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: active ? _cdWhite : Colors.transparent,
          foregroundColor: active ? _cdBlue : const Color(0x80FFFFFF),
          minimumSize: const Size.fromHeight(38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 17,
              height: 17,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? _cdBlue : const Color(0x29FFFFFF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                number,
                style: TextStyle(
                  color: active ? _cdWhite : const Color(0x73FFFFFF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.secondsLeft,
    required this.totalSeconds,
    required this.status,
    required this.compact,
  });

  final int secondsLeft;
  final int totalSeconds;
  final _TimerStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 112.0 : 168.0;
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    final isComplete = status == _TimerStatus.complete;
    final isPaused = status == _TimerStatus.paused;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _TimerRingPainter(
              progress: totalSeconds == 0 ? 0 : secondsLeft / totalSeconds,
              paused: isPaused,
              complete: isComplete,
            ),
            child: SizedBox.expand(),
          ),
          if (isComplete)
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, color: Color(0xE0FFFFFF), size: 36),
                SizedBox(height: 6),
                Text(
                  'DONE',
                  style: TextStyle(
                    color: Color(0x73FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$minutes:$seconds',
                  style: TextStyle(
                    color: isPaused ? const Color(0x80FFFFFF) : _cdWhite,
                    fontSize: compact ? 28 : 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPaused ? 'PAUSED' : 'REMAINING',
                  style: const TextStyle(
                    color: Color(0x73FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({
    required this.progress,
    required this.paused,
    required this.complete,
  });

  final double progress;
  final bool paused;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 168;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 70 * scale;
    final stroke = 9 * scale;

    canvas.drawCircle(
      center,
      82 * scale,
      Paint()
        ..color = const Color(0x0AFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20 * scale,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0x1FFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (complete) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0x47FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      return;
    }

    final clampedProgress = progress.clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = paused ? const Color(0x80FFFFFF) : _cdWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * clampedProgress,
      false,
      ringPaint,
    );

    if (clampedProgress > 0.02) {
      final angle = -math.pi / 2 + (1 - clampedProgress) * 2 * math.pi;
      final dot = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(
        dot,
        5 * scale,
        Paint()..color = paused ? const Color(0x80FFFFFF) : _cdWhite,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.paused != paused ||
        oldDelegate.complete != complete;
  }
}

class _GuidanceSheet extends StatelessWidget {
  const _GuidanceSheet({
    required this.phase,
    required this.status,
    required this.content,
    required this.compact,
    required this.onPauseResume,
    required this.onPrimary,
    required this.onGhost,
  });

  final CoolDownPhase phase;
  final _TimerStatus status;
  final _PhaseContent content;
  final bool compact;
  final VoidCallback onPauseResume;
  final VoidCallback onPrimary;
  final VoidCallback onGhost;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        decoration: const BoxDecoration(
          color: _cdWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Color(0x142F51C8),
              blurRadius: 28,
              offset: Offset(0, -8),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          compact ? 12 : 22,
          20,
          compact ? 12 : 24,
        ),
        child: status == _TimerStatus.complete
            ? _CompleteSheet(
                phase: phase,
                content: content,
                onPrimary: onPrimary,
              )
            : _RunningSheet(
                content: content,
                status: status,
                compact: compact,
                onPauseResume: onPauseResume,
                onGhost: onGhost,
              ),
      ),
    );
  }
}

class _RunningSheet extends StatelessWidget {
  const _RunningSheet({
    required this.content,
    required this.status,
    required this.compact,
    required this.onPauseResume,
    required this.onGhost,
  });

  final _PhaseContent content;
  final _TimerStatus status;
  final bool compact;
  final VoidCallback onPauseResume;
  final VoidCallback onGhost;

  @override
  Widget build(BuildContext context) {
    final isPaused = status == _TimerStatus.paused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(content: content),
        SizedBox(height: compact ? 3 : 5),
        Padding(
          padding: const EdgeInsets.only(left: 50),
          child: Text(
            content.guidance,
            style: TextStyle(
              color: _cdBlue60,
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w500,
              height: compact ? 1.35 : 1.55,
            ),
          ),
        ),
        SizedBox(height: compact ? 7 : 14),
        _TipsCard(tips: content.tips, compact: compact),
        const Spacer(),
        Center(
          child: IconButton(
            tooltip: isPaused
                ? 'Resume cool-down timer'
                : 'Pause cool-down timer',
            onPressed: onPauseResume,
            style: IconButton.styleFrom(
              backgroundColor: _cdBlue06,
              foregroundColor: _cdBlue,
              side: const BorderSide(color: _cdBlue18, width: 1.5),
              fixedSize: Size(compact ? 48 : 58, compact ? 48 : 58),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: isPaused ? 28 : 24,
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        OutlinedButton.icon(
          onPressed: onGhost,
          icon: const SizedBox.shrink(),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content.ghostLabel),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 14),
            ],
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _cdBlue60,
            side: const BorderSide(color: _cdBlue18, width: 1.5),
            minimumSize: Size.fromHeight(compact ? 40 : 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompleteSheet extends StatelessWidget {
  const _CompleteSheet({
    required this.phase,
    required this.content,
    required this.onPrimary,
  });

  final CoolDownPhase phase;
  final _PhaseContent content;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _completeBg,
                border: Border.all(color: _completeBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: _completeCheck,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content.completeTitle,
                style: const TextStyle(
                  color: _cdBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 50),
          child: Text(
            content.completeHelper,
            style: const TextStyle(
              color: _cdBlue60,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (phase == CoolDownPhase.walk) const _UpNextCard(),
        const Spacer(),
        FilledButton(
          onPressed: onPrimary,
          style: FilledButton.styleFrom(
            backgroundColor: _cdOrange,
            foregroundColor: _cdWhite,
            minimumSize: const Size.fromHeight(54),
            elevation: 8,
            shadowColor: const Color(0x42FB6414),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content.primaryLabel),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.content});

  final _PhaseContent content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconChip(icon: content.icon),
        const SizedBox(width: 12),
        Text(
          content.title,
          style: const TextStyle(
            color: _cdBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tips, required this.compact});

  final List<String> tips;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _cdBlue06,
        border: Border.all(color: _cdBlue10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: compact ? 11 : 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _cdWhite,
                    border: Border.all(color: _cdBlue10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: _cdBlue,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tips',
                  style: TextStyle(
                    color: _cdBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            for (final tip in tips) ...[
              _TipRow(tip),
              if (tip != tips.last) SizedBox(height: compact ? 6 : 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            color: _cdBlue30,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _cdBlue75,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _UpNextCard extends StatelessWidget {
  const _UpNextCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _cdBlue06,
        border: Border.all(color: _cdBlue10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UP NEXT',
              style: TextStyle(
                color: _cdBlue45,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _IconChip(icon: Icons.self_improvement, onWhite: true),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stretching',
                      style: TextStyle(
                        color: _cdBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '5 min · gentle recovery',
                      style: TextStyle(
                        color: _cdBlue60,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, this.onWhite = false});

  final IconData icon;
  final bool onWhite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: onWhite ? _cdWhite : _cdBlue06,
        border: Border.all(color: _cdBlue10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: _cdBlue, size: 18),
    );
  }
}
