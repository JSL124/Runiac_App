# admin-role-subscription-expiry

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed Backend Guarded Lane full-stack capsule under ADR-002 Emulator First and ADR-003.

## Status

Implemented emulator-first on 2026-07-20 Asia/Singapore, then deployed to production `runiac-fypp` under a separate explicit user authorization on 2026-07-20 Asia/Singapore, scoped to exactly `functions:expireSubscriptions` and `firestore:indexes`.

Verified live rather than deployed again: both artifacts were already present and current when the authorized deploy was attempted, so no deploy command was run. The only production-affecting command was a separately authorized manual scheduler run, which wrote nothing because the sweep had no candidates. See Deployment below.

## Goal

Close two authority gaps the admin console's Users & Roles surface exposed, where the console recorded state that no backend path honoured.

First, the Platform Administrator role: the console writes the canonical `users/{uid}.userRole = "platformAdmin"`, but the only server-side consumer compared against the legacy display string `"Platform Administrator"`, so a role granted through the console satisfied no backend check. Second, premium entitlement: `subscriptionStatus: "premium"` was permanent once granted, with no expiry or renewal concept, so an admin-granted Premium never lapsed.

The companion client-side work (Auth custom claims, the expiry picker, the compensating XP-correction progression event, paging/search) lives in the separate `website/` repository and is outside this repo's governance scope.

## Contract Summary

