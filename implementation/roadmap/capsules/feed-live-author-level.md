# feed-live-author-level

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Mode / Type

Mode: IMPLEMENTATION_MODE (explicit user routing and implementation request). This document was written on branch `JSL124/feed-live-author-level` on 2026-07-21 Asia/Singapore to record work already implemented in the working tree.

Type: Backend Guarded Lane capsule (a new read-only Cloud Functions callable plus display-only Flutter client wiring), emulator-first per ADR-002, lane classification per ADR-003.

## Problem

Feed post/comment author level (`authorLevelLabel`) is a denormalized string frozen at publish time (`functions/src/feed/contracts.ts:113`) and is never refreshed afterward — there is no updater, no trigger, and no backfill anywhere in the codebase. `firestore.rules:851` denies all client writes to `feedPosts`, so even a well-intentioned client could not repair a stale label itself.

Verified in production for uid `RtEOc6ujVKWtOAzBTwBVfgqoGLD2` (live Level 6): its six posts stored Level 2, Level 4, Level 4, and three with the field absent entirely, rendering as `Lv.6 / Lv.6 / Lv.2 / Lv.6 / Lv.4 / Lv.4` in a single feed. The three absent-field posts looked correct only by accident: `feed_display_models.dart` substituted the live viewer profile for the viewer's OWN posts, masking the same underlying staleness that was visible on every other post.

## Decision

Show the author's CURRENT level, for both posts and comments, with NO data migration. The stored `authorLevelLabel` field is kept exactly as-is and becomes an offline/fallback cache rather than the source of truth.

## Constraint

`firestore.rules:756` makes `userProfiles/{uid}` owner-read-only (`allow read: if isOwner(uid);`), and no friend-readable projection of level exists anywhere in the schema. A viewer therefore cannot read another user's live level directly from Firestore under any existing rule — the value must be resolved server-side, per-request, with its own authorization check.

## Implementation (already present in the working tree)

A new read-only callable, `getFeedAuthorLevels`, in `functions/src/feed/authorLevels/core.ts` and `functions/src/feed/authorLevels/callable.ts`, registered in `functions/src/index.ts` and deployed to region `asia-southeast1`.

- Reuses the already-shipped live-resolution pattern from `functions/src/challenge/challengeLobbyCore.ts:872-894` (`readParticipantLevels` / `participantLevelLabel`): read the trusted `userProfiles/{uid}` document per requested author, prefer a non-empty `levelLabel`, else fall back to `Lv.{level}` from the numeric `level`, else an empty string.
- Authorizes per requested uid using the existing `evaluateFeedRelationship` (`functions/src/feed/relationship.ts`): the caller's own uid is always permitted; any other uid is permitted only when the relationship resolves to `allowed_owner` or `allowed_friend`.
- Request shape: `{ uids: string[] }`, deduplicated and capped at 50 (`MAX_UIDS`); more than 50 unique uids is rejected with `invalid-argument`.
- Response shape: `{ levels: { [uid]: { levelLabel: string; levelProgressPercent: number } } }`. Unauthorized uids are silently omitted from the response rather than causing the whole call to error. A missing/unreadable profile yields `levelLabel: ""` and `levelProgressPercent: 0`. `levelProgressPercent` is clamped to `[0, 100]`.
- Zero Firestore writes, zero `firestore.rules` changes, zero index changes, no new dependencies.
- Deliberately no App Check enforcement, for parity with `readFeedThumbnail` and the existing friends/challenge callables, none of which enforce it either.

## Client Rule (display-only)

- `FeedAuthorLevelResolver` (`implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_author_level_resolver.dart`) is a session-scoped cache: it looks up already-resolved uids from an in-memory map and calls the new `FeedDataPort.fetchAuthorLevels` port method only for uids not yet cached, chunking requests at 50 to match the callable's cap.
- Any failure from the port (offline, permission denial, the callable not yet being deployed) is swallowed entirely — nothing is cached for that attempt, and callers keep using the stored, possibly-stale `authorLevelLabel`. The Feed must always be able to paint even if this resolver never resolves anything.
- Overlays are wired at `feed_timeline_page_loader.dart` and `feed_comment_page_loader.dart`.
- `authorLevelProgressFraction` on the display models is nullable so that "unresolved" stays distinct from a genuine `0.0` progress value.
- An empty resolved label never overwrites a stored one — the stored `authorLevelLabel` remains the floor, and a live resolution only replaces it when the live label is non-empty.
- The client renders only server-produced values. It never computes level, XP, or progress itself.

## Validation Evidence

All commands below were run by the orchestrator on this branch.

- `functions`: `npm test` — 361/361 pass. `npm run test:feed` — 42/42 pass, including the export-surface assertion. A separate 5/5 suite also passed. `npm run build` — clean.
- Flutter: `flutter analyze --no-pub` — clean. `flutter test --no-pub` — 1812/1812 pass.

## Production Deploy Record

Supersedes the "NOT deployed" status this document carried when it was first written: the user
explicitly authorized a scoped production deploy on 2026-07-21 Asia/Singapore, limited to
`functions:getFeedAuthorLevels`, and it was executed against `runiac-fypp`.

`getFeedAuthorLevels` was a **create**, not an update — the function had never existed in
production. It reports `ACTIVE`, v2 callable, `asia-southeast1`, `nodejs22`, with
`updateTime 2026-07-21T13:49:18Z`. No other function was deployed, and no rules or index was
released.

