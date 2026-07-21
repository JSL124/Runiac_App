# Capsule: Friends Live Level

Backend Guarded Lane (ADR-003), emulator-first (ADR-002). Explicitly user-routed on
2026-07-21 Asia/Singapore as a follow-up to `feed-live-author-level`.

## Problem

Every row on all four Friends tabs (Friends / Search / Requests / Blocked) rendered `Lv.0`.
The value was never data — it was a hardcoded presentation placeholder at
`implementation/mobile/runiac_app/lib/features/friends/presentation/widgets/friend_row_identity.dart:14-23`:

```dart
levelLabel: levelLabel.trim().isEmpty ? 'Lv.0' : levelLabel,
progressFraction: 0,
```

`FriendUserReadModel.levelLabel` exists but was always `''`, because
`friend_identity_mapper.dart:3-26` reads only `uid` / `nickname` / `displayName` /
`avatarInitials`, and no level field exists on the friend, request, or block edge documents
(`functions/src/friends/friendsDocuments.ts:24-45`) nor in the `searchFriends` result
(`functions/src/friends/friendsDiscovery.ts:43`). `RuniacLevelProfileBadge` already hides the
pill on an empty label (`runiac_level_profile_badge.dart:97`); the friends layer defeated that
by substituting `'Lv.0'` before the widget saw it, so the UI asserted a level that does not
exist.

## Decision

Resolve the level live from `userProfiles/{uid}` on every load, exactly as
`feed-live-author-level` does, so an admin-console XP/level correction or a user level-up is
reflected on the next load. Nothing is denormalized onto the edge documents.

## Authorization

`userProfiles/{uid}` is owner-read-only (`firestore.rules:756`), so resolution is server-side.
The user asked for levels on all four tabs; rather than adding an endpoint that resolves an
arbitrary uid, the policy is **"a uid present in one of my own lists"**:

- permitted if the uid is the caller's own, or an edge exists at
  `users/{caller}/friends/{uid}`, `users/{caller}/friendRequests/{uid}`, or
  `users/{caller}/blockedUsers/{uid}` — covering the Friends, Requests and Blocked tabs;
- the Search tab is served instead by enriching the existing `searchFriends` result, which
  already reads the candidate profile server-side, so no new exposure surface is created.

This is deliberately looser than the Feed's reciprocal-friendship rule and deliberately
tighter than "any signed-in caller, any uid".

## Implementation

- `functions/src/progression/profileLevelDisplay.ts` — shared `resolveProfileLevelDisplay`
  extracted so `getFeedAuthorLevels`, `getFriendLevels` and the `searchFriends` enrichment
  share one copy of the label/clamp rules. Logic is unchanged from the feed original:
  non-empty trimmed `levelLabel`, else `Lv.{trunc(level)}`, else `""`; percent clamped 0..100.
- `functions/src/friends/friendLevels/{core.ts,callable.ts}` — new read-only callable
  `getFriendLevels` (`asia-southeast1`, `withCallableErrorReporting`, no App Check, parity
  with the other friends callables). Request `{ uids: string[] }` deduped and capped at 50;
  response `{ levels: { uid: { levelLabel, levelProgressPercent } } }`, identical in shape to
  `getFeedAuthorLevels`; unauthorized uids omitted rather than erroring. Edge checks reuse the
  canonical `friendsPaths.ts` helpers rather than re-deriving document ids. Zero writes.
- `functions/src/friends/friendsDiscovery.ts` — the single returned result is spread with the
  level display fields read from the profile snapshot it had already fetched. Matching, block
  handling, rate limiting and every existing field are untouched, and no extra read is added.
- Flutter: `lib/core/formatting/level_label.dart` (`compactLevelLabel`, the same transform the
  feed uses), `friend_level_resolver.dart` (session cache, chunks at 50, swallows all errors),
  level population in `firebase_friends_repository.dart`, defensive level parsing in
  `friend_identity_mapper.dart`, a nullable `levelProgressFraction` on `FriendUserReadModel`,
  and removal of the `'Lv.0'` substitution so an unresolved level now renders no pill.

## Validation

- `functions`: `npm run build` clean; `npm test` 383/383 pass (up from 361 — 22 new tests);
  `npm run test:feed` 42/42 pass; moderation suite 5/5 pass.
- Flutter: `flutter analyze --no-pub` clean; `flutter test --no-pub` 1817/1817 pass.
- `getFeedAuthorLevels` behaviour is unchanged by the shared-helper extraction; its existing
  tests pass unmodified.

## Forbidden

Any production `runiac-fypp` deploy without separate authorization; `firestore.rules` or index
changes; denormalizing a level onto friend/request/block edge documents; client-side
computation of level, XP or progress; new dependencies or secrets; nickname/displayName
fanout changes (out of scope — `updateNicknameFanout` already refreshes those); edits inside
the isolated `adaptive-character-guidance` worktree.

## Open Items

- `getFriendLevels` is new and `searchFriends` is an update to an already-deployed function;
  both need a separately authorized scoped deploy before the Friends tabs show real levels.
- The Requests tab `subtitleLabel` is still permanently blank in production (never written by
  the backend, never read by the mapper). Not addressed here.
