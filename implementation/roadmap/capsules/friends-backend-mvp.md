# friends-backed-mvp

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly delegated Backend Guarded Lane implementation under ADR-002 Emulator First and ADR-003.

## Status

Backend deployed to `runiac-fypp` on 2026-07-13 Asia/Singapore after explicit user authorization. The final callable, Rules/Feed emulator, governance, and production smoke checks passed: all 40 expected Functions are ACTIVE, the Friends indexes are present, and unauthenticated nickname/Friends callable probes reach the deployed endpoint and return `UNAUTHENTICATED` rather than 404. Luna separately owns the listed Flutter implementation and test verification.

## Goal

Deliver the integrated backed MVP Friends contract: Unicode-safe nickname identity and migration, authenticated callable lifecycle transitions, rate/cooldown limits, reciprocal-friend and directional-block authority, owner-only social reads, Firestore Rules/index enforcement, and Luna's callable-backed Friends/Profile client seam.

## Allowed Scope

- `functions/src/friends/**`, `functions/test/friendsCore.test.ts`, and the Friends export appended after existing `functions/src/index.ts` work.
- `functions/package.json` only to add `test:friends`, preserving the existing concurrent Challenge script hunk.
- `firestore.rules`, `firestore.indexes.json`, and scoped Firestore Rules/Feed fixtures under `tests/firebase-rules/`.
- Luna-owned Flutter integration only on these exact paths: `implementation/mobile/runiac_app/lib/app.dart`, `lib/main.dart`, `lib/core/firebase/runiac_firebase_bootstrap.dart`, `lib/features/account/data/firestore_user_profile_persistence_repository.dart`, `lib/features/account/domain/repositories/user_profile_persistence_repository.dart`, `lib/features/account/presentation/account_edit_profile_screen.dart`, `lib/features/friends/data/firebase_friends_repository.dart`, `lib/features/friends/data/static_friends_repository.dart`, `lib/features/friends/domain/models/friends_read_model.dart`, `lib/features/friends/domain/repositories/friends_repository.dart`, `lib/features/friends/presentation/friends_screen.dart`, `lib/features/friends/presentation/friends_action_sheets.dart`, `lib/features/friends/presentation/friends_screen_controller.dart`, `lib/features/friends/presentation/widgets/friends_rows.dart`, `lib/features/home/presentation/home_tab.dart`, and `lib/features/shell/runiac_shell.dart`.
- Luna-owned Flutter tests only: `test/firebase_friends_repository_test.dart`, `test/friends_backed_ui_test.dart`, `test/friends_static_ui_test.dart`, `test/user_profile_persistence_repository_test.dart`, `test/backend_owned_contract_test.dart`, and `test/onboarding_generated_plan_session_activation_test.dart`. `implementation/mobile/runiac_app/DESIGN.md` may change only for Friends/Profile backed-MVP contract and component documentation.
- The shared Friends backend contract artifact and this capsule, plus one append-only CURRENT routing line.

## Forbidden Scope

- No Flutter edits outside Luna's exact paths above, no direct client social writes, no notifications, and no XP/rank/streak/leaderboard/subscription/expert-plan mutation.
- No changes to `functions/src/challenge/**` or the pre-existing Challenge portion of `functions/src/index.ts` or `functions/package.json`.
- No deploy, Firebase initialization, secrets, staging, commit, production project, or real user data.
- Do not rewrite or delete the historical static Friends shell/refinement capsules. This capsule supersedes their runtime behavior only: the backed product has Friends / Search / Requests / Blocked, removes Suggested, and uses Firebase callable/list integration.

## Contract Summary

- All Friends callables require Firebase Authentication. `searchFriends` and `checkNicknameAvailability` share the 10/minute neutral discovery bucket.
- `nicknameClaims/{n1_sha256Hex}` is path-safe; canonical text remains stored for collision checking. Callable-owned profile identity is NFC nickname `displayName` plus Unicode-safe `avatarInitials`.
- Requests are mirrored at `users/{uid}/friendRequests/{otherUid}`. Duplicate same-direction sends are unchanged; crossed sends are `STALE_SOCIAL_STATE`; acceptance is explicit.
- Sends enforce 3/minute, 10/rolling-24-hour, and 25 outstanding. Cancel, decline, and remove cooldowns are respectively 24 hours, 7 days, and 24 hours.
- Block atomically creates the actor's directional block and removes both friend and pending-request directions. It writes no social notification.
- Friends, requests, and blocks are owner-only reads, direct client writes are denied, and list queries require `limit(30)` with canonical sort order. Required indexes cover two-key Friends/Blocked ordering and status/direction Requests ordering.
- Feed access remains read-time reciprocal-friend plus either-direction-block enforcement; the focused Rules test proves a friend read before block state and denial after it.
- Flutter uses `checkNicknameAvailability` then `upsertNickname`; it directly creates/updates only non-identity profile fields. Owner lists use the exact required sort and `limit(30)` shapes.

## Required Validation

```bash
cd /Users/leejinseo/Desktop/FYP_Runiac/functions && npm run build
cd /Users/leejinseo/Desktop/FYP_Runiac/functions && npm run test:friends
cd /Users/leejinseo/Desktop/FYP_Runiac && GCLOUD_PROJECT=demo-runiac-friends FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 ./tests/firebase-rules/node_modules/.bin/firebase emulators:exec --only firestore --project demo-runiac-friends "cd tests/firebase-rules && node --test --test-concurrency=1 firestore.rules.test.mjs friends.firestore.rules.test.mjs feed.firestore.rules.test.mjs"
cd /Users/leejinseo/Desktop/FYP_Runiac && git diff --check
```

## Done When

- [x] Functions build and `test:friends` pass after the final rerun.
- [x] Profile identity, Unicode migration, quotas, cooldown boundaries, idempotency, and block reset are proven by the callable emulator suite.
- [x] Firestore owner-list/query limits, cross-user denial, direct social/claim write denial, composite indexes, and post-block Feed revocation are proven by Rules tests.
- [x] Contract artifact and Luna handoff are current.
- [x] Only the scoped backend, Rules/indexes, tests, capsule, and governance allowlist participate in this backend release; unrelated Flutter work remains separately owned and unstaged.
