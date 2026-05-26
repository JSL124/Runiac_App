# Repository Workflow Record

> **NON-OPERATIONAL RECORD:** This document is a curated process/workflow record only. It is not operational truth, approval evidence, routing authority, setup-gate authority, implementation guidance, or dependency input for tooling. If this record conflicts with `implementation/roadmap/CURRENT.md`, active roadmap capsules, ADRs, setup gates, validated snapshots, or active `AGENTS.md` instructions, those operational-authority sources control.

## Purpose

This artifact-backed workflow memory record describes the current Runiac repository workflow discipline. It exists to preserve reusable process understanding without turning `docs/meta/` into an operational source.

The record is intentionally bounded. It does not reconstruct full repository history, define approval state, replace roadmap routing, or authorize implementation work.

## Workflow Discipline Evolution

This record summarizes artifact-backed workflow checkpoints, not a complete historical reconstruction. The repository evolved toward its current governed state through a small set of visible documentation, routing, and validation structures.

The starting point was an FYP documentation baseline: product and design material, PDD references, diagrams, wireframes, and supporting notes existed as the main repository focus. The current structure reflects a later separation between assessment/design documentation and operational governance so that documentation can remain useful without becoming an execution authority.

The AGENTS instruction hierarchy became the active instruction layer for AI-assisted work. Root instructions hold global Runiac constraints, while folder-level instructions define local boundaries for documentation, PDD material, diagrams, wireframes, implementation planning, Firebase/backend work, tests, and meta/archive files.

The repository then separated PDD/reference material from operational roadmap and traceability material. `docs/pdd/` and submitted artifacts remain design or assessment-oriented, while `implementation/roadmap/`, roadmap capsules, ADRs, snapshots, and setup gates carry the current routing and governance context.

Roadmap and capsule routing became the intended workflow for bounded changes. Instead of inferring the next task from archive notes or prior work, agents are expected to read `CURRENT.md`, follow the selected phase or capsule, check relevant ADRs, and validate against the latest snapshot.

Setup gates introduced pre-scaffold controls before irreversible or external setup work. The current gate model distinguishes review readiness from execution approval and keeps Flutter scaffold execution, Firebase initialization, production source creation, builds, tests, and deployment blocked until explicit approval exists.

Governance CI was introduced as local validation support. Its checks help detect instruction drift, unrelated path changes, pre-scaffold contamination, roadmap routing issues, and sensitive-path risks. These checks support review, but they do not replace human approval or operational routing.

`docs/meta/` became the non-operational archive layer. It may preserve curated workflow learning, archive policy, schema references, and reflective process notes, but it must not become routing authority, approval evidence, setup-gate evidence, or implementation guidance.

The current governed state is therefore pre-scaffold and documentation/governance-centered. Runiac has explicit instruction hierarchy, roadmap context, setup gates, local validation checks, and meta/archive boundaries, while Flutter, Firebase, production source, production tests, and Phase 02 work remain outside this record's authority.

## Workflow Memory Recording Schema

Checkpoint numbering is approximate record order only. It is not a complete chronology or timeline.

Each checkpoint uses exactly this block format:

### CP-NN — <Short stable name>
- Trigger / context:
- Change / approach:
- Evidence basis:
- Confidence:
- Boundary / not inferred:
- Recording trigger hint:

Field constraints:
- Each field should fit in 1-3 sentences or a short bullet list.
- Recording trigger hint is one sentence only.
- Recording trigger hint is passive observation only and must not contain commands to future agents.
- Checkpoint fields should preserve workflow memory without expanding into mini-ADRs.

## Confidence Level Guide

ARTIFACT_VERIFIED
- Directly supported by committed repository artifacts.

ARTIFACT_INFERRED
- Supported by multiple artifacts, but exact rationale or sequence is partly inferred.
- The inference boundary must be stated in Boundary / not inferred.

USER_MEMORY_REQUIRED
- Cannot be safely reconstructed from repository artifacts alone.
- Use mainly in the Unknown or User-Memory-Required History section, not as a normal factual checkpoint.

UNSUPPORTED
- Not safe to claim.
- Use only to explicitly mark excluded or unsafe claims.

## Artifact-Backed Evolution Checkpoints

These checkpoints are a current repo memory aid. They separate committed artifact-backed evidence from cautious inference, and they are not a complete historical reconstruction.

