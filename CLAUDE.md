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

## Commands (reference — run only when explicitly authorized)

Non-obvious invocations (standard `flutter`/`npm` commands are omitted — read the manifests):
- `flutter run --dart-define=MAPBOX_PUBLIC_ACCESS_TOKEN=...` (from `implementation/mobile/runiac_app/`) — the Mapbox token is runtime-only; never commit it.
- `./tools/governance-ci/run-all-checks.sh` (from repo root) — governance gates; must pass before commit.
