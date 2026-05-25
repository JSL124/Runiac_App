# Repository Workflow Record

> **NON-OPERATIONAL RECORD:** This document is a curated process/workflow record only. It is not operational truth, approval evidence, routing authority, setup-gate authority, implementation guidance, or dependency input for tooling. If this record conflicts with `implementation/roadmap/CURRENT.md`, active roadmap capsules, ADRs, setup gates, validated snapshots, or active `AGENTS.md` instructions, those operational-authority sources control.

## Purpose

This artifact-backed summary describes the current Runiac repository workflow discipline at a high level. It exists to preserve reusable process understanding without turning `docs/meta/` into an operational source.

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

## Artifact-Backed Evolution Checkpoints

This table is a current repo memory aid. It separates committed artifact-backed evidence from cautious inference, and it is not a complete historical reconstruction.

| Checkpoint | What changed | Why this appears to have happened | Evidence basis | Confidence | Boundary / unsafe claim |
| --- | --- | --- | --- | --- | --- |
| FYP documentation baseline | Product/design documentation, PDD references, diagrams, wireframes, and supporting notes formed the early repository focus. | Evidence suggests the repo began as an FYP documentation and design repository before implementation governance became dominant. | `requirements-map.md` source baseline; root and docs AGENTS path protections; PDD/documentation paths referenced by current instructions. | Medium - artifact-backed existence, inferred origin order. | Do not claim the exact earliest repo creation sequence or full PRD/PDD drafting process. |
| PRD/PDD and submitted-material protection | Submitted assessment material and PDD/reference material became protected from casual edits. | Evidence suggests the human needed stable assessment/design baselines while allowing later governance work to continue elsewhere. | `docs/AGENTS.md`; root `AGENTS.md`; `requirements-map.md` read-only source baseline. | High - committed instruction evidence. | Do not treat protected docs as automatically editable or as implementation approval. |
| Implementation boundary separation | Production implementation work was separated from documentation and planning work. | Evidence suggests the repo needed to prevent documentation tasks from drifting into Flutter, Firebase, source, tests, builds, or deploys. | Root `AGENTS.md`; `docs/AGENTS.md`; `CURRENT.md`; `latest.md`; `setup-gates.md`. | High - repeated committed guardrails. | Do not infer Phase 02, scaffold, Firebase, source, or test authorization. |
| Traceability and setup-gate creation | Requirements mapping and setup gates were introduced before scaffold/setup execution. | Evidence suggests the human wanted future implementation to trace back to PRD/PDD requirements and pass explicit gates before irreversible setup actions. | `requirements-map.md`; `setup-gates.md`; recent traceability commits. | High - committed planning artifacts. | Gate evidence is not the same as approval to execute scaffold/setup commands. |
| Roadmap and `CURRENT.md` operating model | Active work began routing through `implementation/roadmap/CURRENT.md`, active phases/capsules, ADRs, and snapshots. | Evidence suggests the repo needed one current operational context to reduce stale-context and archive-driven decisions. | `AGENTS.md` roadmap context protocol; `CURRENT.md`; `latest.md`. | High - committed operational-routing evidence. | Do not use this record or other `docs/meta` files as routing authority. |
| Capsule-based execution model | Bounded tasks began using roadmap capsules with explicit scope, forbidden work, validation, and exit criteria. | Evidence suggests the workflow needed short-lived task boundaries that prevent scope creep. | `implementation/roadmap/capsules/`; active Repository Workflow Record capsule; capsule template. | High - committed capsule structure. | Do not treat a capsule as permission for work outside its listed scope. |
| ADR and tier-gate persistence | ADRs and setup gates preserved durable decisions about tier/access, emulator-first direction, and scaffold readiness. | Evidence suggests stable decision records were needed before implementation choices could safely proceed. | ADR files listed in `CURRENT.md`; `setup-gates.md`; `requirements-map.md`. | Medium - artifact-backed presence, inferred rationale. | Do not claim unlisted ADR decisions or unstored human rationale. |
| Governance CI local validation checks | Local governance checks were added for roadmap routing, sensitive paths, pre-scaffold scope, historical isolation, diff hygiene, and agent governance. | Evidence suggests the repo needed repeatable local checks to catch workflow drift before readiness claims. | `tools/governance-ci/`; `latest.md`; recent governance CI commits. | High - committed tooling and snapshot evidence. | CI support does not replace human approval, A6/A8 review, or operational routing. |
| Agent-review workflow | A0_ORCH, A6_REVIEW, A8_OUTPUT_CHECKER, and A14_ERROR_TRIAGE became explicit review lenses for routing, consistency, completeness, and concrete error triage. | Evidence suggests the repo needed named review passes so agent work could be checked without assuming real parallel subagents. | Root `AGENTS.md`; `docs/AGENTS.md`; `setup-gates.md`; `tools/agent-review/`; traceability review artifacts. | High - committed instructions and tooling evidence. | Do not claim every past task used the workflow correctly without reading its task evidence. |
| `docs/meta` non-operational archive boundary | Meta files were explicitly limited to reflective, historical, or schema-only context. | Evidence suggests the human wanted long-term memory without allowing archive notes to become operational truth. | `docs/meta/AGENTS.md`; `META_KNOWLEDGE_ARCHITECTURE.md`; `ARTIFACT_INVENTORY_SCHEMA.md`; this record's banner. | High - committed boundary evidence. | Do not use `docs/meta` as approval evidence, routing authority, setup-gate authority, or implementation guidance. |
| Artifact Inventory Schema creation | A schema-only meta document was persisted without creating inventory entries. | Evidence suggests the repo wanted a controlled future inventory shape while blocking live inventory, timelines, Genesis material, or autonomous archives. | `ARTIFACT_INVENTORY_SCHEMA.md`; `CURRENT.md`; `latest.md`; artifact inventory capsule routing/completion references. | High - committed artifact and routing evidence. | Do not create inventory entries or infer artifact authority from the schema. |
| AGENTS hierarchy refinement | Root and folder-level AGENTS files became the active instruction hierarchy for global and local scope rules. | Evidence suggests the repo needed concise global rules plus folder-specific boundaries to avoid duplicated or conflicting instructions. | Root `AGENTS.md`; `docs/AGENTS.md`; `docs/meta/AGENTS.md`; documentation-scope commit context in `latest.md`. | High - committed instruction evidence. | Do not treat planning or meta files as active instructions unless explicitly routed. |
| Repository Workflow Record routing | A bounded non-operational workflow record was routed under `docs/meta`. | Evidence suggests the human wanted a practical process memory aid without creating a Genesis file, timeline, or full history reconstruction. | `CURRENT.md`; `latest.md`; active workflow-record capsule; this document. | High for active route; medium for human motivation. | Do not claim this record is complete history or operational authority. |
| Current governed pre-scaffold state | The current repo state is governed, pre-scaffold, and documentation/governance-centered. | Evidence suggests prior workflow choices shaped a repo that can prepare implementation without yet authorizing scaffold/setup execution. | `CURRENT.md`; `latest.md`; `setup-gates.md`; root AGENTS; governance CI files. | High - committed current-state evidence. | Do not infer Flutter scaffold execution, Firebase setup, Phase 02, source, tests, builds, init, deploy, or production implementation. |

## Unknown or User-Memory-Required History

The current repo memory cannot safely reconstruct every part of the human workflow. These items require human memory, external chat summaries, or additional artifact-backed evidence:

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

Human approval remains required for higher-risk work, especially irreversible or external actions. The current setup-gate discipline separates review readiness from execution approval.

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
