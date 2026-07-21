# exception-queue-moderation-adjudication

## Parent Phase / Lane

Phase 01 governance and implementation readiness. Backend Guarded Lane (ADR-003), emulator-first (ADR-002).

## Status

Routed on 2026-07-21 Asia/Singapore after an explicit user request and plan approval. All five waves implemented and verified locally on 2026-07-21 Asia/Singapore. Not deployed. Ready for commit.

Executed as an orchestrator/worker capsule: Opus orchestrates and reviews every diff, Sonnet workers implement one wave at a time.

## Goal

Make the admin console's Exception Queue explicitly distinct from the two other inbox-shaped pages, and make it adjudicate rather than merely label.

The console now has three inboxes that blur together: Feedback (`feedback`, user-initiated complaints about the product), Errors & Crashes (`errorGroups`, machine-generated, made real by `error-reporting-pipeline`), and Exception Queue (`reports`). Three concrete defects made the third read as a duplicate of the other two:

1. `ExceptionType` contained `repeated-crash` and `user-complaint` — the boundary was violated in the type system itself.
2. `reportFeedPost` writes `targetType: "feedPost"`, but `ReportTargetType` had no such member, so `toCaseType()` fell through to its `"user-complaint"` default. Every in-app feed report rendered under the exact label that collides with the Feedback page, and its `targetId` was dropped because `feedPost` was absent from the whitelist — so the "Suspend user" action silently no-opped on the queue's most common real case.
3. The queue could not act on the reported content at all, and its `actionLog` was local React state that the code's own comment described as "for the demo".

Exception Queue's job, stated once and rendered in the page header: **cases where a user may have harmed another user or gamed the system.**

## Boundary Contract

| Page | Collection | Initiator | Subject | Admin verb |
|---|---|---|---|---|
| Feedback | `feedback` | User, about the product | The product | Triage, respond |
| Errors & Crashes | `errorGroups` | Machine | The code | Debug, resolve |
| Exception Queue | `reports` | User about another user, or anomaly detection | Another user's content, conduct, or score | Adjudicate — remove, suspend, resolve |

## Contract Summary

- `ExceptionType` is narrowed to moderation and integrity only: `reported-feed-post`, `reported-user`, `reported-route`, `reported-plan`, `suspicious-xp`, `unclassified`. It can no longer express a crash or a product complaint.
- `ExceptionSource` drops `auto-moderation`, which had no producer anywhere in the codebase.
- Legacy or unrecognised `targetType` values render as `unclassified`, never silently as a real moderation type.
- `moderationCommands/{commandId}` is a new client-denied command collection. The admin console uses the Admin SDK and cannot call callables, so content actions go through a Firestore trigger, reusing the pattern proven by `leaderboardAdminCommands`. The trigger derives nothing from caller-supplied trust fields and writes terminal state back for console polling.
- `accountStatus` gains defence-in-depth enforcement. Suspension is already enforced at the Auth layer by the console (`disabled` plus `revokeRefreshTokens`); this capsule closes the residual window in which an already-issued, unexpired ID token still passes Firestore rules and callables. Absent field means not suspended, so every existing document keeps its current behaviour.
- Report-a-user reuses the existing `reports` create rule, which already permits authenticated client creates for any `targetType` other than `feedPost`. No new callable is required. Dedup and anti-spam come from a rules-enforced deterministic document id of `<reporterUid>_<targetId>`, mirroring the dedup the feed path already gets from `deterministicFeedIds`.
- Self-reporting is rejected in rules.

## Allowed Scope

- `functions/src/moderation/` — the command trigger and its tests.
- `functions/src/security/accountStatus.ts` — one canonical suspension predicate, mirroring the canonical role predicate in `functions/src/security/roles.ts`.
- Suspension guards at write-bearing callable entry points, reusing each callable's existing `users/{uid}` read where one exists rather than adding a second read.
- `firestore.rules` — the `moderationCommands` deny-all stanza, an `isNotSuspended()` helper applied to client write paths only (never reads, since every rules `get()` bills a document read), and the extended `reports` create rule for deterministic-id dedup and self-report rejection.
- `implementation/mobile/runiac_app/lib/` — a report-a-user affordance on another runner's profile and the Friends row surfaces, reusing the bottom-sheet idiom already established by the feed report sheet.
- The admin console's Exception Queue section (separate `website/` repository, outside this repo's governance scope).

