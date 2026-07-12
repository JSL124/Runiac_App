import 'package:cloud_functions/cloud_functions.dart';

import '../domain/models/activity_feedback_agent.dart';
import '../domain/services/activity_feedback_payload_builder.dart';

typedef ActivityFeedbackCallable =
    Future<Object?> Function(Map<String, Object?> payload);

class CloudFunctionActivityFeedbackAgent implements ActivityFeedbackAgent {
  CloudFunctionActivityFeedbackAgent({
    FirebaseFunctions? functions,
    ActivityFeedbackCallable? callable,
    this.payloadBuilder = const ActivityFeedbackPayloadBuilder(),
  }) : _callable =
           callable ??
           _firebaseCallable(
             functions ??
                 FirebaseFunctions.instanceFor(region: 'asia-southeast1'),
           );

  final ActivityFeedbackCallable _callable;
  final ActivityFeedbackPayloadBuilder payloadBuilder;

  @override
  Future<ActivityFeedbackBundle> explainRun(
    ActivityFeedbackRequest request,
  ) async {
    try {
      final payload = payloadBuilder.build(
        summary: request.summary,
        analysis: request.analysis,
      );
      final bundle = _bundleFromResponse(await _callable(payload));
      if (bundle != null) return bundle;
    } catch (_) {
      // Keep the summary UI usable when Firebase, quota, or model output fails.
    }
    return fallbackActivityFeedbackBundle();
  }

  static ActivityFeedbackCallable _firebaseCallable(
    FirebaseFunctions functions,
  ) {
    return (payload) async {
      final result = await functions
          .httpsCallable('activityFeedbackAgent')
          .call(payload);
      return result.data;
    };
  }

  ActivityFeedbackBundle? _bundleFromResponse(Object? data) {
    if (data is! Map<Object?, Object?>) return null;
    final source = data['source'];
    final delivery = data['delivery'];
    final sections = _sectionsFromResponse(data['sections']);
    if (sections == null) return null;
    if (source == 'agent' && delivery == 'generated') {
      return ActivityFeedbackBundle(
        source: ActivityFeedbackSource.generated,
        sections: sections,
      );
    }
    if (source == 'quota' && delivery == 'quota') {
      return ActivityFeedbackBundle(
        source: ActivityFeedbackSource.quota,
        sections: sections,
        retryAfterDate: data['retryAfterDate'] is String
            ? data['retryAfterDate']! as String
            : null,
      );
    }
    if (source == 'unavailable' && delivery == 'fallback') {
      return ActivityFeedbackBundle(
        source: ActivityFeedbackSource.fallback,
        sections: sections,
      );
    }
    return null;
  }

  ActivityFeedbackSections? _sectionsFromResponse(Object? data) {
    if (data is! Map<Object?, Object?>) return null;
    final summary = data['summary'];
    final wentWell = data['wentWell'];
    final improve = data['improve'];
    final nextFocus = data['nextFocus'];
    if (summary is! String ||
        wentWell is! String ||
        improve is! String ||
        nextFocus is! String) {
      return null;
    }
    return ActivityFeedbackSections(
      summary: summary,
      wentWell: wentWell,
      improve: improve,
      nextFocus: nextFocus,
    );
  }
}
