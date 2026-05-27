# leaderboard-leagues-popup-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only Leaderboard leagues popup shell.

## Status

Status: Ready for commit.

Routed on: 2026-05-27 Asia/Singapore.

Ready for commit on: 2026-05-27 Asia/Singapore.

Depends on:

- `implementation/roadmap/capsules/leaderboard-map-first-landing-shell.md` closed at `b1ed742 feat(mobile): add leaderboard map landing shell`.
- `implementation/roadmap/capsules/leaderboard-help-modal-shell.md` closed at `96a2706 feat(mobile): add leaderboard tips popup`.
- `implementation/roadmap/capsules/flutter-frontend-hygiene-cleanup.md` closed at `8074092 chore(mobile): apply frontend hygiene cleanup`.
- `implementation/roadmap/capsules/leaderboard-region-preview-sheet-shell.md` closed at `09d6389 feat(mobile): add draggable leaderboard region preview sheet` with hosted GitHub Actions Governance CI #41 PASS.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add one visible static Leaderboard UI improvement: a separate Leagues popup opened from the league/division pill, using display-only taxonomy rows and preserving the existing Tips dialog, draggable region preview sheet, bottom navigation, and all backend-owned leaderboard boundaries.

## Implementation Summary

- Preserved the existing `Leaderboard information` info icon behavior and Tips dialog.
- Added a separate static Leagues popup opened from the `Rising Runner Division` / `Lv.11 - Lv.20` league pill area.
- Used a white rounded dialog with close X, centered `Leagues` title, and a bordered list of league taxonomy rows.
- Reused existing Flutter widgets and existing custom medal painter styling.
- Updated widget tests for Tips preservation, Leagues popup open/content/dismiss behavior, bottom navigation visibility, and forbidden fake/user-specific leaderboard content absence.
- Updated roadmap records so `leaderboard-region-preview-sheet-shell` is no longer treated as ready-for-commit after commit `09d6389`.

## Visual Direction

- Use the provided Leagues popup wireframe as layout reference only.
- Keep the existing static Leaderboard screen visible behind the overlay.
- Use a rounded white dialog/modal surface.
- Show a close X button and centered title: `Leagues`.
- Show a bordered list of rows, each with a grey medal/badge icon and one league name plus level range.
- Do not mark any row as current, selected, unlocked, earned, ranked, or user-specific.

## Allowed Scope

- Static frontend-only Leaderboard presentation work.
- Display-only league taxonomy text.
- Existing Flutter widgets and existing dependencies only.
- Small widget-test updates for the approved visible UI change.
- Minimal `CURRENT.md`, previous capsule, new capsule, snapshot, and Governance CI diff-hygiene updates required by roadmap governance.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/capsules/leaderboard-region-preview-sheet-shell.md`
- `implementation/roadmap/capsules/leaderboard-leagues-popup-shell.md`
- `implementation/roadmap/snapshots/latest.md`
- `tools/governance-ci/check-diff-hygiene.sh`

## Safe Display-Only Labels

- `Apex Runner League (Lv.81 - Lv.90)`
- `Summitborn League (Lv.71 - Lv.80)`
- `Roadrunner League (Lv.51 - Lv.60)`
- `Endurancer League (Lv.41 - Lv.50)`
- `Milehunter League (Lv.31 - Lv.40)`
- `Pacebreaker League (Lv.21 - Lv.30)`
- `Strideforge League (Lv.11 - Lv.20)`
- `Trailborn League (Lv.1 - Lv.10)`

## Forbidden Scope

- No real leaderboard data.
- No fake users.
- No fake ranks.
- No fake XP.
- No fake scores.
- No fake current user league.
- No current, selected, unlocked, earned, ranked, or user-specific league styling.
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
- No removal or replacement of existing Tips behavior.
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
- `cd implementation/mobile/runiac_app && flutter test` PASS.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git status --short` shows only task-relevant unstaged changes.

## Widget Test Expectations

- Confirm the existing Tips behavior remains available from the info icon.
- Confirm tapping the league/division pill opens the separate Leagues popup.
- Confirm expected static league taxonomy rows appear.
- Confirm close X dismisses the Leagues popup.
- Confirm existing Leaderboard labels and bottom navigation remain visible after dismissal.
- Confirm forbidden fake/user-specific content remains absent, including `#18`, `520 XP`, `Alex`, `Maya`, `Ryan`, fake ranks, fake current-user level indicators, and current/selected/unlocked/earned league wording.

## Risk Notes

- The league list must remain taxonomy-only and must not imply live progression state.
- The `Lv.11 - Lv.20` pill label is display-only and must not become client-side current league calculation.
- The Tips dialog must remain separate from the Leagues popup.
- The region preview sheet must remain draggable and inert.

## Ready-For-Commit Scope Review

- No fake users, fake ranks, fake XP, fake scores, fake current league, sorting, ranking logic, or leaderboard aggregation was introduced.
- No Firebase, Auth, Firestore, Cloud Functions, GPS/native configuration, map SDK, sharing integration, premium gating, subscription logic, dependency, `pubspec.yaml`, Android/iOS native, or Phase 02 work was introduced.
- Existing Tips behavior was preserved.
- No staging, commit, or push was performed.

## Done When

- [x] The previous region preview capsule is recorded as closed at `09d6389` with hosted GitHub Actions Governance CI #41 PASS.
- [x] The info icon still opens the existing Tips dialog.
- [x] Tapping the league/division pill opens a separate static Leagues popup.
- [x] The Leagues popup includes close X, centered title, and all approved taxonomy rows.
- [x] No row is current, selected, unlocked, earned, ranked, or user-specific.
- [x] Existing bottom navigation remains visible.
- [x] Region preview bottom sheet behavior remains intact.
- [x] CTA labels remain visual-only and inert.
- [x] No forbidden files or scopes are touched.
- [x] Required validation passes.
- [x] Capsule, `CURRENT.md`, previous capsule, snapshot, and diff-hygiene allowlist are updated.