- `isPlatformAdminRole(data)` (`functions/src/security/roles.ts`) is the single server-side predicate for the Platform Administrator role. It accepts the canonical `"platformAdmin"` and the legacy `"Platform Administrator"` so already-stored documents keep working; every server-side role check routes through it rather than comparing literals. `functions/src/friends/friendsMigration.ts` is the only existing consumer. (`validateRunPayload.ts`'s `"userRole"` entry is a protected-field blacklist, not a role-value comparison, and is intentionally untouched.)
- `users/{uid}.subscriptionExpiresAt` (nullable Firestore `Timestamp`) is the premium expiry instant. Absent or null means "no expiry", which preserves the existing behaviour of every stored document — this is a zero-regression addition.
- `isPremiumSubscription(data, nowMs)` (`functions/src/progression/progressionAuditHelpers.ts`) treats a `premium` status whose `subscriptionExpiresAt` has passed as not premium for in-request XP/leaderboard evaluation. The required `nowMs` parameter is threaded from the existing call sites rather than read inside the helper, keeping it pure.
- **The stored expiry is contractually a Firestore `Timestamp` and nothing else.** The only writer is the admin console's `setUserSubscription()`, which stores `Timestamp.fromDate()`. Every non-Timestamp shape — ISO string, millis number, anything else — is uniformly treated as "no expiry" by the helper, is never selected by the sweep, and reads as premium in `firestore.rules`. This is deliberate: the sweep's candidate query is bounded at both ends by a `Timestamp`, so only Timestamp values are selected. (Emulator evidence indicates Firestore inequality filters are type-scoped and the upper bound alone would suffice; the lower bound is retained so correctness does not depend on that holding identically in production.) Honouring those shapes in the helper alone would deny premium in-request while the sweep left `subscriptionStatus: "premium"` stored forever and rules kept granting access. Consistency across the three is achieved by narrowing the contract, not by three implementations agreeing. Manual or seeded data that stores an expiry in any other shape will therefore never lapse — store a `Timestamp`.
- `expireSubscriptions` scheduled function (`asia-southeast1`, `Asia/Singapore`, daily 03:00) materialises the downgrade: it queries `users` where `subscriptionStatus == "premium"` and `subscriptionExpiresAt <= now` (capped at 200 documents per run), batch-writes `subscriptionStatus: "basic"`, clears the expiry, and stamps `subscriptionUpdatedAt` / `subscriptionSource: "system-expiry"`. Each downgrade appends an `adminAuditLogs` entry with actor `system`, action `user.subscription.expire`, and before/after snapshots.
- The downgrade must be **materialised** rather than evaluated on read because the client-facing gate, `firestore.rules` `isPremiumUser()`, can only compare the stored `subscriptionStatus` — it cannot evaluate an expiry instant. The scheduled sweep is what keeps the stored document consistent with the in-request evaluation above.
- `firestore.indexes.json` gains a `users` composite index (`subscriptionStatus ASC`, `subscriptionExpiresAt ASC`). The sweep combines an equality filter with a range filter on a different field, which production Firestore requires an index for; the emulator does not enforce this, so the index is not discoverable from emulator runs alone.

## Allowed Scope

- New: `functions/src/security/roles.ts`, `functions/src/progression/subscriptionExpiryCore.ts`, `functions/src/progression/subscriptionExpirySchedule.ts`.
- New tests: `functions/test/roles.test.ts`, `functions/test/progressionAuditHelpers.test.ts`, `functions/test/subscriptionExpiry.test.ts`.
- Modified for the role predicate: `functions/src/friends/friendsMigration.ts`, `functions/test/friendsCore.test.ts`.
- Modified for the `nowMs` threading required by the expiry-aware premium check: `functions/src/progression/progressionAuditHelpers.ts`, `functions/src/progression/progressionAudit.ts`, `functions/src/run/completeRun.ts`, `functions/src/run/completeCoolDown.ts`, `functions/src/leaderboard/monthlyLeaderboardOwnerFacts.ts`, `functions/src/leaderboard/monthlyLeaderboardWriter.ts`.
- `functions/src/index.ts` only to export `expireSubscriptions`; `functions/package.json` only to register the three new test files.
- `firestore.indexes.json` only for the `users` subscription-expiry composite index.
- This capsule plus one append-only CURRENT routing line and the minimal governance-CI allowlist entries for the paths above.

## Forbidden Scope

- No production `runiac-fypp` deploy without separate explicit authorization. That authorization was granted on 2026-07-20 Asia/Singapore for exactly `functions:expireSubscriptions` and `firestore:indexes`, and for nothing else; every other function and `firestore:rules` remain outside it. A full-function deploy (`--only functions`) stays forbidden.
- No client-side computation or write of any backend-owned value.
- No change to XP/leaderboard formulas, cadence, activity history, feed, challenge, notification, or agent behaviour. The `nowMs` threading is a signature change only and must remain behaviour-preserving.
- No `firestore.rules` change in this capsule; entitlement gating continues to read the materialised `subscriptionStatus`.
- No new dependencies, no secrets, and no edits inside the isolated `adaptive-character-guidance` worktree.

## Validation

- `functions`: `npm run build` clean.
- New suites (`roles`, `progressionAuditHelpers`, `subscriptionExpiry`): pass. Covers canonical and legacy role strings; no-expiry, future-expiry, past-expiry and boundary instants; non-Timestamp shapes reading as no-expiry; a sweep that downgrades exactly the lapsed document and leaves future-expiry, lifetime-premium and already-basic documents untouched; the renewal race; out-of-contract values never being selected; and mirrored-profile clearing.
- The renewal-race and mirror-clearing regressions are mutation-verified: removing the transaction re-check fails the former, removing the mirror write fails the latter. Two earlier versions of these tests passed against deliberately broken code and were rewritten.
- Regression over the `nowMs` blast radius (`completeRun`, `completeCoolDown`, `monthlyLeaderboard`, `monthlyLeaderboardWriter`, `progressionCalculator`) plus the new suites: 154/154 pass.
- `friendsCore` including new canonical-role coverage: 26/26 pass.
- Emulator note: the suites were run via `firebase emulators:exec --config` on isolated ports (firestore 8099, auth 9299, functions 5011) so the developer's already-running emulator on 8080/9099/5001 was not disturbed. The temporary config was removed afterwards.

## Deployment

Confirmed against production `runiac-fypp` on 2026-07-20 Asia/Singapore. `functions: npm run build` was clean; the only production-affecting command was the user-authorized manual scheduler run recorded below, and everything else was a read-only query.

- `expireSubscriptions` is live: v2 scheduled, `asia-southeast1`, `nodejs22`, `ACTIVE`, revision `expiresubscriptions-00002-gol`, `updateTime 2026-07-19T21:27:49Z` (2026-07-20 05:27:49 +08). That is after the last source commit `71e9ba58` (04:57:44 +08) and four minutes after the merge `8a210501` (05:23:35 +08), so the live revision carries the full contract including the Timestamp lower bound, the mirrored-profile clearing, and the renewal-race re-check.
- Cloud Scheduler `firebase-schedule-expireSubscriptions-asia-southeast1` is `ENABLED` at `every day 03:00` `Asia/Singapore`. The deploy landed after 03:00 on 2026-07-20, so no scheduled run had fired; the user explicitly authorized a manual run to verify sooner, executed at `2026-07-20T07:34:44Z`. It returned HTTP `200` with no error entry in `gcloud logging`.
- What that manual run establishes, and what it does not. It proves the deployed revision executes against production and — more usefully — that the sweep's combined equality-plus-range query runs **without `FAILED_PRECONDITION`**, which is the one part of the contract the emulator structurally cannot check because it does not enforce composite indexes. It does not exercise the downgrade path: a read-only query of production `users` immediately before the run found six documents, all `subscriptionStatus: "basic"` with no `subscriptionExpiresAt`, so the sweep had zero candidates and correctly wrote nothing. The downgrade, mirror clearing, renewal race, and audit entry remain covered by the emulator suites only.
- `firestore:indexes` needed no deploy. Production carries 14 indexes that match `firestore.indexes.json` exactly once the implicit trailing `__name__` field is discounted, with no create and no delete candidate on either side. The `users` composite (`subscriptionStatus` ASC, `subscriptionExpiresAt` ASC) is present and `SPARSE_ALL`.
- Accepted bounded gap: the `nowMs` threading was deliberately left undeployed, so production `completeRun` remains the `2026-07-16T06:29:49Z` revision whose premium check reads only the stored `subscriptionStatus`. A lapsed premium therefore keeps entitlement for at most the interval to the next daily sweep (≤ ~24h), after which the materialised downgrade makes the older revision behave correctly. Tighten the schedule rather than the deploy scope if that proves too coarse.
- Production `users` state observed on 2026-07-20: six documents, all `userRole: "runner"` except `m3wD49fw3bamXhP4opmkwxkPIdj1`, which already carries `userRole: "platformAdmin"` on a real account. All six are `subscriptionStatus: "basic"` with no stored expiry. The `platformAdmin` document has no `accountStatus` field because a console role change merge-writes only `userRole` and `updatedAt`; every consumer defaults an absent value to `active`, so this is consistent rather than broken. Note the collection is populated, which contradicts an earlier working assumption that production had no `users` documents and would need a provisioning capsule before the console could be pointed at production.
- Outstanding: end-to-end production evidence that a lapsed document is actually downgraded. This cannot be produced from current production data, because no premium document with a past expiry exists and the console's `setUserSubscription()` rejects a past expiry date, so a lapsed document can only arise by granting a future expiry and waiting for it to pass. Verify then that the account's `users/{uid}.subscriptionStatus` flips to `basic`, the expiry is cleared, `subscriptionSource: "system-expiry"` is stamped, and an `adminAuditLogs` entry appears with actor `system` and action `user.subscription.expire`. Do not manufacture the evidence by writing a synthetic lapsed document into production `users`.

## Follow-ups

- Deploy gate: satisfied on 2026-07-20 Asia/Singapore for `functions:expireSubscriptions` and `firestore:indexes` only. Any further production change, including deploying the `nowMs` threading in `completeRun`/`completeCoolDown`/`monthlyLeaderboard*`, requires its own explicit authorization.
- `firestore.rules` still cannot express expiry; if the sweep cadence (daily) proves too coarse for an entitlement boundary, tighten the schedule rather than moving the check into rules.
