import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'view_summary_screen.dart';

const _navy = Color(0xFF2F51C8);
const _orange = Color(0xFFFB6414);
const _surface = Color(0xFFF8FAFF);
const _pureWhite = Color(0xFFFFFFFF);
const _navy75 = Color(0xBF2F51C8);
const _navy60 = Color(0x992F51C8);
const _navy45 = Color(0x732F51C8);
const _navy30 = Color(0x4D2F51C8);
const _navy18 = Color(0x2E2F51C8);
const _navy12 = Color(0x1F2F51C8);
const _navy10 = Color(0x1A2F51C8);
const _navy06 = Color(0x0F2F51C8);

enum CoolDownPhase { walk, stretch }

enum _CoolDownStatus { running, paused, complete }

class CoolDownGuideScreen extends StatefulWidget {
  const CoolDownGuideScreen({
    super.key,
    this.timerEnabled = true,
    this.initialPhase = CoolDownPhase.walk,
    this.initialSecondsLeft,
    this.initialCompletedPhases = const <CoolDownPhase>{},
  });

  final bool timerEnabled;
  final CoolDownPhase initialPhase;
  final int? initialSecondsLeft;
  final Set<CoolDownPhase> initialCompletedPhases;

  @override
  State<CoolDownGuideScreen> createState() => _CoolDownGuideScreenState();
}

class _CoolDownGuideScreenState extends State<CoolDownGuideScreen> {
  static const _walkDuration = 180;
  static const _stretchDuration = 300;

  late CoolDownPhase _phase;
  late int _secondsLeft;
  late _CoolDownStatus _status;
  late Set<CoolDownPhase> _completedPhases;
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
    if (oldWidget.timerEnabled != widget.timerEnabled ||
        oldWidget.initialPhase != widget.initialPhase ||
        oldWidget.initialSecondsLeft != widget.initialSecondsLeft ||
        oldWidget.initialCompletedPhases != widget.initialCompletedPhases) {
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
    _status = _secondsLeft <= 0
        ? _CoolDownStatus.complete
        : _CoolDownStatus.running;
    _completedPhases = {...widget.initialCompletedPhases};
    if (_status == _CoolDownStatus.complete) {
      _completedPhases.add(_phase);
      if (_phase == CoolDownPhase.stretch) {
        _completedPhases.add(CoolDownPhase.walk);
      }
    }
  }

  void _scheduleTick() {
    _timer?.cancel();
    if (!widget.timerEnabled || _status != _CoolDownStatus.running) {
      return;
    }

    _timer = Timer(const Duration(seconds: 1), () {
      if (!mounted || _status != _CoolDownStatus.running) {
        return;
      }

      setState(() {
        _secondsLeft -= 1;
        if (_secondsLeft <= 0) {
          _secondsLeft = 0;
          _status = _CoolDownStatus.complete;
          _completedPhases.add(_phase);
        }
      });
      _scheduleTick();
    });
  }

  void _selectPhase(CoolDownPhase phase) {
    if (phase == _phase) {
      return;
    }

    setState(() {
      _phase = phase;
      _secondsLeft = _durationFor(phase);
      _status = _CoolDownStatus.running;
    });
    _scheduleTick();
  }

  void _togglePause() {
    if (_status == _CoolDownStatus.complete) {
      return;
    }

    setState(() {
      _status = _status == _CoolDownStatus.running
          ? _CoolDownStatus.paused
          : _CoolDownStatus.running;
    });
    _scheduleTick();
  }