### CP-01 — FYP documentation baseline
- Trigger / context: Product/design documentation, PDD references, diagrams, wireframes, and supporting notes formed the early repository focus.
- Change / approach: The repository memory records a design-documentation baseline before the later governance-centered structure became dominant.
- Evidence basis: `requirements-map.md` source baseline; root and docs AGENTS path protections; PDD/documentation paths referenced by current instructions.
- Confidence: ARTIFACT_INFERRED.
- Boundary / not inferred: Artifact presence is visible, but the exact earliest repo creation sequence and complete PRD/PDD drafting process are not reconstructed.
- Recording trigger hint: Future changes to committed baseline documentation or protected PDD/reference paths may indicate that this checkpoint should be reviewed.

### CP-02 — PRD/PDD and submitted-material protection
- Trigger / context: Submitted assessment material and PDD/reference material became protected from casual edits.
- Change / approach: Documentation protections separated stable assessment/design baselines from later governance or planning work.
- Evidence basis: `docs/AGENTS.md`; root `AGENTS.md`; `requirements-map.md` read-only source baseline.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: Protected docs are not automatically editable and do not create implementation approval.
- Recording trigger hint: Future changes to submitted-material or PDD protection rules may indicate that this checkpoint should be reviewed.

### CP-03 — Implementation boundary separation
- Trigger / context: Production implementation work was separated from documentation and planning work.
- Change / approach: Guardrails block documentation tasks from drifting into Flutter, Firebase, source, tests, builds, or deploys.
- Evidence basis: Root `AGENTS.md`; `docs/AGENTS.md`; `CURRENT.md`; `latest.md`; `setup-gates.md`.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: Phase 02, scaffold, Firebase, source, or test authorization is not inferred.
- Recording trigger hint: Future changes to documentation or implementation boundary rules may indicate that this checkpoint should be reviewed.

### CP-04 — Traceability and setup-gate creation
- Trigger / context: Requirements mapping and setup gates were introduced before scaffold/setup execution.
- Change / approach: Future implementation planning was tied to PRD/PDD traceability and explicit gates before irreversible or external setup actions.
- Evidence basis: `requirements-map.md`; `setup-gates.md`; recent traceability commits.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: Gate evidence is not approval to execute scaffold/setup commands.
- Recording trigger hint: Future setup-gate or traceability changes may indicate that this checkpoint should be reviewed.

### CP-05 — Roadmap and `CURRENT.md` operating model
- Trigger / context: Active work began routing through `implementation/roadmap/CURRENT.md`, active phases/capsules, ADRs, and snapshots.
- Change / approach: The workflow established one current operational context to reduce stale-context and archive-driven decisions.
- Evidence basis: `AGENTS.md` roadmap context protocol; `CURRENT.md`; `latest.md`.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: This record and other `docs/meta` files are not routing authority.
- Recording trigger hint: Future changes to roadmap context routing may indicate that this checkpoint should be reviewed.

### CP-06 — Capsule-based execution model
- Trigger / context: Bounded tasks began using roadmap capsules with explicit scope, forbidden work, validation, and exit criteria.
- Change / approach: Short-lived task boundaries were used to prevent scope creep and keep work inside selected capsule scope.
- Evidence basis: `implementation/roadmap/capsules/`; Repository Workflow Record capsule; capsule template.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: A capsule is not permission for work outside its listed scope.
- Recording trigger hint: Future capsule model or template changes may indicate that this checkpoint should be reviewed.

### CP-07 — ADR and tier-gate persistence
- Trigger / context: ADRs and setup gates preserved durable decisions about tier/access, emulator-first direction, and scaffold readiness.
- Change / approach: The repository records stable decisions before implementation choices proceed.
- Evidence basis: ADR files listed in `CURRENT.md`; `setup-gates.md`; `requirements-map.md`.
- Confidence: ARTIFACT_INFERRED.
- Boundary / not inferred: The stored decisions are artifact-backed, but unlisted ADR decisions and unstored human rationale are not claimed.
- Recording trigger hint: Future ADR or setup-gate persistence changes may indicate that this checkpoint should be reviewed.

### CP-08 — Governance CI local validation checks
- Trigger / context: Local governance checks were added for roadmap routing, sensitive paths, pre-scaffold scope, historical isolation, diff hygiene, and agent governance.
- Change / approach: Repeatable local checks support readiness review by catching workflow drift before readiness claims.
- Evidence basis: `tools/governance-ci/`; `latest.md`; recent governance CI commits.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: CI support does not replace human approval, A6/A8 review, or operational routing.
- Recording trigger hint: Future Governance CI check changes may indicate that this checkpoint should be reviewed.

