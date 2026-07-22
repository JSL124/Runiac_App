# admin-automation-policy-control-plane

## Parent Phase / Lane

Phase 01 governance and implementation readiness. Backend Guarded Lane (ADR-003), emulator-first (ADR-002).

## Status

Routed on 2026-07-22 Asia/Singapore, explicitly by the user (plan approved). Work in progress. NOT deployed.

Executed as an orchestrator/worker capsule: Opus orchestrates and reviews every diff, Sonnet workers implement one wave at a time.

## Goal

Make the admin console's "Automation & Policy" page real. Today that page is a set of toggles with no backend behind them: there is no `config/automation` document, no Cloud Function reads any automation policy, and the console cannot tell an admin whether flipping a switch does anything. This capsule gives the page four concrete, server-enforced levers — feed-post auto-hide on repeated reports, stale-report escalation, a pause switch for each of the platform's three scheduled sweeps, and an admin-notification feed for error groups and new reports — all owned by a new `config/automation` Firestore document and read only through Cloud Functions.

## Contract Summary

- **Config document.** `config/automation` is owned by the admin console via audited Admin-SDK writes (`saveAdminConfig`, audit action `config.automation.update`), loaded functions-side by `loadAutomationConfig` in `functions/src/config/configLoader.ts`. The runtime contract matches every other config loader in this file: deep-merge the stored document over deep-frozen `DEFAULT_AUTOMATION_CONFIG` → validate → on a per-field validation failure, repair just the invalid fields back to defaults and keep the rest → on an unrepairable or unreadable document, fall back to the full defaults. Malformed config must never throw out of a trigger or scheduled function.
- **Schema.**
  ```
  autoHide { enabled: false, reportThreshold: 3 (int 2-100) }
  staleReportEscalation { enabled: true, pendingDays: 7 (int 1-365) }
  scheduled { leaderboardSnapshotRefresh: true, subscriptionExpirySweep: true, pushNotificationDispatch: true }
  notifications { notifyErrorGroups: true, minimumErrorSeverity: "critical" ("high"|"critical"), notifyNewReports: false }
  version
  ```
  Every default equals "the platform behaves exactly as it does today with no `config/automation` document present" — auto-hide off, escalation on but silent (no delivery channel existed before this capsule), every sweep running, only critical error groups notified, new reports not notified. An unseeded database is unaffected.
