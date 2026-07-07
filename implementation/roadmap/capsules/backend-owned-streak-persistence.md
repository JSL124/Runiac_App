# backend-owned-streak-persistence

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's `ulw-loop` execution request.

Type: Flutter + Firebase guarded implementation capsule.

## Status

Status: Locally complete. Reconciled on 2026-07-07 Asia/Singapore from existing implementation and test evidence.

Reconciliation note:

- The roadmap previously still listed this capsule as "In progress locally".
- Existing source now includes backend-owned streak calculation in `functions/src/progression/streakCalculator.ts`, plan-bounded trusted streak reconstruction in `functions/src/progression/planBoundedStreakState.ts`, and trusted `completeRun` writes to `userProfiles/{uid}` plus `progressionEvents/{eventId}` in `functions/src/run/completeRun.ts`.
- Existing tests cover consecutive-day increment, same-day no double increment, duplicate idempotency, missed-day reset, late older sync non-regression, plan-bounded streak recalculation, and client-write denial for backend-owned streak fields.
- This reconciliation did not run validation commands; it updates roadmap state from inspected source and existing test coverage only.

## Goal

Persist official running consistency streak state through the trusted `completeRun` Cloud Functions path after run validation, while keeping Flutter as a read-only display boundary for official streak values.

## Agent Chain

`A0_ORCH -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Scope

Allowed implementation files:

- `functions/src/run/completeRun.ts`
- `functions/src/run/runCompletionTypes.ts`
- `functions/src/run/validateRunPayload.ts`
- New focused helpers under `functions/src/progression/`
- `functions/test/completeRun.test.ts`
- `functions/test/completeRunCallableSurface.test.ts` only if the callable surface contract changes
- `firestore.rules`
- Focused Firebase rules tests under `tests/firebase-rules/`
- `implementation/mobile/runiac_app/lib/features/you/domain/models/user_progress_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/you_progress_surface.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- Focused Flutter tests under `implementation/mobile/runiac_app/test/`

Allowed workflow artifacts:

- `.omo/plans/backend-owned-streak-persistence.md`
- `.omo/drafts/backend-owned-streak-persistence.md`
- `.omo/evidence/**`
- `.omo/ulw-loop/backend-owned-streak-persistence/**`

## Required Boundaries

- Official streak calculation must happen only after backend run validation.
- Canonical current streak state may be backend-written to `userProfiles/{uid}` as `streakCount`, `lastStreakRunDate`, and `streakUpdatedAt`.
- Per-run streak audit may be backend-written to `progressionEvents/{eventId}` as `previousStreak`, `nextStreak`, `previousStreakRunDate`, and `nextStreakRunDate`.
- Duplicate `clientRunSessionId` completion must remain idempotent and must not double-increment streak.
- Premium users may update personal streak only as a non-competitive consistency metric; premium must still receive no XP, rank, leaderboard score, weekly XP, monthly XP, level, or competitive advantage.
- Flutter may display backend-produced streak labels or explicit pending/fallback state only.
- Firestore rules and callable payload validation must deny client attempts to write official streak/progression fields.

## Forbidden Scope

- No Firebase deploy, Firestore rules/index deploy, or Cloud Functions production deploy.
- No `firebase init`.
- No `flutterfire configure`.
- No `.firebaserc`.
- No secrets, service accounts, API keys, plist/resource config changes, or committed tokens.
- No route trace upload.
- No GPS sample persistence.
- No shared route generation.
- No background tracking.
- No XP formula, level formula, rank formula, weekly XP, monthly XP, leaderboard score, or leaderboard aggregation.
- No premium entitlement logic.
- No expert-plan publication logic.
- No Phase 02 selection.
- No client write or calculation of official `streak`, `streakCount`, `lastStreakRunDate`, `streakUpdatedAt`, or progression audit fields.

## Required Validation

- RED to GREEN Functions tests for first run, consecutive day increment, same-day no double increment, gap reset, duplicate idempotency, and premium no XP/rank/leaderboard advantage.
- Firestore rules tests proving clients cannot write `streak`, `streakCount`, `lastStreakRunDate`, `streakUpdatedAt`, or `progressionEvents`.
- Callable payload tests proving client-supplied `streak` and `streakCount` remain rejected.
- Flutter boundary tests proving official streak display uses backend-produced labels or pending/fallback state, not UI-derived activity-history math.
- `git diff --check`.
- `cd functions && npm test`.
- `cd tests/firebase-rules && npm test`.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`.
- Focused Flutter tests for backend contract and You tab streak display.
- `./tools/governance-ci/run-all-checks.sh`.

## Done When

- [x] Validated first run creates backend-owned streak state.
- [x] Validated consecutive-day run increments backend-owned streak state.
- [x] Same-day and duplicate session completions do not double-increment streak.
- [x] A missed-day gap resets or restarts streak according to the documented UTC-date rule.
- [x] `progressionEvents` contains previous/next streak audit fields.
- [x] Clients remain unable to write streak/progression fields directly.
- [x] Flutter no longer presents UI-derived activity-history math as official streak.
- [x] No XP/level/rank/leaderboard/premium entitlement behavior is added.
- [x] Final automated validation and ulw-loop evidence are captured in existing artifacts; no validation rerun was performed during this roadmap reconciliation.
