# maps-static-discovery-hierarchy-polish

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only Maps visual hierarchy polish capsule.

## Status

Status: Closed.

Routed on: 2026-05-27 Asia/Singapore.

Completed on: 2026-05-27 Asia/Singapore.

Completion evidence commit: `60fe96f feat(mobile): polish maps discovery hierarchy`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Improve the beginner-friendly Maps route discovery hierarchy while keeping the Maps screen static, calm, and clearly placeholder-only.

## Intended UX Direction

- Improve beginner-friendly Maps route discovery hierarchy.
- Keep the screen static.
- Keep blue for route and structure.
- Use orange lightly for discovery/location accents.
- Keep search, Saved, and Shared Routes understandable.
- Avoid visual noise and metric overload.

## Allowed Scope

- Static frontend-only Maps visual polish.
- Local Maps presentation hierarchy, color, copy, spacing, and placeholder clarity.
- Keep current Maps tab structure and bottom navigation unchanged.
- Preserve safe placeholder meaning for search, saved routes, shared routes, route previews, pins, and route lines.
- Add or update widget coverage only for stable visible Maps expectations if copy changes.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/maps/presentation/maps_tab.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/widgets/maps_top_overlay.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/widgets/shared_routes_sheet.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/widgets/route_preview_card.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/widgets/maps_background.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if stable visible expectations need updates.

## Forbidden Scope

- No Home, Run, shell, Leaderboard, You/Profile changes.
- No Phase 02 selection.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, or backend work.
- No GPS/location permission, current-location state, or location behavior.
- No real map SDK.
- No real map tiles.
- No route generation.
- No route recommendation logic.
- No route persistence.
- No saved-route behavior.
- No fake distance, duration, pace, difficulty, ratings, saved counts, ranking, or activity data.
- No backend-owned XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, premium entitlement, or expert plan publication state computation or mutation.
- No dependencies.
- No native Android/iOS changes.
- No scaffold, build, init, deploy, Firebase setup, or `flutterfire configure` commands.

## Future Validation Plan

- `git status --short`
- `git diff --stat`
- `git diff --check`
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`
- `cd implementation/mobile/runiac_app && flutter test`
- `./tools/governance-ci/run-all-checks.sh`

No backend, Firebase, GPS, or security-rules tests are required for this static frontend-only Maps capsule.

## Done When

- Maps route discovery hierarchy is clearer for a beginner.
- Search, Saved, and Shared Routes remain understandable.
- Blue remains the route/structure color.
- Orange is used lightly for discovery/location accents only.
- Maps remains static, frontend-only, and placeholder-safe.
- No real map, GPS, route, saved-route, backend, or metric behavior is introduced.
- No forbidden files or scopes are touched.
- `flutter analyze --no-pub` passes.
- `flutter test` passes.
- `git diff --check` passes.
- `./tools/governance-ci/run-all-checks.sh` passes.

## Current Routing Evidence

- `run-launch-brand-color-polish` is closed at `e1f9c6d feat(mobile): polish run launch brand colors`.
- No active implementation capsule was selected after Run launch color polish closure.
- Inspect-only Maps pass found the current Maps screen is static and safe, but the route discovery hierarchy can be clearer and more beginner-friendly.
- A9_TRACE routing finding: this capsule is roadmap-routed static frontend-only Maps polish and does not introduce GPS/location, Firebase, backend, real maps, real routes, dependencies, native changes, or backend-owned value behavior.
- A6_REVIEW routing finding: a new capsule is required before implementation and the capsule must not imply Phase 02 readiness.
- A12_QA_TEST routing finding: future implementation should run Flutter analyze, Flutter widget tests, diff whitespace check, and local Governance CI; no backend/Firebase tests are needed.

## Completion Evidence

- Implementation commit: `60fe96f feat(mobile): polish maps discovery hierarchy`.
- Implemented scope: static frontend-only Maps visual hierarchy polish with route/structure blue treatment, light orange discovery/location accents, calmer search/Saved balance, route-card visual polish, and a simpler draggable Shared Routes sheet.
- Bottom sheet closure state: draggable behavior preserved; collapsed state is handle-only; expanded state is capped at `0.5`; subtitle/helper copy and Preview badge removed.
- Validation before implementation commit: `git diff --check` PASS; `flutter analyze --no-pub` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- Required boundary preserved: no Phase 02 selection, Firebase, Auth, Firestore, Cloud Functions, FCM, GPS/location permission, current-location state, real map SDK, real map tiles, route generation, route recommendation logic, route persistence, saved-route behavior, fake route metrics, XP/streak/level/rank/leaderboard, premium entitlement, backend-like data behavior, dependency, native platform, shell navigation, Home, Run, Leaderboard, You/Profile, or unrelated screen changes.

## Exit Criteria

- [x] Maps route discovery hierarchy is clearer for a beginner.
- [x] Static frontend-only behavior preserved.
- [x] No forbidden files or scopes touched.
- [x] Required validation completed.
- [x] Capsule, CURRENT.md, and snapshot updated with confirmed implementation state.
- [x] Closed and pushed; no next capsule selected.
