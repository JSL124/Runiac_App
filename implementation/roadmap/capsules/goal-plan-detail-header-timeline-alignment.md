# goal-plan-detail-header-timeline-alignment

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by explicit local-only governed workflow request.

Type: Flutter static frontend-only You tab Goal Plan Detail UI alignment capsule.

## Status

Status: Selected for implementation. Implementation may begin only after `implementation/roadmap/CURRENT.md` confirms this capsule as the current active capsule.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Refine the existing static Goal Plan Detail screen so its fixed header and weekly timeline alignment match the implemented Expert Plan Detail / Plan Preview quality bar.

The screen remains a static backend-owned display snapshot only. This capsule must not calculate, mutate, persist, infer, or activate plan progress, week status, current phase, selected plan state, training progression, enrollment, subscription state, XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, or expert plan publication state on the client.

## Allowed Implementation Scope

- Goal Plan Detail widget/file only.
- Directly relevant You tab widget test only.
- Minimal navigation wiring only if actually required by the alignment work.
- Inspect the implemented Expert Plan Detail / Plan Preview file as the visual and structural header reference.

## UI Requirements

- Match the Expert Plan Detail / Plan Preview header pattern for back button placement, title alignment, top padding feel, header height feel, and background behavior.
- Keep the sticky header area limited to the back button, title, and header container/background.
- Add the long blue/orange accent strip directly below the fixed header as the first content element.
- Ensure the accent strip scrolls with content and is not part of sticky header height.
- Remove or avoid older short strip treatment on the Goal Plan Detail screen.
- Align completed, current, upcoming, and goal-week timeline markers with their corresponding `Week` labels and row content.
- Keep the vertical connector visually continuous and centered through the marker column.
- Preserve the existing static display statuses: `Completed`, `Current`, `Upcoming`, and `Goal Week`.

## Forbidden Scope

- No Phase 02 selection.
- No unrelated You page changes.
- No Expert Plan Detail implementation changes except inspect-only reference.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, build, or FlutterFire commands.
- No `pubspec.yaml`, `pubspec.lock`, dependency, Android, or iOS changes.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No enrollment, activation, persistence, progress mutation, subscription behavior, XP, streak, level, rank, leaderboard, expert publication, or trusted backend-owned state.
- No unrelated refactors.
- No new ADRs.
- No implementation staging, commit, or push without separate explicit instruction.

## Required Validation

Stage 1 routing validation before commit:

- `pwd`
- `git rev-parse --show-toplevel`
- `git branch --show-current`
- `git status --short`
- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- `git diff --cached --check`

Stage 2 implementation validation before Ready for commit:

- Focused You / Goal Plan widget test if present, for example `flutter test test/you_tab_static_ui_test.dart`.
- `flutter analyze --no-pub`.
- `flutter test`.
- `git diff --check`.
- `./tools/governance-ci/run-all-checks.sh`.
- Android emulator screenshot smoke for initial header/accent strip, timeline alignment, and sticky behavior unless unavailable.

## Done When

- [ ] `CURRENT.md` confirms this capsule as active.
- [ ] Header/back/title layout matches the Expert Plan Detail / Plan Preview pattern.
- [ ] Long blue/orange accent strip appears directly below the fixed header as first content.
- [ ] Accent strip is not sticky and is not part of fixed header height.
- [ ] Weekly timeline markers align with the `Week` labels and row content.
- [ ] Completed/current/upcoming/goal-week rows remain static and visually consistent.
- [ ] No backend-owned state behavior, persistence, calculation, or mutation is introduced.
- [ ] Required validation passes.
- [ ] Implementation stops at Ready for commit.
