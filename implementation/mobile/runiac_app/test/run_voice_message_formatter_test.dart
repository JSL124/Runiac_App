import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/run/voice/domain/models/run_voice_announcement.dart';
import 'package:runiac_app/features/run/voice/domain/models/run_voice_language.dart';
import 'package:runiac_app/features/run/voice/domain/models/run_voice_session_config.dart';
import 'package:runiac_app/features/run/voice/domain/services/run_voice_message_formatter.dart';

RunVoiceAnnouncement _milestone(
  int meters, {
  Duration elapsed = const Duration(minutes: 5),
  Duration? averagePace,
}) {
  return RunVoiceAnnouncement(
    id: 'distance:$meters',
    type: RunVoiceAnnouncementType.distanceMilestone,
    priority: 50,
    distanceMeters: meters,
    elapsed: elapsed,
    averagePace: averagePace,
  );
}

RunVoiceAnnouncement _timeMilestone(
  Duration elapsed, {
  Duration? averagePace,
}) {
  return RunVoiceAnnouncement(
    id: 'time:${elapsed.inSeconds}',
    type: RunVoiceAnnouncementType.timeMilestone,
    priority: 40,
    distanceMeters: null,
    elapsed: elapsed,
    averagePace: averagePace,
  );
}

RunVoiceAnnouncement _targetHalfway({
  Duration elapsed = const Duration(minutes: 5),
  Duration? averagePace,
}) {
  return RunVoiceAnnouncement(
    id: 'target:halfway',
    type: RunVoiceAnnouncementType.targetHalfway,
    priority: 70,
    distanceMeters: 2500,
    elapsed: elapsed,
    averagePace: averagePace,
  );
}

RunVoiceAnnouncement _targetCompleted({
  Duration elapsed = const Duration(minutes: 5),
  Duration? averagePace,
}) {
  return RunVoiceAnnouncement(
    id: 'target:completed',
    type: RunVoiceAnnouncementType.targetCompleted,
    priority: 100,
    distanceMeters: 5000,
    elapsed: elapsed,
    averagePace: averagePace,
  );
}

RunVoiceSessionConfig _config(
  RunVoiceLanguage language, {
  bool includeElapsedTime = false,
  bool includeAveragePace = false,
}) {
  return RunVoiceSessionConfig(
    enabled: true,
    distanceIntervalMeters: 1000,
    timeInterval: null,
    includeElapsedTime: includeElapsedTime,
    includeAveragePace: includeAveragePace,
    language: language,
    targetDistanceMeters: null,
  );
}

