# Runiac Current Roadmap Context

## Current Routing

- Current track: Track A - Governance and implementation readiness
- Current phase: `implementation/roadmap/phases/phase-01-governance-ci.md`
- Current active capsule: `implementation/roadmap/capsules/artifact-inventory-schema-persistence.md`
- Current status: Phase 01 governance CI closed; repository remains pre-scaffold
- Current state: Post-Phase-01 governance follow-up planning; planning and review only
- Current active milestone: Artifact Inventory Schema persistence routing

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
- Maintain the active Artifact Inventory Schema persistence routing capsule under `implementation/roadmap/capsules/`.
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

Run A6_REVIEW and A8_OUTPUT_CHECKER on any proposed next-phase routing.

The selected next routing option is governance follow-up planning through `implementation/roadmap/capsules/artifact-inventory-schema-persistence.md`.

This routing selection authorizes planning and review for a future bounded documentation capsule targeting `docs/meta/ARTIFACT_INVENTORY_SCHEMA.md`. It does not create or approve creation of that schema document in the current routing patch.

This planning gate does not approve Phase 02 implementation, Flutter scaffold execution, Firebase setup, dependency installation, build, init, deploy, or production implementation.
