import 'advanced_analysis_snapshot.dart';
import 'run_summary_snapshot.dart';

class ActivityFeedbackRequest {
  const ActivityFeedbackRequest({
    required this.summary,
    required this.analysis,
  });

  final RunSummarySnapshot summary;
  final AdvancedAnalysisSnapshot analysis;
}

class ActivityFeedbackSections {
  const ActivityFeedbackSections({
    required this.summary,
    required this.wentWell,
    required this.improve,
    required this.nextFocus,
  });

  final String summary;
  final String wentWell;
  final String improve;
  final String nextFocus;

  List<ActivityFeedbackSectionStep> get steps {
    return <ActivityFeedbackSectionStep>[
      ActivityFeedbackSectionStep(title: 'Summary', body: summary),
      ActivityFeedbackSectionStep(title: 'Went well', body: wentWell),
      ActivityFeedbackSectionStep(title: 'Improve', body: improve),
      ActivityFeedbackSectionStep(title: 'Next focus', body: nextFocus),
    ];
  }
}

class ActivityFeedbackSectionStep {
  const ActivityFeedbackSectionStep({required this.title, required this.body});

  final String title;
  final String body;
}

class ActivityFeedbackBundle {
  const ActivityFeedbackBundle({
    required this.sections,
    required this.source,
    this.retryAfterDate,
  });

  final ActivityFeedbackSections sections;
  final ActivityFeedbackSource source;
  final String? retryAfterDate;

  bool get isGenerated => source == ActivityFeedbackSource.generated;
}

enum ActivityFeedbackSource { generated, fallback, quota }

abstract interface class ActivityFeedbackAgent {
  Future<ActivityFeedbackBundle> explainRun(ActivityFeedbackRequest request);
}

ActivityFeedbackBundle fallbackActivityFeedbackBundle({
  ActivityFeedbackSource source = ActivityFeedbackSource.fallback,
  String? retryAfterDate,
}) {
  return ActivityFeedbackBundle(
    source: source,
    retryAfterDate: retryAfterDate,
    sections: const ActivityFeedbackSections(
      summary:
          'Your run summary is ready, but personalised feedback is temporarily unavailable.',
      wentWell: 'You completed the run and captured useful derived metrics.',
      improve:
          'Keep the next effort comfortable and notice what feels repeatable.',
      nextFocus: 'Aim for one calm, steady session when you feel ready.',
    ),
  );
}
