import 'package:cloud_functions/cloud_functions.dart';

import '../domain/guide/home_guide_agent.dart';
import '../domain/guide/rule_based_home_guide_agent.dart';

/// Remote [HomeGuideAgent] backed by the `homeGuideAgent` Cloud Function.
///
/// The callable is expected to run an OpenAI/LangGraph-backed agent whose API
/// key is held server-side only; this client adapter never embeds an API key
/// and never calls OpenAI directly. Every request field is display-only plan
/// copy (see [HomeGuideRequest]) — no backend-owned XP/level/streak/rank/
/// leaderboard value is sent or requested.
///
/// This adapter never throws to its caller: any network failure, callable
/// error, or unusable response is composed into a message by delegating to
/// [fallbackAgent] (the offline, deterministic [RuleBasedHomeGuideAgent] by
/// default), mirroring the fallback behavior expected of the guide seam.
class CloudFunctionHomeGuideAgent implements HomeGuideAgent {
  CloudFunctionHomeGuideAgent({
    FirebaseFunctions? functions,
    this.fallbackAgent = const RuleBasedHomeGuideAgent(),
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  final FirebaseFunctions _functions;

  /// Local agent used whenever the remote callable is unavailable, errors,
  /// or returns a response this adapter cannot use.
  final HomeGuideAgent fallbackAgent;

  @override
  Future<HomeGuideMessage> explainTodayPlan(HomeGuideRequest request) async {
    try {
      final result = await _functions
          .httpsCallable('homeGuideAgent')
          .call(_requestPayload(request));
      final message = _messageFromResponse(result.data);
      if (message != null) {
        return message;
      }
    } catch (_) {
      // Network error, callable error, or malformed response: compose a
      // local fallback message instead of surfacing a crash to the UI.
    }
    return fallbackAgent.explainTodayPlan(request);
  }

  Map<String, Object?> _requestPayload(HomeGuideRequest request) {
    return <String, Object?>{
      'planTitle': request.planTitle,
      'weekNumber': request.weekNumber,
      'weekFocus': request.weekFocus,
      'dayLabel': request.dayLabel,
      'workoutTitle': request.workoutTitle,
      'durationMinutes': request.durationMinutes,
      'intensity': request.intensityLabel,
      'description': request.description,
      'steps': request.steps,
      'supportiveNote': request.supportiveNote,
    };
  }

  HomeGuideMessage? _messageFromResponse(Object? data) {
    final Map<Object?, Object?>? map;
    if (data is Map<Object?, Object?>) {
      map = data;
    } else {
      return null;
    }
    final source = map['source'];
    final message = map['message'];
    if (source == 'agent' && message is String && message.trim().isNotEmpty) {
      return HomeGuideMessage(text: message.trim(), isFromRemoteAgent: true);
    }
    return null;
  }
}
