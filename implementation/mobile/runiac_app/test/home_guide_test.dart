import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/home/domain/guide/home_guide_agent.dart';
import 'package:runiac_app/features/home/domain/guide/rule_based_home_guide_agent.dart';

HomeGuideRequest _request({
  String dayLabel = 'Mon',
  String workoutTitle = 'Easy Run',
  int durationMinutes = 20,
  String intensityLabel = 'Gentle',
  String description = 'A relaxed run to build your habit.',
  String supportiveNote = 'Keep the pace conversational.',
}) {
  return HomeGuideRequest(
    planTitle: 'First 10K Preparation',
    weekNumber: 1,
    weekFocus: 'Build a steady habit',
    dayLabel: dayLabel,
    workoutTitle: workoutTitle,
    durationMinutes: durationMinutes,
    intensityLabel: intensityLabel,
    description: description,
    supportiveNote: supportiveNote,
  );
}

void main() {
  group('RuleBasedHomeGuideAgent', () {
    const agent = RuleBasedHomeGuideAgent();

    test('composes friendly copy that mentions the day, title and duration', () async {
      final message = await agent.explainTodayPlan(_request());

      expect(message.isFromRemoteAgent, isFalse);
      expect(message.text, contains('Mon'));
      expect(message.text, contains('Easy Run'));
      expect(message.text, contains('20 minutes'));
      expect(message.text, contains('gentle'));
    });

    test('includes the supportive note when present', () async {
      final message = await agent.explainTodayPlan(
        _request(supportiveNote: 'Smile and enjoy the fresh air.'),
      );

      expect(message.text, contains('Smile and enjoy the fresh air.'));
    });

    test('falls back to a generic encouragement when there is no note', () async {
      final message = await agent.explainTodayPlan(_request(supportiveNote: ''));

      expect(message.text, contains("You've got this"));
    });

    test('is deterministic for the same request', () async {
      final request = _request();
      final first = await agent.explainTodayPlan(request);
      final second = await agent.explainTodayPlan(request);

      expect(first.text, second.text);
    });

    test('never emits more than 3 sentences', () async {
      final message = await agent.explainTodayPlan(_request());
      final sentenceCount = RegExp(r'[.!?]').allMatches(message.text).length;

      expect(sentenceCount, lessThanOrEqualTo(3));
    });
  });
}
