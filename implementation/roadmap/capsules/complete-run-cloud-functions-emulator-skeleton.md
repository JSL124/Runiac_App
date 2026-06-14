# complete-run-cloud-functions-emulator-skeleton

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Backend Guarded Lane implementation capsule.

## Status

Status: Active on 2026-06-14 Asia/Singapore.

## Required Agent Chain

```text
A0_ORCH -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Implement the first emulator-only Cloud Functions `completeRun` skeleton that accepts raw run completion input, validates it on the backend boundary, writes backend-owned completion artifacts in Firestore emulator, and returns a read-only completion result.

## Approved Scope

- Cloud Functions TypeScript skeleton under `functions/`.
- Firebase v2 callable `completeRun`.
- Auth-required request boundary.
- Raw run payload validation.
- Protected field rejection.
- Deterministic idempotency by `uid + clientRunSessionId`.
- Emulator-only writes to:
  - `activities/{deterministicActivityId}`
  - `runSummaries/{deterministicSummaryId}`
  - `progressionEvents/{deterministicEventId}`
- Deferred/no-advantage progression event:
  - `xpDelta: 0`
  - `countsTowardLeaderboard: false`
  - status/reason indicates the formula is deferred.
- Emulator tests.
- Minimal emulator documentation updates if needed.

## Forbidden Scope

- No FlutterFire client wiring.
- No Firebase deploy.
- No production project config.
- No `.firebaserc`.
- No secrets, service accounts, API keys, or `.env*`.
- No real XP, streak, level, rank, weekly XP, monthly XP, or leaderboard formula.
- No leaderboard aggregation.
- No `leaderboardSnapshots` writes.
- No user profile XP/streak/level/rank/leaderboard writes.
- No subscription privilege logic.
- No expert/admin privilege logic.
- No client-side mutation of backend-owned fields.
- No phase advancement.

## Contract Source

This capsule implements the first emulator-only skeleton from `implementation/roadmap/capsules/complete-run-progression-contract-plan.md`.

## Required Validation

```bash
cd functions && npm test
cd tests/firebase-rules && npm test
git diff --check
./tools/governance-ci/run-all-checks.sh
git status --short --untracked-files=all
```

If dependency installation is required, it must remain local/package-scoped and must not create production Firebase config, secrets, `.firebaserc`, or deployment state.

## Done When

- [ ] `completeRun` callable is implemented as emulator-only Functions code.
- [ ] Missing auth fails.
- [ ] Valid minimal payload writes backend-owned activity, summary, and deferred progression event.
- [ ] Missing required fields fail.
- [ ] Invalid timestamp ordering fails.
- [ ] Protected fields are rejected.
- [ ] Duplicate `clientRunSessionId` is idempotent.
- [ ] Premium user receives no XP/rank/leaderboard advantage.
- [ ] Precise GPS/private route traces are rejected or not persisted.
- [ ] Existing Firestore rules tests still pass or any blocker is explicitly recorded.
- [ ] No forbidden production config, deploy, FlutterFire, secrets, or backend-owned client mutation is introduced.