void main() {
  group('LocalizedRunVoiceMessageFormatter', () {
    const formatter = LocalizedRunVoiceMessageFormatter();

    group('distance milestone (flags off, bare line)', () {
      test('formats the 1km distance milestone in English', () {
        final message = formatter.format(
          _milestone(1000),
          _config(RunVoiceLanguage.english),
        );
        expect(message, 'You have completed 1 kilometer.');
      });

      test('formats the 1km distance milestone in Korean', () {
        final message = formatter.format(
          _milestone(1000),
          _config(RunVoiceLanguage.korean),
        );
        expect(message, '1킬로미터를 완료했습니다.');
      });

      test('formats the 1km distance milestone in Simplified Chinese', () {
        final message = formatter.format(
          _milestone(1000),
          _config(RunVoiceLanguage.simplifiedChinese),
        );
        expect(message, '您已完成1公里。');
      });
    });

    group('distance milestone (elapsed + pace clauses)', () {
      test('English: elapsed 6:12, pace 6:12', () {
        final message = formatter.format(
          _milestone(
            1000,
            elapsed: const Duration(minutes: 6, seconds: 12),
            averagePace: const Duration(minutes: 6, seconds: 12),
          ),
          _config(
            RunVoiceLanguage.english,
            includeElapsedTime: true,
            includeAveragePace: true,
          ),
        );
        expect(
          message,
          'You have completed 1 kilometer. Your time is 6 minutes 12 '
          'seconds. Your average pace is 6 minutes 12 seconds per '
          'kilometer.',
        );
      });

      test('Korean: elapsed 6:12, pace 6:12', () {
        final message = formatter.format(
          _milestone(
            1000,
            elapsed: const Duration(minutes: 6, seconds: 12),
            averagePace: const Duration(minutes: 6, seconds: 12),
          ),
          _config(
            RunVoiceLanguage.korean,
            includeElapsedTime: true,
            includeAveragePace: true,
          ),
        );
        expect(
          message,
          '1킬로미터를 완료했습니다. 운동 시간은 6분 12초입니다. 평균 페이스는 킬로미터당 6분 12초입니다.',
        );
      });

      test('Simplified Chinese: elapsed 6:12, pace 6:12', () {
        final message = formatter.format(
          _milestone(
            1000,
            elapsed: const Duration(minutes: 6, seconds: 12),
            averagePace: const Duration(minutes: 6, seconds: 12),
          ),
          _config(
            RunVoiceLanguage.simplifiedChinese,
            includeElapsedTime: true,
            includeAveragePace: true,
          ),
        );
        expect(message, '您已完成1公里。运动时间6分12秒。平均配速每公里6分12秒。');
      });

      test('a null averagePace omits the pace clause even when enabled', () {
        final message = formatter.format(
          _milestone(
            1000,
            elapsed: const Duration(minutes: 6, seconds: 12),
          ),
          _config(
            RunVoiceLanguage.english,
            includeElapsedTime: true,
            includeAveragePace: true,
          ),
        );
        expect(
          message,
          'You have completed 1 kilometer. Your time is 6 minutes 12 '
          'seconds.',
        );
      });

      test('includeAveragePace false omits the pace clause', () {
        final message = formatter.format(
          _milestone(
            1000,
            elapsed: const Duration(minutes: 6, seconds: 12),
            averagePace: const Duration(minutes: 6, seconds: 12),
          ),
          _config(
            RunVoiceLanguage.english,
            includeElapsedTime: true,
          ),
        );
        expect(
          message,
          'You have completed 1 kilometer. Your time is 6 minutes 12 '
          'seconds.',
        );
      });
    });

    group('time milestone', () {
      test('10 minutes elapsed, Korean, no pace', () {
        final message = formatter.format(
          _timeMilestone(const Duration(seconds: 600)),
          _config(RunVoiceLanguage.korean),
        );
        expect(message, '10분 경과했습니다.');
      });

      test('10 minutes elapsed, English, no pace', () {
        final message = formatter.format(
          _timeMilestone(const Duration(seconds: 600)),
          _config(RunVoiceLanguage.english),
        );
        expect(message, '10 minutes elapsed.');
      });

      test('10 minutes elapsed, Simplified Chinese, no pace', () {
        final message = formatter.format(
          _timeMilestone(const Duration(seconds: 600)),
          _config(RunVoiceLanguage.simplifiedChinese),
        );
        expect(message, '已经过10分钟。');
      });
    });

    group('target halfway', () {
      test('English base line', () {
        final message = formatter.format(
          _targetHalfway(),
          _config(RunVoiceLanguage.english),
        );
        expect(message, 'You are halfway to your goal.');
      });

      test('Korean base line', () {
        final message = formatter.format(
          _targetHalfway(),
          _config(RunVoiceLanguage.korean),
        );
        expect(message, '목표 거리의 절반을 지났습니다.');
      });

      test('Simplified Chinese base line', () {
        final message = formatter.format(
          _targetHalfway(),
          _config(RunVoiceLanguage.simplifiedChinese),
        );
        expect(message, '您已到达目标距离的一半。');
      });
    });

    group('target completed', () {
      test('English base line', () {
        final message = formatter.format(
          _targetCompleted(),
          _config(RunVoiceLanguage.english),
        );
        expect(message, 'You have reached your goal distance. Well done.');
      });

      test('Korean base line', () {
        final message = formatter.format(
          _targetCompleted(),
          _config(RunVoiceLanguage.korean),
        );
        expect(message, '목표 거리를 완료했습니다. 수고하셨습니다.');
      });

      test('Simplified Chinese base line', () {
        final message = formatter.format(
          _targetCompleted(),
          _config(RunVoiceLanguage.simplifiedChinese),
        );
        expect(message, '您已完成目标距离。做得好。');
      });
    });
  });
}