- **`adminNotifications` collection (new).** Written only by Cloud Functions triggers using the Admin SDK; read only by the admin console; `firestore.rules` denies all client access, matching the existing `moderationCommands`/`leaderboardAdminCommands` deny-all pattern. Every document id is deterministic for idempotency on trigger replay: `report_<reportId>`, `error_<fingerprint>`, `staleReports_<YYYY-MM-DD>`. The auto-hide command itself reuses the existing `moderationCommands` collection with id `auto_removeFeedPost_<postId>`.
- **Enforcement point 1 — report auto-hide.** A new trigger, `reportCreated` on `reports/{reportId}` (`functions/src/moderation/reportAutomation.ts`), counts distinct reporters against the target feed post. When the count reaches `autoHide.reportThreshold` and `autoHide.enabled` is true, it enqueues `moderationCommands/auto_removeFeedPost_<postId>` with `requestedBy: "system:report-auto-hide"`. The actual removal stays entirely with the existing, already-idempotent `moderationCommandCreated` trigger (`functions/src/moderation/moderationCommand.ts`) — this capsule only ever writes the command, never calls `deleteFeedPostCore` directly, so there is exactly one code path that removes a post. Audited as `moderation.report-auto-hide.request` with actor `system`.
- **Enforcement point 2 — stale report escalation.** A new scheduled function, `escalateStaleReports` (`functions/src/moderation/staleReportSweep.ts`), runs daily at 09:00 Asia/Singapore. It finds `reports` documents still pending after `staleReportEscalation.pendingDays` and writes one daily digest notification (`adminNotifications/staleReports_<YYYY-MM-DD>`) rather than one document per stale report, so the admin console gets a count and list without a notification flood. Audited as `moderation.stale-reports.escalate`. This sweep only ever notifies; it never adjudicates, dismisses, or resolves a report itself.
- **Enforcement point 3 — error group notifications.** A new trigger, `errorGroupWritten` on `errorGroups/{fingerprint}` (`functions/src/errors/errorGroupNotifications.ts`), notifies only when severity crosses the configured floor (`notifications.minimumErrorSeverity`) on that write — not on every write to an already-notified group. It is deliberately **not** wrapped in the existing trigger error-reporting helper (`functions/src/errors/withErrorReporting.ts`): that helper reports faults back into `errorGroups`, and this trigger listens on `errorGroups` writes, so wrapping it would risk a self-recursive write loop the moment the trigger itself faults. This is a documented, deliberate exception to the otherwise-universal error-reporting wrapper convention, not an oversight.
- **Enforcement point 4 — scheduled sweep pause switches.** The three existing scheduled wrappers — `refreshLeaderboardSnapshots` (`functions/src/leaderboard/monthlyLeaderboard.ts`), `expireSubscriptions` (`functions/src/progression/subscriptionExpirySchedule.ts`), and `dispatchScheduledPushNotifications` (`functions/src/notifications/scheduledPushDispatch.ts`) — each gate on the matching `config/automation.scheduled.*` flag through one shared helper, `scheduledAutomationEnabled` (`functions/src/config/automationGate.ts`). The gate lives in the wrapper only: the underlying `*Now()`/core functions and every manual admin-command path that already exists (e.g. the leaderboard admin recalculation command) are untouched and keep working while a sweep is paused, which is a deliberate asymmetry — pausing the clock must not remove an admin's ability to force a run. `scheduledAutomationEnabled` is fail-open by construction: `loadAutomationConfig`'s existing fallback-to-defaults behavior means a missing, unreadable, or invalid `config/automation` document can never silently halt a platform sweep; the only way to pause one is an explicit `false` written by an admin.
- **Companion console work.** The admin console itself (separate `website/` repository, not gated by this repo's governance CI) wires the Automation & Policy page to real data: `src/lib/admin/config-validation.ts` and `types.ts` gain the `AutomationConfig` shape mirroring the functions-side schema and validators; `mock-data.ts`, `data.ts`, and `live-data.ts` gain the live/mock read path; `src/lib/firebase/firestore.ts` and `src/lib/actions/admin.ts` gain `saveAdminConfig` wiring for `config/automation` plus a read path for `adminNotifications`; `src/components/admin/PolicySettings.tsx` and `src/app/admin/policies/page.tsx` become the real editable page; `src/app/admin/page.tsx` gains an admin-notifications surface on the overview; `scripts/seed-emulator.mjs` gains emulator seed data for `config/automation` and a few `adminNotifications` fixtures.
- **Feature-access catalog rebuild (user-requested scope addition, revised).** `DEFAULT_FEATURE_ACCESS_CONFIG` in `functions/src/config/configLoader.ts` (already in Allowed Scope; no allowlist change needed) was first expanded 3→10 by directory-level inference, then — after the user asked for the catalog to reflect the actual app rather than the PDD — rebuilt against a code audit of `implementation/mobile/runiac_app` (2026-07-22). Final catalog (8 entries, premium-convertible features only): `advancedAnalysis` ("premium"; the real post-run Advanced Analysis screen), `goalPlan` ("basic"; the onboarding-generated beginner plan — kept in the catalog as a kill switch but its tier should stay basic because it is the core beginner experience; note the previous default was "premium" from the PDD-era contract, and any live `config/featureAccess` document that stored that value will still override this default until an admin re-saves), `aiHomeCoach` ("basic"; the rule-based fallback guide keeps basic users covered if premium-gated), `activityFeedback` ("basic"), `routeLibrary` ("basic"; renamed from `routes` — the browsing UI exists but is not yet reachable from the app shell and is static-data-only), `shareRouteToFeed` ("basic"), `shareCards` ("basic"), `healthWorkoutImport` ("basic"). Deliberately REMOVED from the catalog: `leaderboard`, `challenges`, `socialFeed`, `friends` — competitive standing and core social infrastructure must never differ by tier — and `expertPlans` (user-directed removal 2026-07-23: expert plan governance is out of this capsule's scope; its premium-only access is a static `firestore.rules` check on `subscriptionStatus` that never reads this document). Absence from the catalog is the guarantee the console cannot premium-gate (or un-gate) them here (pinned by a test). A legacy `leaderboard` entry in a live stored document is harmless: the loader merges stored keys over defaults generically and nothing consumes the flag. Every default reproduces current live behavior; mobile-app dynamic feature gating remains explicitly deferred — only `expertPlans` is enforced today, at the pre-existing `firestore.rules` layer.
- **Enforcement point 5 — challenge tier entitlement (user-requested scope addition 2026-07-23).** New config document `config/challengeAccess` (`ChallengeAccessConfig { premiumOnlyTiers: string[], version }` in `functions/src/config/configLoader.ts`, default `["100K","200K","250K","300K","500K","1000K"]` — the first three tiers 10K/20K/42K stay open to every account, the six higher tiers require premium). Enforced server-side in `createChallengeLobbyForCallable` (`functions/src/challenge/challengeLobbyCore.ts`): a non-premium caller creating a lobby for a premium-only tier is rejected with the new stable reason `PREMIUM_REQUIRED` (`permission-denied` transport, added to `functions/src/challenge/challengeErrors.ts`); premium is evaluated with the existing `isPremiumSubscription` helper (expiry-aware). Only lobby CREATION is gated — invited friends may join a premium owner's lobby regardless of their own tier, and an owner whose subscription lapses after creation keeps the already-created lobby (both deliberate, documented in code). `getChallengeCatalogForCallable` gains an additive `premiumOnlyTiers` field (and a `Firestore` parameter) so clients can render lock states; older clients ignore it. Parity note: challenges award badges only — never XP, level, rank, or leaderboard score (verified: no XP writes anywhere in `functions/src/challenge/`) — so tier gating sells difficulty-tier access without touching competitive standing. A stored `premiumOnlyTiers` array REPLACES the default list (deepMerge treats arrays as leaf values), so an admin clearing every checkbox genuinely opens all nine tiers; an invalid stored doc falls back to the premium-gated defaults (fail-closed for entitlement, the safe direction for a paid feature). Console side: `config/challengeAccess` editor section on the Automation & Policy page, saved via `saveChallengeAccessConfig` → `saveAdminConfig` with audit action `config.challengeAccess.update`.

## Allowed Scope

- `implementation/roadmap/capsules/admin-automation-policy-control-plane.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh`
- `tools/governance-ci/check-pre-scaffold-scope.sh`
- `functions/src/config/configLoader.ts`
- `functions/src/config/automationGate.ts`
- `functions/src/moderation/reportAutomation.ts`
- `functions/src/moderation/staleReportSweep.ts`
- `functions/src/errors/errorGroupNotifications.ts`
- `functions/src/leaderboard/monthlyLeaderboard.ts`
- `functions/src/progression/subscriptionExpirySchedule.ts`
- `functions/src/notifications/scheduledPushDispatch.ts`
- `functions/src/index.ts`
- `firestore.rules`
- `functions/package.json`
- `functions/test/configLoader.test.ts`
- `functions/test/automationGate.test.ts`
- `functions/test/reportAutomation.test.ts`
- `functions/test/staleReportSweep.test.ts`
- `functions/test/errorGroupNotifications.test.ts`
- `functions/src/challenge/challengeErrors.ts` (challenge tier entitlement: `PREMIUM_REQUIRED` reason)
- `functions/src/challenge/challengeLobbyCore.ts` (challenge tier entitlement: create-lobby gate + catalog lock info)
- `functions/src/challenge/callable.ts` (challenge tier entitlement: catalog callable passes Firestore)
- `functions/test/challengeLobby.test.ts` (challenge tier entitlement tests)
- `functions/test/feedCallableSurface.test.ts` (mechanical consequence of the `index.ts` exports: the deployed-surface golden list must include `reportCreated`, `escalateStaleReports`, `errorGroupWritten`)
- `tests/firebase-rules/firestore.rules.test.mjs`

Verified against the real repository layout before being written into this capsule and into `check-diff-hygiene.sh`: `functions/test/configLoader.test.ts` and `functions/test/moderationCommand.test.ts` both already live at `functions/test/*.test.ts` (not `functions/src/test/`), and the Firestore rules suite that already covers `moderationCommands`/`leaderboardAdminCommands` deny-all behavior is `tests/firebase-rules/firestore.rules.test.mjs`. All Allowed Scope paths above use those real, verified locations.

Companion work in the separate `website/` admin console repository (not gated by this repo's governance CI, tracked and committed in that repository's own history): `src/lib/admin/config-validation.ts`, `src/lib/admin/types.ts`, `src/lib/admin/mock-data.ts`, `src/lib/admin/data.ts`, `src/lib/admin/live-data.ts`, `src/lib/firebase/firestore.ts`, `src/lib/firebase/types.ts`, `src/lib/actions/admin.ts`, `src/components/admin/PolicySettings.tsx`, `src/components/admin/AttentionItemsPanel.tsx`, `src/app/admin/policies/page.tsx`, `src/app/admin/page.tsx`, `scripts/seed-emulator.mjs`.

## Forbidden Scope

- Any production `runiac-fypp` deploy. This capsule lands undeployed; a production deploy requires separate scoped authorization.
- Pausing `settleChallengeDeadlines`. It is not one of the three sweeps this capsule gates, and challenge settlement must never be pausable through this policy plane.
- Automated adjudication, dismissal, or resolution of a `reports` document. Every enforcement point here escalates, hides, or notifies — never adjudicates. A human admin still makes every moderation decision.
- Email or push delivery of admin notifications. `adminNotifications` is a Firestore feed the console polls/reads; no delivery channel (email, push, SMS) is in scope.
- New dependencies or secrets.
- Any XP, level, rank, or leaderboard formula change. The scheduled-sweep gate pauses *when* `refreshLeaderboardSnapshots` runs, never *how* it, or any progression math, computes.
- Any edit or staging inside the isolated `adaptive-character-guidance` worktree.
- Client-side (Flutter) computation or writing of any backend-owned value; this capsule touches no Flutter code at all.

## Waves

1. **Foundation** — `config/automation` schema, `DEFAULT_AUTOMATION_CONFIG`, `validateAutomationConfig`, and `loadAutomationConfig` in `functions/src/config/configLoader.ts`; the fail-open `scheduledAutomationEnabled` helper in `functions/src/config/automationGate.ts`; `firestore.rules` deny-all stanzas for `config/automation` (client reads/writes) and the new `adminNotifications` collection. Rules are touched only in this wave; every later wave is trigger/scheduled-function wiring with no further rules change.
2. **Report auto-hide** — `reportCreated` trigger (`functions/src/moderation/reportAutomation.ts`), reusing `moderationCommands`/`moderationCommandCreated` for the actual removal.
3. **Stale report escalation** — `escalateStaleReports` scheduled function (`functions/src/moderation/staleReportSweep.ts`), daily digest notification.
4. **Error group notifications** — `errorGroupWritten` trigger (`functions/src/errors/errorGroupNotifications.ts`), severity-floor crossing only, deliberately outside the trigger error-reporting wrapper.
5. **Scheduled sweep gating** — wire `refreshLeaderboardSnapshots`, `expireSubscriptions`, and `dispatchScheduledPushNotifications` through `scheduledAutomationEnabled`, leaving every core/manual path untouched.
6. **Companion console wave** (separate `website/` repository, runs in parallel with Waves 1-5 since it is outside this repo's governance scope) — real `config/automation` editing UI, `adminNotifications` surface, and emulator seed fixtures.

Waves 2-4 each add one new trigger/scheduled function and do not touch `firestore.rules` again, so they may run in parallel with each other once Wave 1 lands; Wave 5 depends on Wave 1 only (the gate helper) and may also run in parallel with Waves 2-4.

## Validation

Completed 2026-07-22 Asia/Singapore. All verification on local emulators per ADR-002; nothing deployed to `runiac-fypp`.

Backend (this repo):
- `functions` build clean (`npm run build`).
- Unit/emulator suites: main `test` list now includes `configLoader.test.js` (previously wired into no script — gap fixed) and `automationGate.test.js`; `test:moderation` grew from 1 to 4 files. Tallies: configLoader+automationGate 49/49; `test:moderation` 25/25 (moderationCommand + reportAutomation 7 + staleReportSweep 6 + errorGroupNotifications); `test:feed` 42/42 (golden export list updated for the three new exports); main `npm test` 442/443 with the sole failure being the pre-existing `homeGuideAgentCallableSurface` Secret Manager 403 environment limitation.
- Firestore rules suite: 105/105, including the new `adminNotifications` client-denial case.
- End-to-end on `firebase emulators:exec` (`demo-runiac-moderation`, firestore+functions+storage, real compiled triggers loaded): 18/18 assertions.
  - Auto-hide full loop (9/9): report #1 → `adminNotifications/report_<id>` via the real `reportCreated` trigger, no command below threshold; report #2 → `moderationCommands/auto_removeFeedPost_<postId>` created and driven to `status: completed` by the real `moderationCommandCreated` trigger, post removed, exactly one `moderation.report-auto-hide.request` audit row with `actor: system`; report #3 after removal → no duplicate command/audit (deterministic id, ALREADY_EXISTS swallowed), no crash.
  - Error-group crossing (3/3): no notification at `low`; one at low→critical crossing; no duplicate on critical→critical re-ingest.
  - Gates + stale sweep (6/6): `scheduledAutomationEnabled` false for a disabled key, true for enabled, true (fail-open) with `config/automation` deleted; `escalateStaleReportsNow` produced the daily digest + audit exactly once across a re-run. Stale predicate verified against the console's real `ReportResolutionStatus` union: missing/`pending`/`reviewing`/unknown count as unresolved; only `resolved`/`dismissed` stop the clock.
- Governance: `check-diff-hygiene` PASS and `check-pre-scaffold-scope` PASS (both carry this capsule's predicates); `check-canonical-root` FAIL is environmental (non-Desktop checkout) and unrelated to this diff.
- Cross-system config drift: the repo script SKIPs locally (expects `website/` colocated), so the real `config-contract-drift.mjs` was executed against a synthetic layout combining this repo's `configLoader.ts` with the console's `config-validation.ts` — PASS across all nine compared exports, including the new `DEFAULT_AUTOMATION_CONFIG`/`validateAutomationConfig` and the expanded `DEFAULT_FEATURE_ACCESS_CONFIG`.

Companion console repo (`website`, branch `JSL124/admin-automation-policy`):
- `npx tsc --noEmit` zero errors; `npm run lint` no new warnings (one pre-existing unrelated warning in `src/components/Problem.tsx`); `npm run build` succeeds.
- `PolicySettings` rewritten: the mock Automation switches / Confidence thresholds / Notification rules sections and their no-op save were removed and replaced by live `config/automation` editing with validation, two-step confirm, reset-to-defaults, and honest save messaging; feature-access section now renders the 10-entry catalog with human-readable labels. Overview attention items read live `adminNotifications` with an audited dismiss action. Emulator seed script covers `config/automation`, a critical error group, and a sample notification.

An independent adversarial review pass (fresh-context reviewer over both diffs) ran after implementation. Its one major finding was fixed before commit: `errorGroupWritten`'s config load could itself write `errorGroups` via `reportConfigFallback` on a degraded `config/automation` document, re-firing the trigger it feeds — `loadAutomationConfig` now accepts `{ reportFallback: false }` and that trigger is its sole silent caller. Also fixed from the same review: stale-report boundary made strictly "older than" `pendingDays`; console dirty-tracking excludes the server-bumped `version`; `listAdminNotifications` over-fetches 5x before the dismissed-filter so dismissed rows cannot mask older active items; the console's `AdminNotificationStatus` union now includes the backend's `"unread"` spelling with an exclusion-only filtering contract documented.

Known accepted limitations (from the same review, deliberately not changed):
- The console's `getLiveAutomationConfig` falls back to full defaults on an invalid stored doc instead of replicating the backend's per-field repair — consistent with the pre-existing `getLiveFeatureAccessConfig` behaviour; an admin editing on top of a degraded doc may save defaults over surviving tuned fields (the save is validated and audited either way).
- Auto-hide is one-shot per post by design (deterministic command id). If the removal command terminally fails, automation never retries that post; the failed `moderationCommands` document is the signal, and the admin's manual Exception Queue removal path remains available.
- `adminNotifications` documents are never deleted; bounded reads plus the 5x over-fetch window are the current mitigation, and a TTL/cleanup pass is future work.
- The create()-then-audit sequences in `reportAutomation` and `staleReportSweep` have a narrow crash window that can leave a command/digest unaudited on replay; the created document itself remains the durable record (commented at both sites).

Both repositories are at Ready for commit; no commits were made and no production deploy occurred.
