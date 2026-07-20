# user-feedback-pipeline

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed Backend Guarded Lane full-stack capsule under ADR-002 Emulator First and ADR-003.

## Status

Implemented emulator-first on 2026-07-19 Asia/Singapore. The user explicitly authorized a scoped production deploy on 2026-07-20 Asia/Singapore after debugging a live "Something went wrong" feedback-submission failure traced to the `submitFeedback` callable never having been deployed to `runiac-fypp`. Deployed: `functions:submitFeedback` (`asia-southeast1`, now ACTIVE), `firestore:rules` (feedback deny block), `firestore:indexes` (feedback `uid`+`receivedAt` composite index). No other function was touched by this deploy. Code deployed matches commit `5d7b2ada feat(feedback): server-owned submitFeedback callable and account feedback form` unchanged from the 2026-07-19 emulator-first evidence.

## Goal

Deliver a user feedback pipeline end-to-end: a "Feedback" option on the app's Account screen (between "About Runiac" and "Sign out") where a signed-in user picks a category (bug / plan issue / billing / other) and writes a free-text message; submission flows through a new server-owned `submitFeedback` callable into a new Firestore `feedback` collection; the admin console's existing Feedback & Complaints tab (separate `website/` repo) reads the collection live via firebase-admin using its `liveOrMock` pattern.

## Contract Summary

- `submitFeedback` callable (`asia-southeast1`, App Check per `shouldEnforceAppCheck()`): request is exactly `{category, message}` with category in {`bug`, `plan issue`, `billing`, `other`} and message 1–2000 chars after trim; unknown keys rejected. Requires Firebase Auth. Best-effort rate limit: at most 5 submissions per caller per trailing 10 minutes (`resource-exhausted`). Response `{feedbackId}`.
- Server-owned document fields (client never writes them): `uid`, `category`, `message`, `summary` (whitespace-collapsed first 120 chars), `severity: "low"`, `status: "new"`, `duplicateCount: 1`, `note: ""`, `receivedAt: serverTimestamp()`.
- `firestore.rules`: `feedback/{feedbackId}` denies all client read/write; only the callable (Admin SDK) writes and only the admin console (firebase-admin) reads. `firestore.indexes.json` adds the `feedback` `uid`+`receivedAt` composite index backing the rate-limit query.
- The `abuse` category is intentionally excluded from the client form; abuse arrives via the reports pipeline. Admin-side status/note triage in `FeedbackInbox` remains client-local (persistence deferred; would mirror `setReportResolution`).

## Allowed Scope

- `functions/src/feedback/**`, `functions/test/submitFeedback.test.ts`, the `submitFeedback` export line in `functions/src/index.ts`, and `functions/package.json` only to register the new test file.
- `firestore.rules` (feedback deny block), `firestore.indexes.json` (feedback composite index), `tests/firebase-rules/feedback.firestore.rules.test.mjs`, and `tests/firebase-rules/package.json` only to register that rules test.
- Flutter under `implementation/mobile/runiac_app/`: the `feedback` manage action, Feedback row in both manage-row sources, the `_ManageRow` navigation branch, `flutterfire_submit_feedback_callable.dart`, `feedback_screen.dart`, and `test/feedback_screen_test.dart`.
- Admin console wiring lives in the separate `website/` repository and is outside this repo's governance scope.
- This capsule plus one append-only CURRENT routing line and the minimal governance-CI allowlist entries for the paths above.

## Forbidden Scope

- No client-side computation or write of any backend-owned value (XP, level, rank, streak, leaderboard, subscription, expert-plan state, or any feedback field beyond the two submitted keys).
- No production `runiac-fypp` deploy without separate explicit authorization.
- No new dependencies, no secrets, no changes to feed/challenge/friends/agent/notification/leaderboard functions, and no edits inside the isolated `adaptive-character-guidance` worktree.

## Validation

- `functions`: `npm run build` clean; `submitFeedback` node test suite (in-memory port) 12/12 pass; registered in the `npm test` file list.
- `tests/firebase-rules`: feedback deny suite passes with the full rules family (67/67 against the running Firestore emulator).
- Flutter: `flutter analyze --no-pub` clean; full `flutter test` suite passes including the new feedback screen tests.
- `website/`: `npm run lint` and `npm run build` pass; `/admin/feedback` builds as a dynamic route and falls back to mock data without Firebase credentials.
