import 'home_guide_agent.dart';

/// Offline, deterministic [HomeGuideAgent] used by default and as the
/// fallback whenever the remote guide is unavailable.
///
/// Composes a complete compact bundle purely from [HomeGuideRequest]. It
/// performs no network I/O, is deterministic for a given request, and never
/// derives or references a backend-owned value (XP, level, rank, streak, or
/// leaderboard data).
class RuleBasedHomeGuideAgent implements HomeGuideAgent {
  const RuleBasedHomeGuideAgent();

  @override
  Future<HomeGuideBundle> explainTodayPlan(HomeGuideRequest request) async {
    final bundle = HomeGuideBundle.tryCreate(
      planSummary: _planSummary(request),
      runningTip: _runningTip(request),
      progressionCheckIn:
          "You've got this! A steady baseline is a strong start.",
      isFromRemoteAgent: false,
    );
    return bundle ?? _safeLocalBundle();
  }

  /// Keeps the offline path total if untrusted display copy happens to repeat
  /// a named purpose. These constants are pre-validated: distinct, one
  /// sentence each, and shorter than the compact bubble limit.
  HomeGuideBundle _safeLocalBundle() {
    return HomeGuideBundle(
      planSummary: const HomeGuideMessage(
        kind: HomeGuideMessageKind.planSummary,
        text: 'Your gentle running session is ready, superstar!',
      ),
      runningTip: const HomeGuideMessage(
        kind: HomeGuideMessageKind.runningTip,
        text:
            'Tiny trainer tip: Keep the effort conversational and comfortable.',
      ),
      progressionCheckIn: const HomeGuideMessage(
        kind: HomeGuideMessageKind.progressionCheckIn,
        text: "You've got this! A steady baseline is a strong start.",
      ),
      isFromRemoteAgent: false,
    );
  }

  String _planSummary(HomeGuideRequest request) {
    final day = _label(request.dayLabel, 24);
    final title = _label(request.workoutTitle, 54, fallback: 'run');
    final durationPart = request.durationMinutes > 0
        ? ' for about ${request.durationMinutes} minutes'
        : '';
    final dayPart = day.isEmpty ? 'Today' : "Today's $day session";
    return "$dayPart is $title$durationPart. You've got this!";
  }

  String _runningTip(HomeGuideRequest request) {
    final note = _bounded(request.supportiveNote, 120);
    if (note.isNotEmpty && _sentenceCount(note) <= 2) {
      return 'Tiny trainer tip: ${_asSentence(note)}';
    }
    return 'Tiny trainer tip: Keep the effort conversational and comfortable.';
  }

  String _asSentence(String text) {
    return text.endsWith('.') ||
            text.endsWith('!') ||
            text.endsWith('?') ||
            text.endsWith('。') ||
            text.endsWith('！') ||
            text.endsWith('？')
        ? text
        : '$text.';
  }

  String _bounded(String value, int maxRunes, {String fallback = ''}) {
    final trimmed = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    final runes = trimmed.runes;
    return runes.length <= maxRunes
        ? trimmed
        : String.fromCharCodes(runes.take(maxRunes));
  }

  String _label(String value, int maxRunes, {String fallback = ''}) {
    return _bounded(
      value.replaceAll(RegExp(r'[.!?。！？]'), ' '),
      maxRunes,
      fallback: fallback,
    );
  }

  int _sentenceCount(String text) =>
      RegExp(r'[.!?。！？]+').allMatches(text).length;
}
