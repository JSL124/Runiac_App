import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/cloud_function_activity_feedback_agent.dart';
import 'package:runiac_app/features/run/domain/models/activity_feedback_agent.dart';
import 'package:runiac_app/features/run/domain/models/run_summary_snapshot.dart';
import 'package:runiac_app/features/run/domain/services/advanced_analysis_snapshot_builder.dart';

void main() {
  group('CloudFunctionActivityFeedbackAgent', () {
    test('sends only derived metrics and parses generated sections', () async {
      Map<String, Object?>? capturedPayload;
      final agent = CloudFunctionActivityFeedbackAgent(
        callable: (payload) async {
          capturedPayload = payload;
          return _response(source: 'agent', delivery: 'generated');
        },
      );
      final summary = _summary();

      final bundle = await agent.explainRun(
        ActivityFeedbackRequest(
          summary: summary,
          analysis: const AdvancedAnalysisSnapshotBuilder().fromRunSummary(
            summary,
          ),
        ),
      );

      expect(bundle.isGenerated, isTrue);
      expect(bundle.sections.summary, 'You completed a steady run.');
      final encoded = capturedPayload.toString();
      for (final forbidden in <String>[
        'routeName',
        'activityId',
        'polyline',
        'coordinates',
        'Private loop',
      ]) {
        expect(encoded, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('parses quota and fallback responses', () async {
      final quotaAgent = CloudFunctionActivityFeedbackAgent(
        callable: (_) async => _response(
          source: 'quota',
          delivery: 'quota',
          retryAfterDate: '2026-07-12',
        ),
      );
      final fallbackAgent = CloudFunctionActivityFeedbackAgent(
        callable: (_) async =>
            _response(source: 'unavailable', delivery: 'fallback'),
      );

      final quota = await quotaAgent.explainRun(_request());
      final fallback = await fallbackAgent.explainRun(_request());

      expect(quota.source, ActivityFeedbackSource.quota);
      expect(quota.retryAfterDate, '2026-07-12');
      expect(fallback.source, ActivityFeedbackSource.fallback);
    });

    test(
      'falls back locally on callable errors or malformed responses',
      () async {
        final throwingAgent = CloudFunctionActivityFeedbackAgent(
          callable: (_) async => throw StateError('network unavailable'),
        );
        final malformedAgent = CloudFunctionActivityFeedbackAgent(
          callable: (_) async => <String, Object?>{'source': 'agent'},
        );

        expect(
          (await throwingAgent.explainRun(_request())).source,
          ActivityFeedbackSource.fallback,
        );
        expect(
          (await malformedAgent.explainRun(_request())).source,
          ActivityFeedbackSource.fallback,
        );
      },
    );
  });
}

ActivityFeedbackRequest _request() {
  final summary = _summary();
  return ActivityFeedbackRequest(
    summary: summary,
    analysis: const AdvancedAnalysisSnapshotBuilder().fromRunSummary(summary),
  );
}

RunSummarySnapshot _summary() {
  return const RunSummarySnapshot(
    title: 'Morning Run',
    dateLabel: 'Today',
    timeLabel: '7:00 AM',
    distanceKm: '4.00 km',
    avgPace: '6’00” / km',
    duration: '24:00',
    avgHeartRate: '--',
    calories: '200 kcal',
    routeName: 'Private loop',
  );
}

Map<String, Object?> _response({
  required String source,
  required String delivery,
  String? retryAfterDate,
}) {
  return <String, Object?>{
    'source': source,
    'delivery': delivery,
    'retryAfterDate': ?retryAfterDate,
    'sections': <String, Object?>{
      'summary': 'You completed a steady run.',
      'wentWell': 'You kept the effort controlled.',
      'improve': 'Start the next run gently.',
      'nextFocus': 'Keep the next session repeatable.',
    },
  };
}
