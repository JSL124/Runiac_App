# running-activity-history-user-link

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's `ulw-loop` execution request.

Type: Flutter + Firebase guarded implementation capsule.

## Status

Status: In progress locally.

## Goal

Connect Running Activity History to the authenticated runner by reading owner-scoped `runSummaries` where `ownerUid == currentUser.uid`, while preserving static fallback, current-session completed-run overlay behavior, and backend-owned write boundaries.

## Scope

Allowed implementation files:

- `firestore.indexes.json`
- `firestore.rules` only if rules tests prove a minimal owner-read fix is required
- `tests/firebase-rules/**`
- `functions/test/completeRun.test.ts` only if existing tests do not already prove owner-scoped writes and uid-scoped deterministic ids
- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/you/**`
- Focused Flutter tests under `implementation/mobile/runiac_app/test/`

Allowed workflow artifacts:

- `.omo/plans/running-activity-history-user-link.md`
- `.omo/drafts/running-activity-history-user-link.md`
- `.omo/evidence/**`
- `.omo/ulw-loop/**`

## Required Boundaries

- Activity History reads must be scoped to the authenticated user.
- The intended Firestore query shape is `runSummaries` filtered by `ownerUid == currentUser.uid`, ordered by `endedAt` descending, and bounded by a small limit.
- Flutter must keep static fallback behavior when Firebase/Auth/history loading is unavailable.
- Newly completed in-session runs must remain visible immediately and should be deduplicated against repository rows by `activityId`.
- Activity History summary navigation must keep the XP update action hidden.
- Client code must not directly write `runSummaries`, `progressionEvents`, XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, expert plan publication state, or validated activity contribution state.
- `completeRun` remains the run completion write path.

## Forbidden Scope

- No Firestore rules/index deployment.
- No Cloud Functions production deploy.
- No `firebase init`.
- No `flutterfire configure`.
- No `.firebaserc`.
- No secrets, service accounts, API keys, or Firebase config files.
- No route trace upload.
- No GPS sample persistence.
- No shared route generation.
- No background tracking.
- No Auto Pause or Moving Time.
- No XP, streak, level, rank, weekly XP, monthly XP, or leaderboard formula.
- No leaderboard aggregation.
- No premium entitlement logic.
- No expert-plan publication logic.
- No Phase 02 selection.
- No screenshot/manual QA requirement; the user will handle manual visual confirmation.

## Required Validation

- Focused Flutter RED to GREEN tests for repository-backed Activity History.
- Focused Flutter repository mapper tests for owner scoping, fallback, malformed data, grouping, and recent-run limits.
- Focused bootstrap wiring tests.
- Firebase rules tests proving owner-only `runSummaries` reads and denied cross-owner/client writes.
- Function characterization tests only if existing `completeRun` tests do not already prove owner-scoped writes and uid-scoped deterministic ids.
- `git diff --check`.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`.
- `cd implementation/mobile/runiac_app && flutter test`.
- `cd tests/firebase-rules && npm test`.
- `cd functions && npm test`.
- `./tools/governance-ci/run-all-checks.sh`.

## Done When

- [ ] Authenticated users can see their own completed-run scalar history from `runSummaries`.
- [ ] Cross-user history reads and client writes to `runSummaries` are denied by tests.
- [ ] Unauthenticated/non-Firebase paths remain safe and use static fallback.
- [ ] Current-session completed runs still appear immediately and dedupe by `activityId`.
- [ ] History-opened summaries keep `View XP Update` hidden.
- [ ] No client writes backend-owned progression, ranking, entitlement, publication, or validation fields.
- [ ] Final automated validation is captured with exact evidence.
