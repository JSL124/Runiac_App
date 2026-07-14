part of 'home_stage_map.dart';

class _GuideSpeechBubble extends StatelessWidget {
  const _GuideSpeechBubble({
    required this.state,
    required this.isRestDay,
    required this.onAdvance,
    required this.onDismiss,
    this.onManageDataUse,
    super.key,
  });

  final HomeGuideCycleState state;
  final bool isRestDay;
  final VoidCallback onAdvance;
  final VoidCallback onDismiss;
  final VoidCallback? onManageDataUse;

  static const String _fallbackErrorText =
      "Let's get moving — you've got this today.";

  @override
  Widget build(BuildContext context) {
    final message = state.currentMessage;
    return _GuideBubbleCard(
      key: ValueKey<String>('${state.isLoading}:${message?.text}'),
      message: message,
      isLoading: state.isLoading,
      isUnavailable: !state.isLoading && message == null,
      isRestDay: isRestDay,
      fallbackText: _fallbackErrorText,
      onAdvance: onAdvance,
      onDismiss: onDismiss,
      onManageDataUse: onManageDataUse,
    );
  }
}

class _GuideBubbleCard extends StatelessWidget {
  const _GuideBubbleCard({
    required this.message,
    required this.isLoading,
    required this.isUnavailable,
    required this.isRestDay,
    required this.fallbackText,
    required this.onAdvance,
    required this.onDismiss,
    this.onManageDataUse,
    super.key,
  });

  final HomeGuideMessage? message;
  final bool isLoading;
  final bool isUnavailable;
  final bool isRestDay;
  final String fallbackText;
  final VoidCallback onAdvance;
  final VoidCallback onDismiss;
  final VoidCallback? onManageDataUse;

  String get _bodyText {
    if (isLoading) {
      return 'Preparing your guide...';
    }
    return message?.text ?? fallbackText;
  }

  String get _bodySemanticsLabel {
    if (isLoading) {
      return 'Guide message loading. Please wait.';
    }
    if (isUnavailable) {
      return 'Guide message unavailable.';
    }
    if (isRestDay) {
      return switch (message!.kind) {
        HomeGuideMessageKind.planSummary =>
          'Rest-day cheer. Tap to hear a rest tip.',
        HomeGuideMessageKind.runningTip =>
          'Rest-day tip. Tap to hear why rest matters.',
        HomeGuideMessageKind.progressionCheckIn =>
          'Why rest matters. Tap to return to your rest-day cheer.',
      };
    }
    return switch (message!.kind) {
      HomeGuideMessageKind.planSummary =>
        'Plan summary. Tap to hear a running tip.',
      HomeGuideMessageKind.runningTip =>
        'Running tip. Tap to hear a progression check-in.',
      HomeGuideMessageKind.progressionCheckIn =>
        'Progression check-in. Tap to return to your plan summary.',
    };
  }

  bool get _canAdvance => !isLoading && !isUnavailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('homeGuideBubble'),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.cardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: RuniacColors.softCardShadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Semantics(
              button: _canAdvance,
              label: _bodySemanticsLabel,
              child: ExcludeSemantics(
                child: GestureDetector(
                  key: const ValueKey<String>('homeGuideBubbleBody'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _canAdvance ? onAdvance : null,
                  child: Text(
                    _bodyText,
                    style: TextStyle(
                      fontSize: isLoading ? 14 : 13,
                      height: 1.35,
                      fontWeight: isLoading ? FontWeight.w700 : FontWeight.w600,
                      color: isLoading
                          ? RuniacColors.textSecondary
                          : RuniacColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (onManageDataUse != null)
            SizedBox(
              width: 44,
              height: 44,
              child: Semantics(
                button: true,
                label: 'Manage guide data use',
                child: IconButton(
                  tooltip: 'Manage guide data use',
                  onPressed: onManageDataUse,
                  icon: const Icon(
                    Icons.shield_outlined,
                    size: 19,
                    color: RuniacColors.textSecondary,
                  ),
                ),
              ),
            ),
          SizedBox(
            width: 44,
            height: 44,
            child: Semantics(
              button: true,
              label: 'Close guide message',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
                child: const Tooltip(
                  message: 'Close guide message',
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: RuniacColors.textSecondary,
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

class _GuideConsentCard extends StatelessWidget {
  const _GuideConsentCard({required this.onReview});

  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    const message = Text(
      'Personalize your guide with recent run totals.',
      style: TextStyle(
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: RuniacColors.textPrimary,
      ),
    );
    final reviewButton = TextButton(
      onPressed: onReview,
      child: Semantics(
        button: true,
        label: 'Review guide data use',
        child: const ExcludeSemantics(child: Text('Review')),
      ),
    );
    return Container(
      key: const ValueKey<String>('homeGuideConsentCard'),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RuniacColors.cardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: RuniacColors.softCardShadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largeText = MediaQuery.textScalerOf(context).scale(13) > 18;
          if (constraints.maxWidth < 280 || largeText) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                message,
                Align(alignment: Alignment.centerRight, child: reviewButton),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: message),
              reviewButton,
            ],
          );
        },
      ),
    );
  }
}
