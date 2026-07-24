import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/run/voice/application/run_voice_coaching_coordinator.dart';
import 'package:runiac_app/features/run/voice/domain/models/run_voice_announcement.dart';
import 'package:runiac_app/features/run/voice/domain/models/run_voice_language.dart';
import 'package:runiac_app/features/run/voice/domain/models/run_voice_session_config.dart';
import 'package:runiac_app/features/run/voice/domain/models/run_voice_snapshot.dart';
import 'package:runiac_app/features/run/voice/domain/ports/run_speech_output.dart';
import 'package:runiac_app/features/run/voice/domain/services/run_voice_announcement_policy.dart';
import 'package:runiac_app/features/run/voice/domain/services/run_voice_announcement_selector.dart';
import 'package:runiac_app/features/run/voice/domain/services/run_voice_message_formatter.dart';

class _FakeRunSpeechOutput implements RunSpeechOutput {
  int initializeCallCount = 0;
  int stopCallCount = 0;
  final List<String> spokenMessages = [];
  final List<String?> languageTags = [];
  bool throwOnSpeak = false;
  Completer<void>? gate;

  @override
  Future<void> initialize() async {
    initializeCallCount += 1;
  }

  @override
  Future<void> speak(String message, {String? languageTag}) async {
    if (throwOnSpeak) {
      throw StateError('speak failed');
    }
    spokenMessages.add(message);
    languageTags.add(languageTag);
    final currentGate = gate;
    if (currentGate != null) {
      await currentGate.future;
    }
  }

  @override
  Future<void> stop() async {
    stopCallCount += 1;
  }
}

class _EchoIdMessageFormatter implements RunVoiceMessageFormatter {
  const _EchoIdMessageFormatter();

  @override
  String format(
    RunVoiceAnnouncement announcement,
    RunVoiceSessionConfig config,
  ) {
    return announcement.id;
  }
}

class _ScriptedPolicy implements RunVoiceAnnouncementPolicy {
  _ScriptedPolicy(this._results);

  final List<RunVoicePolicyResult> _results;
  int _callIndex = 0;

  @override
  RunVoicePolicyResult evaluate({
    required RunVoiceSnapshot previous,
    required RunVoiceSnapshot current,
    required RunVoiceSessionConfig config,
    required Set<String> announcedIds,
  }) {
    if (_callIndex >= _results.length) {
      return const RunVoicePolicyResult.empty();
    }
    final result = _results[_callIndex];
    _callIndex += 1;
    return result;
  }
}

RunVoiceSnapshot _snapshot(
  int distanceMeters, {
  bool isActive = true,
  bool isPaused = false,
}) {
  return RunVoiceSnapshot(
    distanceMeters: distanceMeters,
    elapsed: Duration(seconds: distanceMeters),
    averagePace: null,
    isActive: isActive,
    isPaused: isPaused,
  );
}

RunVoiceSessionConfig _config({bool enabled = true}) {
  return RunVoiceSessionConfig(
    enabled: enabled,
    distanceIntervalMeters: 1000,
    timeInterval: null,
    // Elapsed-time/pace clauses are covered exhaustively by
    // run_voice_message_formatter_test.dart; keep this coordinator config
    // on the bare-line path so integration assertions below stay focused
    // on speak sequencing rather than message wording.
    includeElapsedTime: false,
    includeAveragePace: false,
    language: RunVoiceLanguage.english,
    targetDistanceMeters: null,
  );
}

RunVoiceAnnouncement _scriptedAnnouncement(String id, int priority) {
  return RunVoiceAnnouncement(
    id: id,
    type: RunVoiceAnnouncementType.distanceMilestone,
    priority: priority,
    distanceMeters: null,
    elapsed: Duration.zero,
    averagePace: null,
  );
}

RunVoiceCoachingCoordinator _realCoordinator(_FakeRunSpeechOutput speech) {
  return RunVoiceCoachingCoordinator(
    policy: const DefaultRunVoiceAnnouncementPolicy(),
    selector: const PriorityRunVoiceAnnouncementSelector(),
    formatter: const LocalizedRunVoiceMessageFormatter(),
    speechOutput: speech,
  );
}

