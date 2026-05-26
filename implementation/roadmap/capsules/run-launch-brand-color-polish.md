# run-launch-brand-color-polish

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only Run launch visual polish capsule.

## Status

Status: Closed; implementation committed and pushed.

Routed on: 2026-05-27 Asia/Singapore.

Completion evidence commit: `e1f9c6d feat(mobile): polish run launch brand colors`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Apply narrow static Run launch brand color polish so the Run launch surface has a clearer Runiac blue/orange hierarchy without changing behavior.

## Color Direction

- Blue = route and structure.
- Orange = Start and action energy.
- White / soft gray = calm surfaces.
- Navy = readable text.

## Allowed Scope

- Static frontend-only visual color polish for the Run launch screen.
- Make the Start button/action hierarchy more energetic and action-oriented.
- Keep route line and route structure blue.
- Keep Setting and Route setup visually secondary as white/blue pill actions.
- Keep the Today's Plan card white with soft blue structure.
- Preserve beginner-friendly, calm, non-aggressive visual balance.
- Keep all Run launch controls static/inert unless a later capsule explicitly approves behavior.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if stable expectations need update.

## Forbidden Scope

- No Phase 02 selection.
- No GPS/location permission, current-location state, or location behavior.
- No real run tracking.
- No timers.
- No route setup logic.
- No real route generation, route persistence, or map SDK behavior.
- No Firebase, Auth, Firestore, Cloud Functions, or backend work.
- No backend-owned values.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, premium entitlement, or expert plan publication state computation or mutation.
- No fake run metrics, including distance, pace, duration, calories, cadence, heart-rate, route stats, rankings, or progress data.
- No dependencies.
- No native Android/iOS changes.
- No shell navigation changes.
- No Maps, Home, Leaderboard, You, backend, governance workflow, or PDD changes.

## Done When

- Start button/action color hierarchy is improved.
- Route line remains blue.
- Setting and Route setup remain visually secondary.
- Run launch remains static, frontend-only, and beginner-friendly.
- No behavior changes are introduced.
- No backend-owned boundary is touched.
- No Flutter source or test files outside the allowed list are changed.
- `flutter analyze --no-pub` passes.
- `flutter test` passes.
- `git diff --check` passes.
- `./tools/governance-ci/run-all-checks.sh` passes.

## Required Validation

- `git status --short` before changes.
- `flutter analyze --no-pub`.
- `flutter test`.
- `git diff --check`.
- `./tools/governance-ci/run-all-checks.sh`.
- `git status --short` after validation.

## Current Routing Evidence

- Home dashboard primary-action and brand color polish is closed at `bd2963d feat(mobile): polish home brand action hierarchy`.
- The next visual issue is Run launch brand color hierarchy: blue should continue to communicate route/structure, while orange should communicate Start/action energy.
- A5_WIRE routing finding: this is a visual-only Run launch polish capsule; it should not mix with Home implementation and should not change Run behavior.
- A9_TRACE routing finding: this capsule remains static frontend-only and does not introduce GPS/location, tracking, timers, route setup logic, Firebase, backend behavior, fake run metrics, dependencies, native changes, or shell navigation changes.
- A6_REVIEW routing finding: the capsule is small and deterministic because it targets Run launch color hierarchy only.

## Closure Evidence

- Implementation commit: `e1f9c6d feat(mobile): polish run launch brand colors`.
- Implemented scope: Start button changed to orange/action-oriented, Start shadow changed to subtle orange, Setting and Route setup remained secondary white/blue pill actions, and Run launch background moved to soft gray-blue.
- Preserved scope: route line remained blue, Today's Plan remained calm and readable, map placeholder and markers were not redesigned, and behavior stayed static/inert.
- Validation: `git diff --check` PASS; `flutter analyze --no-pub` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- Scope boundary: no Home, Maps, shell navigation, Firebase/Auth/Firestore/Cloud Functions, GPS/location, tracking, timers, route setup logic, backend-owned values, fake run metrics, dependencies, native Android/iOS changes, or Phase 02 selection were introduced.

## Exit Criteria

- [x] Start button/action color hierarchy is improved.
- [x] Route line remains blue.
- [x] Secondary controls remain visually secondary.
- [x] Static frontend-only behavior preserved.
- [x] No forbidden files or scopes touched.
- [x] Required validation completed.
- [x] Capsule, CURRENT.md, and snapshot updated with confirmed implementation state.
- [x] Ready for commit only unless explicit commit approval is granted.
