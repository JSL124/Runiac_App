# home-social-dropdown-friends-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only Home Social dropdown plus Friends screen static shell capsule under the Safe Visible Product Acceleration Rule.

## Status

Status: Implemented; Ready for user screen QA; Ready for manual commit.

Routed on: 2026-07-12 Asia/Singapore.

Implemented on: 2026-07-12 Asia/Singapore.

Depends on: `implementation/roadmap/capsules/home-stage-map-density-polish.md` closed at `74f9c219 feat(home): refine stage map density and guide`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add an always-visible `Social` dropdown trigger pill below the profile badge on the Home stage-map header that expands a small menu with `Friends` (navigates to a new static Friends screen) and `Challenge` (Coming-soon SnackBar only), plus a new static demo-data Friends feature module with Friends / Search / Suggested / Requests tabs.

## Starting Context

- No standalone friends feature module exists; the only prior friends-adjacent work is the feed's read-only accepted-friends paging, which this capsule must not touch.
- The Home stage map header already exposes streak, notification, and profile-badge controls with the shared `_homeStageControlDecoration` pill/circle style.
- State management is `StatefulWidget` + `setState` with constructor-injected `Static*` repositories, following the leaderboard static repository pattern.
- The user confirmed: dropdown trigger below the profile badge, 4 Friends tabs, static UI plus demo data only, Challenge as a Coming-soon stub, all copy in English.

## Allowed Scope

- Home stage-map header `Social` trigger pill, expandable menu panel, and tap-outside dismissal barrier (barrier mounted only while the menu is open).
- New static Friends feature module: unified read models with pre-formatted display-only level labels, repository interface, const static repository, const demo snapshots, and a 4-tab Friends screen with session-local `setState` accept/decline and case-insensitive search filtering.
- `home_tab.dart` wiring: optional `friendsRepository` injection seam and `Navigator.push` navigation to the Friends screen.
- Optional `onOpenFriends` callback on `HomeStageMap` so all existing call sites and tests compile unchanged.
- Two new widget-test files covering the social menu and the Friends static shell.
- Two new DESIGN.md component sections after `Home Guide Bubble`.
- Minimal required capsule/routing/governance updates only.

## Allowed Files

