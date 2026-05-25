# Runiac Current Roadmap Context

## Current Routing

- Current track: Track A - Governance and implementation readiness
- Current phase: `implementation/roadmap/phases/phase-01-governance-ci.md`
- Current status: Phase 00 governance freeze closed; Phase 01 governance CI active; Governance CI check contract and local shell checks committed
- Current active milestone: Capsule 2 complete; Phase 01 post-implementation roadmap update and review

## Required Reading Order

1. `implementation/roadmap/CURRENT.md`
2. Active phase document listed above
3. Relevant ADRs listed below
4. `implementation/roadmap/snapshots/latest.md`

Do not load future phase documents unless explicitly requested.

## Relevant ADRs

- `implementation/roadmap/decisions/ADR-001-tier-gate-system.md`
- `implementation/roadmap/decisions/ADR-002-emulator-first.md`

## Allowed Work

- Maintain roadmap/context governance files under `implementation/roadmap/`.
- Maintain root `AGENTS.md` roadmap context protocol when required.
- Update `snapshots/latest.md` from confirmed repository state only.
- Update CURRENT.md immediately when active phase, active capsule, gate status, or forbidden scope changes.

## Forbidden Work

- Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands.
- Do not create production implementation code.
- Do not modify existing implementation logic.
- Do not modify `docs/submissions/`, `PRD.md`, or frozen submitted PDD snapshots.
- Do not load `roadmap-stretch.md`, archived snapshots, or future phase docs unless explicitly requested.

## Next Gate

Run A6_REVIEW and A8_OUTPUT_CHECKER on this post-implementation roadmap update, then prepare the next Phase 01 closure or routing update only after review approval. Do not advance Flutter scaffold approval or execution.
