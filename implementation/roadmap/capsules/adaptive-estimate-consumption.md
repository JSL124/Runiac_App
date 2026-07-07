# adaptive-estimate-consumption

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's `ulw-loop` execution request.

Type: Flutter mobile read/display consumption capsule.

## Status

Status: Complete locally on 2026-07-07 Asia/Singapore.

## Goal

Consume the backend-owned `adaptivePlanEstimates/{uid}` document in Flutter as display-only state so generated duration-based planned runs can show a personalized distance estimate in the existing Run launch copy.

## Agent Chain

`A0_ORCH -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Scope

Allowed implementation files:

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/main.dart` if production repository composition requires it.
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart` if production repository composition requires it.
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/lib/features/plan/domain/models/adaptive_plan_estimate_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/plan/domain/repositories/adaptive_plan_estimate_repository.dart`
- `implementation/mobile/runiac_app/lib/features/plan/data/firestore_adaptive_plan_estimate_repository.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/adapters/generated_plan_you_display_adapter.dart`
- `implementation/mobile/runiac_app/test/adaptive_plan_estimate_read_model_test.dart`
- `implementation/mobile/runiac_app/test/adaptive_plan_estimate_consumption_test.dart`
- Existing tests only if directly extended: `implementation/mobile/runiac_app/test/plan_progress_read_model_test.dart`, `implementation/mobile/runiac_app/test/generated_planned_workout_start_flow_test.dart`, `implementation/mobile/runiac_app/test/run_tracking_flow_test.dart`, `implementation/mobile/runiac_app/test/you_generated_plan_session_activation_test.dart`, `implementation/mobile/runiac_app/test/backend_owned_contract_test.dart`

Allowed roadmap/workflow artifacts:

- `implementation/roadmap/capsules/adaptive-estimate-consumption.md`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `.omo/evidence/adaptive-estimate-consumption/**`
- `.omo/ulw-loop/adaptive-estimate-consumption/**`
- `.omo/plans/adaptive-estimate-consumption.md`

## Required Boundaries

- `CURRENT.md` and `implementation/roadmap/capsules/personalized-adaptive-estimate-learning.md` are authoritative for the completed backend-owned adaptive estimate learning capsule.
- Flutter may owner-read `adaptivePlanEstimates/{uid}` for display-only state.
- Flutter must not create, update, delete, reset, increment, or persist learned adaptive estimate fields.
- The read model must accept only the backend fields written by `functions/src/plan/adaptiveEstimate.ts`: `averageRecentPaceSecondsPerKm`, `completedRunCount`, `positivePaceRunCount`, `readinessBand`, `updatedAt`, and latest run metadata.
- Duration-run display distance must be derived as `round(durationMinutes * 60 / averageRecentPaceSecondsPerKm * 1000)` and displayed as a one-decimal kilometer label such as `~3.2 km`.
- Missing, malformed, non-positive pace, read failure, permission denial, offline, or `readinessBand == conservative` must produce no distance estimate and no target distance.
- Confidence mapping is display-only: `none` for unusable state, `low` for one positive pace sample or building readiness, `medium` for two or more positive pace samples, and no `high` in this MVP.
- Owner UID scoped loading, auth-owner clearing, stale async load suppression, and no cross-owner carryover are required.
- Completed planned-run extra-run messaging must continue to override estimate copy.

## Forbidden Scope

- No generated plan regeneration, workout schedule rewrite, onboarding plan generation change, AI/LLM plan adaptation, or server-side schedule change.
- No client write path to `adaptivePlanEstimates`, `planProgress`, XP, level, rank, leaderboard score, weekly/monthly XP, subscription privilege state, or expert plan publication state.
- No Firebase deploy, Firestore rules/index deploy, `firebase init`, `flutterfire configure`, `.firebaserc`, secrets, service accounts, API keys, plist/resource config, committed tokens, or production environment changes.
- No route trace upload, GPS sample persistence, shared route generation, background tracking, Auto Pause, Moving Time, Mapbox token QA, premium entitlement logic, expert publishing logic, Phase 02 selection, or new external dependencies.
- Do not change Firestore rules unless existing owner-read coverage is proven missing.

## Required Validation

- RED to GREEN Flutter test proving adaptive estimate read-model parsing and fallback behavior.
- RED to GREEN Flutter test proving generated planned-run adapter consumes usable adaptive estimate state as distance copy.
- GREEN Flutter test proving missing/conservative/malformed adaptive state keeps generated planned-run distance hidden.
- GREEN Flutter widget test proving `RuniacApp` hydrates adaptive estimate state into Run launch copy.
- GREEN Flutter widget or unit test proving stale owner loads cannot carry adaptive estimate state across users.
- `git diff --check`.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`.
- `cd implementation/mobile/runiac_app && flutter test`.

## Done When

- [x] Owner-read adaptive estimate state is consumed in Flutter as display-only state.
- [x] Duration-based generated planned runs show personalized distance estimate copy when backend pace data is usable.
- [x] Missing, malformed, conservative, or zero-pace adaptive estimate state produces no distance estimate and preserves fallback copy.
- [x] Completed planned-run extra-run messaging continues to override estimate copy.
- [x] The mobile client has no adaptive estimate write path and no backend-owned value mutation.
- [x] Generated plan workouts are not regenerated, reshaped, or persisted differently by this capsule.
- [x] Focused tests, full Flutter tests, `flutter analyze --no-pub`, and `git diff --check` pass.
- [x] Roadmap capsule is closed locally with no active capsule left unless the user explicitly selects a follow-up.

## Closure Evidence

- RED read model/repository evidence: `.omo/evidence/adaptive-estimate-consumption/t2-red.txt`.
- RED generated-plan adapter evidence: `.omo/evidence/adaptive-estimate-consumption/t4-red.txt`.
- RED app hydration evidence: `.omo/evidence/adaptive-estimate-consumption/t6-red.txt`.
- GREEN focused evidence: `.omo/evidence/adaptive-estimate-consumption/t2-green.txt`, `.omo/evidence/adaptive-estimate-consumption/t4-green.txt`, `.omo/evidence/adaptive-estimate-consumption/t6-green.txt`, `.omo/evidence/adaptive-estimate-consumption/t7-green.txt`.
- Regression evidence: `.omo/evidence/adaptive-estimate-consumption/t5-plan-progress-regression.txt`, `.omo/evidence/adaptive-estimate-consumption/t5-generated-start-regression.txt`, `.omo/evidence/adaptive-estimate-consumption/t7-run-launch-copy-regression.txt`.
- Final validation evidence: `.omo/evidence/adaptive-estimate-consumption/t8-session-activation-fix.txt`, `.omo/evidence/adaptive-estimate-consumption/t8-backend-boundary-fix.txt`, `.omo/evidence/adaptive-estimate-consumption/t8-read-model-boundary-fix.txt`, `.omo/evidence/adaptive-estimate-consumption/t8-final-analyze.txt`, `.omo/evidence/adaptive-estimate-consumption/t8-final-flutter-test.txt`, `.omo/evidence/adaptive-estimate-consumption/t8-final-diff-check.txt`, `.omo/evidence/adaptive-estimate-consumption/t8-scope-grep.txt`, `.omo/evidence/adaptive-estimate-consumption/t8-roadmap-closure.txt`.
