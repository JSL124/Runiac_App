# flutter-frontend-hygiene-cleanup

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter frontend hygiene / behavior-preserving cleanup.

## Status

Status: Closed.

Routed on: 2026-05-27 Asia/Singapore.

Selected on: 2026-05-27 Asia/Singapore.

Closed on: 2026-05-27 Asia/Singapore.

Depends on: `implementation/roadmap/capsules/leaderboard-help-modal-shell.md` closed at `96a2706 feat(mobile): add leaderboard tips popup` and roadmap closure commit `2d1ec46 docs(roadmap): close leaderboard help modal capsule`.

Routing basis: inspect-only Flutter frontend hygiene audit completed after the Leaderboard help modal closure. The audit found no critical blockers and recommended a separate behavior-preserving cleanup capsule before editing frontend code.

Implementation commit: `8074092 chore(mobile): apply frontend hygiene cleanup`.

Closure evidence: local `git diff --check`, `cd implementation/mobile/runiac_app && flutter analyze --no-pub`, `cd implementation/mobile/runiac_app && flutter test`, and `./tools/governance-ci/run-all-checks.sh` passed before commit; hosted GitHub Actions for `8074092` was manually confirmed PASS by the user.

Closure summary: behavior-preserving frontend hygiene cleanup completed. The inactive RunTab shell body path was removed from `RuniacShell` while preserving Run launch route behavior; the redundant `RunControls` wrapper was flattened; safe const constructors/usages were added for small custom painters; and a stable widget-test assertion now confirms `Tips` is absent before tapping `Leaderboard information`.

Closure skipped scope: broad refactors, inert placeholder behavior changes, league selector popup, region tap behavior, region preview sheet, `leaderboard_tab.dart` splitting, and color-system normalization were intentionally left unchanged.

Closure boundary preserved: no Flutter source/test changes in this roadmap closure pass, no new UX features, no fake leaderboard users/ranks/XP/scores/levels/streaks, no backend-owned value mutation, no Firebase/Auth/Firestore/Cloud Functions/FCM, no GPS/location behavior, no native Android/iOS changes, no dependency or `pubspec.yaml` changes, no workflow changes, no broad visual redesign, no broad architecture refactor, no next capsule selection, and no Phase 02 selection.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

Future implementation may add A10_FLUTTER_IMPL if code cleanup is performed.

## Goal

Perform behavior-preserving frontend hygiene cleanup only: remove or clarify stale or unreachable UI paths, simplify tiny redundant wrappers, add safe const constructors/usages, and make small stable test hygiene improvements without changing product behavior.

## Audit Findings To Encode

Main SHOULD FIX findings:

- F01: Investigate, resolve, or document the possible unreachable `RunTab` shell path in `runiac_shell.dart`.
- F02: Treat large `leaderboard_tab.dart` as a maintainability concern, but do not split it unless the change is clearly behavior-preserving and low-risk.

NICE TO HAVE findings:

- F03: Simplify the single-child `Column` wrapper in `run_controls.dart` if still valid.
- F08: Add safe const constructors/usages for small painter/widgets if analyzer-safe.
- F09: Add a small stable widget-test assertion only if useful and non-brittle.
- Conservative palette/local constant cleanup only when duplication is obvious and behavior-neutral.

DO NOT FIX NOW findings:

- F05: Do not change inert placeholder interactions in this capsule.
- F06: Do not implement the league selector popup in this capsule.
- F10: Do not clean `pubspec.yaml` scaffold metadata/comments in this capsule.
- Do not perform broad visual redesign.
- Do not perform broad component extraction without clear behavior-preserving benefit.

## Allowed Future Implementation Files

- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_tab.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/run_controls.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/run_map_placeholder.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/widgets/route_preview_card.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`

## Forbidden Future Scope

- No new UX features.
- No league selector popup.
- No region tap behavior.
- No region preview sheet.
- No fake leaderboard users.
- No fake leaderboard ranks.
- No fake leaderboard XP.
- No fake leaderboard scores.
- No fake leaderboard rows.
- No fake profile rows.
- No backend-owned value mutation.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state mutation.
- No Firebase, Auth, Firestore, Cloud Functions, or FCM.
- No GPS/location behavior, permission, or state.
- No native Android/iOS changes.
- No dependency or `pubspec.yaml` changes.
- No workflow changes.
- No shell navigation redesign.
- No bottom-navigation changes.
- No broad visual redesign.
- No broad architecture refactor.
- No roadmap closure, reactivation, or next-capsule routing unless separately routed.
- No Phase 02 selection.
- No scaffold, build, init, deploy, Firebase setup, or `flutterfire configure` commands.

## Intended Cleanup Priorities

1. F01: Investigate and either resolve or document the possible unreachable `RunTab` shell path.
2. F03: Simplify the single-child `Column` in `RunControls` if still valid.
3. F08: Add safe const constructors/usages for small painter/widgets if analyzer-safe.
4. F09: Add a small stable widget-test assertion only if useful and non-brittle.
5. F02: Do not split `leaderboard_tab.dart` unless the change is clearly behavior-preserving and low-risk.
6. F05/F06/F10: Do not fix in this capsule.

## Decision Rule

If a proposed cleanup risks behavior change, do not perform it.

If cleanup cannot be proven behavior-preserving, report it as future work instead of editing.

Prefer small local cleanup over broad refactors. Avoid changing visual hierarchy, navigation semantics, placeholder behavior, or product meaning.

## Future Widget Test Guidance

- Tests should cover stable visible behavior only.
- Do not assert exact pixels, colors, private widget internals, or custom painter internals.
- If the Run shell path is changed, preserve or update stable navigation expectations.
- If the Leaderboard test is touched, a small stable assertion that `Tips` is absent before tapping the information button is acceptable.
- No backend, Firebase, GPS, security-rules, Cloud Functions, leaderboard aggregation, or native tests are required.

## Future Validation Plan

```bash
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
cd /Users/leejinseo/Desktop/FYP_Runiac && ./tools/governance-ci/run-all-checks.sh
git status --short
```

## Risk Notes

- The cleanup must preserve static frontend-only behavior.
- Placeholder controls that currently do nothing must not become real interactions or disabled visual states unless separately routed.
- The league selector must remain static; its future popup behavior is not part of this capsule.
- Region preview behavior remains a future candidate only and is not authorized here.
- `leaderboard_tab.dart` size is a maintainability concern, but broad extraction is not automatically justified for the FYP/demo state.

## Done When

- [x] The possible unreachable Run shell path is resolved or explicitly documented without changing product behavior.
- [x] Tiny redundant wrappers are simplified where clearly behavior-neutral.
- [x] Safe const constructors/usages are added where analyzer-safe.
- [x] Widget tests are updated only for stable visible behavior if useful.
- [x] No new UX feature, fake data, backend-owned value, Firebase/GPS/native/dependency/workflow scope, broad redesign, broad architecture refactor, or Phase 02 selection is introduced.
- [x] Required validation passes.
