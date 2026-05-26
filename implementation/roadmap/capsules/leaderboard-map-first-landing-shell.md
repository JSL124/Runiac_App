# leaderboard-map-first-landing-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only Leaderboard landing shell.

## Status

Status: Selected for implementation; implementation not started.

Routed on: 2026-05-27 Asia/Singapore.

Supersedes: `implementation/roadmap/capsules/leaderboard-static-motivation-hierarchy-polish.md`.

Completion evidence commit target: `feat(mobile): add leaderboard map landing shell`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Implement the first map-first Leaderboard landing shell as a static frontend-only screen that establishes the new visual hierarchy without help modal behavior, region tap behavior, ranking preview behavior, real leaderboard data, fake leaderboard data, or backend-owned value logic.

## Intended UX Direction

- Remove the top white header area.
- Make a full-screen map-like background the Leaderboard page surface.
- Add `Weekly XP / Monthly XP` segmented control as a static overlay.
- Add the current league selector as a static overlay below the segmented control.
- Add an info icon button visually on the right near the league selector.
- Highlight the user's own ranked area using a distinct warm accent.
- Keep the default landing state mostly map.
- Keep the screen beginner-friendly, calm, and non-intimidating.
- Use Runiac blue for structure and selection, orange for the user's area highlight, a warm neutral map background, dark navy text, and muted gray helper text.
- Show no bottom sheet by default.

## Allowed Scope

- Static frontend-only Leaderboard map-first landing shell.
- Local Leaderboard presentation layout, color, copy, spacing, and static placeholder clarity.
- Static overlay segmented control for `Weekly XP / Monthly XP`.
- Static overlay current league selector.
- Static visual info icon button.
- Static map-like region background and own-area highlight.
- Add or update widget coverage only for stable visible Leaderboard text or placeholder behavior if needed.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if stable visible expectations need updates.

## Forbidden Scope

- No help modal behavior.
- No region tap behavior.
- No region preview bottom sheet.
- No bottom sheet visible by default.
- No internal ranking preview.
- No fake users.
- No fake ranks.
- No fake XP.
- No fake scores.
- No fake streaks.
- No fake levels.
- No real leaderboard data.
- No leaderboard aggregation.
- No client-side XP calculation.
- No client-side rank calculation.
- No client-side leaderboard score calculation.
- No XP mutation.
- No streak mutation.
- No level mutation.
- No rank mutation.
- No leaderboard score mutation.
- No weekly XP or monthly XP mutation.
- No subscription privilege state mutation.
- No expert plan publication state mutation.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, or backend work.
- No GPS/current-location permission.
- No real location state.
- No real map SDK or real map tiles.
- No shell navigation changes.
- No Home, Maps, Run, or You/Profile changes.
- No dependency changes.
- No native Android/iOS changes.
- No scaffold, build, init, deploy, Firebase setup, or `flutterfire configure` commands.
- No Phase 02 selection.

## Dirty State Boundary

The repository may contain dirty Flutter files from an earlier uncommitted Leaderboard implementation attempt:

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`

Those dirty files are unapproved context only. They are not completion evidence for this capsule, must not be staged as part of routing, and must not be treated as approved final implementation.

## Future Implementation Plan

- Replace the current Leaderboard surface with a map-first static landing shell.
- Keep the default view dominated by the map-like background.
- Place compact static controls as overlays rather than a scroll/card hierarchy.
- Keep the info button visual only in this capsule; route help modal behavior separately.
- Keep regions visual only in this capsule; route region tap and bottom-sheet behavior separately.
- Do not show ranking rows, profile rows, names, numeric ranks, XP totals, leaderboard scores, streak counts, levels, or backend-owned values.

## Future Capsule References

The refined Leaderboard direction should continue later through separate capsules only after this capsule is complete:

- `leaderboard-help-modal-shell`
- `leaderboard-region-preview-sheet-shell`

These future references are not selected by this capsule and are not authorized for implementation here.

## Risk Notes

- `Weekly XP / Monthly XP` must remain static view labels and must not imply live XP data exists.
- The highlighted area must remain a static visual placeholder and must not use GPS/current-location state.
- The info button must not open help UI until a separate help-modal capsule is routed.
- Region visuals must not become tappable until a separate region-preview capsule is routed.
- Do not allow the visual shell to drift into fake leaderboard rows, fake users, fake ranks, fake XP, or fake scores.

## Future Validation Plan

- `git diff --check`
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`
- `cd implementation/mobile/runiac_app && flutter test`
- `cd /Users/leejinseo/Desktop/FYP_Runiac && ./tools/governance-ci/run-all-checks.sh`
- `git status --short`

No backend, Firebase, GPS, security-rules, Cloud Functions, or leaderboard aggregation tests are required for this static frontend-only Leaderboard landing-shell capsule.

Widget tests are recommended only for stable visible text, placeholder behavior, and absence of forbidden fake leaderboard data. Do not test exact pixels, exact colors, private widget structure, or custom painter internals.

## Done When

- The Leaderboard landing screen is map-first and mostly map by default.
- The top white header area is removed.
- Static `Weekly XP / Monthly XP` segmented control is visible as an overlay.
- Static current league selector is visible below the segmented control.
- Static info icon button is visible near the league selector.
- The user's own ranked area is visually highlighted with a warm accent.
- No bottom sheet is visible by default.
- No help modal, region tap, or region preview behavior is introduced.
- No fake ranks, users, XP, scores, streaks, levels, profile rows, or backend-owned values are introduced.
- No forbidden files or scopes are touched.
- Required validation passes.
- Capsule, CURRENT.md, and snapshot are updated with confirmed implementation state.
