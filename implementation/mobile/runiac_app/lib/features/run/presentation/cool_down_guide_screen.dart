import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:runiac_app/core/theme/runiac_colors.dart';

import '../domain/models/complete_run_result.dart';
import '../domain/models/local_run_completion_payload.dart';
import 'view_summary_screen.dart';

part 'cool_down_models.dart';
part 'cool_down_phase_controls.dart';
part 'cool_down_timer.dart';
part 'cool_down_content.dart';
part 'cool_down_cards.dart';
part 'cool_down_actions.dart';

const _navy = Color(0xFF2F51C8);
const _orange = Color(0xFFFB6414);
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
    this.completionResult,
    this.completionPayload,
  });

  final bool timerEnabled;
  final CoolDownPhase initialPhase;
  final int? initialSecondsLeft;
  final Set<CoolDownPhase> initialCompletedPhases;
  final CompleteRunResult? completionResult;
  final LocalRunCompletionPayload? completionPayload;

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
      setState(() {
        _completedPhases.add(CoolDownPhase.walk);
        _phase = CoolDownPhase.stretch;
        _secondsLeft = _stretchDuration;
        _status = _CoolDownStatus.running;
      });
      _scheduleTick();
      return;
    }

    if (_status == _CoolDownStatus.complete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ViewSummaryScreen(
            completionResult: widget.completionResult,
            completionPayload: widget.completionPayload,
          ),
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
        completeCta: 'Next',
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
      backgroundColor: RuniacColors.background,
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
