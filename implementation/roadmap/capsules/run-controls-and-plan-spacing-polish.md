# run-controls-and-plan-spacing-polish

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter static UI polish capsule.

## Status

Status: Ready for commit.

Routed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `fix(mobile): polish run tab controls spacing`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Polish the static Run tab spacing and control layout so the Today’s Plan card, Start control, secondary controls, and shell-owned bottom navigation have clearer visual separation.

## Allowed Scope

- Adjust static Run tab spacing, constraints, and hierarchy only.
- Keep the full map-like static background.
- Keep Today’s Plan, Setting, Start, and Switch Route as static controls.
- Keep Start visually primary.
- Keep Setting and Switch Route secondary and readable on small screens.
- Update `CURRENT.md`, `snapshots/latest.md`, and this capsule with confirmed state.
- Update Governance CI exact allowlist only for this capsule path if required.

## Forbidden Scope

- No Phase 02 selection.
- No Firebase, Auth, Firestore, Cloud Functions, or backend work.
- No GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, timer, distance, pace, duration, heart-rate, cadence, or activity submission logic.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription, premium entitlement, or backend-owned state changes.
- No fake route metrics, fake run metrics, fake activity result, fake premium entitlement, or fake backend-owned values.
- No dependency changes.
- No native Android/iOS changes.
- No GitHub Actions workflow changes.
- No Home, Maps, Leaderboard, or You UI changes.
- No unrelated UI redesign.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/features/run/presentation/run_tab.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/run_controls.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/run_plan_card.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/run_map_placeholder.dart` only for minor background de-emphasis if required.
- `implementation/mobile/runiac_app/test/widget_test.dart` only if visible expectations require it.
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/run-controls-and-plan-spacing-polish.md`
- `tools/governance-ci/check-diff-hygiene.sh` only if exact allowlisting requires it.

## Evidence

- Initial `git status --short`: no output.
- A0_ORCH finding: implementation-approved mode applies to this explicitly requested Run tab polish capsule; the working tree was clean; Phase 02 remains unselected; no staging, commit, or push is authorized.
- A9_TRACE finding: the change is static Run tab UI polish only; Start remains an inert static control; bottom navigation remains Home / Maps / Run / Leaderboard / You.
- A5_WIRE finding: safest polish target is the vertical relationship between Today’s Plan, controls, and the shell bottom navigation, with small-screen readability for Setting and Switch Route.
- A10_FLUTTER_IMPL summary: grouped the Today’s Plan card and Run controls into one bottom overlay column, increased bottom clearance, capped overlay width, added compact spacing for narrow widths, kept Start visually primary with a larger circular filled button, and kept Setting / Switch Route as static secondary controls with scale-down labels.
- A6_REVIEW finding: modified only Run presentation files plus roadmap/capsule governance files and Governance CI allowlisting; no fake metrics, backend-owned values, Firebase/Auth/Firestore/GPS/location/map SDK/tracking/timer behavior, bottom-navigation change, or unrelated screen change was introduced.
- A12_QA_TEST finding: `flutter analyze --no-pub` PASS after removing an invalid const; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Android smoke evidence: app launched on `emulator-5554`; Run tab was selected through adb; screenshot captured at `/private/tmp/runiac-run-controls-spacing-polish.png`; Today's Plan card and controls did not overlap; controls had bottom/nav clearance; Start remained visually primary; no fake GPS/tracking/metrics were visible; bottom navigation remained Home / Maps / Run / Leaderboard / You.

## Required Validation

- `git status --short` before changes.
- `flutter analyze --no-pub`.
- `flutter test`.
- `git diff --check`.
- `./tools/governance-ci/run-all-checks.sh`.
- Android smoke evidence on `emulator-5554` if available.
- `git status --short` after validation.

## Exit Criteria

- [x] Run tab spacing/control polish completed.
- [x] Static UI-only behavior preserved.
- [x] No forbidden files or scopes touched.
- [x] Required validation completed.
- [x] Capsule, CURRENT.md, and snapshot updated.
- [x] Ready for commit only; not staged, committed, or pushed.
