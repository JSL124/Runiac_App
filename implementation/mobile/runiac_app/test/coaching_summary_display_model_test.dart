import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/coaching_summary_snapshot.dart';

void main() {
  group('CoachingSummarySnapshot', () {
    test('maps coaching summary source to safe section titles', () {
      const ruleBasedSummary = CoachingSummarySnapshot(
        source: CoachingSummarySource.ruleBased,
        headline: 'Nice steady effort',
        message: 'You kept this run simple and complete.',
        nextAction: 'Keep the next run easy.',
      );

      const aiGeneratedSummary = CoachingSummarySnapshot(
        source: CoachingSummarySource.aiGenerated,
        headline: 'Detailed coaching insight',
        message: 'A trusted backend returned this AI-backed summary.',
        nextAction: 'Review the next planned run.',
      );

      expect(ruleBasedSummary.sectionTitle, 'Coaching Summary');
      expect(aiGeneratedSummary.sectionTitle, 'AI Coaching Summary');
    });

    test('keeps source metadata separate from entitlement authority', () {
      const summary = CoachingSummarySnapshot(
        source: CoachingSummarySource.aiGenerated,
        headline: 'Backend supplied summary',
        message: 'The source describes display metadata already returned.',
        nextAction: 'Render the returned copy.',
      );

      expect(summary.source, CoachingSummarySource.aiGenerated);
      expect(summary.sectionTitle, 'AI Coaching Summary');
      expect(
        CoachingSummarySource.values.map((source) => source.name),
        isNot(contains('premium')),
      );
      expect(
        CoachingSummarySource.values.map((source) => source.name),
        isNot(contains('subscription')),
      );
      expect(
        CoachingSummarySource.values.map((source) => source.name),
        isNot(contains('userRole')),
      );
      expect(
        CoachingSummarySource.values.map((source) => source.name),
        isNot(contains('openAi')),
      );
    });

    test('exposes optional bullets as an unmodifiable display list', () {
      final bullets = ['Start easy', 'Keep the next run relaxed'];
      final summary = CoachingSummarySnapshot(
        source: CoachingSummarySource.ruleBased,
        headline: 'Good finish',
        message: 'This summary can carry a few concise coaching points.',
        bullets: bullets,
        nextAction: 'Repeat one comfortable run.',
      );

      expect(summary.bullets, ['Start easy', 'Keep the next run relaxed']);
      expect(
        () => summary.bullets.add('Mutated bullet'),
        throwsUnsupportedError,
      );
      expect(summary.sectionTitle, 'Coaching Summary');
    });
  });
}
