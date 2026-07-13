# Home and You State Stability

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly routed IMPLEMENTATION_MODE reliability fix isolated in `/Users/leejinseo/Desktop/FYP_Runiac-home-you-state-stability`.

## Goal

Stabilize Home and You state across shell tab round trips, same-UID cache-first progress/history loading, owner changes, refresh failures, and loading surfaces without false zero/default flashes or client-side backend-owned progression logic.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Flutter shell state retention, current-session progress/history coordination, and loading-state correctness.
- Status: `Implemented; Ready for manual commit after user review`.
- Current active capsule in this isolated worktree: `implementation/roadmap/capsules/home-you-state-stability.md`.
- Commit boundary: no automatic staging, commit, push, deployment, or production mutation. The full package stops at `Ready for manual commit` after later implementation and review gates.
- Todo boundary: this routing todo creates/selects the capsule only; it does not modify Flutter product source, tests, Firebase/backend, native files, dependencies, or Activity Feedback paths.

## Required Review Chain

Routing-only todo:

```text
A0_ORCH -> A6_REVIEW -> A8_OUTPUT_CHECKER
```

Implementation/test todos:

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A13_SECURITY_RULES -> A8_OUTPUT_CHECKER
```

## Allowed Future Product Scope

- Lazy retained shell tabs for Home and You, with Run remaining route-only and never selected/visited as a retained tab.
- Home/You lifecycle stability across at least two Home <-> You round trips.
- Cache-first same-UID user progress display before a held authoritative remote refresh.
- One app/session-owned user-progress coordinator with request coalescing, owner UID isolation, generation protection, last-good retention, retryable initial failure, and no intermediate null/zero on refresh.
- Store-owned Activity History cache/default-source loading with last-good graph retention, distinguishable unknown/loading/confirmed-empty states, retry, owner isolation, and late-owner-result rejection.
- Truthful Home and You loading surfaces that do not present `0`, `Lv.0`, ring `0`, fallback initials, or a confirmed twelve-zero graph as real loaded user data while data is unknown.
- Focused widget/unit tests and final full Flutter/governance validation after implementation.

## Allowed Files for Later Todos

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/current_session_feed.dart` (only for retained-tab-safe post-frame author-profile sync)
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map.dart`
- `implementation/mobile/runiac_app/lib/features/you/domain/models/activity_history_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/you/domain/repositories/activity_history_repository.dart`
- `implementation/mobile/runiac_app/lib/features/you/domain/repositories/user_progress_repository.dart`
- `implementation/mobile/runiac_app/lib/features/you/data/firestore_activity_history_repository.dart`
- `implementation/mobile/runiac_app/lib/features/you/data/firestore_user_progress_repository.dart`
- `implementation/mobile/runiac_app/lib/features/you/data/local_user_progress_cache_store.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/activity_history_display_controller.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/current_session_activity_history.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/current_session_user_progress.dart` (new, only if implementation proceeds)
- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/monthly_distance_graph.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/you_progress_surface.dart`
- `implementation/mobile/runiac_app/test/activity_history_display_controller_test.dart`
- `implementation/mobile/runiac_app/test/current_session_activity_history_cache_test.dart` (new, only if implementation proceeds)
- `implementation/mobile/runiac_app/test/current_session_user_progress_test.dart` (new, only if implementation proceeds)
- `implementation/mobile/runiac_app/test/current_day_rollover_test.dart`
- `implementation/mobile/runiac_app/test/firestore_activity_history_repository_test.dart`
- `implementation/mobile/runiac_app/test/firestore_user_progress_repository_test.dart`
- `implementation/mobile/runiac_app/test/home_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/shell_tab_lifecycle_test.dart` (new, only if implementation proceeds)
- `implementation/mobile/runiac_app/test/widget_test.dart`
- `implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart`
- `implementation/roadmap/capsules/home-you-state-stability.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh` (routed-capsule allowlist entry only)

## Forbidden Scope

