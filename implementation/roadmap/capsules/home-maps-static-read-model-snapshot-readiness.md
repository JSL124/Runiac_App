# home-maps-static-read-model-snapshot-readiness

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only Home and Maps presentation refactor capsule.

## Status

Status: Implemented, validated, committed, pushed, and hosted Governance CI passed on 2026-06-08 Asia/Singapore at `386d324 refactor(home-maps): isolate static display snapshots`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Prepare the static Home and Maps UI for future backend read-model integration by isolating static placeholder display values behind private presentation-only snapshots or display data objects.

The UI must remain visually unchanged. This capsule does not add behavior.

## Scope

Allowed implementation files:

- `implementation/mobile/runiac_app/lib/features/home/presentation/`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/`
- Existing relevant tests under `implementation/mobile/runiac_app/test/` only if needed

Allowed roadmap files:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/home-maps-static-read-model-snapshot-readiness.md`
- `tools/governance-ci/check-diff-hygiene.sh` only to allowlist this capsule path

## Required Refactor

Home:

- Keep the Home UI visually unchanged.
- Isolate static Home display values behind private presentation-only snapshots or display data.
- Candidate areas include runner progress, weekly plan, today's plan/dashboard summary copy, last run, and feedback placeholder copy.
- Snapshot values must be precomputed display literals only.
- Do not derive progress, streak, completed runs, remaining runs, weekly summaries, or plan status from local arrays or UI state.

Maps:

- Keep the Maps UI visually unchanged.
- Isolate static route card and sheet display values behind private presentation-only snapshots or display data.
- Candidate areas include shared routes sheet card copy, route preview card copy, saved route placeholder copy, and route labels.
- Snapshot values must be precomputed display literals only.
- Do not derive route popularity, saved count, ownership, completion, shared metadata, or territorial state from local arrays or UI state.

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
- route popularity
- saved route counts
- shared route metadata
- route ownership
- territorial ownership
- route completion status
- activity saved/synced state
- trusted weekly/monthly activity summaries

Static display values remain presentation-only placeholders.

## Forbidden Scope

- No Phase 02 selection.
- No Run, Leaderboard, You, Shell, navigation, theme, shared widget, dependency, backend, Firebase, native, or unrelated file changes.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No real route discovery, saved/shared route state, route popularity, saved counts, ownership, territorial state, completion, backend metadata, activity history, or trusted weekly/monthly summaries.
- No client-side mutation, write, or calculation of backend-owned values.
- No unrelated refactors.
- No new ADRs.

## Required Validation

Routing validation:

```bash
git status --short
git diff --check
./tools/governance-ci/check-roadmap-routing.sh
./tools/governance-ci/run-all-checks.sh
```

Implementation validation:

```bash
dart format <modified Dart source/test files>
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

## Done When

- [x] This capsule is selected before Home/Maps Flutter edits.
- [x] Focused tests cover Home and Maps static rendering and backend-safe placeholder boundaries where practical.
- [x] Home display values are isolated behind private presentation-only snapshots/display data.
- [x] Maps display values are isolated behind private presentation-only snapshots/display data.
- [x] UI remains visually unchanged.
- [x] No backend-owned value is calculated, mutated, written, derived, or implied as client-owned.
- [x] No forbidden implementation scope is touched.
- [x] Required validation passes.
- [x] Review gate confirms only approved files changed and backend-owned boundaries remain preserved.
