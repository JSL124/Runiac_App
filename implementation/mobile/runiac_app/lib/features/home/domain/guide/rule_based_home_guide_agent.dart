import 'home_guide_agent.dart';

/// Offline, deterministic [HomeGuideAgent] used by default and as the
/// fallback whenever the remote guide is unavailable.
///
/// Composes 2-3 friendly, beginner-coach sentences purely from the fields on
/// [HomeGuideRequest]. It performs no network I/O, is fully deterministic for
/// a given request, and never derives or references any backend-owned value
/// (XP, level, rank, streak, or leaderboard data).
class RuleBasedHomeGuideAgent implements HomeGuideAgent {
  const RuleBasedHomeGuideAgent();

  @override
  Future<HomeGuideMessage> explainTodayPlan(HomeGuideRequest request) async {
    return HomeGuideMessage(text: _composeMessage(request));
  }

  String _composeMessage(HomeGuideRequest request) {
    final sentences = <String>[
      _openingSentence(request),
      ..._descriptionSentence(request),
      _closingSentence(request),
    ];
    return sentences.take(3).join(' ');
  }

  String _openingSentence(HomeGuideRequest request) {
    final day = request.dayLabel.trim();
    final title = request.workoutTitle.trim().isEmpty
        ? 'run'
        : request.workoutTitle.trim();
    final durationPart = request.durationMinutes > 0
        ? ' for about ${request.durationMinutes} minutes'
        : '';
    final effort = request.intensityLabel.trim().isEmpty
        ? ''
        : ' at a ${request.intensityLabel.trim().toLowerCase()} effort';
    final dayPart = day.isEmpty ? 'Today' : "Today's $day session";
    return '$dayPart is $title$durationPart$effort.';
  }

  List<String> _descriptionSentence(HomeGuideRequest request) {
    final description = request.description.trim();
    if (description.isEmpty) {
      return const <String>[];
    }
    return <String>[_asSentence(description)];
  }

  String _closingSentence(HomeGuideRequest request) {
    final note = request.supportiveNote.trim();
    if (note.isNotEmpty) {
      return _asSentence(note);
    }
    return "You've got this — take it one easy step at a time.";
  }

  String _asSentence(String text) {
    return text.endsWith('.') || text.endsWith('!') || text.endsWith('?')
        ? text
        : '$text.';
  }
}
