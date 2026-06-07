# goal-plan-detail-static-snapshot-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only You tab Goal Plan Detail capsule.

## Status

Status: Implemented, validated, committed, pushed, and hosted Governance CI passed on 2026-06-08 Asia/Singapore at `58a164d3daa1760524c74e6fdc6cdaa3457e5e26 feat(you): add static goal plan detail screen`.

Hosted validation:

- Workflow: `Governance CI`
- Run: `#61`
- Run ID: `27101828124`
- Result: `completed` / `success`

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add a static `GoalPlanDetailScreen` opened from the You tab Plan section so a beginner user can understand the selected 10K goal plan at a glance.

The screen renders a static backend-owned display snapshot only. It must not calculate, mutate, persist, or infer plan progress, week status, current phase, selected plan, or training progression on the client.

## Implemented Scope

- Added static `GoalPlanDetailScreen`.
- Added `GoalPlanDisplaySnapshot` and `GoalPlanWeekDisplaySnapshot` presentation display objects.
- Opened the screen only from the You tab Plan section's `View Goal Plan` action.
- Kept bottom navigation visible.
- Back returns to the previous Plans screen.
- Rendered the static 10K plan summary and eight static timeline rows.
- Kept week rows static and non-interactive.
- Added focused widget coverage for entry, title/summary, bottom navigation, all eight rows, back behavior, non-interactive rows, and static progress label.

## Backend-Owned Boundary

The implementation introduced no Firebase, Firestore, Cloud Functions, backend logic, persistence, training-plan progression, XP/streak/level/rank/leaderboard, subscription privilege, expert-plan publication, or client-side plan progress/status calculation.

The client must continue not to calculate, mutate, write, derive, or imply ownership of:

- progress percentage
- current week label
- completed/current/upcoming/goal-week statuses
- current phase
- selected plan
- plan progression state
- training completion state
- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- expert plan publication state

Static display values remain presentation-only placeholders until backend read models are explicitly routed.

## Forbidden Scope

- No Phase 02 selection.
- No Home entry point.
- No week detail pages.
- No plan switching.
- No plan editing.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No client-side mutation, write, persistence, or calculation of backend-owned values.
- No unrelated refactors.
- No new ADRs.

## Validation Evidence

Local implementation validation before commit:

- `git diff --check` PASS.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `flutter analyze --no-pub` PASS.
- `flutter test` PASS.

Hosted validation after push:

- Governance CI run `#61`, run ID `27101828124`, completed with result `success` for commit `58a164d3daa1760524c74e6fdc6cdaa3457e5e26`.

## Done When

- [x] `View Goal Plan` from You tab Plan section opens `GoalPlanDetailScreen`.
- [x] Bottom navigation remains visible.
- [x] Back returns to the previous Plans screen.
- [x] Static 10K goal plan snapshot renders.
- [x] Progress, status, and current phase are rendered from snapshot fields only.
- [x] Week rows are non-interactive.
- [x] No Home entry point was added.
- [x] No Firebase, Firestore, Cloud Functions, persistence, calculation, or progression logic was introduced.
- [x] Required validation passed.
- [x] Hosted Governance CI passed for the implementation commit.