- No Flutter product source or test changes during this routing-only todo.
- No Firebase, Firestore rules, Cloud Functions, backend, native Android/iOS, dependency, generated, build, scaffold, init, deploy, or secret/config changes unless a later explicitly authorized implementation todo requires and validates them.
- No new SharedPreferences Activity History copy or sensitive route/GPS payload persistence.
- No raw GPS geometry expansion and no durable prompt/generated-feedback storage.
- No unrelated Activity Feedback changes, including:
  - `implementation/roadmap/capsules/activity-summary-agent-feedback.md`
  - `.omo/evidence/activity-feedback/`
  - `implementation/mobile/runiac_app/lib/core/assets/runiac_assets.dart`
  - `implementation/mobile/runiac_app/lib/features/run/data/cloud_function_activity_feedback_agent.dart`
  - `implementation/mobile/runiac_app/lib/features/run/data/local_activity_feedback_cache_store.dart`
  - `implementation/mobile/runiac_app/lib/features/run/domain/models/activity_feedback_agent.dart`
  - `implementation/mobile/runiac_app/lib/features/run/domain/services/activity_feedback_payload_builder.dart`
  - `implementation/mobile/runiac_app/lib/features/run/presentation/view_summary_screen.dart`
  - `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/activity_feedback_overlay.dart`
  - `implementation/mobile/runiac_app/test/activity_feedback_payload_builder_test.dart`
  - `implementation/mobile/runiac_app/test/activity_feedback_overlay_test.dart`
  - `implementation/mobile/runiac_app/test/cloud_function_activity_feedback_agent_test.dart`
- No unrelated cadence, Run completion, Feed/Friends, Leaderboard, design, debug-journal, or roadmap capsule work.
- No automatic commit, push, staging, destructive cleanup, or broad `git add .`.

## Backend Ownership Boundaries

- Flutter may display backend-provided XP, streak, level, rank, leaderboard, weekly XP, monthly XP, subscription, and expert-publication state when available.
- Flutter must not directly calculate or write XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, expert plan publication state, or validated activity contribution state.
- Progress/history stores may coordinate reads, cache display, last-good state, retry, owner isolation, and UI loading state only.
- Authoritative calculation and mutation remain owned by Cloud Functions / trusted backend flows.

## Acceptance Criteria

- Routing-only Todo 1:
  - [x] Baseline `git status --short`, branch, worktrees, and pre-work `git diff --name-only` are captured outside the repository.
  - [x] Capsule names Home/You lifecycle, cache-first display, UID isolation, tests, forbidden backend-owned calculations, and manual commit stop.
  - [x] `implementation/roadmap/CURRENT.md` selects this isolated capsule without touching cadence, Activity Feedback, or product implementation files.
  - [x] Diff hygiene allowlist is updated only if required for this new capsule file.
  - [x] Negative diff-hygiene scenario proves an out-of-allowlist temporary path is rejected and then cleaned up.
  - [x] Cadence capsule files and Activity Feedback paths remain unchanged.

- Later implementation/test todos:
  - [x] Home and You retain requested state across at least two round trips without repeated initial repository loads.
  - [x] Unvisited You performs no Activity History read before first visit.
  - [x] Same-UID progress/history cache can render before a held refresh, and fresh remote data replaces it without false zero/empty intermediate state.
  - [x] Refresh failure keeps last-good data; no-cache initial failure exposes retry.
  - [x] Owner A clears synchronously before owner B, and late A cache/Future results cannot render for B.
  - [x] Unknown progress/profile/history is visually loading, not valid-looking zero/default user data.
  - [x] Focused tests, `flutter analyze --no-pub`, `flutter test --no-pub`, `git diff --check`, Governance CI, review gates, and real-screen evidence are completed before final Ready-for-manual-commit handoff.

## Validation Plan

Routing-only Todo 1:

```bash
git status --short
git branch --show-current
git worktree list --porcelain
git diff --name-only
git diff --check
./tools/governance-ci/run-all-checks.sh
tools/governance-ci/check-diff-hygiene.sh
git diff --name-only
git status --short
```

Later implementation/test todos add focused Flutter tests, full Flutter analyze/test, review roles, and real-screen evidence as required by the plan.

## Done When

- [x] Routing files are limited to this capsule, `CURRENT.md`, and the exact governance allowlist entry required for the new capsule file.
- [x] `git diff --check` passes.
- [x] Governance CI is run and any failure is classified as introduced by this routing change or pre-existing/unrelated with exact evidence.
- [x] Negative diff-hygiene evidence is captured and the temporary path is removed.
- [x] Regression evidence confirms cadence capsule files and Activity Feedback paths are unchanged.
- [x] No staging, commit, push, product source/test implementation, backend, native, dependency, or destructive cleanup was performed.

## Routing Todo 1 Evidence

Captured under `/private/tmp/runiac-home-you-state-stability/`:

- `task-1-routing.txt`: baseline and after-edit status, `git diff --check`, and full Governance CI transcript.
- `task-1-diff-hygiene-negative.txt`: temporary out-of-allowlist file rejection and cleanup verification.
- `task-1-regression.txt`: changed-path inventory and cadence / Activity Feedback unchanged checks.

Todo 1 verification summary:

