# Capsule: Progression Follow-ups

Status: implemented locally, pending commit authorization.
Routed: 2026-07-21 Asia/Singapore (explicit user request).
Lane: Backend Guarded Lane (ADR-002 emulator-first, ADR-003).

Closes the three follow-ups recorded on PR #13
(`premium-parity-progression`), all raised by adversarial review of that PR
and deliberately deferred out of it.

## 1. Streak milestone bonuses were capped into being unpayable

`dailyXpCap` is 200. The shipped `streakRewards` include 14 days -> 220 and
30 days -> 600, and the bonus was clamped to whatever daily room remained
after the base activity XP. A runner who crossed day 30 after an ordinary
80 XP run received 120 of 600; the other 480 was dropped, never paid back,
and never surfaced. `validateProgressionConfig` did not warn either.

The bonus is now exempt from `dailyXpCap` as well as `activityXpCap`. That
is safe *because* of the high-water mark shipped in the same PR: a milestone
pays at most once per owner ever, so it cannot be farmed the way an uncapped
per-run reward could. Capping a once-in-a-lifetime award against a per-day
budget conflated two different limits.

`sumDailyXp` now nets `streakBonusXp` out of the stored `xpDelta`, so an
exempt bonus does not consume the day's budget either — otherwise a 600 XP
milestone would zero out every later run that day, which is the same
conflation from the other direction.

`streakBonusCapped` is retained in the contract and is always `false`. It is
kept rather than removed so progression events written before the exemption
stay readable and the field keeps a stable meaning.

## 2. `qualifyingRunCount` was dropped on zero-XP runs

`writeLeaderboardContribution` returns early when `scoreXp <= 0`, which
discarded the caller's authoritative absolute recompute of the qualifying-run
count. The count measures *validated runs in the period*, not XP-awarding
ones, so a user who exhausted the daily cap on their qualifying run stayed
below `minRunsToQualify` for the rest of the month — the "self-heals on the
next run" contract only held for the next *XP-awarding* run.

The count is now merged even on the zero-score path, but only when the
contribution document already exists. Creating one there would mint a
contribution carrying nothing but a run count — no score, no region, no
schema version — which the planner would have to parse and reject and which
the seed fixtures treat as a distinct state.

## 3. The two policy flags were never type-validated

`premiumEarnsXp` and `excludePremium` are read as plain truthiness tests and
`deepMerge` passes stored values through verbatim, so a wrong *type* silently
inverted the policy instead of failing: `"false"` is truthy, `0` is falsy.
Both documents are admin-console editable. Both validators now require a
boolean, and `website/src/lib/admin/config-validation.ts` mirrors the change
(enforced by `tests/cross-system/config-contract-drift.mjs`).

## Evidence

- `npm test` **298/298**, 0 fail, under a dedicated `runiac-functions-test`
  emulator.
- `npm run test:feed` 41/42 — the failure is the pre-existing stale
  `feedCallableSurface` export-surface assertion, unrelated to this capsule.
- `config-contract-drift` PASS (both mirrors in sync).
- One `homeGuideAgent` fingerprint test failed on an earlier run and passed on
  re-run; it touches no file in this capsule and matches the flake already
  recorded in CURRENT.md.

`completeRun.test.ts`'s "trims the bonus to the remaining daily XP room" case
was rewritten rather than deleted: it now pins the new contract (milestone
paid in full, `dailyXpAfter` deliberately exceeding `dailyXpCap`).

## Forbidden

- Any production `runiac-fypp` deploy without separate authorization.
- Changing `streakRewards` values or `dailyXpCap` (the balance decision was to
  exempt, not to retune).
- Client-side calculation or mutation of XP, level, rank, streak or
  leaderboard score.
- New dependencies or secrets; generated-file or league-band edits.
- Edits inside the isolated `adaptive-character-guidance` worktree.

## Second round (adversarial review of PR #14)

Review found no XP-inflation or double-payment path, and confirmed the
exemption's safety argument. It did find one regression introduced by the
exemption itself plus three lower-severity issues, all fixed here:

- **Cool-down bonus silently zeroed on a milestone run.** `completeCoolDown`
  read `baseEarnedXp` from the run event's `xpDelta`, which after the
  exemption also carries the milestone. `calculateCoolDownBonus` clamps to
  `activityXpCap - baseEarnedXp`, so that term went negative and the stretch
  bonus became 0 while the reason ladder reported `low_data_no_xp` on a
  full-GPS run. The milestone is now netted out first.
- **The daily-cap notice disappearing when the cap took the whole base was NOT
  fixed.** A backend-only reason change was attempted and reverted: review
  showed it is inert. The Flutter mapper gates the reason message on
  `awarded = status == 'awarded' && xpDelta > 0`, which is true whenever the
  milestone paid, so rewriting the stored reason changes nothing the user sees
  while giving `daily_cap_reached` two meanings. Closing it needs a
  coordinated mapper change; recorded under Open items with the reasoning left
  in a comment at the call site.
- **The zero-score `qualifyingRunCount` write could demote a legacy
  contribution.** Stamping a first count ends the planner's grandfathering;
  doing it on a zero-XP run made that happen strictly earlier than before.
  The write now only refreshes a count that already exists.
- **One bad field reverted the whole config document.** `loadProgressionConfig`
  / `loadLeaderboardConfig` now reset only the fields the validator named and
  keep the rest, falling back to the full defaults only if that repair does
  not validate.

The admin console's Gamification Rules page was also corrected: it still
stated the bonus "counts toward the daily XP cap" and warned that the shipped
600 XP reward "will be trimmed", which pushed admins toward the retune this
capsule forbids.

## Open items

- The daily-cap notice is still not shown when the cap trims the base to zero
  and an exempt milestone pays. Needs `xp_update_display_model_mapper.dart` to
  surface the cap note independently of `awarded`, paired with a backend reason
  change. Backend-only is inert; mapper-only has nothing to key on.

- The exemption means `dailyXpAfter` can exceed `dailyXpCap` on a milestone
  run. That is intended and pinned by test, but any future consumer reading
  `dailyXpAfter` as "at most the cap" must be updated.
- Not deployed. `functions:completeRun`, `functions:completeCoolDown` and the
  leaderboard aggregation functions carry these changes and need a scoped
  authorization.
