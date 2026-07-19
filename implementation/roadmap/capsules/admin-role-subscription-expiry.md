# admin-role-subscription-expiry

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed Backend Guarded Lane full-stack capsule under ADR-002 Emulator First and ADR-003.

## Status

Implemented emulator-first on 2026-07-20 Asia/Singapore. No production `runiac-fypp` deploy is authorized by this capsule.

## Goal

Close two authority gaps the admin console's Users & Roles surface exposed, where the console recorded state that no backend path honoured.

First, the Platform Administrator role: the console writes the canonical `users/{uid}.userRole = "platformAdmin"`, but the only server-side consumer compared against the legacy display string `"Platform Administrator"`, so a role granted through the console satisfied no backend check. Second, premium entitlement: `subscriptionStatus: "premium"` was permanent once granted, with no expiry or renewal concept, so an admin-granted Premium never lapsed.

The companion client-side work (Auth custom claims, the expiry picker, the compensating XP-correction progression event, paging/search) lives in the separate `website/` repository and is outside this repo's governance scope.

## Contract Summary

- `isPlatformAdminRole(data)` (`functions/src/security/roles.ts`) is the single server-side predicate for the Platform Administrator role. It accepts the canonical `"platformAdmin"` and the legacy `"Platform Administrator"` so already-stored documents keep working; every server-side role check routes through it rather than comparing literals. `functions/src/friends/friendsMigration.ts` is the only existing consumer. (`validateRunPayload.ts`'s `"userRole"` entry is a protected-field blacklist, not a role-value comparison, and is intentionally untouched.)
- `users/{uid}.subscriptionExpiresAt` (nullable Firestore `Timestamp`) is the premium expiry instant. Absent or null means "no expiry", which preserves the existing behaviour of every stored document — this is a zero-regression addition.
- `isPremiumSubscription(data, nowMs)` (`functions/src/progression/progressionAuditHelpers.ts`) treats a `premium` status whose `subscriptionExpiresAt` has passed as not premium for in-request XP/leaderboard evaluation. The required `nowMs` parameter is threaded from the existing call sites rather than read inside the helper, keeping it pure.
- **The stored expiry is contractually a Firestore `Timestamp` and nothing else.** The only writer is the admin console's `setUserSubscription()`, which stores `Timestamp.fromDate()`. Every non-Timestamp shape — ISO string, millis number, anything else — is uniformly treated as "no expiry" by the helper, is never selected by the sweep, and reads as premium in `firestore.rules`. This is deliberate: Firestore inequality filters are type-scoped, so a `<= Timestamp` range query never returns a string or number value. Honouring those shapes in the helper alone would deny premium in-request while the sweep left `subscriptionStatus: "premium"` stored forever and rules kept granting access. Consistency across the three is achieved by narrowing the contract, not by three implementations agreeing. Manual or seeded data that stores an expiry in any other shape will therefore never lapse — store a `Timestamp`.
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

- No production `runiac-fypp` deploy without separate explicit authorization. `expireSubscriptions` and the new index are undeployed; until they ship, an expiry date is recorded but nothing sweeps it.
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

## Follow-ups

- Deploy gate: `functions:expireSubscriptions` and `firestore:indexes` require separate explicit authorization before premium expiry is live in production.
- `firestore.rules` still cannot express expiry; if the sweep cadence (daily) proves too coarse for an entitlement boundary, tighten the schedule rather than moving the check into rules.
