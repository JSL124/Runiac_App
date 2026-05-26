# run-launch-fullscreen-static-interaction

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter static UI interaction capsule.

## Status

Status: Ready for commit.

Routed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `feat(mobile): add static run launch interaction`.

## Required Agent Chain

```text
A0_ORCH -> A14_ERROR_TRIAGE -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add a static full-screen Run launch interaction so tapping the Run bottom-navigation item opens a slide-up pre-run surface that covers the shell bottom navigation and dismisses back to the previous shell state.

## Allowed Scope

- Intercept the Run bottom-navigation item in the shell.
- Push a full-screen slide-up Run launch route.
- Keep the previous shell tab selected underneath.
- Hide the shell bottom navigation while the launch screen is open.
- Add a top-left Close affordance.
- Allow Android back to dismiss the launch route.
- Keep Start, Setting, and Route setup static/inert.
- Use Runiac colors and existing neutral tokens only.
- Add widget coverage for open, close, Android back, bottom-nav hiding, and inert Start behavior.
- Update `CURRENT.md`, `snapshots/latest.md`, and this capsule with confirmed state.
- Update Governance CI exact allowlist only for this capsule path if required.

## Forbidden Scope

- No Phase 02 selection.
- No Firebase, Auth, Firestore, Cloud Functions, or backend work.
- No GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, timer, distance, pace, duration, heart-rate, cadence, calories, or activity submission logic.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription, premium entitlement, or backend-owned state changes.
- No fake route metrics, fake run metrics, fake activity result, fake premium entitlement, or fake backend-owned values.
- No dependency changes.
- No native Android/iOS changes.
- No GitHub Actions workflow changes.
- No unrelated Home, Maps, Leaderboard, or You UI redesign.
- No competitor UI, colors, map visuals, icons, labels, assets, or trade dress.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md`
- `tools/governance-ci/check-diff-hygiene.sh` only if exact allowlisting requires it.

## Evidence

- Initial `git status --short --untracked-files=all`: dirty with expected interrupted Run launch capsule files only.
- A0_ORCH finding: implementation-approved mode applies to this explicitly requested Run launch capsule correction; the dirty tree was inspected before continuing; Phase 02 remains unselected; no staging, commit, or push is authorized.
- A14_ERROR_TRIAGE finding: the incorrect visual state came from grouping launch copy and all controls inside a single large bottom panel; the correction preserves the launch route while restoring separate floating plan and control overlays.
- A9_TRACE finding: the change is static UI interaction only; Start remains inert; normal shell bottom navigation remains Home / Maps / Run / Leaderboard / You; the Run launch screen itself does not show bottom navigation.
- A5_WIRE finding: the visual direction is a Runiac-original calm pre-run surface with static map-like background, top-left Close, a separate floating Today’s Plan card, dominant Start, and secondary Setting / Route setup controls.
- A10_FLUTTER_IMPL summary: the shell intercepts Run bottom-nav taps and pushes an opaque full-screen `PageRouteBuilder` with bottom-to-top slide transition; previous tab selection is preserved underneath; Close and Android back dismiss the route; the launch layout uses separate floating overlays for Today’s Plan and Setting / Start / Route setup controls.
- A6_REVIEW finding: modified only shell, Run launch presentation, widget tests, and roadmap/governance files; no fake metrics, backend-owned values, Firebase/Auth/Firestore/GPS/location/map SDK/tracking/timer behavior, dependency/native change, or unrelated screen redesign was introduced.
- A12_QA_TEST finding: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke screenshot skipped by user preference to reduce iteration time.

## Required Validation

- `git status --short` before changes.
- `flutter analyze --no-pub`.
- `flutter test`.
- `git diff --check`.
- `./tools/governance-ci/run-all-checks.sh`.
- Android smoke screenshot is optional and skipped by default for this correction pass.
- `git status --short` after validation.

## Exit Criteria

- [x] Run bottom-nav item opens a static full-screen launch surface.
- [x] Launch surface hides shell bottom navigation while open.
- [x] Launch surface uses separate floating plan and control overlays.
- [x] Close and Android back dismiss to the previous shell state.
- [x] Start remains inert/static.
- [x] Static UI-only behavior preserved.
- [x] No forbidden files or scopes touched.
- [x] Required validation completed.
- [x] Capsule, CURRENT.md, and snapshot updated.
- [x] Ready for commit only; not staged, committed, or pushed.
