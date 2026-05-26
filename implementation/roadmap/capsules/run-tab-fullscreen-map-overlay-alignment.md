# run-tab-fullscreen-map-overlay-alignment

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter UI layout-alignment capsule.

## Status

Status: Complete.

Routed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `fix(mobile): align run tab map overlay layout`.

Completed on: 2026-05-26 Asia/Singapore.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Align the static Run tab placeholder so the area above the bottom navigation reads as a fullscreen map-like background with floating Today's Plan and Setting / Start / Switch Route controls.

## Allowed Scope

- Refactor only the Run tab layout in `implementation/mobile/runiac_app/lib/app.dart`.
- Use a Stack-style structure:
  - full map-like background filling the available area above the bottom navigation
  - static route line and marker/flag placeholders
  - floating Today's Plan summary card
  - floating Setting / Start / Switch Route controls near the bottom
- Remove or minimize the current large top gap, separate vertical card feel, and long stacked control area.
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Preserve the Runiac palette and static placeholder copy.
- Update `widget_test.dart` only if visible expectations must change.
- Update roadmap and snapshot files for routing and closure.
- Update Governance CI exact allowlist only for this capsule path if required.

## Forbidden Scope

- No Firebase.
- No Auth.
- No Firestore.
- No Cloud Functions.
- No GPS.
- No tracking.
- No real map SDK or map integration.
- No route generation.
- No timer logic.
- No distance, duration, pace, heart-rate, cadence, calories, or route metrics.
- No activity recording.
- No activity submission.
- No run completion flow.
- No fake run result.
- No XP/streak/level/rank updates or displays.
- No fake leaderboard score.
- No fake premium entitlement.
- No backend-owned value mutation or display.
- No dependency changes.
- No native Android/iOS changes.
- No Phase 02 selection.
- No unrelated design overhaul.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if visible text expectations must change
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/run-tab-fullscreen-map-overlay-alignment.md`
- `tools/governance-ci/check-diff-hygiene.sh` only for exact allowlisting of this capsule file

## Required Tests

- Inspect whether `./tools/governance-ci/run-all-checks.sh` includes `flutter test`.
- If Governance CI does not include `flutter test`, run `flutter test` once after `flutter analyze --no-pub`.
- Do not run `flutter test` twice unless the first run fails and a fix is applied, or Governance CI behavior is unclear and the reason is recorded.

## Required Validation

- `flutter analyze --no-pub`
- `flutter test` once if not already covered by Governance CI
- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- `git status --short`
- Android smoke evidence if `emulator-5554` is available

## Required Evidence

- Initial git state.
- A9_TRACE findings.
- A5_WIRE findings.
- A10_FLUTTER_IMPL implementation summary.
- A6_REVIEW findings.
- A12_QA_TEST factual validation evidence.
- A8_OUTPUT_CHECKER readiness findings.
- Android smoke evidence or factual reason it was not run.
- Final modified file list.

## Rollback Conditions

Stop and do not close this capsule if implementation:

- Modifies files outside the allowed scope.
- Changes bottom navigation away from Home / Maps / Run / Leaderboard / You.
- Adds Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, native Android/iOS, dependency, backend, activity recording, timer, or real map behavior.
- Adds fake distance, duration, pace, heart-rate, cadence, GPS readiness, route metrics, activity result, calories, XP, streak, level, rank, leaderboard score, weekly/monthly XP, subscription state, premium state, or any backend-owned value.
- Selects Phase 02.
- Fails required validation.

## Exit Criteria

- [x] Target files completed.
  - Evidence: `implementation/mobile/runiac_app/lib/app.dart` adjusted the existing static Run tab overlay layout only.
- [x] Required tests or validation completed.
  - Evidence: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- [x] Required evidence recorded.
  - Evidence: Android smoke on `emulator-5554` launched successfully with no runtime crash; screenshot captured outside the repository at `/private/tmp/runiac-run-overlay-adjusted.png`.
- [x] Snapshot updated.
- [x] CURRENT.md active capsule returned to none selected after closure.
