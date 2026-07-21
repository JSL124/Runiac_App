# plan-completion-signal

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Mode / Type

Mode: IMPLEMENTATION_MODE (explicit user routing and implementation request on 2026-07-21 Asia/Singapore). The user asked to wire the real plan-completion trigger, execute the QA scenario, and commit.

Type: Backend Guarded Lane capsule (Cloud Functions server-owned signal + Flutter display-only consumption), emulator-first per ADR-002, lane classification per ADR-003.

## Goal

Give the already-implemented `showPlanCompletionCeremony` overlay a real, server-computed trigger. Before this capsule the ceremony was unreachable production code behind a compile-time `false` debug flag, because no plan-completion state existed anywhere — only per-workout completion was tracked.

The `completeRun` callable now records, inside its existing transaction, when the workout being completed is the one that finishes the active generated plan. The client reads that trusted field and celebrates exactly once. The client never derives, computes, or writes plan-completion state.

## Completion Rule (record exactly)

Evaluated inside the existing `completeRun` Firestore transaction, in `persistCompletedWorkoutProgress`, only on the path where a planned workout is actually being recorded as completed:

1. `plannedWorkoutTotal` = the number of planned workouts in the trusted plan snapshot, using the **same** `readPlannedWorkouts` filter already used for matching — rest workouts and objective-less workouts are excluded.
2. `planCompletedWorkoutCount` = the number of existing `workouts` keys prefixed `"<generatedPlanId>__"`, plus `1` for the workout being recorded in this transaction.
3. The plan is recorded as completed only when `planCompletedWorkoutCount >= plannedWorkoutTotal`.
4. Scoping is **per generated plan**, not the lifetime `completedWorkoutCount` counter, which spans every plan the user has ever run. A previous plan's completed workouts must never finish the current plan.
5. Nothing is written when the plan cannot be scoped (`sourceGeneratedPlanId` undefined), when `plannedWorkoutTotal <= 0`, when workouts remain, or when this plan already has a `planCompletions` entry — so the first completion timestamp is never overwritten by a replay or by an extra run on a finished plan.
6. On completion, `planProgress/{uid}.planCompletions[planId]` is merged with `{planId, completedAt, completedWorkoutCount, plannedWorkoutTotal}`, where `completedAt` is the run's validated `completedAt`.

Idempotency is inherited from the surrounding transaction and from the existing duplicate-workout-key guard: a replayed `completeRun` for an already-recorded workout returns before any write.

## Client Rule (display-only)

- `PlanProgressReadModel` gains `planCompletedAt`, parsed from `planCompletions[activeGeneratedPlanId].completedAt`. A completion recorded for a different plan, a malformed entry, or a missing map all yield `null`.
- `HomeTab` celebrates when `planCompletedAt` is newer than a local `PlanCompletionSeenStore` high-water marker, then advances the marker. The marker is advanced **before** the overlay opens, so a crash or force-quit mid-animation cannot leave the celebration re-firing on every launch.
- The seen store is a local, uid-scoped `shared_preferences` integer only — no Firestore access, no trusted state, mirroring `ChallengeResultSeenStore`.
- The celebration is checked on first frame, on app resume, and on `didUpdateWidget` (plan progress loads asynchronously, so the signal usually arrives after the first frame).

## Allowed Scope