### CP-09 — Agent-review workflow
- Trigger / context: A0_ORCH, A6_REVIEW, A8_OUTPUT_CHECKER, and A14_ERROR_TRIAGE became explicit review lenses for routing, consistency, completeness, and concrete error triage.
- Change / approach: Named review passes let agent work be checked without assuming real parallel subagents.
- Evidence basis: Root `AGENTS.md`; `docs/AGENTS.md`; `setup-gates.md`; `tools/agent-review/`; traceability review artifacts.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: This does not claim every past task used the workflow correctly without reading its task evidence.
- Recording trigger hint: Future changes to review lenses or agent-review tooling may indicate that this checkpoint should be reviewed.

### CP-10 — `docs/meta` non-operational archive boundary
- Trigger / context: Meta files were explicitly limited to reflective, historical, or schema-only context.
- Change / approach: Long-term memory was separated from operational truth, routing authority, approval evidence, setup-gate evidence, and implementation guidance.
- Evidence basis: `docs/meta/AGENTS.md`; `META_KNOWLEDGE_ARCHITECTURE.md`; `ARTIFACT_INVENTORY_SCHEMA.md`; this record's banner.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: `docs/meta` must not be used as approval evidence, routing authority, setup-gate authority, or implementation guidance.
- Recording trigger hint: Future changes to `docs/meta` authority boundaries may indicate that this checkpoint should be reviewed.

### CP-11 — Artifact Inventory Schema creation
- Trigger / context: A schema-only meta document was persisted without creating inventory entries.
- Change / approach: A controlled future inventory shape was recorded while blocking live inventory, timelines, Genesis material, or autonomous archives.
- Evidence basis: `ARTIFACT_INVENTORY_SCHEMA.md`; `CURRENT.md`; `latest.md`; artifact inventory capsule routing/completion references.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: Inventory entries are not created, and artifact authority is not inferred from the schema.
- Recording trigger hint: Future artifact inventory schema or entry-scope changes may indicate that this checkpoint should be reviewed.

### CP-12 — AGENTS hierarchy refinement
- Trigger / context: Root and folder-level AGENTS files became the active instruction hierarchy for global and local scope rules.
- Change / approach: Concise global rules and folder-specific boundaries reduce duplicated or conflicting instructions.
- Evidence basis: Root `AGENTS.md`; `docs/AGENTS.md`; `docs/meta/AGENTS.md`; documentation-scope commit context in `latest.md`.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: Planning or meta files are not active instructions unless explicitly routed.
- Recording trigger hint: Future AGENTS hierarchy changes may indicate that this checkpoint should be reviewed.

### CP-13 — Repository Workflow Record routing
- Trigger / context: A bounded non-operational workflow record was routed under `docs/meta`.
- Change / approach: A practical process memory aid was recorded without creating a Genesis file, timeline, or full history reconstruction.
- Evidence basis: `CURRENT.md`; `latest.md`; Repository Workflow Record capsule; this document.
- Confidence: ARTIFACT_INFERRED.
- Boundary / not inferred: The active route is artifact-backed, but human motivation is not fully reconstructed and this record is not complete history or operational authority.
- Recording trigger hint: Future changes to Repository Workflow Record routing or closure state may indicate that this checkpoint should be reviewed.

### CP-14 — Current governed pre-scaffold state
- Trigger / context: The current repo state is governed, pre-scaffold, and documentation/governance-centered.
- Change / approach: Existing workflow choices support implementation preparation without authorizing scaffold/setup execution.
- Evidence basis: `CURRENT.md`; `latest.md`; `setup-gates.md`; root AGENTS; governance CI files.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: Flutter scaffold execution, Firebase setup, Phase 02, source, tests, builds, init, deploy, or production implementation are not inferred.
- Recording trigger hint: Future changes to scaffold/setup authorization or repository implementation state may indicate that this checkpoint should be reviewed.

### CP-15 — Agent-review output template standardization
- Trigger / context: The agent-review workflow gained a Level 1.5 output/review-template layer after a workflow-impacting patch was pushed.
- Change / approach: Standardized Codex output and review-gate expectations were added as reusable templates, with Governance CI diff hygiene narrowly allowing Markdown template files under `tools/agent-review/templates/`.
- Evidence basis: `2c56893 chore(agent-review): add output and review templates`; pushed/recorded on 2026-05-26 15:09 SGT; `tools/agent-review/templates/CODEX_OUTPUT_TEMPLATE.md`; `tools/agent-review/templates/REVIEW_GATE_TEMPLATE.md`; `tools/governance-ci/check-diff-hygiene.sh`; Governance CI passed before push.
- Confidence: ARTIFACT_VERIFIED.
- Boundary / not inferred: This records workflow-template standardization only; it does not claim that every future task used the templates correctly, and it does not create implementation, setup, scaffold, Firebase, build, test, deploy, staging, commit, or push approval.
- Recording trigger hint: Future changes to agent-review output templates, review-gate templates, or their Governance CI allowlist may indicate that this checkpoint should be reviewed.

