# flutter-static-ui-demo-config-extraction

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter UI Fast Lane presentation-data extraction capsule.

## Status

Status: Closed after implementation, local validation, and commit `bdc1a47 refactor(mobile): extract static ui demo data`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Move the smallest practical set of static Flutter demo/display values out of large widgets and run domain model files into lightweight presentation data/config objects while preserving existing visuals and behavior.

This capsule does not add backend integration, runtime configuration, Remote Config, navigation changes, tracking changes, or new dependencies.

## Scope

Allowed implementation files:

- `implementation/mobile/runiac_app/lib/core/assets/runiac_assets.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/data/home_dashboard_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/widgets/today_plan_card.dart`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/run_summary_snapshot.dart`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/xp_update_display_model.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/data/run_launch_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/data/run_completion_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/view_summary_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/xp_update_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/share_achievement_sheet.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/data/maps_route_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/saved_routes_screen.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/widgets/shared_routes_sheet.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/test/home_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/run_flow_static_ui_test.dart`

Allowed roadmap files:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/flutter-static-ui-demo-config-extraction.md`

## Required Refactor

- Keep the Flutter UI visually unchanged.
- Move run completion default demo values out of run domain model files and into presentation data.
- Move Run launch/live demo display values out of `run_launch_screen.dart` and into feature-local presentation data.
- Move Home Today’s Plan static display copy and asset path into Home presentation data.
- Move Maps saved/shared route demo values into Maps presentation data.
- Consolidate only clearly reused asset path strings into a small shared asset constants file.
- Do not introduce a global config framework, code generation, dependencies, Firebase Remote Config, or runtime configuration loading.
- Do not extract layout tokens unless a clear repeated pattern is already present.

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
- route ownership
- shared route metadata
- activity saved/synced state

Any XP, streak, level, rank, leaderboard, route, or activity-looking values touched by this capsule remain presentation-only demo/display placeholders.

## Forbidden Scope

- No Phase 02 selection.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No real GPS/tracking, activity saving/syncing, XP, streak, level, rank, leaderboard, subscription, or expert plan logic.
- No Firebase Remote Config or large configuration framework.
- No intentional UI, navigation, or run-tracking behavior changes.
- No staging, commit, or push was authorized during the original capsule execution; the completed capsule is now recorded as committed at `bdc1a47 refactor(mobile): extract static ui demo data`.

## Required Validation

```bash
dart format <modified Dart source files>
cd implementation/mobile/runiac_app && flutter analyze
cd implementation/mobile/runiac_app && flutter test
git diff --check
git status --short
```

## Done When

- [x] This capsule is selected before closure.
- [x] Run domain model files contain model types only, not default demo display data.
- [x] Home Today’s Plan static copy and asset path are presentation data.
- [x] Run launch/live and run completion demo values are presentation data.
- [x] Maps saved/shared route demo values are presentation data.
- [x] Clearly duplicated asset paths are consolidated without widening into a global config framework.
- [x] No backend/native/Firebase/dependency files are changed.
- [x] Required validation passes.
- [x] Original capsule execution stopped before commit/push as required.
- [x] Follow-up roadmap reconciliation records the completed capsule commit: `bdc1a47 refactor(mobile): extract static ui demo data`.
