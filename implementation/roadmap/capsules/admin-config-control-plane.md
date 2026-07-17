# Capsule: Admin Config Control Plane + User Operations Console

- Type: Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003 lane rules)
- Routed: 2026-07-16 Asia/Singapore, explicitly by the user (plan approved).
- Status: In progress — emulator-first. No production deploy authorized.
- Plan of record: `/Users/leejinseo/.claude/plans/based-on-the-inspection-warm-wozniak.md`

## Goal

Turn the platform admin console (in the separate `website/` repo) into a
config-driven control plane plus a per-user operations console, while preserving
the Runiac rule that the client renders and the server owns truth. All XP,
caps, level curve, cool-down, badge thresholds, feature-access policy, leaderboard
eligibility, and marketing thin-slice copy move from hard-coded constants to
Firestore `config/*` documents that Cloud Functions read and enforce at runtime.
Admins edit config only through authenticated server-side Admin SDK paths, fully
audited. **Zero-regression invariant: an unseeded database behaves exactly as
today because every loader default equals the current constant.**

## Frozen contract (workers must not deviate)

### DEFAULTS = current constants (`functions/src/progression/progressionCalculator.ts`)

```
baseCompletionXp=20  xpPerKilometer=10  xpPerTenActiveMinutes=5
planCompletionBonusXp=20  activityXpCap=100  dailyXpCap=200  maxLevel=100
coolDown: percent=0.2 min=5 max=20
levelIncrements=[100,150,220,300,400,520,660,820,1000,1200]  (per 10-level band)
premiumEarnsXp=false   (premium suppression stays server-enforced)
```
Leaderboard eligibility DEFAULTS: `minRunsToQualify` (current effective 1 via `scoreXp<=0` gate),
`excludePremium=true` (`monthlyLeaderboardOwnerFacts.ts:39-69`), `seasonLengthDays=30`.
Badge thresholds DEFAULT to catalog `personalMinimumMeters` (`functions/src/challenge/challengeCatalog.ts`).

### Firestore config documents

```
config/progression   config/leaderboard   config/featureAccess   config/siteContent
badgeConfigs/{badgeId}
```
Schemas exactly as in the plan of record (§ "Config data model"). `premiumEarnsXp`
lives in `config/progression`. `featureAccess` uses one `minimumTier` per feature
(no dual key lists). Badge identity/settlement refs stay code-owned; Firestore owns
only `{thresholdMeters, enabled, displayMetadata?}`.

### Runtime contract (every loader)

`Load → deep-merge over DEFAULTS (per-field, nested objects too) → validate →
valid: use; invalid: log/report + fall back to safe DEFAULTS.` Malformed config
must never fail `completeRun`, `completeCoolDown`, or leaderboard.

### Validation rules (shared, both website + functions)

no negative XP; `dailyXpCap >= activityXpCap`; `maxLevel > 0`;
`0 <= coolDown.percent <= 1`; `coolDown.min <= coolDown.max`;
non-empty numeric `levelIncrements`; `featureAccess.minimumTier ∈ {basic,premium}`.

### Write + audit contract

Config/user-ops writes are Firestore Admin-SDK writes from `website/` (the admin
app cannot call Cloud Functions callables). Every write goes through one
`saveAdminConfig`-style helper: `authenticate admin → validate → read previous →
write → append explicit before/after audit to adminAuditLogs`. Audit events use
explicit names + `changedFields` + before/after (e.g. `config.progression.update`,
`user.progression.xp.set`).

## Scope (workstreams WS0–WS8 in the plan of record)

Control Plane: dynamic progression/XP, leaderboard eligibility, feature-access
policy, badges, website thin slice (hero/pricing/announcement). Operations Console:
per-user account/role/subscription/progression/activity/badge/leaderboard/moderation
actions. Backend refactor seam: `calculateProgressionAudit()`
(`functions/src/progression/progressionAudit.ts:50`), one call site
`functions/src/run/completeRun.ts:173`, plus `completeCoolDown.ts`.

## Emulator-first evidence (filled as waves land)