- `git diff --check`: PASS.
- `tools/governance-ci/check-diff-hygiene.sh`: PASS after the routed capsule allowlist entry.
- `./tools/governance-ci/run-all-checks.sh`: FAIL, not introduced by these routing files:
  - `check-canonical-root.sh` rejects the isolated worktree path and instructs launch from `/Users/leejinseo/Desktop/FYP_Runiac`, which would verify the shared worktree rather than this isolated task worktree.
  - `check-pre-scaffold-scope.sh` reports already tracked Firebase, Functions, Feed, Activity Feedback, and roadmap artifacts outside this routing diff.
  - `tests/governance/backend_functions_scope_test.sh` fails while copying `implementation/roadmap/CURRENT.md` with `Operation not permitted` under the sandboxed isolated-worktree run.

## Implementation Evidence

Captured under `/private/tmp/runiac-home-you-state-stability/`:

- `final-analyze-8.txt`: `flutter analyze --no-pub` PASS.
- `final-focused-tests-8.txt`: focused Home/You state-stability suite PASS, 108 tests.
- `final-diff-check-8.txt`: `git diff --check` PASS.
- `final-diff-hygiene-8.txt`: `tools/governance-ci/check-diff-hygiene.sh` PASS.
- `final-flutter-test-8.txt`: `flutter test --no-pub` FAIL with the same known baseline failures reproduced from the main worktree baseline; no new Home/You lifecycle failure remained.
- `main-full-flutter-test.txt`: main baseline full test evidence used for comparison.

Focused test coverage added or updated:

- `test/shell_tab_lifecycle_test.dart`: lazy retained tabs, Home/You round trips, Run route-only behavior, and unvisited You no-load boundary.
- `test/current_session_user_progress_test.dart`: same-UID cache-first progress, coalesced refresh, last-good retention, retryable initial failure, owner isolation, late-result rejection, corrupt/wrong-owner/stale cache rejection, and app-level auth-owner wiring.
- `test/current_session_activity_history_cache_test.dart`: last-good You graph/history retention after refresh failure.
- `test/home_static_ui_test.dart`: Home unknown progress loading surface avoids false `0`/`Lv.0`/zero-ring semantics.
- `test/home_static_ui_test.dart`: Home unknown profile loading surface avoids fallback initials/profile badge while progress is already known.
- `test/you_tab_static_ui_test.dart`: You date reload preserves visible progress, auth-owner session progress cache renders before held refresh, and unknown Activity History shows loading instead of a valid-looking zero graph.

Real-screen simulator evidence:

- Temporary QA target was created outside the repository at `/private/tmp/runiac_home_you_state_qa.dart`, run on iPhone 17 simulator `F2239630-B316-4124-B490-3EAE123B0ECF`, then deleted.
- Final initial Home screenshot: `/var/folders/rr/m2x0dsw50pj92grp7x75d45r0000gn/T/screenshot_optimized_2c37f7de-70a3-4510-8780-d3bb6fa59a68.jpg` showed streak `4` and badge `Lv.4`, not default `0` / `Lv.0`.
- Final first You screenshot: `/var/folders/rr/m2x0dsw50pj92grp7x75d45r0000gn/T/screenshot_optimized_1790a6c5-f715-430d-bbf0-0dad5dc66eb7.jpg` showed the weekly distance graph and `Consistency Streak` as `4 days`.
- Final after Home -> You round trip, Home screenshot `/var/folders/rr/m2x0dsw50pj92grp7x75d45r0000gn/T/screenshot_optimized_e0923ee6-8cd8-4533-8417-3c6edcd8261a.jpg` still showed the non-default progress state.
- Final after returning to You, screenshot `/var/folders/rr/m2x0dsw50pj92grp7x75d45r0000gn/T/screenshot_optimized_1e8cf019-2502-4fa5-9538-d40ab688be21.jpg` still showed the same weekly graph and `4 days` streak.

Full `flutter test --no-pub` known baseline failures still present and left unchanged:

- `static_repository_contract_test.dart: Static repositories return demo-preserving Run values`
- `static_repository_contract_test.dart: Static repositories completeRun returns zero summary values for zero run payloads`
- `auth_gate_test.dart: stale missing profile probe does not sign out newer signed-in session`
- `run_flow_static_ui_test.dart: View summary static content and actions match design`
- `run_flow_static_ui_test.dart: Share Route opens a Feed confirmation preview`
- `run_flow_static_ui_test.dart: Share Route uses a summary route thumbnail when no artifact resolver is injected`
- `firebase_run_repository_test.dart: FirebaseRunRepository maps callable response into CompleteRunResult`