void main() {
  group('RunVoiceCoachingCoordinator', () {
    test('crossing 980, 1020, 1050 speaks the 1km milestone exactly once', () async {
      final speech = _FakeRunSpeechOutput();
      final coordinator = _realCoordinator(speech);

      await coordinator.startSession(_config());
      await coordinator.onSnapshot(_snapshot(980));
      await pumpEventQueue();
      await coordinator.onSnapshot(_snapshot(1020));
      await pumpEventQueue();
      await coordinator.onSnapshot(_snapshot(1050));
      await pumpEventQueue();

      expect(speech.spokenMessages, ['You have completed 1 kilometer.']);
      expect(speech.initializeCallCount, 1);
    });

    test('a disabled config never initializes or speaks', () async {
      final speech = _FakeRunSpeechOutput();
      final coordinator = _realCoordinator(speech);

      await coordinator.startSession(_config(enabled: false));
      await coordinator.onSnapshot(_snapshot(980));
      await pumpEventQueue();
      await coordinator.onSnapshot(_snapshot(1020));
      await pumpEventQueue();

      expect(speech.initializeCallCount, 0);
      expect(speech.spokenMessages, isEmpty);
    });

    test('a throwing speech output does not surface an exception', () async {
      final speech = _FakeRunSpeechOutput()..throwOnSpeak = true;
      final coordinator = _realCoordinator(speech);

      await coordinator.startSession(_config());
      await expectLater(coordinator.onSnapshot(_snapshot(980)), completes);
      await pumpEventQueue();
      await expectLater(coordinator.onSnapshot(_snapshot(1020)), completes);
      await pumpEventQueue();

      expect(speech.spokenMessages, isEmpty);
    });

    test(
      'a paused snapshot between active ones does not repeat the 1km milestone',
      () async {
        final speech = _FakeRunSpeechOutput();
        final coordinator = _realCoordinator(speech);

        await coordinator.startSession(_config());
        await coordinator.onSnapshot(_snapshot(980));
        await pumpEventQueue();
        await coordinator.onSnapshot(_snapshot(1020));
        await pumpEventQueue();
        expect(speech.spokenMessages, hasLength(1));

        await coordinator.onSnapshot(_snapshot(1025, isPaused: true));
        await pumpEventQueue();
        await coordinator.onSnapshot(_snapshot(1040));
        await pumpEventQueue();

        expect(speech.spokenMessages, hasLength(1));
      },
    );

    test(
      'stopSession stops speech output and later snapshots produce no speech',
      () async {
        final speech = _FakeRunSpeechOutput();
        final coordinator = _realCoordinator(speech);

        await coordinator.startSession(_config());
        await coordinator.onSnapshot(_snapshot(980));
        await pumpEventQueue();
        await coordinator.onSnapshot(_snapshot(1020));
        await pumpEventQueue();
        expect(speech.spokenMessages, hasLength(1));

        await coordinator.stopSession();
        expect(speech.stopCallCount, 1);
        expect(coordinator.activeSessionCount, 0);

        await coordinator.onSnapshot(_snapshot(2100));
        await pumpEventQueue();

        expect(speech.spokenMessages, hasLength(1));
      },
    );

    test('stopSession is idempotent when called twice', () async {
      final speech = _FakeRunSpeechOutput();
      final coordinator = _realCoordinator(speech);

      await coordinator.startSession(_config());
      await expectLater(coordinator.stopSession(), completes);
      await expectLater(coordinator.stopSession(), completes);

      expect(speech.stopCallCount, 2);
      expect(coordinator.activeSessionCount, 0);
    });

    test(
      'a new session after stopSession can announce the first km again',
      () async {
        final speech = _FakeRunSpeechOutput();
        final coordinator = _realCoordinator(speech);

        await coordinator.startSession(_config());
        await coordinator.onSnapshot(_snapshot(980));
        await pumpEventQueue();
        await coordinator.onSnapshot(_snapshot(1020));
        await pumpEventQueue();
        expect(speech.spokenMessages, hasLength(1));

        await coordinator.stopSession();

        await coordinator.startSession(_config());
        expect(coordinator.activeSessionCount, 1);
        await coordinator.onSnapshot(_snapshot(980));
        await pumpEventQueue();
        await coordinator.onSnapshot(_snapshot(1020));
        await pumpEventQueue();

        expect(speech.spokenMessages, hasLength(2));
        expect(
          speech.spokenMessages,
          everyElement('You have completed 1 kilometer.'),
        );
      },
    );

    test(
      'keeps only the highest-priority pending announcement while a gated '
      'speak is in flight',
      () async {
        final gate = Completer<void>();
        final speech = _FakeRunSpeechOutput()..gate = gate;
        final scriptedPolicy = _ScriptedPolicy([
          RunVoicePolicyResult(
            announcements: [_scriptedAnnouncement('low', 10)],
            consumedIds: {'low'},
          ),
          RunVoicePolicyResult(
            announcements: [_scriptedAnnouncement('mid', 40)],
            consumedIds: {'mid'},
          ),
          RunVoicePolicyResult(
            announcements: [_scriptedAnnouncement('high', 90)],
            consumedIds: {'high'},
          ),
          RunVoicePolicyResult(
            announcements: [_scriptedAnnouncement('low-again', 20)],
            consumedIds: {'low-again'},
          ),
        ]);
        final coordinator = RunVoiceCoachingCoordinator(
          policy: scriptedPolicy,
          selector: const PriorityRunVoiceAnnouncementSelector(),
          formatter: const _EchoIdMessageFormatter(),
          speechOutput: speech,
        );

        await coordinator.startSession(_config());

        // First evaluate call selects 'low' (priority 10); nothing is
        // speaking yet, so it starts speaking immediately and blocks on
        // the gate, simulating an in-flight utterance.
        await coordinator.onSnapshot(_snapshot(0));
        await pumpEventQueue();
        expect(speech.spokenMessages, ['low']);
        expect(coordinator.pendingCount, 0);

        // Second evaluate call selects 'mid' (priority 40) while speaking
        // is still in flight: it becomes pending.
        await coordinator.onSnapshot(_snapshot(1));
        await pumpEventQueue();
        expect(coordinator.pendingCount, 1);
        expect(coordinator.pendingAnnouncement!.id, 'mid');

        // Third evaluate call selects 'high' (priority 90), which beats
        // the current pending ('mid', priority 40) and replaces it.
        await coordinator.onSnapshot(_snapshot(2));
        await pumpEventQueue();
        expect(coordinator.pendingAnnouncement!.id, 'high');

        // Fourth evaluate call selects 'low-again' (priority 20), which is
        // lower than the current pending ('high', priority 90) and must
        // not replace it.
        await coordinator.onSnapshot(_snapshot(3));
        await pumpEventQueue();
        expect(coordinator.pendingAnnouncement!.id, 'high');

        // Release the gate: the first ('low') utterance finishes, then the
        // drain loop speaks only the surviving pending ('high') — 'mid'
        // and 'low-again' are never spoken.
        gate.complete();
        await pumpEventQueue();

        expect(speech.spokenMessages, ['low', 'high']);
        expect(coordinator.pendingCount, 0);
      },
    );

    test(
      'starting a new session while a gated speak of the old session is in '
      'flight does not let the stale drain speak into the new session',
      () async {
        final gate = Completer<void>();
        final speech = _FakeRunSpeechOutput()..gate = gate;
        final scriptedPolicy = _ScriptedPolicy([
          RunVoicePolicyResult(
            announcements: [_scriptedAnnouncement('old', 10)],
            consumedIds: {'old'},
          ),
          RunVoicePolicyResult(
            announcements: [_scriptedAnnouncement('old-pending', 20)],
            consumedIds: {'old-pending'},
          ),
        ]);
        final coordinator = RunVoiceCoachingCoordinator(
          policy: scriptedPolicy,
          selector: const PriorityRunVoiceAnnouncementSelector(),
          formatter: const _EchoIdMessageFormatter(),
          speechOutput: speech,
        );

        await coordinator.startSession(_config());

        // First evaluate call selects 'old'; nothing is speaking yet, so it
        // starts speaking immediately and blocks on the gate, simulating an
        // in-flight utterance for the old session generation.
        await coordinator.onSnapshot(_snapshot(0));
        await pumpEventQueue();
        expect(speech.spokenMessages, ['old']);

        // Second evaluate call selects 'old-pending' while speaking is
        // still in flight: it becomes pending for the old generation.
        await coordinator.onSnapshot(_snapshot(1));
        await pumpEventQueue();
        expect(coordinator.pendingCount, 1);

        // Starting a new session bumps the generation and clears pending
        // state synchronously, even though the old drain is still gated.
        await coordinator.startSession(_config());
        expect(coordinator.pendingCount, 0);

        // Releasing the gate lets the stale 'old' speak() call resolve.
        // The stale drain must detect the generation mismatch and stop
        // instead of speaking 'old-pending' into the new session.
        gate.complete();
        await pumpEventQueue();

        expect(speech.spokenMessages, ['old']);
        expect(coordinator.pendingCount, 0);
      },
    );
  });
}
