# premium-home-dashboard-static-wireframe-alignment

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter UI product-code-changing capsule.

## Status

Status: Closed.

Routed on: 2026-05-26 Asia/Singapore.

Completed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `feat(mobile): align premium home dashboard static UI`.

Completion review:

- A9_TRACE PASS.
- A5_WIRE PASS.
- A10_FLUTTER_IMPL PASS.
- A6_REVIEW PASS.
- A12_QA_TEST PASS.
- A8_OUTPUT_CHECKER PASS.
- `flutter analyze --no-pub` PASS.
- `flutter test` PASS after one layout fix rerun.
- `git diff --check` PASS.
- Governance CI PASS.
- Android smoke evidence PASS on `emulator-5554`.

This capsule is closed. Do not add further work to it.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Align the static Home screen structure with the provided Premium Home Dashboard wireframe while preserving static-only Flutter UI boundaries and replacing backend-owned or user-specific values with safe empty-state placeholders.

## Allowed Scope

- Implement the static Home dashboard section order:
  1. Top greeting/header
  2. Today's Plan card
  3. Goal / preparation progress card
  4. Level / XP placeholder card
  5. This Week's Plan card
  6. Last Run placeholder card
  7. Advice placeholder card
  8. Recommended Community Route placeholder card
  9. Bottom navigation
- Use the existing Runiac logo color palette:
  - Primary Blue `#2F50C7`
  - Accent Orange `#FC6818`
  - White `#FFFFFF`
  - Background `#F7F8FC`
  - Text Primary `#172033`
  - Text Secondary `#6B7280`
  - Border `#E6EAF2`
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Keep the UI static and safe.
- Update widget test expectations only if visible text expectations must change.
- Update roadmap and snapshot files for routing and closure.

## Implemented Scope

- Replaced the previous three-card Home surface with a static Premium Home Dashboard-aligned section order.
- Added a top greeting/header, Today's Plan card, Goal Preparation placeholder, Runner Progress placeholder, This Week's Plan skeleton, Last Run empty state, Advice placeholder, and Recommended Community Route placeholder.
- Preserved bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Used the established Runiac palette with blue for brand/CTA/selected nav, orange for small route accents, white cards, background surface, text colors, and border color.
- Kept all backend-owned and user-specific values as safe placeholder or empty-state copy.

## Forbidden Scope

- No Firebase.
- No Auth.
- No Firestore.
- No Cloud Functions.
- No GPS/tracking.
- No real run recording.
- No backend integration.
- No premium entitlement logic.
- No AI advice logic.
- No fake XP.
- No fake streak.
- No fake level.
- No fake rank.
- No fake leaderboard score.
- No fake weekly XP.
- No fake monthly XP.
- No fake subscription privilege state.
- No fake premium state.
- No fake run history.
- No fake completed plan status.
- No fake route recommendation data.
- No dependency changes.
- No native Android/iOS changes.
- No Phase 02 selection.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if visible test expectations must change
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/premium-home-dashboard-static-wireframe-alignment.md`
- `tools/governance-ci/check-diff-hygiene.sh` only for exact allowlisting of this capsule file

## Required Tests

- Inspect whether `./tools/governance-ci/run-all-checks.sh` includes `flutter test`.
- If Governance CI does not include `flutter test`, run `flutter test` once after `flutter analyze --no-pub`.
- Do not run `flutter test` twice unless the first run fails and a fix is applied, or Governance CI behavior is unclear and the reason is recorded.

## Required Validation

- `flutter analyze --no-pub`
- `flutter test` once because Governance CI does not run Flutter tests
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

Evidence recorded:

- Initial `git status --short`: no output.
- Initial `git status -sb`: `## main...origin/main`.
- Initial `git log --oneline -5` latest entry: `5f11db9 feat(mobile): polish static home dashboard`.
- Governance CI inspection: `./tools/governance-ci/run-all-checks.sh` does not run `flutter test`, so Flutter test was run separately.
- First `flutter analyze --no-pub`: `No issues found!`.
- First `flutter test`: failed because an unconstrained skeleton placeholder caused a Flutter layout assertion.
- Fix applied: replaced fractional skeleton placeholder sizing with bounded/fill-safe skeleton line sizing.
- Second `flutter analyze --no-pub`: `No issues found!`.
- Second `flutter test`: `All tests passed!`.
- `git diff --check`: no output.
- `./tools/governance-ci/run-all-checks.sh`: `All Governance CI checks passed.`
- `git status --short`: only approved files changed.
- `flutter devices` detected `sdk gphone16k arm64 (mobile) • emulator-5554 • android-arm64 • Android 17 (API 37) (emulator)`.
- `flutter run -d emulator-5554`: built, installed, synced files, exposed VM service, and showed no runtime crash in console output during smoke observation.
- Temporary screenshot captured outside the repository at `/private/tmp/runiac-premium-home-smoke.png`; screenshot is not committed.
- Visual observation: the static dashboard used the Runiac blue/orange/white palette, displayed placeholder-only Home sections in a scrollable layout, preserved bottom navigation Home / Maps / Run / Leaderboard / You, and did not display fake XP, level, run history metrics, advice claims, route names, distances, or premium entitlement state.
- Stop method: `q` input was unavailable because the tool session stdin was closed; the Flutter CLI process was stopped with `kill 9037`, after which the run session reported `Lost connection to device`.

## Rollback Conditions

Stop and do not close the capsule if implementation:

- Modifies files outside the allowed implementation scope.
- Adds Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, native Android/iOS, dependency, or backend behavior.
- Adds fake XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, premium state, run history, route data, completed plan state, or any backend-owned value.
- Changes bottom navigation away from Home / Maps / Run / Leaderboard / You.
- Selects Phase 02.
- Fails required validation.

## Exit Criteria

- [x] Target files completed.
- [x] Required tests or validation completed.
- [x] Required evidence recorded.
- [x] Snapshot updated.
- [x] CURRENT.md active capsule returned to none selected after closure.
