# leaderboard-region-preview-sheet-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only Leaderboard region preview sheet shell.

## Status

Status: Closed.

Routed on: 2026-05-27 Asia/Singapore.

Ready for commit on: 2026-05-27 Asia/Singapore.

Closed on: 2026-05-27 Asia/Singapore.

Completion commit: `09d6389 feat(mobile): add draggable leaderboard region preview sheet`.

Hosted validation: GitHub Actions Governance CI #41 PASS for commit `09d6389`.

Depends on:

- `implementation/roadmap/capsules/leaderboard-map-first-landing-shell.md` closed at `b1ed742 feat(mobile): add leaderboard map landing shell`.
- `implementation/roadmap/capsules/leaderboard-help-modal-shell.md` closed at `96a2706 feat(mobile): add leaderboard tips popup`.
- `implementation/roadmap/capsules/flutter-frontend-hygiene-cleanup.md` closed at `8074092 chore(mobile): apply frontend hygiene cleanup`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add one visible static Leaderboard UI improvement: a region preview bottom sheet shell over the existing map-first Leaderboard surface, using display-only placeholder content and preserving all backend-owned leaderboard boundaries.

## Implementation Summary

- Added a static rounded region preview bottom sheet to the Leaderboard tab.
- Preserved the existing static map-like Leaderboard background and bottom navigation.
- Used only display-only placeholder labels and skeleton-style preview rows.
- Added inert visual-only `View More Ranking` and `Share My Rank` CTA labels without navigation, sharing, premium gating, subscription logic, or backend behavior.
- Updated widget tests for safe labels, bottom navigation visibility, and forbidden copied/fake wireframe data absence.
- Updated Governance CI diff hygiene allowlist only for this routed capsule document.
- Refined the sheet to support static local vertical dragging with two stable visual states: expanded at the approved screenshot height and collapsed to handle-only.
- Added map/ranked-area tap expansion without real map, GPS, region lookup, ranking, navigation, or backend behavior.

## Visual Direction

- Use the provided bottom sheet wireframe as a layout reference only.
- Keep the existing static map-like Leaderboard background.
- Add a rounded bottom sheet over the map surface.
- Show a display-only region title such as `Jurong East`.
- Show a display-only context label such as `Weekly XP · Rising Runner Division`.
- Include a preview section shell.
- Include a `My Rank Preview` card shell.
- Include visual-only CTA buttons: `View More Ranking` and `Share My Rank`.
- Keep the existing bottom navigation visible.
- The expanded state remains the approved screenshot-height visual state.
- The collapsed state exposes only the drag handle over the map surface.

## Allowed Scope

- Static frontend-only Leaderboard presentation work.
- Display-only placeholder text that does not represent real leaderboard data.
- Existing Flutter widgets and existing dependencies only.
- Local state and gesture handling for static sheet expansion/collapse.
- Local widget-test updates for stable visible labels and forbidden copied/fake content absence.
- Minimal `CURRENT.md`, capsule, and snapshot updates required by roadmap governance.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/capsules/leaderboard-region-preview-sheet-shell.md`
- `implementation/roadmap/snapshots/latest.md`
- `tools/governance-ci/check-diff-hygiene.sh` only to allowlist this routed capsule document for Governance CI diff hygiene.

## Safe Display-Only Labels

- `Jurong East`
- `Weekly XP · Rising Runner Division`
- `Region Preview`
- `My Rank Preview`
- `Ranking preview pending`
- `Your position will appear after leaderboard data is ready.`
- `View More Ranking`
- `Share My Rank`

## Forbidden Scope

- No real leaderboard data.
- No fake users.
- No fake ranks.
- No fake XP.
- No fake scores.
- No fake levels.
- No sorting or ranking logic.
- No leaderboard aggregation logic.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state mutation or calculation.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, or backend work.
- No `flutterfire configure`.
- No Google Maps or Mapbox SDK integration.
- No GPS/native configuration.
- No dependency changes or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No share sheet integration.
- No premium gating or subscription logic.
- No navigation changes outside the Leaderboard tab.
- No internal scrolling inside the bottom sheet.
- No unrelated refactors.
- No new ADRs.
- No Phase 02 selection.

## Required Validation

```bash
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

## Validation Evidence

- `git diff --check` PASS.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS.
- `cd implementation/mobile/runiac_app && flutter test` PASS after a rounded-border paint assertion was fixed, and again after the draggable sheet refinement.
- `./tools/governance-ci/run-all-checks.sh` PASS after adding the routed capsule document to the diff-hygiene allowlist.
- `git status --short` shows only task-relevant unstaged changes.

## Widget Test Expectations

- Confirm the Leaderboard tab shows the static region preview sheet.
- Confirm bottom navigation labels remain visible.
- Confirm safe labels and visual-only CTA labels appear.
- Confirm the drag handle exists.
- Confirm dragging the sheet and tapping the ranked area/map region area do not throw and restore the expanded visual labels.
- Confirm forbidden copied/fake content remains absent, including `Alex`, `Maya`, `Ryan`, `#18`, `Lv.18`, `520 XP`, `1,240 XP`, `1,180 XP`, and `1,050 XP`.

## Risk Notes

- The preview sheet must not imply live ranking data exists.
- CTA controls must remain visual-only and inert.
- The region label must not imply GPS lookup or real location state.
- The visual reference must not be copied as data.
- Drag behavior must move the whole sheet; it must not introduce internal sheet scrolling.

## Closure Scope Review

- No fake users, fake ranks, fake XP, fake scores, fake levels, sorting, ranking logic, or leaderboard aggregation was introduced.
- No Firebase, Auth, Firestore, Cloud Functions, GPS/native configuration, map SDK, sharing integration, premium gating, subscription logic, dependency, `pubspec.yaml`, Android/iOS native, or Phase 02 work was introduced.
- Implementation was committed at `09d6389 feat(mobile): add draggable leaderboard region preview sheet`.
- Hosted GitHub Actions Governance CI #41 passed for commit `09d6389`.

## Done When

- [x] A static region preview bottom sheet shell is visible on the Leaderboard tab.
- [x] Safe display-only labels are used.
- [x] Existing bottom navigation remains visible.
- [x] CTA labels are visual-only and inert.
- [x] Bottom sheet supports static vertical drag between expanded and handle-only collapsed states.
- [x] Tapping the map/ranked area expands the sheet without real map or ranking behavior.
- [x] No fake users, fake ranks, fake XP, fake scores, fake levels, or backend-owned value logic is introduced.
- [x] No forbidden files or scopes are touched.
- [x] Required validation passes.
- [x] Capsule, `CURRENT.md`, and snapshot are updated with confirmed ready-for-commit state.
