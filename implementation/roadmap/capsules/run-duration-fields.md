# run-duration-fields

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's `ulw-loop` execution request.

Type: Flutter + Firebase guarded implementation capsule.

## Status

Status: Locally complete. Reconciled on 2026-07-07 Asia/Singapore from existing implementation and test evidence.

Reconciliation note:

- The roadmap previously still listed this capsule as "In progress locally".
- Existing source now carries `durationSeconds`, `activeDurationSeconds`, `elapsedWallSeconds`, and `pausedDurationSeconds` through the Flutter completion payload, request adapter, Cloud Functions validation, `activities`, and `runSummaries`.
- Existing Functions and Flutter tests cover paused-run acceptance, malformed duration rejection, callable HTTP surface persistence, active-duration summary semantics, and legacy duration compatibility.
- This reconciliation did not run validation commands; it updates roadmap state from inspected source and existing test coverage only.

## Goal

Split run completion duration into active time, elapsed wall-clock time, and paused/rest time so completed runs with legitimate breaks can sync through `completeRun` instead of being rejected by wall-clock duration validation.

## Agent Chain

`A0_ORCH -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Scope

Allowed implementation files:

- `functions/src/run/runCompletionTypes.ts`
- `functions/src/run/validateRunPayload.ts`
- `functions/src/run/completeRun.ts`
- `functions/test/completeRun.test.ts`
- `functions/test/completeRunCallableSurface.test.ts`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/local_run_completion_payload.dart`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/run_completion_request_adapter.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/controllers/run_tracking_controller.dart`
- Focused Flutter tests under `implementation/mobile/runiac_app/test/` only when needed to prove the payload/adapter contract.

Allowed workflow artifacts:

- `.omo/plans/run-duration-fields.md`
- `.omo/drafts/run-duration-fields.md`
- `.omo/evidence/**`
- `.omo/ulw-loop/run-duration-fields/**`

## Required Boundaries

- Preserve legacy `durationSeconds` as the active/moving duration compatibility alias.
- Add and persist `activeDurationSeconds`, `elapsedWallSeconds`, and `pausedDurationSeconds`.
- Keep summary display duration and average pace based on active duration.
- Backend validation must reject inconsistent duration math before Firestore writes.
- Activity validation remains trusted backend-owned logic.
- Existing activity/history readers must remain compatible with old `durationSeconds`-only records.

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
- No Auto Pause or Moving Time engine implementation.
- No XP formula, streak formula, level formula, rank formula, weekly XP, monthly XP, leaderboard score, or leaderboard aggregation.
- No premium entitlement logic.
- No expert-plan publication logic.
- No Phase 02 selection.

## Required Validation

- RED to GREEN Functions tests for paused-run acceptance and malformed duration rejection.
- Callable HTTP emulator surface coverage proving Firestore emulator writes all four duration fields.
- Focused Flutter payload/adapter validation.
- `git diff --check`.
- `cd functions && npm test`.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`.
- `cd implementation/mobile/runiac_app && flutter test`.
- `./tools/governance-ci/run-all-checks.sh`.

## Done When

- [x] A paused/rested run with active duration smaller than wall-clock elapsed duration is accepted by `completeRun`.
- [x] Malformed duration payloads are rejected before any Firestore write.
- [x] Firestore emulator activity and summary documents contain `durationSeconds`, `activeDurationSeconds`, `elapsedWallSeconds`, and `pausedDurationSeconds`.
- [x] Existing display duration and pace remain active-duration based.
- [x] Existing readers/tests remain compatible with old `durationSeconds`-only records or responses.
- [x] No client writes backend-owned progression, ranking, entitlement, publication, or validation contribution fields.
- [x] Route trace/private GPS sample persistence remains rejected/not persisted.
- [x] Final automated validation is captured in existing artifacts; no validation rerun was performed during this roadmap reconciliation.
