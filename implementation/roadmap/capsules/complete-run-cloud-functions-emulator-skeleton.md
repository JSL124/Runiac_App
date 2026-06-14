# complete-run-cloud-functions-emulator-skeleton

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Backend Guarded Lane implementation capsule.

## Status

Status: Closed on 2026-06-14 Asia/Singapore.

## Required Agent Chain

```text
A0_ORCH -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Implement the first emulator-only Cloud Functions `completeRun` skeleton that accepts raw run completion input, validates it on the backend boundary, writes backend-owned completion artifacts in Firestore emulator, and returns a read-only completion result.

Closure reconciliation:

- M2 backend emulator skeleton is complete at `4fcbf96 feat(functions): add complete run emulator skeleton`.
- M3 Run Repository Integration is complete at `a45b007 feat(run): add repository completion integration`.
- M3 async completion hardening is complete at `68bebf6 fix(run): harden async completion flow`.
- M5 FlutterFire emulator-only wiring is complete at `ff345e3 feat(run): wire complete run emulator repository`.
- FlutterFire is currently allowed only for emulator-only `completeRun` wiring guarded by `RUNIAC_FIREBASE_EMULATOR=true`.
- Production Firebase remains forbidden.
- Real GPS/map tracking, real XP/streak/level formula, and leaderboard aggregation remain not done.

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

- No FlutterFire production config or production Firebase wiring.
- No FlutterFire client wiring outside the completed emulator-only `completeRun` path guarded by `RUNIAC_FIREBASE_EMULATOR=true`.
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

- [x] `completeRun` callable is implemented as emulator-only Functions code.
- [x] Missing auth fails.
- [x] Valid minimal payload writes backend-owned activity, summary, and deferred progression event.
- [x] Missing required fields fail.
- [x] Invalid timestamp ordering fails.
- [x] Protected fields are rejected.
- [x] Duplicate `clientRunSessionId` is idempotent.
- [x] Premium user receives no XP/rank/leaderboard advantage.
- [x] Precise GPS/private route traces are rejected or not persisted.
- [x] Existing Firestore rules tests still pass.
- [x] No forbidden production config, deploy, secrets, or backend-owned client mutation is introduced.
- [x] M5 emulator-only FlutterFire repository wiring is complete with static fallback preserved.
