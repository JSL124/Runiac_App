# goal-plan-detail-header-timeline-alignment

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by explicit local-only governed workflow request.

Type: Flutter static frontend-only You tab Goal Plan Detail UI alignment and week-list refinement capsule.

## Status

Status: Closed after implementation commit `7798f058ae1b272e8eca6dd8a31cba4490c8faa1 feat(you): refine goal plan detail week list` was pushed to `origin/main` and hosted Governance CI #65 passed.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Refine the existing static Goal Plan Detail screen so its fixed header, weekly timeline alignment, and static week-list interaction match the implemented Expert Plan Detail / Plan Preview quality bar and the refined QA Seed for visual-only progress states.

The screen remains a static backend-owned display snapshot only. Static Monday-to-Sunday daily rows and sample onboarding run/rest day mapping are preview display data only. This capsule must not calculate, mutate, persist, infer, or activate plan progress, week status, current phase, selected plan state, onboarding state, training progression, enrollment, subscription state, XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, or expert plan publication state on the client.

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
- Add horizontal dividers between week blocks.
- Remove vertical connector lines between week markers; keep standalone markers aligned to each `Week` label and row content.
- Preserve static progress semantics, but represent them visually only.
- Remove visible `Completed`, `Current`, and `Upcoming` row text labels.
- Treat `Goal Week` as a visual/static milestone state only if it remains present; do not require a visible `Goal Week` row label.
- Use completed check-circle markers, a current orange circular running-person marker, and an inactive future marker tone.
- Add initially-collapsed weekly dropdown behavior for each week row.
- When a week is expanded, show static Monday-to-Sunday daily plan rows with day plus Run/Rest or workout type plus distance/time.
- Use explicit static sample onboarding mapping for preview only: for the sample `10K Goal Plan`, running days are Monday, Wednesday, Friday, and Saturday; rest days are Tuesday, Thursday, and Sunday.
- Add a current-week full-row light-blue highlight that includes the marker, week title, and chevron within the row content margins without visible weekly distance/time summary text.

## Forbidden Scope

- No Phase 02 selection.
- No unrelated You page changes.
- No Expert Plan Detail implementation changes except inspect-only reference.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, build, or FlutterFire commands.
- No `pubspec.yaml`, `pubspec.lock`, dependency, Android, or iOS changes.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No enrollment, activation, persistence, onboarding state mutation, progress mutation, subscription behavior, XP, streak, level, rank, leaderboard, expert publication, or trusted backend-owned state.
- No real personalization engine or trusted onboarding-derived plan generation; any Monday-to-Sunday rows and run/rest mapping remain static preview display data only.
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

## Closure Evidence

- Routing commit: `ab47260 docs(roadmap): select goal plan detail alignment capsule`.
- Scope refinement commit: `53ddd1e docs(roadmap): refine goal plan detail capsule scope`.
- Implementation commit: `7798f058ae1b272e8eca6dd8a31cba4490c8faa1 feat(you): refine goal plan detail week list`.
- Hosted Governance CI: #65 PASS, run ID `27160664756`, exact head SHA `7798f058ae1b272e8eca6dd8a31cba4490c8faa1`.
- Local validation before implementation commit: focused Goal Plan Detail widget test PASS, `flutter test test/you_tab_static_ui_test.dart` PASS, `flutter analyze --no-pub` PASS, `flutter test` PASS, `git diff --check` PASS, and `./tools/governance-ci/run-all-checks.sh` PASS.
- Android screenshot smoke before implementation commit: `/private/tmp/runiac-goal-plan-no-summary-initial.png` and `/private/tmp/runiac-goal-plan-no-summary-week3-expanded.png` confirmed no weekly summary text, no vertical marker connector lines, preserved standalone markers, preserved chevrons, preserved current-week highlight, and preserved daily plan rows.

## Done When

- [x] `CURRENT.md` confirmed this capsule as active before implementation.
- [x] Header/back/title layout matches the Expert Plan Detail / Plan Preview pattern.
- [x] Long blue/orange accent strip appears directly below the fixed header as first content.
- [x] Accent strip is not sticky and is not part of fixed header height.
- [x] Weekly timeline markers align with the `Week` labels and row content.
- [x] Week blocks have horizontal dividers, and vertical connector lines were removed per the refined follow-up QA seed.
- [x] Completed/current/upcoming/goal-week semantics remain static and visually consistent without visible `Completed`, `Current`, or `Upcoming` row labels.
- [x] Weekly dropdowns are initially collapsed and show static Monday-to-Sunday daily plan rows when expanded.
- [x] Sample daily rows use static preview-only run/rest mapping and do not introduce persistence, onboarding mutation, or trusted progress state.
- [x] Current week has a full-row light-blue highlight and an orange circular running-person marker.
- [x] Visible weekly distance/time summary text was removed from week rows while daily row distance/time display remains static preview data.
- [x] No backend-owned state behavior, persistence, calculation, or mutation is introduced.
- [x] Required validation passed.
- [x] Implementation was pushed and verified by hosted Governance CI.
