# admin-console-leaderboard-oversight

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Mode / Type

Mode: IMPLEMENTATION_MODE (explicit user routing and plan approval on 2026-07-20 Asia/Singapore).

Type: Backend Guarded Lane full-stack capsule (Cloud Functions + Firestore rules + Flutter display wiring + separate `website/` admin console), emulator-first per ADR-002, lane classification per ADR-003.

## Goal

Make the admin console's Leaderboard Oversight page tell the truth about the real leaderboard mechanism, and make the controls it exposes actually work.

The page currently shows several values that do not match the backend, and exposes four controls of which only one is wired. Everything the console displays after this capsule must be derived from real Firestore state; nothing may be fabricated.

## Verified Backend Facts (record exactly)

These were confirmed by reading production code and must not be re-derived from documentation:

- Aggregation is a single scheduled function `refreshLeaderboardSnapshots`, running **every 60 minutes** in `asia-southeast1` (`functions/src/leaderboard/monthlyLeaderboard.ts:55-67`). There is no `onWrite` aggregation and no inline aggregation in `completeRun`.
- The period model is the **Singapore calendar month** (`YYYY-MM`) only (`monthlyLeaderboardPeriod.ts:3-6`). There is no weekly leaderboard and no season.
- Score is cumulative monthly XP: `completeRun` / `completeCoolDown` increment `leaderboardContributions/{uid}_monthly_{periodKey}.scoreXp` inside their transaction (`monthlyLeaderboard.ts:73-107`).
- Ranking groups are **region × league tier**: 37 supported Singapore planning areas × `tier_01`…`tier_10`. Region comes from the user's self-selected `userProfiles.locationLabel`, never from GPS.
- Snapshot documents carry `periodKey` / `periodLabel` / `topEntries` / `entryCount` / `refreshesAt` — **not** `monthlyPeriod` / `entries` (`monthlyLeaderboardWriter.ts:177-193`). `refreshesAt` is the month-rollover boundary, not the next job run.
- Real job health lives in `leaderboardAggregationLocks/monthly_{periodKey}`: `status` (`running` / `completed` / `failed`), `startedAt`, `completedAt`, `failedAt`, `leaseExpiresAt`, `buildId`. Lease duration is 15 minutes.
- All leaderboard collections deny client writes entirely (`firestore.rules:862-892`).
- The admin website cannot call Cloud Functions callables — it holds `firebase-admin` (Auth + Firestore) only. Every admin write is an Admin-SDK Firestore write.

## Allowed Scope

### Corrections (website only)

- Fix `getLatestLeaderboardSnapshot` to read the fields the backend actually writes; correct the `LeaderboardSnapshotRow` / `LeaderboardEntry` shapes accordingly.
- Correct the next-scheduled-run derivation from `+24h` to the real 60-minute interval, kept distinct from `refreshesAt`.
- Replace the hardcoded `durationSeconds: 0` and `status: "operational"` with values derived from the aggregation lock document, including detection of a **stale lease** (a run that claimed a lease and never released it).
- Remove the "Season length (days)" control. `seasonLengthDays` **remains** in `LeaderboardConfig`, in `DEFAULT_LEADERBOARD_CONFIG`, and in backend validation — removing the key would make stored config documents fail validation and silently roll the whole config back to defaults. The value is loaded into state and passed through on save, unchanged.

### `minRunsToQualify` enforcement (backend + Flutter + website)

- Record a real qualifying-run count on the contribution document. `completeRun` counts; `completeCoolDown`'s stretch bonus does not (it is not a separate run).
- Enforce the configured minimum in `monthlyLeaderboardPlanner`, emitting a `currentView` with a new `ineligible_min_runs` status rather than silently dropping the owner.
- `leaderboardContributionSchemaVersion` must **not** be bumped — the planner hard-rejects unknown schema versions, so a bump would strand every existing contribution document.
- Contributions written before this capsule carry no count and are **grandfathered** (always pass the gate). No user may be retroactively delisted.
- Flutter maps the new status and renders beginner-friendly copy. The client never computes the threshold or the user's run count.

### Recalculation trigger (backend + rules + website)

- A new `leaderboardAdminCommands` collection is written by the admin console (Admin SDK) and consumed by a new `onDocumentCreated` Cloud Function that invokes the existing `refreshMonthlyLeaderboardSnapshots` and writes the real outcome back onto the command document.
- The existing aggregation lease is reused for concurrency; a colliding run resolves to `skipped_locked`.
- `firestore.rules` denies all client access to the new collection.

### Anomaly detection and Exception Queue (website only)

- Suspicious-score detection is computed by the admin console from real `leaderboardContributions` / `activities` data. The hardcoded mock array is no longer served in live mode.
- "Send to Exception Queue" writes a real `reports` document so the case appears in the existing Exception Queue, with an audit-log entry. Reports raised this way are attributed to anomaly detection rather than a user report.

### New oversight surfaces (website only, existing data)

- Current-period card from `leaderboardPeriods/monthly_current`.
- Participation/eligibility breakdown from `leaderboardCurrentViews` grouped by status — including `region_required`, which counts users locked out of the leaderboard because they have not chosen a planning area.
- Coverage counts (snapshots, regions covered, divisions, ranked entries) and retained period keys.
- A read-only standings viewer: pick region × division, see that snapshot's real `topEntries`.

## Forbidden Scope

- Any production `runiac-fypp` deploy without separate explicit authorization. This capsule stops at emulator-first evidence.
- Bumping `leaderboardContributionSchemaVersion`.
- Removing `seasonLengthDays` from the config type, defaults, or validation.
- Client-side calculation or mutation of XP, level, rank, streak, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state.
- New dependencies or secrets in any package.
- Editing generated league-band or planning-area files, or the generated `leaderboardLeagues.ts` (regenerate via `tools/leaderboard/generate_leaderboard_contracts.mjs` only if genuinely required).
- Weekly-leaderboard or season features of any kind — neither exists in the product.
- Any edit or staging inside the isolated `adaptive-character-guidance` worktree.
- Touching feed, challenge, friends, agent, or notification functions.
- Staging, committing, or pushing without explicit user authorization.

## Execution Model

Executed as orchestrator (Opus) delegating wave-by-wave to Sonnet workers, per the plan of record in `/Users/leejinseo/.claude/plans/`. The orchestrator writes a precise per-wave assignment, reviews the resulting diff directly, and re-issues on failure. A wave must be green before the next is dispatched.

## Stop State

`Ready for user screen QA` plus `Ready for manual commit`. No staging, commit, push, or production deployment is authorized by this capsule.

## Resolved

`qualifyingRunCount` is written as an authoritative absolute recompute from the user's full validated activity history already read inside `completeRun`'s transaction (validated runs completed within the same monthly period), not as a `FieldValue.increment` accumulator. Every write self-heals any prior under-count, including for users who ran before the field existed, so raising `minRunsToQualify` mid-period never under-counts. No transition period applies.
