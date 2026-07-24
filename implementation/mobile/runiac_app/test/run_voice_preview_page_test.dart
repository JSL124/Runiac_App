import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/voice/domain/ports/run_speech_output.dart';
import 'package:runiac_app/features/run/voice/presentation/run_voice_preview_page.dart';

class _SpokenMessage {
  _SpokenMessage(this.message, this.languageTag);

  final String message;
  final String? languageTag;
}

class _FakeRunSpeechOutput implements RunSpeechOutput {
  final List<_SpokenMessage> spoken = <_SpokenMessage>[];
  int stopCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String message, {String? languageTag}) async {
    spoken.add(_SpokenMessage(message, languageTag));
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}

void main() {
  testWidgets(
    'default English: shows the distance-basic sentence and speaks it with en-US',
    (tester) async {
      final fake = _FakeRunSpeechOutput();

      await tester.pumpWidget(
        MaterialApp(home: RunVoicePreviewPage(speechOutput: fake)),
      );
      await tester.pumpAndSettle();

      expect(find.text('You have completed 1 kilometer.'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('preview_play_distance_basic')),
      );
      await tester.pumpAndSettle();

      expect(fake.spoken, hasLength(1));
      expect(fake.spoken.single.message, 'You have completed 1 kilometer.');
      expect(fake.spoken.single.languageTag, 'en-US');
    },
  );

  testWidgets(
    'switching to Korean recomputes displayed text and speaks with ko-KR',
    (tester) async {
      final fake = _FakeRunSpeechOutput();

      await tester.pumpWidget(
        MaterialApp(home: RunVoicePreviewPage(speechOutput: fake)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('preview-language-korean')));
      await tester.pumpAndSettle();

      expect(find.text('1킬로미터를 완료했습니다.'), findsOneWidget);
      expect(
        find.text(
          '1킬로미터를 완료했습니다. 운동 시간은 6분 12초입니다. '
          '평균 페이스는 킬로미터당 6분 12초입니다.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('preview_play_distance_basic')),
      );
      await tester.pumpAndSettle();

      expect(fake.spoken, hasLength(1));
      expect(fake.spoken.single.message, '1킬로미터를 완료했습니다.');
      expect(fake.spoken.single.languageTag, 'ko-KR');
    },
  );

  testWidgets('tapping Stop calls speechOutput.stop', (tester) async {
    final fake = _FakeRunSpeechOutput();

    await tester.pumpWidget(
      MaterialApp(home: RunVoicePreviewPage(speechOutput: fake)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('preview_stop_button')));
    await tester.pumpAndSettle();

    expect(fake.stopCount, greaterThanOrEqualTo(1));
  });

  testWidgets(
    'the distance-full item computes correctly and can be played',
    (tester) async {
      final fake = _FakeRunSpeechOutput();

      await tester.pumpWidget(
        MaterialApp(home: RunVoicePreviewPage(speechOutput: fake)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'You have completed 1 kilometer. Your time is 6 minutes 12 '
          'seconds. Your average pace is 6 minutes 12 seconds per '
          'kilometer.',
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('preview_play_distance_full')),
      );
      await tester.tap(
        find.byKey(const ValueKey('preview_play_distance_full')),
      );
      await tester.pumpAndSettle();

      expect(fake.spoken, hasLength(1));
      expect(fake.spoken.single.languageTag, 'en-US');
    },
  );
}