  void _handlePrimaryAction() {
    if (_phase == CoolDownPhase.walk) {
      if (_status == _CoolDownStatus.complete) {
        setState(() {
          _completedPhases.add(CoolDownPhase.walk);
          _phase = CoolDownPhase.stretch;
          _secondsLeft = _stretchDuration;
          _status = _CoolDownStatus.running;
        });
        _scheduleTick();
        return;
      }

      setState(() {
        _secondsLeft = 0;
        _status = _CoolDownStatus.complete;
        _completedPhases.add(CoolDownPhase.walk);
      });
      _scheduleTick();
      return;
    }

    if (_status == _CoolDownStatus.complete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => const ViewSummaryScreen(),
        ),
      );
    }
  }

  _PhaseCopy get _copy {
    if (_phase == CoolDownPhase.walk) {
      return const _PhaseCopy(
        stepTitle: 'Slow Walk',
        helper: 'Walk slowly to lower your heart rate.',
        tips: [
          'Keep your breathing relaxed.',
          'Walk at an easy pace.',
          'Let your heart rate come down gradually.',
        ],
        completeTitle: 'Walk complete',
        completeHelper: 'Nicely done. Let’s move into some gentle stretching.',
        bottomLabel: 'Next',
        completeCta: 'Start stretching',
        icon: Icons.directions_walk_rounded,
      );
    }

    return const _PhaseCopy(
      stepTitle: 'Gentle Stretch',
      helper: 'Ease through each stretch and breathe.',
      tips: [
        'Stretch slowly — never bounce.',
        'Keep your breathing steady.',
        'Stop if anything feels sharp.',
      ],
      completeTitle: 'Cool-down complete',
      completeHelper: 'That’s your recovery done. Great work today.',
      bottomLabel: 'Finish',
      completeCta: 'Finish',
      icon: Icons.self_improvement_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 690;
            final content = _status == _CoolDownStatus.complete
                ? _copy.completeContent
                : _copy.runningContent;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 16 : 18,
                    0,
                    compact ? 16 : 18,
                    compact ? 8 : 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopNav(onBack: () => Navigator.of(context).pop()),
                      SizedBox(height: compact ? 4 : 8),
                      _CoolDownPhaseSelector(
                        phase: _phase,
                        completedPhases: _completedPhases,
                        onSelected: _selectPhase,
                      ),
                      SizedBox(height: compact ? 8 : 18),
                      Center(
                        child: _CoolDownTimerRing(
                          secondsLeft: _secondsLeft,
                          totalSeconds: _durationFor(_phase),
                          status: _status,
                          compact: compact,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 18),
                      _CoolDownStepIdentity(
                        icon: content.icon,
                        title: content.title,
                        helper: content.helper,
                        compact: compact,
                      ),
                      SizedBox(height: compact ? 8 : 16),
                      if (_status == _CoolDownStatus.complete &&
                          _phase == CoolDownPhase.walk)
                        const _CoolDownUpNextCard()
                      else if (_status != _CoolDownStatus.complete)
                        _CoolDownTipsCard(tips: _copy.tips, compact: compact),
                      const Spacer(),
                      if (_status == _CoolDownStatus.complete)
                        _CoolDownPrimaryCta(
                          label: _copy.completeCta,
                          tone: _CtaTone.orange,
                          onPressed: _handlePrimaryAction,
                        )
                      else
                        Row(
                          children: [
                            _CoolDownPauseButton(
                              status: _status,
                              onPressed: _togglePause,
                            ),
                            SizedBox(width: compact ? 10 : 14),
                            Expanded(
                              child: _CoolDownPrimaryCta(
                                label: _copy.bottomLabel,
                                tone: _CtaTone.navy,
                                onPressed: _handlePrimaryAction,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhaseCopy {
  const _PhaseCopy({
    required this.stepTitle,
    required this.helper,
    required this.tips,
    required this.completeTitle,
    required this.completeHelper,
    required this.bottomLabel,
    required this.completeCta,
    required this.icon,
  });

  final String stepTitle;
  final String helper;
  final List<String> tips;
  final String completeTitle;
  final String completeHelper;
  final String bottomLabel;
  final String completeCta;
  final IconData icon;

  _StepContent get runningContent {
    return _StepContent(icon: icon, title: stepTitle, helper: helper);
  }

  _StepContent get completeContent {
    return _StepContent(
      icon: Icons.check_rounded,
      title: completeTitle,
      helper: completeHelper,
    );
  }
}

class _StepContent {
  const _StepContent({
    required this.icon,
    required this.title,
    required this.helper,
  });

  final IconData icon;
  final String title;
  final String helper;
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            style: IconButton.styleFrom(
              foregroundColor: _navy45,
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
          ),
          const Expanded(
            child: Text(
              'Cool down guide',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _CoolDownPhaseSelector extends StatelessWidget {
  const _CoolDownPhaseSelector({
    required this.phase,
    required this.completedPhases,
    required this.onSelected,
  });

  final CoolDownPhase phase;
  final Set<CoolDownPhase> completedPhases;
  final ValueChanged<CoolDownPhase> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _navy06,
        border: Border.all(color: _navy10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _PhasePill(
            label: 'Walk',
            number: '1',
            active: phase == CoolDownPhase.walk,
            done: completedPhases.contains(CoolDownPhase.walk),
            onPressed: () => onSelected(CoolDownPhase.walk),
          ),
          const SizedBox(width: 5),
          _PhasePill(
            label: 'Stretch',
            number: '2',
            active: phase == CoolDownPhase.stretch,
            done: completedPhases.contains(CoolDownPhase.stretch),
            onPressed: () => onSelected(CoolDownPhase.stretch),
          ),
        ],
      ),
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({
    required this.label,
    required this.number,
    required this.active,
    required this.done,
    required this.onPressed,
  });

  final String label;
  final String number;
  final bool active;
  final bool done;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: active ? _pureWhite : Colors.transparent,
          foregroundColor: active ? _navy : _navy45,
          minimumSize: const Size.fromHeight(42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
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
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? _navy : (done ? _navy18 : _navy12),
                shape: BoxShape.circle,
              ),
              child: done && !active
                  ? const Icon(Icons.check_rounded, color: _navy60, size: 12)
                  : Text(
                      number,
                      style: TextStyle(
                        color: active ? _pureWhite : _navy45,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _CoolDownTimerRing extends StatelessWidget {
  const _CoolDownTimerRing({
    required this.secondsLeft,
    required this.totalSeconds,
    required this.status,
    required this.compact,
  });

  final int secondsLeft;
  final int totalSeconds;
  final _CoolDownStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 150.0 : 190.0;
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    final isPaused = status == _CoolDownStatus.paused;
    final isComplete = status == _CoolDownStatus.complete;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _TimerRingPainter(
              progress: isComplete
                  ? 1
                  : (totalSeconds == 0 ? 0 : secondsLeft / totalSeconds),
              status: status,
            ),
            child: const SizedBox.expand(),
          ),
          if (isComplete)
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _navy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x332F51C8),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.check_rounded,
                      color: _pureWhite,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'DONE',
                  style: TextStyle(
                    color: _navy45,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
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
                    color: isPaused ? _navy45 : _navy,
                    fontSize: compact ? 32 : 46,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  isPaused ? 'PAUSED' : 'REMAINING',
                  style: TextStyle(
                    color: isPaused ? _orange : _navy45,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
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
  const _TimerRingPainter({required this.progress, required this.status});

  final double progress;
  final _CoolDownStatus status;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide / 190;
    final radius = 83 * scale;
    final strokeWidth = 12 * scale;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final isPaused = status == _CoolDownStatus.paused;
    final isComplete = status == _CoolDownStatus.complete;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _navy12
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (isComplete) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = _navy
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth,
      );
      return;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * clampedProgress,
      false,
      Paint()
        ..color = isPaused ? _navy30 : _navy
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );

    if (!isPaused && clampedProgress > 0.01 && clampedProgress < 0.995) {
      final angle = -math.pi / 2 + (1 - clampedProgress) * 2 * math.pi;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas
        ..drawCircle(dotCenter, 9 * scale, Paint()..color = _pureWhite)
        ..drawCircle(dotCenter, 6.5 * scale, Paint()..color = _orange);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.status != status;
  }
}

class _CoolDownStepIdentity extends StatelessWidget {
  const _CoolDownStepIdentity({
    required this.icon,
    required this.title,
    required this.helper,
    required this.compact,
  });

  final IconData icon;
  final String title;
  final String helper;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 28 : 30,
              height: compact ? 28 : 30,
              decoration: BoxDecoration(
                color: _navy06,
                border: Border.all(color: _navy10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _navy, size: compact ? 17 : 19),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _navy,
                  fontSize: compact ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            helper,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _navy60,
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w500,
              height: 1.48,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoolDownTipsCard extends StatelessWidget {
  const _CoolDownTipsCard({required this.tips, required this.compact});

  final List<String> tips;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 9 : 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 24 : 28,
                height: compact ? 24 : 28,
                decoration: BoxDecoration(
                  color: _pureWhite,
                  border: Border.all(color: _navy10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _navy,
                  size: 15,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'Tips',
                style: TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 11),
          for (final tip in tips) ...[
            _TipRow(tip: tip, compact: compact),
            if (tip != tips.last) SizedBox(height: compact ? 5 : 9),
          ],
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip, required this.compact});

  final String tip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: compact ? 18 : 22,
          height: compact ? 18 : 22,
          decoration: BoxDecoration(
            color: _navy06,
            border: Border.all(color: _navy10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: _navy60,
            size: compact ? 11 : 13,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            tip,
            style: TextStyle(
              color: _navy75,
              fontSize: compact ? 12.5 : 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoolDownUpNextCard extends StatelessWidget {
  const _CoolDownUpNextCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _pureWhite,
              border: Border.all(color: _navy10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: _navy,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UP NEXT',
                  style: TextStyle(
                    color: _navy45,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gentle Stretch',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '5 min · gentle recovery',
                  style: TextStyle(
                    color: _navy60,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
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

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _navy06,
        border: Border.all(color: _navy10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _CoolDownPauseButton extends StatelessWidget {
  const _CoolDownPauseButton({required this.status, required this.onPressed});

  final _CoolDownStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final paused = status == _CoolDownStatus.paused;

    return IconButton(
      tooltip: paused ? 'Resume' : 'Pause',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: _navy,
        foregroundColor: _pureWhite,
        fixedSize: const Size(58, 58),
        shape: const CircleBorder(),
        elevation: 8,
        shadowColor: const Color(0x332F51C8),
      ),
      icon: Icon(
        paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
        size: 28,
      ),
    );
  }
}

enum _CtaTone { navy, orange }

class _CoolDownPrimaryCta extends StatelessWidget {
  const _CoolDownPrimaryCta({
    required this.label,
    required this.tone,
    required this.onPressed,
  });

  final String label;
  final _CtaTone tone;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = tone == _CtaTone.orange ? _orange : _navy;
    final shadowColor = tone == _CtaTone.orange
        ? const Color(0x42FB6414)
        : const Color(0x332F51C8);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: _pureWhite,
        minimumSize: const Size.fromHeight(56),
        elevation: 8,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 18),
        ],
      ),
    );
  }
}