### Wave 1 — foundation (PASS)
- W1-fn-config `functions/src/config/configLoader.ts`: `npm run build` clean; 19/19 standalone unit tests (deep-merge preserves missing nested defaults, validator rejections, loader fallback on missing/invalid/throw); full `functions` emulator suite `# fail 0` (zero regression). DEFAULTS verified equal to current constants.
- W1-web-framework: `npx tsc --noEmit` clean; `saveAdminConfig` = requireAdmin → validate → hasFirebaseEnv gate → before/after audit; website validators/DEFAULTS mirror the backend.
- W1-rules: `tests/firebase-rules` 91/91 PASS incl. new `config/*` + `badgeConfigs/*` client deny tests.
- Known pre-existing baseline failure `feedCallableSurface.test.ts` (stale expected callable list, fails on `main` too) — out of scope, untouched.

### Wave 2 — dynamic progression + site-content + user-ops progression (PASS)
- W2-progression: functions emulator suite 220/220 (completeRun suite intact, zero regression); new `config/progression` override test (distance XP doubles under `xpPerKilometer:20`) and corrupted-config fallback test both PASS. Level curve derived from `levelIncrements` verified identical to old constants (Lv.100 @ 53600 XP). `premiumEarnsXp` gates premium suppression.
- W2-site-content: `tsc` clean; hero headline/subtext + announcement banner now read `config/siteContent` with literal fallbacks; `ContentEditor` wired to `saveSiteContent`. KNOWN GAP: `SiteContentRow` lacks structured pricing fields, so pricing tiers still render literals — deferred to Wave 3 schema fix.
- W2-userops-progression: `tsc` clean; Set/Adjust XP (recompute level), Set Level (override), Reset via audited Admin-SDK path writing `userProfiles/{uid}` (verified: same target as completeRun `:346`; keys `totalXp`/`level`/`monthlyXp` are in `backendOwnedKeys()` so clients still cannot self-write). Combined website `tsc` sweep clean.

### Wave 3 — leaderboard config + admin config UIs + user-ops domains (PASS)
- W3-A leaderboard: `config/leaderboard.excludePremium` now drives premium exclusion (`monthlyLeaderboardWriter/Planner/OwnerFacts`); default (true / doc missing) identical to today. Functions emulator suite 222/222 on re-run (first run had a flaky `homeGuideAgent` fingerprint test that passed on re-run; only persistent failure is the pre-existing stale `feedCallableSurface`). New tests PASS: excludes premium by default; includes premium when `excludePremium:false`. `seasonLengthDays` (calendar-month period) and `minRunsToQualify` (no per-user run count upstream) intentionally NOT wired — labeled "enforcement pending" in the UI (no dead controls).
- W3-B admin UIs: `GamificationRules`/`LeaderboardOversight`/`PolicySettings` now editable forms → `saveProgressionConfig`/`saveLeaderboardConfig`/`saveFeatureAccessConfig` with client validation, confirm step, reset-to-defaults, live/staged/error states; new `SystemConfigSummary` on the overview shows each config's version/updated-by. `tsc` + eslint clean.
- W3-C user-ops: Subscription + Moderation (warn/suspend/ban/restore) actions writing `users/{uid}` (client-write-denied; Admin-SDK only), each audited with reason + before/after. `tsc` clean. Combined website `tsc` sweep clean.
- Deferred to a follow-up capsule (flagged, not half-built): badge-threshold enforcement through the frozen challenge snapshot; per-user activity-invalidation / badge / leaderboard exceptions needing new backend flag semantics; structured pricing fields in `siteContent`; mobile dynamic feature gating.

### Later waves

- Functions: `cd functions && npm test` — zero-regression (completeRun 76/76 with
  no config seeded) + new loader/deep-merge/validation/corrupted-config-fallback
  units + RED/GREEN config-override tests.
- Rules: `cd tests/firebase-rules && npm test` — `config/*` and `badgeConfigs/*`
  deny all client writes.
- Website: `cd website && npm run build`; admin edit → config doc + audit → next
  emulator `completeRun` uses new values.
- Client untouched: `flutter analyze --no-pub && flutter test`.
- `./tools/governance-ci/run-all-checks.sh` PASS before any commit.

## Forbidden

- Any production deploy to `runiac-fypp` without a separate explicit authorization.
- Client-side mutation or calculation of any backend-owned value (XP/level/rank/
  streak/leaderboard/subscription/role); those stay rules-protected.
- Mobile dynamic feature gating (deferred to a later capsule).
- Generated leaderboard league-band editing (`leaderboardLeagues.ts` stays fixed).
- New dependencies or secrets; modifying `docs/submissions/` or frozen PDD snapshots.
- Colliding with the isolated `adaptive-character-guidance` worktree.
