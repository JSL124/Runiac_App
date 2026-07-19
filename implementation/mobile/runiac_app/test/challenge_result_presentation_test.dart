import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/challenge/domain/challenge_notification_routing.dart';
import 'package:runiac_app/features/challenge/domain/challenge_result_seen_store.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_enums.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_history.dart';
import 'package:runiac_app/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:runiac_app/features/challenge/presentation/challenge_result_presentation_controller.dart';

import 'support/fake_challenge_repository.dart';

ChallengeHistoryEntry _entry({
  String challengeId = 'c-1',
  ChallengeParticipantStatus outcome = ChallengeParticipantStatus.succeeded,
  int endedAtMs = 2000,
}) {
  return ChallengeHistoryEntry(
    challengeId: challengeId,
    tierId: ChallengeTierId.k10,
    mode: ChallengeMode.group,
    role: ChallengeParticipantRole.member,
    outcome: outcome,
    terminalReason: ChallengeTerminalReason.targetReached,
    teamMeters: 10000,
    personalMeters: 6000,
    targetMeters: 10000,
    personalMinimumMeters: 3000,
    startedAtMs: 0,
    endedAtMs: endedAtMs,
  );
}

void main() {
  group('one-shot foreground presentation', () {
    test('presents the newest unseen result exactly once', () async {
      final repository = FakeChallengeRepository(
        historyOverride: <ChallengeHistoryEntry>[_entry(endedAtMs: 5000)],
      );
      final controller = ChallengeResultPresentationController(
        repository: repository,
        seenStore: InMemoryChallengeResultSeenStore(),
      );

      final first = await controller.takeUnseenResult();
      expect(first, isNotNull);
      expect(first!.challengeId, 'c-1');

      // A resume/replay must not re-present the same result.
      final second = await controller.takeUnseenResult();
      expect(second, isNull);
    });

    test('never re-presents a result already recorded as seen', () async {
      final repository = FakeChallengeRepository(
        historyOverride: <ChallengeHistoryEntry>[_entry(endedAtMs: 5000)],
      );
      final controller = ChallengeResultPresentationController(
        repository: repository,
        seenStore: InMemoryChallengeResultSeenStore(initialEndedAtMs: 5000),
      );

      expect(await controller.takeUnseenResult(), isNull);
    });

    test('presents a strictly newer result after an earlier one was seen',
        () async {
      final repository = FakeChallengeRepository(
        historyOverride: <ChallengeHistoryEntry>[_entry(endedAtMs: 9000)],
      );
      final controller = ChallengeResultPresentationController(
        repository: repository,
        seenStore: InMemoryChallengeResultSeenStore(initialEndedAtMs: 5000),
      );

      final result = await controller.takeUnseenResult();
      expect(result, isNotNull);
      expect(await controller.takeUnseenResult(), isNull);
    });

    test('returns null when there is no history', () async {
      final repository = FakeChallengeRepository(
        historyOverride: const <ChallengeHistoryEntry>[],
      );
      final controller = ChallengeResultPresentationController(
        repository: repository,
        seenStore: InMemoryChallengeResultSeenStore(),
      );

      expect(await controller.takeUnseenResult(), isNull);
    });

    test('swallows a read failure and presents nothing', () async {
      final repository = FakeChallengeRepository(
        historyFailure: const ChallengeFailure(reason: 'CHALLENGE_UNAVAILABLE'),
      );
      final controller = ChallengeResultPresentationController(
        repository: repository,
        seenStore: InMemoryChallengeResultSeenStore(),
      );

      expect(await controller.takeUnseenResult(), isNull);
    });
  });

  group('notification kind -> destination routing', () {
    ChallengeNotificationTarget? routeFor(String kind) {
      return challengeNotificationTargetFor(<String, Object?>{
        'kind': kind,
        'challengeId': 'c-42',
        'tierId': '10K',
      });
    }

    test('invitation received routes to the invitations list', () {
      final target = routeFor('challenge_invitation_received');
      expect(
        target?.destination,
        ChallengeNotificationDestination.invitations,
      );
      expect(target?.challengeId, 'c-42');
    });

    test('started and participant-left route to progress', () {
      expect(
        routeFor('challenge_started')?.destination,
        ChallengeNotificationDestination.progress,
      );
      expect(
        routeFor('challenge_participant_left')?.destination,
        ChallengeNotificationDestination.progress,
      );
    });

    test('owner cancelled, result ready, and badge issued route to result', () {
      for (final kind in <String>[
        'challenge_owner_cancelled',
        'challenge_result_ready',
        'challenge_badge_issued',
      ]) {
        expect(
          routeFor(kind)?.destination,
          ChallengeNotificationDestination.result,
          reason: kind,
        );
      }
    });

    test('non-challenge and malformed payloads resolve to null', () {
      expect(routeFor('plan_reminder'), isNull);
      expect(challengeNotificationTargetFor(const <String, Object?>{}), isNull);
      expect(
        challengeNotificationTargetFor(<String, Object?>{'kind': 42}),
        isNull,
      );
    });

    test('a challenge payload without a challengeId yields an empty id', () {
      final target = challengeNotificationTargetFor(<String, Object?>{
        'kind': 'challenge_result_ready',
      });
      expect(target?.destination, ChallengeNotificationDestination.result);
      expect(target?.challengeId, isEmpty);
    });
  });
}
