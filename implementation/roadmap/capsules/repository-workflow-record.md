# Repository Workflow Record Capsule

## Purpose

Route creation of a bounded, non-operational Repository Workflow Record under `docs/meta/`.

The record may summarize the current Runiac repository workflow discipline as a curated process/workflow note. It must remain informational and must not become operational truth, approval evidence, routing authority, setup-gate authority, or implementation guidance.

## Scope

Allowed files for this capsule:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/capsules/repository-workflow-record.md`
- `implementation/roadmap/snapshots/latest.md`
- `docs/meta/REPOSITORY_WORKFLOW_RECORD.md`

No other files are in scope unless a future human-approved routing prompt explicitly expands the scope.

## Non-Operational Boundary

`docs/meta/` remains a non-operational historical and reflective archive.

The Repository Workflow Record must not override or reinterpret:

- `implementation/roadmap/CURRENT.md`
- active roadmap phase or capsule documents
- ADRs
- setup gates
- validated snapshots
- active `AGENTS.md` instructions

If the workflow record conflicts with operational-authority sources, the operational-authority sources control.

## Explicitly Forbidden Content

This capsule does not authorize:

- Repository Genesis material or `REPOSITORY_GENESIS.md`
- timelines
- full repository history reconstruction
- retrospectives
- artifact inventory entries
- autonomous archive or index systems
- operational approval evidence
- Phase 02 implementation
- Flutter scaffold execution
- Firebase setup or `firebase init`
- build, deploy, init, scaffold, source, or test work
- production Flutter, Firebase, backend, Cloud Functions, or test files

## Required Record Boundaries

The workflow record may describe the current discipline at a high level:

- layered context retrieval
- capsule-based execution
- validation-first workflow
- A0/A6/A8 review discipline
- human approval gates
- commit and push discipline
- `docs/meta` non-operational boundary
- pre-scaffold boundary
- backend-owned XP, streak, level, rank, and leaderboard boundary

The record must use cautious language such as "current discipline", "intended workflow", and "artifact-backed summary". It must not claim complete history, perfect safety, or immutable process.

## Validation Requirements

Before any readiness claim:

- Confirm changes are limited to the allowed files.
- Confirm the Repository Workflow Record has a clear non-operational warning banner.
- Confirm no Genesis material, timelines, full history reconstruction, retrospectives, inventory entries, or autonomous archive/index systems were added.
- Confirm no Phase 02, Flutter, Firebase, scaffold, init, build, deploy, source, or test authorization was introduced.
- Confirm `docs/meta` remains non-operational.
- Run A6_REVIEW and A8_OUTPUT_CHECKER.

## Status

Status: Active for the bounded documentation/governance routing patch.

This capsule does not authorize implementation work.
