# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

# Claude Code Reviewer Instructions

Claude Code is an external reviewer for Runiac planning work. Claude reviews Codex-generated plans and reports risks, gaps, and recommendations. Claude must not execute implementation changes unless the user explicitly requests that work.

Claude should review plans for:

- Risky assumptions or missing constraints.
- Unsafe file operations, broad rewrites, generated-file churn, or missing git-safety gates.
- Flutter and Firebase convention conflicts.
- PRD, submitted PDD, and current working PDD mismatches.
- Overengineering beyond the submitted PDD baseline or current implementation phase.
- Missing approval gates before Codex implementation.

Claude should treat `docs/submissions/pdd/` as the frozen submitted PDD reference. Claude may use `docs/pdd/` as internal working context, but it should not treat those files as replacing the submitted assessment snapshot.

In plan-review mode, Claude must use read-only tools only. Do not use Bash, Edit, Write, filesystem-modifying tools, `dangerously-skip-permissions`, `bypassPermissions`, `auto`, or `acceptEdits` modes.

# Repository Orientation

The rules above (from `@AGENTS.md`) are authoritative and override the reference material below. The default mode is **PDD_MODE** (documentation/planning review); IMPLEMENTATION_MODE work requires an explicit user request. `implementation/roadmap/CURRENT.md` is the operational source of truth for what is currently in scope, forbidden, and gated — read it before any implementation or validation action, and treat the commands below as reference only, not license to run them.

## Layout

- `implementation/mobile/runiac_app/` — the Flutter app (only Flutter package in the repo). Organized feature-first: `lib/core/` (theme, firebase bootstrap, contracts, shared widgets) and `lib/features/<feature>/{data,domain,presentation}` (home, run, maps, leaderboard, you, auth, onboarding, account, plan, shell, splash).
- `functions/` — Firebase Cloud Functions (TypeScript, ESM, Node 22). Only trusted server-owned logic lives here; `src/index.ts` re-exports the `completeRun` callable.
- `firestore.rules`, `firestore.indexes.json`, `firebase.json` — Firestore security rules, indexes, and emulator config (functions:5001, firestore:8080, auth:9099).
- `tests/` — cross-system tests only: `tests/firebase-rules/` (rules-unit-testing), `tests/functions-integration/`, `tests/e2e/`, `tests/governance/`. Flutter unit/widget/integration tests live inside the app at `runiac_app/test/` and `runiac_app/integration_test/`.
- `tools/governance-ci/` — governance gate scripts, orchestrated by `run-all-checks.sh`.
- `docs/pdd/` — working PDD design docs; `docs/submissions/` — frozen submitted PDD snapshot (do not modify). `PRD.md`, `wireframe.md`, `PDD_diagram_plan.md` are top-level design references.

## Architecture (client / server trust boundary)

The central invariant (see the Non-Negotiable rules in `@AGENTS.md`): the **client renders, the server owns truth**. Flutter handles UI, navigation, GPS tracking UI, and local interaction; Firebase Auth handles identity; Firestore stores users/plans/activities/routes/XP/leaderboard data; Cloud Functions compute all XP, level, rank, streak, leaderboard score, weekly/monthly XP, subscription privilege, and expert-plan publication state. The client must never calculate or write those backend-owned values — it may only display trusted values it reads back. `subscriptionStatus` gates Basic/Premium feature access; `userRole` gates governance access. Premium users get feature access only, never competitive advantage (no XP/rank/leaderboard benefit).

Current implementation reality (per `CURRENT.md`) is a scaffold-plus-narrow-vertical-slice: mostly static Flutter UI, a foreground GPS run-tracking engine with a Mapbox map surface (gated by a runtime-only `MAPBOX_PUBLIC_ACCESS_TOKEN` dart-define), bounded production Firebase Auth for project `runiac-fypp`, and a single emulator-guarded `completeRun` callable (region `asia-southeast1`, activated only when `RUNIAC_FIREBASE_EMULATOR=true`). Broad Firestore persistence, real XP/streak/leaderboard formulas, and route/GPS trace upload are **not yet implemented and are forbidden without explicit routing**.

## Commands (reference — run only when explicitly authorized)

Flutter (from `implementation/mobile/runiac_app/`):
- `flutter pub get` — install dependencies
- `flutter analyze --no-pub` — lint/static analysis (used by CI)
- `flutter test` — run all widget/unit tests
- `flutter test test/path/to/foo_test.dart` — run a single test file
- `flutter run --dart-define=MAPBOX_PUBLIC_ACCESS_TOKEN=...` — run with a runtime-only Mapbox token (never commit the token)

Cloud Functions (from `functions/`):
- `npm run build` — `tsc` compile to `lib/`
- `npm test` — build, then run node test suites against the functions+firestore emulators (project `runiac-functions-test`)

Firestore rules tests (from `tests/firebase-rules/`):
- `npm test` — runs `firebase emulators:exec --only firestore` over the rules test suites

Governance CI (from repo root, `/Users/leejinseo/Desktop/FYP_Runiac`):
- `./tools/governance-ci/run-all-checks.sh` — runs all canonical-root, diff-hygiene, roadmap-routing, sensitive-path, and scope gates; must pass before commit
- `git diff --check` — whitespace/conflict-marker gate (part of CI)

The hosted GitHub Actions `governance-ci` workflow runs `git diff --check`, `run-all-checks.sh`, then `flutter pub get` / `flutter analyze --no-pub` / `flutter test`.
