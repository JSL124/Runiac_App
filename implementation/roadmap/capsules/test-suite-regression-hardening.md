# Capsule: Test-Suite Regression Hardening

Status: implemented locally, commit authorized by the user on 2026-07-24.
Routed: 2026-07-24 Asia/Singapore (explicit user request).
Lane: test-only QA hardening. No production source file is modified; the only
non-test change is two test-infra lines in `functions/package.json` chaining
suites into `npm test`.

A full-repository test-validation pass audited the Flutter, Functions,
Firestore-rules, and cross-system suites for regression gaps, then closed the
gaps found. 33 new tests were added, two nondeterministic backend tests were
fixed, and two orphaned suites were wired into the default test command. No
existing assertion was weakened.

## Gaps closed

- **Cross-account cache leakage (Critical class):** `CurrentSessionUserAccount`
  — the session store gating all premium UI — had no owner-switch tests, unlike
  every sibling store. Added a 5-test suite: clear-on-switch, late-result
  discard, stream cutoff, same-uid keep, sign-out clear
  (`current_session_user_account_owner_switch_test.dart`).
- **Rules blind spots (High):** zero-coverage collections now have deny
  matrices: `moderationCommands`, `errorGroups`/`errorReportRateLimit`,
  `leaderboardContributions` (incl. own-uid score injection),
  `progressionEvents`, `users/{uid}` owner-only read, `sharedRoutes`
  update/delete + self-publish, forged `feedPost` create/author-delete
  (8 tests across the three rules test files).
- **Unprotected fixes (High):** regression tests for `daee0021` (feed publish
  allowlist for streak/cool-down fields), the PR #22 client half (Home
  stage-map / You adapter weekday resolution for mid-week `startsOnDate`), and
  `ae155da2` extended to the subscription store.
- **XP cap edges:** cool-down bonus derives from credited daily-capped XP;
  milestone pays in full on a zero-credit daily-capped run; `sumMonthlyXp`
  keeps the streak bonus `sumDailyXp` nets out (pinned asymmetry);
  `cleanupExpiredProjections` retention window; stale `ineligible_min_runs`
  re-evaluation.
- **Suite integrity (High):** `test:challenge` and `test:friends` are now
  chained into `npm test`, and `levelUpLeaderboard.integration.test.js`
  (completeRun → aggregation → Iron→Bronze promotion) joined the main list —
  previously none of these ran under the default command.

## Test defects fixed (no production change)

- `reportAutomation.test.ts`: two tests failed in-suite but passed alone —
  late emulator re-deliveries of `moderationCommand` merges resurrected
  deleted command docs that a collection-wide `size === 0` assertion counted.
  Assertions now target the deterministic command ID.
- `homeGuideAgentCallableSurface.test.ts`: the daily-cap test raced four
  concurrent requests against the daily doc and flaked on the
  `finalize_conflict` fallback split. Now driven sequentially and additionally
  pins that the fourth request is the fallback.

## Observations reported, deliberately not fixed here

- `home_stage_map_model.dart:261-266` marks a future Monday-role stone as
  missed on day 0 of a Wednesday-start plan (slot-index vs resolved-date
  comparison). The new test asserts only the load-bearing invariant
  (`isNot(current)`) and stays valid if this is fixed later.
- The client streak-risk nudge (`runiac_shell.dart:775`) does not consult
  scheduled rest days; cosmetic only, the backend never breaks the streak.
- Repeated `finish()` re-runs teardown side effects but preserves payload
  identity; pinned as safe against the idempotent backend.

## Evidence (2026-07-24)

- `flutter analyze --no-pub` clean; `flutter test --no-pub` **1937/1937**
  (was 1918).
- Functions `npm test` (now main+feed+moderation+challenge+friends)
  **748/748**, 0 skipped: main 480/480 incl. the integration test, feed 43/43,
  moderation 25/25, challenge 169/169, friends 31/31.
- Firestore/Storage rules **117/117** (was 109).
- Governance CI 10/13 locally; the 3 failures are workspace artifacts
  (orca-worktree canonical root; diff-hygiene pending this capsule's own
  registration), not defects.

## Forbidden

- Any production source, rules, or config behaviour change — this capsule is
  test files plus the two `functions/package.json` script lines only.
- Weakening or deleting any existing assertion.
- Any production `runiac-fypp` deploy.
- New dependencies or secrets.
- Edits inside the isolated `adaptive-character-guidance` worktree.

## Open items

- ~~No Functions/Rules tests run in hosted CI (`governance-ci.yml` is
  Flutter-only); adding an emulator job needs a decision on CI minutes.~~
  Closed 2026-07-24: the user authorized the CI-minutes cost and
  `governance-ci.yml` gained a `backend-emulator-tests` job (Node 22,
  Temurin 21, cached emulator binaries) running the full Functions chain and
  the rules suite on every PR.
- Native cadence tests (Kotlin/iOS) run in no automation.
- `tests/cross-system/paywall-config-drift.mjs` and the config-contract drift
  check skip here because `website/` is a separate repo checkout.