## Unknown or User-Memory-Required History

The current repo memory cannot safely reconstruct every part of the human workflow. These items align with USER_MEMORY_REQUIRED and require human memory, external chat summaries, or additional artifact-backed evidence:

- The exact earliest repo creation sequence.
- Chat-only decisions that were not persisted into committed artifacts.
- Exact human motivations unless they are encoded in artifacts.
- Full commit-by-commit chronology.
- Complete early PRD/PDD creation process.
- Any operational approval not recorded in operational authority files.
- Whether every completed task used the intended A0/A6/A8/A14 flow correctly.
- The exact reason each governance safeguard was added when the reason is only implied by later artifacts.

## Current Discipline

Runiac currently uses layered context retrieval before work begins. The intended workflow starts from `implementation/roadmap/CURRENT.md`, then follows any active phase or capsule routing, relevant ADRs, and `implementation/roadmap/snapshots/latest.md`. Folder-level `AGENTS.md` files then provide local scope rules for the area being changed.

This discipline keeps active operational truth separate from reflective archive material. `docs/meta/` may preserve curated workflow learning, but it must not drive routing, approval, setup gates, or implementation decisions.

## Capsule-Based Execution

Bounded work is routed through explicit roadmap context or a capsule before files are changed. A capsule should define purpose, allowed files, forbidden actions, validation requirements, and review expectations.

For documentation/governance tasks, the capsule boundary is used to prevent drift into implementation, source generation, setup actions, broad archive creation, or unapproved historical reconstruction.

## Validation-First Workflow

The current discipline expects repository state to be verified before work starts. Typical checks include clean working tree status, branch alignment, recent commit context, active roadmap state, and relevant snapshot state.

Validation results must be reported as actual command results. Expected outputs must not be presented as if they were observed.

## A0/A6/A8 Review Discipline

A0_ORCH owns routing, mode coordination, and task classification. For bounded documentation/governance work, A0_ORCH identifies the active scope, chooses the responsible path, and keeps implementation work out of documentation-only tasks.

A6_REVIEW checks consistency, governance boundaries, architecture drift, role and subscription terminology, backend-owned progression rules, and conflicts with operational authority.

A8_OUTPUT_CHECKER checks completeness, readiness claims, modified file lists, validation evidence, and whether the output stays inside the approved scope.

## Human Approval Gates

Human approval remains required for Tier 1 or external work, especially irreversible actions. The current setup-gate discipline separates review readiness from execution approval.

Review results, clean status, or agent-generated decisions do not authorize Flutter scaffold execution, Firebase setup, production service changes, deployment, source creation, or tests unless a human-approved task explicitly grants that scope.

## Commit and Push Discipline

The repository uses explicit commit and push discipline. Work should be reviewed before readiness claims, task-relevant files should be staged intentionally, and unrelated changes should remain untouched.

Push actions should be separately approved when required by the task. Commit messages should match the repository style and distinguish documentation, agents, diagrams, wireframes, implementation features, and fixes.

## Non-Operational Meta Boundary

`docs/meta/` is a reflective archive. Its content may explain workflow discipline, archive policy, schemas, or curated engineering learning, but it must not become operational authority.

This record does not create artifact inventory entries, timelines, repository Genesis material, autonomous archive systems, or approval evidence. It does not replace ADRs, setup gates, snapshots, roadmap routing, or active instructions.

## Pre-Scaffold Boundary

Runiac remains in a pre-scaffold governance state until separately approved work changes that state. This record does not authorize Flutter scaffold execution, Firebase initialization, dependency installation, builds, deploys, production source files, generated platform files, or production tests.

Any future scaffold or setup action must follow the active roadmap context, setup gates, ADRs, and explicit human approval.

## Backend-Owned Progression Boundary

The workflow discipline preserves the Runiac rule that official XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP are backend-owned. Flutter may display trusted values, but the client must not directly calculate or write official progression or competitive ranking fields.

Cloud Functions and backend enforcement remain responsible for trusted progression and leaderboard updates when implementation is eventually authorized. Premium features must not create competitive scoring advantages.

## Use and Limits

Use this document only as a bounded process reference when a human explicitly asks for meta/archive or workflow context.

Do not use this document to infer current approval state, select implementation work, bypass roadmap routing, satisfy setup gates, or load archive material into ordinary operational planning.