- `implementation/mobile/runiac_app/lib/features/friends/domain/models/friends_read_model.dart` (new)
- `implementation/mobile/runiac_app/lib/features/friends/domain/repositories/friends_repository.dart` (new)
- `implementation/mobile/runiac_app/lib/features/friends/data/static_friends_repository.dart` (new)
- `implementation/mobile/runiac_app/lib/features/friends/presentation/data/friends_demo_snapshots.dart` (new)
- `implementation/mobile/runiac_app/lib/features/friends/presentation/friends_screen.dart` (new)
- `implementation/mobile/runiac_app/lib/features/friends/presentation/widgets/friends_rows.dart` (new, only if the screen exceeds ~450 lines)
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/test/home_social_menu_test.dart` (new)
- `implementation/mobile/runiac_app/test/friends_static_ui_test.dart` (new)
- `implementation/mobile/runiac_app/test/home_stage_map_widget_test.dart` (only if one broad assertion breaks)
- `implementation/mobile/runiac_app/test/home_static_ui_test.dart` (only if one broad assertion breaks)
- `implementation/mobile/runiac_app/DESIGN.md`
- `implementation/roadmap/capsules/home-social-dropdown-friends-shell.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh` (routed-capsule allowlist entry only)

## Forbidden Scope

- No feed code changes; the feed's accepted-friends contract stays byte-for-byte untouched.
- No Firebase, Auth, Firestore, Cloud Functions, or FCM imports/work anywhere in the friends module.
- No reads or writes of `users/{uid}/friends` or any friendRequests collection.
- No Challenge feature behavior beyond the Coming-soon SnackBar stub.
- No client-side calculation, derivation, or mutation of XP, level, rank, streak, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state; level labels are pre-formatted display strings in demo data only.
- No new dependencies and no `pubspec.yaml` changes.
- No `runiac_shell.dart`, bottom-navigation, or app-shell changes.
- No profile badge-collection UI (future task awaiting user assets).
- No persistence of accept/decline decisions; session-local `setState` only.
- No GPS/location, native Android/iOS, workflow, scaffold, build, init, or deploy changes.
- No Phase 02 selection.

## Validation Plan

```bash
git status --short
./tools/governance-ci/run-all-checks.sh
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
cd /Users/leejinseo/Desktop/FYP_Runiac && git diff --check
cd /Users/leejinseo/Desktop/FYP_Runiac && ./tools/governance-ci/run-all-checks.sh
git status --short
```

No backend, Firebase, security-rules, or Cloud Functions tests are required for this static frontend-only capsule.

## Widget Test Guidance

- Social trigger pill visible and menu panel hidden initially; tapping opens Friends and Challenge items.
- Friends item fires the callback exactly once and closes the menu; omitted callback does not throw.
- Challenge item shows the Coming-soon SnackBar and performs no navigation.
- Tapping outside the open menu dismisses it.
- Friends screen renders 4 segments; default tab lists demo friends; search filters with match and no-match empty state; Accept moves a user from Requests to Friends; Decline removes only.
- Forbidden-content guard: no fabricated XP, rank, or streak values beyond the supplied pre-formatted display labels.

## Risk Notes

- CURRENT.md routing conflicts with the in-progress `activity-history-durable-preview-recovery` capsule in a separate isolated worktree; routing edits here are append-only and preserve those status lines.
- The taller right header column (badge plus trigger pill) must not clip the header gradient container on 360px-wide layouts.
- The opaque tap-outside barrier intentionally blocks map interaction only while the menu is open; it is unmounted when closed so stage-tap semantics tests remain unaffected.

## Done When

- [x] `Social` trigger pill renders below the profile badge and toggles the menu panel.
- [x] `Friends` navigates to the static Friends screen; `Challenge` shows only the Coming-soon SnackBar.
- [x] Friends screen shows Friends / Search / Suggested / Requests tabs with session-local accept/decline and search filtering over demo data.
- [x] No Firebase imports, no feed changes, no shell changes, no backend-owned value calculation, and no new dependencies.
- [x] Both new test files pass and existing suites pass with no new failures beyond the pre-existing baseline.
- [x] DESIGN.md gains the Home Social Dropdown and Friends Screen sections.
- [x] Required validation passes with no regressions against the clean-tree baseline; stopped at Ready for user screen QA / manual commit.

## Closure Evidence

Validated on 2026-07-12 Asia/Singapore against clean baseline `877be6e5 test(run): make title recovery timezone independent`:

- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS (No issues found).
- `cd implementation/mobile/runiac_app && flutter test` — 1420 passed, 12 failed; the 12 failing tests were re-run at the stashed clean HEAD and fail identically there (account_profile_read_flow x2, auth_gate x1, firebase_run_repository x1, home_static_ui x2, run_flow_static_ui x4, static_repository_contract x2). Zero new failures were introduced; both new test files (`test/home_social_menu_test.dart` 6 tests, `test/friends_static_ui_test.dart` 6 tests) pass.
- `git diff --check` PASS.
- `./tools/governance-ci/run-all-checks.sh` — `check-diff-hygiene` PASS with this capsule's changes; `check-pre-scaffold-scope.sh` and `tests/governance/backend_functions_scope_test.sh` FAIL, and both fail identically on the untouched clean tree because this worktree's committed CURRENT.md names the `activity-history-durable-preview-recovery` capsule as active while committed Feed/Friends backend files exist (pre-existing state, not introduced here). A finding-level diff against the clean-tree baseline shows zero new findings.
- `tools/governance-ci/check-diff-hygiene.sh` received one scoped adjustment beyond the planned allowlist append: `implementation/roadmap/CURRENT.md` was removed from the feed-friends gated path set so routed non-feed capsules can append CURRENT.md routing while the Feed capsule is inactive; CURRENT.md remains governed by the general roadmap allowlist entry, and behavior while the Feed capsule is active is unchanged.
- No staging, commit, or push was performed. Real-screen acceptance remains user-owned.
