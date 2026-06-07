# run-static-read-model-snapshot-readiness

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only Run presentation refactor capsule.

## Status

Status: Implemented and validated on 2026-06-07 Asia/Singapore; commit and push handled by this capsule execution.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Prepare the static Run launch/live/paused UI for future backend read-model integration by isolating display-only placeholder values behind private presentation snapshots and removing misleading hold-to-end completion naming.

## Scope

Allowed implementation files:

- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- Existing relevant tests under `implementation/mobile/runiac_app/test/`

Allowed roadmap files:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/run-static-read-model-snapshot-readiness.md`
- `tools/governance-ci/check-diff-hygiene.sh` only to allowlist this capsule path

## Required Refactor

- Keep the Run UI visually unchanged.
- Introduce small private presentation-only display snapshots for static Run launch and live tracking values.
- Snapshot values must be literal display values, not derived from local arrays or UI state.
- Rename hold-to-end animation completion state and callback to hold-specific names.
- Keep hold-to-end inert exactly as before.
- Preserve launch/live/paused visual behavior and tests.

## Backend-Owned Boundary

The client must not calculate, mutate, write, derive, or imply ownership of:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- expert plan publication state
- plan completion
- completed run status
- remaining runs
- expert plan eligibility
- activity saved/synced state
- trusted run completion confirmation

Run launch/live metrics remain static presentation placeholders only.

## Forbidden Scope

- No Phase 02 selection.
- No Home, Maps, Leaderboard, You, Shell, navigation, theme, shared widget, dependency, or unrelated file changes.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No real GPS/tracking, real run completion, activity saving/syncing, activity summary navigation, XP, streak, level, rank, leaderboard, subscription, or expert plan logic.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No client-side mutation, write, or calculation of backend-owned values.
- No unrelated refactors.
- No new ADRs.

## Required Validation

```bash
git status --short
git diff --check
./tools/governance-ci/check-roadmap-routing.sh
./tools/governance-ci/run-all-checks.sh
dart format implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart implementation/mobile/runiac_app/test/widget_test.dart
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

## Done When

- [x] This capsule is selected before Flutter edits.
- [x] A focused test fails before the refactor and passes after it.
- [x] Run display values are isolated behind private presentation-only snapshots.
- [x] Hold completion naming is animation-specific.
- [x] Hold-to-end remains inert with no run summary, XP, streak, leaderboard, saved, synced, or completed activity state.
- [x] Required validation passes.
- [x] Review gate confirms only approved files changed and backend-owned boundaries remain preserved.
