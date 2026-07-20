# Capsule: Premium Parity Progression

Status: implemented locally, pending validation and commit authorization.
Routed: 2026-07-20 Asia/Singapore (explicit user request).
Lane: Backend Guarded Lane (ADR-002 emulator-first, ADR-003).

## Problem

A live account showed "Monthly ranking is not available for this account yet."
on the Leaderboard tab. Production `leaderboardCurrentViews/{uid}.status` was
`ineligible_premium`, written because `config/leaderboard.excludePremium`
defaulted to `true`.

That exclusion was not an isolated decision. It was forced by
`config/progression.premiumEarnsXp: false`, which made
`calculateProgressionAudit()` award a premium runner 0 XP on every run. With no
XP, a premium runner's `totalXp`, level, and division froze on upgrade and their
leaderboard score could only ever be whatever they earned before paying —
so ranking them would have shown a permanent zero, and excluding them merely
hid that.

The governing rule read "Premium users must not receive XP, rank, leaderboard
score, or competitive advantages." The implementation took the strictest
reading. The requirement is that Premium confers no competitive **advantage**;
barring Premium Users from progression turns paying into a penalty and is
harder to defend than parity.

## Decision

Premium parity. Premium Users earn XP, level, rank, and leaderboard score under
exactly the same server-owned rules as Basic Users. Premium sells coaching,
analysis, approved expert plans, route convenience, and presentation/sharing
value only.

Both previous behaviours remain supported configurations — this changes the
default, not the capability.

## Scope

### Backend (`functions/`)

- `config/configLoader.ts`: `DEFAULT_PROGRESSION_CONFIG.premiumEarnsXp` `false` -> `true`;
  `DEFAULT_LEADERBOARD_CONFIG.excludePremium` `true` -> `false`.
- `leaderboard/monthlyLeaderboardPlanner.ts`, `leaderboard/monthlyLeaderboardOwnerFacts.ts`:
  the `excludePremium ?? true` fallbacks now default `false`, matching
  `DEFAULT_LEADERBOARD_CONFIG`.
- `progression/progressionAuditHelpers.ts`: `progressionReason()` takes
  `premiumXpSuppressed` instead of `isPremium`.
- `progression/progressionAudit.ts`: passes the resolved `suppress` decision;
  `countsTowardLeaderboard` no longer subtracts premium a second time
  (`capped.xpDelta > 0`). Board visibility stays with the aggregator's
  `excludePremium`.
- `run/completeCoolDown.ts`: previously branched on `isPremium` directly and so
  ignored the config plane entirely — the stretch bonus was suppressed for
  premium runners even when `premiumEarnsXp` was true. Now derives
  `premiumXpSuppressed = isPremium && !progressionConfig.premiumEarnsXp` and
  uses it for the bonus, the reason, and `countsTowardLeaderboard`.

### Admin console (`website/`, separate repo)

- `lib/admin/config-validation.ts`: mirrored DEFAULTS updated to match.

## Evidence

Emulator-first, `npm test` under a dedicated `runiac-functions-test` emulator:

- Main suite (30 files, including `completeRun`, `completeCoolDown`,
  `completeRunCallableSurface`, `monthlyLeaderboard`,
  `monthlyLeaderboardWriter`, the seed/cleanup safeguards, notifications, home
  guide, and feedback): **267/267 pass, 0 fail**.
- `npm run test:feed`: 41/42. The single failure is
  `feedCallableSurface` -> "exports exactly the production Feed callables and
  triggers once", which fails because the exported surface now also contains
  the challenge/friends/agent callables added by later capsules. It is the
  pre-existing stale failure already recorded in CURRENT.md and is unrelated to
  this capsule.

Tests changed to cover both policies rather than replacing coverage:

- writer: "includes a premium user by default (config/leaderboard missing)" and
  "excludes a premium user when config/leaderboard.excludePremium is true".
- planner: new "ranks a premium runner by default, ordering by score alone";
  the two exclusion tests now pass `excludePremium: true` explicitly.
- `completeRun` / `completeCoolDown`: a parity test plus a suppression test that
  sets `config/progression.premiumEarnsXp: false`.

## Production state

Applied by the Platform Administrator through the admin console on
2026-07-20 Asia/Singapore, audited in `adminAuditLogs`:

- `config/progression.premiumEarnsXp: true` (version 2)
- `config/leaderboard.excludePremium: false`
- XP backfill for the one run suppressed while premium
  (`user.progression.xp.adjust`, +100 XP): `totalXp` 350 -> 450, level 4 -> 5,
  July contribution `scoreXp` 350 -> 450.
- Recalculation ran; `leaderboardCurrentViews/{uid}.status`
  `ineligible_premium` -> `ranked`.

The code DEFAULTS in this capsule are **not yet deployed**. Production behaviour
currently comes from the Firestore config documents; the defaults only matter if
those documents are deleted or fail validation.

## Forbidden

- Any production `runiac-fypp` deploy without separate authorization.
- Bumping the leaderboard contribution schema version.
- Client-side calculation or mutation of XP, level, rank, streak, or leaderboard
  score.
- New dependencies or secrets.
- Editing generated files (`progression/leaderboardLeagues.ts`) or league bands.
- Edits inside the isolated `adaptive-character-guidance` worktree.

## Seed and demo dataset

The mock dataset seeds one `scoreXp: 0` record per region. Under premium
exclusion that record still received an `ineligible_premium` current view; under
parity the planner drops zero-score contributions before any projection is
written, so it now receives neither a rank nor a view. Everything that counted
"one view per seeded record" had to follow:

- `leaderboardMockDataset.ts`: `eligibilityReason` `ineligible_premium` ->
  `ineligible_zero_score` — the tier was never what kept this record off the
  board, the score was.
- `leaderboardSeedOwnership.ts`: expected rank and view ids now derive from
  `contribution.scoreXp > 0` instead of `subscriptionStatus === "basic"`.
- `leaderboardSeedOwnership.ts`: `expectedProjectionDocuments()` returns early on
  an empty ref list. Seeding one user per region makes that user the zero-score
  record, so the projection set is legitimately empty and `getAll()` rejects a
  zero-argument call — a latent crash this change exposed.
- `leaderboardSeedDataset.ts`: `candidateCounts.leaderboardCurrentViews` is now
  `records.length - regionCount`.
- `leaderboardSeedCleanupAuthorization.ts`: the verified-replacement guard
  required `verifiedCurrentViewCount === 100`; the known-good 100-user Jurong
  East fixture now yields 99. This is a production safety check, not a fixture.

## Open items

1. Deploying the code DEFAULTS requires a scoped authorization covering
   `functions:completeRun`, `functions:completeCoolDown`, and the leaderboard
   aggregation functions. Until then the defaults are inert in production.
2. The `website/` admin console changes live in a separate repository and are
   committed and deployed separately.