Post-deploy verification against production, as the real owner account
(uid `RtEOc6ujVKWtOAzBTwBVfgqoGLD2`, live Level 6), via a short-lived custom token exchanged for
an ID token:

| Request | Result |
| --- | --- |
| own uid | HTTP 200 — `{ levelLabel: "Level 6", levelProgressPercent: 50 }` |
| duplicate uid | HTTP 200 — one entry (dedup confirmed) |
| unrelated uid | HTTP 200 — omitted from `levels`, not an error |
| empty array | HTTP 200 — `{ levels: {} }` |
| 51 uids | HTTP 400 — `INVALID_ARGUMENT`, "At most 50 uids may be requested." |
| unauthenticated | HTTP 401 — `UNAUTHENTICATED`, "Authentication is required." |

`Level 6` is the live value, versus the `Level 2` / `Level 4` / absent labels stored on that
account's six posts — so the callable returns exactly the value the Feed must now render.

Not yet verified: the rendered Feed screen itself. The account uses Google SSO, so the simulator
could not be signed in without the user's Google credentials; the client overlay is covered by
the Flutter suite rather than by a real-screen capture. Real-screen acceptance remains
user-owned and is not claimed here.

## Allowed Scope

Documentation only for this task. The following files already exist in the working tree and are the subject of this capsule record, not authored by this documentation pass:

- `functions/src/feed/authorLevels/core.ts`
- `functions/src/feed/authorLevels/callable.ts`
- `functions/test/feedAuthorLevels.test.ts`
- `functions/src/index.ts` (registers the new export)
- `functions/test/feedCallableSurface.test.ts` (export-surface allow-list updated for the new export)
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_author_level_resolver.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_test_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_repository.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_timeline_page_loader.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/comments/feed_comment_page_loader.dart`
- `implementation/mobile/runiac_app/lib/features/feed/domain/models/feed_display_models.dart`
- `implementation/mobile/runiac_app/test/feed_display_models_test.dart`
- `implementation/mobile/runiac_app/test/feed_author_level_overlay_test.dart`
- `implementation/mobile/runiac_app/test/feed_author_level_resolver_test.dart`

This documentation pass itself is limited to:

- `implementation/roadmap/capsules/feed-live-author-level.md` (this file, new)
- `implementation/roadmap/CURRENT.md` (append-only routing entry, plus one in-place correction of a now-verified-false prior statement)
- `tools/governance-ci/check-diff-hygiene.sh` and `tools/governance-ci/check-pre-scaffold-scope.sh` (routed-capsule allowlist entries only, added because `run-all-checks.sh` failed without them)

## Forbidden Scope

- Any production `runiac-fypp` deploy without separate authorization.
- Any `firestore.rules` or Firestore index change.
- Any backfill or mutation of existing `feedPosts` documents.
- Any change to publish-time behaviour in `functions/src/feed/contracts.ts` or `functions/src/feed/publish/core.ts`.
- Any client-side computation of backend-owned values (level, XP, progress).
- New dependencies or secrets.
- Any edit or staging inside the isolated `adaptive-character-guidance` worktree.
- Touching, reverting, staging, describing, or "fixing" the unrelated concurrent work in `lib/features/friends/`, `lib/features/moderation/`, `lib/core/widgets/runiac_sheet_scaffold.dart`, or `test/report_user_sheet_test.dart`.

## Exact Target Files

Same list as Allowed Scope above.

## Required Tests

```bash
cd functions && npm run build
cd functions && npm test
cd functions && npm run test:feed
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test --no-pub
```

## Required Validation

- ADR-002 emulator-first validation, against the Functions/Firestore emulators, before any deploy. The scoped production deploy recorded above happened only after that evidence and only under explicit user authorization.
- A11_FIREBASE_IMPL for the server-owned callable and its per-uid authorization; A10_FLUTTER_IMPL for the display-only client wiring; A13_SECURITY_RULES to confirm no `firestore.rules` change was required and that `userProfiles/{uid}` owner-read-only stays intact; A6_REVIEW for boundary/consistency; A12_QA_TEST for the emulator/analyze/test runs; A8_OUTPUT_CHECKER before any readiness claim.
- `./tools/governance-ci/run-all-checks.sh` and `git diff --check` must pass with only this capsule's files (plus the pre-existing unrelated concurrent work, left untouched) in the diff.

## Rollback Conditions

- Any evidence that `getFeedAuthorLevels` returns a level for a uid the caller is not an owner or friend of.
- Any evidence that the client computes, infers, or writes level/XP/progress locally rather than reading the server-returned value.
- Any `firestore.rules` or index change introduced under this capsule's name.
- Any modification to an unrelated capsule's files, or any reordering of an existing `CURRENT.md` routing bullet.

## Exit Criteria

- [x] Implementation files listed above are present and match this record.
- [x] Required tests passing (Functions build + main suite + feed suite + a separate 5/5 suite; Flutter analyze + full suite).
- [x] `implementation/roadmap/CURRENT.md` updated (append-only) with this capsule's routing bullet, plus the in-place correction of the now-verified-false `feedCallableSurface` staleness claim recorded under `plan-completion-signal`.
- [x] Governance allowlist entries added to `tools/governance-ci/check-diff-hygiene.sh` and `tools/governance-ci/check-pre-scaffold-scope.sh`, and `run-all-checks.sh` passing.

## Stop State

Stop at `Ready for commit`. No commit or push is authorized by this documentation task.