- `functions/src/plan/planProgress.ts`: compute `plannedWorkouts` once and pass it to `findMatchedWorkout` (pure refactor, no behavior change); add `resolvePlanCompletion`, `countCompletedWorkoutsForPlan`, and `readPlanCompletions`; merge the `planCompletions` fragment into the existing `transaction.set`. No new reads, no new trigger, no change to the callable response contract.
- `functions/test/planProgressCompletion.test.ts`: new pure unit tests for the completion rule (no emulator required).
- `functions/test/feedCallableSurface.test.ts`: repair of the stale whole-entrypoint export allow-list (see the repair section below). Assertion-data change only — no production source change, no export added or removed.
- `functions/package.json`: one additive entry in the existing `test` script list.
- `implementation/mobile/runiac_app/lib/features/plan/domain/models/plan_progress_read_model.dart`: additive `planCompletedAt` field and parsing.
- `implementation/mobile/runiac_app/lib/features/plan/domain/plan_completion_seen_store.dart` and `.../features/plan/data/shared_preferences_plan_completion_seen_store.dart`: new one-shot marker port and durable adapter.
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`: remove the `_kDebugShowPlanCompletionCeremony` stub and its TODO; add `planCompletedAt` / `planCompletionSeenStore` inputs and the one-shot `_maybeCelebratePlanCompletion` path.
- `implementation/mobile/runiac_app/lib/features/home/presentation/plan_completion_ceremony.dart`: doc-comment correction only (the "nothing calls this" note is now false).
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart` and `lib/app.dart`: pass-through wiring, plus the fix so the "empty progress collapses to null" shortcut no longer discards a completion-only signal.
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart` and `lib/main.dart`: compose the durable seen store on Firebase-active paths, `null` on the static/no-config path.
- `implementation/mobile/runiac_app/lib/features/home/presentation/qa/plan_completion_qa_launcher.dart`: QA surface (`RUNIAC_QA_SURFACE=plan_completion`) that exercises the overlay without Firebase auth, mirroring the existing XP/Feed/Leaderboard QA launchers; release-mode guarded.
- `implementation/mobile/runiac_app/test/plan_completion_trigger_test.dart`: new model-parsing and one-shot presentation tests.
- Governance files: this capsule file, `implementation/roadmap/CURRENT.md` (append-only), `tools/governance-ci/check-diff-hygiene.sh` and `tools/governance-ci/check-pre-scaffold-scope.sh` (routed-capsule allowlist entries only).

## Forbidden Scope

- No client calculation, inference, or writing of plan-completion state, XP, level, rank, streak, leaderboard score, weekly/monthly XP, subscription privilege, or expert-plan publication state. The client only reads `planCompletions` and renders.
- No new Firestore trigger, no new callable, no change to the `completeRun` callable response contract or to `PlanCompletionResult` (whose `completed` field means "a planned workout was recorded", not "the plan is finished" — the two must not be conflated).
- No change to XP, streak, leaderboard, or progression-audit behaviour. Plan completion awards nothing; it is presentation only.
- No premium advantage: the ceremony is identical for Basic and Premium Users.
- No `firestore.rules` change — `planProgress/{uid}` is already fully backend-owned (`allow create, update, delete: if false`), so the new field is unwritable by clients by construction.
- No new dependencies, no `firebase init`, no `flutterfire configure`, no production deploy, no secrets.
- No edits to unrelated capsule scope, and no reordering of any existing `CURRENT.md` routing bullet — additions are append-only.

## Exact Target Files

- `implementation/roadmap/capsules/plan-completion-signal.md`
- `functions/src/plan/planProgress.ts`
- `functions/test/planProgressCompletion.test.ts`
- `functions/test/feedCallableSurface.test.ts`
- `functions/package.json`
- `implementation/mobile/runiac_app/lib/features/plan/domain/models/plan_progress_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/plan/domain/plan_completion_seen_store.dart`
- `implementation/mobile/runiac_app/lib/features/plan/data/shared_preferences_plan_completion_seen_store.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/plan_completion_ceremony.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/qa/plan_completion_qa_launcher.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/test/plan_completion_trigger_test.dart`
- `implementation/roadmap/CURRENT.md` (append-only)
- `tools/governance-ci/check-diff-hygiene.sh` (routed-capsule allowlist entry only)
- `tools/governance-ci/check-pre-scaffold-scope.sh` (routed-capsule allowlist entry only)

## Required Tests

```bash
cd functions && npm run build
cd functions && npm test
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test --no-pub
```

- `functions/test/feedCallableSurface.test.ts`: the whole-entrypoint export guard and the Feed-subset/leak guards pass against the real 46-export surface.
- `functions/test/planProgressCompletion.test.ts`: no completion while workouts remain; completion on the final planned workout; no re-record or overwrite for an already-completed plan; a previous plan's workouts do not finish the current plan; rest days and objective-less entries excluded from the planned total; replayed workout writes nothing.
- `implementation/mobile/runiac_app/test/plan_completion_trigger_test.dart`: model parses the active plan's completion, ignores another plan's, tolerates malformed entries, survives with no per-workout entries; `HomeTab` celebrates once, does not re-celebrate an already-seen completion, stays silent while in progress and when no seen store is composed, and celebrates a completion that arrives after the first frame.
- `implementation/mobile/runiac_app/test/plan_completion_ceremony_test.dart`: existing overlay tests remain green.

## Required Validation

- ADR-002 emulator-first validation only, against the Functions/Firestore emulators under project `runiac-functions-test` — no production deploy claim.
- A11_FIREBASE_IMPL for the server-owned signal; A10_FLUTTER_IMPL for the display-only client wiring; A13_SECURITY_RULES to confirm the field lands only on the already backend-owned `planProgress/{uid}` document; A6_REVIEW for boundary/consistency; A12_QA_TEST for the emulator and simulator runs; A8_OUTPUT_CHECKER before any readiness claim.
- `./tools/governance-ci/run-all-checks.sh` and `git diff --check` must pass with only this capsule's files in the diff.

## Required Evidence

- `functions npm test` output covering the new unit tests and the unchanged `completeRun` emulator suite.
- `flutter analyze --no-pub` and full `flutter test --no-pub` output.
- iOS simulator evidence that the ceremony renders both sequence stages (gauge filling, then burst + "Plan Completed!"), captured through the `RUNIAC_QA_SURFACE=plan_completion` QA surface.
- `run-all-checks.sh` output confirming no forbidden/unrelated path is flagged.

## Pre-Existing Failure Repaired Under This Capsule

`functions/test/feedCallableSurface.test.ts` — "exports exactly the production Feed callables and triggers once" was failing against a stale expected export list of 18 names, while the real production entrypoint exports 46. The drift accumulated across the challenge, friends, subscription-expiry, cool-down, admin-command, feedback, and error-reporting capsules, none of which updated the list; the guard had therefore been red and ignored for some time.

This capsule adds no exports and does not touch `functions/src/index.ts`, so the failure was not caused here. It was repaired here on explicit user instruction (2026-07-21 Asia/Singapore) rather than left as a known-red caveat.

The repair restores the guard at full strength instead of weakening it: `expectedExports` now lists all 46 real exports, with a comment recording the maintenance contract — an export in that list is a publicly deployed callable or trigger, so adding a Function must be a conscious reviewed act, and adding one without updating the list is *expected* to fail the suite. The narrower Feed-owned subset assertion and the fixture/helper leak guard are unchanged.

Because the whole-entrypoint assertion lives in a Feed-named file for historical reasons, a comment now records that it covers the entire entrypoint, not just Feed.

## Rollback Conditions

- Any evidence that a plan can be recorded as completed while planned workouts remain, that a previous plan's workouts finish the current plan, that a completion timestamp is overwritten by a replay, or that the ceremony re-fires for an already-celebrated completion.
- Any client code path that infers plan completion locally rather than reading the server-written field.
- Any change to XP, streak, leaderboard, or progression-audit behaviour, or any premium/basic divergence in the celebration.
- Any modification to an unrelated capsule's files, or any reordering of an existing `CURRENT.md` routing bullet.

## Exit Criteria

- [x] Target files completed within the exact scope above.
- [x] Required tests passing (Functions build + suite, Flutter analyze + full suite).
- [x] Required evidence recorded (emulator, simulator, analyze/test output).
- [x] `implementation/roadmap/CURRENT.md` updated (append-only) with this capsule's routing bullet.
- [x] Governance allowlist entries added and `run-all-checks.sh` passing.

## Stop State

Stop at `Committed` — the user explicitly authorized the commit for this task on 2026-07-21 Asia/Singapore. No push is authorized by this capsule document.
