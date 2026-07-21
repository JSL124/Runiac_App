# error-reporting-pipeline

## Parent Phase / Lane

Phase 01 governance and implementation readiness. Backend Guarded Lane (ADR-003), emulator-first (ADR-002).

## Status

Implemented and verified locally on 2026-07-21 Asia/Singapore. Not deployed. Ready for commit.

Executed as two plan-approved phases back to back:

- Phase 1 — app error reporting (Flutter capture layer + `reportAppError` callable + live admin console).
- Phase 2 — backend error reporting (Cloud Functions fault capture into the same collection).

## Goal

Replace the admin console's fabricated Errors & Crashes section with a real pipeline. Before this capsule, `getErrorGroups()` returned a hard-coded array from `mock-data.ts`, the status control mutated local React state only, and the page asserted "Every report is sanitized before it reaches this console" over data that had never been sanitised because it had never existed. The Flutter app had no error capture of any kind, and `functions/src/` contained zero `logger.error` or `console.error` calls.

## Contract Summary

- `errorGroups/{fingerprint}` holds one document per distinct error, keyed by a server-computed sha256 of error type, top app-owned stack frame, and location. `reporters/{uid}` markers give exact distinct-user counts.
- `errorReportRateLimit/{uid}/events/{id}` holds timestamps only, no error content, self-pruning, bounding client reports to 30 per 10 minutes.
- Both collections are deny-all in `firestore.rules`. Writes are Admin SDK only; reads are admin-console only.
- The server owns fingerprinting, grouping, severity, occurrence counts, and affected-user counts. The client cannot influence any of them — those keys are rejected as unsupported payload fields.
- Sanitisation is server-authoritative: only app-owned or functions-owned stack frames are retained, and emails, URL query strings, long digit runs, and token-like runs are redacted from both message and stack before anything is persisted or logged.
- `source: "mobile" | "functions"` distinguishes the two producers. Documents written before this capsule have no `source` field and default to `"mobile"`.
- Expected `HttpsError` rejections are never reported — only non-`HttpsError` throws and `internal`/`unknown`. The original error is always rethrown unchanged, so callable responses, Cloud Logging, and trigger retry semantics are unaffected.
- Scheduled jobs and Firestore triggers have no calling user, so they write no reporter marker and their `affectedUserCount` stays 0.
- Admin-owned fields (`status`, `note`, `firstSeenAt`) survive re-ingest when an error recurs.

## Allowed Scope

- `functions/src/errors/` — the shared ingest store, the client callable, the backend reporter, the sanitiser, and the three trigger wrappers.
- Wrapper application at 44 call sites: 33 callables, 4 scheduled jobs, 7 Firestore triggers. Two deliberate exclusions: `reportAppError`, which would recurse on its own failure, and `functions/src/progression/refreshStreakStatus.ts`, which is blob-pinned by the adaptive-inactive immutable baseline guard while the `adaptive-character-guidance` capsule is isolated in a separate worktree. That callable therefore reports no errors until the pin is lifted; wrapping it was reverted rather than editing the guard, since the pin exists to prevent exactly this kind of collision.
- `functions/src/config/configLoader.ts` — 8 degraded-fallback report sites (validation failure, repaired fields, read failure across three configs). The three "config doc is missing" branches are deliberately not reported, since absent config is the designed default.
- `implementation/mobile/runiac_app/lib/core/observability/` — global error hooks, a bounded 50-entry durable outbox, the injectable callable wrapper, and a navigator observer for screen labels.
- `firestore.rules` — two deny-all stanzas.
- The admin console's App Errors section (separate `website/` repository, outside this repo's governance scope).

## Forbidden Scope

- Any `runiac-fypp` deploy. Neither `reportAppError` nor the wrapped functions are live, so the production console shows an empty state.
- Client-side calculation or writing of backend-owned progression, entitlement, ranking, or expert-publication values.
- XP or leaderboard formula changes.
- `firestore.indexes.json` changes — none are needed.
- New dependencies or secrets.
- Instrumenting the ~15 remaining swallowing `catch` blocks.

## Validation

- Functions: 346 tests. The sole failure, `homeGuideAgentCallableSurface`, is pre-existing and provably outside the wrapper's code path — that test calls `createHomeGuideAgentHandler` directly and never reaches the exported callable.
- Flutter: 1767/1767, `flutter analyze` clean.
- Console: `tsc --noEmit`, lint, and build clean.
- End-to-end against the `demo-runiac-errors` emulator, driving deliberate faults through the real wrappers and the real callable: grouping across two uids, PII redaction with identifiers preserved, severity derivation, `HttpsError` correctly not reported, rules denying client reads, both console filters composing, triage persisting to Firestore with an `error-triage` entry in `adminAuditLogs`, admin triage surviving re-ingest, and legacy documents without a `source` field defaulting to `mobile`.

## Deployment

None. No production deploy is authorised by this capsule.

## Follow-ups

- `Feed callable production surface` test is stale (17 expected exports against 40+ actual), so it would not have caught these additions. Pre-existing, unrelated.
- `homeGuideAgent` quota logic under-admits under concurrency: 4 concurrent requests against a cap of 3 intermittently yield 2 generated, roughly 1 run in 6. A Premium user can silently lose a legitimate AI guide generation.
- The ~15 swallowing `catch` blocks across `functions/src/` remain uninstrumented.
- Production deployment of the pipeline is a separate, explicitly authorised decision.
