import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/challenge/domain/challenge_countdown.dart';
import 'package:runiac_app/features/challenge/domain/models/active_challenge.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_enums.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_invitation_summary.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_participant_row.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_rules_snapshot.dart';
import 'package:runiac_app/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:runiac_app/features/challenge/presentation/challenge_friend_picker_screen.dart';
import 'package:runiac_app/features/challenge/presentation/challenge_lobby_screen.dart';
import 'package:runiac_app/features/challenge/presentation/challenge_progress_screen.dart';
import 'package:runiac_app/core/widgets/runiac_level_profile_badge.dart';

import 'support/fake_challenge_repository.dart';

class _FakeTicker implements ChallengeTicker {
  @override
  void start(VoidCallback onTick) {}

  @override
  void stop() {}
}

const _rules = ChallengeRulesSnapshot(
  tierId: ChallengeTierId.k10,
  catalogVersion: 'challenge-distance-v1',
  difficultyLabel: 'Beginner',
  durationDays: 7,
  durationMs: 604800000,
  maxParticipants: 2,
  maxInvitedFriends: 1,
  targetMeters: 10000,
  personalMinimumMeters: 3000,
);

final _clock = DateTime.fromMillisecondsSinceEpoch(1000000000000);

ChallengeParticipantRow _owner() => const ChallengeParticipantRow(
      uid: 'me',
      displayNameSnapshot: 'You',
      avatarInitialsSnapshot: 'YO',
      role: ChallengeParticipantRole.owner,
      status: ChallengeParticipantStatus.accepted,
      creditedMeters: 0,
      reward: ChallengeRewardStatus.notEligible,
      isCurrentUser: true,
    );

ChallengeParticipantRow _member() => const ChallengeParticipantRow(
      uid: 'friend',
      displayNameSnapshot: 'Sam Runner',
      avatarInitialsSnapshot: 'SR',
      role: ChallengeParticipantRole.member,
      status: ChallengeParticipantStatus.accepted,
      creditedMeters: 0,
      reward: ChallengeRewardStatus.notEligible,
      isCurrentUser: false,
    );

ActiveChallenge _lobby({
  required bool isOwner,
  required List<ChallengeParticipantRow> participants,
}) {
  return ActiveChallenge(
    challengeId: 'lobby-1',
    ownerUid: isOwner ? 'me' : 'friend',
    tierId: ChallengeTierId.k10,
    mode: ChallengeMode.solo,
    status: ChallengeInstanceStatus.recruiting,
    rules: _rules,
    rosterUids: participants.map((p) => p.uid).toList(),
    maxParticipants: 2,
    teamMeters: 0,
    createdAtMs: _clock.millisecondsSinceEpoch,
    lobbyExpiresAtMs: _clock.millisecondsSinceEpoch + 3600000,
    startsAtMs: null,
    scheduledEndsAtMs: null,
    terminalReason: null,
    participants: participants,
    isCurrentUserOwner: isOwner,
  );
}

Widget _harness(ChallengeLobbyScreen screen) => MaterialApp(home: screen);

ChallengeLobbyScreen _screen({
  required FakeChallengeRepository repository,
  List<ChallengeInvitationSummary> pendingInvitations =
      const <ChallengeInvitationSummary>[],
}) {
  return ChallengeLobbyScreen(
    challengeId: 'lobby-1',
    repository: repository,
    pendingInvitations: pendingInvitations,
    clock: () => _clock,
    ticker: _FakeTicker(),
    onBack: () {},
  );
}

