# realtime-social-challenge-sync

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed **client-only** implementation. This capsule does not deploy or edit Firestore Rules, indexes, or Cloud Functions, so it stays outside the ADR-003 Backend Guarded Lane; ADR-002 Emulator First still governs any local read verification.

## Status

Routed on 2026-07-14 Asia/Singapore. The user reported that cross-device social/challenge actions (friend send/accept/block, challenge invite/respond, start, leave, abandon) only appear on the other device after leaving and re-entering the affected screen, and explicitly requested real-time reflection via the "snapshot listener (canonical)" approach for all affected screens, with the challenge lobby level label handled by the no-server-change hybrid.

## Goal

Make the affected social/challenge screens reflect server-owned state changes in real time by subscribing to Firestore document/query snapshots for **reads only**, while all writes continue to flow exclusively through the existing authenticated Cloud Functions callables. The client renders trusted values it reads back; it never calculates or writes backend-owned state, preserving the trust boundary.

## Key Finding (why this is client-only)

Firestore Rules already permit authenticated client reads on exactly the documents these screens need, and deny all client writes (`create, update, delete: if false`):

- `users/{uid}/friends`, `users/{uid}/friendRequests`, `users/{uid}/blockedUsers` — owner `get`/`list` (`limit <= 30`). Docs already carry `nickname`, `displayName`, `avatarInitials`, `direction`, `status`, so they render without a cross-user join.
- `challengeInvitations/{inviteId}` — `get`/`list` when the caller is `ownerUid` or `recipientUid`.
- `challengeInstances/{challengeId}` — `get`/`list` when `request.auth.uid in resource.data.rosterUids`; `participants/{participantUid}` subcollection readable by snapshotted members. Participant docs carry `role`, `displayNameSnapshot`, `avatarInitials`.

The only value not directly snapshot-readable is the lobby/roster **level label** (`levelLabelSnapshot`), which the `getActiveChallenge` callable resolves by a live cross-user profile join the client is not permitted to perform. Per the routing decision this is handled by the **hybrid**: membership, role, headcount, and status render live from the snapshot; level labels are best-effort, seeded from the last `activeChallenge()`/callable result and left unchanged until the next callable refresh. No server change.

`leaveChallenge` and `abandonChallenge` mutate the same `challengeInstances`/`participants` documents, so they are covered automatically once the lobby and progress screens subscribe to the instance snapshot — no separate mechanism.

## Allowed Scope

- Add snapshot/stream read methods to the client repositories and their interfaces, leaving existing `Future` write/read methods intact:
  - `FriendsRepository.watchFriendsOverview(...)` backed by the three owner subcollections' `.snapshots()`.
  - `ChallengeRepository.watchActiveChallenge()` and `watchInvitations()` backed by `challengeInstances` + `participants` and `challengeInvitations` `.snapshots()`.
- Rewire the affected screens from one-shot `initState` loads to stream subscriptions (via existing `ChangeNotifier` controllers or `StreamBuilder`), keeping the same read models and copy.
- Focused Flutter widget/unit tests using fake Firestore streams proving that a simulated remote mutation updates the screen without re-navigation, plus analyze and diff hygiene.

## Forbidden Scope

- No changes to `firestore.rules`, `firestore.indexes.json`, `firebase.json`, or anything under `functions/`.
- No Firebase deploy, emulator fixture seeding of production, secrets, or dependency additions.
- No client writes of backend-owned values; writes stay on the existing callables. No changes to XP/level/rank/streak/leaderboard/subscription/expert-plan logic.
- No changes to unrelated screens, the active `home-you-state-stability` capsule, or any concurrent isolated work.
- Level label is not denormalized server-side in this capsule (hybrid decision).

## Exact Target Files

- `implementation/mobile/runiac_app/lib/features/friends/domain/repositories/friends_repository.dart`
- `implementation/mobile/runiac_app/lib/features/friends/data/firebase_friends_repository.dart`
- `implementation/mobile/runiac_app/lib/features/friends/data/friends_owner_list_reader.dart`
- `implementation/mobile/runiac_app/lib/features/friends/data/static_friends_repository.dart` (stream stub for parity)
- `implementation/mobile/runiac_app/lib/features/friends/presentation/friends_screen_controller.dart`
- `implementation/mobile/runiac_app/lib/features/friends/presentation/friends_screen.dart` (only if subscription wiring requires it)
- `implementation/mobile/runiac_app/lib/features/challenge/domain/repositories/challenge_repository.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/data/firebase_challenge_repository.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/data/static_challenge_repository.dart` (stream stub for parity)
- `implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_lobby_screen.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_invitations_screen.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_progress_screen.dart`
- Focused tests under `implementation/mobile/runiac_app/test/` (friends + challenge realtime), and this capsule plus one append-only CURRENT.md routing line.

## Required Tests

- Friends: fake Firestore stream emits an added incoming request / accepted friend / new block → controller notifies and the screen shows it without re-entry.
- Challenge invitations: fake stream emits a new/removed PENDING invitation → list updates live.
- Challenge lobby/progress: fake stream emits a roster/participant/status change (join, withdraw, start, leave, abandon) → roster, headcount, and status update live; level label stays at its seeded best-effort value.

## Required Validation

```bash
cd /Users/leejinseo/Desktop/FYP_Runiac/implementation/mobile/runiac_app && flutter analyze --no-pub
cd /Users/leejinseo/Desktop/FYP_Runiac/implementation/mobile/runiac_app && flutter test --no-pub <focused realtime + affected existing test files>
cd /Users/leejinseo/Desktop/FYP_Runiac && git diff --check
```

## Required Evidence

- Focused test RED→GREEN output for the new realtime tests.
- `flutter analyze --no-pub` clean for touched paths.
- Note confirming no `functions/`, Rules, index, or dependency changes in the diff.

## Rollback Conditions

- If any target read requires a Rules or index change to satisfy a snapshot query, stop and re-route (would cross into Backend Guarded Lane).
- If subscription lifecycle causes leaked listeners or duplicate callable writes, revert the affected screen to its one-shot load.

## Exit Criteria

- [ ] Stream read methods added; existing write/read Futures untouched.
- [ ] Affected screens subscribe and update live without re-navigation.
- [ ] Focused realtime tests, analyze, and diff hygiene pass.
- [ ] Diff contains no `functions/`, Rules, index, or dependency changes.
- [ ] CURRENT.md routing line added; snapshot updated if state changed.
