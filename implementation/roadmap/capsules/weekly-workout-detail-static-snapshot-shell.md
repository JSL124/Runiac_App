# weekly-workout-detail-static-snapshot-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only You tab Weekly Workout Detail capsule.

## Status

Status: Implemented, validated, committed locally, and closed on 2026-06-08 Asia/Singapore.

Routed on: 2026-06-08 Asia/Singapore.

Implementation commits:

- `a6f7e7f8b0b977df06e60d33158d1c2421878c64 feat(you): add weekly workout detail screen`
- `67f67534add890b97ee39cedfa358cdac7fe21a4 fix(you): refine weekly plan and schedule preview`

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add a static beginner-friendly Weekly Workout Detail screen opened from the You > Plans weekly schedule workout rows that have an available instruction preview:

`Thu · 20 min easy run · Upcoming · 7:30 AM`

`Sat · 20 min easy run`

The screen must behave as a workout instruction sheet, not analytics, not a real run start, and not real schedule editing.

## Implemented Scope

- Added the static `WeeklyWorkoutDetailScreen`.
- Opened static workout instruction previews from the You > Plans Thu upcoming and Sat easy-run rows.
- Kept the Tue completed workout row and all Rest Day rows non-clickable.
- Kept completed workout rows free of analytics, XP, streak, route, completion summary, and backend-owned state flows.
- Added static Saturday labeling with no invented schedule time.
- Refined the preview-only Edit schedule sheet.
- Preserved `Start This Run` as visual-only/no-op.
- Polished weekly plan row alignment so tappable and non-tappable rows share the same day-column grid.
- Removed duplicate right-side Rest Day labels while preserving muted non-clickable rest rows.
- Added focused widget coverage for static detail entry, Sat detail, tappable affordances, non-clickable Rest/Completed rows, schedule preview boundaries, visual-only start action, and row alignment.

## Product Direction

- Help a beginner understand the next planned workout with low cognitive load.
- Prioritize supportive instruction, consistency, and confidence over performance analysis.
- Use Runiac's current mobile UI language as the source of truth.
- Use reference screenshots only as information architecture or layout inspiration.
- Keep the implementation static, read-only, and bounded to one visible screen-level improvement.

## Approved UI Decisions

- The `Thu · 20 min easy run · Upcoming · 7:30 AM` row is tappable.
- The `Sat · 20 min easy run` row is tappable.
- Tappable workout rows open static workout instruction preview only.
- The whole tappable workout row should feel tappable, not only the day label.
- Tappable workout rows should use a workout status circle, stronger title, right chevron, row-wide tap affordance, and normal mobile pressed feedback.
- Rest Day rows should be visually quieter with no chevron, no highlight, and no pressed feedback.
- Completed rows should keep the completed indicator but must not show a chevron or detail affordance.
- The `Tue · 15 min walk-run · Completed` row remains non-clickable because completed workout detail is unavailable in this static capsule.
- The Workout Detail screen title is `Workout detail`.
- The top-right secondary action is `Edit schedule`.
- `Start This Run` is visual-only and no-op in this capsule.
- `Edit schedule` opens a static preview-only bottom sheet.
- No visible heavy technical boundary copy should appear on the main workout detail screen.
- The Edit schedule bottom sheet should include the only visible boundary copy:
  `Preview only. Schedule changes will be connected later through backend-controlled plan updates.`

## Required Static Content

Top app bar:

- Back button.
- `Workout detail`.
- `Edit schedule`.

Hero:

- `THURSDAY · EASY RUN`
- `A gentle 20 minutes.`
- `You should be able to chat the whole way through.`
- `No race - just rhythm.`

Summary metrics:

- `Distance` / `3.0 km`
- `Time` / `20 min`
- `Suggested pace` / `7:30 /km`
- `Effort` / `Low`

Session breakdown:

- `Warm-up` / `5 min · easy walk`
- `Easy run` / `12 min · conversational pace`
- `Cool-down` / `3 min · slow walk`

The breakdown total must remain exactly 20 minutes.

Effort guide:

- `Aim for 2 out of 5 - you can speak full sentences without gasping.`

Coach note:

- `Start slower than you think.`
- `If breathing feels sharp, walk briefly and reset.`
- `Easy runs should feel almost too slow at first. That is normal.`

Primary CTA:

- `Start This Run`

Edit schedule bottom sheet:

- `Edit schedule`
- `Current plan`
- `Thursday · 7:30 AM`
- For the Saturday workout detail, the current plan label is `Saturday` with no invented time.
- `Suggested options`
- `Morning · 7:30 AM`
- `Lunch · 12:30 PM`
- `Evening · 6:30 PM`
- `Preview only. Schedule changes will be connected later through backend-controlled plan updates.`

## Design Constraints

