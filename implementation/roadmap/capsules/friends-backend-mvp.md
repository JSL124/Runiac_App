# friends-backed-mvp

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly delegated Backend Guarded Lane implementation under ADR-002 Emulator First and ADR-003.

## Status

Friends Functions and indexes were deployed to `runiac-fypp` on 2026-07-13 Asia/Singapore after explicit user authorization. The exact ten Friends/nickname Functions are ACTIVE in `asia-southeast1`, and the Friends composite plus collection-group indexes were accepted without deleting the pre-existing activity indexes. The backed Flutter client, profile persistence seam, focused tests, and simulator visual QA are complete. This run intentionally did not redeploy Firestore Rules: the stricter identity-write rules remain a coordinated client-cutover step because an installed legacy client would still write nickname identity fields directly.

## Goal

Deliver the integrated backed MVP Friends contract: Unicode-safe nickname identity and migration, authenticated callable lifecycle transitions, rate/cooldown limits, reciprocal-friend and directional-block authority, owner-only social reads, Firestore Rules/index enforcement, and Luna's callable-backed Friends/Profile client seam.

## Allowed Scope

- `functions/src/friends/**`, `functions/test/friendsCore.test.ts`, and the Friends export appended after existing `functions/src/index.ts` work.
- `functions/package.json` only to add `test:friends`, preserving the existing concurrent Challenge script hunk.
- `firestore.rules`, `firestore.indexes.json`, and scoped Firestore Rules/Feed fixtures under `tests/firebase-rules/`.
- Flutter integration under `implementation/mobile/runiac_app/lib/features/friends/**`, plus the bounded composition/profile paths in `lib/app.dart`, `lib/main.dart`, `lib/core/firebase/runiac_firebase_bootstrap.dart`, `lib/core/widgets/runiac_buttons.dart`, `lib/features/account/**`, `lib/features/home/presentation/home_tab.dart`, `lib/features/shell/runiac_shell.dart`, and `lib/features/you/presentation/widgets/you_segmented_control.dart`.
- Focused Flutter coverage in `test/auth_service_test.dart`, `test/backend_owned_contract_test.dart`, `test/firebase_friends_repository_test.dart`, `test/friends_backed_ui_test.dart`, `test/friends_static_ui_test.dart`, `test/onboarding_generated_plan_session_activation_test.dart`, and `test/user_profile_persistence_repository_test.dart`. `implementation/mobile/runiac_app/DESIGN.md` may change only for Friends/Profile backed-MVP contract and component documentation.
- The shared Friends backend contract artifact and this capsule, plus one append-only CURRENT routing line.

## Forbidden Scope

- No Flutter edits outside the bounded paths above, no direct client social writes, no notifications, and no XP/rank/streak/leaderboard/subscription/expert-plan mutation.
- No changes to `functions/src/challenge/**` or the pre-existing Challenge portion of `functions/src/index.ts` or `functions/package.json`.
- No broad Functions deploy, Firebase initialization, secrets, production data seeding, or unrelated service mutation. Production changes are limited to the exact ten Friends/nickname Functions and Friends indexes explicitly authorized by the user; Rules require the coordinated client cutover described in Status.
- Do not rewrite or delete the historical static Friends shell/refinement capsules. This capsule supersedes their runtime behavior only: the backed product has Friends / Search / Requests / Blocked, removes Suggested, and uses Firebase callable/list integration.

## Contract Summary

- All Friends callables require Firebase Authentication. `searchFriends` and `checkNicknameAvailability` share the 10/minute neutral discovery bucket.
- `nicknameClaims/{n1_sha256Hex}` is path-safe; canonical text remains stored for collision checking. Callable-owned profile identity is NFC nickname `displayName` plus Unicode-safe `avatarInitials`.
- Nickname rename fans the sanitized identity out atomically to at most 497 unique Friends/Requests/Blocked rows; 498 or more returns `NICKNAME_RENAME_TOO_LARGE` with zero writes. Collection-group `uid` indexes support this bounded lookup.
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
cd /Users/leejinseo/Desktop/FYP_Runiac/implementation/mobile/runiac_app && flutter analyze --no-pub lib/features/friends test/friends_backed_ui_test.dart test/firebase_friends_repository_test.dart
cd /Users/leejinseo/Desktop/FYP_Runiac/implementation/mobile/runiac_app && flutter test --no-pub test/auth_service_test.dart test/backend_owned_contract_test.dart test/firebase_friends_repository_test.dart test/friends_backed_ui_test.dart test/friends_static_ui_test.dart test/user_profile_persistence_repository_test.dart
cd /Users/leejinseo/Desktop/FYP_Runiac && git diff --check
```

## Done When

- [x] Functions build and `test:friends` pass after the final rerun.
- [x] Profile identity, Unicode migration, quotas, cooldown boundaries, idempotency, and block reset are proven by the callable emulator suite.
- [x] Firestore owner-list/query limits, cross-user denial, direct social/claim write denial, composite indexes, and post-block Feed revocation are proven by Rules tests.
- [x] Contract artifact and Luna handoff are current.
- [x] Backed Flutter Friends/Profile integration passes focused analyze/tests and fresh two-pass simulator visual QA.
- [x] Exact Friends/nickname Functions and indexes are deployed; unrelated project indexes were preserved.
- [ ] Deploy the stricter Firestore Rules only as a coordinated release after confirming no installed legacy client still performs direct nickname identity writes.
- [x] Only scoped Friends/Profile client files participate in the client commit; unrelated Challenge/Run work remains unstaged.
