import 'package:flutter/foundation.dart';

/// Immutable, display-only description of today's workout, used to ask the
/// Home guide character to explain the plan in friendly copy.
///
/// Every field here is read back from a plan the client already rendered
/// (title, duration, steps, coach copy); nothing is backend-owned progression
/// data (no XP, level, rank, streak, or leaderboard value is carried here or
/// derivable from it).
///
/// When [isRestDay] is true the request describes a scheduled rest day rather
/// than a workout: the workout fields ([workoutTitle], [durationMinutes],
/// [intensityLabel], [description], [steps], [supportiveNote]) are empty and
/// the guide composes rest-day encouragement instead of a workout summary.
@immutable
class HomeGuideRequest {
  const HomeGuideRequest({
    required this.planTitle,
    required this.weekNumber,
    required this.weekFocus,
    required this.dayLabel,
    required this.workoutTitle,
    required this.durationMinutes,
    required this.intensityLabel,
    required this.description,
    this.steps = const <String>[],
    this.supportiveNote = '',
    this.isRestDay = false,
  });

  /// Title of the active generated plan (e.g. `'First 10K Preparation'`).
  final String planTitle;

  /// 1-based plan week number today's workout belongs to.
  final int weekNumber;

  /// Short focus line for the active week (e.g. `'Build a steady habit'`).
  final String weekFocus;

  /// Weekday or positional day caption for today's stage (e.g. `'Mon'`).
  final String dayLabel;

  /// Title of today's workout (e.g. `'Easy Run'`).
  final String workoutTitle;

  /// Planned duration of today's workout, in minutes.
  final int durationMinutes;

  /// Human-readable effort label (e.g. `'Gentle'`, `'Balanced'`).
  final String intensityLabel;

  /// Short description of the workout.
  final String description;

  /// Ordered breakdown steps for the workout, when available.
  final List<String> steps;

  /// Encouraging coach note attached to the workout, when available.
  final String supportiveNote;

  /// True when today is a scheduled rest day (no run session). The guide
  /// composes rest-day encouragement instead of a workout summary; the
  /// workout fields are empty in this case.
  final bool isRestDay;
}

/// The three named messages the guide can present in its local cycle.
///
/// These values deliberately describe presentation purpose, not progression
/// state. The client receives already-rendered copy and never calculates any
/// activity, XP, rank, streak, or other protected value.
enum HomeGuideMessageKind { planSummary, runningTip, progressionCheckIn }

/// A short, friendly guide message explaining one part of today's plan.
@immutable
class HomeGuideMessage {
  const HomeGuideMessage({
    required this.kind,
    required this.text,
    this.isFromRemoteAgent = false,
  });

  /// The fixed purpose of this message in the three-message guide bundle.
  final HomeGuideMessageKind kind;

  /// Beginner-friendly copy to render inside the guide character's speech
  /// bubble.
  final String text;

  /// True when [text] came from the remote Cloud Function-backed agent
  /// rather than the local rule-based fallback. Display/debug metadata only.
  final bool isFromRemoteAgent;
}

/// Immutable, complete guide content for one Home request.
///
/// [HomeGuideBundle] extends [HomeGuideMessage] temporarily so the existing
/// stage-map seam can render [planSummary] until its dedicated cycle migration
/// consumes [messages]. The named fields remain the only source of content
/// for new callers.
@immutable
class HomeGuideBundle extends HomeGuideMessage {
  HomeGuideBundle({
    required this.planSummary,
    required this.runningTip,
    required this.progressionCheckIn,
    required super.isFromRemoteAgent,
  }) : assert(planSummary.kind == HomeGuideMessageKind.planSummary),
       assert(runningTip.kind == HomeGuideMessageKind.runningTip),
       assert(
         progressionCheckIn.kind == HomeGuideMessageKind.progressionCheckIn,
       ),
       super(kind: HomeGuideMessageKind.planSummary, text: planSummary.text);

