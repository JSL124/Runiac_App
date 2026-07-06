# run-plan-objective-bottom-sheet

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's `ulw-loop` execution request.

Type: Flutter UI and generated-plan adapter capsule.

## Status

Status: Complete locally.

## Goal

Render the Run launch and active Running bottom sheets according to the selected planned workout objective: keep the existing distance-based fallback sheet unchanged, render duration-based generated workouts with time as the primary objective, treat distance only as optional supporting estimate copy, and show no tracking plan progress bar for rest days.

## Agent Chain

`A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Scope

Allowed implementation files:

- `implementation/mobile/runiac_app/lib/features/run/presentation/models/planned_run_context.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_active_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/run_tracking_sheet_content.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/adapters/generated_plan_you_display_adapter.dart`

Allowed tests:

- `implementation/mobile/runiac_app/test/run_tracking_flow_test.dart`
- `implementation/mobile/runiac_app/test/generated_planned_workout_start_flow_test.dart`
- `implementation/mobile/runiac_app/test/account_profile_read_flow_test.dart`
- `implementation/mobile/runiac_app/test/support/onboarding_flow_test_helpers.dart`
- Existing related Flutter tests needed to prove fallback behavior remains unchanged.

Allowed workflow artifacts:

- `.omo/plans/run-plan-objective-bottom-sheet.md`
- `.omo/drafts/run-plan-objective-bottom-sheet.md`
- `.omo/evidence/**`
- `.omo/ulw-loop/run-plan-objective-bottom-sheet/**`
- `implementation/roadmap/capsules/run-plan-objective-bottom-sheet.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh`
- `tools/governance-ci/check-pre-scaffold-scope.sh`

## Required Boundaries

- Preserve the existing distance-based fallback Run launch sheet copy and layout.
- Treat generated onboarding workouts as duration-objective planned runs.
- Do not implement personalized estimate learning, backend persistence, or user-data model updates in this capsule.
- Distance estimates, when present, are supporting copy only and must not be rendered as a required target.

## Forbidden Scope

- No Firebase deploy, Firestore rules/index deploy, Cloud Functions production deploy, or `firebase init`.
- No `flutterfire configure`.
- No route trace upload, GPS sample persistence, shared route generation, background tracking, Auto Pause, or Moving Time implementation.
- No XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, subscription privilege state, or expert plan publication mutation.
- No premium entitlement logic.
- No Phase 02 selection.
- No changes to Home, Maps, Leaderboard, You/Profile surfaces beyond passing the planned run context into the existing Run launch route and fixing direct test-helper confirmation needed by the final Flutter validation gate.

## Required Validation

- RED to GREEN widget coverage for duration-objective Run launch rendering.
- Generated plan Start flow coverage proving duration objective copy and unchanged fallback behavior.
- `git diff --check`.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`.
- `cd implementation/mobile/runiac_app && flutter test`.
- `./tools/governance-ci/run-all-checks.sh`.
- Visual or surface QA evidence where an emulator/device is available, otherwise an explicit unavailable reason.
- ULW final quality gate evidence for code review, QA review, and gate review.

## Done When

- [x] Distance-based fallback still renders `TODAY'S PLAN`, `4.5`, `km easy run`, and the existing pace/estimate line.
- [x] Duration-based planned workouts render the duration as the primary objective.
- [x] Duration-based planned workouts do not show distance copy as a required goal or target.
- [x] Generated today workout Start opens Run launch with duration-objective copy.
- [x] Duration-based active tracking shows elapsed time progress against target duration.
- [x] Rest day launch context renders and active tracking hides the plan progress bar.
- [x] Notification/system re-entry keeps the planned workout context instead of falling back to 4.5 km.
- [x] Final automated validation is captured with exact evidence.
- [x] Manual/surface QA is captured through ULW quality-gate evidence.

## Closure Evidence

- ULW session: `.omo/ulw-loop/run-plan-progress-20260706/`.
- Final quality gate: `.omo/evidence/run-plan-progress-20260706-quality-gate.json`.
- Manual QA matrix: `.omo/evidence/run-plan-progress-20260706/manual-qa-quality-gate.md`.
- Code review: `.omo/evidence/run-plan-progress-20260706-code-review.md`.
- QA review: `.omo/evidence/run-plan-progress-20260706-qa-review.md`.
- Gate review: `.omo/evidence/run-plan-progress-20260706-gate-review-current.md`.
- Validation passed: focused Running regression, notification re-entry regression, `flutter analyze --no-pub`, full `flutter test`, `./tools/governance-ci/run-all-checks.sh`, and `git diff --check`.