## Forbidden Scope

- Any `runiac-fypp` deploy. This capsule lands undeployed; a production deploy requires separate scoped authorisation.
- Activity invalidation and XP reversal, which remain deferred and need new backend flag semantics.
- Report-a-route. Shared routes are Phase 2 and largely unbacked; adding it would create a second empty category.
- Notifying the reporter of an outcome.
- Expert-plan governance.
- Feedback and App Errors page behaviour, beyond the cross-links added to the Exception Queue header.
- Client-side calculation or writing of XP, streak, level, rank, leaderboard score, subscription privilege state, or expert-plan publication state.
- New dependencies or secrets.
- Any edit or staging inside the isolated `adaptive-character-guidance` worktree.

## Waves

1. Taxonomy and the `feedPost` mapping fix. Console-only, no backend, unblocked immediately.
2. `moderationCommands` collection and trigger, reusing `deleteFeedPostCore` for admin-override post removal.
3. `accountStatus` enforcement in rules and callables.
4. Report-a-user in Flutter plus the rules dedup extension.
5. Console action wiring, replacing the demo `actionLog` with real outcomes.

Waves 2, 3, and 4 all edit `firestore.rules` and are therefore sequenced, not parallelised. Wave 1 runs concurrently with them because it is confined to the separate `website/` repository. Wave 5 depends on Waves 2 and 3.

## Validation

Emulator-first per ADR-002 on isolated ports with explicit host guards (`runiac-functions-test`, `demo-runiac-feed`, `demo-runiac-moderation`, `demo-runiac-friends`, `demo-runiac-challenge`).

- Functions: 361 main + 42 feed + 5 moderation = **408/408, 0 failures**, re-run after the final `firestore.rules` change from Wave 4. Friends 29/29 and challenge 163/163 verified separately in Wave 3.
- Firestore rules suite: **104/104** (was 103 before the report-a-user additions).
- Flutter: **1785/1785**, `flutter analyze --no-pub` clean.
- Admin console (`website/`): `npm run lint` clean, `npx tsc --noEmit` clean, `npm run build` succeeds.
- `git diff --check` PASS; `./tools/governance-ci/run-all-checks.sh` **PASS** after registering this capsule's paths in `check-diff-hygiene.sh` and `check-pre-scaffold-scope.sh`.

Notes for the record:

- The `homeGuideAgentCallableSurface` failure documented as "known-stale" by `error-reporting-pipeline` did not reproduce; that baseline note is superseded. Separately, commit `c66c9c0b` (concurrent, not part of this capsule) restored the `feedCallableSurface` export guard from a stale 18-entry list to the real 46, which is why that test is now meaningful; this capsule adds `moderationCommandCreated` as the 47th.
- `leaderboardSeedAuthorization.test.js` failed intermittently with "refresh did not complete" on three occasions across Waves 3 and the final verification, and passed on clean re-runs each time. Zero leaderboard-seed code is touched by this capsule. Treated as a pre-existing environmental flake and recorded here so a future CI red is not misattributed.

## Known Gaps

- A feed-post `reports` document still stores only `reporterUid`/`targetType`/`targetId` (the post id) and never the post author's uid. The console resolves the author by reading `feedPosts/{targetId}.authorUid`, falling back to the `removedAuthorUid` the moderation trigger writes once the post is gone, and disables the suspend action with a visible reason when neither resolves. Persisting the author on the report itself would need a `reports` schema change and was deliberately left out of scope.
- A suspended reporter and a duplicate report are indistinguishable to the client (both are `permission-denied`), so the report sheet reports silent success for both. This preserves rule opacity by design; distinguishing them would leak whether a prior report exists.
- Dedup and self-report rejection are scoped to `targetType == 'user'` only. Route/plan/activity reports keep free-form ids because they have no client affordance yet.

## Deployment

None. No production deploy is authorised by this capsule.