void main() {
  testWidgets('owner sees start, cancel, invite and the closes-in countdown', (
    tester,
  ) async {
    final repository = FakeChallengeRepository(
      activeOverride: () => _lobby(isOwner: true, participants: [_owner()]),
    );
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Start challenge'), findsOneWidget);
    expect(find.text('Cancel challenge'), findsOneWidget);
    expect(find.text('Invite friends'), findsOneWidget);
    expect(find.text('You · Owner'), findsOneWidget);
    expect(find.text('Lobby closes in 01:00:00'), findsOneWidget);
    expect(find.text('Leave lobby'), findsNothing);
  });

  testWidgets('member sees leave and waiting copy, no owner controls', (
    tester,
  ) async {
    final repository = FakeChallengeRepository(
      activeOverride: () =>
          _lobby(isOwner: false, participants: [_member(), _owner()]),
    );
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Leave lobby'), findsOneWidget);
    expect(find.text('Waiting for the owner to start'), findsOneWidget);
    expect(find.text('Start challenge'), findsNothing);
    expect(find.text('Cancel challenge'), findsNothing);
  });

  testWidgets('roster shows Accepted, Pending and Declined chips', (
    tester,
  ) async {
    final repository = FakeChallengeRepository(
      activeOverride: () =>
          _lobby(isOwner: true, participants: [_owner(), _member()]),
    );
    final invitations = <ChallengeInvitationSummary>[
      const ChallengeInvitationSummary(
        inviteId: 'i1',
        challengeId: 'lobby-1',
        tierId: ChallengeTierId.k10,
        ownerUid: 'me',
        status: ChallengeInvitationStatus.pending,
        createdAtMs: 0,
        expiresAtMs: 0,
        rules: null,
      ),
      const ChallengeInvitationSummary(
        inviteId: 'i2',
        challengeId: 'lobby-1',
        tierId: ChallengeTierId.k10,
        ownerUid: 'me',
        status: ChallengeInvitationStatus.declined,
        createdAtMs: 0,
        expiresAtMs: 0,
        rules: null,
      ),
    ];
    await tester.pumpWidget(
      _harness(_screen(repository: repository, pendingInvitations: invitations)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
  });

  testWidgets('start confirm sheet uses solo wording when alone', (
    tester,
  ) async {
    final repository = FakeChallengeRepository(
      activeOverride: () => _lobby(isOwner: true, participants: [_owner()]),
    );
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start challenge'));
    await tester.pumpAndSettle();

    expect(find.text('Start solo — no one has joined yet.'), findsOneWidget);
  });

  testWidgets('start confirm sheet uses group wording with runners', (
    tester,
  ) async {
    final repository = FakeChallengeRepository(
      activeOverride: () =>
          _lobby(isOwner: true, participants: [_owner(), _member()]),
    );
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start challenge').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Start with 2 runners — unanswered invitations will expire.'),
      findsOneWidget,
    );
  });

  testWidgets('confirming start calls the repository and routes to progress', (
    tester,
  ) async {
    final repository = FakeChallengeRepository(
      activeOverride: () => _lobby(isOwner: true, participants: [_owner()]),
    );
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start challenge'));
    await tester.pumpAndSettle();
    // Confirm inside the sheet (the sheet's primary button).
    await tester.tap(find.text('Start challenge').last);
    await tester.pumpAndSettle();

    expect(repository.startedChallenges, <String>['lobby-1']);
    expect(find.byType(ChallengeProgressScreen), findsOneWidget);
  });

  testWidgets('cancel challenge asks for confirmation and calls repository', (
    tester,
  ) async {
    final repository = FakeChallengeRepository(
      activeOverride: () => _lobby(isOwner: true, participants: [_owner()]),
    );
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel challenge'));
    await tester.pumpAndSettle();

    expect(
      find.text('Cancel this challenge for everyone? This cannot be undone.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel challenge').last);
    await tester.pumpAndSettle();

    expect(repository.cancelledChallenges, <String>['lobby-1']);
  });

  testWidgets('expired lobby shows the calm expired state', (tester) async {
    final repository = FakeChallengeRepository(activeOverride: () => null);
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('This lobby expired'), findsOneWidget);
  });

  testWidgets('surfaces the backend reason when start fails', (tester) async {
    final repository = FakeChallengeRepository(
      activeOverride: () => _lobby(isOwner: true, participants: [_owner()]),
      startFailure: const ChallengeFailure(reason: 'LOBBY_EXPIRED'),
    );
    await tester.pumpWidget(_harness(_screen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start challenge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start challenge').last);
    await tester.pumpAndSettle();

    expect(find.text('This lobby has expired.'), findsOneWidget);
  });

  testWidgets('picker enforces the invite cap with a live counter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChallengeFriendPickerScreen(
          cap: 1,
          onBack: () {},
          friends: const [
            ChallengeInvitableFriend(
              uid: 'a',
              displayName: 'Ann',
              initials: 'AN',
              levelLabel: 'Lv.9',
            ),
            ChallengeInvitableFriend(uid: 'b', displayName: 'Bob', initials: 'BO'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invited 0 of 1'), findsWidgets);
    // Rows use the same profile-circle + XP-ring + level-pill badge as Friends.
    expect(find.byType(RuniacLevelProfileBadge), findsNWidgets(2));
    expect(find.text('Lv.9'), findsOneWidget);
    expect(find.text('Lv.0'), findsOneWidget);

    await tester.tap(find.text('Ann'));
    await tester.pumpAndSettle();

    expect(find.text('Invited 1 of 1'), findsWidgets);
    // The second row is now over cap and disabled.
    expect(find.text('Invite limit reached'), findsOneWidget);
  });

  testWidgets('lobby lays out at 360px and textScale 1.3 without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeChallengeRepository(
      activeOverride: () =>
          _lobby(isOwner: true, participants: [_owner(), _member()]),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: _screen(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Start challenge'), findsOneWidget);
  });
}
