# leaderboard-static-read-model-snapshot-readiness

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only Leaderboard presentation refactor capsule.

## Status

Status: Implemented and validated on 2026-06-08 Asia/Singapore; commit and push handled by this capsule execution.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Prepare the static Leaderboard UI for future backend read-model integration by isolating backend-sensitive display concepts behind private presentation-only display snapshots.

## Scope

Allowed implementation files:

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- Existing relevant tests under `implementation/mobile/runiac_app/test/` only if needed

Allowed roadmap files:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/leaderboard-static-read-model-snapshot-readiness.md`
- `tools/governance-ci/check-diff-hygiene.sh` only to allowlist this capsule path

## Required Refactor

- Keep the Leaderboard UI visually unchanged.
- Introduce small private presentation-only display snapshots for static Leaderboard labels and placeholder copy.
- Snapshot values must be literal display values only, not derived from local arrays or UI state.
- Preserve the Weekly XP / Monthly XP labels as static labels only.
- Preserve the region sheet, map-first shell, tips popup, and leagues popup behavior.
- Avoid copy that implies live backend aggregation is active.

## Backend-Owned Boundary

The client must not calculate, mutate, write, derive, or imply ownership of:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- league or division state
- region ranking
- subscription privilege state
- expert plan publication state

Leaderboard display values remain static presentation placeholders only.

## Forbidden Scope

- No Phase 02 selection.
- No Home, Maps, Run, You, Shell, navigation, theme, shared widget, dependency, or unrelated file changes.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No real leaderboard aggregation.
- No fake leaderboard users, fake ranks, fake XP totals, fake scores, profile rows, or leaderboard rows.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No subscription, premium advantage, entitlement, or expert-plan publication logic.
- No client-side mutation, write, or calculation of backend-owned values.
- No unrelated refactors.
- No new ADRs.

## Required Validation

```bash
git status --short
git diff --check
./tools/governance-ci/check-roadmap-routing.sh
./tools/governance-ci/run-all-checks.sh
dart format implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

## Done When

- [x] This capsule is selected before Flutter edits.
- [x] Focused Leaderboard tests cover static rendering and backend-safe placeholder boundaries where practical.
- [x] Leaderboard display values are isolated behind private presentation-only snapshots.
- [x] Weekly XP / Monthly XP remain labels only with no numeric XP totals.
- [x] Region sheet and league/tips popups remain visually and behaviorally equivalent.
- [x] No backend-owned value is calculated, mutated, written, or derived.
- [x] No fake users, ranks, scores, or numeric XP totals are introduced.
- [x] Required validation passes.
- [x] Review gate confirms only approved files changed and backend-owned boundaries remain preserved.