  /// Strict constructor used at the network boundary. It rejects, rather than
  /// truncates, copy that would overflow the approved compact bubble contract.
  static HomeGuideBundle? tryCreate({
    required String planSummary,
    required String runningTip,
    required String progressionCheckIn,
    required bool isFromRemoteAgent,
  }) {
    // The progression line may carry server-computed comparison figures (e.g.
    // "+2.5 km, +50% vs last week"), so it is allowed a little more length and
    // an extra clause than the plan-summary and running-tip lines.
    if (!_isDisplaySafe(planSummary) ||
        !_isDisplaySafe(runningTip) ||
        !_isDisplaySafe(
          progressionCheckIn,
          maxRunes: _progressionMaxRunes,
          maxSentences: _progressionMaxSentences,
        )) {
      return null;
    }
    final normalizedPlanSummary = _normalizedPurpose(planSummary);
    final normalizedRunningTip = _normalizedPurpose(runningTip);
    final normalizedProgressionCheckIn = _normalizedPurpose(progressionCheckIn);
    if (normalizedPlanSummary == normalizedRunningTip ||
        normalizedPlanSummary == normalizedProgressionCheckIn ||
        normalizedRunningTip == normalizedProgressionCheckIn) {
      return null;
    }
    return HomeGuideBundle(
      planSummary: HomeGuideMessage(
        kind: HomeGuideMessageKind.planSummary,
        text: planSummary,
        isFromRemoteAgent: isFromRemoteAgent,
      ),
      runningTip: HomeGuideMessage(
        kind: HomeGuideMessageKind.runningTip,
        text: runningTip,
        isFromRemoteAgent: isFromRemoteAgent,
      ),
      progressionCheckIn: HomeGuideMessage(
        kind: HomeGuideMessageKind.progressionCheckIn,
        text: progressionCheckIn,
        isFromRemoteAgent: isFromRemoteAgent,
      ),
      isFromRemoteAgent: isFromRemoteAgent,
    );
  }

  /// Summary copy, shown first when the character guide opens.
  final HomeGuideMessage planSummary;

  /// A single actionable running cue, shown second.
  final HomeGuideMessage runningTip;

  /// A calm evidence-backed or baseline check-in, shown third.
  final HomeGuideMessage progressionCheckIn;

  /// The ordered presentation sequence. The returned list cannot be mutated.
  List<HomeGuideMessage> get messages => List<HomeGuideMessage>.unmodifiable(
    <HomeGuideMessage>[planSummary, runningTip, progressionCheckIn],
  );

  /// Default compact bubble limits for the plan-summary and running-tip lines.
  static const int _defaultMaxRunes = 160;
  static const int _defaultMaxSentences = 2;

  /// Relaxed limits for the progression line, which may include comparison
  /// figures and a short "what to improve" clause.
  static const int _progressionMaxRunes = 220;
  static const int _progressionMaxSentences = 3;

  static bool _isDisplaySafe(
    String text, {
    int maxRunes = _defaultMaxRunes,
    int maxSentences = _defaultMaxSentences,
  }) {
    if (text.isEmpty || text != text.trim() || text.contains('\n')) {
      return false;
    }
    if (text.runes.length > maxRunes) {
      return false;
    }
    return _sentenceEndingPattern.allMatches(text).length <= maxSentences;
  }

  static final RegExp _sentenceEndingPattern = RegExp(r'[.!?。！？]+');

  static final RegExp _whitespacePattern = RegExp(r'\s+');

  static String _normalizedPurpose(String text) =>
      text.toLowerCase().replaceAll(_whitespacePattern, ' ');
}

/// Seam for the Home guide "brain" that explains today's plan.
///
/// The API is [Future]-based so a remote implementation fits without
/// changing callers. [CloudFunctionHomeGuideAgent] (see
/// `cloud_function_home_guide_agent.dart`) calls a Cloud Function proxy that
/// holds the OpenAI API key server-side only; the client must never embed an
/// API key or call the OpenAI API directly. [RuleBasedHomeGuideAgent] is the
/// offline, deterministic default and the fallback whenever the remote agent
/// is unavailable, errors, or returns an unusable response.
abstract interface class HomeGuideAgent {
  /// Produces a complete named guide bundle for the workout described by
  /// [request].
  Future<HomeGuideBundle> explainTodayPlan(HomeGuideRequest request);
}
