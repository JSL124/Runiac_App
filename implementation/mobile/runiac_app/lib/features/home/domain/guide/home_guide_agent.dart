import 'package:flutter/foundation.dart';

/// Immutable, display-only description of today's workout, used to ask the
/// Home guide character to explain the plan in friendly copy.
///
/// Every field here is read back from a plan the client already rendered
/// (title, duration, steps, coach copy); nothing is backend-owned progression
/// data (no XP, level, rank, streak, or leaderboard value is carried here or
/// derivable from it).
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
}

/// A short, friendly guide message explaining today's plan.
@immutable
class HomeGuideMessage {
  const HomeGuideMessage({required this.text, this.isFromRemoteAgent = false});

  /// Beginner-friendly copy to render inside the guide character's speech
  /// bubble.
  final String text;

  /// True when [text] came from the remote Cloud Function-backed agent
  /// rather than the local rule-based fallback. Display/debug metadata only.
  final bool isFromRemoteAgent;
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
  /// Produces a guide message that explains the workout described by
  /// [request].
  Future<HomeGuideMessage> explainTodayPlan(HomeGuideRequest request);
}
