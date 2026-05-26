# leaderboard-static-motivation-hierarchy-polish

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only Leaderboard visual hierarchy polish capsule.

## Status

Status: Selected for implementation; implementation not started.

Routed on: 2026-05-27 Asia/Singapore.

Completion evidence commit target: `feat(mobile): polish leaderboard motivation hierarchy`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Replace the generic Leaderboard placeholder with a calm, beginner-friendly static screen that suggests future community motivation without fake ranks, fake users, fake XP, fake scores, backend behavior, or real leaderboard computation.

## Intended UX Direction

- Keep the Leaderboard screen beginner-friendly.
- Keep the tone supportive, motivating, and non-intimidating.
- Keep the screen static and placeholder-only.
- Make competition feel light rather than aggressive.
- Avoid shame, guilt, and performance-obsessed language.
- Emphasize consistency, area identity, and future community motivation.
- Avoid metric overload.
- Keep copy calm and encouraging.

## Allowed Scope

- Static frontend-only Leaderboard visual hierarchy polish.
- Local Leaderboard presentation layout, color, copy, spacing, and placeholder clarity.
- Replace the generic placeholder with a Leaderboard-specific static layout.
- Add or update widget coverage only for stable visible Leaderboard text or placeholder behavior if copy changes.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if stable visible text expectations need updates.

## Forbidden Scope

- No Firebase, Auth, Firestore, Cloud Functions, FCM, or backend work.
- No GPS/location behavior.
- No real leaderboard data.
- No leaderboard aggregation.
- No XP mutation.
- No streak mutation.
- No level mutation.
- No rank mutation.
- No leaderboard score mutation.
- No weekly XP or monthly XP mutation.
- No subscription privilege state mutation.
- No expert plan publication state mutation.
- No fake users.
- No fake ranks.
- No fake XP.
- No fake scores.
- No shell navigation changes.
- No Home, Maps, Run, or You/Profile changes.
- No dependency changes.
- No native Android/iOS changes.
- No scaffold, build, init, deploy, Firebase setup, or `flutterfire configure` commands.
- No Phase 02 selection.

## Future Implementation Plan

- Keep the work single-screen and static.
- Replace the generic placeholder with a Leaderboard-specific layout.
- Include a supportive `Leaderboard` title.
- Include calm explanatory copy that future community rankings will appear after setup.
- Include static placeholder sections for consistency, area identity, and friendly progress or motivation.
- Do not show numeric ranks, XP totals, leaderboard scores, streak counts, levels, or fake profile rows.
- Keep controls inert and placeholder-only if any controls are shown.
- Do not implement region bottom sheet behavior unless separately approved in a future capsule.

## Risk Notes

- Do not show fake names, fake XP, fake ranks, or fake leaderboard rows.
- Do not imply real backend data exists.
- Do not introduce client-side ranking or sorting state.
- Do not touch shell navigation because the Leaderboard tab is already part of the shell.
- Do not make the screen feel aggressive, shame-based, or performance-obsessed.

## Future Validation Plan

- `git status --short`
- `git diff --stat`
- `git diff --check`
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`
- `cd implementation/mobile/runiac_app && flutter test`
- `./tools/governance-ci/run-all-checks.sh`

No backend, Firebase, GPS, security-rules, Cloud Functions, or leaderboard aggregation tests are required for this static frontend-only Leaderboard capsule.

Widget tests are recommended only for stable visible text and placeholder behavior, not exact layout, color, pixel values, or private widget structure.

## Done When

- The generic Leaderboard placeholder is replaced by a calm static Leaderboard-specific screen.
- The screen explains future community motivation without implying live backend data.
- Consistency, area identity, and friendly motivation are represented as placeholder sections.
- No fake ranks, users, XP, scores, streaks, levels, profile rows, or backend-owned values are introduced.
- No forbidden files or scopes are touched.
- `flutter analyze --no-pub` passes.
- `flutter test` passes.
- `git diff --check` passes.
- `./tools/governance-ci/run-all-checks.sh` passes.

## Current Routing Evidence

- `maps-static-discovery-hierarchy-polish` is closed at `60fe96f feat(mobile): polish maps discovery hierarchy`.
- Roadmap closure for Maps was pushed at `0725e61 docs(roadmap): close maps discovery polish capsule`.
- No active implementation capsule was selected after Maps closure.
- Plan-only Leaderboard inspection recommended the smallest safe next capsule as static frontend-only Leaderboard motivation hierarchy polish.
- A9_TRACE routing finding: this capsule is roadmap-routed static frontend-only Leaderboard polish and does not authorize Firebase, backend aggregation, GPS/location, real ranking data, fake metrics, dependencies, native changes, or unrelated tab/shell edits.
- A6_REVIEW routing finding: a new capsule is required before implementation and must not imply Phase 02 readiness or backend-owned value behavior.
- A12_QA_TEST routing finding: future implementation should run Flutter analyze, Flutter widget tests, diff whitespace check, and local Governance CI; backend/Firebase tests are not required for static UI-only scope.

## Exit Criteria

- [ ] Leaderboard static motivation hierarchy polish implemented inside the allowed files.
- [ ] Static frontend-only behavior preserved.
- [ ] No forbidden files or scopes touched.
- [ ] Required validation completed.
- [ ] Capsule, CURRENT.md, and snapshot updated with confirmed implementation state.
