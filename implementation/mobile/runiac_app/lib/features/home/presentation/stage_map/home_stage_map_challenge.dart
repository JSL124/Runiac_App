part of 'home_stage_map.dart';

class _HomeActiveChallengeControl extends StatefulWidget {
  const _HomeActiveChallengeControl({
    required this.display,
    required this.onOpen,
    required this.clock,
    required this.ticker,
  });

  final HomeActiveChallengeDisplay display;
  final VoidCallback? onOpen;
  final DateTime Function()? clock;
  final ChallengeTicker? ticker;

  @override
  State<_HomeActiveChallengeControl> createState() =>
      _HomeActiveChallengeControlState();
}

class _HomeActiveChallengeControlState
    extends State<_HomeActiveChallengeControl> {
  late ChallengeCountdownController _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = ChallengeCountdownController(
      clock: widget.clock ?? DateTime.now,
      ticker: widget.ticker,
      scheduledEndsAt: widget.display.scheduledEndsAt,
      isSettling: widget.display.isSettling,
    );
  }

  @override
  void didUpdateWidget(covariant _HomeActiveChallengeControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.display != widget.display) {
      _countdown.update(
        scheduledEndsAt: widget.display.scheduledEndsAt,
        isSettling: widget.display.isSettling,
      );
    }
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  /// Minute-granularity remaining phrase so the screen-reader summary never
  /// re-announces on the per-second tick.
  String _remainingPhrase(Duration remaining) {
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    String unit(int value, String noun) =>
        '$value $noun${value == 1 ? '' : 's'}';
    if (days > 0) {
      return '${unit(days, 'day')} ${unit(hours, 'hour')} left';
    }
    if (hours > 0) {
      return '${unit(hours, 'hour')} ${unit(minutes, 'minute')} left';
    }
    return '${unit(minutes, 'minute')} left';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countdown,
      builder: (context, _) {
        final value = _countdown.value;
        final tierTitle = challengeTierTitle(widget.display.tierId);
        final semanticRemaining = value.isSettling
            ? 'calculating results'
            : _remainingPhrase(value.remaining);
        final semanticLabel =
            'Active $tierTitle challenge, $semanticRemaining. '
            'Opens challenge progress.';
        return Semantics(
          key: const ValueKey<String>('homeActiveChallengeControl'),
          container: true,
          button: true,
          label: semanticLabel,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onOpen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    padding: const EdgeInsets.all(11),
                    decoration: _homeStageControlDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ChallengeBadgeImage(
                      tierId: widget.display.tierId,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isSettling ? ChallengeCopy.calculating : value.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Always-visible pill below the profile badge that toggles the Social menu.
/// Navigation trigger only — reads and writes no social data.