- Reuse Runiac blue and orange brand accents.
- Use the white / soft off-white background family.
- Reuse existing card, button, spacing, and typography patterns where practical.
- Keep the Edit schedule action visually weaker than `Start This Run`.
- Keep summary metrics compact and secondary.
- Use `Suggested pace`, not `Pace`, and make the pace value feel supportive rather than strict.
- Avoid metric overload, aggressive competition, shame, guilt, or performance-heavy framing.
- Do not copy screenshot typography, colors, icons, spacing, or visual system blindly.

## Allowed Scope For Future Implementation

- Static frontend-only You tab weekly workout detail interaction.
- Add the static detail screen under the You feature presentation layer.
- Make the Thu upcoming and Sat easy-run workout rows tappable.
- Keep the Tue completed workout row and all Rest Day rows non-clickable.
- Add the preview-only Edit schedule bottom sheet.
- Add or update focused widget tests for the new static UI and interaction boundaries.
- Use existing Flutter widgets and existing dependencies only.
- Minimal `CURRENT.md`, this capsule, and snapshot updates required by roadmap governance.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/weekly_workout_detail_screen.dart`
- `implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if validation proves it is unavoidable
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/weekly-workout-detail-static-snapshot-shell.md`

## Forbidden Scope

- No Phase 02 selection.
- No Home, Maps, Run, Leaderboard, Shell, navigation, theme, shared widget, dependency, or unrelated file changes unless implementation discovers a direct routed need.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No real schedule editing.
- No real run start.
- No Run launch navigation unless separately approved later.
- No activity completion.
- No plan progress update.
- No XP, streak, rank, leaderboard score, weekly XP, monthly XP, or trusted state update.
- No client-side progress calculation.
- No Rest Day detail flow.
- No Completed workout detail flow.
- No analytics, XP, streak, route, completion summary, or backend-owned state flow from completed workouts.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No unrelated refactors.
- No new ADRs.
- No staging, commit, or push unless separately approved.

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
- trusted plan completion/progress state
- run completion state
- schedule state

For this capsule, workout metrics, workout timing, row status, and schedule options are literal static placeholders only. Do not derive completion, remaining runs, progress, or schedule state from local logic.

## Required Validation For Future Implementation

```bash
git status --short
git diff --check
dart format implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart implementation/mobile/runiac_app/lib/features/you/presentation/weekly_workout_detail_screen.dart implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart
cd implementation/mobile/runiac_app && flutter analyze
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

If Flutter validation requires dependency resolution and dependencies are missing, stop and report the blocker instead of expanding scope.

## Validation Evidence

Local implementation and polish validation:

- `git diff --check` PASS.
- `dart format implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart implementation/mobile/runiac_app/lib/features/you/presentation/weekly_workout_detail_screen.dart implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart` PASS.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS.
- `cd implementation/mobile/runiac_app && flutter test` PASS.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- Android emulator launch smoke PASS on `emulator-5554`; app built, installed, launched without runtime crash, and the Flutter run session was stopped cleanly.

No hosted validation is claimed for these local commits in this closure record.

## Routing Evidence

- Phase 01 Governance CI is closed.
- Phase 02 remains unselected.
- `implementation/roadmap/CURRENT.md` required explicit next capsule selection.
- The user explicitly selected `weekly-workout-detail-static-snapshot-shell` as the next active capsule.
- The previous Goal Plan Detail capsule is closed and does not authorize this follow-up implementation until this capsule is routed.

## Risk Notes

- The weekly plan schedule touches protected plan status language; keep all values static and display-only.
- Do not make Rest Day or Completed rows look tappable.
- Completed workout rows may show the completed status circle but must not show a chevron or row-wide tap affordance.
- Do not make `Start This Run` look like it starts GPS, real tracking, completion, XP, streak, plan progress, or leaderboard updates.
- Do not make Edit schedule look like a real schedule mutation.
- Do not imply user-history analysis with copy such as `Yesterday's pace looked quick`.
- Do not make `Suggested pace` feel like a strict target.

## Done When

- [x] This capsule was selected before Flutter edits.
- [x] The Thu upcoming and Sat easy-run rows open the static detail screen.
- [x] The Sat detail uses the same 20-minute easy-run instruction content with Saturday labeling and no invented time.
- [x] Rest Day and Completed rows remain non-clickable.
- [x] Static `Workout detail` screen renders the approved hero, metrics, 20-minute breakdown, effort guide, coach note, and visual-only CTA.
- [x] `Edit schedule` opens a preview-only bottom sheet with no trusted schedule mutation.
- [x] `Start This Run` remains visual-only/no-op.
- [x] Weekly plan row affordance and alignment polish is implemented and covered by widget tests.
- [x] No forbidden files or scopes are touched.
- [x] No Firebase, backend, GPS/native, dependencies, real completion, schedule mutation, or trusted backend-owned state logic is introduced.
- [x] Required validation passed.
- [x] Capsule, `CURRENT.md`, and snapshot are updated at closure.
